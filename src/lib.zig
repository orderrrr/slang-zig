const std = @import("std");
const assert = std.debug.assert;

const c = @cImport({
    @cInclude("c/slangc.h");
});

pub const Reflection = @import("./reflection/Reflection.zig");
pub const VariableReflection = @import("./reflection/VariableReflection.zig");
pub const VariableLayoutReflection = @import("./reflection/VariableLayoutReflection.zig");
pub const TypeReflection = @import("./reflection/TypeReflection.zig");
pub const TypeLayoutReflection = @import("./reflection/TypeLayoutReflection.zig");
pub const TypeParameterReflection = @import("./reflection/TypeParameterReflection.zig");
pub const FunctionReflection = @import("./reflection/FunctionReflection.zig");
pub const EntryPointReflection = @import("./reflection/EntryPointReflection.zig");
pub const AttributeReflection = @import("./reflection/AttributeReflection.zig");

pub var gs = std.mem.zeroes(c.IGlobalSession);

pub const IGlobalSession = c.IGlobalSession;
pub const ISession = c.ISession;
pub const IModule = c.IModule;
pub const IBlob = c.IBlob;
pub const IEntryPoint = c.IEntryPoint;
pub const IComponentType = c.IComponentType;
pub const IMetadata = c.IMetadata;
pub const ProgramLayout = c.ProgramLayout;
pub const TypeParameterReflectionPtr = c.TypeParameterReflectionPtr;
pub const VariableLayoutReflectionPtr = c.VariableLayoutReflectionPtr;
pub const EntryPointReflectionPtr = c.EntryPointReflectionPtr;
pub const TypeReflectionPtr = c.TypeReflectionPtr;
pub const FunctionReflectionPtr = c.FunctionReflectionPtr;
pub const VariableReflectionPtr = c.VariableReflectionPtr;
pub const TypeLayoutReflectionPtr = c.TypeLayoutReflectionPtr;
pub const GenericReflectionPtr = c.GenericReflectionPtr;
pub const ShaderReflectionPtr = c.ShaderReflectionPtr;
pub const DeclReflectionPtr = c.DeclReflectionPtr;
pub const Modifier = c.Modifier;
pub const AttributeReflectionPtr = c.Attribute;
pub const Unknown = c.Unknown;

pub const GenericArgReflection = c.GenericArgReflection;

const CompilerOptionName = enum(u32) {
    MacroDefine, // stringValue0: macro name;  stringValue1: macro value
    DepFile,
    EntryPointName,
    Specialize,
    Help,
    HelpStyle,
    Include, // stringValue: additional include path.
    Language,
    MatrixLayoutColumn, // bool
    MatrixLayoutRow, // bool
    ZeroInitialize, // bool
    IgnoreCapabilities, // bool
    RestrictiveCapabilityCheck, // bool
    ModuleName, // stringValue0: module name.
    Output,
    Profile, // intValue0: profile
    Stage, // intValue0: stage
    Target, // intValue0: CodeGenTarget
    Version,
    WarningsAsErrors, // stringValue0: "all" or comma separated list of warning
    // codes or names.
    DisableWarnings, // stringValue0: comma separated list of warning codes or
    // names.
    EnableWarning, // stringValue0: warning code or name.
    DisableWarning, // stringValue0: warning code or name.
    DumpWarningDiagnostics,
    InputFilesRemain,
    EmitIr, // bool
    ReportDownstreamTime, // bool
    ReportPerfBenchmark, // bool
    ReportCheckpointIntermediates, // bool
    SkipSPIRVValidation, // bool
    SourceEmbedStyle,
    SourceEmbedName,
    SourceEmbedLanguage,
    DisableShortCircuit, // bool
    MinimumSlangOptimization, // bool
    DisableNonEssentialValidations, // bool
    DisableSourceMap, // bool
    UnscopedEnum, // bool
    PreserveParameters, // bool: preserve all resource parameters in the output
    // code.
    // Target

    Capability, // intValue0: CapabilityName
    DefaultImageFormatUnknown, // bool
    DisableDynamicDispatch, // bool
    DisableSpecialization, // bool
    FloatingPointMode, // intValue0: FloatingPointMode
    DebugInformation, // intValue0: DebugInfoLevel
    LineDirectiveMode,
    Optimization, // intValue0: OptimizationLevel
    Obfuscate, // bool

    VulkanBindShift, // intValue0 (higher 8 bits): kind; intValue0(lower bits):
    // set; intValue1: shift
    VulkanBindGlobals, // intValue0: index; intValue1: set
    VulkanInvertY, // bool
    VulkanUseDxPositionW, // bool
    VulkanUseEntryPointName, // bool
    VulkanUseGLLayout, // bool
    VulkanEmitReflectionPtr, // bool

    GLSLForceScalarLayout, // bool
    EnableEffectAnnotations, // bool

    EmitSpirvViaGLSL, // bool (will be deprecated)
    EmitSpirvDirectly, // bool (will be deprecated)
    SPIRVCoreGrammarJSON, // stringValue0: json path
    IncompleteLibrary, // bool, when set, will not issue an error when the linked
    // program has unresolved extern function symbols.

    // Downstream

    CompilerPath,
    DefaultDownstreamCompiler,
    DownstreamArgs, // stringValue0: downstream compiler name. stringValue1:
    // argument list, one per line.
    PassThrough,

    // Repro

    DumpRepro,
    DumpReproOnError,
    ExtractRepro,
    LoadRepro,
    LoadReproDirectory,
    ReproFallbackDirectory,

    // Debugging

    DumpAst,
    DumpIntermediatePrefix,
    DumpIntermediates, // bool
    DumpIr, // bool
    DumpIrIds,
    PreprocessorOutput,
    OutputIncludes,
    ReproFileSystem,
    REMOVED_SerialIR, // deprecated and removed
    SkipCodeGen, // bool
    ValidateIr, // bool
    VerbosePaths,
    VerifyDebugSerialIr,
    NoCodeGen, // Not used.

    // Experimental

    FileSystem,
    Heterogeneous,
    NoMangle,
    NoHLSLBinding,
    NoHLSLPackConstantBufferElements,
    ValidateUniformity,
    AllowGLSL,
    EnableExperimentalPasses,
    BindlessSpaceIndex, // int

    // Internal

    ArchiveType,
    CompileCoreModule,
    Doc,

    IrCompression, //< deprecated

    LoadCoreModule,
    ReferenceModule,
    SaveCoreModule,
    SaveCoreModuleBinSource,
    TrackLiveness,
    LoopInversion, // bool, enable loop inversion optimization

    ParameterBlocksUseRegisterSpaces, // Deprecated
    LanguageVersion, // intValue0: SlangLanguageVersion
    TypeConformance, // stringValue0: additional type conformance to link, in the
    // format of
    // "<TypeName>:<IInterfaceName>[=<sequentialId>]", for
    // example "Impl:IFoo=3" or "Impl:IFoo".
    EnableExperimentalDynamicDispatch, // bool, experimental
    EmitReflectionJSON, // bool

    CountOfParsableOptions,

    // Used in parsed options only.
    DebugInformationFormat, // intValue0: DebugInfoFormat
    VulkanBindShiftAll, // intValue0: kind; intValue1: shift
    GenerateWholeProgram, // bool
    UseUpToDateBinaryModule, // bool, when set, will only load
    // precompiled modules if it is up-to-date with its
    // source.
    EmbedDownstreamIR, // bool
    ForceDXLayout, // bool

    // Add this new option to the end of the list to avoid breaking ABI as much as
    // possible. Setting of EmitSpirvDirectly or EmitSpirvViaGLSL will turn into
    // this option internally.
    EmitSpirvMethod, // enum SlangEmitSpirvMethod

    SaveGLSLModuleBinSource,

    SkipDownstreamLinking, // bool, experimental
    DumpModule,

    GetModuleInfo, // Print serialized module version and name
    GetSupportedModuleVersions, // Print the min and max module versions this
    // compiler supports

    EmitSeparateDebug, // bool

    // Floating point denormal handling modes
    DenormalModeFp16,
    DenormalModeFp32,
    DenormalModeFp64,

    // Bitfield options
    UseMSVCStyleBitfieldPacking, // bool

    ForceCLayout, // bool

    ExperimentalFeature, // bool, enable experimental features

    ReportDetailedPerfBenchmark, // bool, reports detailed compiler performance
    // benchmark results
    ValidateIRDetailed, // bool, enable detailed IR validation
    DumpIRBefore, // string, pass name to dump IR before
    DumpIRAfter, // string, pass name to dump IR after

    CountOf,
};

pub const CompilerOptionValueKind = enum(u32) { Int, String };

