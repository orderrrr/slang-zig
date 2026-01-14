const std = @import("std");
const Allocator = std.mem.Allocator;
const slang = @import("slang");
const Type = @import("type.zig").Type;
const Annotation = @import("annotation.zig").Annotation;
const getAnnotation = @import("annotation.zig").getAnnotation;

const Self = @This();

name: []const u8,
parameters: []Type,
annotation: []Annotation,

pub fn findAttribute(self: *const @This(), comptime tag: std.meta.Tag(Annotation)) ?std.meta.TagPayload(Annotation, tag) {
    return getAnnotation(self.annotation, tag);
}

pub fn from(self: *const slang.FunctionReflection, allocator: Allocator) !Self {
    return .{
        .name = try allocator.dupe(u8, self.getName()),
        .parameters = try Self.getParameters(self, allocator),
        .annotation = try Self.toAnnotation(self, allocator),
    };
}

pub fn getParameters(self: *const slang.FunctionReflection, allocator: Allocator) ![]Type {
    var parameters = try std.ArrayList(Type).initCapacity(allocator, self.getParameterCount());
    defer parameters.deinit(allocator);

    for (0..parameters.capacity) |i| {
        parameters.appendAssumeCapacity(try Type.fromVariable(&self.getParameterByIndex(@intCast(i)), allocator));
    }
    return try parameters.toOwnedSlice(allocator);
}

pub fn toAnnotation(self: *const slang.FunctionReflection, allocator: Allocator) ![]Annotation {
    return Annotation.fromList(allocator, self.ptr, self.getUserAttributeCount(), slang.FunctionReflection_getUserAttributeByIndex);
}
