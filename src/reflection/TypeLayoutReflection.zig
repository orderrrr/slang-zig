const std = @import("std");
const c = @import("../c/c.zig");
const VariableLayoutReflection = @import("VariableLayoutReflection.zig");
const VariableLayout = VariableLayoutReflection.VariableLayout;
const TypeReflection = @import("TypeReflection.zig");
const Type = TypeReflection.Type;

const Self = @This();

ptr: c.TypeLayoutReflection,

pub fn getType(self: *const Self) TypeReflection {
    return .{ .ptr = c.TypeLayoutReflection_getType(self.ptr) };
}

pub fn getKind(self: *const Self) c.TypeKind {
    return c.TypeLayoutReflection_getKind(self.ptr);
}

pub fn getSize(self: *const Self, category: c.ParameterCategory) usize {
    return c.TypeLayoutReflection_getSize(self.ptr, category);
}

pub fn getStride(self: *const Self, category: c.ParameterCategory) usize {
    return c.TypeLayoutReflection_getStride(self.ptr, category);
}

pub fn getAlignment(self: *const Self, category: c.ParameterCategory) i32 {
    return c.TypeLayoutReflection_getAlignment(self.ptr, category);
}

pub fn getFieldCount(self: *const Self) u32 {
    return c.TypeLayoutReflection_getFieldCount(self.ptr);
}

pub fn getFieldByIndex(self: *const Self, index: u32) VariableLayoutReflection {
    return .{ .ptr = c.TypeLayoutReflection_getFieldByIndex(self.ptr, index) };
}

pub fn getExplicitCounter(self: *const Self) c.VariableLayoutReflection {
    return c.TypeLayoutReflection_getExplicitCounter(self.ptr);
}

pub fn isArray(self: *const Self) bool {
    return c.TypeLayoutReflection_isArray(self.ptr);
}

pub fn unwrapArray(self: *const Self) c.TypeLayoutReflection {
    return c.TypeLayoutReflection_unwrapArray(self.ptr);
}

pub fn getElementCount(self: *const Self, reflection: c.ShaderReflection) u32 {
    return c.TypeLayoutReflection_getElementCount(self.ptr, reflection);
}

pub fn getTotalElementCount(self: *const Self) usize {
    return c.TypeLayoutReflection_getTotalElementCount(self.ptr);
}

pub fn getElementStride(self: *const Self, category: c.ParameterCategory) usize {
    return c.TypeLayoutReflection_getElementStride(self.ptr, category);
}

pub fn getElementTypeLayout(self: *const Self) Self {
    return .{ .ptr = c.TypeLayoutReflection_getElementTypeLayout(self.ptr) };
}

pub fn getElementVarLayout(self: *const Self) c.VariableLayoutReflection {
    return c.TypeLayoutReflection_getElementVarLayout(self.ptr);
}

pub fn getContainerVarLayout(self: *const Self) c.VariableLayoutReflection {
    return c.TypeLayoutReflection_getContainerVarLayout(self.ptr);
}

pub fn getParameterCategory(self: *const Self) c.ParameterCategory {
    return c.TypeLayoutReflection_getParameterCategory(self.ptr);
}

pub fn getCategoryCount(self: *const Self) u32 {
    return c.TypeLayoutReflection_getCategoryCount(self.ptr);
}

pub fn getCategoryByIndex(self: *const Self, index: u32) c.ParameterCategory {
    return c.TypeLayoutReflection_getCategoryByIndex(self.ptr, index);
}

pub fn getRowCount(self: *const Self) u32 {
    return c.TypeLayoutReflection_getRowCount(self.ptr);
}

pub fn getColumnCount(self: *const Self) u32 {
    return c.TypeLayoutReflection_getColumnCount(self.ptr);
}

pub fn getScalarType(self: *const Self) c.ScalarType {
    return c.TypeLayoutReflection_getScalarType(self.ptr);
}

pub fn getResourceResultType(self: *const Self) TypeReflection {
    return .{ .ptr = c.TypeLayoutReflection_getResourceResultType(self.ptr) };
}

pub fn getResourceShape(self: *const Self) c.ResourceShape {
    return c.TypeLayoutReflection_getResourceShape(self.ptr);
}

pub fn getResourceAccess(self: *const Self) c.ResourceAccess {
    return c.TypeLayoutReflection_getResourceAccess(self.ptr);
}

pub fn getName(self: *const Self) []const u8 {
    return c.TypeLayoutReflection_getName(self.ptr);
}

pub fn getMatrixLayoutMode(self: *const Self) c.MatrixLayoutMode {
    return c.TypeLayoutReflection_getMatrixLayoutMode(self.ptr);
}

pub fn getGenericParamIndex(self: *const Self) i32 {
    return c.TypeLayoutReflection_getGenericParamIndex(self.ptr);
}

