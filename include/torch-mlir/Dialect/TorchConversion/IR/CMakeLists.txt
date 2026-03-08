set(LLVM_TARGET_DEFINITIONS TorchConversionOps.td)
mlir_tablegen(TorchConversionOps.h.inc -gen-op-decls)
mlir_tablegen(TorchConversionOps.cpp.inc -gen-op-defs)
# mlir_tablegen(TorchConversionOps.h.inc -gen-dialect-decls -dialect=torch)
# mlir_tablegen(TorchConversionOps.cpp.inc -gen-dialect-defs -dialect=torch)
add_public_tablegen_target(MLIRTorchConversionOpsIncGen)

# set(LLVM_TARGET_DEFINITIONS TorchConversionBase.td)
# mlir_tablegen(TorchConversionBase.h.inc -gen-op-decls)
# mlir_tablegen(TorchConversionBase.cpp.inc -gen-op-defs)
# mlir_tablegen(TorchConversionBase.h.inc -gen-dialect-decls -dialect=torch)
# mlir_tablegen(TorchConversionBase.cpp.inc -gen-dialect-defs -dialect=torch)
# add_public_tablegen_target(MLIRTorchConversionBaseIncGen)

set(LLVM_TARGET_DEFINITIONS TorchConversionDialect.td)
# mlir_tablegen(TorchConversionDialect.h.inc -gen-op-decls)
# mlir_tablegen(TorchConversionDialect.cpp.inc -gen-op-defs)
mlir_tablegen(TorchConversionDialect.h.inc -gen-dialect-decls -dialect=torch_conversion)
mlir_tablegen(TorchConversionDialect.cpp.inc -gen-dialect-defs -dialect=torch_conversion)
add_public_tablegen_target(MLIRTorchConversionDialectIncGen)

add_dependencies(mlir-headers MLIRTorchConversionOpsIncGen)
# add_dependencies(mlir-headers MLIRTorchConversionBaseIncGen)
add_dependencies(mlir-headers MLIRTorchConversionDialectIncGen)

add_mlir_doc(TorchConversionDialect TorchConversionDialect TorchConversion/ -gen-dialect-doc)
add_mlir_doc(TorchConversionOps TorchConversionOps TorchConversion/ -gen-op-doc)

