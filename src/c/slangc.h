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

TypeParameterReflectionPtr
ProgramLayout_getTypeParameterByIndex(ProgramLayout layout, unsigned index);

TypeParameterReflectionPtr ProgramLayout_findTypeParameter(ProgramLayout layout,
                                                           const char *name);

VariableLayoutReflectionPtr
ProgramLayout_getParameterByIndex(ProgramLayout layout, unsigned index);

SlangUInt ProgramLayout_getEntryPointCount(ProgramLayout layout);

EntryPointReflectionPtr ProgramLayout_getEntryPointByIndex(ProgramLayout layout,
                                                           SlangUInt index);

SlangUInt ProgramLayout_getGlobalConstantBufferBinding(ProgramLayout layout);

size_t ProgramLayout_getGlobalConstantBufferSize(ProgramLayout layout);

TypeReflectionPtr ProgramLayout_findTypeByName(ProgramLayout layout,
                                               const char *name);

FunctionReflectionPtr ProgramLayout_findFunctionByName(ProgramLayout layout,
                                                       const char *name);

FunctionReflectionPtr ProgramLayout_findFunctionByNameInType(
    ProgramLayout layout, TypeReflectionPtr inType, const char *name);

VariableReflectionPtr
ProgramLayout_findVarByNameInType(ProgramLayout layout,
                                  TypeReflectionPtr inType, const char *name);

TypeLayoutReflectionPtr
ProgramLayout_getTypeLayout(ProgramLayout layout, TypeReflectionPtr inType,
                            SlangLayoutRulesIntegral layoutRules);

EntryPointReflectionPtr
ProgramLayout_findEntryPointReflectionByName(ProgramLayout layout,
                                             const char *name);

TypeReflectionPtr
ProgramLayout_specializeType(ProgramLayout layout, TypeReflectionPtr inType,
                             SlangInt specialiazationArgCount,
                             TypeReflectionPtr const *specialiazationArgs,
                             IBlob *outDiagnostics);

GenericReflectionPtr ProgramLayout_specializeGeneric(
    ProgramLayout layout, GenericReflectionPtr inGeneric,
    SlangInt specializationArgCount,
    enum GenericArgType const *inSpecialiazationArgTypes,
    union GenericArgReflection const *inSpecializationArgVals,
    IBlob *outDiagnostics);

bool ProgramLayout_isSubType(ProgramLayout layout, TypeReflectionPtr inSubType,
                             TypeReflectionPtr inSuperType);

SlangUInt ProgramLayout_getHashedStringCount(ProgramLayout layout);

const char *ProgramLayout_getHashedString(ProgramLayout layout, SlangUInt index,
                                          size_t *outCount);

TypeLayoutReflectionPtr
ProgramLayout_getGlobalParamsTypeLayout(ProgramLayout layout);

VariableLayoutReflectionPtr
ProgramLayout_getGlobalParamsVarLayout(ProgramLayout layout);

VariableReflectionPtr
VariableLayoutReflection_getVariable(VariableLayoutReflectionPtr layout);

char const *
VariableLayoutReflection_getName(VariableLayoutReflectionPtr layout);

Modifier
VariableLayoutReflection_findModifier(VariableLayoutReflectionPtr layout,
                                      ModifierIDIntegral id);

TypeLayoutReflectionPtr
VariableLayoutReflection_getTypeLayout(VariableLayoutReflectionPtr layout);

ParameterCategoryIntegral
VariableLayoutReflection_getCategory(VariableLayoutReflectionPtr layout);

unsigned int
VariableLayoutReflection_getCategoryCount(VariableLayoutReflectionPtr layout);

ParameterCategoryIntegral
VariableLayoutReflection_getCategoryByIndex(VariableLayoutReflectionPtr layout,
                                            unsigned int index);

size_t VariableLayoutReflection_getOffset(VariableLayoutReflectionPtr layout,
                                          ParameterCategoryIntegral category);

TypeReflectionPtr
VariableLayoutReflection_getType(VariableLayoutReflectionPtr layout);

unsigned
VariableLayoutReflection_getBindingIndex(VariableLayoutReflectionPtr layout);

unsigned
VariableLayoutReflection_getBindingSpace(VariableLayoutReflectionPtr layout);

size_t VariableLayoutReflection_getBindingSpaceByCategory(
    VariableLayoutReflectionPtr layout, ParameterCategoryIntegral category);

SlangImageFormatIntegral
VariableLayoutReflection_getImageFormat(VariableLayoutReflectionPtr layout);

char const *
VariableLayoutReflection_getSemanticName(VariableLayoutReflectionPtr layout);

size_t
VariableLayoutReflection_getSemanticIndex(VariableLayoutReflectionPtr layout);

