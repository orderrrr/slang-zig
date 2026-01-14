const std = @import("std");
const FixedBufferAllocator = std.heap.FixedBufferAllocator;
const Allocator = std.mem.Allocator;
const AutoHashMap = std.AutoHashMap;
const ArrayList = std.ArrayList;
const StringHashMap = std.StringHashMap;

const slang = @import("slang");

const SlangError = @import("./error.zig").SlangError;

pub const annotation = @import("./annotation.zig");
pub const Annotation = annotation.Annotation;
pub const UserAttribute = annotation.UserAttribute;

pub const Binding = @import("./binding.zig");
pub const BindingType = Binding.BindingType;

pub const Resource = @import("./resource.zig");
pub const ResourceType = Resource.ResourceType;

pub const Type = @import("type.zig").Type;
pub const Variable = @import("variable.zig");
pub const VariableWithAnnotation = Variable.VariableWithAnnotation;
pub const Function = @import("function.zig");

pub const Reflection = struct {
    const Self = @This();

    allocator: Allocator,
    reflection: slang.Reflection,
    metadata: slang.IMetadata,

    function: Function,
    stage: slang.Stage,

    uniform_bindings: ArrayList(Binding),
    sampled_texture_bindings: ArrayList(Binding),
    storage_buffer_bindings: ArrayList(Binding),
    storage_texture_bindings: ArrayList(Binding),

    uniform_totals: u32,
    read_write_totals: u32,
    read_only_totals: u32,

    pub fn init(reflection: slang.Reflection, i: u32, allocator: Allocator) !Self {
        var er: Self = .{
            .allocator = allocator,
            .reflection = reflection,
            .metadata = reflection.metadata,

            .function = try Function.from(&reflection.getEntryPointByIndex(i).getFunction(), allocator),
            .stage = reflection.getEntryPointByIndex(i).getStage(),

            .uniform_bindings = .{},
            .sampled_texture_bindings = .{},
            .storage_buffer_bindings = .{},
            .storage_texture_bindings = .{},

            .uniform_totals = 0,
            .read_write_totals = 0,
            .read_only_totals = 0,
        };

        try er.processResources();

        return er;
    }

    pub fn processResources(self: *Self) !void {
        for (0..self.reflection.getParameterCount()) |i| {
            try self.processResource(self.reflection.getParameterByIndex(@intCast(i)), null);
        }

        const ep = self.reflection.getEntryPointByIndex(0);
        for (0..ep.getParameterCount()) |i| {
            try self.processResource(ep.getParameterByIndex(@intCast(i)), null);
        }
    }

    pub fn processResource(self: *Self, param: slang.VariableLayoutReflection, inSlot: ?u32) !void {
        switch (param.getCategory()) {
            .SUB_ELEMENT_REGISTER_SPACE => {
                const typeLayout = param.getType();
                switch (typeLayout.getKind()) {
                    .PARAMETER_BLOCK => {
                        for (0..typeLayout.getElementType().getFieldCount()) |i| {
                            try self.processResource(typeLayout.getElementType().getFieldByIndex(@intCast(i)), inSlot orelse param.getBindingIndex());
                        }
                    },
                    .CONSTANT_BUFFER => {
                        const tl = param.getType();
                        for (0..tl.getElementType().getFieldCount()) |i| {
                            try self.processResource(tl.getElementType().getFieldByIndex(@intCast(i)), inSlot orelse param.getBindingIndex());
                        }
                    },
                    else => {
                        std.log.info("Unknown type kind: {any}", .{typeLayout.getKind()});
                        return SlangError.UnknownTypeKind;
                    },
                }
            },
            .DESCRIPTOR_TABLE_SLOT => {
                const values = try types(param);
                const bindingType = values[0];
                const resourceType = values[1];

                if (!self.bindingUsed(bindingType, resourceType)) return;

                var binding: *ArrayList(Binding) = switch (resourceType) {
                    .Uniform => &self.uniform_bindings,
                    .Texture => switch (bindingType) {
                        .Sampled => &self.sampled_texture_bindings,
                        .ReadWrite, .ReadOnly => &self.storage_texture_bindings,
                        else => return SlangError.InvalidBindingType,
                    },
                    .Buffer => &self.storage_buffer_bindings,
                };

                // TODO: check if it's not the same buffer
                const resource: Resource = .{
                    .name = try self.allocator.dupe(u8, param.getVariable().getName()),
                    .resourceType = resourceType,
                    .type = try Type.from(&param.getType(), self.allocator),
                    .userAttributes = try VariableWithAnnotation.getAnnotation(&param.getVariable(), self.allocator),
                };

                try binding.append(self.allocator, .{
                    .resource = resource,
                    .bindingType = bindingType,
                    .userAttributes = try VariableWithAnnotation.getAnnotation(&param.getVariable(), self.allocator),
                });
            },
            .NONE => {},
            else => {
                std.log.info("Unknown parameter category: {any}", .{param.getCategory()});
                return SlangError.UnknownParameterCategory;
            },
        }
    }

    pub fn bindingUsed(self: *Self, bindingType: BindingType, resourceType: ResourceType) bool {
        const bindingCount: *u32 = switch (resourceType) {
            .Uniform => &self.uniform_totals,
            .Texture => switch (bindingType) {
                .Sampled => &self.read_only_totals,
                .ReadWrite, .ReadOnly => &self.read_write_totals,
                .Uniform => &self.uniform_totals, // fallback
            },
            .Buffer => &self.read_write_totals,
        };

        const stageId: u32 = switch (self.stage) {
            .VERTEX => switch (bindingType) {
                .ReadOnly, .ReadWrite, .Sampled => 0,
                .Uniform => 1,
            },
            .FRAGMENT => switch (bindingType) {
                .ReadOnly, .ReadWrite, .Sampled => 0,
                .Uniform => 3,
            },
            .COMPUTE => switch (bindingType) {
                .ReadOnly, .Sampled => 0,
                .ReadWrite => 1,
                .Uniform => 2,
            },
            else => {
                std.log.info("Unknown shader stage: {any}", .{self.stage});
                return false;
            },
        };

        var used: bool = false;
        if (!slang.IMetadata_isParameterLocationUsed(self.metadata, .DESCRIPTOR_TABLE_SLOT, stageId, @intCast(bindingCount.*), &used).isSuccess()) {
            std.log.info("Failed to check parameter location usage", .{});
        }

        std.log.info("Binding type: {any}, usage: {any} at index: {any} and slot: {any} used: {any}", .{
            resourceType, bindingType, bindingCount.*, stageId, used,
        });

        bindingCount.* += 1;

        // bind all for now
        return true;
    }

    fn types(param: slang.VariableLayoutReflection) SlangError!std.meta.Tuple(&.{ BindingType, ResourceType }) {
        const kind = param.getType().getKind();
        const shape = param.getType().getResourceShape().primitiveShape();
        const access = param.getType().getResourceAccess();

        return switch (kind) {
            .RESOURCE => switch (shape) {
                .Texture => switch (access) {
                    .SLANG_RESOURCE_ACCESS_READ => .{ .ReadOnly, .Texture },
                    else => .{ .ReadWrite, .Texture },
                },
                .StorageBuffer => switch (access) {
                    .SLANG_RESOURCE_ACCESS_READ => .{ .ReadOnly, .Buffer },
                    else => .{ .ReadWrite, .Buffer },
                },
                .SampledTexture => .{ .Sampled, .Texture },
                .Unknown, .ByteAddressBuffer => {
                    std.log.info("Unknown resource shape: {any}", .{shape});
                    return SlangError.UnknownResourceShape;
                },
            },
            .CONSTANT_BUFFER => .{ .Uniform, .Uniform },
            else => {
                std.log.info("Unknown resource type kind: {any}", .{kind});
                return SlangError.UnknownResourceType;
            },
        };
    }

    pub fn jsonStringify(self: *const Self, jw: anytype) !void {
        try jw.beginObject();

        try jw.objectField("function");
        try jw.write(self.function);

        try jw.objectField("stage");
        try jw.write(self.stage);

        try jw.objectField("uniform_bindings");
        try jw.write(self.uniform_bindings.items);

        try jw.objectField("sampled_texture_bindings");
        try jw.write(self.sampled_texture_bindings.items);

        try jw.objectField("storage_buffer_bindings");
        try jw.write(self.storage_buffer_bindings.items);

        try jw.objectField("storage_texture_bindings");
        try jw.write(self.storage_texture_bindings.items);

        try jw.endObject();
    }
};
