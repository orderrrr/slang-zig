const std = @import("std");

pub const SlangError = error{
    // Compilation errors
    FailedToLoadModule,
    FailedToCreateSession,
    FailedToGetEntryPoint,
    FailedToCreateComposite,
    FailedToLinkProgram,
    FailedToGetLayout,
    FailedToGetTargetCode,
    FailedToGetBlob,
    FailedToGetMetadata,
    FailedToCheckParameterUsage,

    // Reflection errors
    UnknownTypeKind,
    UnknownParameterCategory,
    UnknownResourceShape,
    UnknownResourceType,
    UnknownShaderStage,
    InvalidBindingType,

    // Annotation errors
    InvalidArgument,
    BadArity,
    UnsupportedScalarType,

    // Type errors
    UnsupportedTypeKind,
};

/// Returns a human-readable description of the error.
pub fn errorMessage(err: SlangError) []const u8 {
    return switch (err) {
        // Compilation errors
        error.FailedToLoadModule => "Failed to load shader module from source",
        error.FailedToCreateSession => "Failed to create Slang compiler session",
        error.FailedToGetEntryPoint => "Failed to get shader entry point",
        error.FailedToCreateComposite => "Failed to create composite shader component",
        error.FailedToLinkProgram => "Failed to link shader program",
        error.FailedToGetLayout => "Failed to get shader program layout",
        error.FailedToGetTargetCode => "Failed to get compiled shader code",
        error.FailedToGetBlob => "Failed to get blob data",
        error.FailedToGetMetadata => "Failed to get entry point metadata",
        error.FailedToCheckParameterUsage => "Failed to check parameter location usage",

        // Reflection errors
        error.UnknownTypeKind => "Encountered unknown type kind during reflection",
        error.UnknownParameterCategory => "Encountered unknown parameter category",
        error.UnknownResourceShape => "Encountered unknown resource shape",
        error.UnknownResourceType => "Encountered unknown resource type",
        error.UnknownShaderStage => "Encountered unknown shader stage",
        error.InvalidBindingType => "Invalid binding type for resource",

        // Annotation errors
        error.InvalidArgument => "Invalid argument value or type",
        error.BadArity => "Wrong number of arguments for annotation",
        error.UnsupportedScalarType => "Unsupported scalar type in annotation",

        // Type errors
        error.UnsupportedTypeKind => "Unsupported type kind",
    };
}

/// Logs an error with context and returns it.
pub fn logError(err: SlangError, context: []const u8) SlangError {
    std.log.err("{s}: {s}", .{ context, errorMessage(err) });
    return err;
}
