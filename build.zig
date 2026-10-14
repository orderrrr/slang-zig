const std = @import("std");
const Translator = @import("translate_c").Translator;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.addModule("slang", .{
        .root_source_file = b.path("src/lib.zig"),
        .optimize = optimize,
        .target = target,
    });
    lib_mod.link_libc = true;
    lib_mod.link_libcpp = true;
    lib_mod.addIncludePath(b.path("src"));
    lib_mod.addIncludePath(b.path("src/c"));
    lib_mod.addCSourceFile(.{ .file = b.path("src/c/slangc.cpp"), .flags = &.{"-std=c++17"} });
    lib_mod.linkSystemLibrary("slang", .{});

    // Zig 0.17 removes @cImport; the C API is translated at build time and also
    // exposed as `slang_c` for consumers that build their own types-only module.
    const translator: Translator = .init(b.dependency("translate_c", .{}), .{
        .name = "slang_c",
        .default_init = true, // matches @cImport, which callers rely on
        .c_source_file = b.path("src/c/slangc.h"),
        .target = target,
        .optimize = optimize,
    });
    translator.addIncludePath(b.path("src/c"));
    lib_mod.addImport("slang_c", translator.mod);
    b.modules.put(b.graph.arena, "slang_c", translator.mod) catch @panic("OOM");

    const lib = b.addLibrary(.{
        .name = "slang",
        .root_module = lib_mod,
    });
    b.installArtifact(lib);

    const expose_bin = b.addNamedWriteFiles("slang_bin");
    const expose_lib = b.addNamedWriteFiles("slang_lib");

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

    // Fill in vendor-specific include/library paths only when the dep is
    // actually fetched. On pass 1 this just queues the fetch and returns
    // null; Zig will re-run after fetching.
    if (b.lazyDependency(dep_name, .{})) |slang_dep| {
        const include_path = slang_dep.path("include");
        const lib_path = slang_dep.path("lib");
        const bin_path = slang_dep.path("bin");

        lib_mod.addIncludePath(include_path);
        lib_mod.addLibraryPath(lib_path);
        lib_mod.addLibraryPath(bin_path);

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
        lib.step.dependOn(&install_slang_lib.step);
        lib.step.dependOn(&install_slang_bin.step);

        _ = expose_bin.addCopyDirectory(bin_path, "", .{});
        _ = expose_lib.addCopyDirectory(lib_path, "", .{});

        const exe_mod = b.addModule("example", .{
            .root_source_file = b.path("example/example.zig"),
            .target = target,
            .optimize = optimize,
        });
        const exe = b.addExecutable(.{
            .name = "example",
            .root_module = exe_mod,
        });
        exe_mod.addLibraryPath(lib_path);
        exe_mod.addLibraryPath(bin_path);
        exe_mod.addImport("slang", lib.root_module);
        exe_mod.linkLibrary(lib);
        b.installArtifact(exe);

        const run_example_cmd = b.addRunArtifact(exe);
        const run_example = b.step("example", "Run the example executable");
        run_example_cmd.step.dependOn(b.getInstallStep());
        run_example.dependOn(&run_example_cmd.step);
    }
}
