#!/bin/bash

llvm_version="21.1.4"
llvm_root="/opt/llvm/${llvm_version}"
here="`pwd`"
topdir="`dirname ${here}`"
srcdir="${topdir}/torch-mlir"
builddir="${here}"
llvmdir="/opt/llvm/${llvm_version}"
llvmbindir="${llvmdir}/bin"
llvmlibdir="${llvmdir}/lib"
outfile="${here}/torch-mlir-configure.out"
cret=0
distro="`uname -s`"
linker_type="LLD"
exe_linker_flags="-flto"
bfd_linker_flags="-flto"

if [ "${distro}" != "Darwin" ] ; then
  echo "This cmake configure script only works on MacOS (Darwin)."
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
export PATH="/opt/homebrew/opt/onnx/bin:${PATH}"
export GMAKE="/opt/homebrew/bin/gmake"
export MAKE="${GMAKE}"
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
protobuf="/usr/local"
protobuf_libdir="${protobuf}/lib"
onnx="/usr/local"
onnx_libdir="${onnx}/lib"
onnx_cmake_module_path="${onnx_libdir}/cmake/ONNX"
abseil="/opt/homebrew/opt/abseil"
abseil_libdir="${abseil}/lib"

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
export PKG_CONFIG_PATH="${protobuf_libdir}/pkgconfig:${onnx_libdir}/pkgconfig"

gsed="/opt/homebrew/bin/gsed"
cmakear="/usr/bin/ar"
python_executable="/opt/homebrew/bin/python3"
build_type="Release"

prefix="${llvmdir}"
cmake_install_bindir="${llvmbindir}"
cmake_install_libdir="${llvmlibdir}"
cmake_install_rpath="${cmake_install_libdir};${pytorch_libdir};${protobuf_libdir};${abseil_libdir};${onnx_libdir}"
cmake_build_rpath="${cmake_install_rpath}"
cmake_install_libexecdir="${prefix}/libexec"
cmake_install_incdir="${prefix}/include"
cmake_install_datadir="${prefix}/share"

cmake_flags="-DCMAKE_INSTALL_PREFIX=${prefix}"
cmake_flags="${cmake_flags} -DCMAKE_INSTALL_LIBDIR=${cmake_install_libdir}"
cmake_flags="${cmake_flags} -DCMAKE_BUILD_TYPE=${build_type}"
cmake_flags="${cmake_flags} -DCMAKE_C_COMPILER=${CC}"
cmake_flags="${cmake_flags} -DCMAKE_CXX_COMPILER=${CXX}"
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
cmake_flags="${cmake_flags} -DTORCH_INSTALL_PREFIX:FILEPATH=${TORCH_INSTALL_PREFIX}"
cmake_flags="${cmake_flags} -DTORCH_INCLUDE_DIR:FILEPATH=${pytorch_incdir}"
cmake_flags="${cmake_flags} -DTORCH_MLIR_USE_INSTALLED_PYTORCH:BOOL=ON"
cmake_flags="${cmake_flags} -DTORCH_MLIR_ENABLE_ONNX_C_IMPORTER:BOOL=ON"
cmake_flags="${cmake_flags} -DBUILD_SHARED_LIBS:BOOL=ON"
cmake_flags="${cmake_flags} -DUSE_PROTOBUF_SHARED_LIBS:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_BUILD_SHARED_LIBS:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_CMAKE_MODULE_PATH:FILEPATH=${onnx_cmake_module_path}"
cmake_flags="${cmake_flags} -DBUILD_ONNX_PYTHON:BOOL=ON"

${CC} --version
${CXX} --version

