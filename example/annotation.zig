const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const slang = @import("slang");
const AttributeReflection = slang.AttributeReflection;
const SlangError = @import("./error.zig").SlangError;

pub const BufferSize = Anno(.{u32});
pub const TextureSize = Anno(.{ u32, u32, u32 });
pub const TextureFormat = Anno(.{u32});
pub const WorkGroupCount = Anno(.{ u32, u32, u32 });
pub const Sampler = Anno(.{ u32, u32 });
pub const RunOnce = Anno(.{bool});
pub const BlitToScreen = Anno(.{ u32, u32 });

pub const UserAttribute = struct {
    name: []const u8,
    args: []Argument,

    const Self = @This();

    pub fn from(name: []const u8, args: []Argument) !Self {
        return .{ .name = name, .args = args };
    }
};

pub const Argument = union(enum) {
    Int: i32,
    Float: f32,
    Bool: bool,
    String: []const u8,

    pub fn from(self: *const AttributeReflection, allocator: Allocator) (SlangError || Allocator.Error)![]Argument {
        var args = try std.ArrayList(Argument).initCapacity(allocator, self.getArgumentCount());
        defer args.deinit(allocator);

        for (0..args.capacity) |iu| {
            const i: u32 = @intCast(iu);

            // Assume int if we can't get type kind;
            if (self.getArgumentType(i).ptr == null) {
                args.appendAssumeCapacity(.{ .Int = self.getArgumentValueInt(i) catch return SlangError.InvalidArgument });
                continue;
            }

            switch (self.getArgumentType(i).getScalarType()) {
                .INT8, .INT16, .INT32, .INT64 => args.appendAssumeCapacity(.{ .Int = self.getArgumentValueInt(i) catch return SlangError.InvalidArgument }),
                .FLOAT16, .FLOAT32, .FLOAT64 => args.appendAssumeCapacity(.{ .Float = self.getArgumentValueFloat(i) catch return SlangError.InvalidArgument }),
                .BOOL => args.appendAssumeCapacity(.{ .Bool = @bitCast(@as(u1, @intCast(self.getArgumentValueInt(i) catch return SlangError.InvalidArgument))) }),
                .UINTPTR => args.appendAssumeCapacity(.{ .String = try allocator.dupe(u8, self.getArgumentValueString(i)) }),
                .NONE => {
                    args.appendAssumeCapacity(.{ .Int = self.getArgumentValueInt(i) catch return SlangError.InvalidArgument });
                },
                else => {
                    std.log.err("Attribute with ScalarType {s} is not supported", .{self.getArgumentType(i).getScalarType().toString()});
                    return SlangError.UnsupportedScalarType;
                },
            }
        }
        return try args.toOwnedSlice(allocator);
    }
};

