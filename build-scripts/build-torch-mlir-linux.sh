#!/bin/bash

llvm_version="21.1.8"
here="`pwd`"
topdir="`dirname ${here}`"
srcdir="${topdir}/torch-mlir"
builddir="${here}"
llvmdir="/opt/llvm/${llvm_version}"
llvmbindir="${llvmdir}/bin"
llvmlibdir="${llvmdir}/lib64"
outfile="${here}/torch-mlir-build.out"
cret=0
distro="`uname -s`"

if [ "${distro}" != "Linux" ] ; then
  echo "This cmake configure script only works on Linux."
  exit 1
fi

cuda_version="12.9"
rocm_version="6.4.3"
pytorch_version="2.7.1"
export CUDA="/usr/local/cuda-${cuda_version}"
export ROCM="/opt/rocm-${rocm_version}"
export PYTORCH="/opt/pytorch/${pytorch_version}"
llvm_dir="${llvmdir}/lib64/cmake/llvm"
mlir_dir="${llvmdir}/lib64/cmake/mlir"
mlir_tblgen="${llvmdir}/bin/mlir-tblgen"
mlir_dll_tblgen="${llvmdir}/lib64/libMLIRTableGen.a"
pytorchincdir="${PYTORCH}/include"
pytorchlibdir="${PYTORCH}/lib64"
pytorchbindir="${PYTORCH}/bin"
nvcc="${CUDA}/bin/nvcc"
njobs="1"

export PATH="/usr/local/${CUDA}/bin:/opt/${ROCM}/bin:${pytorchbindir}:${llvmbindir}:${PATH}"
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

echo "gmake -j${njobs} >> ${outfile} 2>&1"
gmake -j${njobs} >> ${outfile} 2>&1

