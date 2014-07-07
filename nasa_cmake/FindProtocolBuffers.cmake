# Find Protobuf and set useful variables
IF (PROTOBUF_LIBRARY AND PROTOBUF_INCLUDE_DIR AND PROTOBUF_PROTOC_EXECUTABLE)
  # in cache already
  SET(PROTOBUF_FOUND TRUE)
ELSE (PROTOBUF_LIBRARY AND PROTOBUF_INCLUDE_DIR AND PROTOBUF_PROTOC_EXECUTABLE)

  FIND_PATH(PROTOBUF_INCLUDE_DIR stubs/common.h
    /usr/include/google/protobuf
  )

  FIND_LIBRARY(PROTOBUF_LIBRARY protobuf)
  FIND_PROGRAM(PROTOBUF_PROTOC_EXECUTABLE protoc)
  INCLUDE(FindPackageHandleStandardArgs)
  FIND_PACKAGE_HANDLE_STANDARD_ARGS(protobuf DEFAULT_MSG PROTOBUF_INCLUDE_DIR PROTOBUF_LIBRARY PROTOBUF_PROTOC_EXECUTABLE)

  # ensure that they are cached
  SET(PROTOBUF_INCLUDE_DIR ${PROTOBUF_INCLUDE_DIR} CACHE INTERNAL "The protocol buffers include path")
  SET(PROTOBUF_LIBRARY ${PROTOBUF_LIBRARY} CACHE INTERNAL "The libraries needed to use protocol buffers library")
  SET(PROTOBUF_PROTOC_EXECUTABLE ${PROTOBUF_PROTOC_EXECUTABLE} CACHE INTERNAL "The protocol buffers compiler")
ENDIF (PROTOBUF_LIBRARY AND PROTOBUF_INCLUDE_DIR AND PROTOBUF_PROTOC_EXECUTABLE)

# this is the "better" version of the function to call to generate proto headers/lib
function(run_protogen PROTO_FILES)
    # Set up some base variables.
    set(proto_dir ${PROJECT_SOURCE_DIR}/proto)
    message(STATUS "Proto Dir: ${proto_dir}")
    message(STATUS "Proto Files: ${PROTO_FILES}")
    set(proto_gen_dir ${PROJECT_SOURCE_DIR}/proto_gen)
    set(proto_gen_cpp_dir ${proto_gen_dir}/cpp/include/${PROJECT_NAME})
    set(proto_gen_python_dir ${proto_gen_dir}/python)
    file(MAKE_DIRECTORY ${proto_gen_dir})
    file(MAKE_DIRECTORY ${proto_gen_cpp_dir})
    file(MAKE_DIRECTORY ${proto_gen_python_dir})

    # Create lists of files to be generated.
    set(proto_gen_cpp_files "")
    set(proto_gen_python_files "")
    foreach(proto_file ${PROTO_FILES})
        get_filename_component(proto_name ${proto_file} NAME_WE)
        list(APPEND proto_gen_cpp_files ${proto_gen_cpp_dir}/${proto_name}.pb.h ${proto_gen_cpp_dir}/${proto_name}.pb.cc)
        list(APPEND proto_gen_python_files ${proto_gen_python_dir}/${proto_name}_pb2.py)
    endforeach(proto_file ${PROTO_FILES})

    # Run protoc and generate language-specific headers.
    add_custom_command(
        COMMAND ${PROTOBUF_PROTOC_EXECUTABLE} --proto_path=${proto_dir} --cpp_out=${proto_gen_cpp_dir} --python_out=${proto_gen_python_dir} ${PROTO_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        DEPENDS ${PROTOBUF_PROTOC_EXECUTABLE} ${PROTO_FILES}
        OUTPUT ${proto_gen_cpp_files} ${proto_gen_python_files}
    )

    # Create single proto library for linking.
    rosbuild_add_library(${PROJECT_NAME}_proto ${proto_gen_cpp_files} ${proto_gen_python_files})
endfunction()

# this is the "original" and doesn't really work like it should
function(run_genproto)
    # compile protobuf *.proto files to appropriate headers
    file(GLOB PROTO_INPUT RELATIVE ${PROJECT_SOURCE_DIR} ${PROJECT_SOURCE_DIR}/proto/*.proto)

    #protobuf compiler
    find_program(PROTOC protoc)
    set(PROTOC_C_OUT_FLAG --cpp_out --python_out)

    #protobuf output
    set(PROTO_GEN_DIR ${PROJECT_SOURCE_DIR}/proto_gen)
    foreach(PROTO_FILE ${PROTO_INPUT})
      #get the name of the file without extension
      get_filename_component(PROTO_NAME ${PROTO_FILE} NAME_WE)
      #add the generated files
      set(PROTO_GEN ${PROTO_GEN}
      ${PROTO_GEN_DIR}/cpp/${PROTO_NAME}.pb.h
      ${PROTO_GEN_DIR}/cpp/${PROTO_NAME}.pb.cc
      ${PROTO_GEN_DIR}/python/${PROTO_NAME}_pb2.py)
    endforeach(PROTO_FILE ${PROTO_INPUT})

    file(MAKE_DIRECTORY ${PROTO_GEN_DIR})
    file(MAKE_DIRECTORY ${PROTO_GEN_DIR}/cpp)
    file(MAKE_DIRECTORY ${PROTO_GEN_DIR}/python)

    add_custom_command(OUTPUT ${PROTO_GEN}
                       COMMAND ${PROTOC} --proto_path=proto ${PROTO_INPUT} --cpp_out ${PROTO_GEN_DIR}/cpp --python_out ${PROTO_GEN_DIR}/python
                       DEPENDS ${PROTOC} ${PROTO_INPUT}
                       WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

    include_directories(${PROTO_GEN_DIR})

    foreach(PROTO_FILE ${PROTO_INPUT})
        get_filename_component(PROTO_NAME ${PROTO_FILE} NAME_WE)
        rosbuild_add_library(${PROTO_NAME} ${PROTO_GEN})
    endforeach(PROTO_FILE ${PROTO_INPUT})
endfunction()