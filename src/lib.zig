const std = @import("std");
const assert = std.debug.assert;

pub const c = @import("./c/c.zig");

pub const Reflection = @import("./reflection/Reflection.zig");
pub const VariableReflection = @import("./reflection/VariableReflection.zig");
pub const VariableLayoutReflection = @import("./reflection/VariableLayoutReflection.zig");
pub const TypeReflection = @import("./reflection/TypeReflection.zig");
pub const TypeLayoutReflection = @import("./reflection/TypeLayoutReflection.zig");
pub const TypeParameterReflection = @import("./reflection/TypeParameterReflection.zig");
pub const FunctionReflection = @import("./reflection/FunctionReflection.zig");
pub const EntryPointReflection = @import("./reflection/EntryPointReflection.zig");
pub const AttributeReflection = @import("./reflection/AttributeReflection.zig");

pub const SessionDesc = c.SessionDesc.Spec;
pub const SlangOptimizationLevel = c.SlangOptimizationLevel;
pub const CompileTarget = c.SlangCompileTarget;
pub const ProgramLayout = c.ProgramLayout;

pub const CompilerOptionEntry = c.CompilerOptionEntry;
pub const TargetDesc = c.TargetDesc;

var gs = std.mem.zeroes(c.IGlobalSession);

pub fn init() void {
    gs = std.mem.zeroes(c.IGlobalSession);
    assert(c.createGlobalSession(&gs).isSuccess());
}

pub fn compileSource(source: []const u8, sessionDesc: SessionDesc, entry_point_name: []const u8) !struct { out: []const u8, diag: []const u8, reflection: Reflection } {
    var ss = std.mem.zeroes(c.ISession);
    assert(c.createSession(gs, &c.SessionDesc.fromSpec(sessionDesc), &ss).isSuccess());

    var diagnostics = std.mem.zeroes(c.IBlob);
    var module = std.mem.zeroes(c.IModule);
    if (!c.loadModuleFromSourceString(ss, source, &module, &diagnostics).isSuccess()) {
        var diag: []const u8 = std.mem.zeroes([]const u8);
        if (diagnostics != null) {
            assert(c.getBlobSlice(diagnostics, &diag).isSuccess());
        }
        std.log.err("Failed to compile source: {s}", .{diag});
        return error.CompilationFailed;
    }

    var entry_point = std.mem.zeroes(c.IEntryPoint);
    assert(c.findEntryPointByName(module, entry_point_name, &entry_point).isSuccess());

    const types = [2]c.IComponentType{ module, entry_point };

    var composedProgram = std.mem.zeroes(c.IComponentType);
    assert(c.createCompositeComponent(ss, &types, &composedProgram, &diagnostics).isSuccess());

    var linked_program = std.mem.zeroes(c.IComponentType);
    assert(c.linkProgram(composedProgram, &linked_program, &diagnostics).isSuccess());

    var layout = std.mem.zeroes(c.ProgramLayout);
    assert(c.getLayout(linked_program, 0, &layout, &diagnostics).isSuccess());

    var codeBlob = std.mem.zeroes(c.IBlob);
    assert(c.getTargetCode(linked_program, &codeBlob, &diagnostics).isSuccess());

    var out: []const u8 = std.mem.zeroes([]const u8);
    assert(c.getBlobSlice(codeBlob, &out).isSuccess());

    var entryPointMetadata = std.mem.zeroes(c.IMetadata);
    assert(c.IComponentType_getEntryPointMetadata(linked_program, 0, 0, &entryPointMetadata, &diagnostics).isSuccess());

    var diag: []const u8 = std.mem.zeroes([]const u8);
    if (diagnostics != null) {
        assert(c.getBlobSlice(diagnostics, &diag).isSuccess());
    }

    return .{ .out = out, .diag = diag, .reflection = .{ .ptr = layout, .metadata = entryPointMetadata } };
}

pub fn findProfile(profile: []const u8) u32 {
    return @intCast(c.findProfile(gs, profile));
}
