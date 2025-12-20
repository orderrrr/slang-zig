const std = @import("std");
const c = @import("../c/c.zig");
const TypeReflection = @import("TypeReflection.zig");
const Type = TypeReflection.Type;
const AttributeReflection = @import("AttributeReflection.zig");
const Attribute = AttributeReflection.Attribute;

const Self = @This();

ptr: c.VariableReflection,

pub fn getName(self: *const Self) []const u8 {
    return c.VariableReflection_getName(self.ptr);
}

pub fn getType(self: *const Self) TypeReflection {
    return TypeReflection{ .ptr = c.VariableReflection_getType(self.ptr) };
}

pub fn findModifier(self: *const Self, id: c.ModifierID) c.Modifier {
    return c.VariableReflection_findModifier(self.ptr, id);
}

pub fn getUserAttributeCount(self: *const Self) u32 {
    return c.VariableReflection_getUserAttributeCount(self.ptr);
}

pub fn getUserAttributeByIndex(self: *const Self, index: u32) AttributeReflection {
    return .{ .ptr = c.VariableReflection_getUserAttributeByIndex(self.ptr, index) };
}

pub fn findAttributeByName(self: *const Self, inSession: c.IGlobalSession, name: []const u8) c.AttributeReflection {
    return c.VariableReflection_findAttributeByName(self.ptr, inSession, name);
}

pub fn findUserAttributeByName(self: *const Self, inSession: c.IGlobalSession, name: []const u8) c.AttributeReflection {
    return c.VariableReflection_findUserAttributeByName(self.ptr, inSession, name);
}

pub fn hasDefaultValue(self: *const Self) bool {
    return c.VariableReflection_hasDefaultValue(self.ptr);
}

pub fn getDefaultValue(self: *const Self, value: *i64) c.SlangResult {
    return c.VariableReflection_getDefaultValue(self.ptr, value);
}

pub fn getGenericContainer(self: *const Self) c.GenericReflection {
    return c.VariableReflection_getGenericContainer(self.ptr);
}

pub fn applySpecializations(self: *const Self, inGeneric: c.GenericReflection) c.VariableReflection {
    return c.VariableReflection_applySpecializations(self.ptr, inGeneric);
}