pub const CompilerOptionValue = extern struct {
    fn fromInt(value: c_int) c.CompilerOptionValue {
        return .{
            .kind = @intFromEnum(CompilerOptionValueKind.Int),
            .intValue0 = value,
            .intValue1 = 0,
        };
    }

    fn fromString(value: [*c]const u8) c.CompilerOptionValue {
        return .{
            .kind = @intFromEnum(CompilerOptionValueKind.String),
            .stringValue0 = value,
            .stringValue1 = std.mem.zeroes([*c]const u8),
        };
    }
};

pub const SlangOptimizationLevel = enum(u32) {
    None = 0,
    Default,
    High,
    Maximal,
};

pub const CompilerOptionEntry = extern struct {
    pub fn fromInt(name: CompilerOptionName, value: c_int) c.CompilerOptionEntry {
        return .{
            .name = @intFromEnum(name),
            .value = CompilerOptionValue.fromInt(value),
        };
    }

    pub fn fromString(name: CompilerOptionName, value: [*c]const u8) c.CompilerOptionEntry {
        return .{
            .name = @intFromEnum(name),
            .value = CompilerOptionValue.fromString(value),
        };
    }
};

pub const CompileTarget = enum(i32) {
    TARGET_UNKNOWN,
    TARGET_NONE,
    GLSL,
    GLSL_VULKAN_DEPRECATED, //< deprecated and removed: just use
    //`GLSL`.
    GLSL_VULKAN_ONE_DESC_DEPRECATED, //< deprecated and removed.
    HLSL,
    SPIRV,
    SPIRV_ASM,
    DXBC,
    DXBC_ASM,
    DXIL,
    DXIL_ASM,
    C_SOURCE, //< The C language
    CPP_SOURCE, //< C++ code for shader kernels.
    HOST_EXECUTABLE, //< Standalone binary executable (for hosting CPU/OS)
    SHADER_SHARED_LIBRARY, //< A shared library/Dll for shader kernels (for
    //< hosting CPU/OS)
    SHADER_HOST_CALLABLE, //< A CPU target that makes the compiled shader
    //< code available to be run immediately
    CUDA_SOURCE, //< Cuda source
    PTX, //< PTX
    CUDA_OBJECT_CODE, //< Object code that contains CUDA functions.
    OBJECT_CODE, //< Object code that can be used for later linking
    HOST_CPP_SOURCE, //< C++ code for host library or executable.
    HOST_HOST_CALLABLE, //< Host callable host code (ie non kernel/shader)
    CPP_PYTORCH_BINDING, //< C++ PyTorch binding code.
    METAL, //< Metal shading language
    METAL_LIB, //< Metal library
    METAL_LIB_ASM, //< Metal library assembly
    HOST_SHARED_LIBRARY, //< A shared library/Dll for host code (for
    //< hosting CPU/OS)
    WGSL, //< WebGPU shading language
    WGSL_SPIRV_ASM, //< SPIR-V assembly via WebGPU shading language
    WGSL_SPIRV, //< SPIR-V via WebGPU shading language

    HOST_VM, //< Bytecode that can be interpreted by the Slang VM
    CPP_HEADER, //< C++ header for shader kernels.
    CUDA_HEADER, //< Cuda header
    TARGET_COUNT_OF,
};

const SlangFloatingPointMode = enum(u32) {
    DEFAULT = 0,
    FAST,
    PRECISE,
};

const SlangLineDirectiveMode = enum(u32) {
    DEFAULT = 0, //< Default behavior: pick behavior base on target.
    NONE, //< Don't emit line directives at all.
    STANDARD, //< Emit standard C-style `#line` directives.
    GLSL, //< Emit GLSL-style directives with file *number* instead of name
    SOURCE_MAP, //< Use a source map to track line mappings (ie no #line will appear in emitting source)
};

pub const TargetDesc = extern struct {
    const Spec = struct {
        structureSize: c_ulong = @sizeOf(c.TargetDesc),
        format: CompileTarget = .TARGET_UNKNOWN,
        profile: c.SlangProfileID = c.SLANG_PROFILE_UNKNOWN,
        flags: SlangTargetFlags = .GENERATE_SPIRV_DIRECTLY,
        floatingPointMode: SlangFloatingPointMode = .DEFAULT,
        lineDirectiveMode: SlangLineDirectiveMode = .DEFAULT,
        forceGLSLScalarBufferLayout: bool = false,
        compilerOptionEntries: *c.CompilerOptionEntry = undefined,
        compilerOptionEntryCount: c_uint = 0,
    };

    pub fn fromSpec(spec: Spec) c.TargetDesc {
        return .{
            .structureSize = spec.structureSize,
            .format = @intFromEnum(spec.format),
            .profile = spec.profile,
            .flags = @intFromEnum(spec.flags),
            .floatingPointMode = @intFromEnum(spec.floatingPointMode),
            .lineDirectiveMode = @intFromEnum(spec.lineDirectiveMode),
            .forceGLSLScalarBufferLayout = spec.forceGLSLScalarBufferLayout,
            .compilerOptionEntries = spec.compilerOptionEntries,
            .compilerOptionEntryCount = spec.compilerOptionEntryCount,
        };
    }
};

pub const SessionDesc = struct {
    pub const Spec = struct {
        structureSize: c_ulong = @sizeOf(c.SessionDesc),
        targets: [*c]const c.TargetDesc = @import("std").mem.zeroes([*c]const c.TargetDesc),
        targetCount: c.SlangInt = @import("std").mem.zeroes(c.SlangInt),
        flags: c.SessionFlags = @import("std").mem.zeroes(c.SessionFlags),
        defaultMatrixLayoutMode: c.SlangMatrixLayoutMode = @import("std").mem.zeroes(c.SlangMatrixLayoutMode),
        searchPaths: [*c]const [*c]const u8 = @import("std").mem.zeroes([*c]const [*c]const u8),
        searchPathCount: c.SlangInt = @import("std").mem.zeroes(c.SlangInt),
        preprocessorMacros: [*c]const c.PreprocessorMacroDesc = @import("std").mem.zeroes([*c]const c.PreprocessorMacroDesc),
        preprocessorMacroCount: c.SlangInt = @import("std").mem.zeroes(c.SlangInt),
        fileSystem: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
        enableEffectAnnotations: bool = @import("std").mem.zeroes(bool),
        allowGLSLSyntax: bool = @import("std").mem.zeroes(bool),
        compilerOptionEntries: [*c]c.CompilerOptionEntry = @import("std").mem.zeroes([*c]c.CompilerOptionEntry),
        compilerOptionEntryCount: u32 = @import("std").mem.zeroes(u32),
        skipSPIRVValidation: bool = @import("std").mem.zeroes(bool),
    };

    pub fn fromSpec(spec: Spec) c.SessionDesc {
        return .{
            .structureSize = spec.structureSize,
            .targets = spec.targets,
            .targetCount = spec.targetCount,
            .flags = spec.flags,
            .defaultMatrixLayoutMode = spec.defaultMatrixLayoutMode,
            .searchPaths = spec.searchPaths,
            .searchPathCount = spec.searchPathCount,
            .preprocessorMacros = spec.preprocessorMacros,
            .preprocessorMacroCount = spec.preprocessorMacroCount,
            .fileSystem = spec.fileSystem,
            .enableEffectAnnotations = spec.enableEffectAnnotations,
            .allowGLSLSyntax = spec.allowGLSLSyntax,
            .compilerOptionEntries = spec.compilerOptionEntries,
            .compilerOptionEntryCount = spec.compilerOptionEntryCount,
            .skipSPIRVValidation = spec.skipSPIRVValidation,
        };
    }
};

const SlangTargetFlags = enum(u32) {
    PARAMETER_BLOCKS_USE_REGISTER_SPACES = 1 << 4,
    GENERATE_WHOLE_PROGRAM = 1 << 8,
    DUMP_IR = 1 << 9,
    GENERATE_SPIRV_DIRECTLY = 1 << 10,

    fn with(flags: SlangTargetFlags, comptime flag: SlangTargetFlags) SlangTargetFlags {
        return @enumFromInt(@intFromEnum(flags) | @intFromEnum(flag));
    }
};

pub const SlangResult = enum(i32) {
    NOT_IMPLEMENTED = c.SLANG_E_NOT_IMPLEMENTED,
    NO_INTERFACE = c.SLANG_E_NO_INTERFACE,
    ABORT = c.SLANG_E_ABORT,
    INVALID_HANDLE = c.SLANG_E_INVALID_HANDLE,
    INVALID_ARG = c.SLANG_E_INVALID_ARG,
    OUT_OF_MEMORY = c.SLANG_E_OUT_OF_MEMORY,
    BUFFER_TOO_SMALL = c.SLANG_E_BUFFER_TOO_SMALL,
    UNINITIALIZED = c.SLANG_E_UNINITIALIZED,
    PENDING = c.SLANG_E_PENDING,
    CANNOT_OPEN = c.SLANG_E_CANNOT_OPEN,
    NOT_FOUND = c.SLANG_E_NOT_FOUND,
    INTERNAL_FAIL = c.SLANG_E_INTERNAL_FAIL,
    NOT_AVAILABLE = c.SLANG_E_NOT_AVAILABLE,
    TIME_OUT = c.SLANG_E_TIME_OUT,
    SUCCESS = 0,
    _,

    pub fn isSuccess(self: SlangResult) bool {
        return @intFromEnum(self) >= 0;
    }
};

