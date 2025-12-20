#include "/Users/nmcintosh/.bin/slang/include/slang.h"
#include <cstddef>
#include <cstdint>
#include <cstdio>
namespace slangc {
#include "slangc.h"
#include "slangc_types.h"
} // namespace slangc

extern "C" {
slangc::SlangResult
createGlobalSession(slangc::IGlobalSession *outGlobalSession) {
  slang::IGlobalSession **globalSession =
      (slang::IGlobalSession **)outGlobalSession;
  return slang_createGlobalSession(SLANG_API_VERSION, globalSession);
}

slangc::SlangResult createSession(slangc::IGlobalSession inGlobalSession,
                                  const slangc::SessionDesc *inSessionDesc,
                                  slangc::ISession *outSession) {

  auto *globalSession = (slang::IGlobalSession *)inGlobalSession;
  auto **session = (slang::ISession **)outSession;
  const slang::SessionDesc sessionDesc = *(slang::SessionDesc *)inSessionDesc;

  return globalSession->createSession(sessionDesc, session);
}

SlangProfileIDIntegral findProfile(slangc::IGlobalSession inGlobalSession,
                                   const char *profile) {
  auto *globalSession = (slang::IGlobalSession *)inGlobalSession;
  return globalSession->findProfile(profile);
}

SlangResult loadModuleFromSourceString(slangc::ISession inSession,
                                       const char *sourceBuffer,
                                       slangc::IModule *outModule,
                                       slangc::IBlob *outDiagnostics) {
  auto *session = (slang::ISession *)inSession;
  auto **diagnostics = (slang::IBlob **)outDiagnostics;
  auto **module = (slang::IModule **)outModule;

  *module = (session->loadModuleFromSourceString(
      "shader_module", "shader.slang", sourceBuffer, diagnostics));

  return *module ? SLANG_OK : SLANG_FAIL;
}

SlangResult findEntryPointByName(slangc::IModule inModule, char const *name,
                                 slangc::IEntryPoint *inEntryPoint) {
  auto *module = (slang::IModule *)inModule;
  auto **entryPoint = (slang::IEntryPoint **)inEntryPoint;
  auto re = module->findEntryPointByName(name, entryPoint);
  return re;
};

SlangResult createCompositeComponent(
    slangc::ISession inSession, const slangc::IComponentType *inComponentTypes,
    SlangInt componentTypeCount, slangc::IComponentType *outComposite,
    slangc::IBlob *outDiagnostics) {

  auto *session = (slang::ISession *)inSession;
  auto **componentTypes = (slang::IComponentType **)inComponentTypes;
  auto **composite = (slang::IComponentType **)outComposite;
  auto **diagnostics = (slang::IBlob **)outDiagnostics;

  return session->createCompositeComponentType(
      componentTypes, componentTypeCount, composite, diagnostics);
}

SlangResult linkProgram(slangc::IComponentType inCompiledProgram,
                        slangc::IComponentType *outLinkedProgram,
                        slangc::IBlob *outDiagnostics) {
  auto *session = (slang::IComponentType *)inCompiledProgram;
  auto **linkedProgram = (slang::IComponentType **)outLinkedProgram;
  auto **diagnostics = (slang::IBlob **)outDiagnostics;
  return session->link(linkedProgram, diagnostics);
}

SlangResult getLayout(slangc::IComponentType inProgram, SlangInt targetIndex,
                      slangc::ProgramLayout *outLayout,
                      slangc::IBlob *outDiagnostics) {
  auto *program = (slang::IComponentType *)inProgram;
  auto **diagnostics = (slang::IBlob **)outDiagnostics;
  *outLayout = program->getLayout(targetIndex, diagnostics);
  return *outLayout ? SLANG_OK : SLANG_FAIL;
}

SlangResult getTargetCode(slangc::IComponentType linkedProgram,
                          slangc::IBlob *outOutput,
                          slangc::IBlob *outDiagnostics) {

  auto *program = (slang::IComponentType *)linkedProgram;
  auto **output = (slang::IBlob **)outOutput;
  auto **diagnostics = (slang::IBlob **)outDiagnostics;

  return program->getTargetCode(0, output, diagnostics);
}

SlangResult getBlobSlice(slangc::IBlob inBlob, const void **pointer,
                         size_t *size) {
  auto *blob = (slang::IBlob *)inBlob;
  *pointer = blob->getBufferPointer();
  *size = blob->getBufferSize();

  return *pointer and *size ? SLANG_OK : SLANG_FAIL;
}

unsigned ProgramLayout_getParameterCount(slangc::ProgramLayout layout) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->getParameterCount();
}

unsigned ProgramLayout_getTypeParameterCount(slangc::ProgramLayout layout) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->getTypeParameterCount();
}

