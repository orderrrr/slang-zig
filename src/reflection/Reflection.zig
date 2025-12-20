const std = @import("std");
const c = @import("../c/c.zig");

const assert = std.debug.assert;

const VariableLayoutReflection = @import("VariableLayoutReflection.zig");
const VariableLayout = VariableLayoutReflection.VariableLayout;
const EntryPointReflection = @import("EntryPointReflection.zig");
const EntryPoint = EntryPointReflection.EntryPoint;
const TypeLayoutReflection = @import("TypeLayoutReflection.zig");
const TypeLayout = TypeLayoutReflection.TypeLayout;
const TypeParameterReflection = @import("TypeParameterReflection.zig");
const TypeParameter = TypeParameterReflection.TypeParameter;
const TypeReflect = @import("TypeReflection.zig");
const Type = TypeReflect.Type;
const VariableReflection = @import("VariableReflection.zig");
const Variable = VariableReflection.Variable;
const AttributeReflection = @import("AttributeReflection.zig");
const Attribute = AttributeReflection.Attribute;
const Argument = AttributeReflection.Argument;
const FunctionReflection = @import("FunctionReflection.zig");
const Function = FunctionReflection.Function;

const Self = @This();

ptr: c.ProgramLayout,
metadata: c.IMetadata,

pub fn getParameterCount(self: *const Self) usize {
    return c.ProgramLayout_getParameterCount(self.ptr);
}

pub fn getTypeParameterCount(self: *const Self) usize {
    return c.ProgramLayout_getTypeParameterCount(self.ptr);
}

pub fn getTypeParameterByIndex(self: *const Self, index: u32) TypeParameterReflection {
    return .{ .ptr = c.ProgramLayout_getTypeParameterByIndex(self.ptr, index) };
}

pub fn findTypeParameter(self: *const Self, name: []const u8) c.TypeParameterReflection {
    return c.ProgramLayout_findTypeParameter(self.ptr, name);
}

pub fn getParameterByIndex(self: *const Self, index: u32) VariableLayoutReflection {
    return .{ .ptr = c.ProgramLayout_getParameterByIndex(self.ptr, index) };
}

pub fn getEntryPointCount(self: *const Self) usize {
    return c.ProgramLayout_getEntryPointCount(self.ptr);
}

pub fn getEntryPointByIndex(self: *const Self, index: u32) EntryPointReflection {
    return .{ .ptr = c.ProgramLayout_getEntryPointByIndex(self.ptr, index) };
}

pub fn getGlobalConstantBufferBinding(self: *const Self) u23 {
    return c.ProgramLayout_getGlobalConstantBufferBinding(self.ptr);
}

pub fn getGlobalConstantBufferSize(self: *const Self) usize {
    return c.ProgramLayout_getGlobalConstantBufferSize(self.ptr);
}

pub fn findTypeByName(self: *const Self, name: []const u8) c.TypeReflection {
    return c.ProgramLayout_findTypeByName(self.ptr, name);
}

pub fn findFunctionByName(self: *const Self, name: []const u8) c.FunctionReflection {
    return c.ProgramLayout_findFunctionByName(self.ptr, name);
}

pub fn findFunctionByNameInType(self: *const Self, t: c.TypeReflection, name: []const u8) c.FunctionReflection {
    return c.ProgramLayout_findFunctionByNameInType(self.ptr, t, name);
}

pub fn findVarByNameInType(self: *const Self, t: c.TypeReflection, name: []const u8) c.VariableReflection {
    return c.ProgramLayout_findVarByNameInType(self.ptr, t, name);
}

pub fn getTypeLayout(self: *const Self, t: c.TypeReflection, layoutRules: c.LayoutRules) c.TypeLayoutReflection {
    return c.ProgramLayout_getTypeLayout(self.ptr, t, layoutRules);
}

pub fn findEntryPointReflectionByName(self: *const Self, name: []const u8) c.EntryPointReflection {
    return c.ProgramLayout_findEntryPointReflectionByName(self.ptr, name);
}

pub fn specializeType(self: *const Self, t: c.TypeReflection, specializationArgCount: i64, specializationArgs: [*c]c.TypeReflection, outDiagnostics: *c.IBlob) c.TypeReflection {
    return c.ProgramLayout_specializeType(self.ptr, t, specializationArgCount, @ptrCast(&specializationArgs[0]), outDiagnostics);
}

pub fn specializeGeneric(self: *const Self, inGeneric: c.GenericReflection, specializationArgCount: i64, specializationArgs: [*c]c.GenericArgReflection, outDiagnostics: *c.IBlob) c.GenericReflection {
    return c.ProgramLayout_specializeGeneric(self.ptr, inGeneric, specializationArgCount, @ptrCast(&specializationArgs[0]), outDiagnostics);
}

pub fn isSubType(self: *const Self, inSubType: c.TypeReflection, inSuperType: c.TypeReflection) bool {
    return c.ProgramLayout_isSubType(self.ptr, inSubType, inSuperType);
}

pub fn getHashedStringCount(self: *const Self) u32 {
    return c.ProgramLayout_getHashedStringCount(self.ptr);
}

pub fn getHashedString(self: *const Self, index: u32, outCount: *usize) [*c]const u8 {
    return c.ProgramLayout_getHashedString(self.ptr, index, outCount);
}

pub fn getGlobalParamsTypeLayout(self: *const Self) c.TypeLayoutReflection {
    return c.ProgramLayout_getGlobalParamsTypeLayout(self.ptr);
}

pub fn getGlobalParamsVarLayout(self: *const Self) c.VariableLayoutReflection {
    return c.ProgramLayout_getGlobalParamsVarLayout(self.ptr);
}

pub fn isParameterLocationUsed(self: *const Self, category: c.ParameterCategory, space: u32, index: u32) bool {
    var used = std.mem.zeroes(bool);
    assert(c.IMetadata_isParameterLocationUsed(self.metadata, category, space, index, &used).isSuccess());
    return used;
}
