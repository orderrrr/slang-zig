const std = @import("std");
const lib = @import("../lib.zig");
const TypeReflection = @import("TypeReflection.zig");
const Type = TypeReflection.Type;

const Self = @This();

ptr: lib.TypeParameterReflectionPtr,

pub fn getName(self: *const Self) []const u8 {
    return std.mem.sliceTo(lib.TypeParameterReflection_getName(self.ptr), 0);
}

pub fn getIndex(self: *const Self) u32 {
    return lib.TypeParameterReflection_getIndex(self.ptr);
}

pub fn getConstraintCount(self: *const Self) u32 {
    return lib.TypeParameterReflection_getConstraintCount(self.ptr);
}

pub fn getConstraintByIndex(self: *const Self, index: u32) TypeReflection {
    return .{ .ptr = lib.TypeParameterReflection_getConstraintByIndex(self.ptr, index) };
}