slangc::TypeParameterReflection
ProgramLayout_getTypeParameterByIndex(slangc::ProgramLayout layout,
                                      unsigned index) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->getTypeParameterByIndex(index);
}

slangc::TypeParameterReflection
ProgramLayout_findTypeParameter(slangc::ProgramLayout layout,
                                const char *name) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->findTypeParameter(name);
}

slangc::VariableLayoutReflection
ProgramLayout_getParameterByIndex(slangc::ProgramLayout layout,
                                  unsigned index) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->getParameterByIndex(index);
}

SlangUInt ProgramLayout_getEntryPointCount(slangc::ProgramLayout layout) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->getEntryPointCount();
}

slangc::EntryPointReflection
ProgramLayout_getEntryPointByIndex(slangc::ProgramLayout layout,
                                   SlangUInt index) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->getEntryPointByIndex(index);
}

SlangUInt
ProgramLayout_getGlobalConstantBufferBinding(slangc::ProgramLayout layout) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->getGlobalConstantBufferBinding();
}

size_t ProgramLayout_getGlobalConstantBufferSize(slangc::ProgramLayout layout) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->getGlobalConstantBufferSize();
}

slangc::TypeReflection
ProgramLayout_findTypeByName(slangc::ProgramLayout layout, const char *name) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->findTypeByName(name);
}

slangc::FunctionReflection
ProgramLayout_findFunctionByName(slangc::ProgramLayout layout,
                                 const char *name) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->findFunctionByName(name);
}

slangc::FunctionReflection
ProgramLayout_findFunctionByNameInType(slangc::ProgramLayout layout,
                                       slangc::TypeReflection inType,
                                       const char *name) {
  auto *self = (slang::ProgramLayout *)layout;
  auto *typeReflection = (slang::TypeReflection *)inType;
  return self->findFunctionByNameInType(typeReflection, name);
}

slangc::VariableReflection
ProgramLayout_findVarByNameInType(slangc::ProgramLayout layout,
                                  slangc::TypeReflection inType,
                                  const char *name) {
  auto *self = (slang::ProgramLayout *)layout;
  auto *typeReflection = (slang::TypeReflection *)inType;
  return self->findVarByNameInType(typeReflection, name);
}

slangc::TypeLayoutReflection
ProgramLayout_getTypeLayout(slangc::ProgramLayout layout,
                            slangc::TypeReflection inType,
                            slangc::SlangLayoutRulesIntegral layoutRules) {
  auto *self = (slang::ProgramLayout *)layout;
  auto *typeReflection = (slang::TypeReflection *)inType;
  return self->getTypeLayout(typeReflection, slang::LayoutRules(layoutRules));
}

slangc::EntryPointReflection
ProgramLayout_findEntryPointReflectionByName(slangc::ProgramLayout layout,
                                             const char *name) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->findEntryPointByName(name);
}

slangc::TypeReflection
ProgramLayout_specializeType(slangc::ProgramLayout layout,
                             slangc::TypeReflection inType,
                             SlangInt specialiazationArgCount,
                             slangc::TypeReflection const *specialiazationArgs,
                             slangc::IBlob *outDiagnostics) {
  auto *self = (slang::ProgramLayout *)layout;
  auto *typeReflection = (slang::TypeReflection *)inType;
  auto *const *args = (slang::TypeReflection *const *)specialiazationArgs;
  auto **diagnostics = (slang::IBlob **)outDiagnostics;
  return self->specializeType(typeReflection, specialiazationArgCount, args,
                              diagnostics);
}

slangc::GenericReflection ProgramLayout_specializeGeneric(
    slangc::ProgramLayout layout, slangc::GenericReflection inGeneric,
    SlangInt specializationArgCount,
    slangc::GenericArgType const *inSpecialiazationArgTypes,
    slangc::GenericArgReflection const *inSpecializationArgVals,
    slangc::IBlob *outDiagnostics) {
  auto *self = (slang::ProgramLayout *)layout;
  auto *generic = (slang::GenericReflection *)inGeneric;
  auto const *specializationArgTypes =
      (slang::GenericArgType const *)inSpecialiazationArgTypes;
  auto const *specializationArgVals =
      (slang::GenericArgReflection const *)inSpecializationArgVals;
  auto **diagnostics = (slang::IBlob **)outDiagnostics;
  return self->specializeGeneric(generic, specializationArgCount,
                                 specializationArgTypes, specializationArgVals,
                                 diagnostics);
}

