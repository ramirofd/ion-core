cmake_minimum_required(VERSION 3.10)
project(ION-Core-ICI VERSION 4.1.3 LANGUAGES C)

# Debug: Print CMAKE_SOURCE_DIR
message("CMAKE_SOURCE_DIR: ${CMAKE_SOURCE_DIR}")

# Default installation path
set(CMAKE_INSTALL_PREFIX /usr/local CACHE PATH "Installation prefix")

# Include custom configuration file for feature selection
include(ion-core-config.cmake OPTIONAL)

# Include the new build-list.cmake file to define global build variables
include(${CMAKE_SOURCE_DIR}/build-list.cmake) # Assuming build-list.cmake is in the root

# Platform detection and flags (now handled by build-list.cmake which sets OS_FLAGS)
# The logic below can be simplified as OS_FLAGS is already set.
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  # Already handled by build-list.cmake setting OS_FLAGS
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  # -m64/-m32 flags are commonly handled by adding to CMAKE_C_FLAGS if necessary,
  # but often CMake's default compilers handle this based on CMAKE_SIZEOF_VOID_P
  # For direct mimicry:
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64")
  else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32")
  endif()
elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64")
  else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32")
  endif()
endif()

# Apply the OS-specific definitions from build-list.cmake
add_definitions(${OS_FLAGS})

# Compiler flags (from Makefile)
# VER is now set in build-list.cmake, so we can use it directly
add_definitions(${VER}) # -DVNAME=ION-CORE-4.1.3s

add_compile_options(-g -Wall -DBP_EXTENDED)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC") # For shared libraries

# Apply extension flags from build-list.cmake
add_definitions(${EXT_FLAGS})

# Extension flags - if these were originally options, keep them as options
# The `EXT_FLAGS` string from build-list.cmake can define the default flags.
# If you want them to be user-configurable, you would still use `option()`
# and then conditionally add definitions. For now, mimicking direct application.
# option(ENABLE_BPQ_EXT "Enable Bundle Protocol QoS Extension Block" ON)
# option(ENABLE_IMC_EXT "Enable IMC Multicast Extension Block" ON)
# if(ENABLE_BPQ_EXT)
#   add_definitions(-DBPQ_EXT)
# endif()
# if(ENABLE_IMC_EXT)
#   add_definitions(-DIMC_EXT)
# endif()


# Define directories
set(SRC_DIR ${CMAKE_SOURCE_DIR}/src)
set(INC_DIR ${CMAKE_SOURCE_DIR}/inc)
set(LIB_DIR ${CMAKE_SOURCE_DIR}/lib)
set(BIN_DIR ${CMAKE_SOURCE_DIR}/bin)
set(MAN_DIR ${CMAKE_SOURCE_DIR}/man)
set(TESTS_DIR ${CMAKE_SOURCE_DIR}/tests) # Define TESTS_DIR for test target

#
# ICI source files
#
set(ICI_SOURCES
  ${SRC_DIR}/ici/bulk.c
  ${SRC_DIR}/ici/csi.c
  ${SRC_DIR}/ici/ionsec.c
  ${SRC_DIR}/ici/memmgr.c
  ${SRC_DIR}/ici/platform_sm.c
  ${SRC_DIR}/ici/radix.c
  ${SRC_DIR}/ici/sdrcatlg.c
  ${SRC_DIR}/ici/sdrmgt.c
  ${SRC_DIR}/ici/smrbt.c
  ${SRC_DIR}/ici/cbor.c
  ${SRC_DIR}/ici/owltsim.c
  ${SRC_DIR}/ici/psm.c
  ${SRC_DIR}/ici/rfx.c
  ${SRC_DIR}/ici/sdrhash.c
  ${SRC_DIR}/ici/sdrstring.c
  ${SRC_DIR}/ici/sdrxn.c
  ${SRC_DIR}/ici/sptrace.c
  ${SRC_DIR}/ici/crc.c
  ${SRC_DIR}/ici/ion.c
  ${SRC_DIR}/ici/lyst.c
  ${SRC_DIR}/ici/platform.c
  ${SRC_DIR}/ici/sdrlist.c
  ${SRC_DIR}/ici/sdrtable.c
  ${SRC_DIR}/ici/smlist.c
  ${SRC_DIR}/ici/zco.c
)