SlangStageIntegral
VariableLayoutReflection_getSlangStage(VariableLayoutReflectionPtr layout);

SlangTypeKindIntegral TypeReflection_getKind(TypeReflectionPtr type);

unsigned int TypeReflection_getFieldCount(TypeReflectionPtr type);

VariableLayoutReflectionPtr
TypeReflection_getFieldByIndex(TypeReflectionPtr type, unsigned int index);

bool TypeReflection_isArray(TypeReflectionPtr type);

TypeReflectionPtr TypeReflection_unwrapArray(TypeReflectionPtr type);

size_t TypeReflection_getElementCount(TypeReflectionPtr type);

size_t TypeReflection_getTotalArrayElementCount(TypeReflectionPtr type);

TypeReflectionPtr TypeReflection_getElementType(TypeReflectionPtr type);

unsigned TypeReflection_getRowCount(TypeReflectionPtr type);

unsigned TypeReflection_getColumnCount(TypeReflectionPtr type);

SlangScalarTypeIntegral TypeReflection_getScalarType(TypeReflectionPtr type);

TypeReflectionPtr TypeReflection_getResourceResultType(TypeReflectionPtr type);

SlangResourceShapeIntegral
TypeReflection_getResourceShape(TypeReflectionPtr type);

SlangResourceAccessIntegral
TypeReflection_getResourceAccess(TypeReflectionPtr type);

char const *TypeReflection_getName(TypeReflectionPtr type);

unsigned int TypeReflection_getUserAttributeCount(TypeReflectionPtr type);

Attribute TypeReflection_getUserAttributeByIndex(TypeReflectionPtr type,
                                                 unsigned int index);

Attribute TypeReflection_findUserAttributeByName(TypeReflectionPtr type,
                                                 char const *name);

Attribute TypeReflection_findAttributeByName(TypeReflectionPtr type,
                                             char const *name);

GenericReflectionPtr
TypeReflection_getGenericCountainer(TypeReflectionPtr type);

char const *VariableReflection_getName(VariableReflectionPtr variable);

TypeReflectionPtr VariableReflection_getType(VariableReflectionPtr variable);

Modifier VariableReflection_findModifier(VariableReflectionPtr variable,
                                         ModifierIDIntegral id);

unsigned int
VariableReflection_getUserAttributeCount(VariableReflectionPtr variable);

Attribute
VariableReflection_getUserAttributeByIndex(VariableReflectionPtr variable,
                                           unsigned int index);

Attribute VariableReflection_findAttributeByName(VariableReflectionPtr variable,
                                                 IGlobalSession inSession,
                                                 char const *name);

Attribute VariableReflection_findUserAttributeByName(
    VariableReflectionPtr variable, IGlobalSession inSession, char const *name);

bool VariableReflection_hasDefaultValue(VariableReflectionPtr variable);

SlangResult VariableReflection_getDefaultValue(VariableReflectionPtr variable,
                                               int64_t *value);

GenericReflectionPtr
VariableReflection_getGenericContainer(VariableReflectionPtr variable);

VariableReflectionPtr
VariableReflection_applySpecializations(VariableReflectionPtr variable,
                                        GenericReflectionPtr inGeneric);

TypeReflectionPtr TypeLayoutReflection_getType(TypeLayoutReflectionPtr layout);

SlangTypeKindIntegral
TypeLayoutReflection_getKind(TypeLayoutReflectionPtr layout);

size_t TypeLayoutReflection_getSize(TypeLayoutReflectionPtr layout,
                                    ParameterCategoryIntegral category);

size_t TypeLayoutReflection_getStride(TypeLayoutReflectionPtr layout,
                                      ParameterCategoryIntegral category);

int32_t TypeLayoutReflection_getAlignment(TypeLayoutReflectionPtr layout,
                                          ParameterCategoryIntegral category);

unsigned int TypeLayoutReflection_getFieldCount(TypeLayoutReflectionPtr layout);

VariableLayoutReflectionPtr
TypeLayoutReflection_getFieldByIndex(TypeLayoutReflectionPtr layout,
                                     unsigned int index);

VariableLayoutReflectionPtr
TypeLayoutReflection_getExplicitCounter(TypeLayoutReflectionPtr layout);

bool TypeLayoutReflection_isArray(TypeLayoutReflectionPtr layout);

TypeLayoutReflectionPtr
TypeLayoutReflection_unwrapArray(TypeLayoutReflectionPtr layout);

size_t TypeLayoutReflection_getElementCount(TypeLayoutReflectionPtr layout,
                                            ShaderReflectionPtr reflection);

size_t
TypeLayoutReflection_getTotalElementCount(TypeLayoutReflectionPtr layout);

size_t TypeLayoutReflection_getElementStride(TypeLayoutReflectionPtr layout,
                                             enum ParameterCategory category);