bool ProgramLayout_isSubType(slangc::ProgramLayout layout,
                             slangc::TypeReflection inSubType,
                             slangc::TypeReflection inSuperType) {
  auto *self = (slang::ProgramLayout *)layout;
  auto *subType = (slang::TypeReflection *)inSubType;
  auto *superType = (slang::TypeReflection *)inSuperType;
  return self->isSubType(subType, superType);
}

SlangUInt ProgramLayout_getHashedStringCount(slangc::ProgramLayout layout) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->getHashedStringCount();
}

const char *ProgramLayout_getHashedString(slangc::ProgramLayout layout,
                                          SlangUInt index, size_t *outCount) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->getHashedString(index, outCount);
}

slangc::TypeLayoutReflection
ProgramLayout_getGlobalParamsTypeLayout(slangc::ProgramLayout layout) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->getGlobalParamsTypeLayout();
}

slangc::VariableLayoutReflection
ProgramLayout_getGlobalParamsVarLayout(slangc::ProgramLayout layout) {
  auto *self = (slang::ProgramLayout *)layout;
  return self->getGlobalParamsVarLayout();
}

slangc::VariableReflection
VariableLayoutReflection_getVariable(slangc::VariableLayoutReflection layout) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getVariable();
}

char const *
VariableLayoutReflection_getName(slangc::VariableLayoutReflection layout) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getName();
}

slangc::Modifier
VariableLayoutReflection_findModifier(slangc::VariableLayoutReflection layout,
                                      slangc::ModifierIDIntegral id) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->findModifier(slang::Modifier::ID(id));
}

slangc::TypeLayoutReflection VariableLayoutReflection_getTypeLayout(
    slangc::VariableLayoutReflection layout) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getTypeLayout();
}

slangc::ParameterCategoryIntegral
VariableLayoutReflection_getCategory(slangc::VariableLayoutReflection layout) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getCategory();
}

unsigned int VariableLayoutReflection_getCategoryCount(
    slangc::VariableLayoutReflection layout) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getCategoryCount();
}

slangc::ParameterCategoryIntegral VariableLayoutReflection_getCategoryByIndex(
    slangc::VariableLayoutReflection layout, unsigned int index) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getCategoryByIndex(index);
}

size_t
VariableLayoutReflection_getOffset(slangc::VariableLayoutReflection layout,
                                   slangc::ParameterCategoryIntegral category) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getOffset(slang::ParameterCategory(category));
}

slangc::TypeReflection
VariableLayoutReflection_getType(slangc::VariableLayoutReflection layout) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getType();
}

unsigned VariableLayoutReflection_getBindingIndex(
    slangc::VariableLayoutReflection layout) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getBindingIndex();
}

unsigned VariableLayoutReflection_getBindingSpace(
    slangc::VariableLayoutReflection layout) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getBindingSpace();
}

size_t VariableLayoutReflection_getBindingSpaceByCategory(
    slangc::VariableLayoutReflection layout,
    slangc::ParameterCategoryIntegral category) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getBindingSpace(slang::ParameterCategory(category));
}

slangc::SlangImageFormatIntegral VariableLayoutReflection_getImageFormat(
    slangc::VariableLayoutReflection layout) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getImageFormat();
}

char const *VariableLayoutReflection_getSemanticName(
    slangc::VariableLayoutReflection layout) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getSemanticName();
}

size_t VariableLayoutReflection_getSemanticIndex(
    slangc::VariableLayoutReflection layout) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getSemanticIndex();
}

slangc::SlangStageIntegral VariableLayoutReflection_getSlangStage(
    slangc::VariableLayoutReflection layout) {
  auto *self = (slang::VariableLayoutReflection *)layout;
  return self->getStage();
}

slangc::SlangTypeKindIntegral
TypeReflection_getKind(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return static_cast<slangc::SlangTypeKindIntegral>(self->getKind());
}

unsigned int TypeReflection_getFieldCount(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getFieldCount();
}

slangc::VariableReflection
TypeReflection_getFieldByIndex(slangc::TypeReflection type,
                               unsigned int index) {
  auto *self = (slang::TypeReflection *)type;
  return self->getFieldByIndex(index);
}

bool TypeReflection_isArray(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->isArray();
}

slangc::TypeReflection TypeReflection_unwrapArray(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->unwrapArray();
}

size_t TypeReflection_getElementCount(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getElementCount();
}

size_t TypeReflection_getTotalArrayElementCount(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getTotalArrayElementCount();
}

slangc::TypeReflection
TypeReflection_getElementType(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getElementType();
}

unsigned TypeReflection_getRowCount(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getRowCount();
}

unsigned TypeReflection_getColumnCount(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getColumnCount();
}

slangc::SlangScalarTypeIntegral
TypeReflection_getScalarType(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getScalarType();
}

slangc::TypeReflection
TypeReflection_getResourceResultType(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getResourceResultType();
}

