#pragma once
#include "slangc_types.h"

typedef int32_t SlangResult;

SlangResult createGlobalSession(IGlobalSession *outGlobalSession);

SlangResult createSession(IGlobalSession inGlobalSession,
                          const struct SessionDesc *inSessionDesc,
                          ISession *outSession);

SlangProfileIDIntegral findProfile(IGlobalSession inGlobalSession,
                                   const char *profile);

SlangResult loadModuleFromSourceString(ISession inSession,
                                       const char *sourceBuffer,
                                       IModule *outModule,
                                       IBlob *outDiagnostics);

SlangResult findEntryPointByName(IModule inModule, char const *name,
                                 IEntryPoint *inEntryPoint);

SlangResult createCompositeComponent(ISession inSession,
                                     const IComponentType *inComponentTypes,
                                     SlangInt componentTypeCount,
                                     IComponentType *outComposite,
                                     IBlob *outDiagnostics);

SlangResult linkProgram(IComponentType inCompiledProgram,
                        IComponentType *outLinkedProgram,
                        IBlob *outDiagnostics);

SlangResult getLayout(IComponentType inProgram, SlangInt targetIndex,
                      ProgramLayout *outLayout, IBlob *outDiagnostics);

SlangResult getTargetCode(IComponentType linkedProgram, IBlob *outOutput,
                          IBlob *outDiagnostics);

SlangResult getBlobSlice(IBlob inBlob, const void **pointer, size_t *size);

unsigned ProgramLayout_getParameterCount(ProgramLayout layout);

unsigned ProgramLayout_getTypeParameterCount(ProgramLayout layout);

TypeParameterReflection
ProgramLayout_getTypeParameterByIndex(ProgramLayout layout, unsigned index);

TypeParameterReflection ProgramLayout_findTypeParameter(ProgramLayout layout,
                                                        const char *name);

VariableLayoutReflection ProgramLayout_getParameterByIndex(ProgramLayout layout,
                                                           unsigned index);

SlangUInt ProgramLayout_getEntryPointCount(ProgramLayout layout);

EntryPointReflection ProgramLayout_getEntryPointByIndex(ProgramLayout layout,
                                                        SlangUInt index);

SlangUInt ProgramLayout_getGlobalConstantBufferBinding(ProgramLayout layout);

size_t ProgramLayout_getGlobalConstantBufferSize(ProgramLayout layout);

TypeReflection ProgramLayout_findTypeByName(ProgramLayout layout,
                                            const char *name);

FunctionReflection ProgramLayout_findFunctionByName(ProgramLayout layout,
                                                    const char *name);

FunctionReflection ProgramLayout_findFunctionByNameInType(ProgramLayout layout,
                                                          TypeReflection inType,
                                                          const char *name);

VariableReflection ProgramLayout_findVarByNameInType(ProgramLayout layout,
                                                     TypeReflection inType,
                                                     const char *name);

TypeLayoutReflection
ProgramLayout_getTypeLayout(ProgramLayout layout, TypeReflection inType,
                            SlangLayoutRulesIntegral layoutRules);

EntryPointReflection
ProgramLayout_findEntryPointReflectionByName(ProgramLayout layout,
                                             const char *name);

TypeReflection
ProgramLayout_specializeType(ProgramLayout layout, TypeReflection inType,
                             SlangInt specialiazationArgCount,
                             TypeReflection const *specialiazationArgs,
                             IBlob *outDiagnostics);

GenericReflection ProgramLayout_specializeGeneric(
    ProgramLayout layout, GenericReflection inGeneric,
    SlangInt specializationArgCount,
    enum GenericArgType const *inSpecialiazationArgTypes,
    union GenericArgReflection const *inSpecializationArgVals,
    IBlob *outDiagnostics);

bool ProgramLayout_isSubType(ProgramLayout layout, TypeReflection inSubType,
                             TypeReflection inSuperType);

