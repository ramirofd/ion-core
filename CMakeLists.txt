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

# ICI source files (automatically gathered)
file(GLOB ICI_ALL_C_FILES
  ${SRC_DIR}/ici/*.c
)

# List of known ICI executables (not to include in library)
set(ICI_PROGRAMS
  ionadmin
  ionwarn
  rfxclock
  psmwatch
  sdrwatch
)

# Build the actual list of library sources by excluding the above
set(ICI_SOURCES ${ICI_ALL_C_FILES})
foreach(prog IN LISTS ICI_PROGRAMS)
  list(REMOVE_ITEM ICI_SOURCES ${SRC_DIR}/ici/${prog}.c)
endforeach()

# LTP source files
file(GLOB LTP_ALL_C_FILES
  ${SRC_DIR}/ltp/*.c
)

# Known LTP executables (exclude these from library)
set(LTP_PROGRAMS
  ltpadmin
  ltpclock
  ltpmeter
  udplsi
  udplso
)

# Filter out program files from source list
set(LTP_SOURCES ${LTP_ALL_C_FILES})
foreach(prog IN LISTS LTP_PROGRAMS)
  list(REMOVE_ITEM LTP_SOURCES ${SRC_DIR}/ltp/${prog}.c)
endforeach()

# BP source files (based on libbp.mk and extract.sh output)
file(GLOB BP_SOURCES
  ${SRC_DIR}/bpv7/*.c
)
# Filter out test programs for separate executable targets
set(BP_EXECUTABLES
  bpadmin 
  bpclm 
  bpclock 
  bpversion 
  ltpcli 
  ltpclo 
  stcpcli 
  stcpclo 
  udpcli 
  udpclo 
  bpchat 
  bpcounter 
  bpdriver 
  bpecho 
  bping 
  bplist 
  bprecvfile 
  bpsendfile 
  bpsink 
  bpsource 
  bpstats 
  bptrace 
  bptransit 
  ipnadmin 
  ipnadminep 
  ipnfw 
  lgagent 
  lgsend
)
# Remove these from BP_SOURCES for library build
foreach(prog IN LISTS BP_EXECUTABLES)
  list(REMOVE_ITEM BP_SOURCES ${SRC_DIR}/bpv7/${prog}.c)
endforeach()

# CFDP source files
file(GLOB CFDP_ALL_C_FILES
  ${SRC_DIR}/cfdp/*.c
)

# Known CFDP programs
set(CFDP_PROGRAMS
  bpcp
  bpcpd
  cfdpadmin
  cfdpclock
  cfdptest
)

# Filter out CFDP executables from library sources
set(CFDP_SOURCES ${CFDP_ALL_C_FILES})
foreach(prog IN LISTS CFDP_PROGRAMS)
  list(REMOVE_ITEM CFDP_SOURCES ${SRC_DIR}/cfdp/${prog}.c)
endforeach()

# ionrestart source (single-file module)
set(RESTART_SOURCES
  ${SRC_DIR}/restart/ionrestart.c
)

# Collect all program executables
set(ALL_PROGRAMS
  ${ICI_PROGRAMS}
  ${BP_PROGRAMS}
  ${LTP_PROGRAMS}
  ${CFDP_PROGRAMS}
  ionrestart
)

# Static ICI library
add_library(icicore_static STATIC ${ICI_SOURCES})
target_include_directories(icicore_static PUBLIC ${INC_DIR})
set_target_properties(icicore_static PROPERTIES
  OUTPUT_NAME icicore
  ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR}
)

# Shared ICI library
add_library(icicore_shared SHARED ${ICI_SOURCES})
target_include_directories(icicore_shared PUBLIC ${INC_DIR})
set_target_properties(icicore_shared PROPERTIES
  OUTPUT_NAME icicore
  LIBRARY_OUTPUT_DIRECTORY ${LIB_DIR}
)
target_link_libraries(icicore_shared PRIVATE m pthread)

# Static BP library
add_library(bpcore_static STATIC ${BP_SOURCES})
target_include_directories(bpcore_static PUBLIC ${INC_DIR})
target_link_libraries(bpcore_static PRIVATE icicore_static)
set_target_properties(bpcore_static PROPERTIES
  OUTPUT_NAME bpcore
  ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR}
)

# Shared BP library
add_library(bpcore_shared SHARED ${BP_SOURCES})
target_include_directories(bpcore_shared PUBLIC ${INC_DIR})
target_link_libraries(bpcore_shared PRIVATE icicore_shared m pthread)
set_target_properties(bpcore_shared PROPERTIES
  OUTPUT_NAME bpcore
  LIBRARY_OUTPUT_DIRECTORY ${LIB_DIR}
)

# Static LTP library
add_library(ltpcore_static STATIC ${LTP_SOURCES})
target_include_directories(ltpcore_static PUBLIC ${INC_DIR})
target_link_libraries(ltpcore_static PRIVATE icicore_static)
set_target_properties(ltpcore_static PROPERTIES
  OUTPUT_NAME ltpcore
  ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR}
)

# Shared LTP library
add_library(ltpcore_shared SHARED ${LTP_SOURCES})
target_include_directories(ltpcore_shared PUBLIC ${INC_DIR})
target_link_libraries(ltpcore_shared PRIVATE icicore_shared m pthread)
set_target_properties(ltpcore_shared PROPERTIES
  OUTPUT_NAME ltpcore
  LIBRARY_OUTPUT_DIRECTORY ${LIB_DIR}
)

# CFDP static library
add_library(cfdpcore_static STATIC ${CFDP_SOURCES})
target_include_directories(cfdpcore_static PUBLIC ${INC_DIR})
target_link_libraries(cfdpcore_static PRIVATE icicore_static bpcore_static)
set_target_properties(cfdpcore_static PROPERTIES
  OUTPUT_NAME cfdpcore
  ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR}
)

# CFDP shared library
add_library(cfdpcore_shared SHARED ${CFDP_SOURCES})
target_include_directories(cfdpcore_shared PUBLIC ${INC_DIR})
target_link_libraries(cfdpcore_shared PRIVATE icicore_shared bpcore_shared m pthread)
set_target_properties(cfdpcore_shared PROPERTIES
  OUTPUT_NAME cfdpcore
  LIBRARY_OUTPUT_DIRECTORY ${LIB_DIR}
)

# ICI Executables
foreach(PROG IN LISTS ICI_PROGRAMS)
  if(NOT EXISTS "${SRC_DIR}/ici/${PROG}.c")
    message(FATAL_ERROR "Source file ${SRC_DIR}/ici/${PROG}.c not found.")
  endif()
  add_executable(${PROG} ${SRC_DIR}/ici/${PROG}.c)
  target_include_directories(${PROG} PRIVATE ${INC_DIR})
  target_link_libraries(${PROG} PRIVATE icicore_static m pthread)
  set_target_properties(${PROG} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}
  )
endforeach()

# BP Executables
foreach(PROG IN LISTS BP_EXECUTABLES)
  if(NOT EXISTS "${SRC_DIR}/bpv7/${PROG}.c")
    message(FATAL_ERROR "Source file ${SRC_DIR}/bpv7/${PROG}.c not found.")
  endif()
  add_executable(${PROG} ${SRC_DIR}/bpv7/${PROG}.c)
  target_include_directories(${PROG} PRIVATE ${INC_DIR})
  target_link_libraries(${PROG} PRIVATE bpcore_static icicore_static m pthread)
  set_target_properties(${PROG} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}
  )
endforeach()

# LTP Executables
foreach(PROG IN LISTS LTP_PROGRAMS)
  if(NOT EXISTS "${SRC_DIR}/ltp/${PROG}.c")
    message(FATAL_ERROR "Source file ${SRC_DIR}/ltp/${PROG}.c not found.")
  endif()
  add_executable(${PROG} ${SRC_DIR}/ltp/${PROG}.c)
  target_include_directories(${PROG} PRIVATE ${INC_DIR})
  target_link_libraries(${PROG} PRIVATE ltpcore_static icicore_static m pthread)
  set_target_properties(${PROG} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}
  )
endforeach()

# CFDP executables
foreach(PROG IN LISTS CFDP_PROGRAMS)
  if(NOT EXISTS "${SRC_DIR}/cfdp/${PROG}.c")
    message(FATAL_ERROR "Source file ${SRC_DIR}/cfdp/${PROG}.c not found.")
  endif()
  add_executable(${PROG} ${SRC_DIR}/cfdp/${PROG}.c)
  target_include_directories(${PROG} PRIVATE ${INC_DIR})
  target_link_libraries(${PROG} PRIVATE cfdpcore_static bpcore_static icicore_static m pthread)
  set_target_properties(${PROG} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}
  )
endforeach()

# ionrestart executable
add_executable(ionrestart ${SRC_DIR}/restart/ionrestart.c)
target_include_directories(ionrestart PRIVATE ${INC_DIR})
target_link_libraries(ionrestart PRIVATE restartcore_static icicore_static m pthread)
set_target_properties(ionrestart PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}
)

install(TARGETS ${ALL_PROGRAMS}
  RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
)

# Man Pages
set(MAN_PROGRAMS
  ionadmin rfxclock psmwatch sdrwatch
  # ionwarn excluded, it has no Man Page
)
list(APPEND MAN_PROGRAMS ${BP_PROGRAMS} ${LTP_PROGRAMS} ${CFDP_PROGRAMS} ionrestart)

# Man pages generation using pod2man
set(MAN_PAGES)
foreach(PROG IN LISTS MAN_PROGRAMS)
  set(POD_FILE ${SRC_DIR}/man/${PROG}.pod)
  set(MAN_FILE ${MAN_DIR}/${PROG}.1)
  set(MAN_GZ_FILE ${MAN_DIR}/${PROG}.1.gz)
  list(APPEND MAN_PAGES ${MAN_GZ_FILE})

  # Generate .1 file from .pod using pod2man
  add_custom_command(
    OUTPUT ${MAN_FILE}
    COMMAND pod2man --section=1 --center="ION-Core Manual" --release="ION-Core ${PROJECT_VERSION}" ${POD_FILE} ${MAN_FILE}
    DEPENDS ${POD_FILE}
    COMMENT "Generating man page ${MAN_FILE}"
    VERBATIM
  )

  # Compress .1 file to .gz
  add_custom_command(
    OUTPUT ${MAN_GZ_FILE}
    COMMAND gzip -f -c ${MAN_FILE} > ${MAN_GZ_FILE}
    DEPENDS ${MAN_FILE}
    COMMENT "Compressing man page to ${MAN_GZ_FILE}"
    VERBATIM
  )
endforeach()

# Custom target to build all man pages
add_custom_target(man DEPENDS ${MAN_PAGES})

# Install ICI libraries
install(TARGETS icicore_static
  ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)
install(TARGETS icicore_shared
  LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)

# Add BP libraries 
install(TARGETS bpcore_static
  ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)
install(TARGETS bpcore_shared
  LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)

# Install CFDP libraries
install(TARGETS cfdpcore_static
  ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)
install(TARGETS cfdpcore_shared
  LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)

# Install LTP libraries
install(TARGETS ltpcore_static
  ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)
install(TARGETS ltpcore_shared
  LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)


install(FILES
  ${BIN_DIR}/ionstart
  ${BIN_DIR}/ionstart.awk
  ${BIN_DIR}/ionstop
  ${BIN_DIR}/killm
  DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
  OPTIONAL
)
install(FILES ${MAN_PAGES}
  DESTINATION ${CMAKE_INSTALL_PREFIX}/share/man/man1
  PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
)

# Clean_all target: remove all build artifacts (but keep .gitkeep files)
add_custom_target(clean_all
  COMMAND ${CMAKE_COMMAND} -E remove -f ${LIB_DIR}/* !${LIB_DIR}/.gitkeep
  COMMAND ${CMAKE_COMMAND} -E remove -f ${BIN_DIR}/* !${BIN_DIR}/.gitkeep !${BIN_DIR}/ionstart !${BIN_DIR}/ionstart.awk !${BIN_DIR}/ionstop !${BIN_DIR}/killm
  COMMAND ${CMAKE_COMMAND} -E remove -f ${MAN_DIR}/* !${MAN_DIR}/.gitkeep
  COMMENT "Cleaning all build artifacts while preserving essential files"
)


# Distclean target
add_custom_target(distclean
  COMMAND find ${INC_DIR} -mindepth 1 ! -name '.gitkeep' -delete
  COMMAND find ${SRC_DIR} -mindepth 1 ! -name '.gitkeep' -delete
  COMMAND find ${LIB_DIR} -mindepth 1 ! -name '.gitkeep' -delete
  COMMAND find ${BIN_DIR} -mindepth 1 ! -name '.gitkeep' -delete
  COMMAND find ${MAN_DIR} -mindepth 1 ! -name '.gitkeep' -delete
  COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_SOURCE_DIR}/system_up
  COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_SOURCE_DIR}/configs
  COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_SOURCE_DIR}/scripts/macOS/install_macos_sysctl.sh
  COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_SOURCE_DIR}/scripts/macOS/sysctl_script.sh
  COMMENT "Removing all build artifacts and extracted source files while preserving .gitkeep files"
)

# Uninstall target: remove installed libraries, programs, scripts, and man pages
add_custom_target(uninstall
  COMMAND ${CMAKE_COMMAND} -E remove -f
    ${CMAKE_INSTALL_PREFIX}/lib/libicicore.a
    ${CMAKE_INSTALL_PREFIX}/lib/libicicore.so
    ${CMAKE_INSTALL_PREFIX}/lib/libbpcore.a
    ${CMAKE_INSTALL_PREFIX}/lib/libbpcore.so
    ${CMAKE_INSTALL_PREFIX}/lib/libltpcore.a
    ${CMAKE_INSTALL_PREFIX}/lib/libltpcore.so
    ${CMAKE_INSTALL_PREFIX}/lib/libcfdpcore.a
    ${CMAKE_INSTALL_PREFIX}/lib/libcfdpcore.so
    ${CMAKE_INSTALL_PREFIX}/lib/librestartcore.a

  # Uninstall ALL programs
  COMMAND ${CMAKE_COMMAND} -E remove -f
    ${ALL_PROGRAMS}
    # Expand each program name into full path
    ${CMAKE_INSTALL_PREFIX}/bin/$<JOIN:${ALL_PROGRAMS}, ${CMAKE_INSTALL_PREFIX}/bin/>

  # Uninstall scripts
  COMMAND ${CMAKE_COMMAND} -E remove -f
    ${CMAKE_INSTALL_PREFIX}/bin/ionstart
    ${CMAKE_INSTALL_PREFIX}/bin/ionstart.awk
    ${CMAKE_INSTALL_PREFIX}/bin/ionstop
    ${CMAKE_INSTALL_PREFIX}/bin/killm

  # Uninstall man pages
  COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_INSTALL_PREFIX}/share/man/man1/*.1.gz

  COMMENT "Uninstalling ION-Core: libraries, binaries, scripts, man pages"
)
