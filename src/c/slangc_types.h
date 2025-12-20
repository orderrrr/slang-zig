#pragma once
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef int64_t SlangInt;
typedef uint64_t SlangUInt;
typedef int32_t SlangUInt32;

typedef void *IGlobalSession;
typedef void *ISession;
typedef void *IModule;
typedef void *IBlob;
typedef void *IEntryPoint;
typedef void *IComponentType;
typedef void *ProgramLayout;
typedef void *Modifier;
typedef void *Attribute;
typedef void *IMetadata;
typedef void *Unknown;

typedef void *ShaderReflectionPtr;
typedef void *TypeParameterReflectionPtr;
typedef void *VariableLayoutReflectionPtr;
typedef void *EntryPointReflectionPtr;
typedef void *TypeReflectionPtr;
typedef void *FunctionReflectionPtr;
typedef void *VariableReflectionPtr;
typedef void *TypeLayoutReflectionPtr;
typedef void *GenericReflectionPtr;

#ifndef SLANG_MAKE_ERROR
#define SLANG_MAKE_ERROR(fac, code)                                            \
  ((((int32_t)(fac)) << 16) | ((int32_t)(code)) | ((int32_t)0x80000000))

#define SLANG_FACILITY_WIN_GENERAL 0
#define SLANG_FACILITY_WIN_INTERFACE 4
#define SLANG_FACILITY_WIN_API 7

#define SLANG_MAKE_WIN_GENERAL_ERROR(code)                                     \
  SLANG_MAKE_ERROR(SLANG_FACILITY_WIN_GENERAL, code)

#define SLANG_FACILITY_BASE 0x200
#define SLANG_FACILITY_CORE SLANG_FACILITY_BASE

#define SLANG_MAKE_CORE_ERROR(code) SLANG_MAKE_ERROR(SLANG_FACILITY_CORE, code)

/* Constant Definitions */
#define SLANG_E_NOT_IMPLEMENTED SLANG_MAKE_WIN_GENERAL_ERROR(0x4001)
#define SLANG_E_NO_INTERFACE SLANG_MAKE_WIN_GENERAL_ERROR(0x4002)
#define SLANG_E_ABORT SLANG_MAKE_WIN_GENERAL_ERROR(0x4004)
#define SLANG_E_INVALID_HANDLE SLANG_MAKE_ERROR(SLANG_FACILITY_WIN_API, 6)
#define SLANG_E_INVALID_ARG SLANG_MAKE_ERROR(SLANG_FACILITY_WIN_API, 0x57)
#define SLANG_E_OUT_OF_MEMORY SLANG_MAKE_ERROR(SLANG_FACILITY_WIN_API, 0xe)
#define SLANG_E_BUFFER_TOO_SMALL SLANG_MAKE_CORE_ERROR(1)
#define SLANG_E_UNINITIALIZED SLANG_MAKE_CORE_ERROR(2)
#define SLANG_E_PENDING SLANG_MAKE_CORE_ERROR(3)
#define SLANG_E_CANNOT_OPEN SLANG_MAKE_CORE_ERROR(4)
#define SLANG_E_NOT_FOUND SLANG_MAKE_CORE_ERROR(5)
#define SLANG_E_INTERNAL_FAIL SLANG_MAKE_CORE_ERROR(6)
#define SLANG_E_NOT_AVAILABLE SLANG_MAKE_CORE_ERROR(7)
#define SLANG_E_TIME_OUT SLANG_MAKE_CORE_ERROR(8)

/* Aliases */
#define SLANG_ERROR_INSUFFICIENT_BUFFER SLANG_E_BUFFER_TOO_SMALL
#define SLANG_ERROR_INVALID_PARAMETER SLANG_E_INVALID_ARG
#endif

struct PreprocessorMacroDesc {
  const char *name;
  const char *value;
};

