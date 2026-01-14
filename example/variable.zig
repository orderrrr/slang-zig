const std = @import("std");
const Allocator = std.mem.Allocator;

const slang = @import("slang");
const Type = @import("type.zig");
const Annotation = @import("annotation.zig").Annotation;

const Self = @This();

name: []const u8,
type: Type,

offset: usize,
stride: usize,

category: slang.ParameterCategory,

pub fn fromLayout(self: *const slang.VariableLayoutReflection, allocator: Allocator) !Self {
    return .{
        .name = try allocator.dupe(u8, self.getName()),
        .bindingIndex = self.getBindingIndex(),
        .bindingSpace = self.getBindingSpace(),
        .offset = self.getOffset(self.getCategory()),
        .stride = self.getType().getElementStride(self.getCategory()),
        .category = self.getCategory(),
        .type = try Type.from(&self.getType(), allocator),
    };
}

pub const VariableWithAnnotation = struct {
    variable: Self,
    annotation: ?[]Annotation,

    pub fn from(self: *const slang.VariableLayoutReflection, allocator: Allocator) anyerror!VariableWithAnnotation {
        const v = VariableWithAnnotation{
            .variable = try Self.from(self, allocator),
            .annotation = try VariableWithAnnotation.getAnnotation(self.getVariable(), allocator),
        };

        return v;
    }

    pub fn getAnnotation(self: *const slang.VariableReflection, allocator: Allocator) ![]Annotation {
        return try Annotation.fromList(allocator, self.ptr, self.getUserAttributeCount(), slang.VariableReflection_getUserAttributeByIndex);
    }
};