SlangUInt ProgramLayout_getHashedStringCount(ProgramLayout layout);

const char *ProgramLayout_getHashedString(ProgramLayout layout, SlangUInt index,
                                          size_t *outCount);

TypeLayoutReflection
ProgramLayout_getGlobalParamsTypeLayout(ProgramLayout layout);

VariableLayoutReflection
ProgramLayout_getGlobalParamsVarLayout(ProgramLayout layout);

VariableReflection
VariableLayoutReflection_getVariable(VariableLayoutReflection layout);

char const *VariableLayoutReflection_getName(VariableLayoutReflection layout);

Modifier VariableLayoutReflection_findModifier(VariableLayoutReflection layout,
                                               ModifierIDIntegral id);

TypeLayoutReflection
VariableLayoutReflection_getTypeLayout(VariableLayoutReflection layout);

ParameterCategoryIntegral
VariableLayoutReflection_getCategory(VariableLayoutReflection layout);

unsigned int
VariableLayoutReflection_getCategoryCount(VariableLayoutReflection layout);

ParameterCategoryIntegral
VariableLayoutReflection_getCategoryByIndex(VariableLayoutReflection layout,
                                            unsigned int index);

size_t VariableLayoutReflection_getOffset(VariableLayoutReflection layout,
                                          ParameterCategoryIntegral category);

TypeReflection
VariableLayoutReflection_getType(VariableLayoutReflection layout);

unsigned
VariableLayoutReflection_getBindingIndex(VariableLayoutReflection layout);

unsigned
VariableLayoutReflection_getBindingSpace(VariableLayoutReflection layout);

size_t VariableLayoutReflection_getBindingSpaceByCategory(
    VariableLayoutReflection layout, ParameterCategoryIntegral category);

SlangImageFormatIntegral
VariableLayoutReflection_getImageFormat(VariableLayoutReflection layout);

char const *
VariableLayoutReflection_getSemanticName(VariableLayoutReflection layout);

size_t
VariableLayoutReflection_getSemanticIndex(VariableLayoutReflection layout);

SlangStageIntegral
VariableLayoutReflection_getSlangStage(VariableLayoutReflection layout);

SlangTypeKindIntegral TypeReflection_getKind(TypeReflection type);

unsigned int TypeReflection_getFieldCount(TypeReflection type);

VariableLayoutReflection TypeReflection_getFieldByIndex(TypeReflection type,
                                                        unsigned int index);

bool TypeReflection_isArray(TypeReflection type);

TypeReflection TypeReflection_unwrapArray(TypeReflection type);

size_t TypeReflection_getElementCount(TypeReflection type);

size_t TypeReflection_getTotalArrayElementCount(TypeReflection type);

TypeReflection TypeReflection_getElementType(TypeReflection type);

unsigned TypeReflection_getRowCount(TypeReflection type);

unsigned TypeReflection_getColumnCount(TypeReflection type);

SlangScalarTypeIntegral TypeReflection_getScalarType(TypeReflection type);

TypeReflection TypeReflection_getResourceResultType(TypeReflection type);

SlangResourceShapeIntegral TypeReflection_getResourceShape(TypeReflection type);

SlangResourceAccessIntegral
TypeReflection_getResourceAccess(TypeReflection type);

char const *TypeReflection_getName(TypeReflection type);

unsigned int TypeReflection_getUserAttributeCount(TypeReflection type);

Attribute TypeReflection_getUserAttributeByIndex(TypeReflection type,
                                                 unsigned int index);

Attribute TypeReflection_findUserAttributeByName(TypeReflection type,
                                                 char const *name);

Attribute TypeReflection_findAttributeByName(TypeReflection type,
                                             char const *name);

GenericReflection TypeReflection_getGenericCountainer(TypeReflection type);

char const *VariableReflection_getName(VariableReflection variable);

TypeReflection VariableReflection_getType(VariableReflection variable);