slangc::SlangResourceShapeIntegral
TypeReflection_getResourceShape(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getResourceShape();
}

slangc::SlangResourceAccessIntegral
TypeReflection_getResourceAccess(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getResourceAccess();
}

char const *TypeReflection_getName(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getName();
}

unsigned int TypeReflection_getUserAttributeCount(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getUserAttributeCount();
}

slangc::Attribute
TypeReflection_getUserAttributeByIndex(slangc::TypeReflection type,
                                       unsigned int index) {
  auto *self = (slang::TypeReflection *)type;
  return self->getUserAttributeByIndex(index);
}

slangc::Attribute
TypeReflection_findUserAttributeByName(slangc::TypeReflection type,
                                       char const *name) {
  auto *self = (slang::TypeReflection *)type;
  return self->findUserAttributeByName(name);
}

slangc::Attribute
TypeReflection_findAttributeByName(slangc::TypeReflection type,
                                   char const *name) {
  auto *self = (slang::TypeReflection *)type;
  return self->findAttributeByName(name);
}

slangc::GenericReflection
TypeReflection_getGenericCountainer(slangc::TypeReflection type) {
  auto *self = (slang::TypeReflection *)type;
  return self->getGenericContainer();
}

char const *VariableReflection_getName(slangc::VariableReflection variable) {
  auto *self = (slang::VariableReflection *)variable;
  return self->getName();
}

slangc::TypeReflection
VariableReflection_getType(slangc::VariableReflection variable) {
  auto *self = (slang::VariableReflection *)variable;
  return self->getType();
}

slangc::Modifier
VariableReflection_findModifier(slangc::VariableReflection variable,
                                slangc::ModifierIDIntegral id) {
  auto *self = (slang::VariableReflection *)variable;
  return self->findModifier(slang::Modifier::ID(id));
}

unsigned int
VariableReflection_getUserAttributeCount(slangc::VariableReflection variable) {
  auto *self = (slang::VariableReflection *)variable;
  return self->getUserAttributeCount();
}

slangc::Attribute
VariableReflection_getUserAttributeByIndex(slangc::VariableReflection variable,
                                           unsigned int index) {
  auto *self = (slang::VariableReflection *)variable;
  return self->getUserAttributeByIndex(index);
}

slangc::Attribute
VariableReflection_findAttributeByName(slangc::VariableReflection variable,
                                       slangc::IGlobalSession inSession,
                                       char const *name) {
  auto *self = (slang::VariableReflection *)variable;
  auto *session = (slang::IGlobalSession *)inSession;
  return self->findAttributeByName(session, name);
}

slangc::Attribute
VariableReflection_findUserAttributeByName(slangc::VariableReflection variable,
                                           slangc::IGlobalSession inSession,
                                           char const *name) {
  auto *self = (slang::VariableReflection *)variable;
  auto *session = (slang::IGlobalSession *)inSession;
  return self->findUserAttributeByName(session, name);
}

bool VariableReflection_hasDefaultValue(slangc::VariableReflection variable) {
  auto *self = (slang::VariableReflection *)variable;
  return self->hasDefaultValue();
}

slangc::SlangResult
VariableReflection_getDefaultValue(slangc::VariableReflection variable,
                                   int64_t *value) {
  auto *self = (slang::VariableReflection *)variable;
  return self->getDefaultValueInt(value);
}

slangc::GenericReflection
VariableReflection_getGenericContainer(slangc::VariableReflection variable) {
  auto *self = (slang::VariableReflection *)variable;
  return self->getGenericContainer();
}

slangc::VariableReflection
VariableReflection_applySpecializations(slangc::VariableReflection variable,
                                        slangc::GenericReflection inGeneric) {
  auto *self = (slang::VariableReflection *)variable;
  auto *generic = (slang::GenericReflection *)inGeneric;
  return self->applySpecializations(generic);
}

slangc::TypeReflection
TypeLayoutReflection_getType(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getType();
}

slangc::SlangTypeKindIntegral
TypeLayoutReflection_getKind(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return static_cast<slangc::SlangTypeKindIntegral>(self->getKind());
}

size_t
TypeLayoutReflection_getSize(slangc::TypeLayoutReflection layout,
                             slangc::ParameterCategoryIntegral category) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getSize(SlangParameterCategory(category));
}

size_t
TypeLayoutReflection_getStride(slangc::TypeLayoutReflection layout,
                               slangc::ParameterCategoryIntegral category) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getStride(SlangParameterCategory(category));
}

int32_t
TypeLayoutReflection_getAlignment(slangc::TypeLayoutReflection layout,
                                  slangc::ParameterCategoryIntegral category) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getAlignment(SlangParameterCategory(category));
}