pub const Annotation = union(enum) {
    BufferSize: BufferSize,
    TextureSize: TextureSize,
    TextureFormat: TextureFormat,
    WorkGroupCount: WorkGroupCount,
    RunOnce: RunOnce,
    BlitToScreen: BlitToScreen,
    Sampler: Sampler,
    UserAttribute: UserAttribute,

    pub fn initFromTag(allocator: Allocator, tag: []const u8, args: []Argument) !Annotation {
        return switch (toTag(tag)) {
            .BufferSize => .{ .BufferSize = try BufferSize.from(args, allocator) },
            .TextureSize => .{ .TextureSize = try TextureSize.from(args, allocator) },
            .WorkGroupCount => .{ .WorkGroupCount = try WorkGroupCount.from(args, allocator) },
            .TextureFormat => .{ .TextureFormat = try TextureFormat.from(args, allocator) },
            .RunOnce => .{ .RunOnce = try RunOnce.from(args, allocator) },
            .BlitToScreen => .{ .BlitToScreen = try BlitToScreen.from(args, allocator) },
            .Sampler => .{ .Sampler = try Sampler.from(args, allocator) },
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

    // Tries to find explicit annotation, otherwise falls back to generic UserAttribute
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

pub fn Anno(comptime Spec: anytype) type {
    const SpecType = @TypeOf(Spec);
    const info = @typeInfo(SpecType);
    if (info != .@"struct" or !info.@"struct".is_tuple) {
        @compileError("Anno expects a tuple of types, e.g. .{u32, f32} or .{}");
    }

    const Fields = info.@"struct".fields;
    const N = Fields.len;

    if (N == 0) {
        return struct {
            const Self = @This();

            pub fn from(args: []Argument, _: Allocator) SlangError!Self {
                if (args.len != 0) return SlangError.BadArity;
                return .{};
            }
        };
    }

    comptime var Ts: [N]type = undefined;
    inline for (Spec, 0..) |T, i| Ts[i] = T;
    const TupleT = std.meta.Tuple(&Ts);

    return struct {
        const Self = @This();
        pub const Arity = N;

        // Holds parsed values
        values: TupleT,

        // Parse from reflection arguments into the typed tuple
        pub fn from(args: []Argument, allocator: Allocator) (SlangError || Allocator.Error)!Self {
            if (args.len != N) return SlangError.BadArity;

            var vals: TupleT = undefined;
            inline for (Spec, 0..) |T, i| {
                vals[i] = try argTo(T, args[i], allocator);
            }
            return .{ .values = vals };
        }
    };
}

fn argTo(comptime T: type, arg: Argument, allocator: Allocator) (SlangError || Allocator.Error)!T {
    const math = std.math;

    if (@typeInfo(T) == .int) {
        return switch (arg) {
            .Int => |v| math.cast(T, v) orelse return SlangError.InvalidArgument,
            else => SlangError.InvalidArgument,
        };
    } else if (@typeInfo(T) == .float) {
        return switch (arg) {
            .Float => |v| math.cast(T, v) orelse return SlangError.InvalidArgument,
            else => SlangError.InvalidArgument,
        };
    } else if (@typeInfo(T) == .bool) {
        return switch (arg) {
            .Bool => |v| v,
            else => SlangError.InvalidArgument,
        };
    } else if (T == []const u8) {
        return switch (arg) {
            .String => |v| try allocator.dupe(u8, v),
            else => SlangError.InvalidArgument,
        };
    }

    return SlangError.UnsupportedTypeKind;
}

pub fn getUserAttribute(attr: ?[]Annotation, tag: []const u8) ?UserAttribute {
    if (attr) |att| {
        for (att) |a| {
            if (a == .UserAttribute and std.ascii.eqlIgnoreCase(tag, a.UserAttribute.name)) {
                return a.UserAttribute;
            }
        }
    }
    return null;
}

pub fn getAnnotation(attr: ?[]Annotation, comptime tag: std.meta.Tag(Annotation)) ?std.meta.TagPayload(Annotation, tag) {
    if (attr) |att| {
        for (att) |a| switch (a) {
            tag => |payload| return payload,
            else => {},
        };
    }
    return null;
}

// ============================================================================
// Tests
// ============================================================================

const testing = std.testing;

test "Anno: zero arity rejects non-empty args" {
    var args = [_]Argument{.{ .Int = 42 }};
    const result = RunOnce.from(&args, testing.allocator);
    try testing.expectError(SlangError.BadArity, result);
}

test "Anno: zero arity accepts empty args" {
    var args = [_]Argument{};
    _ = try RunOnce.from(&args, testing.allocator);
}

test "Anno: BufferSize parses single u32" {
    var args = [_]Argument{.{ .Int = 1024 }};
    const result = try BufferSize.from(&args, testing.allocator);
    try testing.expectEqual(@as(u32, 1024), result.values[0]);
}

test "Anno: BufferSize rejects wrong arity" {
    var args = [_]Argument{ .{ .Int = 1024 }, .{ .Int = 2048 } };
    const result = BufferSize.from(&args, testing.allocator);
    try testing.expectError(SlangError.BadArity, result);
}

test "Anno: TextureSize parses three u32 values" {
    var args = [_]Argument{ .{ .Int = 256 }, .{ .Int = 512 }, .{ .Int = 1 } };
    const result = try TextureSize.from(&args, testing.allocator);
    try testing.expectEqual(@as(u32, 256), result.values[0]);
    try testing.expectEqual(@as(u32, 512), result.values[1]);
    try testing.expectEqual(@as(u32, 1), result.values[2]);
}

test "Anno: WorkGroupCount parses thread dimensions" {
    var args = [_]Argument{ .{ .Int = 8 }, .{ .Int = 8 }, .{ .Int = 1 } };
    const result = try WorkGroupCount.from(&args, testing.allocator);
    try testing.expectEqual(@as(u32, 8), result.values[0]);
    try testing.expectEqual(@as(u32, 8), result.values[1]);
    try testing.expectEqual(@as(u32, 1), result.values[2]);
}

test "Anno: rejects wrong argument type (float for int)" {
    var args = [_]Argument{.{ .Float = 3.14 }};
    const result = BufferSize.from(&args, testing.allocator);
    try testing.expectError(SlangError.InvalidArgument, result);
}

test "Anno: rejects negative values for unsigned int" {
    var args = [_]Argument{.{ .Int = -1 }};
    const result = BufferSize.from(&args, testing.allocator);
    try testing.expectError(SlangError.InvalidArgument, result);
}

test "Anno: handles max u32 value" {
    var args = [_]Argument{.{ .Int = std.math.maxInt(i32) }};
    const result = try BufferSize.from(&args, testing.allocator);
    try testing.expectEqual(@as(u32, std.math.maxInt(i32)), result.values[0]);
}

test "Annotation.toTag: maps known names" {
    var args = [_]Argument{.{ .Int = 512 }};
    const anno = try Annotation.initFromTag(testing.allocator, "BufferSize", &args);
    try testing.expect(anno == .BufferSize);
}

test "Annotation.toTag: case insensitive matching" {
    var args = [_]Argument{.{ .Int = 256 }};

    const lower = try Annotation.initFromTag(testing.allocator, "buffersize", &args);
    try testing.expect(lower == .BufferSize);

    const upper = try Annotation.initFromTag(testing.allocator, "BUFFERSIZE", &args);
    try testing.expect(upper == .BufferSize);

    const mixed = try Annotation.initFromTag(testing.allocator, "BufferSize", &args);
    try testing.expect(mixed == .BufferSize);
}

test "Annotation.toTag: unknown names become UserAttribute" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = [_]Argument{.{ .Int = 42 }};
    const anno = try Annotation.initFromTag(allocator, "CustomAttr", &args);
    try testing.expect(anno == .UserAttribute);
    try testing.expectEqualStrings("CustomAttr", anno.UserAttribute.name);
    allocator.free(anno.UserAttribute.name);
}

test "getUserAttribute: finds matching attribute" {
    const attr1 = UserAttribute{ .name = "MyAttr", .args = &[_]Argument{} };
    const attr2 = UserAttribute{ .name = "Other", .args = &[_]Argument{} };
    var annotations = [_]Annotation{
        .{ .UserAttribute = attr1 },
        .{ .UserAttribute = attr2 },
    };

    const result = getUserAttribute(&annotations, "MyAttr");
    try testing.expect(result != null);
    try testing.expectEqualStrings("MyAttr", result.?.name);
}

test "getUserAttribute: returns null for non-existent" {
    const attr = UserAttribute{ .name = "SomeAttr", .args = &[_]Argument{} };
    var annotations = [_]Annotation{.{ .UserAttribute = attr }};

    const result = getUserAttribute(&annotations, "NonExistent");
    try testing.expect(result == null);
}

test "getUserAttribute: handles null input" {
    const result = getUserAttribute(null, "AnyAttr");
    try testing.expect(result == null);
}

test "getAnnotation: finds typed annotation" {
    var args = [_]Argument{.{ .Int = 2048 }};
    const bufSize = try BufferSize.from(&args, testing.allocator);
    var annotations = [_]Annotation{.{ .BufferSize = bufSize }};

    const result = getAnnotation(&annotations, .BufferSize);
    try testing.expect(result != null);
    try testing.expectEqual(@as(u32, 2048), result.?.values[0]);
}

test "getAnnotation: returns null when tag not found" {
    var args = [_]Argument{.{ .Int = 100 }};
    const bufSize = try BufferSize.from(&args, testing.allocator);
    var annotations = [_]Annotation{.{ .BufferSize = bufSize }};

    const result = getAnnotation(&annotations, .TextureSize);
    try testing.expect(result == null);
}

test "getAnnotation: handles null input" {
    const result = getAnnotation(null, .BufferSize);
    try testing.expect(result == null);
}

test "Argument: can hold all union variants" {
    const int_arg = Argument{ .Int = 42 };
    try testing.expectEqual(@as(i32, 42), int_arg.Int);

    const float_arg = Argument{ .Float = 3.14 };
    try testing.expectApproxEqAbs(@as(f32, 3.14), float_arg.Float, 0.001);

    const bool_arg = Argument{ .Bool = true };
    try testing.expect(bool_arg.Bool);

    const str_arg = Argument{ .String = "test" };
    try testing.expectEqualStrings("test", str_arg.String);
}