Modifier VariableReflection_findModifier(VariableReflection variable,
                                         ModifierIDIntegral id);

unsigned int
VariableReflection_getUserAttributeCount(VariableReflection variable);

Attribute
VariableReflection_getUserAttributeByIndex(VariableReflection variable,
                                           unsigned int index);

Attribute VariableReflection_findAttributeByName(VariableReflection variable,
                                                 IGlobalSession inSession,
                                                 char const *name);

Attribute VariableReflection_findUserAttributeByName(
    VariableReflection variable, IGlobalSession inSession, char const *name);

bool VariableReflection_hasDefaultValue(VariableReflection variable);

SlangResult VariableReflection_getDefaultValue(VariableReflection variable,
                                               int64_t *value);

GenericReflection
VariableReflection_getGenericContainer(VariableReflection variable);

VariableReflection
VariableReflection_applySpecializations(VariableReflection variable,
                                        GenericReflection inGeneric);

TypeReflection TypeLayoutReflection_getType(TypeLayoutReflection layout);

SlangTypeKindIntegral TypeLayoutReflection_getKind(TypeLayoutReflection layout);

size_t TypeLayoutReflection_getSize(TypeLayoutReflection layout,
                                    ParameterCategoryIntegral category);

size_t TypeLayoutReflection_getStride(TypeLayoutReflection layout,
                                      ParameterCategoryIntegral category);

int32_t TypeLayoutReflection_getAlignment(TypeLayoutReflection layout,
                                          ParameterCategoryIntegral category);

unsigned int TypeLayoutReflection_getFieldCount(TypeLayoutReflection layout);

VariableLayoutReflection
TypeLayoutReflection_getFieldByIndex(TypeLayoutReflection layout,
                                     unsigned int index);

VariableLayoutReflection
TypeLayoutReflection_getExplicitCounter(TypeLayoutReflection layout);

bool TypeLayoutReflection_isArray(TypeLayoutReflection layout);

TypeLayoutReflection
TypeLayoutReflection_unwrapArray(TypeLayoutReflection layout);

size_t TypeLayoutReflection_getElementCount(TypeLayoutReflection layout,
                                            ShaderReflection reflection);

size_t TypeLayoutReflection_getTotalElementCount(TypeLayoutReflection layout);

size_t TypeLayoutReflection_getElementStride(TypeLayoutReflection layout,
                                             enum ParameterCategory category);

TypeLayoutReflection
TypeLayoutReflection_getElementTypeLayout(TypeLayoutReflection layout);

VariableLayoutReflection
TypeLayoutReflection_getElementVarLayout(TypeLayoutReflection layout);

VariableLayoutReflection
TypeLayoutReflection_getContainerVarLayout(TypeLayoutReflection layout);

enum ParameterCategory
TypeLayoutReflection_getParameterCategory(TypeLayoutReflection layout);

unsigned int TypeLayoutReflection_getCategoryCount(TypeLayoutReflection layout);

enum ParameterCategory
TypeLayoutReflection_getCategoryByIndex(TypeLayoutReflection layout,
                                        unsigned int index);

unsigned TypeLayoutReflection_getRowCount(TypeLayoutReflection layout);

unsigned TypeLayoutReflection_getColumnCount(TypeLayoutReflection layout);

enum SlangScalarType
TypeLayoutReflection_getScalarType(TypeLayoutReflection layout);

TypeReflection
TypeLayoutReflection_getResourceResultType(TypeLayoutReflection layout);

enum SlangResourceShape
TypeLayoutReflection_getResourceShape(TypeLayoutReflection layout);

enum SlangResourceAccess
TypeLayoutReflection_getResourceAccess(TypeLayoutReflection layout);

char const *TypeLayoutReflection_getName(TypeLayoutReflection layout);

enum SlangMatrixLayoutMode
TypeLayoutReflection_getMatrixLayoutMode(TypeLayoutReflection layout);