unsigned int
TypeLayoutReflection_getFieldCount(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getFieldCount();
}

slangc::VariableLayoutReflection
TypeLayoutReflection_getFieldByIndex(slangc::TypeLayoutReflection layout,
                                     unsigned int index) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getFieldByIndex(index);
}

slangc::VariableLayoutReflection
TypeLayoutReflection_getExplicitCounter(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getExplicitCounter();
}

bool TypeLayoutReflection_isArray(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->isArray();
}

slangc::TypeLayoutReflection
TypeLayoutReflection_unwrapArray(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->unwrapArray();
}

size_t
TypeLayoutReflection_getElementCount(slangc::TypeLayoutReflection layout,
                                     slangc::ShaderReflection reflection) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  auto *refl = (slang::ShaderReflection *)reflection;
  return self->getElementCount(refl);
}

size_t
TypeLayoutReflection_getTotalElementCount(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getTotalArrayElementCount();
}

size_t
TypeLayoutReflection_getElementStride(slangc::TypeLayoutReflection layout,
                                      slangc::ParameterCategory category) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getElementStride(SlangParameterCategory(category));
}

slangc::TypeLayoutReflection
TypeLayoutReflection_getElementTypeLayout(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getElementTypeLayout();
}

slangc::VariableLayoutReflection
TypeLayoutReflection_getElementVarLayout(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getElementVarLayout();
}

slangc::VariableLayoutReflection TypeLayoutReflection_getContainerVarLayout(
    slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getContainerVarLayout();
}

slangc::ParameterCategory
TypeLayoutReflection_getParameterCategory(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return static_cast<slangc::ParameterCategory>(self->getParameterCategory());
}

unsigned int
TypeLayoutReflection_getCategoryCount(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getCategoryCount();
}

slangc::ParameterCategory
TypeLayoutReflection_getCategoryByIndex(slangc::TypeLayoutReflection layout,
                                        unsigned int index) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return static_cast<slangc::ParameterCategory>(
      self->getCategoryByIndex(index));
}

unsigned TypeLayoutReflection_getRowCount(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getRowCount();
}

unsigned
TypeLayoutReflection_getColumnCount(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getColumnCount();
}

slangc::SlangScalarType
TypeLayoutReflection_getScalarType(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return static_cast<slangc::SlangScalarType>(self->getScalarType());
}

slangc::TypeReflection TypeLayoutReflection_getResourceResultType(
    slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getResourceResultType();
}

slangc::SlangResourceShape
TypeLayoutReflection_getResourceShape(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return static_cast<slangc::SlangResourceShape>(self->getResourceShape());
}

slangc::SlangResourceAccess
TypeLayoutReflection_getResourceAccess(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return static_cast<slangc::SlangResourceAccess>(self->getResourceAccess());
}

char const *TypeLayoutReflection_getName(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getName();
}

slangc::SlangMatrixLayoutMode
TypeLayoutReflection_getMatrixLayoutMode(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return static_cast<slangc::SlangMatrixLayoutMode>(
      self->getMatrixLayoutMode());
}

int TypeLayoutReflection_getGenericParamIndex(
    slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getGenericParamIndex();
}

slangc::SlangInt
TypeLayoutReflection_getBindingRangeCount(slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getBindingRangeCount();
}

slangc::SlangBindingType
TypeLayoutReflection_getBindingRangeType(slangc::TypeLayoutReflection layout,
                                         slangc::SlangInt index) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return static_cast<slangc::SlangBindingType>(
      self->getBindingRangeType(index));
}

bool TypeLayoutReflection_isBindingRangeSpecializable(
    slangc::TypeLayoutReflection layout, SlangInt index) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->isBindingRangeSpecializable(index);
}

slangc::SlangInt TypeLayoutReflection_getBindingRangeBindingCount(
    slangc::TypeLayoutReflection layout, SlangInt index) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getBindingRangeBindingCount(index);
}

slangc::SlangInt TypeLayoutReflection_getFieldBindingRangeOffset(
    slangc::TypeLayoutReflection layout, slangc::SlangInt index) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getFieldBindingRangeOffset(index);
}

slangc::SlangInt TypeLayoutReflection_getExplicitCounterBindingRangeOffset(
    slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getExplicitCounterBindingRangeOffset();
}

slangc::TypeLayoutReflection TypeLayoutReflection_getBindingRangeLeafTypeLayout(
    slangc::TypeLayoutReflection layout, slangc::SlangInt index) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getBindingRangeLeafTypeLayout(index);
}

slangc::SlangImageFormatIntegral TypeLayoutReflection_getBindingRangeImageFormat(
    slangc::TypeLayoutReflection layout, slangc::SlangInt index) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getBindingRangeImageFormat(index);
}

