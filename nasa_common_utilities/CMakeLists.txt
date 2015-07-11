cmake_minimum_required(VERSION 2.8.3)
project(nasa_common_utilities)

find_package(catkin REQUIRED COMPONENTS hayai nasa_cmake roslib)

find_package(Log4cpp REQUIRED)
find_package(Boost REQUIRED COMPONENTS regex)

catkin_package(
  INCLUDE_DIRS include ${Log4cpp_INCLUDE_DIR} ${Boost_INCLUDE_DIRS}
  LIBRARIES ${PROJECT_NAME} ${Log4cpp_LIBRARIES} ${Boost_LIBRARIES}
  CATKIN_DEPENDS hayai roslib
  DEPENDS Boost Log4cpp
)

catkin_add_env_hooks(10.${PROJECT_NAME} SHELLS sh DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/env-hooks)

include_directories(
  include
  ${Log4cpp_INCLUDE_DIR}
  ${Boost_INCLUDE_DIRS}
  ${catkin_INCLUDE_DIRS}
)

add_library(${PROJECT_NAME} 
  src/Logger.cpp
)

target_link_libraries(${PROJECT_NAME}
  ${Log4cpp_LIBRARIES} 
  ${Boost_LIBRARIES}
  ${catkin_LIBRARIES}
)

add_executable(LoggerBenchmark test/LoggerBenchmark.cpp)

target_link_libraries(LoggerBenchmark ${PROJECT_NAME})

install(TARGETS ${PROJECT_NAME} LoggerBenchmark
  ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
  LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY include/${PROJECT_NAME}/
  DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
  FILES_MATCHING PATTERN "*.h*"
)

install(DIRECTORY share
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
