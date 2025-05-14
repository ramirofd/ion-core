cmake_minimum_required(VERSION 3.10)
project(ION-Core-ICI VERSION 4.1.3 LANGUAGES C)

# Debug: Print CMAKE_SOURCE_DIR
message("CMAKE_SOURCE_DIR: ${CMAKE_SOURCE_DIR}")

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

# Define directories
set(SRC_DIR ${CMAKE_SOURCE_DIR}/src)
set(INC_DIR ${CMAKE_SOURCE_DIR}/inc)
set(LIB_DIR ${CMAKE_SOURCE_DIR}/lib)
set(BIN_DIR ${CMAKE_SOURCE_DIR}/bin)
set(MAN_DIR ${CMAKE_SOURCE_DIR}/man)

# ICI source files (based on libici.mk)
set(ICI_SOURCES
  ${SRC_DIR}/ici/bulk.c
  ${SRC_DIR}/ici/csi.c
  ${SRC_DIR}/ici/cbor.c
  ${SRC_DIR}/ici/crc.c
  ${SRC_DIR}/ici/ion.c
  ${SRC_DIR}/ici/ionsec.c
  ${SRC_DIR}/ici/lyst.c
  ${SRC_DIR}/ici/memmgr.c
  ${SRC_DIR}/ici/platform_sm.c
  ${SRC_DIR}/ici/platform.c
  ${SRC_DIR}/ici/psm.c
  ${SRC_DIR}/ici/radix.c
  ${SRC_DIR}/ici/rfx.c
  ${SRC_DIR}/ici/smlist.c
  ${SRC_DIR}/ici/smrbt.c
  ${SRC_DIR}/ici/sptrace.c
  ${SRC_DIR}/ici/zco.c
  ${SRC_DIR}/ici/sdrcatlg.c
  ${SRC_DIR}/ici/sdrhash.c
  ${SRC_DIR}/ici/sdrlist.c
  ${SRC_DIR}/ici/sdrmgt.c
  ${SRC_DIR}/ici/sdrstring.c
  ${SRC_DIR}/ici/sdrtable.c
  ${SRC_DIR}/ici/sdrxn.c
)
if(NOT ICI_SOURCES)
  message(FATAL_ERROR "No ICI source files defined. Ensure extract.sh was run manually to populate ${SRC_DIR}/ici.")
endif()

# Static library
add_library(icicore_static STATIC ${ICI_SOURCES})
target_include_directories(icicore_static PUBLIC ${INC_DIR})
set_target_properties(icicore_static PROPERTIES
  OUTPUT_NAME icicore
  ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR}
)

# Shared library
add_library(icicore_shared SHARED ${ICI_SOURCES})
target_include_directories(icicore_shared PUBLIC ${INC_DIR})
set_target_properties(icicore_shared PROPERTIES
  OUTPUT_NAME icicore
  LIBRARY_OUTPUT_DIRECTORY ${LIB_DIR}
)
target_link_libraries(icicore_shared PRIVATE m pthread)

# ICI executables (from build-list.mk, sourced from src/ici)
set(ICI_PROGRAMS
  ionadmin
  ionwarn
  rfxclock
  psmwatch
  sdrwatch
)

foreach(PROG IN LISTS ICI_PROGRAMS)
  if(NOT EXISTS "${SRC_DIR}/ici/${PROG}.c")
    message(FATAL_ERROR "Source file ${SRC_DIR}/ici/${PROG}.c not found. Ensure extract.sh was run manually to populate ${SRC_DIR}/ici.")
  endif()
  add_executable(${PROG} ${SRC_DIR}/ici/${PROG}.c)
  target_include_directories(${PROG} PRIVATE ${INC_DIR})
  target_link_libraries(${PROG} PRIVATE icicore_static m pthread)
  set_target_properties(${PROG} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}
  )
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
  COMMAND ${CMAKE_COMMAND} -E remove -f ${LIB_DIR}/* !${LIB_DIR}/.gitkeep
  COMMAND ${CMAKE_COMMAND} -E remove -f ${BIN_DIR}/* !${BIN_DIR}/.gitkeep !${BIN_DIR}/ionstart !${BIN_DIR}/ionstart.awk !${BIN_DIR}/ionstop !${BIN_DIR}/killm
  COMMAND ${CMAKE_COMMAND} -E remove -f ${MAN_DIR}/* !${MAN_DIR}/.gitkeep
  COMMENT "Cleaning ICI build artifacts while preserving .gitkeep files"
)

# Distclean target
add_custom_target(distclean
  COMMAND ${CMAKE_COMMAND} -E echo "Removing build artifacts..."
  COMMAND ${CMAKE_COMMAND} -E remove -f ${LIB_DIR}/* !${LIB_DIR}/.gitkeep
  COMMAND ${CMAKE_COMMAND} -E remove -f ${BIN_DIR}/* !${BIN_DIR}/.gitkeep !${BIN_DIR}/ionstart !${BIN_DIR}/ionstart.awk !${BIN_DIR}/ionstop !${BIN_DIR}/killm
  COMMAND ${CMAKE_COMMAND} -E remove -f ${MAN_DIR}/* !${MAN_DIR}/.gitkeep
  COMMENT "Removing ICI build artifacts while preserving .gitkeep files"
)

# Uninstall target
add_custom_target(uninstall
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_INSTALL_PREFIX}/lib/libicicore.a ${CMAKE_INSTALL_PREFIX}/lib/libicicore.so
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_INSTALL_PREFIX}/bin/ionadmin ${CMAKE_INSTALL_PREFIX}/bin/ionwarn ${CMAKE_INSTALL_PREFIX}/bin/rfxclock ${CMAKE_INSTALL_PREFIX}/bin/psmwatch ${CMAKE_INSTALL_PREFIX}/bin/sdrwatch
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_INSTALL_PREFIX}/bin/ionstart ${CMAKE_INSTALL_PREFIX}/bin/ionstart.awk ${CMAKE_INSTALL_PREFIX}/bin/ionstop ${CMAKE_INSTALL_PREFIX}/bin/killm
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_INSTALL_PREFIX}/share/man/man1/ionadmin.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/ionwarn.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/rfxclock.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/psmwatch.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/sdrwatch.1
  COMMENT "Uninstalling ICI module files from ${CMAKE_INSTALL_PREFIX}"
)