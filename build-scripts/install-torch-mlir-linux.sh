#!/bin/bash

llvm_version="21.1.8"
cuda_version="12.9"
rocm_version="6.4.3"
pytorch_version="2.7.1"

here="`pwd`"
topdir="`dirname ${here}`"
srcdir="${topdir}/torch-mlir"
destdir="${topdir}/install-torch-mlir"
builddir="${here}"
llvmdir="/opt/llvm/${llvm_version}"
llvmbindir="${llvmdir}/bin"
llvmlibdir="${llvmdir}/lib64"
llvmincdir="${llvmdir}/include"
pytorchdir="/opt/pytorch/${pytorch_version}"
pytorchbindir="${pytorchdir}/bin"
pytorchlibdir="${pytorchdir}/lib64"
runpath="${llvmlibdir}:${pytorchlibdir}:"
herebindir="${here}/bin"
outfile="${here}/torch-mlir-install.out"
cret=0
distro="`uname -s`"

if [ "${distro}" != "Linux" ] ; then
  echo "This cmake configure script only works on Linux."
  exit 1
fi

export CUDA="/usr/local/cuda-${cuda_version}"
export ROCM="/opt/rocm-${rocm_version}"
export PYTORCH="/opt/pytorch/${pytorch_version}"
llvm_dir="${llvmdir}/lib64/cmake/llvm"
mlir_dir="${llvmdir}/lib64/cmake/mlir"
mlir_tblgen="${llvmdir}/bin/mlir-tblgen"
mlir_dll_tblgen="${llvmdir}/lib64/libMLIRTableGen.a"
pytorch_incdir="${PYTORCH}/include"
pytorch_libdir="${PYTORCH}/lib64"
nvcc="${CUDA}/bin/nvcc"
njobs="1"

export PATH="/usr/local/${CUDA}/bin:/opt/${ROCM}/bin:${PYTORCH}/bin:${llvmbindir}:${PATH}"
export GMAKE="/usr/bin/gmake"
export MAKE="${GMAKE}"
export CMAKE="/usr/bin/cmake"

export CC="/usr/bin/gcc"
export CXX="/usr/bin/g++"
export CFLAGS="-Wall -Wextra"
export CXXFLAGS="-Wall -Wextra"
export CPPFLAGS=""
export CMAKE_FLAGS=""
export TORCH_INSTALL_PREFIX="${PYTORCH}"
export USE_CUDNN=1
export USE_CUSPARSELT=1
export USE_CUFILE=1
export USE_PROTOBUF_SHARED_LIBS=1

${CC} --version
${CXX} --version

cat /dev/null > ${outfile}

if [ ! -d ${destdir} ] ; then
  mkdir -p ${destdir}
fi

echo "gmake DESTDIR=${destdir} install >> ${outfile} 2>&1"
gmake DESTDIR=${destdir} install >> ${outfile} 2>&1

cd ${herebindir}

for file in \
  mlir_builder_tblgen \
  torch-mlir-capi-torch-test \
  torch-mlir-import-onnx
do
  echo "patchelf --set-rpath ${runpath} ${file}"
  patchelf --set-rpath ${runpath} ${file}
  echo "cp -fp ${file} ${destdir}/${llvmbindir}/"
  cp ${file} ${destdir}/${llvmbindir}/
done

cd ${here}

libdir="${here}/lib64"
tarball="${here}/libstablehlo.tar"
xztarball="${tarball}.xz"

if [ -e ${tarball} ] ; then
  rm -f ${tarball}
fi

if [ -e ${xztarball} ] ; then
  rm -f ${xztarball}
fi

echo "cd ${libdir}"
cd ${libdir}

tar cf ${tarball} \
  libChloOps.a \
  libInterpreterOps.a \
  libStablehloAssemblyFormat.a \
  libStablehloBase.a \
  libStablehloBroadcastUtils.a \
  libStablehloCAPI.a \
  libStablehloLinalgTransforms.a \
  libStablehloOps.a \
  libStablehloOptimizationPasses.a \
  libStablehloPasses.a \
  libStablehloPassUtils.a \
  libStablehloPortableApi.a \
  libStablehloReferenceApi.a \
  libStablehloReferenceAxes.a \
  libStablehloReferenceConfiguration.a \
  libStablehloReferenceElement.a \
  libStablehloReferenceErrors.a \
  libStablehloReferenceIndex.a \
  libStablehloReferenceNumPy.a \
  libStablehloReferenceOps.a \
  libStablehloReferenceProcess.a \
  libStablehloReferenceProcessGrid.a \
  libStablehloReferenceScope.a \
  libStablehloReferenceTensor.a \
  libStablehloReferenceToken.a \
  libStablehloReferenceTypes.a \
  libStablehloReferenceValue.a \
  libStablehloRegister.a \
  libStablehloSerialization.a \
  libStablehloTypeConversion.a \
  libStablehloTypeInference.a \
  libTorchMLIRCAPI.a \
  libTorchMLIRConversionPasses.a \
  libTorchMLIRConversionUtils.a \
  libTorchMLIRInitAll.a \
  libTorchMLIRRefBackend.a \
  libTorchMLIRTMTensorDialect.a \
  libTorchMLIRTMTensorPasses.a \
  libTorchMLIRTorchConversionDialect.a \
  libTorchMLIRTorchConversionPasses.a \
  libTorchMLIRTorchConversionToMLProgram.a \
  libTorchMLIRTorchDialect.a \
  libTorchMLIRTorchOnnxToTorch.a \
  libTorchMLIRTorchPasses.a \
  libTorchMLIRTorchToArith.a \
  libTorchMLIRTorchToLinalg.a \
  libTorchMLIRTorchToSCF.a \
  libTorchMLIRTorchToStablehlo.a \
  libTorchMLIRTorchToTensor.a \
  libTorchMLIRTorchToTMTensor.a \
  libTorchMLIRTorchToTosa.a \
  libTorchMLIRTorchUtils.a \
  libVersion.a \
  libVhloOps.a \
  libVhloTypes.a

cd ${here}

echo "xz -z -T 4 ${tarball}"
xz -z -T 4 ${tarball}

incfilelist="/tmp/incdialiects.$$"
cat /dev/null > ${incfilelist}

find ./include -type f -name "*.inc" -print >> ${incfilelist}

tarballname="dialectincfiles"
incfiletarball="${here}/${tarballname}.tar"
incfilexztarball="${incfiletarball}.xz"

if [ -e ${incfiletarball} ] ; then
  rm -f ${incfiletarball}
fi

if [ -e ${incfilexztarball} ] ; then
  rm -f ${incfilexztarball}
fi

echo "tar cf ${incfiletarball} -T ${incfilelist}"
tar cf ${incfiletarball} -T ${incfilelist}

echo "xz -z -T 4 ${incfiletarball}"
xz -z -T 4 ${incfiletarball}

echo "rm -f ${incfilelist}"
rm -f ${incfilelist}

echo "cp -fp ${incfilexztarball} ${destdir}/${llvmdir}"
cp -fp ${incfilexztarball} ${destdir}/${llvmdir}

echo "cd ${destdir}/${llvmdir}"
cd ${destdir}/${llvmdir}

echo "tar xf ${tarballname}.tar.xz"
tar xf ${tarballname}.tar.xz

echo "rm -f ${tarballname}.tar.xz"
rm -f ${tarballname}.tar.xz

destdirhere="`pwd`"

if [ -d ${destdirhere}/lib ] ; then
  echo "mv ${destdirhere}/lib ${destdirhere}/lib64"
  mv ${destdirhere}/lib ${destdirhere}/lib64
fi

echo "cd ${here}"
cd ${here}

