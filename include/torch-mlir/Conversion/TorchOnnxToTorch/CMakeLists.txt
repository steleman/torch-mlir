set(LLVM_TARGET_DEFINITIONS Passes.td)
mlir_tablegen(Passes.h.inc -gen-pass-decls)
add_public_tablegen_target(TorchMLIRConversionTorchOnnxToTorchPassIncGen)

if (NOT TORCH_MLIR_OUT_OF_TREE_BUILD)
add_mlir_doc(Passes TorchMLIRConversionTorchOnnxToTorchPasses ./ -gen-pass-doc)
endif()

