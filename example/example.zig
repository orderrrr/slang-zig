const std = @import("std");
const assert = std.debug.assert;
const slang = @import("slang");
const refl = @import("reflection.zig");

pub fn main() !void {
    slang.init();

    const optimizationLevel = slang.CompilerOptionEntry.fromInt(.Optimization, @intFromEnum(slang.SlangOptimizationLevel.High));
    const spirv_target_version: []const u8 = "spirv_1_3";

    const target = slang.TargetDesc.fromSpec(.{
        .format = slang.CompileTarget.SPIRV,
        .profile = slang.findProfile(spirv_target_version),
    });

    const sessionDesc = slang.SessionDesc{
        .compilerOptionEntries = @ptrCast(@constCast(&optimizationLevel)),
        .compilerOptionEntryCount = 1,
        .targets = &target,
        .targetCount = 1,
    };

    const shader_source =
        \\[__AttributeUsage(_AttributeTargets.Function)]
        \\public struct runOnceAttribute {
        \\  bool enabled;
        \\  public __init(bool enabled) { this.enabled = enabled; }
        \\};
        \\[__AttributeUsage(_AttributeTargets.Var)]
        \\public struct bufferSizeAttribute {
        \\  uint size;
        \\  public __init(uint size) { this.size = size; }
        \\}
        \\struct Nested {
        \\  ConstantBuffer<float3> materials;
        \\}
        \\struct Slot1 {
        \\  [bufferSize(1024)]
        \\  RWTexture2D<float4> OutImage;
        \\  ParameterBlock<Nested> nested;
        \\}
        \\struct Slot2 {
        \\  ConstantBuffer<float4> globals;
        \\  ConstantBuffer<float4> globalsUnused;
        \\}
        \\[[vk::binding(4, 5)]]
        \\ConstantBuffer<float3> globalsOutterscope;
        \\[[vk::binding(2, 3)]]
        \\RWTexture2D<float> testing;
        \\[[vk::binding(0, 1)]]
        \\ParameterBlock<Slot1> slot1;
        \\[[vk::binding(0, 2)]]
        \\ParameterBlock<Slot2> slot2;
        \\[shader("compute")]
        \\[runOnce(true)]
        \\[numthreads(1, 2, 4)]
        \\void main(uint3 GlobalInvocationID: SV_DispatchThreadID) {
        \\  float width, height;
        \\  slot1.OutImage.GetDimensions(width, height);
        \\  float2 size = float2(width, height);
        \\  float2 coord = float2(GlobalInvocationID.xy);
        \\  float2 uv = (coord / size) * 6.0;
        \\  float3 col =
        \\      0.5f.xxx +
        \\      cos((slot2.globals.xyz + uv.xyx) + float3(0.0f, 2.0f, 4.0f)) * 0.5f;
        \\  slot1.OutImage[int2(coord)] = float4(col, 1.0f);
        \\}
    ;

    const comp = try slang.compileSource(shader_source, sessionDesc, "main");
    const reflection = comp.reflection;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const reflectionObj = try refl.toEntry(&reflection, gpa.allocator());
    defer gpa.allocator().free(reflectionObj.allocator.buffer);

    const fmt = std.json.fmt(reflectionObj, .{ .whitespace = .indent_2, .emit_null_optional_fields = false });
    var writer = std.Io.Writer.Allocating.init(gpa.allocator());
    try fmt.format(&writer.writer);

    const json_string = try writer.toOwnedSlice();
    defer gpa.allocator().free(json_string);

    std.log.debug("Entry: {s}", .{json_string});
}