int TypeLayoutReflection_getGenericParamIndex(TypeLayoutReflection layout);

SlangInt TypeLayoutReflection_getBindingRangeCount(TypeLayoutReflection layout);

enum SlangBindingType
TypeLayoutReflection_getBindingRangeType(TypeLayoutReflection layout,
                                         SlangInt index);

bool TypeLayoutReflection_isBindingRangeSpecializable(
    TypeLayoutReflection layout, SlangInt index);

SlangInt
TypeLayoutReflection_getBindingRangeBindingCount(TypeLayoutReflection layout,
                                                 SlangInt index);

SlangInt
TypeLayoutReflection_getFieldBindingRangeOffset(TypeLayoutReflection layout,
                                                SlangInt index);

SlangInt TypeLayoutReflection_getExplicitCounterBindingRangeOffset(
    TypeLayoutReflection layout);

TypeLayoutReflection
TypeLayoutReflection_getBindingRangeLeafTypeLayout(TypeLayoutReflection layout,
                                                   SlangInt index);

SlangImageFormatIntegral
TypeLayoutReflection_getBindingRangeImageFormat(TypeLayoutReflection layout,
                                                SlangInt index);

SlangInt TypeLayoutReflection_getBindingRangeDescriptorSetIndex(
    TypeLayoutReflection layout, SlangInt index);

SlangInt TypeLayoutReflection_getBindingRangeFirstDescriptorRangeIndex(
    TypeLayoutReflection layout, SlangInt index);

SlangInt TypeLayoutReflection_getBindingRangeDescriptorRangeCount(
    TypeLayoutReflection layout, SlangInt index);

SlangInt
TypeLayoutReflection_getDescriptorSetCount(TypeLayoutReflection layout);

SlangInt
TypeLayoutReflection_getDescriptorSetSpaceOffset(TypeLayoutReflection layout,
                                                 SlangInt setIndex);

SlangInt TypeLayoutReflection_getDescriptorSetDescriptorRangeCount(
    TypeLayoutReflection layout, SlangInt setIndex);

SlangInt TypeLayoutReflection_getDescriptorSetDescriptorRangeIndexOffset(
    TypeLayoutReflection layout, SlangInt setIndex, SlangInt rangeIndex);

SlangInt TypeLayoutReflection_getDescriptorSetDescriptorRangeDescriptorCount(
    TypeLayoutReflection layout, SlangInt setIndex, SlangInt rangeIndex);

enum SlangBindingType TypeLayoutReflection_getDescriptorSetDescriptorRangeType(
    TypeLayoutReflection layout, SlangInt setIndex, SlangInt rangeIndex);

enum ParameterCategory
TypeLayoutReflection_getDescriptorSetDescriptorRangeCategory(
    TypeLayoutReflection layout, SlangInt setIndex, SlangInt rangeIndex);

SlangInt
TypeLayoutReflection_getSubObjectRangeCount(TypeLayoutReflection layout);

SlangInt TypeLayoutReflection_getSubObjectRangeBindingRangeIndex(
    TypeLayoutReflection layout, SlangInt subObjectRangeIndex);

SlangInt
TypeLayoutReflection_getSubObjectRangeSpaceOffset(TypeLayoutReflection layout,
                                                  SlangInt subObjectRangeIndex);

VariableLayoutReflection
TypeLayoutReflection_getSubObjectRangeOffset(TypeLayoutReflection layout,
                                             SlangInt subObjectRangeIndex);

char const *EntryPointReflection_getName(EntryPointReflection self);

char const *EntryPointReflection_getNameOverride(EntryPointReflection self);

unsigned EntryPointReflection_getParameterCount(EntryPointReflection self);

FunctionReflection EntryPointReflection_getFunction(EntryPointReflection self);

VariableLayoutReflection
EntryPointReflection_getParameterByIndex(EntryPointReflection self,
                                         unsigned index);

