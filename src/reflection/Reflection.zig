const std = @import("std");
const lib = @import("../lib.zig");

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

ptr: lib.ProgramLayout,
metadata: lib.IMetadata,

pub fn getParameterCount(self: *const Self) usize {
    return lib.ProgramLayout_getParameterCount(self.ptr);
}

pub fn getTypeParameterCount(self: *const Self) usize {
    return lib.ProgramLayout_getTypeParameterCount(self.ptr);
}

pub fn getTypeParameterByIndex(self: *const Self, index: u32) TypeParameterReflection {
    return .{ .ptr = lib.ProgramLayout_getTypeParameterByIndex(self.ptr, index) };
}

pub fn findTypeParameter(self: *const Self, name: []const u8) lib.TypeParameterReflection {
    return lib.ProgramLayout_findTypeParameter(self.ptr, name);
}

pub fn getParameterByIndex(self: *const Self, index: u32) VariableLayoutReflection {
    return .{ .ptr = lib.ProgramLayout_getParameterByIndex(self.ptr, index) };
}

pub fn getEntryPointCount(self: *const Self) usize {
    return lib.ProgramLayout_getEntryPointCount(self.ptr);
}

pub fn getEntryPointByIndex(self: *const Self, index: u32) EntryPointReflection {
    return .{ .ptr = lib.ProgramLayout_getEntryPointByIndex(self.ptr, index) };
}

pub fn getGlobalConstantBufferBinding(self: *const Self) u23 {
    return lib.ProgramLayout_getGlobalConstantBufferBinding(self.ptr);
}

pub fn getGlobalConstantBufferSize(self: *const Self) usize {
    return lib.ProgramLayout_getGlobalConstantBufferSize(self.ptr);
}

pub fn findTypeByName(self: *const Self, name: []const u8) lib.TypeReflection {
    return lib.ProgramLayout_findTypeByName(self.ptr, name);
}

pub fn findFunctionByName(self: *const Self, name: []const u8) lib.FunctionReflection {
    return lib.ProgramLayout_findFunctionByName(self.ptr, name);
}

pub fn findFunctionByNameInType(self: *const Self, t: lib.TypeReflection, name: []const u8) lib.FunctionReflection {
    return lib.ProgramLayout_findFunctionByNameInType(self.ptr, t, name);
}

pub fn findVarByNameInType(self: *const Self, t: lib.TypeReflection, name: []const u8) lib.VariableReflection {
    return lib.ProgramLayout_findVarByNameInType(self.ptr, t, name);
}

pub fn getTypeLayout(self: *const Self, t: lib.TypeReflection, layoutRules: lib.LayoutRules) lib.TypeLayoutReflection {
    return lib.ProgramLayout_getTypeLayout(self.ptr, t, layoutRules);
}

pub fn findEntryPointReflectionByName(self: *const Self, name: []const u8) lib.EntryPointReflection {
    return lib.ProgramLayout_findEntryPointReflectionByName(self.ptr, name);
}

pub fn specializeType(self: *const Self, t: lib.TypeReflection, specializationArgCount: i64, specializationArgs: [*c]lib.TypeReflection, outDiagnostics: *lib.IBlob) lib.TypeReflection {
    return lib.ProgramLayout_specializeType(self.ptr, t, specializationArgCount, @ptrCast(&specializationArgs[0]), outDiagnostics);
}

pub fn specializeGeneric(self: *const Self, inGeneric: lib.GenericReflection, specializationArgCount: i64, specializationArgs: [*c]lib.GenericArgReflection, outDiagnostics: *lib.IBlob) lib.GenericReflection {
    return lib.ProgramLayout_specializeGeneric(self.ptr, inGeneric, specializationArgCount, @ptrCast(&specializationArgs[0]), outDiagnostics);
}

pub fn isSubType(self: *const Self, inSubType: lib.TypeReflection, inSuperType: lib.TypeReflection) bool {
    return lib.ProgramLayout_isSubType(self.ptr, inSubType, inSuperType);
}

pub fn getHashedStringCount(self: *const Self) u32 {
    return lib.ProgramLayout_getHashedStringCount(self.ptr);
}

pub fn getHashedString(self: *const Self, index: u32, outCount: *usize) [*c]const u8 {
    return lib.ProgramLayout_getHashedString(self.ptr, index, outCount);
}

pub fn getGlobalParamsTypeLayout(self: *const Self) lib.TypeLayoutReflection {
    return lib.ProgramLayout_getGlobalParamsTypeLayout(self.ptr);
}

pub fn getGlobalParamsVarLayout(self: *const Self) lib.VariableLayoutReflection {
    return lib.ProgramLayout_getGlobalParamsVarLayout(self.ptr);
}

pub fn isParameterLocationUsed(self: *const Self, category: lib.ParameterCategory, space: u32, index: u32) bool {
    var used = std.mem.zeroes(bool);
    assert(lib.IMetadata_isParameterLocationUsed(self.metadata, category, space, index, &used).isSuccess());
    return used;
}
