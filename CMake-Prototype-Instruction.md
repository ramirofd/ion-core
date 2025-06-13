# ION-Core CMake Prototype Build Instructions

June, 2025

This document provides a list of CMake build commands and a step-by-step process to build, test, uninstall, and clean up the ION-Core project using CMake. The instructions are based on the `CMakeLists.txt` for ION-Core version 4.1.3, which supports building static and shared libraries, executables, and man pages for the ICI, BP, LTP, CFDP, and ionrestart modules.

## CMake Build Commands

The following commands are used to manage the build process in a `build` directory:

- **Configure the build system**:
  ```bash
  cmake ..
  ```
  Generates build files (e.g., `Makefile`) based on `CMakeLists.txt`. Run from the `build` directory.

- **Build the project**:
  ```bash
  make
  ```
  Compiles libraries (e.g., `libicicore.a`, `libbpcore.so`) and executables (e.g., `ionadmin`, `bpadmin`) to `lib` and `bin` directories.

- **Generate man pages**:
  ```bash
  make man
  ```
  Creates compressed man pages (e.g., `man/ionadmin.1.gz`) from `.pod` files in `src/man`.

- **Install the project**:
  ```bash
  sudo make install
  ```
  Installs libraries to `/usr/local/lib`, executables and scripts to `/usr/local/bin`, and man pages to `/usr/local/share/man/man1`.

- **Uninstall the project**:
  ```bash
  sudo make uninstall
  ```
  Removes installed files from `/usr/local/lib`, `/usr/local/bin`, and `/usr/local/share/man/man1`.

- **Clean build artifacts**:
  ```bash
  make clean_all
  ```
  Removes files in `lib`, `bin`, and `man` directories, preserving `.gitkeep` and scripts (`ionstart`, `ionstart.awk`, `ionstop`, `killm`).

- **Full cleanup**:
  ```bash
  make distclean
  ```
  Removes all extracted source files, headers, and generated files in `src`, `inc`, `lib`, `bin`, `man`, `tests`, and specific files (`system_up`, `configs`, macOS scripts), preserving `.gitkeep`.

- **Verbose output (for debugging)**:
  ```bash
  make <target> VERBOSE=1
  ```
  Shows detailed command execution (e.g., `make uninstall VERBOSE=1`).

## Build, Test, Uninstall, and Cleanup Process

Follow these steps to build, test, uninstall, and clean up the ION-Core project. The process assumes you’re starting from the project root directory (`/home/jgao/iondev/ion-core-dev`) and have run `extract.sh` to populate `src` and `inc` with symbolic links from the ION-DTN repository.

### Prerequisites
- Ensure `extract.sh` has been run to populate `src` and `inc`:
  ```bash
  ./extract.sh
  ```
- Verify required tools: CMake (3.10+), make, gcc, pod2man, gzip.
  ```bash
  cmake --version
  gcc --version
  pod2man --version
  gzip --version
  ```
- Create a build directory if not already present:
  ```bash
  mkdir build
  cd build
  ```

### 1. Build the Project
**Purpose**: Compile libraries, executables, and prepare for man page generation.

1. **Configure CMake**:
   ```bash
   cmake ..
   ```
   - Generates `Makefile` and other build files.
   - Check for errors (e.g., missing source files). If errors occur, ensure `extract.sh` was run.

2. **Build libraries and executables**:
   ```bash
   make
   ```
   - Compiles:
     - Libraries: `lib/libicicore.a`, `libbpcore.so`, `libltpcore.a`, `libcfdpcore.so`, etc.
     - Executables: `bin/ionadmin`, `bin/bpadmin`, `bin/ltpcli`, `bin/cfdptest`, `bin/ionrestart`, etc.
   - Verify artifacts:
     ```bash
     ls ../lib ../bin
     ```

3. **Generate man pages**:
   ```bash
   make man
   ```
   - Creates man pages (e.g., `man/ionadmin.1.gz`) for programs in `MAN_PROGRAMS` (excluding `ionwarn`, `ltpdeliv`).
   - Verify:
     ```bash
     ls ../man/*.1.gz
     ```
   - If errors occur (e.g., missing `.pod` files), check `src/man`:
     ```bash
     ls ../src/man/*.pod
     ```
     Update `MAN_PROGRAMS` to exclude programs without `.pod` files (e.g., `bpcp`, `bpcpd`).

