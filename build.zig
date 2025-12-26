const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // Determine dependency name based on target
    const dep_name = switch (target.result.os.tag) {
        .windows => switch (target.result.cpu.arch) {
            .x86_64 => "slang-windows-x86_64",
            .aarch64 => "slang-windows-aarch64",
            else => @panic("unsupported arch for Slang"),
        },
        .linux => switch (target.result.cpu.arch) {
            .x86_64 => "slang-linux-x86_64",
            .aarch64 => "slang-linux-aarch64",
            else => @panic("unsupported arch for Slang"),
        },
        .macos => switch (target.result.cpu.arch) {
            .x86_64 => "slang-macos-x86_64",
            .aarch64 => "slang-macos-aarch64",
            else => @panic("unsupported arch for Slang"),
        },
        else => @panic("unsupported OS for Slang"),
    };

    const slang_dep = b.lazyDependency(dep_name, .{}) orelse @panic("failed to resolve Slang dependency");
    // Get paths to the extracted Slang files
    const include_path = slang_dep.path("include");
    const lib_path = slang_dep.path("lib");
    const bin_path = slang_dep.path("bin");
    // Main library with ALL the linking configuration
    const lib_mod = b.addModule("slang", .{
        .root_source_file = b.path("src/lib.zig"),
        .optimize = optimize,
        .target = target,
    });
    const lib = b.addLibrary(.{
        .name = "slang",
        .root_module = lib_mod,
    });

    lib.linkLibC();
    lib.linkLibCpp();

    lib.addIncludePath(include_path);
    lib.addIncludePath(b.path("src"));
    lib.addIncludePath(b.path("src/c"));
    lib.addLibraryPath(lib_path);
    lib.addLibraryPath(bin_path);
    lib.linkSystemLibrary("slang");
    lib.addCSourceFiles(.{
        .files = &.{"src/c/slangc.cpp"},
        .flags = &.{"-std=c++17"},
    });

    b.installArtifact(lib);
    // Copy Slang shared libraries to the install directory
    const install_slang_lib = b.addInstallDirectory(.{
        .source_dir = lib_path,
        .install_dir = .lib,
        .install_subdir = "",
    });
    const install_slang_bin = b.addInstallDirectory(.{
        .source_dir = bin_path,
        .install_dir = .bin,
        .install_subdir = "",
    });
    // Make sure the Slang libraries are installed when building
    lib.step.dependOn(&install_slang_lib.step);
    lib.step.dependOn(&install_slang_bin.step);

    const exe_mod = b.addModule("example", .{
        .root_source_file = b.path("example/example.zig"),
        .target = target,
        .optimize = optimize,
    });
    const exe = b.addExecutable(.{
        .name = "example",
        .root_module = exe_mod,
    });

    exe.addLibraryPath(lib_path);
    exe.addLibraryPath(bin_path);

    exe_mod.addImport("slang", lib.root_module);

    exe.linkLibrary(lib);
    b.installArtifact(exe);

    const run_example_cmd = b.addRunArtifact(exe);
    const run_example = b.step("example", "Run the example executable");
    run_example_cmd.step.dependOn(b.getInstallStep());
    run_example.dependOn(&run_example_cmd.step);
}
