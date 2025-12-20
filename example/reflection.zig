pub const std = @import("std");
pub const slang = @import("slang");
pub const c = slang.c;

pub const Reflection = slang.Reflection;
pub const FunctionReflection = slang.FunctionReflection;
pub const TypeReflection = slang.TypeReflection;
pub const TypeLayoutReflection = slang.TypeLayoutReflection;
pub const VariableReflection = slang.VariableReflection;
pub const VariableLayoutReflection = slang.VariableLayoutReflection;
pub const TypeParameterReflection = slang.TypeParameterReflection;
pub const EntryPointReflection = slang.EntryPointReflection;
pub const AttributeReflection = slang.AttributeReflection;

pub const Stage = slang.Stage;

pub const Entry = struct {
    allocator: std.heap.FixedBufferAllocator,

    name: []const u8,
    stage: c.Stage,
    workerSize: [3]u64,

    function: Function,
    bindings: SlotBindings,

    pub fn jsonStringify(self: @This(), jw: anytype) !void {
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

pub const Binding = struct {
    name: []const u8,
    bindingType: BindingType,
    type: TypeLayout,
    userAttributes: ?[]Attribute,
};

pub const BindingType = enum {
    Constant,
    Resource,
};

pub const ComputeBindings = struct {
    pub const readOnlyBinding: u32 = 0;
    pub const readWriteBinding: u32 = 1;
    pub const uniformBinding: u32 = 2;

    readOnly: []Binding,
    readWrite: []Binding,
    uniform: []Binding,
};

pub const VertexBindings = struct {
    const readWriteBinding: u32 = 0;
    const uniformBinding: u32 = 1;

    readWrite: []Binding,
    uniform: []Binding,
};

pub const FragmentBindings = struct {
    const readWriteBinding: u32 = 2;
    const uniformBinding: u32 = 3;

    readWrite: []Binding,
    uniform: []Binding,
};

pub const SlotBindings = union(enum) {
    const maxBindingSlot = 4;

    Compute: ComputeBindings,
    Vertex: VertexBindings,
    Fragment: FragmentBindings,
};

pub const TypeLayout = union(enum) {
    Scalar: struct {
        type: c.ScalarType,
    },
    Structure: struct {
        name: []const u8,
        fields: []VariableLayout,
    },
    Resource: struct {
        name: []const u8,
        type: *Type,
        access: c.ResourceAccess,
        shape: c.ResourceShape,
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

pub const Variable = struct {
    name: []const u8,
    type: Type,
    userAttributes: ?[]Attribute,
};

// TODO make this an enum and separate values by category.
pub const VariableLayout = struct {
    variable: ?Variable,
    typeLayout: TypeLayout,

    bindingIndex: u32,
    bindingSpace: u32,
    offset: usize,
    size: usize,
    stride: usize,

    category: c.ParameterCategory,
};

pub const Type = union(enum) {
    Scalar: struct {
        type: c.ScalarType,
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
        access: c.ResourceAccess,
        shape: c.ResourceShape,
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

pub const TypeParameter = struct {
    name: []const u8,
    constraints: []Type,
};
pub const Function = struct {
    name: []const u8,
    parameters: []Variable,
    userAttributes: []Attribute,
};

pub const EntryPoint = struct {
    name: []const u8,
    stage: c.Stage,
    function: Function,
    parameters: []VariableLayout,
    varriableLayout: VariableLayout,
    computeThreadGroupSize: [3]u64,
    typeLayout: TypeLayout,
    resultVarLayout: ?VariableLayout,
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

pub fn getArguments(self: *const AttributeReflection, allocator: std.mem.Allocator) ![]Argument {
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
                args.appendAssumeCapacity(.{ .String = self.getArgumentValueString(i) });
            },
            else => {
                std.log.err("Attribute with ScalarType {s} is not supported", .{self.getArgumentType(i).getScalarType().toString()});
                @panic("Attribute is not supported");
            },
        }
    }
    return try args.toOwnedSlice(allocator);
}

pub fn toAttribute(self: *const AttributeReflection, allocator: std.mem.Allocator) !Attribute {
    return Attribute{
        .name = self.getName(),
        .args = try getArguments(self, allocator),
    };
}

pub fn bindParam(self: *const Reflection, slotsArr: *std.AutoHashMap(u32, std.ArrayList(Binding)), param: VariableLayoutReflection, inSlot: ?u32) !void {
    switch (param.getCategory()) {
        .SUB_ELEMENT_REGISTER_SPACE => {
            const typeLayout = param.getTypeLayout();
            switch (typeLayout.getKind()) {
                .PARAMETER_BLOCK => {
                    for (0..typeLayout.getElementTypeLayout().getFieldCount()) |i| {
                        try bindParam(self, slotsArr, typeLayout.getElementTypeLayout().getFieldByIndex(@intCast(i)), inSlot orelse param.getBindingIndex());
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
                .RESOURCE => .Resource,
                .CONSTANT_BUFFER => .Constant,
                else => @panic("unknown"),
            };

            const typeLayout = try toTypeLayout(&param.getTypeLayout(), slotsArr.allocator);

            const userAttributes = try getVariableLayoutUserAttributes(&param.getVariable(), slotsArr.allocator);

            const binding: Binding = .{
                .name = param.getVariable().getName(),
                .bindingType = bindingType,
                .type = typeLayout,
                .userAttributes = userAttributes,
            };

            slotsArr.getPtr(slot).?.appendAssumeCapacity(binding);
        },
        else => @panic("unknown"),
    }
}

pub fn bindings(self: *const Reflection, allocator: std.mem.Allocator) !SlotBindings {
    var slotsArr = std.AutoHashMap(u32, std.ArrayList(Binding)).init(allocator);

    for (0..SlotBindings.maxBindingSlot) |slot| {
        try slotsArr.put(@intCast(slot), try std.ArrayList(Binding).initCapacity(allocator, 16));
    }

    for (0..self.getParameterCount()) |i| {
        try bindParam(self, &slotsArr, self.getParameterByIndex(@intCast(i)), null);
    }

    return switch (self.getEntryPointByIndex(0).getStage()) {
        .COMPUTE => .{ .Compute = .{
            .readOnly = try allocator.dupe(Binding, slotsArr.getPtr(ComputeBindings.readOnlyBinding).?.items),
            .readWrite = try allocator.dupe(Binding, slotsArr.getPtr(ComputeBindings.readWriteBinding).?.items),
            .uniform = try allocator.dupe(Binding, slotsArr.getPtr(ComputeBindings.uniformBinding).?.items),
        } },
        .VERTEX => .{ .Vertex = .{
            .readWrite = try allocator.dupe(Binding, slotsArr.getPtr(VertexBindings.readWriteBinding).?.items),
            .uniform = try allocator.dupe(Binding, slotsArr.getPtr(VertexBindings.uniformBinding).?.items),
        } },
        .FRAGMENT => .{ .Fragment = .{
            .readWrite = try allocator.dupe(Binding, slotsArr.getPtr(FragmentBindings.readWriteBinding).?.items),
            .uniform = try allocator.dupe(Binding, slotsArr.getPtr(FragmentBindings.uniformBinding).?.items),
        } },
        else => @panic("unknown"),
    };
}

pub fn toEntry(self: *const Reflection, allocator: std.mem.Allocator) !Entry {
    var fba = std.heap.FixedBufferAllocator.init(try allocator.alloc(u8, 10_240));
    const entryPoint = self.getEntryPointByIndex(0);

    return .{
        .allocator = fba,
        .name = entryPoint.getName(),
        .stage = entryPoint.getStage(),
        .workerSize = entryPoint.getWorkerSize(),
        .function = try toFunction(&entryPoint.getFunction(), fba.allocator()),
        .bindings = try bindings(self, fba.allocator()),
    };
}

pub fn getFieldsLayout(self: *const TypeLayoutReflection, allocator: std.mem.Allocator) ![]VariableLayout {
    var fields = try std.ArrayList(VariableLayout).initCapacity(allocator, self.getFieldCount());
    for (0..fields.capacity) |i| {
        fields.appendAssumeCapacity(try toVariableLayout(&self.getFieldByIndex(@intCast(i)), allocator));
    }
    return try fields.toOwnedSlice(allocator);
}

pub fn toTypeLayout(self: *const TypeLayoutReflection, allocator: std.mem.Allocator) anyerror!TypeLayout {
    return switch (self.getKind()) {
        .SCALAR => .{ .Scalar = .{
            .type = self.getScalarType(),
        } },
        .STRUCT => .{ .Structure = .{
            .name = self.getName(),
            .fields = try getFieldsLayout(self, allocator),
        } },
        .RESOURCE => {
            const t = try allocator.create(Type);
            t.* = try toType(&self.getResourceResultType(), allocator);

            return .{ .Resource = .{
                .name = self.getName(),
                .type = t,
                .access = self.getResourceAccess(),
                .shape = self.getResourceShape(),
            } };
        },
        .ARRAY => {
            const nestedType = try allocator.create(TypeLayout);
            nestedType.* = try toTypeLayout(&self.getElementTypeLayout(), allocator);

            return .{ .Array = .{
                .name = self.getName(),
                .elementType = nestedType,
            } };
        },
        .TEXTURE_BUFFER => .{ .Texture = .{
            .name = self.getName(),
            .rowCount = self.getRowCount(),
            .columnCount = self.getColumnCount(),
        } },
        .NONE => .None,
        .CONSTANT_BUFFER => {
            const nestedType = try allocator.create(TypeLayout);
            nestedType.* = try toTypeLayout(&self.getElementTypeLayout(), allocator);

            return .{ .ConstantBuffer = .{
                .name = self.getName(),
                .type = nestedType,
            } };
        },
        .PARAMETER_BLOCK => {
            const nestedType = try allocator.create(TypeLayout);
            nestedType.* = try toTypeLayout(&self.getElementTypeLayout(), allocator);

            return .{ .ParameterBlock = .{
                .name = self.getName(),
                .elementType = nestedType,
            } };
        },
        .VECTOR => {
            const t = try allocator.create(Type);
            t.* = try toType(&self.getType().getElementType(), allocator);

            return .{ .Vector = .{
                .name = self.getName(),
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

pub fn getVariableLayoutUserAttributes(self: *const VariableReflection, allocator: std.mem.Allocator) !?[]Attribute {
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

pub fn variableToObject(self: *const VariableReflection, allocator: std.mem.Allocator) anyerror!Variable {
    const v = Variable{
        .name = self.getName(),
        .type = try toType(&self.getType(), allocator),
        .userAttributes = try getVariableLayoutUserAttributes(self, allocator),
    };

    return v;
}

pub fn toVariableLayout(self: *const VariableLayoutReflection, allocator: std.mem.Allocator) !VariableLayout {
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

pub fn getTypeReflectionUserAttributes(self: *const TypeReflection, allocator: std.mem.Allocator) !?[]Attribute {
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

pub fn getFields(self: *const TypeReflection, allocator: std.mem.Allocator) anyerror![]Variable {
    var fields = try std.ArrayList(Variable).initCapacity(allocator, self.getFieldCount());
    for (0..fields.capacity) |i| {
        fields.appendAssumeCapacity(try variableToObject(&self.getFieldByIndex(@intCast(i)), allocator));
    }
    return try fields.toOwnedSlice(allocator);
}

pub fn toType(self: *const TypeReflection, allocator: std.mem.Allocator) !Type {
    return switch (self.getKind()) {
        .SCALAR => .{ .Scalar = .{
            .type = self.getScalarType(),
            .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
        } },
        .STRUCT => .{ .Structure = .{
            .name = self.getName(),
            .fields = try getFields(self, allocator),
            .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
        } },
        .RESOURCE => {
            const t = try allocator.create(Type);
            t.* = try toType(&self.getResourceResultType(), allocator);
            return .{ .Resource = .{
                .name = self.getName(),
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
                .name = self.getName(),
                .elementType = t,
                .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
            } };
        },
        .TEXTURE_BUFFER => .{ .Texture = .{
            .name = self.getName(),
            .rowCount = self.getRowCount(),
            .columnCount = self.getColumnCount(),
            .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
        } },
        .NONE => .None,
        .CONSTANT_BUFFER => {
            const t = try allocator.create(Type);
            t.* = try toType(&self.getElementType(), allocator);

            return .{ .ConstantBuffer = .{
                .name = self.getName(),
                .type = t,
                .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
            } };
        },
        .VECTOR => {
            const t = try allocator.create(Type);
            t.* = try toType(&self.getElementType(), allocator);

            return .{ .Vector = .{
                .name = self.getName(),
                .size = self.getElementCount(),
                .type = t,
                .userAttributes = try getTypeReflectionUserAttributes(self, allocator),
            } };
        },
        else => .NotImplemented,
    };
}

pub fn getFunctionUserAttributes(self: *const FunctionReflection, allocator: std.mem.Allocator) ![]Attribute {
    var userAttributes = try std.ArrayList(Attribute).initCapacity(allocator, self.getUserAttributeCount());
    defer userAttributes.deinit(allocator);

    for (0..userAttributes.capacity) |i| {
        userAttributes.appendAssumeCapacity(try toAttribute(&self.getUserAttributeByIndex(@intCast(i)), allocator));
    }
    return try userAttributes.toOwnedSlice(allocator);
}

pub fn getFunctionParameters(self: *const FunctionReflection, allocator: std.mem.Allocator) ![]Variable {
    var parameters = try std.ArrayList(Variable).initCapacity(allocator, self.getParameterCount());
    defer parameters.deinit(allocator);

    for (0..parameters.capacity) |i| {
        parameters.appendAssumeCapacity(try variableToObject(&self.getParameterByIndex(@intCast(i)), allocator));
    }
    return try parameters.toOwnedSlice(allocator);
}

pub fn toFunction(self: *const FunctionReflection, allocator: std.mem.Allocator) !Function {
    return Function{
        .name = self.getName(),
        .parameters = try getFunctionParameters(self, allocator),
        .userAttributes = try getFunctionUserAttributes(self, allocator),
    };
}