if(NOT ICI_SOURCES)
  message(FATAL_ERROR "No ICI source files defined. Ensure extract.sh was run manually to populate ${SRC_DIR}/ici.")
endif()

# List of known ICI executables (not to include in library)
# PROGRAMS are now defined in build-list.cmake, use its values
set(ICI_PROGRAMS
  ionadmin
  ionwarn
  rfxclock
  psmwatch
  sdrwatch
  owltsim
)

# 
# LTP source files
#
set(LTP_SOURCES
  ${SRC_DIR}/ltp/libltp.c
  ${SRC_DIR}/ltp/libltpP.c
  ${SRC_DIR}/ltp/libsda.c
  ${SRC_DIR}/ltp/libudplsa.c
  ${SRC_DIR}/ltp/ltpei.c
)

if(NOT LTP_SOURCES)
  message(FATAL_ERROR "No LTP source files defined. Ensure extract.sh was run manually to populate ${SRC_DIR}/ltp.")
endif()

# Known LTP executables (exclude these from library)
set(LTP_PROGRAMS
  ltpadmin
  ltpclock
  ltpmeter
  udplsi
  udplso
  ltpdeliv
  ltpcli
  ltpclo
)

#
# BP source files (based on libbp.mk and extract.sh output)
#
set(BP_SOURCES
  ${SRC_DIR}/bpv7/bae.c
  ${SRC_DIR}/bpv7/bpsec_instr.c
  ${SRC_DIR}/bpv7/bcb_aes_gcm_sc.c
  ${SRC_DIR}/bpv7/bpsec_policy.c
  ${SRC_DIR}/bpv7/meb.c
  ${SRC_DIR}/bpv7/bcb.c
  ${SRC_DIR}/bpv7/bpsec_policy_event.c
  ${SRC_DIR}/bpv7/libbp.c
  ${SRC_DIR}/bpv7/pnb.c
  ${SRC_DIR}/bpv7/bei.c
  ${SRC_DIR}/bpv7/bpsec_policy_eventset.c
  ${SRC_DIR}/bpv7/eureka.c
  ${SRC_DIR}/bpv7/libbpP.c
  ${SRC_DIR}/bpv7/rfc9173_utils.c
  ${SRC_DIR}/bpv7/bib.c
  ${SRC_DIR}/bpv7/bpsec_policy_rule.c
  ${SRC_DIR}/bpv7/hcb.c          
  ${SRC_DIR}/bpv7/libcgr.c      
  ${SRC_DIR}/bpv7/saga.c
  ${SRC_DIR}/bpv7/bibe.c
  ${SRC_DIR}/bpv7/bpsec_util.c
  ${SRC_DIR}/bpv7/imc.c
  ${SRC_DIR}/bpv7/libimcfw.c
  ${SRC_DIR}/bpv7/sci.c
  ${SRC_DIR}/bpv7/bib_hmac_sha2_sc.c
  ${SRC_DIR}/bpv7/ion_test_sc.c
  ${SRC_DIR}/bpv7/libipnfw.c
  ${SRC_DIR}/bpv7/sci_valmap.c
  ${SRC_DIR}/bpv7/bpq.c
  ${SRC_DIR}/bpv7/libstcpcla.c
  ${SRC_DIR}/bpv7/sc_util.c
  ${SRC_DIR}/bpv7/libudpcla.c
  ${SRC_DIR}/bpv7/sc_value.c
  ${SRC_DIR}/bpv7/bpsec_asb.c
  ${SRC_DIR}/bpv7/snw.c
)

if(NOT BP_SOURCES)
  message(FATAL_ERROR "No BP source files defined. Ensure extract.sh was run manually to populate ${SRC_DIR}/bpv7.")
endif()