typedef int SlangCompileTargetIntegral;
enum SlangCompileTarget : SlangCompileTargetIntegral {
  SLANG_TARGET_UNKNOWN,
  SLANG_TARGET_NONE,
  SLANG_GLSL,
  SLANG_GLSL_VULKAN_DEPRECATED,          //< deprecated and removed: just use
                                         //`SLANG_GLSL`.
  SLANG_GLSL_VULKAN_ONE_DESC_DEPRECATED, //< deprecated and removed.
  SLANG_HLSL,
  SLANG_SPIRV,
  SLANG_SPIRV_ASM,
  SLANG_DXBC,
  SLANG_DXBC_ASM,
  SLANG_DXIL,
  SLANG_DXIL_ASM,
  SLANG_C_SOURCE,        ///< The C language
  SLANG_CPP_SOURCE,      ///< C++ code for shader kernels.
  SLANG_HOST_EXECUTABLE, ///< Standalone binary executable (for hosting CPU/OS)
  SLANG_SHADER_SHARED_LIBRARY, ///< A shared library/Dll for shader kernels (for
                               ///< hosting CPU/OS)
  SLANG_SHADER_HOST_CALLABLE,  ///< A CPU target that makes the compiled shader
                               ///< code available to be run immediately
  SLANG_CUDA_SOURCE,           ///< Cuda source
  SLANG_PTX,                   ///< PTX
  SLANG_CUDA_OBJECT_CODE,      ///< Object code that contains CUDA functions.
  SLANG_OBJECT_CODE,         ///< Object code that can be used for later linking
  SLANG_HOST_CPP_SOURCE,     ///< C++ code for host library or executable.
  SLANG_HOST_HOST_CALLABLE,  ///< Host callable host code (ie non kernel/shader)
  SLANG_CPP_PYTORCH_BINDING, ///< C++ PyTorch binding code.
  SLANG_METAL,               ///< Metal shading language
  SLANG_METAL_LIB,           ///< Metal library
  SLANG_METAL_LIB_ASM,       ///< Metal library assembly
  SLANG_HOST_SHARED_LIBRARY, ///< A shared library/Dll for host code (for
                             ///< hosting CPU/OS)
  SLANG_WGSL,                ///< WebGPU shading language
  SLANG_WGSL_SPIRV_ASM,      ///< SPIR-V assembly via WebGPU shading language
  SLANG_WGSL_SPIRV,          ///< SPIR-V via WebGPU shading language

  SLANG_HOST_VM,     ///< Bytecode that can be interpreted by the Slang VM
  SLANG_CPP_HEADER,  ///< C++ header for shader kernels.
  SLANG_CUDA_HEADER, ///< Cuda header
  SLANG_TARGET_COUNT_OF,
};

typedef unsigned int SlangProfileIDIntegral;
enum SlangProfileID : SlangProfileIDIntegral {
  SLANG_PROFILE_UNKNOWN,
};

typedef unsigned int SlangTargetFlags;
enum {
  /* When compiling for a D3D Shader Model 5.1 or higher target, allocate
     distinct register spaces for parameter blocks.

     @deprecated This behavior is now enabled unconditionally.
  */
  SLANG_TARGET_FLAG_PARAMETER_BLOCKS_USE_REGISTER_SPACES = 1 << 4,

  /* When set, will generate target code that contains all entrypoints defined
     in the input source or specified via the `spAddEntryPoint` function in a
     single output module (library/source file).
  */
  SLANG_TARGET_FLAG_GENERATE_WHOLE_PROGRAM = 1 << 8,

  /* When set, will dump out the IR between intermediate compilation steps.*/
  SLANG_TARGET_FLAG_DUMP_IR = 1 << 9,

  /* When set, will generate SPIRV directly rather than via glslang. */
  // This flag will be deprecated, use CompilerOption instead.
  SLANG_TARGET_FLAG_GENERATE_SPIRV_DIRECTLY = 1 << 10,
};
#define kDefaultTargetFlags SLANG_TARGET_FLAG_GENERATE_SPIRV_DIRECTLY

typedef unsigned int SlangFloatingPointModeIntegral;
enum SlangFloatingPointMode : SlangFloatingPointModeIntegral {
  SLANG_FLOATING_POINT_MODE_DEFAULT = 0,
  SLANG_FLOATING_POINT_MODE_FAST,
  SLANG_FLOATING_POINT_MODE_PRECISE,
};