pub fn getBindingRangeCount(self: *const Self) i64 {
    return c.TypeLayoutReflection_getBindingRangeCount(self.ptr);
}

pub fn getBindingRangeType(self: *const Self, index: i64) c.BindingType {
    return c.TypeLayoutReflection_getBindingRangeType(self.ptr, index);
}

pub fn isBindingRangeSpecializable(self: *const Self, index: i64) bool {
    return c.TypeLayoutReflection_isBindingRangeSpecializable(self.ptr, index);
}

pub fn getBindingRangeBindingCount(self: *const Self, index: i64) i64 {
    return c.TypeLayoutReflection_getBindingRangeBindingCount(self.ptr, index);
}

pub fn getFieldBindingRangeOffset(self: *const Self, index: i64) i64 {
    return c.TypeLayoutReflection_getFieldBindingRangeOffset(self.ptr, index);
}

pub fn getExplicitCounterBindingRangeOffset(self: *const Self) i64 {
    return c.TypeLayoutReflection_getExplicitCounterBindingRangeOffset(self.ptr);
}

pub fn getBindingRangeLeafTypeLayout(self: *const Self, index: i64) Self {
    return .{ .ptr = c.TypeLayoutReflection_getBindingRangeLeafTypeLayout(self.ptr, index) };
}

pub fn getBindingRangeImageFormat(self: *const Self, index: i64) c.ImageFormat {
    return c.TypeLayoutReflection_getBindingRangeImageFormat(self.ptr, index);
}

pub fn getBindingRangeDescriptorSetIndex(self: *const Self, index: i64) i64 {
    return c.TypeLayoutReflection_getBindingRangeDescriptorSetIndex(self.ptr, index);
}

pub fn getBindingRangeFirstDescriptorRangeIndex(self: *const Self, index: i64) i64 {
    return c.TypeLayoutReflection_getBindingRangeFirstDescriptorRangeIndex(self.ptr, index);
}

pub fn getBindingRangeDescriptorRangeCount(self: *const Self, index: i64) i64 {
    return c.TypeLayoutReflection_getBindingRangeDescriptorRangeCount(self.ptr, index);
}

pub fn getDescriptorSetCount(self: *const Self) i64 {
    return c.TypeLayoutReflection_getDescriptorSetCount(self.ptr);
}

pub fn getDescriptorSetSpaceOffset(self: *const Self, setIndex: i64) i64 {
    return c.TypeLayoutReflection_getDescriptorSetSpaceOffset(self.ptr, setIndex);
}

pub fn getDescriptorSetDescriptorRangeCount(self: *const Self, setIndex: i64) i64 {
    return c.TypeLayoutReflection_getDescriptorSetDescriptorRangeCount(self.ptr, setIndex);
}

pub fn getDescriptorSetDescriptorRangeIndexOffset(self: *const Self, setIndex: i64, rangeIndex: i64) i64 {
    return c.TypeLayoutReflection_getDescriptorSetDescriptorRangeIndexOffset(self.ptr, setIndex, rangeIndex);
}

pub fn getDescriptorSetDescriptorRangeDescriptorCount(self: *const Self, setIndex: i64, rangeIndex: i64) i64 {
    return c.TypeLayoutReflection_getDescriptorSetDescriptorRangeDescriptorCount(self.ptr, setIndex, rangeIndex);
}

pub fn getDescriptorSetDescriptorRangeType(self: *const Self, setIndex: i64, rangeIndex: i64) c.BindingType {
    return c.TypeLayoutReflection_getDescriptorSetDescriptorRangeType(self.ptr, setIndex, rangeIndex);
}

pub fn getDescriptorSetDescriptorRangeCategory(self: *const Self, setIndex: i64, rangeIndex: i64) c.ParameterCategory {
    return c.TypeLayoutReflection_getDescriptorSetDescriptorRangeCategory(self.ptr, setIndex, rangeIndex);
}

pub fn getSubObjectRangeCount(self: *const Self) i64 {
    return c.TypeLayoutReflection_getSubObjectRangeCount(self.ptr);
}

pub fn getSubObjectRangeBindingRangeIndex(self: *const Self, subObjectRangeIndex: i64) i64 {
    return c.TypeLayoutReflection_getSubObjectRangeBindingRangeIndex(self.ptr, subObjectRangeIndex);
}

pub fn getSubObjectRangeSpaceOffset(self: *const Self, subObjectRangeIndex: i64) i64 {
    return c.TypeLayoutReflection_getSubObjectRangeSpaceOffset(self.ptr, subObjectRangeIndex);
}

pub fn getSubObjectRangeOffset(self: *const Self, subObjectRangeIndex: i64) c.VariableLayoutReflection {
    return c.TypeLayoutReflection_getSubObjectRangeOffset(self.ptr, subObjectRangeIndex);
}