SlangStageIntegral EntryPointReflection_getStage(EntryPointReflection self);

void EntryPointReflection_getComputeThreadGroupSize(
    EntryPointReflection self, SlangUInt axisCount,
    SlangUInt *outSizeAlongAxis);

void EntryPointReflection_getComputeWaveSize(EntryPointReflection self,
                                             SlangUInt *outWaveSize);

bool EntryPointReflection_usesAnySampleRateInput(EntryPointReflection self);

VariableLayoutReflection
EntryPointReflection_getVarLayout(EntryPointReflection self);

TypeLayoutReflection
EntryPointReflection_getTypeLayout(EntryPointReflection self);

VariableLayoutReflection
EntryPointReflection_getResultVarLayout(EntryPointReflection self);

bool EntryPointReflection_hasDefaultConstantBuffer(EntryPointReflection self);

char const *TypeParameterReflection_getName(TypeParameterReflection self);

unsigned TypeParameterReflection_getIndex(TypeParameterReflection self);

unsigned
TypeParameterReflection_getConstraintCount(TypeParameterReflection self);

TypeReflection
TypeParameterReflection_getConstraintByIndex(TypeParameterReflection self,
                                             unsigned index);

SlangResult IComponentType_getEntryPointMetadata(IComponentType componentType,
                                                 size_t entryPointIndex,
                                                 size_t targetIndex,
                                                 IMetadata *outMetadata,
                                                 IBlob *outDiagnostics);

SlangResult IMetadata_isParameterLocationUsed(IMetadata inMetadata,
                                              enum ParameterCategory category,
                                              SlangUInt spaceInt,
                                              SlangUInt registerInt,
                                              bool *outUsed);

char const *AttributeReflection_getName(Attribute self);

uint32_t AttributeReflection_getArgumentCount(Attribute self);

TypeReflection AttributeReflection_getArgumentType(Attribute self,
                                                   uint32_t index);

SlangResult AttributeReflection_getArgumentValueInt(Attribute self,
                                                    uint32_t index, int *value);

SlangResult AttributeReflection_getArgumentValueFloat(Attribute self,
                                                      uint32_t index,
                                                      float *value);

const char *AttributeReflection_getArgumentValueString(Attribute self,
                                                       uint32_t index,
                                                       size_t *outSize);

const char *FunctionReflection_getName(FunctionReflection self);

TypeReflection FunctionReflection_getReturnType(FunctionReflection self);

unsigned int FunctionReflection_getParameterCount(FunctionReflection self);

VariableReflection
FunctionReflection_getParameterByIndex(FunctionReflection self,
                                       unsigned int index);

unsigned int FunctionReflection_getUserAttributeCount(FunctionReflection self);

Attribute FunctionReflection_getUserAttributeByIndex(FunctionReflection self,
                                                     unsigned int index);

Attribute FunctionReflection_findAttributeByName(FunctionReflection self,
                                                 IGlobalSession inSession,
                                                 char const *name);

Attribute FunctionReflection_findUserAttributeByName(FunctionReflection self,
                                                     IGlobalSession inSession,
                                                     char const *name);

Modifier FunctionReflection_findModifier(FunctionReflection self,
                                         ModifierIDIntegral id);

GenericReflection
FunctionReflection_getGenericContainer(FunctionReflection self);

FunctionReflection
FunctionReflection_applySpecializations(FunctionReflection self,
                                        GenericReflection inGeneric);

FunctionReflection
FunctionReflection_specializeWithArgTypes(FunctionReflection self,
                                          unsigned int argCount,
                                          TypeReflection const *inTypes);

bool FunctionReflection_isOverloaded(FunctionReflection self);

unsigned int FunctionReflection_getOverloadCount(FunctionReflection self);

FunctionReflection FunctionReflection_getOverload(FunctionReflection self,
                                                  unsigned int index);
