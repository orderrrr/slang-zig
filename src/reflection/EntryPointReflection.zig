const std = @import("std");
const c = @import("../c/c.zig");
const VariableLayoutReflection = @import("VariableLayoutReflection.zig");
const VariableLayout = VariableLayoutReflection.VariableLayout;

const TypeLayoutReflection = @import("TypeLayoutReflection.zig");
const TypeLayout = TypeLayoutReflection.TypeLayout;

const FunctionReflection = @import("FunctionReflection.zig");
const Function = FunctionReflection.Function;

const Self = @This();

ptr: c.EntryPointReflection,

pub fn getName(self: *const Self) []const u8 {
    return c.EntryPointReflection_getName(self.ptr);
}

pub fn getNameOverride(self: *const Self) []const u8 {
    return c.EntryPointReflection_getNameOverride(self.ptr);
}

pub fn getParameterCount(self: *const Self) usize {
    return c.EntryPointReflection_getParameterCount(self.ptr);
}

pub fn getFunction(self: *const Self) FunctionReflection {
    return .{ .ptr = c.EntryPointReflection_getFunction(self.ptr) };
}

pub fn getParameterByIndex(self: *const Self, index: u32) VariableLayoutReflection {
    return .{ .ptr = c.EntryPointReflection_getParameterByIndex(self.ptr, index) };
}

pub fn getStage(self: *const Self) c.Stage {
    return c.EntryPointReflection_getStage(self.ptr);
}

pub fn getWorkerSize(self: *const Self) [3]u64 {
    var x: [3]u64 = .{ 0, 0, 0 };
    c.EntryPointReflection_getComputeThreadGroupSize(self.ptr, x.len, &x[0]);
    return x;
}

pub fn usesAnySampleRateInput(self: *const Self) bool {
    return c.EntryPointReflection_usesAnySampleRateInput(self.ptr);
}

pub fn getVarLayout(self: *const Self) VariableLayoutReflection {
    return .{ .ptr = c.EntryPointReflection_getVarLayout(self.ptr) };
}

pub fn getTypeLayout(self: *const Self) TypeLayoutReflection {
    return .{ .ptr = c.EntryPointReflection_getTypeLayout(self.ptr) };
}

pub fn getResultVarLayout(self: *const Self) VariableLayoutReflection {
    return .{ .ptr = c.EntryPointReflection_getResultVarLayout(self.ptr) };
}

pub fn hasDefaultConstantBuffer(self: *const Self) bool {
    return c.EntryPointReflection_hasDefaultConstantBuffer(self.ptr);
}
