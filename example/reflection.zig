const std = @import("std");
const FixedBufferAllocator = std.heap.FixedBufferAllocator;
const Allocator = std.mem.Allocator;
const AutoHashMap = std.AutoHashMap;
const ArrayList = std.ArrayList;

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
    name: []const u8,
    bindingType: BindingType,
    type: TypeLayout,
    userAttributes: ?[]Attribute,
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

pub const TypeLayout = union(enum) {
    Scalar: struct {
        type: slang.ScalarType,
    },
    Structure: struct {
        name: []const u8,
        fields: []VariableLayout,
    },
    Resource: struct {
        name: []const u8,
        type: *Type,
        access: slang.ResourceAccess,
        shape: slang.ResourceShape,
    },
    Array: struct {
        name: []const u8,
        elementType: *TypeLayout,
    },
    Texture: struct {
        name: []const u8,
        rowCount: u32,
        columnCount: u32,
    },
    ConstantBuffer: struct {
        name: []const u8,
        type: *TypeLayout,
    },
    ParameterBlock: struct {
        name: []const u8,
        elementType: *TypeLayout,
    },
    Vector: struct {
        name: []const u8,
        size: usize,
        type: *Type,
    },
    NotImplemented,
    None,
};

pub const Type = union(enum) {
    Scalar: struct {
        type: slang.ScalarType,
        userAttributes: ?[]Attribute,
    },

    Structure: struct {
        name: []const u8,
        fields: []Variable,
        userAttributes: ?[]Attribute,
    },

    Resource: struct {
        name: []const u8,
        result: *Type,
        access: slang.ResourceAccess,
        shape: slang.ResourceShape,
        userAttributes: ?[]Attribute,
    },

    Array: struct {
        name: []const u8,
        elementType: *Type,
        userAttributes: ?[]Attribute,
        // TODO: complete.
        // elementCount: u32,
        // elementStride: u32,
    },

    Texture: struct {
        name: []const u8,
        rowCount: u32,
        columnCount: u32,
        userAttributes: ?[]Attribute,
    },

    ConstantBuffer: struct {
        name: []const u8,
        type: *Type,
        userAttributes: ?[]Attribute,
    },

    Vector: struct {
        name: []const u8,
        type: *Type,
        size: usize,
        userAttributes: ?[]Attribute,
    },

    NotImplemented,
    None,
};

pub const Variable = struct {
    name: []const u8,
    type: Type,
    userAttributes: ?[]Attribute,
};

pub const VariableLayout = struct {
    variable: ?Variable,
    typeLayout: TypeLayout,

    bindingIndex: u32,
    bindingSpace: u32,
    offset: usize,
    size: usize,
    stride: usize,

    category: slang.ParameterCategory,
};

pub const Argument = union(enum) {
    Int: i32,
    Float: f32,
    Bool: bool,
    String: []const u8,
};

pub const Attribute = struct {
    name: []const u8,
    args: []Argument,
};

pub const Function = struct {
    name: []const u8,
    parameters: []Variable,
    userAttributes: []Attribute,
};

pub fn getFunctionUserAttributes(self: *const slang.FunctionReflection, allocator: Allocator) ![]Attribute {
    var userAttributes = try std.ArrayList(Attribute).initCapacity(allocator, self.getUserAttributeCount());
    defer userAttributes.deinit(allocator);

    for (0..userAttributes.capacity) |i| {
        userAttributes.appendAssumeCapacity(try toAttribute(&self.getUserAttributeByIndex(@intCast(i)), allocator));
    }
    return try userAttributes.toOwnedSlice(allocator);
}

pub fn getFunctionParameters(self: *const slang.FunctionReflection, allocator: Allocator) ![]Variable {
    var parameters = try std.ArrayList(Variable).initCapacity(allocator, self.getParameterCount());
    defer parameters.deinit(allocator);

    for (0..parameters.capacity) |i| {
        parameters.appendAssumeCapacity(try variableToObject(&self.getParameterByIndex(@intCast(i)), allocator));
    }
    return try parameters.toOwnedSlice(allocator);
}

pub fn getFields(self: *const slang.TypeReflection, allocator: Allocator) anyerror![]Variable {
    var fields = try std.ArrayList(Variable).initCapacity(allocator, self.getFieldCount());
    for (0..fields.capacity) |i| {
        fields.appendAssumeCapacity(try variableToObject(&self.getFieldByIndex(@intCast(i)), allocator));
    }
    return try fields.toOwnedSlice(allocator);
}

pub fn getArguments(self: *const slang.AttributeReflection, allocator: Allocator) ![]Argument {
    var args = try std.ArrayList(Argument).initCapacity(allocator, self.getArgumentCount());
    defer args.deinit(allocator);

    for (0..args.capacity) |iu| {
        const i: u32 = @intCast(iu);
        switch (self.getArgumentType(i).getScalarType()) {
            .INT8, .INT16, .INT32, .INT64 => {
                args.appendAssumeCapacity(.{ .Int = try self.getArgumentValueInt(i) });
            },
            .FLOAT16, .FLOAT32, .FLOAT64 => {
                args.appendAssumeCapacity(.{ .Float = try self.getArgumentValueFloat(i) });
            },
            .BOOL => {
                args.appendAssumeCapacity(.{ .Bool = @bitCast(@as(u1, @intCast(try self.getArgumentValueInt(i)))) });
            },
            .UINTPTR => {
                args.appendAssumeCapacity(.{ .String = try allocator.dupe(u8, self.getArgumentValueString(i)) });
            },
            else => {
                std.log.err("Attribute with ScalarType {s} is not supported", .{self.getArgumentType(i).getScalarType().toString()});
                @panic("Attribute is not supported");
            },
        }
    }
    return try args.toOwnedSlice(allocator);
}

