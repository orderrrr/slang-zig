const std = @import("std");
const c = @import("../c/c.zig");
const TypeReflection = @import("TypeReflection.zig");
const Type = TypeReflection.Type;
const TypeLayoutReflection = @import("TypeLayoutReflection.zig");
const TypeLayout = TypeLayoutReflection.TypeLayout;
const VariableReflection = @import("VariableReflection.zig");
const Variable = VariableReflection.Variable;
const AttributeReflection = @import("AttributeReflection.zig");
const Attribute = AttributeReflection.Attribute;

const Self = @This();

ptr: c.VariableLayoutReflection,

pub fn getVariable(self: *const Self) VariableReflection {
    return .{ .ptr = c.VariableLayoutReflection_getVariable(self.ptr) };
}
pub fn getName(self: *const Self) []const u8 {
    return c.VariableLayoutReflection_getName(self.ptr);
}
pub fn findModifier(self: *const Self, id: c.ModifierID) c.Modifier {
    return c.VariableLayoutReflection_findModifier(self.ptr, id);
}
pub fn getTypeLayout(self: *const Self) TypeLayoutReflection {
    return .{ .ptr = c.VariableLayoutReflection_getTypeLayout(self.ptr) };
}
pub fn getCategory(self: *const Self) c.ParameterCategory {
    return c.VariableLayoutReflection_getCategory(self.ptr);
}
pub fn getCategoryCount(self: *const Self) u32 {
    return c.VariableLayoutReflection_getCategoryCount(self.ptr);
}
pub fn getCategoryByIndex(self: *const Self, index: u32) c.ParameterCategory {
    return c.VariableLayoutReflection_getCategoryByIndex(self.ptr, index);
}
pub fn getOffset(self: *const Self, category: c.ParameterCategory) usize {
    return c.VariableLayoutReflection_getOffset(self.ptr, category);
}
pub fn getType(self: *const Self) ?TypeReflection {
    if (self.getVariable() == null) {
        return null;
    }

    return TypeReflection{ .ptr = c.VariableLayoutReflection_getType(self.ptr) };
}
pub fn getBindingIndex(self: *const Self) u32 {
    return c.VariableLayoutReflection_getBindingIndex(self.ptr);
}
pub fn getBindingSpace(self: *const Self) u32 {
    return c.VariableLayoutReflection_getBindingSpace(self.ptr);
}
pub fn getBindingSpaceByCategory(self: *const Self, category: c.ParameterCategory) u32 {
    return c.VariableLayoutReflection_getBindingSpaceByCategory(self.ptr, category);
}
pub fn getImageFormat(self: *const Self) c.ImageFormat {
    return c.VariableLayoutReflection_getImageFormat(self.ptr);
}
pub fn getSemanticName(self: *const Self) [*c]const u8 {
    return c.VariableLayoutReflection_getSemanticName(self.ptr);
}
pub fn getSemanticIndex(self: *const Self) u32 {
    return c.VariableLayoutReflection_getSemanticIndex(self.ptr);
}
pub fn getSlangStage(self: *const Self) c.Stage {
    return c.VariableLayoutReflection_getSlangStage(self.ptr);
}
