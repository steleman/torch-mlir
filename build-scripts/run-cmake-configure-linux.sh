#!/bin/bash

llvm_version="21.1.8"
here="`pwd`"
topdir="`dirname ${here}`"
srcdir="${topdir}/torch-mlir"
builddir="${here}"
llvmdir="/opt/llvm/${llvm_version}"
llvmbindir="${llvmdir}/bin"
llvmlibdir="${llvmdir}/lib64"
outfile="${here}/torch-mlir-configure.out"
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
onnx="/usr"
onnx_libdir="${onnx}/lib64"
onnx_cmake_module_path="${onnx_libdir}/cmake/ONNX"
abseil="/usr"
abseil_libdir="${abseil}/lib64"

export PATH="/usr/local/${CUDA}/bin:/opt/${ROCM}/bin:${PYTORCH}/bin:${PATH}"
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

gsed="/usr/bin/sed"
cmakear="/usr/bin/ar"
python_executable="/usr/bin/python3"
build_type="Release"

libffi_incdir="/usr/include"
libffi_libdir="/usr/lib64"

prefix="${llvmdir}"
cmake_install_bindir="${llvmbindir}"
cmake_install_libdir="${llvmlibdir}"
cmake_install_rpath="${cmake_install_libdir};${pytorch_libdir}"
cmake_build_rpath="${here}/lib64;${here}/lib;${cmake_install_rpath}"
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
cmake_flags="${cmake_flags} -DCMAKE_BUILD_RPATH:STRING=${cmake_build_rpath}"
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
cmake_flags="${cmake_flags} -DBUILD_SHARED_LIBS:BOOL=OFF"
cmake_flags="${cmake_flags} -DUSE_PROTOBUF_SHARED_LIBS:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_BUILD_SHARED_LIBS:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_CMAKE_MODULE_PATH:FILEPATH=${onnx_cmake_module_path}"
cmake_flags="${cmake_flags} -DBUILD_ONNX_PYTHON:BOOL=ON"

if [ ! -e ${here}/generate-onnx-pb-files.sh ] ; then
  echo "ONNX Protobuf Generator script was not found."
  exit 1
fi

echo "./generate-onnx-pb-files.sh"
./generate-onnx-pb-files.sh

${CC} --version
${CXX} --version

cat /dev/null > ${outfile}
echo "Running ${CMAKE} ${CMAKE_FLAGS} ${cmake_flags} ${srcdir}"
echo "Running ${CMAKE} ${CMAKE_FLAGS} ${cmake_flags} ${srcdir}" >> ${outfile} 2>&1
${CMAKE} ${CMAKE_FLAGS} ${cmake_flags} ${srcdir} >> ${outfile} 2>&1
cret=$?

if [ ${cret} -ne 0 ] ; then
  echo "CMake configuration failed."
  exit 1
fi

echo "Fixing bad compile flags from CMake ..."
echo "Fixing bad compile flags from CMake ..." >> ${outfile} 2>&1

listfile="/tmp/bad-compilerflags.$$"
cat /dev/null > ${listfile}

find . -type f -name "*.make" -print >> ${listfile} 2>&1

while read -r line
do
  cp -fp ${line} "${line}.orig"
  sed -i 's#-fvisibility-inlines-hidden##g' ${line}
  sed -i 's#-fvisibility=hidden##g' ${line}
  sed -i 's#-fvisibility=default##g' ${line}
  sed -i 's#-fno-semantic-interposition##g' ${line}
  sed -i 's#-Wctad-maybe-unsupported##g' ${line}
  sed -i 's#-fno-exceptions##g' ${line}
  sed -i 's#-fno-unwind-tables##g' ${line}
  sed -i 's#-fno-asynchronous-unwind-tables##g' ${line}
  touch -r "${line}.orig" -acm ${line}
  rm -f "${line}.orig"
done < ${listfile}

rm -f ${listfile}

echo "Fixing bad Clang-specific compiler flags from stablehlo ..."
echo "Fixing bad Clang-specific compiler flags from stablehlo ..." >> ${outfile} 2>&1

listfile="/tmp/badclangflags.$$"
cat /dev/null > ${listfile}
find . -type f -name 'flags.make' -print >> ${listfile}

while read -r line
do
  cp -fp ${line} "${line}.orig"
  sed -i 's#-Wno-error=nested-anon-types##g' ${line}
  sed -i 's#-Wno-error=zero-length-array##g' ${line}
  sed -i 's#-Wno-error=covered-switch-default##g' ${line}
  sed -i 's#-Wno-zero-length-array##g' ${line}
  sed -i 's#-Wno-nested-anon-types##g' ${line}
  sed -i 's#-Wno-covered-switch-default##g' ${line}
  sed -i 's#-Wno-c++98-compat-extra-semi##g' ${line}
  sed -i 's#-isystem /usr/lib64/python3.13/site-packages/torch/include##g' ${line}
  touch -r ${line} -acm "${line}.orig"
  rm -f "${line}.orig"
done < ${listfile}

rm -f ${listfile}

echo "Fixing bad linker flags from CMake ..."
echo "Fixing bad linker flags from CMake ..." >> ${outfile} 2>&1

listfile="/tmp/link-relocations.$$"
cat /dev/null > ${listfile}

find . -type f -name "link.txt" -print >> ${listfile} 2>&1

while read -r line
do
  cp -fp ${line} "${line}.orig"
  sed -i 's#-fno-semantic-interposition##g' ${line}
  sed -i 's#-fvisibility=hidden##g' ${line}
  sed -i 's#-fvisibility=default##g' ${line}
  sed -i 's#-fvisibility-inlines-hidden##g' ${line}
  touch -r "${line}.orig" -acm ${line}
  rm -f "${line}.orig"