pub fn toAttribute(self: *const slang.AttributeReflection, allocator: Allocator) !Attribute {
    return Attribute{
        .name = try allocator.dupe(u8, self.getName()),
        .args = try getArguments(self, allocator),
    };
}

pub fn getTypeReflectionUserAttributes(self: *const slang.TypeReflection, allocator: Allocator) !?[]Attribute {
    if (self.getUserAttributeCount() == 0) {
        return null;
    }

    var userAttributes = try std.ArrayList(Attribute).initCapacity(allocator, self.getUserAttributeCount());
    defer userAttributes.deinit(allocator);

    for (0..userAttributes.capacity) |i| {
        userAttributes.appendAssumeCapacity(try toAttribute(&self.getUserAttributeByIndex(@intCast(i)), allocator));
    }
    return try userAttributes.toOwnedSlice(allocator);
}

pub fn toType(self: *const slang.TypeReflection, allocator: Allocator) !Type {
    return switch (self.getKind()) {
        .SCALAR => .{ .Scalar = .{
            .type = self.getScalarType(),
            .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
        } },
        .STRUCT => .{ .Structure = .{
            .name = try allocator.dupe(u8, self.getName()),
            .fields = try getFields(self, allocator),
            .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
        } },
        .RESOURCE => {
            const t = try allocator.create(Type);
            t.* = try toType(&self.getResourceResultType(), allocator);
            return .{ .Resource = .{
                .name = try allocator.dupe(u8, self.getName()),
                .result = t,
                .access = self.getResourceAccess(),
                .shape = self.getResourceShape(),
                .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
            } };
        },
        .ARRAY => {
            const t = try allocator.create(Type);
            t.* = try toType(&self.getElementType(), allocator);
            return .{ .Array = .{
                .name = try allocator.dupe(u8, self.getName()),
                .elementType = t,
                .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
            } };
        },
        .TEXTURE_BUFFER => .{ .Texture = .{
            .name = try allocator.dupe(u8, self.getName()),
            .rowCount = self.getRowCount(),
            .columnCount = self.getColumnCount(),
            .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
        } },
        .NONE => .None,
        .CONSTANT_BUFFER => {
            const t = try allocator.create(Type);
            t.* = try toType(&self.getElementType(), allocator);

            return .{ .ConstantBuffer = .{
                .name = try allocator.dupe(u8, self.getName()),
                .type = t,
                .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
            } };
        },
        .VECTOR => {
            const t = try allocator.create(Type);
            t.* = try toType(&self.getElementType(), allocator);

            return .{ .Vector = .{
                .name = try allocator.dupe(u8, self.getName()),
                .size = self.getElementCount(),
                .type = t,
                .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
            } };
        },
        else => .NotImplemented,
    };
}

pub fn getVariableLayoutUserAttributes(self: *const slang.VariableReflection, allocator: Allocator) !?[]Attribute {
    if (self.getUserAttributeCount() == 0) {
        return null;
    }

    var userAttributes = try std.ArrayList(Attribute).initCapacity(allocator, self.getUserAttributeCount());
    defer userAttributes.deinit(allocator);

    for (0..userAttributes.capacity) |i| {
        userAttributes.appendAssumeCapacity(try toAttribute(&self.getUserAttributeByIndex(@intCast(i)), allocator));
    }
    return try userAttributes.toOwnedSlice(allocator);
}

pub fn variableToObject(self: *const slang.VariableReflection, allocator: Allocator) anyerror!Variable {
    const v = Variable{
        .name = try allocator.dupe(u8, self.getName()),
        .type = try toType(&self.getType(), allocator),
        .userAttributes = try getVariableLayoutUserAttributes(self, allocator),
    };

    return v;
}

pub fn toVariableLayout(self: *const slang.VariableLayoutReflection, allocator: Allocator) !VariableLayout {
    return VariableLayout{
        .variable = if (self.getVariable().ptr == null) null else try variableToObject(&self.getVariable(), allocator),
        .bindingIndex = self.getBindingIndex(),
        .bindingSpace = self.getBindingSpace(),
        .offset = self.getOffset(self.getCategory()),
        .size = self.getTypeLayout().getSize(self.getCategory()),
        .stride = self.getTypeLayout().getElementStride(self.getCategory()),
        .category = self.getCategory(),
        .typeLayout = try toTypeLayout(&self.getTypeLayout(), allocator),
    };
}

