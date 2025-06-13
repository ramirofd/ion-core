# ION-Core Compile Options

This table lists the compile options available in the `CMakeLists.txt` for the ION-Core project (version 4.1.3). These options control features, preprocessor macros, build types, and installation paths. The syntax is provided for use with the `cmake -D` command to customize the build process.

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