**Why**: Builds all components and prepares documentation for installation.

### 2. Install the Project
**Purpose**: Install libraries, executables, scripts, and man pages to `/usr/local`.

1. **Install**:
   ```bash
   sudo make install
   ```
   - Installs:
     - Libraries to `/usr/local/lib`.
     - Executables and scripts to `/usr/local/bin`.
     - Man pages to `/usr/local/share/man/man1`.
   - Verify:
     ```bash
     ls /usr/local/lib/libicicore* /usr/local/lib/libbpcore*
     ls /usr/local/bin/ionadmin /usr/local/bin/bpadmin /usr/local/bin/ltpcli
     ls /usr/local/share/man/man1/ionadmin.1.gz
     ls /usr/local/bin/ionstart
     ```

2. **Fix Errors**:
   - If man page errors occur (e.g., `ionadmin.1.gz` missing), ensure `make man` was run first.
   - If permission errors occur, verify `sudo` privileges.

**Why**: Makes ION-Core available system-wide.

### 3. Test the Project
**Purpose**: Validate the built or installed executables using tests defined in `build-list.mk` (e.g., `bping+bpecho+udpcli:bping/`).

1. **Run Tests Manually**:
   - Navigate to the `tests` directory:
     ```bash
     cd ../tests
     ```
   - Run a test (e.g., `bping`):
     ```bash
     ./runtests bping
     ```
   - If errors occur (e.g., `dirname: missing operand`), debug `runtests`:
     ```bash
     cat runtests
     ```
     Add `set -x` to `runtests` for debug output:
     ```bash
     nano runtests
     # Add at top: set -x
     ```
     Re-run:
     ```bash
     ./runtests bping
     ```
   - Ensure test directories exist (e.g., `tests/bping`):
     ```bash
     ls -ld bping
     ```
     If missing, restore from ION-DTN repository or create a placeholder:
     ```bash
     mkdir bping
     echo '#!/bin/bash\n../bin/bpecho &\n../bin/udpcli &\n../bin/bping' > bping/test.sh
     chmod +x bping/test.sh
     ```

2. **Add Test Target (Optional)**:
   - Update `CMakeLists.txt` to include a `test` target (add at the end):
     ```cmake
     add_custom_target(test
       COMMAND ${CMAKE_SOURCE_DIR}/tests/runtests bench-ltp bping bench-cfdp bptrace_terminal_test
       WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/tests
       COMMENT "Running ION-Core tests"
     )
     ```
   - Re-run CMake:
     ```bash
     cd ../build
     cmake ..
     ```
   - Run tests:
     ```bash
     make test
     ```

3. **Verify Test Results**:
   - Check `runtests` output for pass/fail status.
   - If tests fail, ensure executables (`bin/bping`, `bin/bpecho`, `bin/udpcli`) exist and test configurations are correct.

**Why**: Validates functionality, mirroring the `Makefile`’s `test` target.

### 4. Uninstall the Project
**Purpose**: Remove installed files from `/usr/local`.

1. **Uninstall**:
   ```bash
   sudo make uninstall
   ```
   - Removes libraries, executables, scripts, and man pages.
   - Verify:
     ```bash
     ls /usr/local/lib/libicicore* /usr/local/bin/ionadmin /usr/local/share/man/man1/ionadmin.1.gz /usr/local/bin/ionstart
     ```
     Expect `ls: cannot access ...: No such file or directory`.

