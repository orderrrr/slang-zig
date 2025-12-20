const std = @import("std");
const lib = @import("../lib.zig");
const VariableLayoutReflection = @import("VariableLayoutReflection.zig");
const VariableLayout = VariableLayoutReflection.VariableLayout;
const TypeReflection = @import("TypeReflection.zig");
const Type = TypeReflection.Type;

const Self = @This();

ptr: lib.TypeLayoutReflectionPtr,

pub fn getType(self: *const Self) TypeReflection {
    return .{ .ptr = lib.TypeLayoutReflection_getType(self.ptr) };
}

pub fn getKind(self: *const Self) lib.TypeKind {
    return lib.TypeLayoutReflection_getKind(self.ptr);
}

pub fn getSize(self: *const Self, category: lib.ParameterCategory) usize {
    return lib.TypeLayoutReflection_getSize(self.ptr, category);
}

pub fn getStride(self: *const Self, category: lib.ParameterCategory) usize {
    return lib.TypeLayoutReflection_getStride(self.ptr, category);
}

pub fn getAlignment(self: *const Self, category: lib.ParameterCategory) i32 {
    return lib.TypeLayoutReflection_getAlignment(self.ptr, category);
}

pub fn getFieldCount(self: *const Self) u32 {
    return lib.TypeLayoutReflection_getFieldCount(self.ptr);
}

pub fn getFieldByIndex(self: *const Self, index: u32) VariableLayoutReflection {
    return .{ .ptr = lib.TypeLayoutReflection_getFieldByIndex(self.ptr, index) };
}

pub fn getExplicitCounter(self: *const Self) lib.VariableLayoutReflection {
    return lib.TypeLayoutReflection_getExplicitCounter(self.ptr);
}

pub fn isArray(self: *const Self) bool {
    return lib.TypeLayoutReflection_isArray(self.ptr);
}

pub fn unwrapArray(self: *const Self) lib.TypeLayoutReflection {
    return lib.TypeLayoutReflection_unwrapArray(self.ptr);
}

pub fn getElementCount(self: *const Self, reflection: lib.ShaderReflection) u32 {
    return lib.TypeLayoutReflection_getElementCount(self.ptr, reflection);
}

pub fn getTotalElementCount(self: *const Self) usize {
    return lib.TypeLayoutReflection_getTotalElementCount(self.ptr);
}

pub fn getElementStride(self: *const Self, category: lib.ParameterCategory) usize {
    return lib.TypeLayoutReflection_getElementStride(self.ptr, category);
}

pub fn getElementTypeLayout(self: *const Self) Self {
    return .{ .ptr = lib.TypeLayoutReflection_getElementTypeLayout(self.ptr) };
}

pub fn getElementVarLayout(self: *const Self) lib.VariableLayoutReflection {
    return lib.TypeLayoutReflection_getElementVarLayout(self.ptr);
}

pub fn getContainerVarLayout(self: *const Self) lib.VariableLayoutReflection {
    return lib.TypeLayoutReflection_getContainerVarLayout(self.ptr);
}

pub fn getParameterCategory(self: *const Self) lib.ParameterCategory {
    return lib.TypeLayoutReflection_getParameterCategory(self.ptr);
}

pub fn getCategoryCount(self: *const Self) u32 {
    return lib.TypeLayoutReflection_getCategoryCount(self.ptr);
}

pub fn getCategoryByIndex(self: *const Self, index: u32) lib.ParameterCategory {
    return lib.TypeLayoutReflection_getCategoryByIndex(self.ptr, index);
}

pub fn getRowCount(self: *const Self) u32 {
    return lib.TypeLayoutReflection_getRowCount(self.ptr);
}

pub fn getColumnCount(self: *const Self) u32 {
    return lib.TypeLayoutReflection_getColumnCount(self.ptr);
}

pub fn getScalarType(self: *const Self) lib.ScalarType {
    return lib.TypeLayoutReflection_getScalarType(self.ptr);
}

pub fn getResourceResultType(self: *const Self) TypeReflection {
    return .{ .ptr = lib.TypeLayoutReflection_getResourceResultType(self.ptr) };
}

pub fn getResourceShape(self: *const Self) lib.ResourceShape {
    return lib.TypeLayoutReflection_getResourceShape(self.ptr);
}

pub fn getResourceAccess(self: *const Self) lib.ResourceAccess {
    return lib.TypeLayoutReflection_getResourceAccess(self.ptr);
}

pub fn getName(self: *const Self) []const u8 {
    return lib.TypeLayoutReflection_getName(self.ptr);
}

pub fn getMatrixLayoutMode(self: *const Self) lib.MatrixLayoutMode {
    return lib.TypeLayoutReflection_getMatrixLayoutMode(self.ptr);
}

pub fn getGenericParamIndex(self: *const Self) i32 {
    return lib.TypeLayoutReflection_getGenericParamIndex(self.ptr);
}

