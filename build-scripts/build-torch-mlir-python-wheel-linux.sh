#!/bin/bash

llvm_version="21.1.4"
here="`pwd`"
topdir="`dirname ${here}`"
srcdir="${topdir}/torch-mlir"
torch_mlir_builddir="${topdir}/build-torch-mlir"
llvmdir="/opt/llvm/${llvm_version}"
llvmbindir="${llvmdir}/bin"
llvmlibdir="${llvmdir}/lib64"
outfile="${here}/torch-mlir-wheel-build.out"
cret=0
distro="`uname -s`"
linker_type="BFD"
exe_linker_flags="-flto"
bfd_linker_flags="-flto"

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
pytorch_incdir="${PYTORCH}/include"
pytorch_libdir="${PYTORCH}/lib64"
nvcc="${CUDA}/bin/nvcc"

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
export LLVM_TARGETS_TO_BUILD="X86\;"
export LLVM_INSTALL_DIR="${llvmdir}"
export TORCH_MLIR_CMAKE_ALREADY_BUILT=1
export TORCH_MLIR_CMAKE_BUILD_DIR="${torch_mlir_builddir}"
export MAX_JOBS=1

gsed="/usr/bin/sed"
cmakear="/usr/bin/ar"
python_executable="/usr/bin/python3"
build_type="Release"

prefix="${llvmdir}"
cmake_install_bindir="${llvmbindir}"
cmake_install_libdir="${llvmlibdir}"
cmake_install_rpath="${cmake_install_libdir};${pytorch_libdir}"
cmake_build_rpath="${cmake_install_rpath}"
cmake_install_libexecdir="${prefix}/libexec"
cmake_install_incdir="${prefix}/include"
cmake_install_datadir="${prefix}/share"

cmake_flags="-DCMAKE_INSTALL_PREFIX=${prefix}"
cmake_flags="${cmake_flags} -DCMAKE_INSTALL_LIBDIR=${cmake_install_libdir}"
cmake_flags="${cmake_flags} -DCMAKE_BUILD_TYPE=${build_type}"
cmake_flags="${cmake_flags} -DCMAKE_C_COMPILER=${CC}"
cmake_flags="${cmake_flags} -DCMAKE_CXX_COMPILER=${CXX}"
cmake_flags="${cmake_flags} -DCMAKE_CUDA_COMPILER:FILEPATH=${nvcc}"
cmake_flags="${cmake_flags} -DCMAKE_C_FLAGS=${CFLAGS}"
cmake_flags="${cmake_flags} -DCMAKE_CXX_FLAGS=${CXXFLAGS}"
cmake_flags="${cmake_flags} -DCMAKE_C_FLAGS_RELEASE=${CFLAGS}"
cmake_flags="${cmake_flags} -DCMAKE_CXX_FLAGS_RELEASE=${CXXFLAGS}"
cmake_flags="${cmake_flags} -DCMAKE_LINKER_TYPE:STRING=${linker_type}"
cmake_flags="${cmake_flags} -DCMAKE_EXE_LINKER_FLAGS=${exe_linker_flags}"
cmake_flags="${cmake_flags} -DCMAKE_SHARED_LINKER_FLAGS=${bfd_linker_flags}"
cmake_flags="${cmake_flags} -DCMAKE_MODULE_LINKER_FLAGS=${bfd_linker_flags}"
cmake_flags="${cmake_flags} -DCMAKE_AR:FILEPATH=${cmakear}"
cmake_flags="${cmake_flags} -DCMAKE_C_STANDARD=11"
cmake_flags="${cmake_flags} -DCMAKE_CXX_STANDARD=17"
cmake_flags="${cmake_flags} -DCMAKE_C_EXTENSIONS:BOOL=ON"
cmake_flags="${cmake_flags} -DCMAKE_CXX_EXTENSIONS:BOOL=ON"
cmake_flags="${cmake_flags} -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON"
cmake_flags="${cmake_flags} -DCMAKE_BUILD_TYPE:STRING=${build_type}"
cmake_flags="${cmake_flags} -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON"
cmake_flags="${cmake_flags} -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"
cmake_flags="${cmake_flags} -DCMAKE_SUPPRESS_REGENERATION:BOOL=ON"
cmake_flags="${cmake_flags} -DCMAKE_BUILD_RPATH:STRING=${cmake_install_rpath}"
cmake_flags="${cmake_flags} -DCMAKE_INSTALL_RPATH:STRING=${cmake_install_rpath}"

