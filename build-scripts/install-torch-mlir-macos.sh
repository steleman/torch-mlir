#!/bin/bash

llvm_version="21.1.4"
llvm_root="/opt/llvm/${llvm_version}"
here="`pwd`"
topdir="`dirname ${here}`"
srcdir="${topdir}/torch-mlir"
builddir="${here}"
stablehlo_libdir="${here}/lib64"
torch_mlir_bindir="${here}/bin"
destdir="${topdir}/install-torch-mlir"
target_libdir="${destdir}/opt/llvm/${llvm_version}/lib"
target_bindir="${destdir}/opt/llvm/${llvm_version}/bin"
target_pythondir="${destdir}/opt/llvm/${llvm_version}/python_packages"
llvmdir="/opt/llvm/${llvm_version}"
outfile="${here}/torch-mlir-install.out"
cret=0
distro="`uname -s`"

if [ "${distro}" != "Darwin" ] ; then
  echo "This cmake configure script only works on Apple MacOS (Darwin)."
  exit 1
fi

if [ -e /opt/homebrew/bin/brew ] ; then
  /opt/homebrew/bin/brew shellenv >& /tmp/brewshellenv.$$
  source /tmp/brewshellenv.$$
  rm -f /tmp/brewshellenv.$$
fi

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:${here}/bin"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:${PATH}"
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:${PATH}"
export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:${PATH}"
export PATH="/opt/homebrew/opt/diffutils/libexec/gnubin:${PATH}"
export GMAKE="/opt/homebrew/bin/gmake"
export MAKE="${GMAKE}"
export GMAKE="${GMAKE}"
export CMAKE="/opt/homebrew/opt/cmake/bin/cmake"
build_type="Release"

pytorch_version="2.7.1"
export PYTORCH="/opt/pytorch/${pytorch_version}"
llvm_dir="${llvmdir}/lib/cmake/llvm"
mlir_dir="${llvmdir}/lib/cmake/mlir"
mlir_tblgen="${llvmdir}/bin/mlir-tblgen"
mlir_dll_tblgen="${llvmdir}/lib/libMLIRTableGen.a"
pytorch_incdir="${PYTORCH}/include"
pytorch_libdir="${PYTORCH}/lib"

export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"
export CFLAGS="-Wall -Wextra"
export CXXFLAGS="-Wall -Wextra"
export CPPFLAGS=""
export CMAKE_FLAGS=""
export TORCH_INSTALL_PREFIX="${PYTORCH}"
export USE_CUDNN=0
export USE_CUSPARSELT=0
export USE_CUFILE=0
export USE_PROTOBUF_SHARED_LIBS=1

if [ ! -d ${destdir} ] ; then
  mkdir -p ${destdir}
fi

${CC} --version
${CXX} --version

cat /dev/null > ${outfile}

echo "gmake DESTDIR=${destdir} install >> ${outfile} 2>&1"
gmake DESTDIR=${destdir} install >> ${outfile} 2>&1

for file in \
  libChloOps.dylib \
  libInterpreterOps.dylib \
  libStablehloAssemblyFormat.dylib \
  libStablehloBase.dylib \
  libStablehloBroadcastUtils.dylib \
  libStablehloCAPI.dylib \
  libStablehloLinalgTransforms.dylib \
  libStablehloOps.dylib \
  libStablehloOptimizationPasses.dylib \
  libStablehloPassUtils.dylib \
  libStablehloPasses.dylib \
  libStablehloPortableApi.dylib \
  libStablehloReferenceApi.dylib \
  libStablehloReferenceAxes.dylib \
  libStablehloReferenceConfiguration.dylib \
  libStablehloReferenceElement.dylib \
  libStablehloReferenceErrors.dylib \
  libStablehloReferenceIndex.dylib \
  libStablehloReferenceNumPy.dylib \
  libStablehloReferenceOps.dylib \
  libStablehloReferenceProcess.dylib \
  libStablehloReferenceProcessGrid.dylib \
  libStablehloReferenceScope.dylib \
  libStablehloReferenceTensor.dylib \
  libStablehloReferenceToken.dylib \
  libStablehloReferenceTypes.dylib \
  libStablehloReferenceValue.dylib \
  libStablehloRegister.dylib \
  libStablehloSerialization.dylib \
  libStablehloTypeConversion.dylib \
  libStablehloTypeInference.dylib \
  libTorchMLIRCAPI.dylib \
  libTorchMLIRConversionPasses.dylib \
  libTorchMLIRConversionUtils.dylib \
  libTorchMLIRInitAll.dylib \
  libTorchMLIRRefBackend.dylib \
  libTorchMLIRTMTensorDialect.dylib \
  libTorchMLIRTMTensorPasses.dylib \
  libTorchMLIRTorchConversionDialect.dylib \
  libTorchMLIRTorchConversionPasses.dylib \
  libTorchMLIRTorchConversionToMLProgram.dylib \
  libTorchMLIRTorchDialect.dylib \
  libTorchMLIRTorchOnnxToTorch.dylib \
  libTorchMLIRTorchPasses.dylib \
  libTorchMLIRTorchToArith.dylib \
  libTorchMLIRTorchToLinalg.dylib \
  libTorchMLIRTorchToSCF.dylib \
  libTorchMLIRTorchToStablehlo.dylib \
  libTorchMLIRTorchToTMTensor.dylib \
  libTorchMLIRTorchToTensor.dylib \
  libTorchMLIRTorchToTosa.dylib \
  libTorchMLIRTorchUtils.dylib \
  libVersion.dylib \
  libVhloOps.dylib \
  libVhloTypes.dylib
do
  echo "cp -fp ${stablehlo_libdir}/${file} ${target_libdir}/"
  cp -fp "${stablehlo_libdir}/${file}" "${target_libdir}/"
done

for file in \
  mlir_builder_tblgen \
  torch-mlir-capi-torch-test \
  torch-mlir-lsp-server \
  torch-mlir-opt \
  torch-mlir-import-onnx
do
  echo "cp -fp ${torch_mlir_bindir}/${file} ${target_bindir}/"
  cp -fp "${torch_mlir_bindir}/${file}" "${target_bindir}/"
done

echo "cp -frpd ${here}/python_packages/torch_mlir/torch_mlir/base_lazy_backend ${target_pythondir}/torch_mlir/"
cp -frpd ${here}/python_packages/torch_mlir/torch_mlir/base_lazy_backend ${target_pythondir}/torch_mlir/

cd ${here}

echo "Done."