typedef unsigned int SlangLineDirectiveModeIntegral;
enum SlangLineDirectiveMode : SlangLineDirectiveModeIntegral {
  SLANG_LINE_DIRECTIVE_MODE_DEFAULT =
      0, /**< Default behavior: pick behavior base on target. */
  SLANG_LINE_DIRECTIVE_MODE_NONE,     /**< Don't emit line directives at all. */
  SLANG_LINE_DIRECTIVE_MODE_STANDARD, /**< Emit standard C-style `#line`
                                         directives. */
  SLANG_LINE_DIRECTIVE_MODE_GLSL,     /**< Emit GLSL-style directives with file
                                       *number* instead     of name */
  SLANG_LINE_DIRECTIVE_MODE_SOURCE_MAP, /**< Use a source map to track line
                                           mappings (ie no #line will appear in
                                           emitting source) */
};

enum CompilerOptionName {
  MacroDefine, // stringValue0: macro name;  stringValue1: macro value
  DepFile,
  EntryPointName,
  Specialize,
  Help,
  HelpStyle,
  Include, // stringValue: additional include path.
  Language,
  MatrixLayoutColumn,         // bool
  MatrixLayoutRow,            // bool
  ZeroInitialize,             // bool
  IgnoreCapabilities,         // bool
  RestrictiveCapabilityCheck, // bool
  ModuleName,                 // stringValue0: module name.
  Output,
  Profile, // intValue0: profile
  Stage,   // intValue0: stage
  Target,  // intValue0: CodeGenTarget
  Version,
  WarningsAsErrors, // stringValue0: "all" or comma separated list of warning
                    // codes or names.
  DisableWarnings,  // stringValue0: comma separated list of warning codes or
                    // names.
  EnableWarning,    // stringValue0: warning code or name.
  DisableWarning,   // stringValue0: warning code or name.
  DumpWarningDiagnostics,
  InputFilesRemain,
  EmitIr,                        // bool
  ReportDownstreamTime,          // bool
  ReportPerfBenchmark,           // bool
  ReportCheckpointIntermediates, // bool
  SkipSPIRVValidation,           // bool
  SourceEmbedStyle,
  SourceEmbedName,
  SourceEmbedLanguage,
  DisableShortCircuit,            // bool
  MinimumSlangOptimization,       // bool
  DisableNonEssentialValidations, // bool
  DisableSourceMap,               // bool
  UnscopedEnum,                   // bool
  PreserveParameters, // bool: preserve all resource parameters in the output
                      // code.
  // Target

  Capability,                // intValue0: CapabilityName
  DefaultImageFormatUnknown, // bool
  DisableDynamicDispatch,    // bool
  DisableSpecialization,     // bool
  FloatingPointMode,         // intValue0: FloatingPointMode
  DebugInformation,          // intValue0: DebugInfoLevel
  LineDirectiveMode,
  Optimization, // intValue0: OptimizationLevel
  Obfuscate,    // bool

  VulkanBindShift,   // intValue0 (higher 8 bits): kind; intValue0(lower bits):
                     // set; intValue1: shift
  VulkanBindGlobals, // intValue0: index; intValue1: set
  VulkanInvertY,     // bool
  VulkanUseDxPositionW,    // bool
  VulkanUseEntryPointName, // bool
  VulkanUseGLLayout,       // bool
  VulkanEmitReflection,    // bool

  GLSLForceScalarLayout,   // bool
  EnableEffectAnnotations, // bool

  EmitSpirvViaGLSL,     // bool (will be deprecated)
  EmitSpirvDirectly,    // bool (will be deprecated)
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
  DumpIr,            // bool
  DumpIrIds,
  PreprocessorOutput,
  OutputIncludes,
  ReproFileSystem,
  REMOVED_SerialIR, // deprecated and removed
  SkipCodeGen,      // bool
  ValidateIr,       // bool
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
  LanguageVersion,                  // intValue0: SlangLanguageVersion
  TypeConformance, // stringValue0: additional type conformance to link, in the
                   // format of
                   // "<TypeName>:<IInterfaceName>[=<sequentialId>]", for
                   // example "Impl:IFoo=3" or "Impl:IFoo".
  EnableExperimentalDynamicDispatch, // bool, experimental
  EmitReflectionJSON,                // bool

