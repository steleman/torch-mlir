include(LLVMConfig)
include(MLIRConfig)
include(TableGen)
include(LLVMExports)
include(MLIRTargets)
include(AddLLVM)
include(AddMLIR)

add_subdirectory(CAPI)
add_subdirectory(Conversion)
add_subdirectory(Dialect)

set(LinkedLibs
  MLIRAffineDialect
  MLIRArithDialect
  MLIRBufferizationDialect
  MLIRControlFlowDialect
  MLIRComplexDialect
  MLIRFuncDialect
  MLIRFuncInlinerExtension
  MLIRIR
  MLIRCAPIIR
  MLIRDLTIDialect
  MLIRDLTITransformOps
  MLIRGPUDialect
  MLIRIndexDialect
  MLIRIRDL
  MLIRLinalgDialect
  MLIRLLVMDialect
  MLIRMathDialect
  MLIRMLProgramDialect
  MLIRMemRefDialect
  MLIRSCFDialect
  MLIRQuantDialect
  MLIRTensorDialect
  MLIRTensorInferTypeOpInterfaceImpl
  MLIRShapeDialect
  MLIRSparseTensorDialect
  MLIRTosaDialect
  MLIRSupport
  MLIRUBDialect
  MLIRVectorDialect
  MLIROpenACCDialect
  MLIROpenACCMPCommon
  MLIROpenACCToLLVMIRTranslation
  MLIROpenACCToSCF
  MLIROpenACCTransforms
  MLIROpenMPDialect
  MLIROpenMPToLLVM
  MLIROpenMPToLLVMIRTranslation
  MLIROptLib

  # Dialects.
  TorchMLIRTMTensorDialect
  TorchMLIRTorchDialect
  TorchMLIRTorchConversionDialect

  # Dialect passes.
  TorchMLIRTMTensorPasses
  TorchMLIRTorchConversionPasses
  TorchMLIRTorchPasses

  # Conversion passes.
  TorchMLIRConversionPasses
  TorchMLIRTorchOnnxToTorch
)

if(TORCH_MLIR_ENABLE_STABLEHLO)
  list(APPEND LinkedLibs StablehloLinalgTransforms StablehloPasses)
endif()

if(TORCH_MLIR_ENABLE_TOSA)
  list(APPEND LinkedLibs MLIRTosaDialect)
endif()

if(TORCH_MLIR_ENABLE_REFBACKEND)
  add_subdirectory(RefBackend)
  list(APPEND LinkedLibs TorchMLIRRefBackend)
endif()

add_mlir_library(TorchMLIRInitAll
  InitAll.cpp

  LINK_LIBS PUBLIC
  ${LinkedLibs}
)

torch_mlir_target_includes(TorchMLIRInitAll)