TypeLayoutReflectionPtr
TypeLayoutReflection_getElementTypeLayout(TypeLayoutReflectionPtr layout);

VariableLayoutReflectionPtr
TypeLayoutReflection_getElementVarLayout(TypeLayoutReflectionPtr layout);

VariableLayoutReflectionPtr
TypeLayoutReflection_getContainerVarLayout(TypeLayoutReflectionPtr layout);

enum ParameterCategory
TypeLayoutReflection_getParameterCategory(TypeLayoutReflectionPtr layout);

unsigned int
TypeLayoutReflection_getCategoryCount(TypeLayoutReflectionPtr layout);

enum ParameterCategory
TypeLayoutReflection_getCategoryByIndex(TypeLayoutReflectionPtr layout,
                                        unsigned int index);

unsigned TypeLayoutReflection_getRowCount(TypeLayoutReflectionPtr layout);

unsigned TypeLayoutReflection_getColumnCount(TypeLayoutReflectionPtr layout);

enum SlangScalarType
TypeLayoutReflection_getScalarType(TypeLayoutReflectionPtr layout);

TypeReflectionPtr
TypeLayoutReflection_getResourceResultType(TypeLayoutReflectionPtr layout);

enum SlangResourceShape
TypeLayoutReflection_getResourceShape(TypeLayoutReflectionPtr layout);

enum SlangResourceAccess
TypeLayoutReflection_getResourceAccess(TypeLayoutReflectionPtr layout);

char const *TypeLayoutReflection_getName(TypeLayoutReflectionPtr layout);

enum SlangMatrixLayoutMode
TypeLayoutReflection_getMatrixLayoutMode(TypeLayoutReflectionPtr layout);

int TypeLayoutReflection_getGenericParamIndex(TypeLayoutReflectionPtr layout);

SlangInt
TypeLayoutReflection_getBindingRangeCount(TypeLayoutReflectionPtr layout);

enum SlangBindingType
TypeLayoutReflection_getBindingRangeType(TypeLayoutReflectionPtr layout,
                                         SlangInt index);

bool TypeLayoutReflection_isBindingRangeSpecializable(
    TypeLayoutReflectionPtr layout, SlangInt index);

SlangInt
TypeLayoutReflection_getBindingRangeBindingCount(TypeLayoutReflectionPtr layout,
                                                 SlangInt index);

SlangInt
TypeLayoutReflection_getFieldBindingRangeOffset(TypeLayoutReflectionPtr layout,
                                                SlangInt index);

SlangInt TypeLayoutReflection_getExplicitCounterBindingRangeOffset(
    TypeLayoutReflectionPtr layout);

TypeLayoutReflectionPtr TypeLayoutReflection_getBindingRangeLeafTypeLayout(
    TypeLayoutReflectionPtr layout, SlangInt index);

SlangImageFormatIntegral
TypeLayoutReflection_getBindingRangeImageFormat(TypeLayoutReflectionPtr layout,
                                                SlangInt index);

SlangInt TypeLayoutReflection_getBindingRangeDescriptorSetIndex(
    TypeLayoutReflectionPtr layout, SlangInt index);

SlangInt TypeLayoutReflection_getBindingRangeFirstDescriptorRangeIndex(
    TypeLayoutReflectionPtr layout, SlangInt index);

SlangInt TypeLayoutReflection_getBindingRangeDescriptorRangeCount(
    TypeLayoutReflectionPtr layout, SlangInt index);

SlangInt
TypeLayoutReflection_getDescriptorSetCount(TypeLayoutReflectionPtr layout);

SlangInt
TypeLayoutReflection_getDescriptorSetSpaceOffset(TypeLayoutReflectionPtr layout,
                                                 SlangInt setIndex);

SlangInt TypeLayoutReflection_getDescriptorSetDescriptorRangeCount(
    TypeLayoutReflectionPtr layout, SlangInt setIndex);

SlangInt TypeLayoutReflection_getDescriptorSetDescriptorRangeIndexOffset(
    TypeLayoutReflectionPtr layout, SlangInt setIndex, SlangInt rangeIndex);

SlangInt TypeLayoutReflection_getDescriptorSetDescriptorRangeDescriptorCount(
    TypeLayoutReflectionPtr layout, SlangInt setIndex, SlangInt rangeIndex);

enum SlangBindingType TypeLayoutReflection_getDescriptorSetDescriptorRangeType(
    TypeLayoutReflectionPtr layout, SlangInt setIndex, SlangInt rangeIndex);

enum ParameterCategory
TypeLayoutReflection_getDescriptorSetDescriptorRangeCategory(
    TypeLayoutReflectionPtr layout, SlangInt setIndex, SlangInt rangeIndex);