pub const ModifierID = enum(u32) {
    SHARED,
    NO_DIFF,
    STATIC,
    CONST,
    EXPORT,
    EXTERN,
    DIFFERENTIABLE,
    MUTATING,
    IN,
    OUT,
    INOUT,
};

pub const ParameterCategory = enum(u32) {
    NONE,
    MIXED,
    CONSTANT_BUFFER,
    SHADER_RESOURCE,
    UNORDERED_ACCESS,
    VARYING_INPUT,
    VARYING_OUTPUT,
    SAMPLER_STATE,
    UNIFORM,
    DESCRIPTOR_TABLE_SLOT,
    SPECIALIZATION_CONSTANT,
    PUSH_CONSTANT_BUFFER,
    REGISTER_SPACE,
    GENERIC,
    RAY_PAYLOAD,
    HIT_ATTRIBUTES,
    CALLABLE_PAYLOAD,
    SHADER_RECORD,
    EXISTENTIAL_TYPE_PARAM,
    EXISTENTIAL_OBJECT_PARAM,
    SUB_ELEMENT_REGISTER_SPACE,
    SUBPASS,
    METAL_ARGUMENT_BUFFER_ELEMENT,
    METAL_ATTRIBUTE,
    METAL_PAYLOAD,
    COUNT,
    METAL_BUFFER,
    METAL_TEXTURE,
    METAL_SAMPLER,
    VERTEX_INPUT,
    FRAGMENT_OUTPUT,
    COUNT_V1,
};

pub const ImageFormat = enum(c.SlangImageFormatIntegral) {
    unknown,
    rgba32f,
    rgba16f,
    rg32f,
    rg16f,
    r11f_g11f_b10f,
    r32f,
    r16f,
    rgba16,
    rgb10_a2,
    rgba8,
    rg16,
    rg8,
    r16,
    r8,
    rgba16_snorm,
    rgba8_snorm,
    rg16_snorm,
    rg8_snorm,
    r16_snorm,
    r8_snorm,
    rgba32i,
    rgba16i,
    rgba8i,
    rg32i,
    rg16i,
    rg8i,
    r32i,
    r16i,
    r8i,
    rgba32ui,
    rgba16ui,
    rgb10_a2ui,
    rgba8ui,
    rg32ui,
    rg16ui,
    rg8ui,
    r32ui,
    r16ui,
    r8ui,
    r64ui,
    r64i,
    bgra8,
};

pub const LayoutRules = enum(c.SlangLayoutRulesIntegral) {
    DEFAULT,
    METAL_ARGUMENT_BUFFER_TIER_2,
};

pub const Stage = enum(c.SlangStageIntegral) {
    NONE,
    VERTEX,
    HULL,
    DOMAIN,
    GEOMETRY,
    FRAGMENT,
    COMPUTE,
    RAY_GENERATION,
    INTERSECTION,
    ANY_HIT,
    CLOSEST_HIT,
    MISS,
    CALLABLE,
    MESH,
    AMPLIFICATION,
    DISPATCH,
    COUNT,
    PIXEL,
};

pub const TypeKind = enum(c.SlangTypeKindIntegral) {
    NONE,
    STRUCT,
    ARRAY,
    MATRIX,
    VECTOR,
    SCALAR,
    CONSTANT_BUFFER,
    RESOURCE,
    SAMPLER_STATE,
    TEXTURE_BUFFER,
    SHADER_STORAGE_BUFFER,
    PARAMETER_BLOCK,
    GENERIC_TYPE_PARAMETER,
    INTERFACE,
    OUTPUT_STREAM,
    MESH_OUTPUT,
    SPECIALIZED,
    FEEDBACK,
    POINTER,
    DYNAMIC_RESOURCE,
    COUNT,
};

pub const ScalarType = enum(c.SlangScalarTypeIntegral) {
    NONE,
    VOID,
    BOOL,
    INT32,
    UINT32,
    INT64,
    UINT64,
    FLOAT16,
    FLOAT32,
    FLOAT64,
    INT8,
    UINT8,
    INT16,
    UINT16,
    INTPTR,
    UINTPTR,

    pub fn toString(self: ScalarType) []const u8 {
        return switch (self) {
            .NONE => "NONE",
            .VOID => "VOID",
            .BOOL => "BOOL",
            .INT32 => "INT32",
            .UINT32 => "UINT32",
            .INT64 => "INT64",
            .UINT64 => "UINT64",
            .FLOAT16 => "FLOAT16",
            .FLOAT32 => "FLOAT32",
            .FLOAT64 => "FLOAT64",
            .INT8 => "INT8",
            .UINT8 => "UINT8",
            .INT16 => "INT16",
            .UINT16 => "UINT16",
            .INTPTR => "INTPTR",
            .UINTPTR => "UINTPTR",
        };
    }
};

pub const ResourceShape = enum(c.SlangResourceShapeIntegral) {
    SLANG_RESOURCE_BASE_SHAPE_MASK = 0x0F,

    SLANG_RESOURCE_NONE = 0x00,

    SLANG_TEXTURE_1D = 0x01,
    SLANG_TEXTURE_2D = 0x02,
    SLANG_TEXTURE_3D = 0x03,
    SLANG_TEXTURE_CUBE = 0x04,
    SLANG_TEXTURE_BUFFER = 0x05,

    SLANG_STRUCTURED_BUFFER = 0x06,
    SLANG_BYTE_ADDRESS_BUFFER = 0x07,
    SLANG_RESOURCE_UNKNOWN = 0x08,
    SLANG_ACCELERATION_STRUCTURE = 0x09,
    SLANG_TEXTURE_SUBPASS = 0x0A,

    SLANG_RESOURCE_EXT_SHAPE_MASK = 0x1F0,

    SLANG_TEXTURE_FEEDBACK_FLAG = 0x10,
    SLANG_TEXTURE_SHADOW_FLAG = 0x20,
    SLANG_TEXTURE_ARRAY_FLAG = 0x40,
    SLANG_TEXTURE_MULTISAMPLE_FLAG = 0x80,
    SLANG_TEXTURE_COMBINED_FLAG = 0x100,

    SLANG_TEXTURE_1D_ARRAY = c.SLANG_TEXTURE_1D_ARRAY,
    SLANG_TEXTURE_2D_ARRAY = c.SLANG_TEXTURE_2D_ARRAY,
    SLANG_TEXTURE_CUBE_ARRAY = c.SLANG_TEXTURE_CUBE_ARRAY,

    SLANG_TEXTURE_2D_MULTISAMPLE = c.SLANG_TEXTURE_2D_MULTISAMPLE,
    SLANG_TEXTURE_2D_MULTISAMPLE_ARRAY = c.SLANG_TEXTURE_2D_MULTISAMPLE_ARRAY,
    SLANG_TEXTURE_SUBPASS_MULTISAMPLE = c.SLANG_TEXTURE_SUBPASS_MULTISAMPLE,

    _,

    pub const PrimitiveShape = enum {
        Texture,
        SampledTexture,
        StorageBuffer,
        ByteAddressBuffer,
        Unknown,
    };

    pub fn isTexture(self: ResourceShape) bool {
        switch (self) {
            .SLANG_TEXTURE_1D, .SLANG_TEXTURE_2D, .SLANG_TEXTURE_3D, .SLANG_TEXTURE_CUBE, .SLANG_TEXTURE_BUFFER => return true,
        }
        return false;
    }

    pub fn primitiveShape(self: ResourceShape) PrimitiveShape {
        return switch (self) {
            .SLANG_TEXTURE_1D,
            .SLANG_TEXTURE_2D,
            .SLANG_TEXTURE_3D,
            .SLANG_TEXTURE_CUBE,
            .SLANG_TEXTURE_BUFFER,
            .SLANG_TEXTURE_1D_ARRAY,
            .SLANG_TEXTURE_2D_ARRAY,
            .SLANG_TEXTURE_CUBE_ARRAY,
            .SLANG_TEXTURE_2D_MULTISAMPLE,
            .SLANG_TEXTURE_2D_MULTISAMPLE_ARRAY,
            .SLANG_TEXTURE_SUBPASS_MULTISAMPLE,
            => return .Texture,
            .SLANG_BYTE_ADDRESS_BUFFER => .ByteAddressBuffer,
            .SLANG_STRUCTURED_BUFFER => .StorageBuffer,
            _ => {
                const shape = @intFromEnum(self);
                if (shape & @intFromEnum(ResourceShape.SLANG_TEXTURE_MULTISAMPLE_FLAG) != 0) return .SampledTexture;
                if (shape & @intFromEnum(ResourceShape.SLANG_TEXTURE_COMBINED_FLAG) != 0) return .SampledTexture;
                @panic("unknown shape");
            },
            else => @panic("unknown shape"),
        };
    }
};

