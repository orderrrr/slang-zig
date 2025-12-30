const std = @import("std");
const lib = @import("../lib.zig");

const VariableReflection = @import("VariableReflection.zig");
const TypeReflection = @import("TypeReflection.zig");
const AttributeReflection = @import("AttributeReflection.zig");

const Self = @This();

ptr: lib.FunctionReflectionPtr,

pub fn getName(self: *const Self) []const u8 {
    return lib.FunctionReflection_getName(self.ptr);
}

pub fn getReturnType(self: *const Self) TypeReflection {
    return .{ .ptr = lib.FunctionReflection_getReturnType(self.ptr) };
}

pub fn getParameterCount(self: *const Self) u32 {
    return lib.FunctionReflection_getParameterCount(self.ptr);
}

pub fn getParameterByIndex(self: *const Self, index: u32) VariableReflection {
    return .{ .ptr = lib.FunctionReflection_getParameterByIndex(self.ptr, index) };
}

pub fn getUserAttributeCount(self: *const Self) u32 {
    return lib.FunctionReflection_getUserAttributeCount(self.ptr);
}

pub fn getUserAttributeByIndex(self: *const Self, index: u32) AttributeReflection {
    return .{ .ptr = lib.FunctionReflection_getUserAttributeByIndex(self.ptr, index) };
}

pub fn findAttributeByName(self: *const Self, name: []const u8) AttributeReflection {
    return .{ .ptr = lib.FunctionReflection_findAttributeByName(self.ptr, name.ptr) };
}

pub fn findModifier(self: *const Self, id: lib.ModifierID) lib.Modifier {
    return lib.FunctionReflection_findModifier(self.ptr, @enumFromInt(id));
}

pub fn getGenericContainer(self: *const Self) lib.GenericReflection {
    return lib.FunctionReflection_getGenericContainer(self.ptr);
}

pub fn applySpecializations(self: *const Self, inGeneric: lib.GenericReflection) Self {
    return .{ .ptr = lib.FunctionReflection_applySpecializations(self.ptr, inGeneric) };
}

pub fn specializeWithArgTypes(self: *const Self, argCount: u32, types: []const TypeReflection) Self {
    return .{ .ptr = lib.FunctionReflection_specializeWithArgTypes(self.ptr, argCount, types.ptr) };
}

pub fn isOverloaded(self: *const Self) bool {
    return lib.FunctionReflection_isOverloaded(self.ptr);
}

pub fn getOverloadCount(self: *const Self) u32 {
    return lib.FunctionReflection_getOverloadCount(self.ptr);
}

pub fn getOverload(self: *const Self, index: u32) Self {
    return .{ .ptr = lib.FunctionReflection_getOverload(self.ptr, index) };
}