done < ${listfile}

rm -f ${listfile}

echo "Fixing OCaml linker crap ..."
echo "Fixing OCaml linker crap ..." >> ${outfile} 2>&1

listfile="/tmp/badocaml-link.$$"
cat /dev/null > ${listfile}

find . -type f -name "build.make" -print >> ${listfile} 2>&1
find . -type f -name "link.txt" -print >> ${listfile} 2>&1

while read -r line
do
  cp -fp ${line} "${line}.orig"
  sed -i 's#-l/opt/homebrew/lib/libz3.dylib#-L/opt/homebrew/lib -lz3#g' ${line}
  touch -r "${line}.orig" -acm ${line}
  rm -f "${line}.orig"
done < ${listfile}

rm -f ${listfile}

echo "Fixing bad Python header file includes ..."

filelist="/tmp/badpythonflags.$$"
cat /dev/null > ${filelist}

find . -type f -name "*.make" -print >> ${filelist} 2>&1
find . -type f -name "link.txt" -print >> ${filelist} 2>&1

while read -r line
do
  sed -i 's#-isystem /usr/lib64/python3.13/site-packages/torch/include##g' ${line}
  sed -i 's#-isystem /usr/local/lib64/python3.13/site-packages/torch/include##g' ${line}
  sed -i 's#-D_GLIBCXX_USE_CXX11_ABI= # #g' ${line}
  sed -i 's#-D_GLIBCXX_USE_CXX11_ABI=0##g' ${line}
  sed -i 's#-D_GLIBCXX_USE_CXX11_ABI=1##g' ${line}
  sed -i 's#-D_GLIBCXX_USE_CXX11_ABI=##g' ${line}
  sed -i 's#/usr/lib64/python3.13/site-packages/torch/lib:##g' ${line}
done < ${filelist}

rm -f ${filelist}

echo "Fixing PyTorch linker line crap ..."
echo "Fixing PyTorch linker line crap ..." >> ${outfile} 2>&1

listfile="/tmp/torchlink.$$"

cat /dev/null > ${listfile}
find . -type f -name 'link.txt' -print >> ${listfile}

while read -r line
do
  cp -fp ${line} "${line}.orig"
  sed -i 's#"/usr/lib64/python3.13/site-packages/torch/lib/libtorch.so.2.7.1"#/opt/pytorch/2.7.1/lib64/libtorch.so.2.7.1#g' ${line}
  sed -i 's#"/usr/lib64/python3.13/site-packages/torch/lib/libtorch_cpu.so.2.7.1"#/opt/pytorch/2.7.1/lib64/libtorch_cpu.so.2.7.1#g' ${line}
  sed -i 's#"/usr/lib64/python3.13/site-packages/torch/lib/libtorch_cuda.so.2.7.1"#/opt/pytorch/2.7.1/lib64/libtorch_cuda.so.2.7.1#g' ${line}
  sed -i 's#/usr/lib64/python3.13/site-packages/torch/lib/c10_cuda.so#/opt/pytorch/2.7.1/lib64/libc10_cuda.so#g' ${line}
  sed -i 's#/usr/lib64/python3.13/site-packages/torch/lib/c10.so.2.7.1#/opt/pytorch/2.7.1/lib64/libc10.so.2.7.1#g' ${line}
  sed -i 's#/opt/pytorch/2.7.1/lib/#/opt/pytorch/2.7.1/lib64/#g' ${line}
  sed -i 's#/opt/pytorch/2.7.1/lib:#/opt/pytorch/2.7.1/lib64:#g' ${line}
  sed -i 's#-L/opt/pytorch/2.7.1/lib #-L/opt/pytorch/2.7.1/lib64 #g' ${line}
  sed -i 's#/usr/local/cuda/lib64:#/usr/local/cuda-12.9/lib64:#g' ${line}
  sed -i 's#"/usr/lib64/python3.13/site-packages/torch/lib/libtorch_cuda.so"#/opt/pytorch/2.7.1/lib64/libtorch_cuda.so#g' ${line}
  sed -i 's#/usr/local/cuda/lib64/libnvrtc.so#/usr/local/cuda-12.9/lib64/libnvrtc.so#g' ${line}
  sed -i 's#/usr/local/cuda/lib64/libcudart.so#/usr/local/cuda-12.9/lib64/libcudart.so#g' ${line}
  sed -i 's#/usr/lib64/python3.13/site-packages/torch/lib/libc10_cuda.so#/opt/pytorch/2.7.1/lib64/libc10_cuda.so#g' ${line}
  sed -i 's#/usr/lib64/python3.13/site-packages/torch/lib/libc10.so.2.7.1#/opt/pytorch/2.7.1/lib64/libc10.so.2.7.1#g' ${line}
  sed -i 's#/usr/lib64/python3.13/site-packages/torch/lib/libtorch.so.2.7.1#/opt/pytorch/2.7.1/lib64/libtorch.so.2.7.1#g' ${line}
  sed -i 's#/usr/local/cuda/#/usr/local/cuda-12.9/#g' ${line}
  sed -i 's#-lonnx#/usr/lib64/libonnx.so /usr/lib64/libonnx_proto.so#g' ${line}
  sed -i 's#-Wl,-z,defs##g' ${line}
  sed -i 's#-Wl,-z,nodelete##g' ${line}
  sed -i 's#"##g' ${line}
  sed -i 's#/usr/lib64/libonnx_proto.so_proto##g' ${line}
  touch -r ${line} -acm "${line}.orig"
  rm -f "${line}.orig"
done < ${listfile}

rm -f ${listfile}

echo "CMake configuration finished."
echo "CMake configuration finished." >> ${outfile} 2>&1