  CountOfParsableOptions,

  // Used in parsed options only.
  DebugInformationFormat,  // intValue0: DebugInfoFormat
  VulkanBindShiftAll,      // intValue0: kind; intValue1: shift
  GenerateWholeProgram,    // bool
  UseUpToDateBinaryModule, // bool, when set, will only load
                           // precompiled modules if it is up-to-date with its
                           // source.
  EmbedDownstreamIR,       // bool
  ForceDXLayout,           // bool

  // Add this new option to the end of the list to avoid breaking ABI as much as
  // possible. Setting of EmitSpirvDirectly or EmitSpirvViaGLSL will turn into
  // this option internally.
  EmitSpirvMethod, // enum SlangEmitSpirvMethod

  SaveGLSLModuleBinSource,

  SkipDownstreamLinking, // bool, experimental
  DumpModule,

  GetModuleInfo,              // Print serialized module version and name
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
  ValidateIRDetailed,          // bool, enable detailed IR validation
  DumpIRBefore,                // string, pass name to dump IR before
  DumpIRAfter,                 // string, pass name to dump IR after

  CountOf,
};

enum CompilerOptionValueKind { Int, String };

struct CompilerOptionValue {
  enum CompilerOptionValueKind kind;
  int32_t intValue0;
  int32_t intValue1;
  const char *stringValue0;
  const char *stringValue1;
};

struct CompilerOptionEntry {
  enum CompilerOptionName name;
  struct CompilerOptionValue value;
};

struct TargetDesc {
  /** The size of this structure, in bytes.
   */
  size_t structureSize;

  /** The target format to generate code for (e.g., SPIR-V, DXIL, etc.)
   */
  enum SlangCompileTarget format;

  /** The compilation profile supported by the target (e.g., "Shader Model 5.1")
   */
  enum SlangProfileID profile;

  /** Flags for the code generation target. Currently unused. */
  SlangTargetFlags flags;

  /** Default mode to use for floating-point operations on the target.
   */
  enum SlangFloatingPointMode floatingPointMode;

  /** The line directive mode for output source code.
   */
  enum SlangLineDirectiveMode lineDirectiveMode;

  /** Whether to force `scalar` layout for glsl shader storage buffers.
   */
  bool forceGLSLScalarBufferLayout;

  /** Pointer to an array of compiler option entries, whose size is
   * compilerOptionEntryCount.
   */
  const struct CompilerOptionEntry *compilerOptionEntries;

  /** Number of additional compiler option entries.
   */
  uint32_t compilerOptionEntryCount;
};

typedef uint32_t SessionFlags;
enum { kSessionFlags_None = 0 };

typedef unsigned int SlangMatrixLayoutModeIntegral;
enum SlangMatrixLayoutMode : SlangMatrixLayoutModeIntegral {
  SLANG_MATRIX_LAYOUT_MODE_UNKNOWN = 0,
  SLANG_MATRIX_LAYOUT_ROW_MAJOR,
  SLANG_MATRIX_LAYOUT_COLUMN_MAJOR,
};

struct SessionDesc {
  /** The size of this structure, in bytes.
   */
  size_t structureSize;

  /** Code generation targets to include in the session.
   */
  struct TargetDesc const *targets;
  SlangInt targetCount;

  /** Flags to configure the session.
   */
  SessionFlags flags;

  /** Default layout to assume for variables with matrix types.
   */
  enum SlangMatrixLayoutMode defaultMatrixLayoutMode;

  /** Paths to use when searching for `#include`d or `import`ed files.
   */
  char const *const *searchPaths;
  SlangInt searchPathCount;

  struct PreprocessorMacroDesc const *preprocessorMacros;
  SlangInt preprocessorMacroCount;

  void *fileSystem;

  bool enableEffectAnnotations;
  bool allowGLSLSyntax;

  /** Pointer to an array of compiler option entries, whose size is
   * compilerOptionEntryCount.
   */
  struct CompilerOptionEntry *compilerOptionEntries;

  /** Number of additional compiler option entries.
   */
  uint32_t compilerOptionEntryCount;