cmake_flags="${cmake_flags} -DCMAKE_INSTALL_BINDIR:FILEPATH=${cmake_install_bindir}"
cmake_flags="${cmake_flags} -DCMAKE_INSTALL_LIBDIR:FILEPATH=${cmake_install_libdir}"
cmake_flags="${cmake_flags} -DCMAKE_INSTALL_LIBEXECDIR:FILEPATH=${cmake_install_libexecdir}"
cmake_flags="${cmake_flags} -DCMAKE_INSTALL_INCLUDEDIR:FILEPATH=${cmake_install_incdir}"
cmake_flags="${cmake_flags} -DCMAKE_INSTALL_DATADIR:FILEPATH=${cmake_install_datadir}"
cmake_flags="${cmake_flags} -DCMAKE_INSTALL_DATAROOTDIR:FILEPATH=${cmake_install_datadir}"
cmake_flags="${cmake_flags} -DCMAKE_MAKE_PROGRAM:FILEPATH=${GMAKE}"
cmake_flags="${cmake_flags} -DCMAKE_ASM_COMPILER:FILEPATH=${CC}"

cmake_flags="${cmake_flags} -DMLIR_DIR=${mlir_dir}"
cmake_flags="${cmake_flags} -DMLIR_CMAKE_DIR=${mlir_dir}"
cmake_flags="${cmake_flags} -DLLVM_DIR=${llvm_dir}"
cmake_flags="${cmake_flags} -DLLVM_CMAKE_DIR=${llvm_dir}"
cmake_flags="${cmake_flags} -DMLIR_TABLEGEN_EXE:FILEPATH=${mlir_tblgen}"
cmake_flags="${cmake_flags} -DMLIR_PDLL_TABLEGEN_EXE:FILEPATH=${mlir_dll_tblgen}"
cmake_flags="${cmake_flags} -DPython3_EXECUTABLE:FILEPATH=${python_executable}"
cmake_flags="${cmake_flags} -DCMAKE_CUDA_ARCHITECTURES:STRING=89"
cmake_flags="${cmake_flags} -DTORCH_INSTALL_PREFIX:FILEPATH=${TORCH_INSTALL_PREFIX}"
cmake_flags="${cmake_flags} -DTORCH_INCLUDE_DIR:FILEPATH=${pytorch_incdir}"
cmake_flags="${cmake_flags} -DUSE_CUDNN=1"
cmake_flags="${cmake_flags} -DUSE_CUSPARSELT=1"
cmake_flags="${cmake_flags} -DUSE_CUDSS=1"
cmake_flags="${cmake_flags} -DUSE_CUFILE=1"
cmake_flags="${cmake_flags} -DCAFFE2_USE_CUDNN:BOOL=ON"
cmake_flags="${cmake_flags} -DCAFFE2_USE_CUSPARSELT:BOOL=ON"
cmake_flags="${cmake_flags} -DCAFFE2_USE_CUFILE:BOOL=ON"
cmake_flags="${cmake_flags} -DTORCH_MLIR_USE_INSTALLED_PYTORCH:BOOL=ON"
cmake_flags="${cmake_flags} -DTORCH_MLIR_ENABLE_ONNX_C_IMPORTER:BOOL=ON"
cmake_flags="${cmake_flags} -DBUILD_SHARED_LIBS:BOOL=ON"
cmake_flags="${cmake_flags} -DUSE_PROTOBUF_SHARED_LIBS:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_BUILD_SHARED_LIBS:BOOL=ON"
cmake_flags="${cmake_flags} -DBUILD_ONNX_PYTHON:BOOL=ON"

export TORCH_MLIR_CMAKE_FLAGS="${cmake_flags}"

echo "python3 ./setup.py bdist_wheel --verbose"
python3 ./setup.py bdist_wheel --verbose >> ${outfile} 2>&1
rc=$?

if [ ${rc} -eq 0 ] ; then
  ts="`date +%Y%m%d%H%M%S`"
  if [ -d ./build ] ; then
    mv ./build ./build-torch-mlir-linux-wheel-${ts}
  fi

  if [ -d ./dist ] ; then
    mv ./dist ./dist-torch-mlir-linux-wheel-${ts}
  fi
else
  echo "python3 ./setup.py bdist_wheel FAILED."
  exit 1
fi


