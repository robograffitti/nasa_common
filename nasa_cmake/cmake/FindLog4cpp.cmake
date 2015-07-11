# - Find Log4cpp
# Find the native Log4cpp includes and library
#
#  Log4cpp_FOUND       - True if Log4cpp found.
#  Log4cpp_INCLUDE_DIR - where to find Log4cpp.h, etc.
#  Log4cpp_LIBRARIES   - List of libraries when using Log4cpp.

#IF (Log4cpp_INCLUDE_DIR)
  # Already in cache, be silent
#  SET(Log4cpp_FIND_QUIETLY TRUE)
#ENDIF (Log4cpp_INCLUDE_DIR)

find_program(ROSSTACK_CMD NAMES rosstack PATHS /opt/ros/hydro/bin)
execute_process(COMMAND ${ROSSTACK_CMD} find orocos_toolchain RESULT_VARIABLE OROCOS_FOUND_ERROR OUTPUT_VARIABLE OROCOS_PATH_UGLY ERROR_VARIABLE OROCOS_ERROR_STRING)
if (NOT OROCOS_FOUND_ERROR)
    message(STATUS "FindLog4cpp: Orocos found.  Priority given to Orocos' version of Log4cpp.")
	string(STRIP ${OROCOS_PATH_UGLY} OROCOS_PATH)
	set(OROCOS_LOG4CPP_INCLUDE_DIR ${OROCOS_PATH}/install/include)
	set(OROCOS_LOG4CPP_LIBRARY_DIR ${OROCOS_PATH}/install/lib)
	link_directories(${OROCOS_LOG4CPP_LIBRARY_DIR})
else (NOT OROCOS_FOUND_ERROR)
	message(STATUS "FindLog4cpp: Orocos could not be found.  Using system install of Log4cpp.")
endif (NOT OROCOS_FOUND_ERROR)

FIND_PATH(Log4cpp_INCLUDE_DIR log4cpp/Category.hh
  ${OROCOS_LOG4CPP_INCLUDE_DIR}
  /opt/local/include
  /usr/local/include
  /usr/include
)

SET(Log4cpp_NAMES log4cpp)
FIND_LIBRARY(Log4cpp_LIBRARY
  NAMES ${Log4cpp_NAMES}
  PATHS ${OROCOS_LOG4CPP_LIBRARY_DIR} /usr/local/lib64/lib /usr/lib /usr/local/lib /opt/local/lib
)

IF (Log4cpp_INCLUDE_DIR AND Log4cpp_LIBRARY)
    SET(Log4cpp_FOUND TRUE)
    SET(Log4cpp_LIBRARIES ${Log4cpp_LIBRARY} )
ELSE (Log4cpp_INCLUDE_DIR AND Log4cpp_LIBRARY)
    SET(Log4cpp_FOUND FALSE)
    SET(Log4cpp_LIBRARIES )
ENDIF (Log4cpp_INCLUDE_DIR AND Log4cpp_LIBRARY)

IF (Log4cpp_FOUND)
   IF (NOT Log4cpp_FIND_QUIETLY)
      MESSAGE(STATUS "Log4cpp found.")
      MESSAGE(STATUS "  Includes:  ${Log4cpp_INCLUDE_DIR}")
      MESSAGE(STATUS "  Libraries: ${Log4cpp_LIBRARIES}")
   ENDIF (NOT Log4cpp_FIND_QUIETLY)
ELSE (Log4cpp_FOUND)
   IF (Log4cpp_FIND_REQUIRED)
      MESSAGE(STATUS "Looked for Log4cpp libraries named ${Log4cpp_NAMES}.")
      MESSAGE(FATAL_ERROR "Could NOT find Log4cpp library")
   ENDIF (Log4cpp_FIND_REQUIRED)
ENDIF (Log4cpp_FOUND)

MARK_AS_ADVANCED(
  Log4cpp_LIBRARIES
  Log4cpp_INCLUDE_DIR
  )