pub const ResourceAccess = enum(c.SlangResourceAccessIntegral) {
    SLANG_RESOURCE_ACCESS_NONE,
    SLANG_RESOURCE_ACCESS_READ,
    SLANG_RESOURCE_ACCESS_READ_WRITE,
    SLANG_RESOURCE_ACCESS_RASTER_ORDERED,
    SLANG_RESOURCE_ACCESS_APPEND,
    SLANG_RESOURCE_ACCESS_CONSUME,
    SLANG_RESOURCE_ACCESS_WRITE,
    SLANG_RESOURCE_ACCESS_FEEDBACK,
    SLANG_RESOURCE_ACCESS_UNKNOWN = 0x7FFFFFFF,
};

pub const MatrixLayoutMode = enum(c.SlangMatrixLayoutModeIntegral) {
    SLANG_MATRIX_LAYOUT_MODE_UNKNOWN = 0,
    SLANG_MATRIX_LAYOUT_ROW_MAJOR,
    SLANG_MATRIX_LAYOUT_COLUMN_MAJOR,
};

pub const BindingType = enum(c.SlangBindingTypeIntegral) {
    SLANG_BINDING_TYPE_UNKNOWN = 0,

    SLANG_BINDING_TYPE_SAMPLER,
    SLANG_BINDING_TYPE_TEXTURE,
    SLANG_BINDING_TYPE_CONSTANT_BUFFER,
    SLANG_BINDING_TYPE_PARAMETER_BLOCK,
    SLANG_BINDING_TYPE_TYPED_BUFFER,
    SLANG_BINDING_TYPE_RAW_BUFFER,
    SLANG_BINDING_TYPE_COMBINED_TEXTURE_SAMPLER,
    SLANG_BINDING_TYPE_INPUT_RENDER_TARGET,
    SLANG_BINDING_TYPE_INLINE_UNIFORM_DATA,
    SLANG_BINDING_TYPE_RAY_TRACING_ACCELERATION_STRUCTURE,

    SLANG_BINDING_TYPE_VARYING_INPUT,
    SLANG_BINDING_TYPE_VARYING_OUTPUT,

    SLANG_BINDING_TYPE_EXISTENTIAL_VALUE,
    SLANG_BINDING_TYPE_PUSH_CONSTANT,

    SLANG_BINDING_TYPE_MUTABLE_FLAG = 0x100,

    SLANG_BINDING_TYPE_MUTABLE_TETURE = c.SLANG_BINDING_TYPE_TEXTURE | c.SLANG_BINDING_TYPE_MUTABLE_FLAG,
    SLANG_BINDING_TYPE_MUTABLE_TYPED_BUFFER = c.SLANG_BINDING_TYPE_TYPED_BUFFER | c.SLANG_BINDING_TYPE_MUTABLE_FLAG,
    SLANG_BINDING_TYPE_MUTABLE_RAW_BUFFER = c.SLANG_BINDING_TYPE_RAW_BUFFER | c.SLANG_BINDING_TYPE_MUTABLE_FLAG,

    SLANG_BINDING_TYPE_BASE_MASK = 0x00FF,
    SLANG_BINDING_TYPE_EXT_MASK = 0xFF00,
};

pub fn createGlobalSession(globalSession: *c.IGlobalSession) SlangResult {
    return @enumFromInt(c.createGlobalSession(globalSession));
}

pub fn createSession(globalSession: c.IGlobalSession, sessionDesc: *const c.SessionDesc, session: *c.ISession) SlangResult {
    return @enumFromInt(c.createSession(globalSession, sessionDesc, session));
}

pub fn loadModuleFromSourceString(ss: c.ISession, sourceBuffer: []const u8, outModule: *c.IModule, outDiagnostics: *c.IBlob) SlangResult {
    return @enumFromInt(c.loadModuleFromSourceString(ss, sourceBuffer.ptr, outModule, outDiagnostics));
}

pub fn findProfile(global: c.IGlobalSession, profile: []const u8) c.SlangProfileID {
    return c.findProfile(global, profile.ptr);
}

pub fn createCompositeComponent(ss: c.ISession, componentTypes: []const c.IComponentType, outComposite: *c.IComponentType, diagnostics: *IBlob) SlangResult {
    return @enumFromInt(c.createCompositeComponent(ss, @ptrCast(&componentTypes[0]), @intCast(componentTypes.len), outComposite, diagnostics));
}

pub fn linkProgram(program: c.IComponentType, outLinkedProgram: *c.IComponentType, diagnostics: *IBlob) SlangResult {
    return @enumFromInt(c.linkProgram(program, outLinkedProgram, diagnostics));
}

pub fn getLayout(program: c.IComponentType, targetIndex: c.SlangInt, outLayout: *c.ProgramLayout, diagnostics: *IBlob) SlangResult {
    return @enumFromInt(c.getLayout(program, targetIndex, outLayout, diagnostics));
}

pub fn getTargetCode(linkedProgram: c.IComponentType, outOutput: *c.IBlob, outDiagnostics: *c.IBlob) SlangResult {
    return @enumFromInt(c.getTargetCode(linkedProgram, outOutput, outDiagnostics));
}

pub fn getBlobSlice(blob: c.IBlob, slice: *[]const u8) SlangResult {
    var p: *const anyopaque = undefined;
    var s: usize = undefined;

    const result: SlangResult = @enumFromInt(c.getBlobSlice(blob, @ptrCast(&p), &s));
    if (!result.isSuccess()) {
        return result;
    }

    slice.* = @as([*c]const u8, @ptrCast(p))[0..s];

    return result;
}

pub fn ProgramLayout_getParameterCount(layout: c.ProgramLayout) u32 {
    return @intCast(c.ProgramLayout_getParameterCount(layout));
}

pub fn ProgramLayout_getTypeParameterCount(layout: c.ProgramLayout) u32 {
    return @intCast(c.ProgramLayout_getTypeParameterCount(layout));
}

pub fn ProgramLayout_getTypeParameterByIndex(layout: c.ProgramLayout, index: u32) TypeParameterReflectionPtr {
    return c.ProgramLayout_getTypeParameterByIndex(layout, @intCast(index));
}

pub fn ProgramLayout_findTypeParameter(layout: c.ProgramLayout, name: []const u8) TypeParameterReflectionPtr {
    return c.ProgramLayout_findTypeParameter(layout, @ptrCast(name.ptr));
}

pub fn ProgramLayout_getParameterByIndex(layout: c.ProgramLayout, index: u32) VariableLayoutReflectionPtr {
    return c.ProgramLayout_getParameterByIndex(layout, @intCast(index));
}

pub fn ProgramLayout_getEntryPointCount(layout: c.ProgramLayout) u32 {
    return @intCast(c.ProgramLayout_getEntryPointCount(layout));
}

pub fn ProgramLayout_getEntryPointByIndex(layout: c.ProgramLayout, index: u32) c.EntryPointReflectionPtr {
    return c.ProgramLayout_getEntryPointByIndex(layout, @intCast(index));
}

pub fn ProgramLayout_getGlobalConstantBufferBinding(layout: c.ProgramLayout) u32 {
    return @intCast(c.ProgramLayout_getGlobalConstantBufferBinding(layout));
}

pub fn ProgramLayout_getGlobalConstantBufferSize(layout: c.ProgramLayout) u64 {
    return @intCast(c.ProgramLayout_getGlobalConstantBufferSize(layout));
}

pub fn ProgramLayout_findTypeByName(layout: c.ProgramLayout, name: []const u8) TypeReflectionPtr {
    return c.ProgramLayout_findTypeByName(layout, @ptrCast(name.ptr));
}

pub fn ProgramLayout_findFunctionByName(layout: c.ProgramLayout, name: []const u8) FunctionReflectionPtr {
    return c.ProgramLayout_findFunctionByName(layout, @ptrCast(name.ptr));
}

pub fn ProgramLayout_findFunctionByNameInType(layout: c.ProgramLayout, t: c.TypeReflectionPtr, name: []const u8) FunctionReflectionPtr {
    return c.ProgramLayout_findFunctionByNameInType(layout, t, @ptrCast(name.ptr));
}

pub fn ProgramLayout_findVarByNameInType(layout: c.ProgramLayout, t: c.TypeReflectionPtr, name: []const u8) VariableReflectionPtr {
    return c.ProgramLayout_findVarByNameInType(layout, t, @ptrCast(name.ptr));
}

pub fn ProgramLayout_getTypeLayout(layout: c.ProgramLayout, t: c.TypeReflectionPtr, layoutRules: LayoutRules) TypeLayoutReflectionPtr {
    return c.ProgramLayout_getTypeLayout(layout, t, layoutRules);
}

