const std = @import("std");
const lib = @import("../lib.zig");
const VariableLayoutReflection = @import("VariableLayoutReflection.zig");
const VariableLayout = VariableLayoutReflection.VariableLayout;
const TypeLayoutReflection = @import("TypeLayoutReflection.zig");
const TypeLayout = TypeLayoutReflection.TypeLayout;
const TypeReflection = @import("TypeReflection.zig");
const Type = TypeReflection.Type;

const Self = @This();

ptr: lib.AttributeReflectionPtr,

pub fn getName(self: Self) []const u8 {
    return lib.AttributeReflection_getName(self.ptr);
}

pub fn getArgumentCount(self: Self) u32 {
    return lib.AttributeReflection_getArgumentCount(self.ptr);
}

pub fn getArgumentType(self: Self, index: u32) TypeReflection {
    return .{ .ptr = lib.AttributeReflection_getArgumentType(self.ptr, index) };
}

pub fn getArgumentValueInt(self: Self, index: u32) !i32 {
    var value: i32 = undefined;
    std.debug.assert(lib.AttributeReflection_getArgumentValueInt(self.ptr, index, &value).isSuccess());
    return value;
}

pub fn getArgumentValueFloat(self: Self, index: u32) !f32 {
    var value: f32 = undefined;
    std.debug.assert(lib.AttributeReflection_getArgumentValueFloat(self.ptr, index, &value).isSuccess());
    return value;
}

pub fn getArgumentValueString(self: Self, index: u32) []const u8 {
    return lib.AttributeReflection_getArgumentValueString(self.ptr, index);
}
