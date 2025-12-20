const std = @import("std");
const lib = @import("../lib.zig");
const TypeReflection = @import("TypeReflection.zig");
const Type = TypeReflection.Type;
const AttributeReflection = @import("AttributeReflection.zig");
const Attribute = AttributeReflection.Attribute;

const Self = @This();

ptr: lib.VariableReflectionPtr,

pub fn getName(self: *const Self) []const u8 {
    return lib.VariableReflection_getName(self.ptr);
}

pub fn getType(self: *const Self) TypeReflection {
    return TypeReflection{ .ptr = lib.VariableReflection_getType(self.ptr) };
}

pub fn findModifier(self: *const Self, id: lib.ModifierID) lib.Modifier {
    return lib.VariableReflection_findModifier(self.ptr, id);
}

pub fn getUserAttributeCount(self: *const Self) u32 {
    return lib.VariableReflection_getUserAttributeCount(self.ptr);
}

pub fn getUserAttributeByIndex(self: *const Self, index: u32) AttributeReflection {
    return .{ .ptr = lib.VariableReflection_getUserAttributeByIndex(self.ptr, index) };
}

pub fn findAttributeByName(self: *const Self, inSession: lib.IGlobalSession, name: []const u8) lib.AttributeReflection {
    return lib.VariableReflection_findAttributeByName(self.ptr, inSession, name);
}

pub fn findUserAttributeByName(self: *const Self, inSession: lib.IGlobalSession, name: []const u8) lib.AttributeReflection {
    return lib.VariableReflection_findUserAttributeByName(self.ptr, inSession, name);
}

pub fn hasDefaultValue(self: *const Self) bool {
    return lib.VariableReflection_hasDefaultValue(self.ptr);
}

pub fn getDefaultValue(self: *const Self, value: *i64) lib.SlangResult {
    return lib.VariableReflection_getDefaultValue(self.ptr, value);
}

pub fn getGenericContainer(self: *const Self) lib.GenericReflection {
    return lib.VariableReflection_getGenericContainer(self.ptr);
}

pub fn applySpecializations(self: *const Self, inGeneric: lib.GenericReflection) lib.VariableReflection {
    return lib.VariableReflection_applySpecializations(self.ptr, inGeneric);
}
