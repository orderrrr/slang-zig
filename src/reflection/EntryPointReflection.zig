const std = @import("std");
const lib = @import("../lib.zig");
const VariableLayoutReflection = @import("VariableLayoutReflection.zig");
const VariableLayout = VariableLayoutReflection.VariableLayout;

const TypeLayoutReflection = @import("TypeLayoutReflection.zig");
const TypeLayout = TypeLayoutReflection.TypeLayout;

const FunctionReflection = @import("FunctionReflection.zig");
const Function = FunctionReflection.Function;

const Self = @This();

ptr: lib.EntryPointReflectionPtr,

pub fn getName(self: *const Self) []const u8 {
    return lib.EntryPointReflection_getName(self.ptr);
}

pub fn getNameOverride(self: *const Self) []const u8 {
    return lib.EntryPointReflection_getNameOverride(self.ptr);
}

pub fn getParameterCount(self: *const Self) usize {
    return lib.EntryPointReflection_getParameterCount(self.ptr);
}

pub fn getFunction(self: *const Self) FunctionReflection {
    return .{ .ptr = lib.EntryPointReflection_getFunction(self.ptr) };
}

pub fn getParameterByIndex(self: *const Self, index: u32) VariableLayoutReflection {
    return .{ .ptr = lib.EntryPointReflection_getParameterByIndex(self.ptr, index) };
}

pub fn getStage(self: *const Self) lib.Stage {
    return lib.EntryPointReflection_getStage(self.ptr);
}

pub fn getWorkerSize(self: *const Self) [3]u64 {
    var x: [3]u64 = .{ 0, 0, 0 };
    lib.EntryPointReflection_getComputeThreadGroupSize(self.ptr, x.len, &x[0]);
    return x;
}

pub fn usesAnySampleRateInput(self: *const Self) bool {
    return lib.EntryPointReflection_usesAnySampleRateInput(self.ptr);
}

pub fn getVarLayout(self: *const Self) VariableLayoutReflection {
    return .{ .ptr = lib.EntryPointReflection_getVarLayout(self.ptr) };
}

pub fn getTypeLayout(self: *const Self) TypeLayoutReflection {
    return .{ .ptr = lib.EntryPointReflection_getTypeLayout(self.ptr) };
}

pub fn getResultVarLayout(self: *const Self) VariableLayoutReflection {
    return .{ .ptr = lib.EntryPointReflection_getResultVarLayout(self.ptr) };
}

pub fn hasDefaultConstantBuffer(self: *const Self) bool {
    return lib.EntryPointReflection_hasDefaultConstantBuffer(self.ptr);
}