# Filter out test programs for separate executable targets
set(BP_EXECUTABLES
  bpadmin 
  bpclm 
  bpclock 
  bpversion 
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
  bpcancel
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

#
# CFDP source files
#
set(CFDP_SOURCES
  ${SRC_DIR}/cfdp/bputa.c
  ${SRC_DIR}/cfdp/libcfdp.c
  ${SRC_DIR}/cfdp/libcfdpops.c
  ${SRC_DIR}/cfdp/libcfdpP.c
)

if(NOT CFDP_SOURCES)
  message(FATAL_ERROR "No CFDP source files defined. Ensure extract.sh was run manually to populate ${SRC_DIR}/cfdp.")
endif()

# Known CFDP programs
set(CFDP_PROGRAMS
  bputa
  bpcp
  bpcpd
  cfdpadmin
  cfdpclock
  cfdptest
)

# ionrestart source (single-file module)
set(RESTART_SOURCES
  ${SRC_DIR}/restart/ionrestart.c
)

# Collect all program executables (now primarily driven by PROGRAMS from build-list.cmake)
# Ensure ALL_PROGRAMS contains all listed executables for linking
# You might still need these sub-lists (ICI_PROGRAMS, BP_EXECUTABLES, etc.)
# for iterating over specific module sources, but the master list comes from build-list.cmake
set(ALL_PROGRAMS ${PROGRAMS}) # Use PROGRAMS variable populated from build-list.cmake


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
target_link_libraries(ltpcore_static PRIVATE bpcore_static icicore_static)
set_target_properties(ltpcore_static PROPERTIES
  OUTPUT_NAME ltpcore
  ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR}
)

# Shared LTP library
add_library(ltpcore_shared SHARED ${LTP_SOURCES})
target_include_directories(ltpcore_shared PUBLIC ${INC_DIR})
target_link_libraries(ltpcore_shared PRIVATE bpcore_shared icicore_shared m pthread)
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
  if(${PROG} IN_LIST ALL_PROGRAMS) # Only build if it's in the master PROGRAMS list
    if(NOT EXISTS "${SRC_DIR}/ici/${PROG}.c")
      message(FATAL_ERROR "Source file ${SRC_DIR}/ici/${PROG}.c not found.")
    endif()
    add_executable(${PROG} ${SRC_DIR}/ici/${PROG}.c)
    target_include_directories(${PROG} PRIVATE ${INC_DIR})
    target_link_libraries(${PROG} PRIVATE icicore_static m pthread)
    set_target_properties(${PROG} PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}
    )
  endif()
endforeach()

# BP Executables
foreach(PROG IN LISTS BP_EXECUTABLES)
  if(${PROG} IN_LIST ALL_PROGRAMS) # Only build if it's in the master PROGRAMS list
    if(NOT EXISTS "${SRC_DIR}/bpv7/${PROG}.c")
      message(FATAL_ERROR "Source file ${SRC_DIR}/bpv7/${PROG}.c not found.")
    endif()
    add_executable(${PROG} ${SRC_DIR}/bpv7/${PROG}.c)
    target_include_directories(${PROG} PRIVATE ${INC_DIR})
    target_link_libraries(${PROG} PRIVATE bpcore_static icicore_static m pthread)
    set_target_properties(${PROG} PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}
    )
  endif()
endforeach()

# LTP Executables
foreach(PROG IN LISTS LTP_PROGRAMS)
  if(${PROG} IN_LIST ALL_PROGRAMS) # Only build if it's in the master PROGRAMS list
    if(PROG STREQUAL "ltpcli" OR PROG STREQUAL "ltpclo")
      set(SRC_PATH "${SRC_DIR}/bpv7/${PROG}.c")
    else()
      set(SRC_PATH "${SRC_DIR}/ltp/${PROG}.c")
    endif()
    if(NOT EXISTS "${SRC_PATH}")
      message(FATAL_ERROR "Source file ${SRC_PATH} not found.")
    endif()
    add_executable(${PROG} ${SRC_PATH})
    target_include_directories(${PROG} PRIVATE ${INC_DIR})
    target_link_libraries(${PROG} PRIVATE ltpcore_static bpcore_static icicore_static m pthread)
    set_target_properties(${PROG} PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}
    )
  endif()
endforeach()

# CFDP executables
foreach(PROG IN LISTS CFDP_PROGRAMS)
  if(${PROG} IN_LIST ALL_PROGRAMS) # Only build if it's in the master PROGRAMS list
    if(NOT EXISTS "${SRC_DIR}/cfdp/${PROG}.c")
      message(FATAL_ERROR "Source file ${SRC_DIR}/cfdp/${PROG}.c not found.")
    endif()
    add_executable(${PROG} ${SRC_DIR}/cfdp/${PROG}.c)
    target_include_directories(${PROG} PRIVATE ${INC_DIR})
    target_link_libraries(${PROG} PRIVATE cfdpcore_static bpcore_static icicore_static m pthread)
    set_target_properties(${PROG} PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}
    )
  endif()
endforeach()