pub fn ProgramLayout_findEntryPointReflectionByName(layout: c.ProgramLayout, name: []const u8) EntryPointReflectionPtr {
    return c.ProgramLayout_findEntryPointReflectionByName(layout, @ptrCast(name.ptr));
}

pub fn ProgramLayout_specializeType(layout: c.ProgramLayout, t: c.TypeReflectionPtr, specializationArgCount: c.SlangInt, specializationArgs: [*c]c.TypeReflectionPtr, outDiagnostics: *c.IBlob) TypeReflectionPtr {
    return c.ProgramLayout_specializeType(layout, t, specializationArgCount, @ptrCast(&specializationArgs[0]), outDiagnostics);
}

pub fn ProgramLayout_specializeGeneric(layout: c.ProgramLayout, inGeneric: c.GenericReflectionPtr, specializationArgCount: c.SlangInt, specializationArgs: [*c]c.GenericArgReflectionPtr, outDiagnostics: *c.IBlob) GenericReflectionPtr {
    return c.ProgramLayout_specializeGeneric(layout, inGeneric, specializationArgCount, @ptrCast(&specializationArgs[0]), outDiagnostics);
}
pub fn ProgramLayout_isSubType(layout: c.ProgramLayout, inSubType: c.TypeReflectionPtr, inSuperType: TypeReflectionPtr) bool {
    return c.ProgramLayout_isSubType(layout, inSubType, inSuperType);
}

pub fn ProgramLayout_getHashedStringCount(layout: c.ProgramLayout) u32 {
    return @intCast(c.ProgramLayout_getHashedStringCount(layout));
}

pub fn ProgramLayout_getHashedString(layout: c.ProgramLayout, index: u32, outCount: *usize) [*c]const u8 {
    return c.ProgramLayout_getHashedString(layout, @intCast(index), outCount);
}

pub fn ProgramLayout_getGlobalParamsTypeLayout(layout: c.ProgramLayout) TypeLayoutReflectionPtr {
    return c.ProgramLayout_getGlobalParamsTypeLayout(layout);
}

pub fn ProgramLayout_getGlobalParamsVarLayout(layout: c.ProgramLayout) VariableLayoutReflectionPtr {
    return c.ProgramLayout_getGlobalParamsVarLayout(layout);
}

pub fn VariableLayoutReflection_getVariable(layout: VariableLayoutReflectionPtr) VariableReflectionPtr {
    return c.VariableLayoutReflection_getVariable(layout);
}
pub fn VariableLayoutReflection_getName(layout: VariableLayoutReflectionPtr) []const u8 {
    const name = c.VariableLayoutReflection_getName(layout);
    const span = std.mem.span(name);
    return span[0..span.len];
}
pub fn VariableLayoutReflection_findModifier(layout: c.VariableLayoutReflectionPtr, id: ModifierID) c.Modifier {
    return c.VariableLayoutReflection_findModifier(layout, @intFromEnum(id));
}
pub fn VariableLayoutReflection_getTypeLayout(layout: VariableLayoutReflectionPtr) TypeLayoutReflectionPtr {
    return c.VariableLayoutReflection_getTypeLayout(layout);
}
pub fn VariableLayoutReflection_getCategory(layout: VariableLayoutReflectionPtr) ParameterCategory {
    return @enumFromInt(c.VariableLayoutReflection_getCategory(layout));
}
pub fn VariableLayoutReflection_getCategoryCount(layout: VariableLayoutReflectionPtr) u32 {
    return @intCast(c.VariableLayoutReflection_getCategoryCount(layout));
}
pub fn VariableLayoutReflection_getCategoryByIndex(layout: c.VariableLayoutReflectionPtr, index: u32) ParameterCategory {
    return @enumFromInt(c.VariableLayoutReflection_getCategoryByIndex(layout, @intCast(index)));
}
pub fn VariableLayoutReflection_getOffset(layout: c.VariableLayoutReflectionPtr, category: ParameterCategory) usize {
    return c.VariableLayoutReflection_getOffset(layout, @intFromEnum(category));
}
pub fn VariableLayoutReflection_getType(layout: VariableLayoutReflectionPtr) TypeReflectionPtr {
    return c.VariableLayoutReflection_getType(layout);
}
pub fn VariableLayoutReflection_getBindingIndex(layout: VariableLayoutReflectionPtr) u32 {
    return @intCast(c.VariableLayoutReflection_getBindingIndex(layout));
}
pub fn VariableLayoutReflection_getBindingSpace(layout: VariableLayoutReflectionPtr) u32 {
    return @intCast(c.VariableLayoutReflection_getBindingSpace(layout));
}
pub fn VariableLayoutReflection_getBindingSpaceByCategory(layout: c.VariableLayoutReflectionPtr, category: c.ParameterCategory) u32 {
    return @intCast(c.VariableLayoutReflection_getBindingSpaceByCategory(layout, @intFromEnum(category)));
}
pub fn VariableLayoutReflection_getImageFormat(layout: VariableLayoutReflectionPtr) ImageFormat {
    return @enumFromInt(c.VariableLayoutReflection_getImageFormat(layout));
}
pub fn VariableLayoutReflection_getSemanticName(layout: VariableLayoutReflectionPtr) [*c]const u8 {
    return c.VariableLayoutReflection_getSemanticName(layout);
}
pub fn VariableLayoutReflection_getSemanticIndex(layout: VariableLayoutReflectionPtr) u32 {
    return @intCast(c.VariableLayoutReflection_getSemanticIndex(layout));
}
pub fn VariableLayoutReflection_getSlangStage(layout: VariableLayoutReflectionPtr) Stage {
    return @enumFromInt(c.VariableLayoutReflection_getSlangStage(layout));
}

pub fn TypeReflection_getKind(typeLayout: TypeReflectionPtr) TypeKind {
    return @enumFromInt(c.TypeReflection_getKind(typeLayout));
}

pub fn TypeReflection_getFieldCount(typeLayout: TypeReflectionPtr) u32 {
    return c.TypeReflection_getFieldCount(typeLayout);
}

pub fn TypeReflection_getFieldByIndex(typeLayout: c.TypeReflectionPtr, index: u32) VariableReflectionPtr {
    return c.TypeReflection_getFieldByIndex(typeLayout, @intCast(index));
}

pub fn TypeReflection_isArray(typeLayout: TypeReflectionPtr) bool {
    return c.TypeReflection_isArray(typeLayout);
}

pub fn TypeReflection_unwrapArray(typeLayout: TypeReflectionPtr) TypeReflectionPtr {
    return c.TypeReflection_unwrapArray(typeLayout);
}

pub fn TypeReflection_getElementCount(typeLayout: TypeReflectionPtr) usize {
    return c.TypeReflection_getElementCount(typeLayout);
}

pub fn TypeReflection_getTotalArrayElementCount(typeLayout: TypeReflectionPtr) u32 {
    return c.TypeReflection_getTotalArrayElementCount(typeLayout);
}

pub fn TypeReflection_getElementType(typeLayout: TypeReflectionPtr) TypeReflectionPtr {
    return c.TypeReflection_getElementType(typeLayout);
}

pub fn TypeReflection_getRowCount(typeLayout: TypeReflectionPtr) u32 {
    return c.TypeReflection_getRowCount(typeLayout);
}

pub fn TypeReflection_getColumnCount(typeLayout: TypeReflectionPtr) u32 {
    return c.TypeReflection_getColumnCount(typeLayout);
}

pub fn TypeReflection_getScalarType(typeLayout: TypeReflectionPtr) ScalarType {
    return @enumFromInt(c.TypeReflection_getScalarType(typeLayout));
}

pub fn TypeReflection_getResourceResultType(typeLayout: TypeReflectionPtr) TypeReflectionPtr {
    return c.TypeReflection_getResourceResultType(typeLayout);
}

pub fn TypeReflection_getResourceShape(typeLayout: TypeReflectionPtr) ResourceShape {
    return @enumFromInt(c.TypeReflection_getResourceShape(typeLayout));
}

pub fn TypeReflection_getResourceAccess(typeLayout: TypeReflectionPtr) ResourceAccess {
    return @enumFromInt(c.TypeReflection_getResourceAccess(typeLayout));
}

pub fn TypeReflection_getName(typeLayout: TypeReflectionPtr) []const u8 {
    const name = c.TypeReflection_getName(typeLayout);
    const z = std.mem.span(name);
    return z[0..z.len];
}

pub fn TypeReflection_getUserAttributeCount(typeLayout: TypeReflectionPtr) u32 {
    return c.TypeReflection_getUserAttributeCount(typeLayout);
}

pub fn TypeReflection_getUserAttributeByIndex(typeLayout: c.TypeReflectionPtr, index: u32) AttributeReflectionPtr {
    return c.TypeReflection_getUserAttributeByIndex(typeLayout, @intCast(index));
}

