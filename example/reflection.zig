const std = @import("std");
const FixedBufferAllocator = std.heap.FixedBufferAllocator;
const Allocator = std.mem.Allocator;
const AutoHashMap = std.AutoHashMap;
const ArrayList = std.ArrayList;
const StringHashMap = std.StringHashMap;

const annotation = @import("annotation.zig");
const Annotation = annotation.Annotation;
const UserAttribute = annotation.UserAttribute;

const slang = @import("slang");

pub const Entry = struct {
    allocator: FixedBufferAllocator,
    name: []const u8,
    stage: slang.Stage,
    workerSize: [3]u64,
    function: Function,
    bindings: SlotBindings,

    pub fn deinit(self: *const Entry, alloc: Allocator) void {
        alloc.free(self.allocator.buffer);
    }

    pub fn jsonStringify(self: *const @This(), jw: anytype) !void {
        try jw.beginObject();

        try jw.objectField("name");
        try jw.write(self.name);

        try jw.objectField("stage");
        try jw.write(self.stage);

        try jw.objectField("workerSize");
        try jw.write(self.workerSize);

        try jw.objectField("function");
        try jw.write(self.function);

        try jw.objectField("bindings");
        try jw.write(self.bindings);

        try jw.endObject();
    }
};

pub const Argument = union(enum) {
    Int: i32,
    Float: f32,
    Bool: bool,
    String: []const u8,

    pub fn from(self: *const slang.AttributeReflection, allocator: Allocator) ![]Argument {
        var args = try std.ArrayList(Argument).initCapacity(allocator, self.getArgumentCount());
        defer args.deinit(allocator);

        for (0..args.capacity) |iu| {
            const i: u32 = @intCast(iu);
            switch (self.getArgumentType(i).getScalarType()) {
                .INT8, .INT16, .INT32, .INT64 => args.appendAssumeCapacity(.{ .Int = try self.getArgumentValueInt(i) }),
                .FLOAT16, .FLOAT32, .FLOAT64 => args.appendAssumeCapacity(.{ .Float = try self.getArgumentValueFloat(i) }),
                .BOOL => args.appendAssumeCapacity(.{ .Bool = @bitCast(@as(u1, @intCast(try self.getArgumentValueInt(i)))) }),
                .UINTPTR => args.appendAssumeCapacity(.{ .String = try allocator.dupe(u8, self.getArgumentValueString(i)) }),
                .NONE => {},
                else => {
                    std.log.err("Attribute with ScalarType {s} is not supported", .{self.getArgumentType(i).getScalarType().toString()});
                    @panic("Attribute is not supported");
                },
            }
        }
        return try args.toOwnedSlice(allocator);
    }
};

pub const BindingCounts = struct {
    uniform_buffers: u32 = 0,
    readonly_storage_buffers: u32 = 0,
    readwrite_storage_buffers: u32 = 0,
    readonly_storage_textures: u32 = 0,
    readwrite_storage_textures: u32 = 0,
    sampled_textures: u32 = 0,
    samplers: u32 = 0,

    pub fn add(bindingCounts: *BindingCounts, bindingType: BindingType) void {
        switch (bindingType) {
            .Uniform => bindingCounts.uniform_buffers += 1,
            .ReadOnlyStorage => bindingCounts.readonly_storage_buffers += 1,
            .ReadWriteStorage => bindingCounts.readwrite_storage_buffers += 1,
            .ReadOnlyStorageTexture => bindingCounts.readonly_storage_textures += 1,
            .ReadWriteStorageTexture => bindingCounts.readwrite_storage_textures += 1,
            .SampledTexture => bindingCounts.sampled_textures += 1,
            .Sampler => bindingCounts.samplers += 1,
        }
    }
};

