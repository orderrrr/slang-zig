const std = @import("std");
const c = @import("../c/c.zig");

const VariableReflection = @import("VariableReflection.zig");
const TypeReflection = @import("TypeReflection.zig");
const AttributeReflection = @import("AttributeReflection.zig");

const Self = @This();

ptr: c.FunctionReflection,

pub fn getName(self: *const Self) []const u8 {
    return std.mem.sliceTo(c.FunctionReflection_getName(self.ptr), 0);
}

pub fn getReturnType(self: *const Self) TypeReflection {
    return .{ .ptr = c.FunctionReflection_getReturnType(self.ptr) };
}

pub fn getParameterCount(self: *const Self) u32 {
    return c.FunctionReflection_getParameterCount(self.ptr);
}

pub fn getParameterByIndex(self: *const Self, index: u32) VariableReflection {
    return .{ .ptr = c.FunctionReflection_getParameterByIndex(self.ptr, index) };
}

pub fn getUserAttributeCount(self: *const Self) u32 {
    return c.FunctionReflection_getUserAttributeCount(self.ptr);
}

pub fn getUserAttributeByIndex(self: *const Self, index: u32) AttributeReflection {
    return .{ .ptr = c.FunctionReflection_getUserAttributeByIndex(self.ptr, index) };
}

pub fn findAttributeByName(self: *const Self, name: []const u8) AttributeReflection {
    return .{ .ptr = c.FunctionReflection_findAttributeByName(self.ptr, name.ptr) };
}

pub fn findModifier(self: *const Self, id: c.ModifierID) c.Modifier {
    return c.FunctionReflection_findModifier(self.ptr, @enumFromInt(id));
}

pub fn getGenericContainer(self: *const Self) c.GenericReflection {
    return c.FunctionReflection_getGenericContainer(self.ptr);
}

pub fn applySpecializations(self: *const Self, inGeneric: c.GenericReflection) Self {
    return .{ .ptr = c.FunctionReflection_applySpecializations(self.ptr, inGeneric) };
}

pub fn specializeWithArgTypes(self: *const Self, argCount: u32, types: []const TypeReflection) Self {
    return .{ .ptr = c.FunctionReflection_specializeWithArgTypes(self.ptr, argCount, types.ptr) };
}

pub fn isOverloaded(self: *const Self) bool {
    return c.FunctionReflection_isOverloaded(self.ptr);
}

pub fn getOverloadCount(self: *const Self) u32 {
    return c.FunctionReflection_getOverloadCount(self.ptr);
}

pub fn getOverload(self: *const Self, index: u32) Self {
    return .{ .ptr = c.FunctionReflection_getOverload(self.ptr, index) };
}