slangc::SlangInt TypeLayoutReflection_getBindingRangeDescriptorSetIndex(
    slangc::TypeLayoutReflection layout, SlangInt index) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getBindingRangeDescriptorSetIndex(index);
}

slangc::SlangInt TypeLayoutReflection_getBindingRangeFirstDescriptorRangeIndex(
    slangc::TypeLayoutReflection layout, SlangInt index) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getBindingRangeFirstDescriptorRangeIndex(index);
}

slangc::SlangInt TypeLayoutReflection_getBindingRangeDescriptorRangeCount(
    slangc::TypeLayoutReflection layout, SlangInt index) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getBindingRangeDescriptorRangeCount(index);
}

slangc::SlangInt TypeLayoutReflection_getDescriptorSetCount(
    slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getDescriptorSetCount();
}

slangc::SlangInt TypeLayoutReflection_getDescriptorSetSpaceOffset(
    slangc::TypeLayoutReflection layout, SlangInt setIndex) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getDescriptorSetSpaceOffset(setIndex);
}

slangc::SlangInt TypeLayoutReflection_getDescriptorSetDescriptorRangeCount(
    slangc::TypeLayoutReflection layout, SlangInt setIndex) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getDescriptorSetDescriptorRangeCount(setIndex);
}

slangc::SlangInt
TypeLayoutReflection_getDescriptorSetDescriptorRangeIndexOffset(
    slangc::TypeLayoutReflection layout, SlangInt setIndex,
    SlangInt rangeIndex) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getDescriptorSetDescriptorRangeIndexOffset(setIndex, rangeIndex);
}

slangc::SlangInt
TypeLayoutReflection_getDescriptorSetDescriptorRangeDescriptorCount(
    slangc::TypeLayoutReflection layout, slangc::SlangInt setIndex,
    slangc::SlangInt rangeIndex) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getDescriptorSetDescriptorRangeDescriptorCount(setIndex,
                                                              rangeIndex);
}

slangc::SlangBindingTypeIntegral
TypeLayoutReflection_getDescriptorSetDescriptorRangeType(
    slangc::TypeLayoutReflection layout, slangc::SlangInt setIndex,
    slangc::SlangInt rangeIndex) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return static_cast<slangc::SlangBindingType>(
      self->getDescriptorSetDescriptorRangeType(setIndex, rangeIndex));
}

slangc::ParameterCategory
TypeLayoutReflection_getDescriptorSetDescriptorRangeCategory(
    slangc::TypeLayoutReflection layout, slangc::SlangInt setIndex,
    slangc::SlangInt rangeIndex) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return static_cast<slangc::ParameterCategory>(
      self->getDescriptorSetDescriptorRangeCategory(setIndex, rangeIndex));
}

slangc::SlangInt TypeLayoutReflection_getSubObjectRangeCount(
    slangc::TypeLayoutReflection layout) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getSubObjectRangeCount();
}

slangc::SlangInt TypeLayoutReflection_getSubObjectRangeBindingRangeIndex(
    slangc::TypeLayoutReflection layout, slangc::SlangInt subObjectRangeIndex) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getSubObjectRangeBindingRangeIndex(subObjectRangeIndex);
}

slangc::SlangInt TypeLayoutReflection_getSubObjectRangeSpaceOffset(
    slangc::TypeLayoutReflection layout, slangc::SlangInt subObjectRangeIndex) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getSubObjectRangeSpaceOffset(subObjectRangeIndex);
}

slangc::VariableLayoutReflection TypeLayoutReflection_getSubObjectRangeOffset(
    slangc::TypeLayoutReflection layout, slangc::SlangInt subObjectRangeIndex) {
  auto *self = (slang::TypeLayoutReflection *)layout;
  return self->getSubObjectRangeOffset(subObjectRangeIndex);
}

// SlangInt findFieldIndexByName(char const* nameBegin, char const* nameEnd =
// nullptr)
// {
//     return spReflectionTypeLayout_findFieldIndexByName(
//         (SlangReflectionTypeLayout*)this,
//         nameBegin,
//         nameEnd);
// }

char const *EntryPointReflection_getName(slangc::EntryPointReflection self) {
  auto *reflection = (slang::EntryPointReflection *)self;
  return reflection->getName();
}

char const *
EntryPointReflection_getNameOverride(slangc::EntryPointReflection self) {
  auto *reflection = (slang::EntryPointReflection *)self;
  return reflection->getNameOverride();
}

unsigned
EntryPointReflection_getParameterCount(slangc::EntryPointReflection self) {
  auto *reflection = (slang::EntryPointReflection *)self;
  return reflection->getParameterCount();
}