pub fn TypeReflection_findUserAttributeByName(typeLayout: c.TypeReflectionPtr, name: []const u8) AttributeReflectionPtr {
    return c.TypeReflection_findUserAttributeByName(typeLayout, @ptrCast(name.ptr));
}

pub fn TypeReflection_findAttributeByName(typeLayout: c.TypeReflectionPtr, name: []const u8) AttributeReflectionPtr {
    return c.TypeReflection_findAttributeByName(typeLayout, @ptrCast(name.ptr));
}

pub fn TypeReflection_getGenericCountainer(typeLayout: TypeReflectionPtr) GenericReflectionPtr {
    return c.TypeReflection_getGenericCountainer(typeLayout);
}

pub fn VariableReflection_getName(variable: VariableReflectionPtr) []const u8 {
    const name = c.VariableReflection_getName(variable);
    const z = std.mem.span(name);
    return z[0..z.len];
}

pub fn VariableReflection_getType(variable: VariableReflectionPtr) TypeReflectionPtr {
    return c.VariableReflection_getType(variable);
}

pub fn VariableReflection_findModifier(variable: c.VariableReflectionPtr, id: ModifierID) Modifier {
    return c.VariableReflection_findModifier(variable, @intFromEnum(id));
}

pub fn VariableReflection_getUserAttributeCount(variable: VariableReflectionPtr) u32 {
    return @intCast(c.VariableReflection_getUserAttributeCount(variable));
}

pub fn VariableReflection_getUserAttributeByIndex(variable: c.VariableReflectionPtr, index: u32) AttributeReflectionPtr {
    return c.VariableReflection_getUserAttributeByIndex(variable, @intCast(index));
}

pub fn VariableReflection_findAttributeByName(variable: VariableReflectionPtr, inSession: IGlobalSession, name: []const u8) AttributeReflectionPtr {
    return c.VariableReflection_findAttributeByName(variable, inSession, @ptrCast(name.ptr));
}

pub fn VariableReflection_findUserAttributeByName(variable: VariableReflectionPtr, inSession: IGlobalSession, name: []const u8) AttributeReflectionPtr {
    return c.VariableReflection_findUserAttributeByName(variable, inSession, @ptrCast(name.ptr));
}

pub fn VariableReflection_hasDefaultValue(variable: VariableReflectionPtr) bool {
    return c.VariableReflection_hasDefaultValue(variable);
}

pub fn VariableReflection_getDefaultValue(variable: VariableReflectionPtr, value: *i64) SlangResult {
    return @enumFromInt(c.VariableReflection_getDefaultValue(variable, value));
}

pub fn VariableReflection_getGenericContainer(variable: VariableReflectionPtr) GenericReflectionPtr {
    return c.VariableReflection_getGenericContainer(variable);
}

pub fn VariableReflection_applySpecializations(variable: VariableReflectionPtr, inGeneric: GenericReflectionPtr) VariableReflectionPtr {
    return c.VariableReflection_applySpecializations(variable, inGeneric);
}

pub fn TypeLayoutReflection_getType(layout: TypeLayoutReflectionPtr) TypeReflectionPtr {
    return c.TypeLayoutReflection_getType(layout);
}

pub fn TypeLayoutReflection_getKind(layout: TypeLayoutReflectionPtr) TypeKind {
    return @enumFromInt(c.TypeLayoutReflection_getKind(layout));
}

pub fn TypeLayoutReflection_getSize(layout: TypeLayoutReflectionPtr, category: ParameterCategory) usize {
    return c.TypeLayoutReflection_getSize(layout, @intFromEnum(category));
}

pub fn TypeLayoutReflection_getStride(layout: TypeLayoutReflectionPtr, category: ParameterCategory) usize {
    return c.TypeLayoutReflection_getStride(layout, @intFromEnum(category));
}

pub fn TypeLayoutReflection_getAlignment(layout: TypeLayoutReflectionPtr, category: ParameterCategory) i32 {
    return c.TypeLayoutReflection_getAlignment(layout, @intFromEnum(category));
}

pub fn TypeLayoutReflection_getFieldCount(layout: TypeLayoutReflectionPtr) u32 {
    return c.TypeLayoutReflection_getFieldCount(layout);
}

pub fn TypeLayoutReflection_getFieldByIndex(layout: TypeLayoutReflectionPtr, index: u32) VariableLayoutReflectionPtr {
    return c.TypeLayoutReflection_getFieldByIndex(layout, index);
}

pub fn TypeLayoutReflection_getExplicitCounter(layout: TypeLayoutReflectionPtr) VariableLayoutReflectionPtr {
    return c.TypeLayoutReflection_getExplicitCounter(layout);
}

pub fn TypeLayoutReflection_isArray(layout: TypeLayoutReflectionPtr) bool {
    return c.TypeLayoutReflection_isArray(layout);
}

pub fn TypeLayoutReflection_unwrapArray(layout: TypeLayoutReflectionPtr) TypeLayoutReflectionPtr {
    return c.TypeLayoutReflection_unwrapArray(layout);
}

pub fn TypeLayoutReflection_getElementCount(layout: TypeLayoutReflectionPtr, reflection: ShaderReflectionPtr) u32 {
    return c.TypeLayoutReflection_getElementCount(layout, reflection);
}

pub fn TypeLayoutReflection_getTotalElementCount(layout: TypeLayoutReflectionPtr) usize {
    return c.TypeLayoutReflection_getTotalElementCount(layout);
}

pub fn TypeLayoutReflection_getElementStride(layout: TypeLayoutReflectionPtr, category: ParameterCategory) usize {
    return c.TypeLayoutReflection_getElementStride(layout, @intFromEnum(category));
}

pub fn TypeLayoutReflection_getElementTypeLayout(layout: TypeLayoutReflectionPtr) TypeLayoutReflectionPtr {
    return c.TypeLayoutReflection_getElementTypeLayout(layout);
}

pub fn TypeLayoutReflection_getElementVarLayout(layout: TypeLayoutReflectionPtr) VariableLayoutReflectionPtr {
    return c.TypeLayoutReflection_getElementVarLayout(layout);
}

pub fn TypeLayoutReflection_getContainerVarLayout(layout: TypeLayoutReflectionPtr) VariableLayoutReflectionPtr {
    return c.TypeLayoutReflection_getContainerVarLayout(layout);
}

pub fn TypeLayoutReflection_getParameterCategory(layout: TypeLayoutReflectionPtr) ParameterCategory {
    return @enumFromInt(c.TypeLayoutReflection_getParameterCategory(layout));
}

pub fn TypeLayoutReflection_getCategoryCount(layout: TypeLayoutReflectionPtr) u32 {
    return c.TypeLayoutReflection_getCategoryCount(layout);
}

pub fn TypeLayoutReflection_getCategoryByIndex(layout: TypeLayoutReflectionPtr, index: u32) ParameterCategory {
    return @enumFromInt(c.TypeLayoutReflection_getCategoryByIndex(layout, index));
}

pub fn TypeLayoutReflection_getRowCount(layout: TypeLayoutReflectionPtr) u32 {
    return c.TypeLayoutReflection_getRowCount(layout);
}

pub fn TypeLayoutReflection_getColumnCount(layout: TypeLayoutReflectionPtr) u32 {
    return c.TypeLayoutReflection_getColumnCount(layout);
}

pub fn TypeLayoutReflection_getScalarType(layout: TypeLayoutReflectionPtr) ScalarType {
    return @enumFromInt(c.TypeLayoutReflection_getScalarType(layout));
}

pub fn TypeLayoutReflection_getResourceResultType(layout: TypeLayoutReflectionPtr) TypeReflectionPtr {
    return c.TypeLayoutReflection_getResourceResultType(layout);
}

pub fn TypeLayoutReflection_getResourceShape(layout: TypeLayoutReflectionPtr) ResourceShape {
    return @enumFromInt(c.TypeLayoutReflection_getResourceShape(layout));
}

pub fn TypeLayoutReflection_getResourceAccess(layout: TypeLayoutReflectionPtr) ResourceAccess {
    return @enumFromInt(c.TypeLayoutReflection_getResourceAccess(layout));
}

pub fn TypeLayoutReflection_getName(layout: TypeLayoutReflectionPtr) []const u8 {
    const name = c.TypeLayoutReflection_getName(layout);
    const z = std.mem.span(name);
    return z[0..z.len];
}

pub fn TypeLayoutReflection_getMatrixLayoutMode(layout: TypeLayoutReflectionPtr) MatrixLayoutMode {
    return @enumFromInt(c.TypeLayoutReflection_getMatrixLayoutMode(layout));
}

pub fn TypeLayoutReflection_getGenericParamIndex(layout: TypeLayoutReflectionPtr) i32 {
    return c.TypeLayoutReflection_getGenericParamIndex(layout);
}