# ionrestart executable (only build if it's in the master PROGRAMS list)
if("ionrestart" IN_LIST ALL_PROGRAMS)
  add_executable(ionrestart ${SRC_DIR}/restart/ionrestart.c)
  target_include_directories(ionrestart PRIVATE ${INC_DIR})
  target_link_libraries(ionrestart PRIVATE cfdpcore_static ltpcore_static bpcore_static icicore_static m pthread)
  set_target_properties(ionrestart PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}
  )
endif()

install(TARGETS ${ALL_PROGRAMS}
  RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
)

# Man Pages (only programs with .pod files)
set(MAN_PROGRAMS
  ${ICI_PROGRAMS}
  ${BP_EXECUTABLES}
  ${LTP_PROGRAMS}
  ${CFDP_PROGRAMS}
  ionrestart
)
# Exclude ionwarn, ltpdeliv from MAN Pages
list(REMOVE_ITEM MAN_PROGRAMS ionwarn ltpdeliv)


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

# Generate list of executable paths for uninstall
set(ALL_PROGRAMS_FILES)
foreach(PROG IN LISTS ALL_PROGRAMS)
  list(APPEND ALL_PROGRAMS_FILES ${CMAKE_INSTALL_PREFIX}/bin/${PROG})
endforeach()

# Generate list of man page paths for uninstall
set(MAN_PAGES_FILES)
foreach(PROG IN LISTS MAN_PROGRAMS)
  list(APPEND MAN_PAGES_FILES ${CMAKE_INSTALL_PREFIX}/share/man/man1/${PROG}.1.gz)
endforeach()

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
  COMMAND ${CMAKE_COMMAND} -E remove -f
    ${ALL_PROGRAMS_FILES}
    ${CMAKE_INSTALL_PREFIX}/bin/ionstart
    ${CMAKE_INSTALL_PREFIX}/bin/ionstart.awk
    ${CMAKE_INSTALL_PREFIX}/bin/ionstop
    ${CMAKE_INSTALL_PREFIX}/bin/killm
  COMMAND ${CMAKE_COMMAND} -E remove -f
    ${MAN_PAGES_FILES}
  COMMENT "Uninstalling ION-Core: libraries, binaries, scripts, man pages"
)

# --- Test Target ---
# This section mimics the 'test' target from your Makefile.
# It uses the 'COMBINATION_TESTS' variable defined in build-list.cmake.

set(ALL_TESTS_TO_RUN "")

foreach(COMBO_ENTRY IN LISTS COMBINATION_TESTS)
  # Split the combination entry into program part and test part
  string(REPLACE ":" ";" COMBO_PARTS "${COMBO_ENTRY}")
  list(GET COMBO_PARTS 0 COMB_PROGS_STR)
  list(GET COMBO_PARTS 1 TESTS_TO_RUN_STR)

  # Convert the program combination string to a CMake list
  string(REPLACE "+" ";" CURRENT_COMBO_PROGS "${COMB_PROGS_STR}")
  # Convert the tests to run string to a CMake list. No regex replace to preserve slashes.
  string(REPLACE "+" ";" CLEANED_TESTS_TO_RUN "${TESTS_TO_RUN_STR}")
  
  set(COMB_FOUND TRUE)
  foreach(PROG IN LISTS CURRENT_COMBO_PROGS)
    # Check if the program exists in the ALL_PROGRAMS list
    list(FIND ALL_PROGRAMS "${PROG}" PROG_INDEX)
    if(PROG_INDEX EQUAL -1)
      set(COMB_FOUND FALSE)
      break()
    endif()
  endforeach()

  if(COMB_FOUND)
    message(STATUS "Combination found: ${COMB_PROGS_STR}. Adding tests: ${CLEANED_TESTS_TO_RUN}")
    list(APPEND ALL_TESTS_TO_RUN ${CLEANED_TESTS_TO_RUN})
  else()
    message(STATUS "Combination not found (one or more programs not built): ${COMB_PROGS_STR}")
  endif()
endforeach()

# Pass the CMake list directly to the COMMAND, so each element is a separate argument.
add_custom_target(test
  COMMAND
    ${CMAKE_COMMAND} -E chdir ${TESTS_DIR} ./runtests ${ALL_TESTS_TO_RUN}
  COMMENT "Running selected tests based on enabled programs (mimics Makefile 'test' target)."
)