cat /dev/null > ${outfile}
echo "Running ${CMAKE} ${CMAKE_FLAGS} ${cmake_flags} ${srcdir}"
echo "Running ${CMAKE} ${CMAKE_FLAGS} ${cmake_flags} ${srcdir}" >> ${outfile} 2>&1
env TORCH_INSTALL_PREFIX=${TORCH_INSTALL_PREFIX} ${CMAKE} ${CMAKE_FLAGS} ${cmake_flags} ${srcdir} >> ${outfile} 2>&1
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
  ${gsed} -i 's#-fvisibility-inlines-hidden##g' ${line}
  ${gsed} -i 's#-fvisibility=hidden##g' ${line}
  ${gsed} -i 's#-fvisibility=default##g' ${line}
  ${gsed} -i 's#-fno-semantic-interposition##g' ${line}
  ${gsed} -i 's#-Wctad-maybe-unsupported##g' ${line}
  ${gsed} -i 's#-fno-exceptions##g' ${line}
  ${gsed} -i 's#-fno-unwind-tables##g' ${line}
  ${gsed} -i 's#-fno-asynchronous-unwind-tables##g' ${line}
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
  ${gsed} -i 's#-Wno-error=nested-anon-types##g' ${line}
  ${gsed} -i 's#-Wno-error=zero-length-array##g' ${line}
  ${gsed} -i 's#-Wno-error=covered-switch-default##g' ${line}
  ${gsed} -i 's#-Wno-zero-length-array##g' ${line}
  ${gsed} -i 's#-Wno-nested-anon-types##g' ${line}
  ${gsed} -i 's#-Wno-covered-switch-default##g' ${line}
  ${gsed} -i 's#-Wno-c++98-compat-extra-semi##g' ${line}
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
  ${gsed} -i 's#-fno-semantic-interposition##g' ${line}
  ${gsed} -i 's#-fvisibility=hidden##g' ${line}
  ${gsed} -i 's#-fvisibility=default##g' ${line}
  ${gsed} -i 's#-fvisibility-inlines-hidden##g' ${line}
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
  ${gsed} -i 's#-l/opt/homebrew/lib/libz3.dylib#-L/opt/homebrew/lib -lz3#g' ${line}
  touch -r "${line}.orig" -acm ${line}
  rm -f "${line}.orig"
done < ${listfile}

rm -f ${listfile}

filelist="/tmp/badpythonflags.$$"
cat /dev/null > ${filelist}

find . -type f -name "*.make" -print >> ${filelist} 2>&1
find . -type f -name "link.txt" -print >> ${filelist} 2>&1

while read -r line
do
  ${gsed} -i 's#-D_GLIBCXX_USE_CXX11_ABI= # #g' ${line}
  ${gsed} -i 's#-D_GLIBCXX_USE_CXX11_ABI=0##g' ${line}
  ${gsed} -i 's#-D_GLIBCXX_USE_CXX11_ABI=1##g' ${line}
  ${gsed} -i 's#-D_GLIBCXX_USE_CXX11_ABI=##g' ${line}
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
  ${gsed} -i 's#-lonnx#/opt/homebrew/opt/onnx/lib/libonnx.dylib /opt/homebrew/opt/onnx/lib/libonnx_proto.dylib#g' ${line}
  ${gsed} -i 's#/opt/homebrew/lib/python3.13/site-packages/torch/lib/libc10.2.7.1.dylib##g' ${line}
  ${gsed} -i 's#/opt/homebrew/lib/python3.13/site-packages/torch/lib/libtorch.2.7.1.dylib#/opt/pytorch/2.7.1/lib/libtorch.2.7.1.dylib#g' ${line}
  ${gsed} -i 's#-Wl,-rpath,/opt/homebrew/lib/python3.13/site-packages/torch/lib##g' ${line}
  ${gsed} -i 's#-Wl,-z,defs##g' ${line}
  ${gsed} -i 's#-Wl,-z,nodelete##g' ${line}
  ${gsed} -i 's#"##g' ${line}
  ${gsed} -i 's#-Wl,-headerpad_max_install_names#-Wl,-headerpad_max_install_names -Wl,-no_fixup_chains -Wl,-undefined -Wl,dynamic_lookup#g' ${line}
  ${gsed} -i 's#/opt/homebrew/opt/onnx/lib/libonnx.dylib#/usr/local/lib/libonnx.dylib#g' ${line}
  ${gsed} -i 's#/opt/homebrew/opt/onnx/lib/libonnx_proto.dylib#/usr/local/lib/libonnx_proto.dylib#g' ${line}
  ${gsed} -i 's#-lprotobuf#/usr/local/lib/libprotobuf.dylib#g' ${line}
  ${gsed} -i 's#/usr/local/lib/libonnx_proto.dylib_proto#/usr/local/lib/libonnx_proto.dylib#g' ${line}
  ${gsed} -i 's#-lprotoc#/usr/local/lib/libprotoc.dylib#g' ${line}
  touch -r ${line} -acm "${line}.orig"
  rm -f "${line}.orig"
done < ${listfile}

rm -f ${listfile}

echo "CMake configuration finished."
echo "CMake configuration finished." >> ${outfile} 2>&1