pub const Binding = struct {
    buffer: []u8,
    name: []const u8,
    bindingType: BindingType,
    size: usize,
    type: Type,
    userAttributes: ?[]Annotation,

    pub fn findAttribute(self: *const Binding, comptime tag: std.meta.Tag(Annotation)) ?std.meta.TagPayload(Annotation, tag) {
        return getAnnotation(self.userAttributes, tag);
    }

    pub fn empty(allocator: Allocator) Binding {
        const buf = allocator.alloc(u8, 1024) catch @panic("OOM");
        return .{
            .buffer = buf,
            .name = undefined,
            .bindingType = undefined,
            .type = undefined,
            .size = undefined,
            .userAttributes = undefined,
        };
    }

    pub fn jsonStringify(self: *const @This(), jw: anytype) !void {
        try jw.beginObject();

        try jw.objectField("name");
        try jw.write(self.name);

        try jw.objectField("bindingType");
        try jw.write(self.bindingType);

        try jw.objectField("size");
        try jw.write(self.size);

        try jw.objectField("type");
        try jw.write(self.type);

        try jw.objectField("userAttributes");
        try jw.write(self.userAttributes);

        try jw.endObject();
    }
};

pub const BindingType = enum {
    Uniform,
    ReadOnlyStorage,
    ReadWriteStorage,
    ReadOnlyStorageTexture,
    ReadWriteStorageTexture,
    SampledTexture,
    Sampler,
};

pub const ComputeBindings = struct {
    pub const readOnlyBinding: u32 = 0;
    pub const readWriteBinding: u32 = 1;
    pub const uniformBinding: u32 = 2;

    readOnly: []Binding,
    readWrite: []Binding,
    uniform: []Binding,
    bindingCounts: BindingCounts,
};

pub const VertexBindings = struct {
    const readWriteBinding: u32 = 0;
    const uniformBinding: u32 = 1;

    readWrite: []Binding,
    uniform: []Binding,
    bindingCounts: BindingCounts,
};

pub const FragmentBindings = struct {
    const readWriteBinding: u32 = 2;
    const uniformBinding: u32 = 3;

    readWrite: []Binding,
    uniform: []Binding,
    bindingCounts: BindingCounts,
};

pub const SlotBindings = union(enum) {
    const maxBindingSlot = 4;
    Compute: ComputeBindings,
    Vertex: VertexBindings,
    Fragment: FragmentBindings,

    pub fn getBindingCounts(self: *const SlotBindings) BindingCounts {
        return switch (self.*) {
            .Compute => |c| c.bindingCounts,
            .Vertex => |v| v.bindingCounts,
            .Fragment => |f| f.bindingCounts,
        };
    }
};

