const std = @import("std");
const Allocator = std.mem.Allocator;

const slang = @import("slang");
const Annotation = @import("annotation.zig").Annotation;
const VariableWithAnnotation = @import("variable.zig").VariableWithAnnotation;
const SlangError = @import("./error.zig").SlangError;

pub const Type = union(enum) {
    Scalar: struct {
        type: slang.ScalarType,
        size: ?usize,
        annotation: ?[]Annotation,
    },
    Structure: struct {
        name: []const u8,
        fields: []Type,
        size: ?usize,
        annotation: ?[]Annotation,
    },
    Resource: struct {
        name: []const u8,
        result: *Type,
        size: ?usize,
        access: slang.ResourceAccess,
        shape: slang.ResourceShape,
        annotation: ?[]Annotation,
    },
    Array: struct {
        name: []const u8,
        elementType: *Type,
        size: ?usize,
        annotation: ?[]Annotation,
    },
    Texture: struct {
        name: []const u8,
        rowCount: u32,
        columnCount: u32,
        size: ?usize,
        annotation: ?[]Annotation,
    },
    ConstantBuffer: struct {
        name: []const u8,
        type: *Type,
        size: ?usize,
        annotation: ?[]Annotation,
    },
    ParameterBlock: struct {
        name: []const u8,
        elementType: *Type,
        size: ?usize,
        annotation: ?[]Annotation,
    },
    Vector: struct {
        name: []const u8,
        type: *Type,
        size: ?usize,
        annotation: ?[]Annotation,
    },
    NotImplemented,
    None,

    pub fn getSize(self: @This()) ?usize {
        return switch (self) {
            .Scalar => |t| return t.size,
            .Structure => |t| return t.size,
            .Resource => |t| return t.size,
            .Array => |t| return t.size,
            .Texture => |t| return t.size,
            .ConstantBuffer => |t| return t.size,
            .ParameterBlock => |t| return t.size,
            .Vector => |t| return t.size,
            else => null,
        };
    }

    pub fn getAnnotation(self: *const slang.TypeReflection, allocator: Allocator) ![]Annotation {
        return try Annotation.fromList(allocator, self.ptr, self.getUserAttributeCount(), slang.TypeReflection_getUserAttributeByIndex);
    }

    pub fn from(self: anytype, allocator: Allocator) !Type {
        const annotationsOf = struct {
            inline fn annotationsOf(x: anytype, a: Allocator) ?[]Annotation {
                const T = @TypeOf(x.*);
                if (T == slang.TypeReflection) {
                    return Type.getAnnotation(x, a) catch |err| {
                        std.log.warn("Failed to get type annotation: {}", .{err});
                        return null;
                    };
                }
                return null;
            }
        }.annotationsOf;

        const sizeOf = struct {
            inline fn sizeOf(x: anytype) ?usize {
                const T = @TypeOf(x.*);
                if (T == slang.TypeLayoutReflection) {
                    return x.getSize(x.getParameterCategory());
                }
                return x.getElementCount();
            }
        }.sizeOf;

        return switch (self.getKind()) {
            .SCALAR => .{ .Scalar = .{
                .type = self.getScalarType(),
                .size = self.getScalarType().sizeOf(),
                .annotation = annotationsOf(self, allocator),
            } },
            .STRUCT => .{ .Structure = .{
                .name = try allocator.dupe(u8, self.getName()),
                .fields = try Type.getFields(self, allocator),
                .size = sizeOf(self),
                .annotation = null,
            } },
            .RESOURCE => {
                const t = try allocator.create(Type);
                t.* = try Type.from(&self.getResourceResultType(), allocator);

                const parentSize = sizeOf(self) orelse 1;
                const size = t.getSize() orelse 1;

                return .{
                    .Resource = .{
                        .name = try allocator.dupe(u8, self.getName()),
                        .result = t,
                        .size = parentSize * size,
                        .access = self.getResourceAccess(),
                        .shape = self.getResourceShape(),
                        .annotation = annotationsOf(self, allocator),
                    },
                };
            },
            .ARRAY => {
                const t = try allocator.create(Type);
                t.* = try from(&self.getElementType(), allocator);
                return .{ .Array = .{
                    .name = try allocator.dupe(u8, self.getName()),
                    .size = sizeOf(self),
                    .elementType = t,
                    .annotation = annotationsOf(self, allocator),
                } };
            },
            .TEXTURE_BUFFER => .{ .Texture = .{
                .name = try allocator.dupe(u8, self.getName()),
                .size = sizeOf(self),
                .rowCount = self.getRowCount(),
                .columnCount = self.getColumnCount(),
                .annotation = annotationsOf(self, allocator),
            } },
            .NONE => .None,
            .CONSTANT_BUFFER => {
                const t = try allocator.create(Type);
                t.* = try from(&self.getElementType(), allocator);

                const parentSize = sizeOf(self) orelse 1;
                const size = t.getSize() orelse 1;

                return .{ .ConstantBuffer = .{
                    .name = try allocator.dupe(u8, self.getName()),
                    .size = parentSize * size,
                    .type = t,
                    .annotation = annotationsOf(self, allocator),
                } };
            },
            .VECTOR => {
                const t = try allocator.create(Type);
                t.* = try from(&self.getElementType(), allocator);

                const parentSize = sizeOf(self) orelse 1;
                const size = t.getSize().?;

                return .{ .Vector = .{
                    .name = try allocator.dupe(u8, self.getName()),
                    .size = parentSize * size,
                    .type = t,
                    .annotation = annotationsOf(self, allocator),
                } };
            },
            else => .NotImplemented,
        };
    }

    pub fn getFields(self: anytype, allocator: Allocator) anyerror![]Type {
        var fields = try std.ArrayList(Type).initCapacity(allocator, self.getFieldCount());
        for (0..fields.capacity) |i| {
            fields.appendAssumeCapacity(try Type.fromVariable(&self.getFieldByIndex(@intCast(i)), allocator));
        }
        return try fields.toOwnedSlice(allocator);
    }

    pub fn fromVariable(self: anytype, allocator: Allocator) !Type {
        return Type.from(&self.getType(), allocator);
    }

    pub fn getFieldsLayout(self: *const slang.TypeLayoutReflection, allocator: Allocator) ![]VariableWithAnnotation {
        var fields = try std.ArrayList(VariableWithAnnotation).initCapacity(allocator, self.getFieldCount());
        for (0..fields.capacity) |i| {
            fields.appendAssumeCapacity(try VariableWithAnnotation.from(&self.getFieldByIndex(@intCast(i)), allocator));
        }
        return try fields.toOwnedSlice(allocator);
    }
};
