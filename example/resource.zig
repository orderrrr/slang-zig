const std = @import("std");
const Allocator = std.mem.Allocator;
const FixedBufferAllocator = std.heap.FixedBufferAllocator;
const ArrayList = std.ArrayList;

const libslang = @import("slang");
const Type = @import("type.zig").Type;
const Annotation = @import("annotation.zig").Annotation;
const getAnnotation = @import("annotation.zig").getAnnotation;

pub const Self = @This();

pub const ResourceType = enum {
    Uniform,
    Texture,
    Buffer,
};

name: []const u8,
type: Type,
resourceType: ResourceType,
userAttributes: ?[]Annotation,

pub fn findAttribute(self: *const Self, comptime tag: std.meta.Tag(Annotation)) ?std.meta.TagPayload(Annotation, tag) {
    return getAnnotation(self.userAttributes, tag);
}

pub fn jsonStringify(self: *const Self, jw: anytype) !void {
    try jw.beginObject();

    try jw.objectField("name");
    try jw.write(self.name);

    try jw.objectField("resourceType");
    try jw.write(self.resourceType);

    try jw.objectField("type");
    try jw.write(self.type);

    try jw.objectField("userAttributes");
    try jw.write(self.userAttributes);

    try jw.endObject();
}