pub const Type = union(enum) {
    Scalar: struct {
        type: slang.ScalarType,
        annotation: ?[]Annotation,
    },
    Structure: struct {
        name: []const u8,
        fields: []Type,
        annotation: ?[]Annotation,
    },
    Resource: struct {
        name: []const u8,
        result: *Type,
        access: slang.ResourceAccess,
        shape: slang.ResourceShape,
        annotation: ?[]Annotation,
    },
    Array: struct {
        name: []const u8,
        elementType: *Type,
        annotation: ?[]Annotation,
    },
    Texture: struct {
        name: []const u8,
        rowCount: u32,
        columnCount: u32,
        annotation: ?[]Annotation,
    },
    ConstantBuffer: struct {
        name: []const u8,
        type: *Type,
        annotation: ?[]Annotation,
    },
    ParameterBlock: struct {
        name: []const u8,
        elementType: *Type,
        annotation: ?[]Annotation,
    },
    Vector: struct {
        name: []const u8,
        size: usize,
        type: *Type,
        annotation: ?[]Annotation,
    },
    NotImplemented,
    None,

    pub fn getAnnotation(self: *const slang.TypeReflection, allocator: Allocator) ![]Annotation {
        return try Annotation.fromList(allocator, self.ptr, self.getUserAttributeCount(), slang.TypeReflection_getUserAttributeByIndex);
    }

    pub fn from(self: anytype, allocator: Allocator) !Type {
        const annotationsOf = struct {
            inline fn annotationsOf(x: anytype, a: Allocator) ?[]Annotation {
                const T = @TypeOf(x.*);
                if (T == slang.TypeReflection) {
                    return Type.getAnnotation(x, a) catch null;
                }
                return null;
            }
        }.annotationsOf;

        return switch (self.getKind()) {
            .SCALAR => .{ .Scalar = .{
                .type = self.getScalarType(),
                .annotation = annotationsOf(self, allocator),
            } },
            .STRUCT => .{ .Structure = .{
                .name = try allocator.dupe(u8, self.getName()),
                .fields = try Type.getFields(self, allocator),
                .annotation = null,
            } },
            .RESOURCE => {
                const t = try allocator.create(Type);
                t.* = try Type.from(&self.getResourceResultType(), allocator);
                return .{ .Resource = .{
                    .name = try allocator.dupe(u8, self.getName()),
                    .result = t,
                    .access = self.getResourceAccess(),
                    .shape = self.getResourceShape(),
                    .annotation = annotationsOf(self, allocator),
                } };
            },
            .ARRAY => {
                const t = try allocator.create(Type);
                t.* = try from(&self.getElementType(), allocator);
                return .{ .Array = .{
                    .name = try allocator.dupe(u8, self.getName()),
                    .elementType = t,
                    .annotation = annotationsOf(self, allocator),
                } };
            },
            .TEXTURE_BUFFER => .{ .Texture = .{
                .name = try allocator.dupe(u8, self.getName()),
                .rowCount = self.getRowCount(),
                .columnCount = self.getColumnCount(),
                .annotation = annotationsOf(self, allocator),
            } },
            .NONE => .None,
            .CONSTANT_BUFFER => {
                const t = try allocator.create(Type);
                t.* = try from(&self.getElementType(), allocator);

                return .{ .ConstantBuffer = .{
                    .name = try allocator.dupe(u8, self.getName()),
                    .type = t,
                    .annotation = annotationsOf(self, allocator),
                } };
            },
            .VECTOR => {
                const t = try allocator.create(Type);
                t.* = try from(&self.getElementType(), allocator);

                return .{ .Vector = .{
                    .name = try allocator.dupe(u8, self.getName()),
                    .size = 0,
                    .type = t,
                    .annotation = annotationsOf(self, allocator),
                } };
            },
            else => .NotImplemented,
        };
    }

    pub fn getFields(self: anytype, allocator: Allocator) anyerror![]Type {
        var fields = try std.ArrayList(Type).initCapacity(allocator, self.getFieldCount());
        for (0..fields.capacity) |i| {
            fields.appendAssumeCapacity(try Type.fromVariable(&self.getFieldByIndex(@intCast(i)), allocator));
        }
        return try fields.toOwnedSlice(allocator);
    }

    pub fn fromVariable(self: anytype, allocator: Allocator) !Type {
        return Type.from(&self.getType(), allocator);
    }
};

pub const Variable = struct {
    name: []const u8,
    type: Type,

    bindingIndex: u32,
    bindingSpace: u32,
    offset: usize,
    size: usize,
    stride: usize,

    category: slang.ParameterCategory,

    pub fn fromLayout(self: *const slang.VariableLayoutReflection, allocator: Allocator) !Variable {
        return Variable{
            .name = try allocator.dupe(u8, self.getName()),
            .bindingIndex = self.getBindingIndex(),
            .bindingSpace = self.getBindingSpace(),
            .offset = self.getOffset(self.getCategory()),
            .size = self.getType().getSize(self.getCategory()),
            .stride = self.getType().getElementStride(self.getCategory()),
            .category = self.getCategory(),
            .type = try Type.from(&self.getType(), allocator),
        };
    }
};

