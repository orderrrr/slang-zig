const std = @import("std");
const Allocator = std.mem.Allocator;
const slang = @import("slang");
const reflection = @import("reflection.zig");
const Argument = reflection.Argument;
const AttributeReflection = slang.AttributeReflection;

pub const Annotation = union(enum) {
    BufferSize: BufferSize,
    TextureSize: TextureSize,
    WorkGroupCount: WorkGroupCount,
    RunOnce: RunOnce,
    UserAttribute: UserAttribute,

    pub fn initFromTag(allocator: Allocator, tag: []const u8, args: []Argument) !Annotation {
        return switch (toTag(tag)) {
            .BufferSize => .{ .BufferSize = try BufferSize.from(args) },
            .TextureSize => .{ .TextureSize = try TextureSize.from(args) },
            .WorkGroupCount => .{ .WorkGroupCount = try WorkGroupCount.from(args) },
            .RunOnce => .{ .RunOnce = try RunOnce.from(args) },
            .UserAttribute => .{ .UserAttribute = try UserAttribute.from(try allocator.dupe(u8, tag), args) },
        };
    }

    pub fn fromList(
        allocator: Allocator,
        ptr: ?*anyopaque,
        count: u32,
        getFn: *const fn (ptr: ?*anyopaque, i: u32) AttributeReflection,
    ) ![]Annotation {
        var userAttributes = try std.ArrayList(Annotation).initCapacity(allocator, count);
        defer userAttributes.deinit(allocator);

        for (0..userAttributes.capacity) |i| {
            const refl = &getFn(ptr, @intCast(i));
            const name = refl.getName();
            const args = try Argument.from(refl, allocator);

            userAttributes.appendAssumeCapacity(try Annotation.initFromTag(allocator, name, args));
        }
        return try userAttributes.toOwnedSlice(allocator);
    }

    fn toTag(name: []const u8) std.meta.Tag(Annotation) {
        const Tag = std.meta.Tag(Annotation);
        const fields = @typeInfo(Tag).@"enum".fields;
        inline for (fields) |f| {
            if (std.ascii.eqlIgnoreCase(name, f.name)) {
                return @field(Tag, f.name);
            }
        }
        return @field(Tag, "UserAttribute");
    }
};

pub const UserAttribute = struct {
    name: []const u8,
    args: []Argument,

    const Self = @This();

    pub fn from(name: []const u8, args: []Argument) !Self {
        return .{ .name = name, .args = args };
    }
};

pub const BufferSize = struct {
    size: u32,

    const Self = @This();

    pub fn from(args: []Argument) !Self {
        return .{ .size = try argTo(u32, args[0]) };
    }
};

pub const TextureSize = struct {
    width: u32,
    height: u32,
    depth: u32,

    const Self = @This();

    pub fn from(args: []Argument) !Self {
        return .{
            .width = try argTo(u32, args[0]),
            .height = try argTo(u32, args[1]),
            .depth = try argTo(u32, args[2]),
        };
    }
};

pub const WorkGroupCount = struct {
    x: u32,
    y: u32,
    z: u32,

    const Self = @This();

    pub fn from(args: []Argument) !Self {
        return .{
            .x = try argTo(u32, args[0]),
            .y = try argTo(u32, args[1]),
            .z = try argTo(u32, args[2]),
        };
    }
};

pub const RunOnce = struct {
    const Self = @This();
    dummy: u1 = 0,

    pub fn from(args: []Argument) !Self {
        _ = args;
        return .{};
    }
};

pub const ArgError = error{
    InvalidArgument,
    TooFewArgs,
    TooManyArgs,
    UnsupportedFieldType,
};

fn argTo(comptime T: type, arg: Argument) ArgError!T {
    const math = std.math;

    if (@typeInfo(T) == .int) {
        return switch (arg) {
            .Int => |v| math.cast(T, v) orelse return ArgError.InvalidArgument,
            else => ArgError.InvalidArgument,
        };
    } else if (@typeInfo(T) == .float) {
        return switch (arg) {
            .Float => |v| math.cast(T, v) orelse return ArgError.InvalidArgument,
            else => ArgError.InvalidArgument,
        };
    } else if (@typeInfo(T) == .bool) {
        return switch (arg) {
            .Bool => |v| v,
            else => ArgError.InvalidArgument,
        };
    } else if (T == []const u8) {
        return switch (arg) {
            .String => |v| v,
            else => ArgError.InvalidArgument,
        };
    }

    return ArgError.UnsupportedFieldType;
}