pub fn getFieldsLayout(self: *const slang.TypeLayoutReflection, allocator: Allocator) ![]VariableLayout {
    var fields = try std.ArrayList(VariableLayout).initCapacity(allocator, self.getFieldCount());
    for (0..fields.capacity) |i| {
        fields.appendAssumeCapacity(try toVariableLayout(&self.getFieldByIndex(@intCast(i)), allocator));
    }
    return try fields.toOwnedSlice(allocator);
}

pub fn toFunction(self: *const slang.FunctionReflection, allocator: Allocator) !Function {
    return Function{
        .name = try allocator.dupe(u8, self.getName()),
        .parameters = try getFunctionParameters(self, allocator),
        .userAttributes = try getFunctionUserAttributes(self, allocator),
    };
}

pub fn toTypeLayout(self: *const slang.TypeLayoutReflection, allocator: Allocator) anyerror!TypeLayout {
    return switch (self.getKind()) {
        .SCALAR => .{ .Scalar = .{
            .type = self.getScalarType(),
        } },
        .STRUCT => .{ .Structure = .{
            .name = try allocator.dupe(u8, self.getName()),
            .fields = try getFieldsLayout(self, allocator),
        } },
        .RESOURCE => {
            const t = try allocator.create(Type);
            t.* = try toType(&self.getResourceResultType(), allocator);

            return .{ .Resource = .{
                .name = try allocator.dupe(u8, self.getName()),
                .type = t,
                .access = self.getResourceAccess(),
                .shape = self.getResourceShape(),
            } };
        },
        .ARRAY => {
            const nestedType = try allocator.create(TypeLayout);
            nestedType.* = try toTypeLayout(&self.getElementTypeLayout(), allocator);

            return .{ .Array = .{
                .name = try allocator.dupe(u8, self.getName()),
                .elementType = nestedType,
            } };
        },
        .TEXTURE_BUFFER => .{ .Texture = .{
            .name = try allocator.dupe(u8, self.getName()),
            .rowCount = self.getRowCount(),
            .columnCount = self.getColumnCount(),
        } },
        .NONE => .None,
        .CONSTANT_BUFFER => {
            const nestedType = try allocator.create(TypeLayout);
            nestedType.* = try toTypeLayout(&self.getElementTypeLayout(), allocator);

            return .{ .ConstantBuffer = .{
                .name = try allocator.dupe(u8, self.getName()),
                .type = nestedType,
            } };
        },
        .PARAMETER_BLOCK => {
            const nestedType = try allocator.create(TypeLayout);
            nestedType.* = try toTypeLayout(&self.getElementTypeLayout(), allocator);

            return .{ .ParameterBlock = .{
                .name = try allocator.dupe(u8, self.getName()),
                .elementType = nestedType,
            } };
        },
        .VECTOR => {
            const t = try allocator.create(Type);
            t.* = try toType(&self.getType().getElementType(), allocator);

            return .{ .Vector = .{
                .name = try allocator.dupe(u8, self.getName()),
                .size = self.getType().getElementCount(),
                .type = t,
            } };
        },
        else => {
            std.log.err("TypeLayoutReflection::toReflectionObject: type is {}", .{self.getKind()});
            return .NotImplemented;
        },
    };
}

pub fn bindParam(self: *const slang.Reflection, slotsArr: *AutoHashMap(u32, ArrayList(Binding)), bindingCounts: *BindingCounts, param: slang.VariableLayoutReflection, inSlot: ?u32) !void {
    switch (param.getCategory()) {
        .SUB_ELEMENT_REGISTER_SPACE => {
            const typeLayout = param.getTypeLayout();
            switch (typeLayout.getKind()) {
                .PARAMETER_BLOCK => {
                    for (0..typeLayout.getElementTypeLayout().getFieldCount()) |i| {
                        try bindParam(self, slotsArr, bindingCounts, typeLayout.getElementTypeLayout().getFieldByIndex(@intCast(i)), inSlot orelse param.getBindingIndex());
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

            const bindingType: BindingType = switch (param.getTypeLayout().getKind()) {
                .RESOURCE => switch (param.getTypeLayout().getResourceShape().primitiveShape()) {
                    .SampledTexture => .SampledTexture,
                    .Texture => switch (param.getTypeLayout().getResourceAccess()) {
                        .SLANG_RESOURCE_ACCESS_WRITE, .SLANG_RESOURCE_ACCESS_READ_WRITE => .ReadWriteStorageTexture,
                        else => .ReadOnlyStorageTexture,
                    },
                    .StorageBuffer => switch (param.getTypeLayout().getResourceAccess()) {
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

            const typeLayout = try toTypeLayout(&param.getTypeLayout(), slotsArr.allocator);
            const userAttributes = try getVariableLayoutUserAttributes(&param.getVariable(), slotsArr.allocator);

            const binding: Binding = .{
                .name = try slotsArr.allocator.dupe(u8, param.getVariable().getName()),
                .bindingType = bindingType,
                .type = typeLayout,
                .userAttributes = userAttributes,
            };

            slotsArr.getPtr(slot).?.appendAssumeCapacity(binding);
        },
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
        .function = try toFunction(&entryPoint.getFunction(), fba_alloc),
        .bindings = try tallyBindings(self, fba_alloc),
    };
}