  /** Whether to skip SPIRV validation.
   */
  bool skipSPIRVValidation;
};

typedef SlangUInt32 SlangLayoutRulesIntegral;
enum LayoutRules : SlangLayoutRulesIntegral {
  SLANG_LAYOUT_RULES_DEFAULT,
  SLANG_LAYOUT_RULES_METAL_ARGUMENT_BUFFER_TIER_2,
};

enum GenericArgType {
  SLANG_GENERIC_ARG_TYPE = 0,
  SLANG_GENERIC_ARG_INT = 1,
  SLANG_GENERIC_ARG_BOOL = 2
};

union GenericArgReflectionPtr {
  TypeReflectionPtr typeVal;
  int64_t intVal;
  bool boolVal;
};

typedef SlangUInt32 ModifierIDIntegral;
enum ModifierID : ModifierIDIntegral {
  SLANG_MODIFIER_SHARED,
  SLANG_MODIFIER_NO_DIFF,
  SLANG_MODIFIER_STATIC,
  SLANG_MODIFIER_CONST,
  SLANG_MODIFIER_EXPORT,
  SLANG_MODIFIER_EXTERN,
  SLANG_MODIFIER_DIFFERENTIABLE,
  SLANG_MODIFIER_MUTATING,
  SLANG_MODIFIER_IN,
  SLANG_MODIFIER_OUT,
  SLANG_MODIFIER_INOUT
};

typedef unsigned int ParameterCategoryIntegral;
enum ParameterCategory : ParameterCategoryIntegral {
  SLANG_PARAMETER_CATEGORY_NONE,
  SLANG_PARAMETER_CATEGORY_MIXED,
  SLANG_PARAMETER_CATEGORY_CONSTANT_BUFFER,
  SLANG_PARAMETER_CATEGORY_SHADER_RESOURCE,
  SLANG_PARAMETER_CATEGORY_UNORDERED_ACCESS,
  SLANG_PARAMETER_CATEGORY_VARYING_INPUT,
  SLANG_PARAMETER_CATEGORY_VARYING_OUTPUT,
  SLANG_PARAMETER_CATEGORY_SAMPLER_STATE,
  SLANG_PARAMETER_CATEGORY_UNIFORM,
  SLANG_PARAMETER_CATEGORY_DESCRIPTOR_TABLE_SLOT,
  SLANG_PARAMETER_CATEGORY_SPECIALIZATION_CONSTANT,
  SLANG_PARAMETER_CATEGORY_PUSH_CONSTANT_BUFFER,

  // HLSL register `space`, Vulkan GLSL `set`
  SLANG_PARAMETER_CATEGORY_REGISTER_SPACE,

  // TODO: Ellie, Both APIs treat mesh outputs as more or less varying output,
  // Does it deserve to be represented here??

  // A parameter whose type is to be specialized by a global generic type
  // argument
  SLANG_PARAMETER_CATEGORY_GENERIC,

  SLANG_PARAMETER_CATEGORY_RAY_PAYLOAD,
  SLANG_PARAMETER_CATEGORY_HIT_ATTRIBUTES,
  SLANG_PARAMETER_CATEGORY_CALLABLE_PAYLOAD,
  SLANG_PARAMETER_CATEGORY_SHADER_RECORD,

  // An existential type parameter represents a "hole" that
  // needs to be filled with a concrete type to enable
  // generation of specialized code.
  //
  // Consider this example:
  //
  //      struct MyParams
  //      {
  //          IMaterial material;
  //          ILight lights[3];
  //      };
  //
  // This `MyParams` type introduces two existential type parameters:
  // one for `material` and one for `lights`. Even though `lights`
  // is an array, it only introduces one type parameter, because
  // we need to have a *single* concrete type for all the array
  // elements to be able to generate specialized code.
  //
  SLANG_PARAMETER_CATEGORY_EXISTENTIAL_TYPE_PARAM,

  // An existential object parameter represents a value
  // that needs to be passed in to provide data for some
  // interface-type shader parameter.
  //
  // Consider this example:
  //
  //      struct MyParams
  //      {
  //          IMaterial material;
  //          ILight lights[3];
  //      };
  //
  // This `MyParams` type introduces four existential object parameters:
  // one for `material` and three for `lights` (one for each array
  // element). This is consistent with the number of interface-type
  // "objects" that are being passed through to the shader.
  //
  SLANG_PARAMETER_CATEGORY_EXISTENTIAL_OBJECT_PARAM,

