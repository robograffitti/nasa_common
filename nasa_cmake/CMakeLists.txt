cmake_minimum_required(VERSION 2.8.3)
project(nasa_cmake)

find_package(catkin REQUIRED)

catkin_package(
  CFG_EXTRAS ${PROJECT_NAME}-setup.cmake
)

install(DIRECTORY cmake
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION})
