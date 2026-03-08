message(STATUS "Enabling onnx_c_importer...")

include(FindPkgConfig)

find_package(Protobuf REQUIRED)
find_package(ONNX REQUIRED)
if (NOT ONNX_FOUND)
  message(FATAL_ERROR "Could not find ONNX")
endif()

if (LINUX)
  include(ONNXConfig)
elseif (APPLE AND ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
  include(ONNXConfig)
endif()

include_directories(${Protobuf_INCLUDE_DIR})

set(LLVM_REQUIRES_EH ON)
set(LLVM_REQUIRES_RTTI ON)

if (APPLE AND ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
  set(BUILD_SHARED_LIBS OFF)
else()
  set(BUILD_SHARED_LIBS ON)
endif()

set(USE_PROTOBUF_SHARED_LIBS ON)
set(ONNX_BUILD_SHARED_LIBS ON)
set(BUILD_ONNX_PYTHON ON)

if (APPLE AND ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
  set(PROTOBUF_ONNX_FILES ${ONNX_INCLUDE_DIR}/onnx.proto)
  set(PROTOBUF_ONNX_OPERATORS_FILES ${ONNX_INCLUDE_DIR}/onnx-operators.proto)
elseif (LINUX)
  set(PROTOBUF_ONNX_FILES ${ONNX_INCLUDE_DIR}/onnx.proto)
  set(PROTOBUF_ONNX_OPERATORS_FILES ${ONNX_INCLUDE_DIR}/onnx-operators.proto)
endif()

message(STATUS "PROTOBUF_ONNX_FILES: ${PROTOBUF_ONNX_FILES}")
message(STATUS "PROTOBUF_ONNX_OPERATORS_FILES: ${PROTOBUF_ONNX_OPERATORS_FILES}")

if (LINUX)
  add_custom_target(protobuf_onnx_gen_files
                    COMMAND ${Protobuf_PROTOC_EXECUTABLE} -I ${ONNX_INCLUDE_DIR} --proto_path ${ONNX_INCLUDE_DIR} --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${PROTOBUF_ONNX_FILES}
                    COMMAND ${Protobuf_PROTOC_EXECUTABLE} -I ${ONNX_INCLUDE_DIR} --proto_path ${ONNX_INCLUDE_DIR} --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${PROTOBUF_ONNX_OPERATORS_FILES})
elseif(APPLE AND ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
  execute_process(COMMAND dirname ${ONNX_INCLUDE_DIR} OUTPUT_VARIABLE _ONNX_INCLUDE_PARENT_DIR)
  string(STRIP ${_ONNX_INCLUDE_PARENT_DIR} ONNX_INCLUDE_PARENT_DIR)
  add_custom_target(protobuf_onnx_gen_files
                    COMMAND ${Protobuf_PROTOC_EXECUTABLE} -I${ONNX_INCLUDE_PARENT_DIR} --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${PROTOBUF_ONNX_FILES}
                    COMMAND ${Protobuf_PROTOC_EXECUTABLE} -I${ONNX_INCLUDE_PARENT_DIR} --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${PROTOBUF_ONNX_OPERATORS_FILES})
endif()

add_compile_definitions(-DONNX_NAMESPACE=onnx)
add_compile_options("-I${CMAKE_CURRENT_BINARY_DIR}")
include_directories(BEFORE ${CMAKE_CURRENT_BINARY_DIR})

if (LINUX)
  message(STATUS "${Protobuf_PROTOC_EXECUTABLE} -I ${ONNX_INCLUDE_DIR} --proto_path ${ONNX_INCLUDE_DIR} --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${PROTOBUF_ONNX_FILES}")
  execute_process(COMMAND ${Protobuf_PROTOC_EXECUTABLE} -I ${ONNX_INCLUDE_DIR} --proto_path ${ONNX_INCLUDE_DIR} --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${PROTOBUF_ONNX_FILES} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
elseif (APPLE AND ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
  message(STATUS "dirname ${ONNX_INCLUDE_DIR}")
  execute_process(COMMAND dirname ${ONNX_INCLUDE_DIR} OUTPUT_VARIABLE _ONNX_INCLUDE_PARENT_DIR)
  string(STRIP ${_ONNX_INCLUDE_PARENT_DIR} ONNX_INCLUDE_PARENT_DIR)
  message(STATUS "_ONNX_INCLUDE_PARENT_DIR: ${_ONNX_INCLUDE_PARENT_DIR}")
  message(STATUS "ONNX_INCLUDE_PARENT_DIR: ${ONNX_INCLUDE_PARENT_DIR}")
  message(STATUS "/bin/mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/onnx")
  execute_process(COMMAND /bin/mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/onnx)
  message(STATUS "${Protobuf_PROTOC_EXECUTABLE} -I${ONNX_INCLUDE_PARENT_DIR} --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${PROTOBUF_ONNX_FILES}")
  execute_process(COMMAND ${Protobuf_PROTOC_EXECUTABLE} -I${ONNX_INCLUDE_PARENT_DIR} --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${PROTOBUF_ONNX_FILES} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
  message(STATUS "${Protobuf_PROTOC_EXECUTABLE} -I${ONNX_INCLUDE_PARENT_DIR} --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${PROTOBUF_ONNX_OPERATORS_FILES}")
  execute_process(COMMAND ${Protobuf_PROTOC_EXECUTABLE} -I${ONNX_INCLUDE_PARENT_DIR} --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${PROTOBUF_ONNX_OPERATORS_FILES} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
else()
  message(FATAL_ERROR "Don't know how to generate onnx protobuf files on this OS.")
endif()

if (LINUX)
  set(ONNX_GENERATED_FILES "${CMAKE_CURRENT_BINARY_DIR}/onnx/onnx.pb.h;${CMAKE_CURRENT_BINARY_DIR}/onnx/onnx.pb.cc" )
elseif (APPLE AND ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
  set(ONNX_GENERATED_FILES "${CMAKE_CURRENT_BINARY_DIR}/onnx/onnx.pb.h;${CMAKE_CURRENT_BINARY_DIR}/onnx/onnx.pb.cc;${CMAKE_CURRENT_BINARY_DIR}/onnx/onnx-operators.pb.h;${CMAKE_CURRENT_BINARY_DIR}/onnx/onnx-operators.pb.cc" )
else()
  set(ONNX_GENERATED_FILES "/this/file/does/not/exist.h;/this/file/does/not/exist.cc")
endif()

add_executable(torch-mlir-import-onnx
               import-onnx-main.cpp
               OnnxImporter.h
               OnnxImporter.cpp
               SimpleArgParser.hpp
               Dict.hpp
               Status.hpp
               onnx_extras.hpp
               ${ONNX_GENERATED_FILES})

add_dependencies(torch-mlir-import-onnx protobuf_onnx_gen_files)

set_target_properties(torch-mlir-import-onnx PROPERTIES CXX_STANDARD 20)

# Supress compiler warnings from onnx headers
check_cxx_compiler_flag(-Wno-c++98-compat-extra-semi
                        CXX_SUPPORTS_NO_CXX98_COMPAT_EXTRA_SEMI_FLAG)

if (CXX_SUPPORTS_CXX98_COMPAT_EXTRA_SEMI_FLAG)
    target_compile_options(torch-mlir-import-onnx PRIVATE
        "-Wno-c++98-compat-extra-semi")
    target_compile_options(onnx PRIVATE
        "-Wno-c++98-compat-extra-semi")
endif()

target_compile_options(torch-mlir-import-onnx PRIVATE "-O1")

target_link_libraries(
    torch-mlir-import-onnx
    MLIRAffineDialect
    MLIRArithDialect
    MLIRBufferizationDialect
    MLIRControlFlowDialect
    MLIRComplexDialect
    MLIRCAPIIR
    MLIRDLTIDialect
    MLIRFuncDialect
    MLIRGPUDialect
    MLIRIndexDialect
    MLIRIRDL
    MLIRLinalgDialect
    MLIRLLVMDialect
    MLIRMathDialect
    MLIRMemRefDialect
    MLIRMLProgramDialect
    MLIROpenMPDialect
    MLIRQuantDialect
    MLIRSCFDialect
    MLIRShapeDialect
    MLIRSparseTensorDialect
    MLIRTensorDialect
    MLIRTosaDialect
    MLIRUBDialect
    MLIRVectorDialect
    TorchMLIRCAPI
    onnx
    onnx_proto
    protobuf
    protoc)