SlangInt
TypeLayoutReflection_getSubObjectRangeCount(TypeLayoutReflectionPtr layout);

SlangInt TypeLayoutReflection_getSubObjectRangeBindingRangeIndex(
    TypeLayoutReflectionPtr layout, SlangInt subObjectRangeIndex);

SlangInt TypeLayoutReflection_getSubObjectRangeSpaceOffset(
    TypeLayoutReflectionPtr layout, SlangInt subObjectRangeIndex);

VariableLayoutReflectionPtr
TypeLayoutReflection_getSubObjectRangeOffset(TypeLayoutReflectionPtr layout,
                                             SlangInt subObjectRangeIndex);

char const *EntryPointReflection_getName(EntryPointReflectionPtr self);

char const *EntryPointReflection_getNameOverride(EntryPointReflectionPtr self);

unsigned EntryPointReflection_getParameterCount(EntryPointReflectionPtr self);

FunctionReflectionPtr
EntryPointReflection_getFunction(EntryPointReflectionPtr self);

VariableLayoutReflectionPtr
EntryPointReflection_getParameterByIndex(EntryPointReflectionPtr self,
                                         unsigned index);

SlangStageIntegral EntryPointReflection_getStage(EntryPointReflectionPtr self);

void EntryPointReflection_getComputeThreadGroupSize(
    EntryPointReflectionPtr self, SlangUInt axisCount,
    SlangUInt *outSizeAlongAxis);

void EntryPointReflection_getComputeWaveSize(EntryPointReflectionPtr self,
                                             SlangUInt *outWaveSize);

bool EntryPointReflection_usesAnySampleRateInput(EntryPointReflectionPtr self);

VariableLayoutReflectionPtr
EntryPointReflection_getVarLayout(EntryPointReflectionPtr self);

TypeLayoutReflectionPtr
EntryPointReflection_getTypeLayout(EntryPointReflectionPtr self);

VariableLayoutReflectionPtr
EntryPointReflection_getResultVarLayout(EntryPointReflectionPtr self);

bool EntryPointReflection_hasDefaultConstantBuffer(
    EntryPointReflectionPtr self);

char const *TypeParameterReflection_getName(TypeParameterReflectionPtr self);

unsigned TypeParameterReflection_getIndex(TypeParameterReflectionPtr self);

unsigned
TypeParameterReflection_getConstraintCount(TypeParameterReflectionPtr self);

TypeReflectionPtr
TypeParameterReflection_getConstraintByIndex(TypeParameterReflectionPtr self,
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

TypeReflectionPtr AttributeReflection_getArgumentType(Attribute self,
                                                      uint32_t index);

SlangResult AttributeReflection_getArgumentValueInt(Attribute self,
                                                    uint32_t index, int *value);

SlangResult AttributeReflection_getArgumentValueFloat(Attribute self,
                                                      uint32_t index,
                                                      float *value);

const char *AttributeReflection_getArgumentValueString(Attribute self,
                                                       uint32_t index,
                                                       size_t *outSize);

const char *FunctionReflection_getName(FunctionReflectionPtr self);

TypeReflectionPtr FunctionReflection_getReturnType(FunctionReflectionPtr self);

unsigned int FunctionReflection_getParameterCount(FunctionReflectionPtr self);

VariableReflectionPtr
FunctionReflection_getParameterByIndex(FunctionReflectionPtr self,
                                       unsigned int index);

unsigned int
FunctionReflection_getUserAttributeCount(FunctionReflectionPtr self);

Attribute FunctionReflection_getUserAttributeByIndex(FunctionReflectionPtr self,
                                                     unsigned int index);

Attribute FunctionReflection_findAttributeByName(FunctionReflectionPtr self,
                                                 IGlobalSession inSession,
                                                 char const *name);

Attribute FunctionReflection_findUserAttributeByName(FunctionReflectionPtr self,
                                                     IGlobalSession inSession,
                                                     char const *name);

Modifier FunctionReflection_findModifier(FunctionReflectionPtr self,
                                         ModifierIDIntegral id);

GenericReflectionPtr
FunctionReflection_getGenericContainer(FunctionReflectionPtr self);

FunctionReflectionPtr
FunctionReflection_applySpecializations(FunctionReflectionPtr self,
                                        GenericReflectionPtr inGeneric);

FunctionReflectionPtr
FunctionReflection_specializeWithArgTypes(FunctionReflectionPtr self,
                                          unsigned int argCount,
                                          TypeReflectionPtr const *inTypes);

bool FunctionReflection_isOverloaded(FunctionReflectionPtr self);

unsigned int FunctionReflection_getOverloadCount(FunctionReflectionPtr self);

FunctionReflectionPtr FunctionReflection_getOverload(FunctionReflectionPtr self,
                                                     unsigned int index);

SlangResult release(Unknown self);
