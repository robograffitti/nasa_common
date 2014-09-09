cmake_minimum_required(VERSION 2.8.3)

# This creates a standard cmake project. You may extend this file with
# any cmake macro you see fit.
project(nasa_common_utilities)

find_package(catkin REQUIRED)

# Do setup in case of ros package, If ROS_ROOT is set, it is
# recommended to use RTT/OCL through the ros packages.
#set (ROS_ROOT $ENV{ROS_ROOT} )
#if (ROS_ROOT)
#  include($ENV{ROS_ROOT}/core/rosbuild/rosbuild.cmake)
#  rosbuild_init()
#  rosbuild_find_ros_package( rtt )
#  set( RTT_HINTS HINTS ${rtt_PACKAGE_PATH}/install )
#endif()

#set the default path for built executables to the "bin" directory
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)
#set the default path for built libraries to the "lib" directory
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)

#uncomment if you have defined messages
#rosbuild_genmsg()
#uncomment if you have defined services
#rosbuild_gensrv()

#common commands for building c++ executables and libraries
#rosbuild_add_library(${PROJECT_NAME} src/example.cpp)
#target_link_libraries(${PROJECT_NAME} another_library)
#rosbuild_add_boost_directories()
#rosbuild_link_boost(${PROJECT_NAME} thread)
#rosbuild_add_executable(example examples/example.cpp)
#target_link_libraries(example ${PROJECT_NAME})

# Get access to nasa_cmake
execute_process(COMMAND rospack find nasa_cmake OUTPUT_VARIABLE NASA_CMAKE OUTPUT_STRIP_TRAILING_WHITESPACE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${NASA_CMAKE})
find_package(Log4cpp REQUIRED)
include_directories(${Log4cpp_INCLUDE_DIR})

#add_definitions(-DBUILD_PREFIX='"${PROJECT_SOURCE_DIR}"')
# Hacky, janky crap to make Logger work with rosbuild-style Debian packages
#add_definitions(-DINSTALL_PREFIX='"/opt/nasa/common/stacks/nasa_common/nasa_common_utilities"')

if ($ENV{ROS_DISTRO} STREQUAL fuerte)
	set(BUILD_PREFIX_STR -DBUILD_PREFIX='"${PROJECT_SOURCE_DIR}"')
	set(INSTALL_PREFIX_STR -DINSTALL_PREFIX='"/opt/nasa/common/stacks/nasa_common/nasa_common_utilities"')
	MESSAGE(FUERTE)
else ()
	set(BUILD_PREFIX_STR -DBUILD_PREFIX="${PROJECT_SOURCE_DIR}")
	set(INSTALL_PREFIX_STR -DINSTALL_PREFIX="/opt/nasa/common/stacks/nasa_common/nasa_common_utilities")
	MESSAGE(NOT FUERTE)
endif ()

add_definitions(${INSTALL_PREFIX_STR})
add_definitions(${BUILD_PREFIX_STR})

catkin_package(
  INCLUDE_DIRS include
  LIBRARIES  ${PROJECT_NAME} 
  DEPENDS Boost
)
include_directories(include ${catkin_INCLUDE_DIRS})
add_library(${PROJECT_NAME} ${PROJECT_SOURCE_DIR}/src/Logger.cpp)

target_link_libraries(${PROJECT_NAME} ${Log4cpp_LIBRARIES})



# benchmarks
#rosbuild_add_executable(LoggerBenchmark ${PROJECT_SOURCE_DIR}/test/LoggerBenchmark.cpp)
#target_link_libraries(LoggerBenchmark ${PROJECT_NAME})
