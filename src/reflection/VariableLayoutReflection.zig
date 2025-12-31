const std = @import("std");
const lib = @import("../lib.zig");
const TypeReflection = @import("TypeReflection.zig");
const Type = TypeReflection.Type;
const TypeLayoutReflection = @import("TypeLayoutReflection.zig");
const TypeLayout = TypeLayoutReflection.TypeLayout;
const VariableReflection = @import("VariableReflection.zig");
const Variable = VariableReflection.Variable;
const AttributeReflection = @import("AttributeReflection.zig");
const Attribute = AttributeReflection.Attribute;

const Self = @This();

ptr: lib.VariableLayoutReflectionPtr,

pub fn getVariable(self: *const Self) VariableReflection {
    return .{ .ptr = lib.VariableLayoutReflection_getVariable(self.ptr) };
}
pub fn getName(self: *const Self) []const u8 {
    return lib.VariableLayoutReflection_getName(self.ptr);
}
pub fn findModifier(self: *const Self, id: lib.ModifierID) lib.Modifier {
    return lib.VariableLayoutReflection_findModifier(self.ptr, id);
}
pub fn getType(self: *const Self) TypeLayoutReflection {
    return .{ .ptr = lib.VariableLayoutReflection_getTypeLayout(self.ptr) };
}
pub fn getCategory(self: *const Self) lib.ParameterCategory {
    return lib.VariableLayoutReflection_getCategory(self.ptr);
}
pub fn getCategoryCount(self: *const Self) u32 {
    return lib.VariableLayoutReflection_getCategoryCount(self.ptr);
}
pub fn getCategoryByIndex(self: *const Self, index: u32) lib.ParameterCategory {
    return lib.VariableLayoutReflection_getCategoryByIndex(self.ptr, index);
}
pub fn getOffset(self: *const Self, category: lib.ParameterCategory) usize {
    return lib.VariableLayoutReflection_getOffset(self.ptr, category);
}
// pub fn getType(self: *const Self) ?TypeReflection {
//     if (self.getVariable() == null) {
//         return null;
//     }
//
//     return TypeReflection{ .ptr = lib.VariableLayoutReflection_getType(self.ptr) };
// }
pub fn getBindingIndex(self: *const Self) u32 {
    return lib.VariableLayoutReflection_getBindingIndex(self.ptr);
}
pub fn getBindingSpace(self: *const Self) u32 {
    return lib.VariableLayoutReflection_getBindingSpace(self.ptr);
}
pub fn getBindingSpaceByCategory(self: *const Self, category: lib.ParameterCategory) u32 {
    return lib.VariableLayoutReflection_getBindingSpaceByCategory(self.ptr, category);
}
pub fn getImageFormat(self: *const Self) lib.ImageFormat {
    return lib.VariableLayoutReflection_getImageFormat(self.ptr);
}
pub fn getSemanticName(self: *const Self) [*c]const u8 {
    return lib.VariableLayoutReflection_getSemanticName(self.ptr);
}
pub fn getSemanticIndex(self: *const Self) u32 {
    return lib.VariableLayoutReflection_getSemanticIndex(self.ptr);
}
pub fn getSlangStage(self: *const Self) lib.Stage {
    return lib.VariableLayoutReflection_getSlangStage(self.ptr);
}
