#!/usr/bin/env bash

ION_SRC="$1" # ION source directory (either external/ION-DTN or legacy src via extract.sh)
PROGRAMS="$2"

# Check if ION_SRC is provided
if [[ -z "$ION_SRC" ]]; then
  echo "Error: You must supply a path to ION source directory."
  exit 1
fi

# Check if PROGRAMS is provided
if [[ -z "$PROGRAMS" ]]; then
  echo "Error: You must supply a list of programs."
  exit 1
fi

POD2MAN=pod2man
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAN_OUTPUT_DIR="${SCRIPT_DIR}/../man"

# Define pod file search paths (for both ION-DTN submodule and extract.sh methods)
POD_SEARCH_PATHS=(
  "${ION_SRC}"                    # For extract.sh method (flat directory)
  "${ION_SRC}/man"                # Alternative flat directory location
  "${ION_SRC}/ici/doc/pod1"       # For submodule method
  "${ION_SRC}/bpv7/doc/pod1"
  "${ION_SRC}/ltp/doc/pod1"
  "${ION_SRC}/cfdp/doc/pod1"
  "${ION_SRC}/restart/doc/pod1"
)

# Ensure the man output directory exists
mkdir -p "$MAN_OUTPUT_DIR"

# Split PROGRAMS into an array
IFS=' ' read -r -a prog_array <<< "$PROGRAMS"

# Debugging output
echo "ION source directory = $ION_SRC"
echo "Man page output directory = $MAN_OUTPUT_DIR"

for prog in "${prog_array[@]}"; do
    found=0

    # Search for pod file in all possible locations
    for pod_dir in "${POD_SEARCH_PATHS[@]}"; do
        full_path="${pod_dir}/${prog}.pod"

        if [[ -f "$full_path" ]]; then
            echo "Found pod file: $full_path"
            if $POD2MAN "$full_path" | gzip -c > "${MAN_OUTPUT_DIR}/${prog}.1.gz"; then
                echo "Generated man page for $prog"
                found=1
                break
            else
                echo "ERROR: Failed to generate man page for $prog"
            fi
        fi
    done

    if [[ $found -eq 0 ]]; then
        echo "WARNING: Documentation for $prog is not available in any of the search paths."
    fi
done