2. **Fix Errors**:
   - If errors occur, manually remove files:
     ```bash
     sudo rm -f /usr/local/lib/libicicore* /usr/local/lib/libbpcore* /usr/local/lib/libltpcore* /usr/local/lib/libcfdpcore*
     sudo rm -f /usr/local/bin/ionadmin /usr/local/bin/ionwarn /usr/local/bin/rfxclock /usr/local/bin/psmwatch /usr/local/bin/sdrwatch
     sudo rm -f /usr/local/bin/bpadmin /usr/local/bin/bpclm /usr/local/bin/bpclock /usr/local/bin/bpversion /usr/local/bin/stcpcli /usr/local/bin/stcpclo /usr/local/bin/udpcli /usr/local/bin/udpclo /usr/local/bin/udplsi /usr/local/bin/udplso /usr/local/bin/bpchat /usr/local/bin/bpcounter /usr/local/bin/bpdriver /usr/local/bin/bpecho /usr/local/bin/bping /usr/local/bin/bplist /usr/local/bin/bprecvfile /usr/local/bin/bpsendfile /usr/local/bin/bpsink /usr/local/bin/bpsource /usr/local/bin/bpstats /usr/local/bin/bptrace /usr/local/bin/bptransit /usr/local/bin/ipnadmin /usr/local/bin/ipnadminep /usr/local/bin/ipnfw /usr/local/bin/lgagent /usr/local/bin/lgsend
     sudo rm -f /usr/local/bin/ltpadmin /usr/local/bin/ltpclock /usr/local/bin/ltpmeter /usr/local/bin/ltpdeliv /usr/local/bin/ltpcli /usr/local/bin/ltpclo
     sudo rm -f /usr/local/bin/bpcp /usr/local/bin/bpcpd /usr/local/bin/cfdpadmin /usr/local/bin/cfdpclock /usr/local/bin/cfdptest
     sudo rm -f /usr/local/bin/ionrestart
     sudo rm -f /usr/local/bin/ionstart /usr/local/bin/ionstart.awk /usr/local/bin/ionstop /usr/local/bin/killm
     sudo rm -f /usr/local/share/man/man1/*.1.gz
     ```

**Why**: Removes system-wide files installed by `make install`.

### 5. Clean Up Build Artifacts
**Purpose**: Remove intermediate build artifacts from `bin`, `lib`, and `man`.

1. **Clean**:
   ```bash
   make clean_all
   ```

2. **Verify**:
   - Check directories:
     ```bash
     ls ../lib ../bin ../man
     ```
     Expect:
     - `lib`: `.gitkeep`
     - `bin`: `.gitkeep`, `ionstart`, `ionstart.awk`, `ionstop`, `killm` (if present)
     - `man`: `.gitkeep`

3. **Fix Errors**:
   - Manually remove files:
     ```bash
     rm -f ../lib/* ../bin/* ../man/*
     touch ../lib/.gitkeep ../bin/.gitkeep ../man/.gitkeep
     ```

**Why**: Clears build artifacts, mirroring the `Makefile`’s `clean` target.

### 6. Perform Full Cleanup
**Purpose**: Remove all extracted source files, headers, and generated files.

1. **Distclean**:
   ```bash
   make distclean
   ```

2. **Verify**:
   - Check directories:
     ```bash
     ls -a ../inc ../src ../lib ../bin ../man ../tests
     ```
     Expect only `.gitkeep`.
   - Check removed files:
     ```bash
     ls -l ../system_up ../configs ../scripts/macOS/install_macos_sysctl.sh ../scripts/macOS/sysctl_script.sh
     ```
     Expect `ls: cannot access ...: No such file or directory`.

3. **Fix Errors**:
   - Manually remove files:
     ```bash
     find ../inc -mindepth 1 ! -name '.gitkeep' -delete
     find ../src -mindepth 1 ! -name '.gitkeep' -delete
     find ../lib -mindepth 1 ! -name '.gitkeep' -delete
     find ../bin -mindepth 1 ! -name '.gitkeep' -delete
     find ../man -mindepth 1 ! -name '.gitkeep' -delete
     find ../tests -mindepth 1 ! -name '.gitkeep' -delete
     rm -f ../system_up ../configs ../scripts/macOS/install_macos_sysctl.sh ../scripts/macOS/sysctl_script.sh
     touch ../inc/.gitkeep ../src/.gitkeep ../lib/.gitkeep ../bin/.gitkeep ../man/.gitkeep ../tests/.gitkeep
     ```

**Why**: Removes all extracted files, mirroring the `Makefile`’s `distclean` target.

### 7. Remove Build Directory
**Purpose**: Delete the `build` directory.

1. **Remove**:
   ```bash
   cd ..
   rm -rf build
   ```

2. **Verify**:
   ```bash
   ls -ld build
   ```
   Expect `ls: cannot access 'build': No such file or directory`.

**Why**: Ensures a clean slate.

### 8. Verify Project State
**Purpose**: Confirm the project directory is clean.

1. **Check root**:
   ```bash
   ls -a .
   ```
   Expect `CMakeLists.txt`, `build-list.mk`, `developer-notes.md`, `extract.sh`, `.mk` files, and directories with `.gitkeep`.