slangc::FunctionReflection
EntryPointReflection_getFunction(slangc::EntryPointReflection self) {
  auto *reflection = (slang::EntryPointReflection *)self;
  return reflection->getFunction();
}

slangc::VariableLayoutReflection
EntryPointReflection_getParameterByIndex(slangc::EntryPointReflection self,
                                         unsigned index) {
  auto *reflection = (slang::EntryPointReflection *)self;
  return reflection->getParameterByIndex(index);
}

slangc::SlangStageIntegral
EntryPointReflection_getStage(slangc::EntryPointReflection self) {
  auto *reflection = (slang::EntryPointReflection *)self;
  return static_cast<slangc::SlangStageIntegral>(reflection->getStage());
}

void EntryPointReflection_getComputeThreadGroupSize(
    slangc::EntryPointReflection self, slangc::SlangUInt axisCount,
    slangc::SlangUInt *outSizeAlongAxis) {
  auto *reflection = (slang::EntryPointReflection *)self;
  reflection->getComputeThreadGroupSize(axisCount, outSizeAlongAxis);
}

void EntryPointReflection_getComputeWaveSize(slangc::EntryPointReflection self,
                                             slangc::SlangUInt *outWaveSize) {
  auto *reflection = (slang::EntryPointReflection *)self;
  reflection->getComputeWaveSize(outWaveSize);
}

bool EntryPointReflection_usesAnySampleRateInput(
    slangc::EntryPointReflection self) {
  auto *reflection = (slang::EntryPointReflection *)self;
  return reflection->usesAnySampleRateInput();
}

slangc::VariableLayoutReflection
EntryPointReflection_getVarLayout(slangc::EntryPointReflection self) {
  auto *reflection = (slang::EntryPointReflection *)self;
  return reflection->getVarLayout();
}

slangc::TypeLayoutReflection
EntryPointReflection_getTypeLayout(slangc::EntryPointReflection self) {
  auto *reflection = (slang::EntryPointReflection *)self;
  return reflection->getTypeLayout();
}

slangc::VariableLayoutReflection
EntryPointReflection_getResultVarLayout(slangc::EntryPointReflection self) {
  auto *reflection = (slang::EntryPointReflection *)self;
  return reflection->getResultVarLayout();
}

bool EntryPointReflection_hasDefaultConstantBuffer(
    slangc::EntryPointReflection self) {
  auto *reflection = (slang::EntryPointReflection *)self;
  return reflection->hasDefaultConstantBuffer();
}

char const *
TypeParameterReflection_getName(slangc::TypeParameterReflection self) {
  auto *reflection = (slang::TypeParameterReflection *)self;
  return reflection->getName();
}

unsigned
TypeParameterReflection_getIndex(slangc::TypeParameterReflection self) {
  auto *reflection = (slang::TypeParameterReflection *)self;
  return reflection->getIndex();
}

unsigned TypeParameterReflection_getConstraintCount(
    slangc::TypeParameterReflection self) {
  auto *reflection = (slang::TypeParameterReflection *)self;
  return reflection->getConstraintCount();
}

slangc::TypeReflection TypeParameterReflection_getConstraintByIndex(
    slangc::TypeParameterReflection self, unsigned index) {
  auto *reflection = (slang::TypeParameterReflection *)self;
  return reflection->getConstraintByIndex(index);
}

slangc::SlangResult
IComponentType_getEntryPointMetadata(slangc::IComponentType inComponentType,
                                     size_t entryPointIndex, size_t targetIndex,
                                     slangc::IMetadata *outMetadata,
                                     slangc::IBlob *outDiagnostics) {
  auto *componentType = (slang::IComponentType *)inComponentType;
  auto **metadata = (slang::IMetadata **)outMetadata;
  auto **diagnostics = (slang::IBlob **)outDiagnostics;
  return componentType->getEntryPointMetadata(entryPointIndex, targetIndex,
                                              metadata, diagnostics);
}

slangc::SlangResult IMetadata_isParameterLocationUsed(
    slangc::IMetadata inMetadata, slangc::ParameterCategory category,
    slangc::SlangUInt spaceInt, slangc::SlangUInt registerInt, bool &outUsed) {
  auto *metadata = (slang::IMetadata *)inMetadata;
  return metadata->isParameterLocationUsed(SlangParameterCategory(category),
                                           spaceInt, registerInt, outUsed);
}

char const *AttributeReflection_getName(slangc::Attribute self) {
  auto *attribute = (slang::Attribute *)self;
  return attribute->getName();
}

uint32_t AttributeReflection_getArgumentCount(slangc::Attribute self) {
  auto *attribute = (slang::Attribute *)self;
  return attribute->getArgumentCount();
}