pub const VariableWithAnnotation = struct {
    variable: Variable,
    annotation: ?[]Annotation,

    pub fn from(self: *const slang.VariableLayoutReflection, allocator: Allocator) anyerror!VariableWithAnnotation {
        const v = VariableWithAnnotation{
            .variable = try Variable.from(self, allocator),
            .annotation = try VariableWithAnnotation.getAnnotation(self.getVariable(), allocator),
        };

        return v;
    }

    pub fn getAnnotation(self: *const slang.VariableReflection, allocator: Allocator) ![]Annotation {
        return try Annotation.fromList(allocator, self.ptr, self.getUserAttributeCount(), slang.VariableReflection_getUserAttributeByIndex);
    }
};

pub const Function = struct {
    name: []const u8,
    parameters: []Type,
    annotation: []Annotation,

    pub fn from(self: *const slang.FunctionReflection, allocator: Allocator) !Function {
        return .{
            .name = try allocator.dupe(u8, self.getName()),
            .parameters = try Function.getParameters(self, allocator),
            .annotation = try Function.getAnnotation(self, allocator),
        };
    }

    pub fn getParameters(self: *const slang.FunctionReflection, allocator: Allocator) ![]Type {
        var parameters = try std.ArrayList(Type).initCapacity(allocator, self.getParameterCount());
        defer parameters.deinit(allocator);

        for (0..parameters.capacity) |i| {
            parameters.appendAssumeCapacity(try Type.fromVariable(&self.getParameterByIndex(@intCast(i)), allocator));
        }
        return try parameters.toOwnedSlice(allocator);
    }

    pub fn getAnnotation(self: *const slang.FunctionReflection, allocator: Allocator) ![]Annotation {
        return Annotation.fromList(allocator, self.ptr, self.getUserAttributeCount(), slang.FunctionReflection_getUserAttributeByIndex);
    }
};

pub fn getFieldsLayout(self: *const slang.TypeLayoutReflection, allocator: Allocator) ![]VariableWithAnnotation {
    var fields = try std.ArrayList(VariableWithAnnotation).initCapacity(allocator, self.getFieldCount());
    for (0..fields.capacity) |i| {
        fields.appendAssumeCapacity(try VariableWithAnnotation.from(&self.getFieldByIndex(@intCast(i)), allocator));
    }
    return try fields.toOwnedSlice(allocator);
}

pub fn bindParam(self: *const slang.Reflection, slotsArr: *AutoHashMap(u32, ArrayList(Binding)), bindingCounts: *BindingCounts, param: slang.VariableLayoutReflection, inSlot: ?u32) !void {
    switch (param.getCategory()) {
        .SUB_ELEMENT_REGISTER_SPACE => {
            const typeLayout = param.getType();
            switch (typeLayout.getKind()) {
                .PARAMETER_BLOCK => {
                    for (0..typeLayout.getElementType().getFieldCount()) |i| {
                        try bindParam(self, slotsArr, bindingCounts, typeLayout.getElementType().getFieldByIndex(@intCast(i)), inSlot orelse param.getBindingIndex());
                    }
                },
                else => @panic("unknown"),
            }
        },
        .DESCRIPTOR_TABLE_SLOT => {
            const slot = inSlot orelse param.getBindingSpace();
            if (!slotsArr.contains(slot)) return;
            const index: u32 = @intCast(slotsArr.get(slot).?.items.len);

            if (!self.isParameterLocationUsed(.DESCRIPTOR_TABLE_SLOT, slot, index)) return;

            const bindingType: BindingType = switch (param.getType().getKind()) {
                .RESOURCE => switch (param.getType().getResourceShape().primitiveShape()) {
                    .SampledTexture => .SampledTexture,
                    .Texture => switch (param.getType().getResourceAccess()) {
                        .SLANG_RESOURCE_ACCESS_WRITE, .SLANG_RESOURCE_ACCESS_READ_WRITE => .ReadWriteStorageTexture,
                        else => .ReadOnlyStorageTexture,
                    },
                    .StorageBuffer => switch (param.getType().getResourceAccess()) {
                        .SLANG_RESOURCE_ACCESS_WRITE, .SLANG_RESOURCE_ACCESS_READ_WRITE => .ReadWriteStorage,
                        else => .ReadOnlyStorage,
                    },
                    .Unknown, .ByteAddressBuffer => @panic("unknown"),
                },
                .CONSTANT_BUFFER => .Uniform,
                .SAMPLER_STATE => .Sampler,
                else => @panic("unknown"),
            };
            bindingCounts.add(bindingType);

            var binding = Binding.empty(slotsArr.allocator);
            var fba = FixedBufferAllocator.init(binding.buffer);
            var allocator = fba.allocator();

            binding.name = try allocator.dupe(u8, param.getVariable().getName());
            binding.bindingType = bindingType;
            binding.type = try Type.from(&param.getType(), allocator);
            binding.userAttributes = try VariableWithAnnotation.getAnnotation(&param.getVariable(), allocator);

            slotsArr.getPtr(slot).?.appendAssumeCapacity(binding);
        },
        .NONE => {},
        else => @panic("unknown"),
    }
}