2. **Check residuals**:
   ```bash
   find . -type f ! -name '.gitkeep' ! -name 'CMakeLists.txt' ! -name 'build-list.mk' ! -name 'developer-notes.md' ! -name 'extract.sh' ! -name '*.mk'
   ```
   Remove unexpected files:
   ```bash
   rm -f <unexpected_file>
   ```

**Why**: Ensures the project is ready for a fresh build or archival.

## Notes
- **Permissions**: Use `sudo` for `make install` and `make uninstall`. User permissions suffice for other commands.
- **Custom Install Prefix**: If using `-DCMAKE_INSTALL_PREFIX=/custom/path`, adjust verification paths.
- **Testing**: If `runtests` fails (e.g., `dirname: missing operand` for `bping`), debug `tests/runtests` or ensure test directories exist.
- **Rebuilding**: Run `./extract.sh` after `distclean` to repopulate `src` and `inc`.
- **Contributing**: Update `developer-notes.md` with CMake transition details for `nasa-jpl/ion-core`.

## CMake Compile Options

This table lists the compile options available in the `CMakeLists.txt` for the ION-Core project (version 4.1.3s). These options control features, preprocessor macros, build types, and installation paths. The syntax is provided for use with the `cmake -D` command to customize the build process.

| Option Name            | Description                                      | Default Value | Possible Values                     | Syntax Example                                      |
|------------------------|--------------------------------------------------|---------------|-------------------------------------|----------------------------------------------------|
| `ENABLE_BPQ_EXT`       | Enables Bundle Protocol QoS Extension Block, defining `-DBPQ_EXT` | `ON`          | `ON`, `OFF`                         | `cmake -DENABLE_BPQ_EXT=OFF ..`                    |
| `ENABLE_IMC_EXT`       | Enables IMC Multicast Extension Block, defining `-DIMC_EXT` | `ON`          | `ON`, `OFF`                         | `cmake -DENABLE_IMC_EXT=ON ..`                     |
| `CMAKE_BUILD_TYPE`     | Sets build type, affecting optimization and debug settings | `Debug` (implied by `-g`) | `Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel` | `cmake -DCMAKE_BUILD_TYPE=Release ..`              |
| `CMAKE_INSTALL_PREFIX` | Specifies the installation directory for libraries, executables, and man pages | `/usr/local`  | Any valid path                      | `cmake -DCMAKE_INSTALL_PREFIX=/custom/path ..`     |
| `CMAKE_SYSTEM_NAME`    | Overrides platform detection to set macros like `-Dlinux`, `-Ddarwin`, `-Dfreebsd` | System default (e.g., `Linux`) | `Linux`, `Darwin`, `FreeBSD` | `cmake -DCMAKE_SYSTEM_NAME=Darwin ..`              |
| `CUSTOM_FEATURE`       | Example custom macro (requires adding to `CMakeLists.txt`) | N/A           | `ON`, `OFF`, or custom value        | `cmake -DCUSTOM_FEATURE=ON ..`                     |
| `CMAKE_C_FLAGS`        | Custom compiler flags to add or override default flags (`-g -Wall -DBP_EXTENDED -fPIC`) | `-g -Wall -DBP_EXTENDED -fPIC` | Any valid compiler flags             | `cmake -DCMAKE_C_FLAGS="-DMY_MACRO=1" ..`          |

## Notes
- **Explicit Options**: `ENABLE_BPQ_EXT` and `ENABLE_IMC_EXT` are defined in `CMakeLists.txt` and control `-DBPQ_EXT` and `-DIMC_EXT` macros, respectively.
- **Implicit Options**: `CMAKE_BUILD_TYPE` and `CMAKE_INSTALL_PREFIX` are standard CMake variables, configurable via `-D`.
- **Platform Macros**: `-Dlinux`, `-Ddarwin`, `-Dfreebsd`, and `-DSPACE_ORDER` are set based on `CMAKE_SYSTEM_NAME` and architecture detection.
- **Custom Macro Example**: To add `CUSTOM_FEATURE`, modify `CMakeLists.txt`:
  ```cmake
  set(CUSTOM_FEATURE OFF CACHE BOOL "Enable custom feature")
  if(CUSTOM_FEATURE)
    add_definitions(-DCUSTOM_FEATURE)
  endif()
  ```
- **Verification**: Check applied options with:
  ```bash
  cmake -LA | grep ENABLE
  make VERBOSE=1
  ```