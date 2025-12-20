# slang-zig

Zig bindings for the [Slang](https://github.com/shader-slang/slang) shader compiler and reflection API. This package provides a thin, idiomatic Zig layer over Slang’s C API.

The repository also includes a runnable example that compiles a small Slang shader to SPIR-V and prints a JSON summary of the entry-point, parameters, and bindings.

## Features

- Prebuilt Slang SDK fetched per-platform via Zig package manager.
- Zig wrappers for sessions, compilation, and reflection.
- Higher-level reflection utilities producing ergonomic structs and JSON.
- Example program for compilation + reflection.

## Requirements

- Zig 0.14.1 or newer (this repo targets 0.14.x; see `build.zig.zon`).
- macOS, Linux, or Windows on x86_64 or aarch64 (prebuilt Slang bundles are selected automatically in `build.zig`).
- Network access on first build so Zig can fetch the Slang SDK archives.

## Build and Run

- Build library and example:
  - `zig build`
- Run the example directly:
  - `zig build example`

The first build downloads the appropriate Slang SDK bundle for your host target and installs the required shared libraries under the Zig install prefix.

To explore reflection and produce a compact JSON summary similar to the example, see `example/reflection.zig` and `example/example.zig`.

- `example/example.zig:7` shows `slang.init()` and session/target setup.
- `example/example.zig:71` compiles source via `slang.compileSource(...)` and converts reflection to a serializable `Entry` using helpers in `example/reflection.zig`.

## Build Integration Notes

This package defines both a Zig module and a library artifact named `slang` in `build.zig`. It also wires up C/C++ compilation for the small shim in `src/c/slangc.cpp` and links against the prebuilt Slang binaries.

Common ways to consume:

- Use this repo directly as your workspace dependency and import `slang` in your code. The example demonstrates linking the library artifact into an executable (see `build.zig:72` and `build.zig:87`).
- If you add this repo as a dependency in another project’s `build.zig.zon`, import the module from the dependency and mirror the linking approach found in this repo’s `build.zig` (add include paths, link `slang`, ensure C++17 for the shim, and link the library artifact). Exact linking steps vary by your build graph; use this repo’s `build.zig` as a reference.

Key bits you’ll likely need in your own build:

- Link C and C++: `lib.linkLibC(); lib.linkLibCpp();`
- Add the Slang include/lib/bin paths from the dependency.
- Link the `slang` system library from the fetched SDK: `lib.linkSystemLibrary("slang");`
- Ensure the Slang shared libraries are present at runtime; this repo copies them to the install `lib`/`bin` directories.

## Acknowledgements

- Slang is developed by the Shader-Slang project. This package simply exposes its C API to Zig and adds a small set of convenience utilities for reflection.
