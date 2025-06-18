# ION-Core CMake Prototype Build Instructions

June, 2025

This document provides simple, step-by-step instructions to build, test, uninstall, and clean up the ION-Core project using CMake. These instructions are based on the `CMakeLists.txt` for ION-Core version 4.1.3.

**Key Change:** Project configuration (like enabled programs, OS flags, and extension flags) is now primarily controlled by `build-list.cmake`. This file acts as the central configuration for your build.

## CMake Build Commands

The following commands are used to manage the build process in a `build` directory:

* **Configure the build system**:

    ```bash
    cmake ..
    ```

    This command generates build files (e.g., `Makefile`) based on `CMakeLists.txt` and the settings in `build-list.cmake`. Run this from your `build` directory.

* **Build the project**:

    ```bash
    make
    ```

    This compiles libraries (e.g., `libicicore.a`, `libbpcore.so`) and executables (e.g., `ionadmin`, `bpadmin`) into the project's `lib` and `bin` directories.

* **Generate man pages**:

    ```bash
    make man
    ```

    This creates compressed man pages (e.g., `man/ionadmin.1.gz`) from `.pod` files.

* **Install the project**:

    ```bash
    sudo make install
    ```

    This installs libraries to `/usr/local/lib`, executables and scripts to `/usr/local/bin`, and man pages to `/usr/local/share/man/man1`.

* **Uninstall the project**:

    ```bash
    sudo make uninstall
    ```

    This removes installed files from `/usr/local/lib`, `/usr/local/bin`, and `/usr/local/share/man/man1`.

* **Clean build artifacts**:

    ```bash
    make clean_all
    ```

    This removes files generated during the build in `lib`, `bin`, and `man` directories, while preserving essential files like `.gitkeep` and specific scripts.

* **Full cleanup**:

    ```bash
    make distclean
    ```

    This performs a complete cleanup, removing all extracted source files, headers, and all generated files in `src`, `inc`, `lib`, `bin`, `man`, `tests`, and other specific project files.

* **Verbose output (for debugging)**:

    ```bash
    make <target> VERBOSE=1
    ```

    Shows detailed command execution (e.g., `make uninstall VERBOSE=1`).

## Build, Test, Uninstall, and Cleanup Process

Follow these steps to manage your ION-Core project. The process assumes you’re starting from the project root directory (e.g., `/home/jgao/iondev/ion-core-dev`) and have run `extract.sh` to populate `src` and `inc`.

### Prerequisites

* Ensure `extract.sh` has been run to populate `src` and `inc`:

    ```bash
    ./extract.sh
    ```

* Verify required tools: CMake (3.10+), make, gcc, pod2man, gzip.

    ```bash
    cmake --version
    gcc --version
    pod2man --version
    gzip --version
    ```

* Create a `build` directory (if not already present) and navigate into it:

    ```bash
    mkdir build
    cd build
    ```

### 1. Build the Project

**Purpose**: Compile libraries, executables, and prepare for man page generation.

1.  **Configure CMake**:

    ```bash
    cmake ..
    ```

    * This step reads `CMakeLists.txt` and `build-list.cmake` to set up the build system.

    * Check for errors; if found, ensure `extract.sh` was run and `build-list.cmake` is correctly configured.

2.  **Build libraries and executables**:

    ```bash
    make
    ```

    * This compiles libraries and executables based on the programs enabled in `build-list.cmake`.

    * Verify artifacts:

        ```bash
        ls ../lib ../bin
        ```

3.  **Generate man pages**:

    ```bash
    make man
    ```

    * This creates compressed man pages for programs included in `MAN_PROGRAMS` as configured via `build-list.cmake`.

    * Verify:

        ```bash
        ls ../man/*.1.gz
        ```

### 2. Install the Project

**Purpose**: Install built components to the system's `/usr/local` directory.

1.  **Install**:

    ```bash
    sudo make install
    ```

    * This installs libraries, executables, scripts, and man pages. CMake automatically ensures man pages are generated before installation.

    * Verify:

        ```bash
        ls /usr/local/lib/libicicore*
        ls /usr/local/bin/ionadmin
        ls /usr/local/share/man/man1/ionadmin.1.gz
        ```

### 3. Test the Project

**Purpose**: Validate the built executables using test suites configured in `build-list.cmake`.

1.  **Run Tests**:

    ```bash
    make test
    ```

    * This command uses the test mapping defined in `build-list.cmake` to execute the relevant `runtests` script with the specified test suites.

    * Verify test results by examining the output in your terminal.

### 4. Uninstall the Project

**Purpose**: Remove installed files from `/usr/local`.

1.  **Uninstall**:

    ```bash
    sudo make uninstall
    ```

    * This removes libraries, executables, scripts, and man pages installed previously.

    * Verify by checking that the files are no longer present in the installation paths.

### 5. Clean Up Build Artifacts

**Purpose**: Remove intermediate build artifacts from the project's build directories.

1.  **Clean**:

    ```bash
    make clean_all
    ```

    * This clears build artifacts from `lib`, `bin`, and `man` directories.

### 6. Perform Full Cleanup

**Purpose**: Remove all extracted source files, headers, and all generated files to return the project to a pristine state.

1.  **Distclean**:

    ```bash
    make distclean
    ```

    * This removes all build-related files and symbolic links created by `extract.sh`.

### 7. Remove Build Directory

**Purpose**: Delete the `build` directory.

1.  **Remove**:

    ```bash
    cd ..
    rm -rf build
    ```

### 8. Verify Project State

**Purpose**: Confirm the project directory is clean and ready for a fresh build or archiving.

1.  **Check root**:

    ```bash
    ls -a .
    ```

    * You should mainly see source control files, original build scripts, and empty directories marked with `.gitkeep`.

## Notes

* **Permissions**: Use `sudo` for `make install` and `make uninstall`. User permissions suffice for other commands.

* **Configuration via `build-list.cmake`**: This file now defines:

    * The project version (`VER`).

    * Platform-specific compiler flags (`OS_FLAGS`).

    * Extension flags (`EXT_FLAGS`).

    * The list of all programs (`PROGRAMS`) to be built and installed.

    * The mapping of program combinations to test suites (`COMBINATION_TESTS`).

    * Modify `build-list.cmake` to customize your build configuration.

* **Custom Install Prefix**: If you specify a custom installation prefix (e.g., `cmake -DCMAKE_INSTALL_PREFIX=/custom/path ..`), remember to adjust your verification paths accordingly.

* **Rebuilding after `distclean`**: After running `make distclean`, you **must** re-run `./extract.sh` before attempting another build.