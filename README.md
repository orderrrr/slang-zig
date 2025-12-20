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

## Acknowledgements

- Slang is developed by the Shader-Slang project. This package simply exposes its C API to Zig and adds a small set of convenience utilities for reflection.
