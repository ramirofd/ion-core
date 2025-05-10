cmake_minimum_required(VERSION 3.10)
project(ION-Core-ICI VERSION 4.1.3 LANGUAGES C)

# Default installation path
set(CMAKE_INSTALL_PREFIX /usr/local CACHE PATH "Installation prefix")

# Include custom configuration file for feature selection
include(ion-core-config.cmake OPTIONAL)

# Platform detection and flags (from build-list.mk)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    add_definitions(-Dlinux -DSPACE_ORDER=3 -fno-strict-aliasing)
  else()
    add_definitions(-Dlinux -DSPACE_ORDER=2 -fno-strict-aliasing)
  endif()
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    add_definitions(-Dunix -Ddarwin -DSPACE_ORDER=3)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64")
  else()
    add_definitions(-Dunix -Ddarwin -DSPACE_ORDER=2)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32")
  endif()
elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    add_definitions(-Dfreebsd -DSPACE_ORDER=3)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64")
  else()
    add_definitions(-Dfreebsd -DSPACE_ORDER=2)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32")
  endif()
endif()

# Compiler flags (from Makefile)
add_compile_options(-g -Wall -DBP_EXTENDED)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC") # For shared libraries

# Extension flags (configurable via ion-core-config.cmake)
option(ENABLE_BPQ_EXT "Enable Bundle Protocol QoS Extension Block" ON)
option(ENABLE_IMC_EXT "Enable IMC Multicast Extension Block" ON)
if(ENABLE_BPQ_EXT)
  add_definitions(-DBPQ_EXT)
endif()
if(ENABLE_IMC_EXT)
  add_definitions(-DIMC_EXT)
endif()

# Check for extract.sh
if(NOT EXISTS "${CMAKE_SOURCE_DIR}/scripts/extract.sh")
  message(FATAL_ERROR "extract.sh not found in ${CMAKE_SOURCE_DIR}/scripts. Please ensure the script is present.")
endif()

# Source extraction (run extract.sh to create symbolic links and modify files)
set(ION_DTN_REPO_PATH "" CACHE PATH "Path to ION-DTN repository")
if(ION_DTN_REPO_PATH)
  set(EXTRACT_COMMAND ${CMAKE_SOURCE_DIR}/scripts/extract.sh ${ION_DTN_REPO_PATH})
else()
  set(EXTRACT_COMMAND ${CMAKE_SOURCE_DIR}/scripts/extract.sh)
endif()
add_custom_command(
  OUTPUT 
    ${CMAKE_SOURCE_DIR}/src/ici
    ${CMAKE_SOURCE_DIR}/src/bpsec_policy_rule.c
    ${CMAKE_SOURCE_DIR}/inc/bpextensions.c
  COMMAND ${EXTRACT_COMMAND}
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  COMMENT "Running scripts/extract.sh to create ICI source symbolic links and modify BP files"
)
add_custom_target(extract_ici 
  DEPENDS 
    ${CMAKE_SOURCE_DIR}/src/ici
    ${CMAKE_SOURCE_DIR}/src/bpsec_policy_rule.c
    ${CMAKE_SOURCE_DIR}/inc/bpextensions.c
)

# Define directories
set(SRC_DIR ${CMAKE_SOURCE_DIR}/src)
set(INC_DIR ${CMAKE_SOURCE_DIR}/inc)
set(LIB_DIR ${CMAKE_SOURCE_DIR}/lib)
set(BIN_DIR ${CMAKE_SOURCE_DIR}/bin)
set(MAN_DIR ${CMAKE_SOURCE_DIR}/man)

# ICI source files (assumes all .c files in src/ici)
file(GLOB ICI_SOURCES ${SRC_DIR}/ici/*.c)

# Static library
add_library(icicore_static STATIC ${ICI_SOURCES})
target_include_directories(icicore_static PUBLIC ${INC_DIR})
set_target_properties(icicore_static PROPERTIES
  OUTPUT_NAME icicore
  ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR}
)
add_dependencies(icicore_static extract_ici)

# Shared library
add_library(icicore_shared SHARED ${ICI_SOURCES})
target_include_directories(icicore_shared PUBLIC ${INC_DIR})
set_target_properties(icicore_shared PROPERTIES
  OUTPUT_NAME icicore
  LIBRARY_OUTPUT_DIRECTORY ${LIB_DIR}
)
target_link_libraries(icicore_shared PRIVATE m pthread)
add_dependencies(icicore_shared extract_ici)

# ICI executables (from build-list.mk)
set(ICI_PROGRAMS
  ionadmin
  ionwarn
  rfxclock
  ionrestart
  psmwatch
  sdrwatch
)

foreach(PROG IN LISTS ICI_PROGRAMS)
  add_executable(${PROG} ${SRC_DIR}/${PROG}.c)
  target_include_directories(${PROG} PRIVATE ${INC_DIR})
  target_link_libraries(${PROG} PRIVATE icicore_static m pthread)
  set_target_properties(${PROG} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}
  )
  add_dependencies(${PROG} extract_ici)
endforeach()

# Installation
install(TARGETS icicore_static
  ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)
install(TARGETS icicore_shared
  LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)
install(TARGETS ${ICI_PROGRAMS}
  RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
)
install(FILES
  ${BIN_DIR}/ionstart
  ${BIN_DIR}/ionstart.awk
  ${BIN_DIR}/ionstop
  ${BIN_DIR}/killm
  DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
  OPTIONAL
)
if(EXISTS ${MAN_DIR})
  install(DIRECTORY ${MAN_DIR}/
    DESTINATION ${CMAKE_INSTALL_PREFIX}/share/man/man1
    FILES_MATCHING PATTERN "*"
  )
endif()

# Man pages
add_custom_target(man
  COMMAND ${CMAKE_SOURCE_DIR}/scripts/make-man-pages.sh ${SRC_DIR}/man "${ICI_PROGRAMS}"
  COMMENT "Generating man pages for ICI programs"
)

# Clean target
add_custom_target(ici_clean
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${LIB_DIR}
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${BIN_DIR}
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${MAN_DIR}
  COMMENT "Cleaning ICI build artifacts"
)

# Distclean target
add_custom_target(distclean
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${SRC_DIR}/ici
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${LIB_DIR}
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${BIN_DIR}
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${MAN_DIR}
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_SOURCE_DIR}/system_up
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_SOURCE_DIR}/configs
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_SOURCE_DIR}/scripts/macOS/install_macos_sysctl.sh
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_SOURCE_DIR}/scripts/macOS/sysctl_script.sh
  COMMENT "Removing all ICI build and source artifacts"
)