const std = @import("std");
const c = @import("../c/c.zig");

const TypeLayoutReflection = @import("TypeLayoutReflection.zig");

const VariableLayoutReflection = @import("VariableLayoutReflection.zig");
const VariableLayout = VariableLayoutReflection.VariableLayout;

const VariableReflection = @import("VariableReflection.zig");
const Variable = VariableReflection.Variable;

const AttributeReflection = @import("AttributeReflection.zig");
const Attribute = AttributeReflection.Attribute;

const Self = @This();

ptr: c.TypeReflection,

pub fn getKind(self: *const Self) c.TypeKind {
    return c.TypeReflection_getKind(self.ptr);
}

pub fn getFieldCount(self: *const Self) u32 {
    return c.TypeReflection_getFieldCount(self.ptr);
}

pub fn getFieldByIndex(self: *const Self, index: u32) VariableReflection {
    return VariableReflection{ .ptr = c.TypeReflection_getFieldByIndex(self.ptr, index).? };
}

pub fn isArray(self: *const Self) bool {
    return c.TypeReflection_isArray(self.ptr);
}

pub fn unwrapArray(self: *const Self) Self {
    return .{ .ptr = c.TypeReflection_unwrapArray(self.ptr) };
}

pub fn getElementCount(self: *const Self) usize {
    return c.TypeReflection_getElementCount(self.ptr);
}

pub fn getTotalArrayElementCount(self: *const Self) u32 {
    return c.TypeReflection_getTotalArrayElementCount(self.ptr);
}

pub fn getElementType(self: *const Self) Self {
    return .{ .ptr = c.TypeReflection_getElementType(self.ptr) };
}

pub fn getRowCount(self: *const Self) u32 {
    return c.TypeReflection_getRowCount(self.ptr);
}

pub fn getColumnCount(self: *const Self) u32 {
    return c.TypeReflection_getColumnCount(self.ptr);
}

pub fn getScalarType(self: *const Self) c.ScalarType {
    return c.TypeReflection_getScalarType(self.ptr);
}

pub fn getResourceResultType(self: *const Self) Self {
    return .{ .ptr = c.TypeReflection_getResourceResultType(self.ptr) };
}

pub fn getResourceShape(self: *const Self) c.ResourceShape {
    return c.TypeReflection_getResourceShape(self.ptr);
}

pub fn getResourceAccess(self: *const Self) c.ResourceAccess {
    return c.TypeReflection_getResourceAccess(self.ptr);
}

pub fn getName(self: *const Self) []const u8 {
    return c.TypeReflection_getName(self.ptr);
}

pub fn getUserAttributeCount(self: *const Self) u32 {
    return c.TypeReflection_getUserAttributeCount(self.ptr);
}

pub fn getUserAttributeByIndex(self: *const Self, index: u32) AttributeReflection {
    return .{ .ptr = c.TypeReflection_getUserAttributeByIndex(self.ptr, index) };
}

pub fn findUserAttributeByName(self: *const Self, name: []const u8) AttributeReflection {
    return .{ .ptr = c.TypeReflection_findUserAttributeByName(self.ptr, name) };
}

pub fn findAttributeByName(self: *const Self, name: []const u8) AttributeReflection {
    return .{ .ptr = c.TypeReflection_findAttributeByName(self.ptr, name) };
}

pub fn getGenericCountainer(self: *const Self) c.GenericReflection {
    return c.TypeReflection_getGenericCountainer(self.ptr);
}