pub fn getBindingRangeCount(self: *const Self) i64 {
    return lib.TypeLayoutReflection_getBindingRangeCount(self.ptr);
}

pub fn getBindingRangeType(self: *const Self, index: i64) lib.BindingType {
    return lib.TypeLayoutReflection_getBindingRangeType(self.ptr, index);
}

pub fn isBindingRangeSpecializable(self: *const Self, index: i64) bool {
    return lib.TypeLayoutReflection_isBindingRangeSpecializable(self.ptr, index);
}

pub fn getBindingRangeBindingCount(self: *const Self, index: i64) i64 {
    return lib.TypeLayoutReflection_getBindingRangeBindingCount(self.ptr, index);
}

pub fn getFieldBindingRangeOffset(self: *const Self, index: i64) i64 {
    return lib.TypeLayoutReflection_getFieldBindingRangeOffset(self.ptr, index);
}

pub fn getExplicitCounterBindingRangeOffset(self: *const Self) i64 {
    return lib.TypeLayoutReflection_getExplicitCounterBindingRangeOffset(self.ptr);
}

pub fn getBindingRangeLeafTypeLayout(self: *const Self, index: i64) Self {
    return .{ .ptr = lib.TypeLayoutReflection_getBindingRangeLeafTypeLayout(self.ptr, index) };
}

pub fn getBindingRangeImageFormat(self: *const Self, index: i64) lib.ImageFormat {
    return lib.TypeLayoutReflection_getBindingRangeImageFormat(self.ptr, index);
}

pub fn getBindingRangeDescriptorSetIndex(self: *const Self, index: i64) i64 {
    return lib.TypeLayoutReflection_getBindingRangeDescriptorSetIndex(self.ptr, index);
}

pub fn getBindingRangeFirstDescriptorRangeIndex(self: *const Self, index: i64) i64 {
    return lib.TypeLayoutReflection_getBindingRangeFirstDescriptorRangeIndex(self.ptr, index);
}

pub fn getBindingRangeDescriptorRangeCount(self: *const Self, index: i64) i64 {
    return lib.TypeLayoutReflection_getBindingRangeDescriptorRangeCount(self.ptr, index);
}

pub fn getDescriptorSetCount(self: *const Self) i64 {
    return lib.TypeLayoutReflection_getDescriptorSetCount(self.ptr);
}

pub fn getDescriptorSetSpaceOffset(self: *const Self, setIndex: i64) i64 {
    return lib.TypeLayoutReflection_getDescriptorSetSpaceOffset(self.ptr, setIndex);
}

pub fn getDescriptorSetDescriptorRangeCount(self: *const Self, setIndex: i64) i64 {
    return lib.TypeLayoutReflection_getDescriptorSetDescriptorRangeCount(self.ptr, setIndex);
}

pub fn getDescriptorSetDescriptorRangeIndexOffset(self: *const Self, setIndex: i64, rangeIndex: i64) i64 {
    return lib.TypeLayoutReflection_getDescriptorSetDescriptorRangeIndexOffset(self.ptr, setIndex, rangeIndex);
}

pub fn getDescriptorSetDescriptorRangeDescriptorCount(self: *const Self, setIndex: i64, rangeIndex: i64) i64 {
    return lib.TypeLayoutReflection_getDescriptorSetDescriptorRangeDescriptorCount(self.ptr, setIndex, rangeIndex);
}

pub fn getDescriptorSetDescriptorRangeType(self: *const Self, setIndex: i64, rangeIndex: i64) lib.BindingType {
    return lib.TypeLayoutReflection_getDescriptorSetDescriptorRangeType(self.ptr, setIndex, rangeIndex);
}

pub fn getDescriptorSetDescriptorRangeCategory(self: *const Self, setIndex: i64, rangeIndex: i64) lib.ParameterCategory {
    return lib.TypeLayoutReflection_getDescriptorSetDescriptorRangeCategory(self.ptr, setIndex, rangeIndex);
}

pub fn getSubObjectRangeCount(self: *const Self) i64 {
    return lib.TypeLayoutReflection_getSubObjectRangeCount(self.ptr);
}

pub fn getSubObjectRangeBindingRangeIndex(self: *const Self, subObjectRangeIndex: i64) i64 {
    return lib.TypeLayoutReflection_getSubObjectRangeBindingRangeIndex(self.ptr, subObjectRangeIndex);
}

pub fn getSubObjectRangeSpaceOffset(self: *const Self, subObjectRangeIndex: i64) i64 {
    return lib.TypeLayoutReflection_getSubObjectRangeSpaceOffset(self.ptr, subObjectRangeIndex);
}

pub fn getSubObjectRangeOffset(self: *const Self, subObjectRangeIndex: i64) lib.VariableLayoutReflection {
    return lib.TypeLayoutReflection_getSubObjectRangeOffset(self.ptr, subObjectRangeIndex);
}