slangc::TypeReflection
AttributeReflection_getArgumentType(slangc::Attribute self, uint32_t index) {
  auto *attribute = (slang::Attribute *)self;
  return attribute->getArgumentType(index);
}

slangc::SlangResult
AttributeReflection_getArgumentValueInt(slangc::Attribute self, uint32_t index,
                                        int *value) {
  auto *attribute = (slang::Attribute *)self;
  return attribute->getArgumentValueInt(index, value);
}

slangc::SlangResult
AttributeReflection_getArgumentValueFloat(slangc::Attribute self,
                                          uint32_t index, float *value) {
  auto *attribute = (slang::Attribute *)self;
  return attribute->getArgumentValueFloat(index, value);
}

const char *AttributeReflection_getArgumentValueString(slangc::Attribute self,
                                                       uint32_t index,
                                                       size_t *outSize) {
  auto *attribute = (slang::Attribute *)self;
  return attribute->getArgumentValueString(index, outSize);
}

const char *FunctionReflection_getName(slangc::FunctionReflection self) {
  auto *function = (slang::FunctionReflection *)self;
  return function->getName();
}

slangc::TypeReflection
FunctionReflection_getReturnType(slangc::FunctionReflection self) {
  auto *function = (slang::FunctionReflection *)self;
  return (slangc::TypeReflection)function->getReturnType();
}

unsigned int
FunctionReflection_getParameterCount(slangc::FunctionReflection self) {
  auto *function = (slang::FunctionReflection *)self;
  return function->getParameterCount();
}

slangc::VariableReflection
FunctionReflection_getParameterByIndex(slangc::FunctionReflection self,
                                       unsigned int index) {
  auto *function = (slang::FunctionReflection *)self;
  return (slangc::VariableReflection)function->getParameterByIndex(index);
}

unsigned int
FunctionReflection_getUserAttributeCount(slangc::FunctionReflection self) {
  auto *function = (slang::FunctionReflection *)self;
  return function->getUserAttributeCount();
}

slangc::Attribute
FunctionReflection_getUserAttributeByIndex(slangc::FunctionReflection self,
                                           unsigned int index) {
  auto *function = (slang::FunctionReflection *)self;
  return function->getUserAttributeByIndex(index);
}

slangc::Attribute
FunctionReflection_findAttributeByName(slangc::FunctionReflection self,
                                       slangc::IGlobalSession inSession,
                                       char const *name) {
  auto *function = (slang::FunctionReflection *)self;
  auto *session = (slang::IGlobalSession *)inSession;
  return function->findAttributeByName(session, name);
}

slangc::Attribute
FunctionReflection_findUserAttributeByName(slangc::FunctionReflection self,
                                           slangc::IGlobalSession inSession,
                                           char const *name) {
  auto *function = (slang::FunctionReflection *)self;
  auto *session = (slang::IGlobalSession *)inSession;
  return function->findUserAttributeByName(session, name);
}

slangc::Modifier
FunctionReflection_findModifier(slangc::FunctionReflection self,
                                slangc::ModifierIDIntegral id) {
  auto *function = (slang::FunctionReflection *)self;
  return function->findModifier(slang::Modifier::ID(id));
}

slangc::GenericReflection
FunctionReflection_getGenericContainer(slangc::FunctionReflection self) {
  auto *function = (slang::FunctionReflection *)self;
  return function->getGenericContainer();
}

slangc::FunctionReflection
FunctionReflection_applySpecializations(slangc::FunctionReflection self,
                                        slangc::GenericReflection inGeneric) {
  auto *function = (slang::FunctionReflection *)self;
  auto *generic = (slang::GenericReflection *)inGeneric;
  return (slangc::FunctionReflection)function->applySpecializations(generic);
}

slangc::FunctionReflection FunctionReflection_specializeWithArgTypes(
    slangc::FunctionReflection self, unsigned int argCount,
    slangc::TypeReflection const *inTypes) {
  auto *function = (slang::FunctionReflection *)self;
  auto *types = (slang::TypeReflection *const *)inTypes;
  return function->specializeWithArgTypes(argCount, types);
}

bool FunctionReflection_isOverloaded(slangc::FunctionReflection self) {
  auto *function = (slang::FunctionReflection *)self;
  return function->isOverloaded();
}

unsigned int
FunctionReflection_getOverloadCount(slangc::FunctionReflection self) {
  auto *function = (slang::FunctionReflection *)self;
  return function->getOverloadCount();
}

slangc::FunctionReflection
FunctionReflection_getOverload(slangc::FunctionReflection self,
                               unsigned int index) {
  auto *function = (slang::FunctionReflection *)self;
  return (slangc::FunctionReflection)function->getOverload(index);
}
}