pub fn TypeLayoutReflection_getBindingRangeCount(layout: TypeLayoutReflectionPtr) c.SlangInt {
    return c.TypeLayoutReflection_getBindingRangeCount(layout);
}

pub fn TypeLayoutReflection_getBindingRangeType(layout: TypeLayoutReflectionPtr, index: c.SlangInt) BindingType {
    return @enumFromInt(c.TypeLayoutReflection_getBindingRangeType(layout, index));
}

pub fn TypeLayoutReflection_isBindingRangeSpecializable(layout: TypeLayoutReflectionPtr, index: c.SlangInt) bool {
    return c.TypeLayoutReflection_isBindingRangeSpecializable(layout, index);
}

pub fn TypeLayoutReflection_getBindingRangeBindingCount(layout: TypeLayoutReflectionPtr, index: c.SlangInt) c.SlangInt {
    return c.TypeLayoutReflection_getBindingRangeBindingCount(layout, index);
}

pub fn TypeLayoutReflection_getFieldBindingRangeOffset(layout: TypeLayoutReflectionPtr, index: c.SlangInt) c.SlangInt {
    return c.TypeLayoutReflection_getFieldBindingRangeOffset(layout, index);
}

pub fn TypeLayoutReflection_getExplicitCounterBindingRangeOffset(layout: TypeLayoutReflectionPtr) c.SlangInt {
    return c.TypeLayoutReflection_getExplicitCounterBindingRangeOffset(layout);
}

pub fn TypeLayoutReflection_getBindingRangeLeafTypeLayout(layout: TypeLayoutReflectionPtr, index: c.SlangInt) TypeLayoutReflectionPtr {
    return c.TypeLayoutReflection_getBindingRangeLeafTypeLayout(layout, index);
}

pub fn TypeLayoutReflection_getBindingRangeImageFormat(layout: TypeLayoutReflectionPtr, index: c.SlangInt) ImageFormat {
    return @enumFromInt(c.TypeLayoutReflection_getBindingRangeImageFormat(layout, index));
}

pub fn TypeLayoutReflection_getBindingRangeDescriptorSetIndex(layout: TypeLayoutReflectionPtr, index: c.SlangInt) c.SlangInt {
    return c.TypeLayoutReflection_getBindingRangeDescriptorSetIndex(layout, index);
}

pub fn TypeLayoutReflection_getBindingRangeFirstDescriptorRangeIndex(layout: TypeLayoutReflectionPtr, index: c.SlangInt) c.SlangInt {
    return c.TypeLayoutReflection_getBindingRangeFirstDescriptorRangeIndex(layout, index);
}

pub fn TypeLayoutReflection_getBindingRangeDescriptorRangeCount(layout: TypeLayoutReflectionPtr, index: c.SlangInt) c.SlangInt {
    return c.TypeLayoutReflection_getBindingRangeDescriptorRangeCount(layout, index);
}

pub fn TypeLayoutReflection_getDescriptorSetCount(layout: TypeLayoutReflectionPtr) c.SlangInt {
    return c.TypeLayoutReflection_getDescriptorSetCount(layout);
}

pub fn TypeLayoutReflection_getDescriptorSetSpaceOffset(layout: TypeLayoutReflectionPtr, setIndex: c.SlangInt) c.SlangInt {
    return c.TypeLayoutReflection_getDescriptorSetSpaceOffset(layout, setIndex);
}

pub fn TypeLayoutReflection_getDescriptorSetDescriptorRangeCount(layout: TypeLayoutReflectionPtr, setIndex: c.SlangInt) c.SlangInt {
    return c.TypeLayoutReflection_getDescriptorSetDescriptorRangeCount(layout, setIndex);
}

pub fn TypeLayoutReflection_getDescriptorSetDescriptorRangeIndexOffset(layout: TypeLayoutReflectionPtr, setIndex: c.SlangInt, rangeIndex: c.SlangInt) c.SlangInt {
    return c.TypeLayoutReflection_getDescriptorSetDescriptorRangeIndexOffset(layout, setIndex, rangeIndex);
}

pub fn TypeLayoutReflection_getDescriptorSetDescriptorRangeDescriptorCount(layout: TypeLayoutReflectionPtr, setIndex: c.SlangInt, rangeIndex: c.SlangInt) c.SlangInt {
    return c.TypeLayoutReflection_getDescriptorSetDescriptorRangeDescriptorCount(layout, setIndex, rangeIndex);
}

pub fn TypeLayoutReflection_getDescriptorSetDescriptorRangeType(layout: TypeLayoutReflectionPtr, setIndex: c.SlangInt, rangeIndex: c.SlangInt) BindingType {
    return @enumFromInt(c.TypeLayoutReflection_getDescriptorSetDescriptorRangeType(layout, setIndex, rangeIndex));
}

pub fn TypeLayoutReflection_getDescriptorSetDescriptorRangeCategory(layout: TypeLayoutReflectionPtr, setIndex: c.SlangInt, rangeIndex: c.SlangInt) ParameterCategory {
    return c.TypeLayoutReflection_getDescriptorSetDescriptorRangeCategory(layout, setIndex, rangeIndex);
}

pub fn TypeLayoutReflection_getSubObjectRangeCount(layout: TypeLayoutReflectionPtr) c.SlangInt {
    return c.TypeLayoutReflection_getSubObjectRangeCount(layout);
}

pub fn TypeLayoutReflection_getSubObjectRangeBindingRangeIndex(layout: TypeLayoutReflectionPtr, subObjectRangeIndex: c.SlangInt) c.SlangInt {
    return c.TypeLayoutReflection_getSubObjectRangeBindingRangeIndex(layout, subObjectRangeIndex);
}

pub fn TypeLayoutReflection_getSubObjectRangeSpaceOffset(layout: TypeLayoutReflectionPtr, subObjectRangeIndex: c.SlangInt) c.SlangInt {
    return c.TypeLayoutReflection_getSubObjectRangeSpaceOffset(layout, subObjectRangeIndex);
}

pub fn TypeLayoutReflection_getSubObjectRangeOffset(layout: TypeLayoutReflectionPtr, subObjectRangeIndex: c.SlangInt) VariableLayoutReflectionPtr {
    return c.TypeLayoutReflection_getSubObjectRangeOffset(layout, subObjectRangeIndex);
}

pub fn EntryPointReflection_getName(entryPoint: EntryPointReflectionPtr) []const u8 {
    return std.mem.sliceTo(c.EntryPointReflection_getName(entryPoint), 0);
}

pub fn EntryPointReflection_getNameOverride(entryPoint: EntryPointReflectionPtr) []const u8 {
    const name = c.EntryPointReflection_getNameOverride(entryPoint);
    const span = std.mem.span(name);
    return span[0..span.len];
}

pub fn EntryPointReflection_getParameterCount(entryPoint: EntryPointReflectionPtr) u32 {
    return c.EntryPointReflection_getParameterCount(entryPoint);
}

pub fn EntryPointReflection_getFunction(entryPoint: EntryPointReflectionPtr) FunctionReflectionPtr {
    return c.EntryPointReflection_getFunction(entryPoint);
}

pub fn EntryPointReflection_getParameterByIndex(entryPoint: EntryPointReflectionPtr, index: u32) VariableLayoutReflectionPtr {
    return c.EntryPointReflection_getParameterByIndex(entryPoint, index);
}

pub fn EntryPointReflection_getStage(entryPoint: EntryPointReflectionPtr) Stage {
    return @enumFromInt(c.EntryPointReflection_getStage(entryPoint));
}

pub fn EntryPointReflection_getComputeThreadGroupSize(entryPoint: EntryPointReflectionPtr, axisCount: u32, outSizeAlongAxis: *u64) void {
    return c.EntryPointReflection_getComputeThreadGroupSize(entryPoint, axisCount, outSizeAlongAxis);
}

pub fn EntryPointReflection_getComputeWaveSize(entryPoint: EntryPointReflectionPtr, outWaveSize: *u32) void {
    return c.EntryPointReflection_getComputeWaveSize(entryPoint, outWaveSize);
}

pub fn EntryPointReflection_usesAnySampleRateInput(entryPoint: EntryPointReflectionPtr) bool {
    return c.EntryPointReflection_usesAnySampleRateInput(entryPoint);
}

pub fn EntryPointReflection_getVarLayout(entryPoint: EntryPointReflectionPtr) VariableLayoutReflectionPtr {
    return c.EntryPointReflection_getVarLayout(entryPoint);
}

pub fn EntryPointReflection_getTypeLayout(entryPoint: EntryPointReflectionPtr) TypeLayoutReflectionPtr {
    return c.EntryPointReflection_getTypeLayout(entryPoint);
}

pub fn EntryPointReflection_getResultVarLayout(entryPoint: EntryPointReflectionPtr) VariableLayoutReflectionPtr {
    return c.EntryPointReflection_getResultVarLayout(entryPoint);
}

