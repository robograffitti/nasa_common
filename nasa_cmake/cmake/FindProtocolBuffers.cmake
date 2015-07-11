# Find Protobuf and set useful variables
message(STATUS "Protobuf Include Path Hints: ${ProtocolBuffers_INCLUDE_PATH_HINTS}")
FIND_PATH(ProtocolBuffers_INCLUDE_DIRS stubs/common.h
  HINTS ${ProtocolBuffers_INCLUDE_PATH_HINTS}
  PATHS /usr/include/google/protobuf
)
message(STATUS "ProtocolBuffers_INCLUDE_DIRS: ${ProtocolBuffers_INCLUDE_DIRS}")

message(STATUS "Protobuf Lib Path Hints: ${ProtocolBuffers_LIB_PATH_HINTS}")
FIND_LIBRARY(ProtocolBuffers_LIBRARIES protobuf
  HINTS ${ProtocolBuffers_LIB_PATH_HINTS}
)
message(STATUS "ProtocolBuffers_LIBRARIES: ${ProtocolBuffers_LIBRARIES}")

message(STATUS "Protobuf Exe Path Hints: ${ProtocolBuffers_EXECUTABLE_PATH_HINTS}")
FIND_PROGRAM(ProtocolBuffers_EXECUTABLE protoc
  HINTS ${ProtocolBuffers_EXECUTABLE_PATH_HINTS}
)
message(STATUS "ProtocolBuffers_EXECUTABLE: ${ProtocolBuffers_EXECUTABLE}")

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(protobuf DEFAULT_MSG ProtocolBuffers_INCLUDE_DIRS ProtocolBuffers_LIBRARIES ProtocolBuffers_EXECUTABLE)
message(STATUS "ProtocolBuffers_FOUND: ${ProtocolBuffers_FOUND}")

# ensure that they are cached
SET(ProtocolBuffers_INCLUDE_DIRS ${ProtocolBuffers_INCLUDE_DIRS} CACHE INTERNAL "The protocol buffers include path")
SET(ProtocolBuffers_LIBRARIES ${ProtocolBuffers_LIBRARIES} CACHE INTERNAL "The libraries needed to use protocol buffers library")
SET(ProtocolBuffers_EXECUTABLE ${ProtocolBuffers_EXECUTABLE} CACHE INTERNAL "The protocol buffers compiler")




# run after catkin_destinations() and before catkin_python_setup()
# provides ${PROTOGEN_INCLUDE_DIRS} for catkin_package(INCLUDE_DIRS)
function(proto_destinations)
  set(PROTO_GEN_CPP_DIR ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_INCLUDE_DESTINATION} CACHE INTERNAL "Protocol buffer generation dir, cpp")
  set(PROTO_GEN_PYTHON_DIR ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_PYTHON_DESTINATION} CACHE INTERNAL "Protocol buffer generation dir, python")
  file(MAKE_DIRECTORY ${PROTO_GEN_CPP_DIR})
  file(MAKE_DIRECTORY ${PROTO_GEN_PYTHON_DIR})
  set(PROTOGEN_INCLUDE_DIRS ${PROTO_GEN_CPP_DIR}/../ ${PROTO_GEN_PYTHON_DIR} CACHE INTERNAL "Protocol buffer include dirs")
  message(STATUS "Proto Include Dirs: ${PROTOGEN_INCLUDE_DIRS}")
endfunction()

# run after catkin_package()
# provides ${PROJECT_NAME}_proto for catkin_package(LIBRARIES)
function(proto_generate PROTO_DIR)
  file(GLOB proto_files "${PROTO_DIR}/*.proto")
  message(STATUS "Proto Source Dir: ${PROTO_DIR}")
  message(STATUS "Proto Source Files: ${proto_files}")

  set(proto_gen_cpp_files "")
  set(proto_gen_python_files "")
  foreach(proto_file ${proto_files})
    get_filename_component(proto_name ${proto_file} NAME_WE)
    list(APPEND proto_gen_cpp_files ${PROTO_GEN_CPP_DIR}/${proto_name}.pb.h ${PROTO_GEN_CPP_DIR}/${proto_name}.pb.cc)
    list(APPEND proto_gen_python_files ${PROTO_GEN_PYTHON_DIR}/${proto_name}_pb2.py)
  endforeach(proto_file ${proto_files})

  # Run protoc and generate language-specific headers.
  add_custom_command(
    OUTPUT ${proto_gen_cpp_files} ${proto_gen_python_files}
    COMMAND ${ProtocolBuffers_EXECUTABLE} --proto_path=${PROTO_DIR} --cpp_out=${PROTO_GEN_CPP_DIR} --python_out=${PROTO_GEN_PYTHON_DIR} ${proto_files}
    DEPENDS ${ProtocolBuffers_EXECUTABLE} ${proto_files}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )

  set_source_files_properties(${proto_gen_cpp_files} PROPERTIES GENERATED TRUE)
  set_source_files_properties(${proto_gen_python_files} PROPERTIES GENERATED TRUE)

  add_custom_target(${PROJECT_NAME}_generate_headers
    DEPENDS ${proto_gen_cpp_files} ${proto_gen_python_files}
  )

  # Create proto library for linking.
  include_directories(${ProtocolBuffers_INCLUDE_DIRS} ${ProtocolBuffers_INCLUDE_DIRS}/../../)
  add_library(${PROJECT_NAME}_proto ${proto_gen_cpp_files})
  target_link_libraries(${PROJECT_NAME}_proto ${ProtocolBuffers_LIBRARIES})
  add_dependencies(${PROJECT_NAME}_proto ${PROJECT_NAME}_generate_headers)

  install(TARGETS ${PROJECT_NAME}_proto
    ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
    LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
    RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
  )

  install(DIRECTORY ${PROTO_GEN_CPP_DIR}/
    DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
    FILES_MATCHING PATTERN "*.h"
  )

  install(DIRECTORY ${PROTO_GEN_PYTHON_DIR}/
    DESTINATION ${CATKIN_PACKAGE_PYTHON_DESTINATION}
    FILES_MATCHING PATTERN "*.py"
  )
endfunction()