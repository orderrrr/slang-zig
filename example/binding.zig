const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const FixedBufferAllocator = std.heap.FixedBufferAllocator;

const libslang = @import("slang");
const Resource = @import("reflection.zig").Resource;
const ResourceType = @import("reflection.zig").ResourceType;

const annotation = @import("annotation.zig");
const Annotation = annotation.Annotation;
const getAnnotation = annotation.getAnnotation;

const Self = @This();

pub const BindingType = enum {
    Uniform,
    ReadOnly,
    ReadWrite,
    Sampled,
};

resource: Resource,
bindingType: BindingType,
userAttributes: ?[]Annotation,

pub fn findAttribute(self: *const Self, comptime tag: std.meta.Tag(Annotation)) ?std.meta.TagPayload(Annotation, tag) {
    return getAnnotation(self.userAttributes, tag);
}

pub fn jsonStringify(self: *const Self, jw: anytype) !void {
    try jw.beginObject();

    try jw.objectField("resource");
    try jw.write(self.resource);

    try jw.objectField("bindingType");
    try jw.write(self.bindingType);

    try jw.objectField("userAttributes");
    try jw.write(self.userAttributes);

    try jw.endObject();
}