pub fn EntryPointReflection_hasDefaultConstantBuffer(entryPoint: EntryPointReflectionPtr) bool {
    return c.EntryPointReflection_hasDefaultConstantBuffer(entryPoint);
}

pub fn TypeParameterReflection_getName(typeParameter: TypeParameterReflectionPtr) []const u8 {
    return std.mem.sliceTo(c.TypeParameterReflection_getName(typeParameter), 0);
}

pub fn TypeParameterReflection_getIndex(typeParameter: TypeParameterReflectionPtr) u32 {
    return c.TypeParameterReflection_getIndex(typeParameter);
}

pub fn TypeParameterReflection_getConstraintCount(typeParameter: TypeParameterReflectionPtr) u32 {
    return c.TypeParameterReflection_getConstraintCount(typeParameter);
}

pub fn TypeParameterReflection_getConstraintByIndex(typeParameter: TypeParameterReflectionPtr, index: u32) TypeReflectionPtr {
    return c.TypeParameterReflection_getConstraintByIndex(typeParameter, index);
}

pub fn IComponentType_getEntryPointMetadata(componentType: IComponentType, entryPointIndex: usize, targetIndex: usize, outMetadata: *IMetadata, outDiagnostics: *IBlob) SlangResult {
    return @enumFromInt(c.IComponentType_getEntryPointMetadata(componentType, entryPointIndex, targetIndex, outMetadata, outDiagnostics));
}

pub fn IMetadata_isParameterLocationUsed(inMetadata: IMetadata, category: ParameterCategory, spaceInt: u64, registerInt: u64, outUsed: *bool) SlangResult {
    return @enumFromInt(c.IMetadata_isParameterLocationUsed(inMetadata, @intFromEnum(category), spaceInt, registerInt, outUsed));
}

pub fn AttributeReflection_getName(self: AttributeReflectionPtr) []const u8 {
    return std.mem.sliceTo(c.AttributeReflection_getName(self), 0);
}

pub fn AttributeReflection_getArgumentCount(self: AttributeReflectionPtr) u32 {
    return c.AttributeReflection_getArgumentCount(self);
}

pub fn AttributeReflection_getArgumentType(self: AttributeReflectionPtr, index: u32) TypeReflectionPtr {
    return c.AttributeReflection_getArgumentType(self, index);
}

pub fn AttributeReflection_getArgumentValueInt(self: AttributeReflectionPtr, index: u32, value: *i32) SlangResult {
    return @enumFromInt(c.AttributeReflection_getArgumentValueInt(self, index, value));
}

pub fn AttributeReflection_getArgumentValueFloat(self: AttributeReflectionPtr, index: u32, value: *f32) SlangResult {
    return @enumFromInt(c.AttributeReflection_getArgumentValueFloat(self, index, value));
}

pub fn AttributeReflection_getArgumentValueString(self: AttributeReflectionPtr, index: u32) []const u8 {
    var outSize: usize = undefined;
    return std.mem.sliceTo(c.AttributeReflection_getArgumentValueString(self, index, &outSize), 0);
}

pub fn FunctionReflection_getName(self: FunctionReflectionPtr) []const u8 {
    const name = c.FunctionReflection_getName(self);
    const span = std.mem.span(name);
    return span[0..span.len];
}

pub fn FunctionReflection_getReturnType(self: FunctionReflectionPtr) TypeReflectionPtr {
    return c.FunctionReflection_getReturnType(self);
}

pub fn FunctionReflection_getParameterCount(self: FunctionReflectionPtr) u32 {
    return c.FunctionReflection_getParameterCount(self);
}

pub fn FunctionReflection_getParameterByIndex(self: FunctionReflectionPtr, index: u32) VariableReflectionPtr {
    return c.FunctionReflection_getParameterByIndex(self, index);
}

pub fn FunctionReflection_getUserAttributeCount(self: FunctionReflectionPtr) u32 {
    return c.FunctionReflection_getUserAttributeCount(self);
}

pub fn FunctionReflection_getUserAttributeByIndex(self: FunctionReflectionPtr, index: u32) AttributeReflectionPtr {
    return c.FunctionReflection_getUserAttributeByIndex(self, index);
}

pub fn FunctionReflection_findAttributeByName(self: FunctionReflectionPtr, name: []const u8) AttributeReflectionPtr {
    return c.FunctionReflection_findAttributeByName(self, name.ptr);
}

pub fn FunctionReflection_findModifier(self: FunctionReflectionPtr, id: ModifierID) Modifier {
    return c.FunctionReflection_findModifier(self, @enumFromInt(id));
}

pub fn FunctionReflection_getGenericContainer(self: FunctionReflectionPtr) GenericReflectionPtr {
    return c.FunctionReflection_getGenericContainer(self);
}

pub fn FunctionReflection_applySpecializations(self: FunctionReflectionPtr, inGeneric: GenericReflectionPtr) FunctionReflectionPtr {
    return c.FunctionReflection_applySpecializations(self, inGeneric);
}

pub fn FunctionReflection_specializeWithArgTypes(self: FunctionReflectionPtr, argCount: u32, types: []const TypeReflectionPtr) FunctionReflectionPtr {
    return c.FunctionReflection_specializeWithArgTypes(self, argCount, types.ptr);
}

pub fn FunctionReflection_isOverloaded(self: FunctionReflectionPtr) bool {
    return c.FunctionReflection_isOverloaded(self);
}

pub fn FunctionReflection_getOverloadCount(self: FunctionReflectionPtr) u32 {
    return c.FunctionReflection_getOverloadCount(self);
}

pub fn FunctionReflection_getOverload(self: FunctionReflectionPtr, index: u32) FunctionReflectionPtr {
    return c.FunctionReflection_getOverload(self, index);
}

pub fn release(unknown: Unknown) SlangResult {
    if (unknown == null) return SlangResult.SUCCESS;
    return @enumFromInt(c.release(unknown));
}

pub fn init() void {
    gs = std.mem.zeroes(c.IGlobalSession);
    assert(createGlobalSession(&gs).isSuccess());
}

pub fn deinit() void {
    _ = c.release(gs);
}

pub fn IModule_findEntryPointByName(inModule: IModule, name: []const u8, entryPoint: *IEntryPoint) SlangResult {
    return @enumFromInt(c.IModule_findEntryPointByName(inModule, name.ptr, entryPoint));
}

pub fn IModule_getDefinedEntryPointCount(inModule: IModule) i32 {
    return @intCast(c.IModule_getDefinedEntryPointCount(inModule));
}

pub fn IModule_getDefinedEntryPoint(inModule: IModule, index: i32, outEntryPoint: *IEntryPoint) SlangResult {
    return @enumFromInt(c.IModule_getDefinedEntryPoint(inModule, index, outEntryPoint));
}

pub fn IModule_serialize(inModule: IModule, outBlob: *IBlob) SlangResult {
    return @enumFromInt(c.IModule_serialize(inModule, outBlob));
}

pub fn IModule_writeToFile(inModule: IModule, file_name: []const u8) SlangResult {
    return @enumFromInt(c.IModule_writeToFile(inModule, file_name.ptr));
}

pub fn IModule_getName(inModule: IModule) []const u8 {
    return std.mem.sliceTo(c.IModule_getName(inModule), 0);
}

pub fn IModule_getFilePath(inModule: IModule) []const u8 {
    return std.mem.sliceTo(c.IModule_getFilePath(inModule), 0);
}

pub fn IModule_getUniqueIdentity(inModule: IModule) []const u8 {
    return std.mem.sliceTo(c.IModule_getUniqueIdentity(inModule), 0);
}

pub fn IModule_findAndCheckEntryPoint(inModule: IModule, name: []const u8, stage: Stage, outEntryPoint: *IEntryPoint, outDiagnostics: *IBlob) SlangResult {
    return @intFromEnum(c.IModule_findAndCheckEntryPoint(inModule, name, @intFromEnum(stage), outEntryPoint, outDiagnostics));
}

pub fn IModule_getDependencyFileCount(inModule: IModule) i32 {
    return @intCast(c.IModule_getDependencyFileCount(inModule));
}

pub fn IModule_getDependencyFilePath(inModule: IModule, index: i32) []const u8 {
    return std.mem.sliceTo(c.IModule_getDependencyFilePath(inModule, index), 0);
}

pub fn IModule_getModuleReflection(inModule: IModule) DeclReflectionPtr {
    return c.IModule_getModuleReflection(inModule);
}

pub fn IModule_disassemble(inModule: IModule, outDisassembledBlob: *IBlob) SlangResult {
    return @enumFromInt(c.IModule_disassemble(inModule, outDisassembledBlob));
}

pub fn IEntryPoint_getFunctionReflection(inEntryPoint: IEntryPoint) FunctionReflectionPtr {
    return c.IEntryPoint_getFunctionReflection(inEntryPoint);
}