  // The register space offset for the sub-elements that occupies register
  // spaces.
  SLANG_PARAMETER_CATEGORY_SUB_ELEMENT_REGISTER_SPACE,

  // The input_attachment_index subpass occupancy tracker
  SLANG_PARAMETER_CATEGORY_SUBPASS,

  // Metal tier-1 argument buffer element [[id]].
  SLANG_PARAMETER_CATEGORY_METAL_ARGUMENT_BUFFER_ELEMENT,

  // Metal [[attribute]] inputs.
  SLANG_PARAMETER_CATEGORY_METAL_ATTRIBUTE,

  // Metal [[payload]] inputs
  SLANG_PARAMETER_CATEGORY_METAL_PAYLOAD,

  //
  SLANG_PARAMETER_CATEGORY_COUNT,

  // Aliases for Metal-specific categories.
  SLANG_PARAMETER_CATEGORY_METAL_BUFFER =
      SLANG_PARAMETER_CATEGORY_CONSTANT_BUFFER,
  SLANG_PARAMETER_CATEGORY_METAL_TEXTURE =
      SLANG_PARAMETER_CATEGORY_SHADER_RESOURCE,
  SLANG_PARAMETER_CATEGORY_METAL_SAMPLER =
      SLANG_PARAMETER_CATEGORY_SAMPLER_STATE,

  // DEPRECATED:
  SLANG_PARAMETER_CATEGORY_VERTEX_INPUT =
      SLANG_PARAMETER_CATEGORY_VARYING_INPUT,
  SLANG_PARAMETER_CATEGORY_FRAGMENT_OUTPUT =
      SLANG_PARAMETER_CATEGORY_VARYING_OUTPUT,
  SLANG_PARAMETER_CATEGORY_COUNT_V1 = SLANG_PARAMETER_CATEGORY_SUBPASS,
};

typedef SlangUInt32 SlangImageFormatIntegral;
enum SlangImageFormat : SlangImageFormatIntegral {
#define SLANG_FORMAT(NAME, DESC) SLANG_IMAGE_FORMAT_##NAME,
#include "slangc_image_format_defs.h"
#undef SLANG_FORMAT
};

typedef SlangUInt32 SlangStageIntegral;
enum SlangStage : SlangStageIntegral {
  SLANG_STAGE_NONE,
  SLANG_STAGE_VERTEX,
  SLANG_STAGE_HULL,
  SLANG_STAGE_DOMAIN,
  SLANG_STAGE_GEOMETRY,
  SLANG_STAGE_FRAGMENT,
  SLANG_STAGE_COMPUTE,
  SLANG_STAGE_RAY_GENERATION,
  SLANG_STAGE_INTERSECTION,
  SLANG_STAGE_ANY_HIT,
  SLANG_STAGE_CLOSEST_HIT,
  SLANG_STAGE_MISS,
  SLANG_STAGE_CALLABLE,
  SLANG_STAGE_MESH,
  SLANG_STAGE_AMPLIFICATION,
  SLANG_STAGE_DISPATCH,
  //
  SLANG_STAGE_COUNT,

  // alias:
  SLANG_STAGE_PIXEL = SLANG_STAGE_FRAGMENT,
};

