const std = @import("std");
const c = @import("../c/c.zig");
const TypeReflection = @import("TypeReflection.zig");
const Type = TypeReflection.Type;

const Self = @This();

ptr: c.TypeParameterReflection,

pub fn getName(self: *const Self) []const u8 {
    return std.mem.sliceTo(c.TypeParameterReflection_getName(self.ptr), 0);
}

pub fn getIndex(self: *const Self) u32 {
    return c.TypeParameterReflection_getIndex(self.ptr);
}

pub fn getConstraintCount(self: *const Self) u32 {
    return c.TypeParameterReflection_getConstraintCount(self.ptr);
}

pub fn getConstraintByIndex(self: *const Self, index: u32) TypeReflection {
    return .{ .ptr = c.TypeParameterReflection_getConstraintByIndex(self.ptr, index) };
}
