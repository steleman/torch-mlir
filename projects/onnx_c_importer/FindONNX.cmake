# Script to find the ONNX header files and libraries.
# Defines the following:
#   ONNX_FOUND       - if the package is found
#   ONNX_INCLUDE_DIR - the directory for 'nvtx3'
#   ONNX_LIBRARIES   - the libraries needed to linked for using ONNX
#

include(FindPackageHandleStandardArgs)
unset(ONNX_FOUND)

find_path(ONNX_INCLUDE_DIR
          NAMES
          onnx_pb.h
          HINTS
          /usr/include/onnx
          /usr/local/include/onnx)

if (NOT DEFINED ONNX_INCLUDE_DIR)
  message(FATAL_ERROR "Could not find ONNX's header files directory.")
endif()

# set ONNX_FOUND
find_package_handle_standard_args(ONNX DEFAULT_MSG ONNX_INCLUDE_DIR)

find_path(ONNX_LIBRARY_DIR)
          NAMES
          libonnx.so
          libonnx_proto.so
          HINTS
          /usr/lib64
          /usr/local/lib64)

if (NOT DEFINED ONNX_LIBRARY_DIR)
  message(FATAL_ERROR "Could not find ONNX libraries directory.")
endif()

# set ONNX_FOUND
find_package_handle_standard_args(ONNX DEFAULT_MSG ONNX_LIBRARY_DIR)

# set external variables for usage in CMakeLists.txt
if (ONNX_FOUND)
  set(ONNX_FOUND True)
  set(ONNX_INCLUDE_DIR ${ONNX_INCLUDE_DIR})
  set(ONNX_LIBRARY_DIR ${ONNX_LIBRARY_DIR})
  message(STATUS "ONNX found. ONNX_INCLUDE_DIR: ${ONNX_INCLUDE_DIR} ONNX_LIBRARY_DIR: ${ONNX_LIBRARY_DIR}")
  mark_as_advanced(ONNX_INCLUDE_DIR)
  mark_as_advanced(ONNX_LIBRARY_DIR)
else()
  message(FATAL_ERROR "ONNX not found.")
endif()

