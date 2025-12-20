#pragma once
#include <cstdio>
#include "/Users/nmcintosh/.bin/slang/include/slang.h"
namespace slangc {
#include "slangc.h"
}

namespace slangcutil {
static void dumpCTargetDesc(const slangc::TargetDesc& t, int idx)
{
    std::printf("  [C   ] targets[%d] @%p\n", idx, (const void*)&t);
    std::printf("         structureSize              = %zu\n", (size_t)t.structureSize);
    std::printf("         format                     = %d\n", (int)t.format);
    std::printf("         profile                    = %d\n", (int)t.profile);
    std::printf("         flags                      = 0x%x\n", (unsigned)t.flags);
    std::printf("         floatingPointMode          = %u\n", (unsigned)t.floatingPointMode);
    std::printf("         lineDirectiveMode          = %u\n", (unsigned)t.lineDirectiveMode);
    std::printf("         forceGLSLScalarBufferLayout= %" PRId64 "\n", (int64_t)t.forceGLSLScalarBufferLayout); // SlangInt in C API
    std::printf("         compilerOptionEntries      = %p\n", (const void*)t.compilerOptionEntries);
    std::printf("         compilerOptionEntryCount   = %u\n", (unsigned)t.compilerOptionEntryCount);
}

// Print a C++ TargetDesc
static void dumpCppTargetDesc(const slang::TargetDesc& t, int idx, const char* tag)
{
    std::printf("  [%s] targets[%d] @%p\n", tag, idx, (const void*)&t);
    std::printf("         structureSize              = %d\n", (int)t.structureSize);
    std::printf("         format                     = %d\n", (int)t.format);
    std::printf("         profile                    = %d\n", (int)t.profile);
    std::printf("         flags                      = 0x%x\n", (unsigned)t.flags);
    std::printf("         floatingPointMode          = %u\n", (unsigned)t.floatingPointMode);
    std::printf("         lineDirectiveMode          = %u\n", (unsigned)t.lineDirectiveMode);
    // In the C++ API this is typically SlangInt or bool-like; print as 64-bit to be safe.
    std::printf("         forceGLSLScalarBufferLayout= %" PRId64 "\n", (int64_t)t.forceGLSLScalarBufferLayout);
    std::printf("         compilerOptionEntries      = %p\n", (const void*)t.compilerOptionEntries);
    std::printf("         compilerOptionEntryCount   = %u\n", (unsigned)t.compilerOptionEntryCount);
}

static void dumpSessionDesc(const slangc::SessionDesc& session)
{
	std::printf("  [C   ] session @%p\n", &session);
	std::printf("         structureSize              = %zu\n", (size_t)session.structureSize);
	std::printf("         targets                    = %p\n", (const void*)session.targets);
	std::printf("         targetCount                = %u\n", (unsigned)session.targetCount);
	std::printf("         flags                      = 0x%x\n", (unsigned)session.flags);
	std::printf("         defaultMatrixLayoutMode    = %u\n", (unsigned)session.defaultMatrixLayoutMode);
	std::printf("         searchPaths                = %p\n", (const void*)session.searchPaths);
	std::printf("         searchPathCount            = %u\n", (unsigned)session.searchPathCount);
	std::printf("         preprocessorMacros         = %p\n", (const void*)session.preprocessorMacros);
	std::printf("         preprocessorMacroCount     = %u\n", (unsigned)session.preprocessorMacroCount);
	std::printf("         fileSystem                 = %p\n", (const void*)session.fileSystem);
	std::printf("         enableEffectAnnotations    = %u\n", (unsigned)session.enableEffectAnnotations);
	std::printf("         allowGLSLSyntax            = %u\n", (unsigned)session.allowGLSLSyntax);
	std::printf("         compilerOptionEntries      = %p\n", (const void*)session.compilerOptionEntries);
	std::printf("         compilerOptionEntryCount   = %u\n", (unsigned)session.compilerOptionEntryCount);
	std::printf("         skipSPIRVValidation        = %u\n", (unsigned)session.skipSPIRVValidation);
}

static void dumpCppSessionDesc(const slang::SessionDesc& session)
{
	std::printf("  [C   ] session @%p\n", &session);
	std::printf("         structureSize              = %zu\n", (size_t)session.structureSize);
	std::printf("         targets                    = %p\n", (const void*)session.targets);
	std::printf("         targetCount                = %u\n", (unsigned)session.targetCount);
	std::printf("         flags                      = 0x%x\n", (unsigned)session.flags);
	std::printf("         defaultMatrixLayoutMode    = %u\n", (unsigned)session.defaultMatrixLayoutMode);
	std::printf("         searchPaths                = %p\n", (const void*)session.searchPaths);
	std::printf("         searchPathCount            = %u\n", (unsigned)session.searchPathCount);
	std::printf("         preprocessorMacros         = %p\n", (const void*)session.preprocessorMacros);
	std::printf("         preprocessorMacroCount     = %u\n", (unsigned)session.preprocessorMacroCount);
	std::printf("         fileSystem                 = %p\n", (const void*)session.fileSystem);
	std::printf("         enableEffectAnnotations    = %u\n", (unsigned)session.enableEffectAnnotations);
	std::printf("         allowGLSLSyntax            = %u\n", (unsigned)session.allowGLSLSyntax);
	std::printf("         compilerOptionEntries      = %p\n", (const void*)session.compilerOptionEntries);
	std::printf("         compilerOptionEntryCount   = %u\n", (unsigned)session.compilerOptionEntryCount);
	std::printf("         skipSPIRVValidation        = %u\n", (unsigned)session.skipSPIRVValidation);
}
}