typedef unsigned int SlangTypeKindIntegral;
enum SlangTypeKind : SlangTypeKindIntegral {
  SLANG_TYPE_KIND_NONE,
  SLANG_TYPE_KIND_STRUCT,
  SLANG_TYPE_KIND_ARRAY,
  SLANG_TYPE_KIND_MATRIX,
  SLANG_TYPE_KIND_VECTOR,
  SLANG_TYPE_KIND_SCALAR,
  SLANG_TYPE_KIND_CONSTANT_BUFFER,
  SLANG_TYPE_KIND_RESOURCE,
  SLANG_TYPE_KIND_SAMPLER_STATE,
  SLANG_TYPE_KIND_TEXTURE_BUFFER,
  SLANG_TYPE_KIND_SHADER_STORAGE_BUFFER,
  SLANG_TYPE_KIND_PARAMETER_BLOCK,
  SLANG_TYPE_KIND_GENERIC_TYPE_PARAMETER,
  SLANG_TYPE_KIND_INTERFACE,
  SLANG_TYPE_KIND_OUTPUT_STREAM,
  SLANG_TYPE_KIND_MESH_OUTPUT,
  SLANG_TYPE_KIND_SPECIALIZED,
  SLANG_TYPE_KIND_FEEDBACK,
  SLANG_TYPE_KIND_POINTER,
  SLANG_TYPE_KIND_DYNAMIC_RESOURCE,
  SLANG_TYPE_KIND_COUNT,
};

typedef unsigned int SlangScalarTypeIntegral;
enum SlangScalarType : SlangScalarTypeIntegral {
  SLANG_SCALAR_TYPE_NONE,
  SLANG_SCALAR_TYPE_VOID,
  SLANG_SCALAR_TYPE_BOOL,
  SLANG_SCALAR_TYPE_INT32,
  SLANG_SCALAR_TYPE_UINT32,
  SLANG_SCALAR_TYPE_INT64,
  SLANG_SCALAR_TYPE_UINT64,
  SLANG_SCALAR_TYPE_FLOAT16,
  SLANG_SCALAR_TYPE_FLOAT32,
  SLANG_SCALAR_TYPE_FLOAT64,
  SLANG_SCALAR_TYPE_INT8,
  SLANG_SCALAR_TYPE_UINT8,
  SLANG_SCALAR_TYPE_INT16,
  SLANG_SCALAR_TYPE_UINT16,
  SLANG_SCALAR_TYPE_INTPTR,
  SLANG_SCALAR_TYPE_UINTPTR
};

typedef unsigned int SlangResourceShapeIntegral;
enum SlangResourceShape : SlangResourceShapeIntegral {
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

  SLANG_TEXTURE_1D_ARRAY = SLANG_TEXTURE_1D | SLANG_TEXTURE_ARRAY_FLAG,
  SLANG_TEXTURE_2D_ARRAY = SLANG_TEXTURE_2D | SLANG_TEXTURE_ARRAY_FLAG,
  SLANG_TEXTURE_CUBE_ARRAY = SLANG_TEXTURE_CUBE | SLANG_TEXTURE_ARRAY_FLAG,

  SLANG_TEXTURE_2D_MULTISAMPLE =
      SLANG_TEXTURE_2D | SLANG_TEXTURE_MULTISAMPLE_FLAG,
  SLANG_TEXTURE_2D_MULTISAMPLE_ARRAY = SLANG_TEXTURE_2D |
                                       SLANG_TEXTURE_MULTISAMPLE_FLAG |
                                       SLANG_TEXTURE_ARRAY_FLAG,
  SLANG_TEXTURE_SUBPASS_MULTISAMPLE =
      SLANG_TEXTURE_SUBPASS | SLANG_TEXTURE_MULTISAMPLE_FLAG,
};

typedef unsigned int SlangResourceAccessIntegral;
enum SlangResourceAccess : SlangResourceAccessIntegral {
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

typedef SlangUInt32 SlangBindingTypeIntegral;
enum SlangBindingType : SlangBindingTypeIntegral {
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

  SLANG_BINDING_TYPE_MUTABLE_TETURE =
      SLANG_BINDING_TYPE_TEXTURE | SLANG_BINDING_TYPE_MUTABLE_FLAG,
  SLANG_BINDING_TYPE_MUTABLE_TYPED_BUFFER =
      SLANG_BINDING_TYPE_TYPED_BUFFER | SLANG_BINDING_TYPE_MUTABLE_FLAG,
  SLANG_BINDING_TYPE_MUTABLE_RAW_BUFFER =
      SLANG_BINDING_TYPE_RAW_BUFFER | SLANG_BINDING_TYPE_MUTABLE_FLAG,

  SLANG_BINDING_TYPE_BASE_MASK = 0x00FF,
  SLANG_BINDING_TYPE_EXT_MASK = 0xFF00,
};