pub fn tallyBindings(self: *const slang.Reflection, allocator: Allocator) !SlotBindings {
    var slotsArr = AutoHashMap(u32, ArrayList(Binding)).init(allocator);
    var bindingCounts = BindingCounts{};

    for (0..SlotBindings.maxBindingSlot) |slot| {
        try slotsArr.put(@intCast(slot), try ArrayList(Binding).initCapacity(allocator, 16));
    }

    for (0..self.getParameterCount()) |i| {
        try bindParam(self, &slotsArr, &bindingCounts, self.getParameterByIndex(@intCast(i)), null);
    }

    return switch (self.getEntryPointByIndex(0).getStage()) {
        .COMPUTE => .{ .Compute = .{
            .readOnly = try slotsArr.getPtr(ComputeBindings.readOnlyBinding).?.toOwnedSlice(allocator),
            .readWrite = try slotsArr.getPtr(ComputeBindings.readWriteBinding).?.toOwnedSlice(allocator),
            .uniform = try slotsArr.getPtr(ComputeBindings.uniformBinding).?.toOwnedSlice(allocator),
            .bindingCounts = bindingCounts,
        } },
        .VERTEX => .{ .Vertex = .{
            .readWrite = try slotsArr.getPtr(VertexBindings.readWriteBinding).?.toOwnedSlice(allocator),
            .uniform = try slotsArr.getPtr(VertexBindings.uniformBinding).?.toOwnedSlice(allocator),
            .bindingCounts = bindingCounts,
        } },
        .FRAGMENT => .{ .Fragment = .{
            .readWrite = try slotsArr.getPtr(FragmentBindings.readWriteBinding).?.toOwnedSlice(allocator),
            .uniform = try slotsArr.getPtr(FragmentBindings.uniformBinding).?.toOwnedSlice(allocator),
            .bindingCounts = bindingCounts,
        } },
        else => @panic("unknown"),
    };
}

pub fn toEntry(self: *const slang.Reflection, allocator: Allocator) !Entry {
    var fba = FixedBufferAllocator.init(try allocator.alloc(u8, 10_240));
    const entryPoint = self.getEntryPointByIndex(0);
    var fba_alloc = fba.allocator();

    return .{
        .allocator = fba,
        .name = try fba_alloc.dupe(u8, entryPoint.getName()),
        .stage = entryPoint.getStage(),
        .workerSize = entryPoint.getWorkerSize(),
        .function = try Function.from(&entryPoint.getFunction(), fba_alloc),
        .bindings = try tallyBindings(self, fba_alloc),
    };
}

pub fn getUserAttribute(attr: []Annotation, tag: []const u8) ?UserAttribute {
    for (attr) |a| {
        if (a == .UserAttribute and std.ascii.ignoreCase(tag, a.UserAttribute.name)) {
            return a.UserAttribute;
        }
    }
    return null;
}

pub fn getAnnotation(attr: []Annotation, comptime tag: std.meta.Tag(Annotation)) ?std.meta.TagPayload(Annotation, tag) {
    for (attr) |a| switch (a) {
        tag => |payload| return payload,
        else => {},
    };
    return null;
}
