add_mlir_library(TorchMLIRTorchDialect
  TorchDialect.cpp
  TorchOps.cpp
  TorchOpsODSGenerated.cpp
  TorchTypes.cpp
  UtilsForODSGenerated.cpp

  ADDITIONAL_HEADER_DIRS
  ${PROJECT_SOURCE_DIR}/include/torch-mlir/Dialect/Torch

  DEPENDS
  MLIRTorchOpsIncGen
  MLIRTorchTypesIncGen
  TorchMLIRTorchUtils

  LINK_LIBS PUBLIC
  MLIRBytecodeOpInterface
  MLIRBytecodeReader
  MLIRBytecodeWriter
  MLIRFuncDialect
  MLIRIR
  MLIRSupport
  MLIRCastInterfaces
  MLIRControlFlowInterfaces
  MLIRInferTypeOpInterface
  MLIRSideEffectInterfaces
  TorchMLIRTorchUtils
)

torch_mlir_target_includes(TorchMLIRTorchDialect)
