#!/usr/bin/env python3
"""
Script to generate correct CMake source file lists for ION-DTN submodule.
This script searches the ION-DTN directory structure and generates the correct
paths for library source files.
"""

import os
import sys
from pathlib import Path

def find_source_file(ion_dtn_dir, module, filename):
    """
    Find a source file in the ION-DTN directory structure.
    Searches common subdirectories.
    """
    search_dirs = [
        '',  # Root of module
        'library',
        'library/ext/bpsec',
        'library/ext/bpq',
        'library/ext/imc',
        'library/ext/snw',
        'library/ext/bae',
        'library/ext/pnb',
        'library/ext/meb',
        'library/ext/hcb',
        'library/ext/bibe',
        'library/ext/saga',
        'library/ext',
        'sdr',
        'crypto',
        'crypto/NULL_SUITES',
        'crypto/MBEDTLS_SUITES',
        'bulk/STUB_BULK',
        'cgr',
        'ipn',
        'stcp',
        'udp',
        'ltp',
        'bp',
        'bpsec',
        'bpsec/instr',
        'bpsec/policy',
        'bpsec/sci',
        'bpsec/utils',
        'imc',
        'bibe',
        'saga',
        'utils',
        'daemon',
        'test',
    ]

    module_path = Path(ion_dtn_dir) / module

    for subdir in search_dirs:
        file_path = module_path / subdir / filename
        if file_path.exists():
            # Return relative to ion_dtn_dir
            return str(file_path.relative_to(ion_dtn_dir))

    return None

def generate_cmake_sources(ion_dtn_dir, module, filenames):
    """
    Generate CMake source file list for a module.
    """
    cmake_lines = []
    not_found = []

    for filename in filenames:
        rel_path = find_source_file(ion_dtn_dir, module, filename)
        if rel_path:
            cmake_lines.append(f"  ${{SRC_DIR}}/{rel_path}")
        else:
            not_found.append(filename)

    return cmake_lines, not_found

def main():
    if len(sys.argv) < 2:
        print("Usage: generate_cmake_sources.py <path-to-ION-DTN>")
        sys.exit(1)

    ion_dtn_dir = Path(sys.argv[1])

    if not ion_dtn_dir.exists():
        print(f"Error: Directory {ion_dtn_dir} does not exist")
        sys.exit(1)

    # BP source files (from current CMakeLists.txt)
    bp_files = [
        'bae.c', 'bpsec_instr.c', 'bcb_aes_gcm_sc.c', 'bpsec_policy.c',
        'meb.c', 'bcb.c', 'bpsec_policy_event.c', 'libbp.c', 'pnb.c',
        'bei.c', 'bpsec_policy_eventset.c', 'eureka.c', 'libbpP.c',
        'rfc9173_utils.c', 'bib.c', 'bpsec_policy_rule.c', 'hcb.c',
        'libcgr.c', 'saga.c', 'bibe.c', 'bpsec_util.c', 'imc.c',
        'libimcfw.c', 'sci.c', 'bib_hmac_sha2_sc.c', 'ion_test_sc.c',
        'libipnfw.c', 'sci_valmap.c', 'bpq.c', 'libstcpcla.c',
        'sc_util.c', 'libudpcla.c', 'sc_value.c', 'bpsec_asb.c', 'snw.c'
    ]

    # CFDP source files (from current CMakeLists.txt)
    cfdp_files = [
        'bputa.c', 'libcfdp.c', 'libcfdpP.c', 'libcfdpops.c'
    ]

    print("=" * 80)
    print("Generating BP_SOURCES")
    print("=" * 80)
    bp_sources, bp_not_found = generate_cmake_sources(ion_dtn_dir, 'bpv7', bp_files)

    if bp_sources:
        print("\nset(BP_SOURCES")
        for line in bp_sources:
            print(line)
        print(")")

    if bp_not_found:
        print("\n# WARNING: The following files were not found:")
        for filename in bp_not_found:
            print(f"#   {filename}")

    print("\n" + "=" * 80)
    print("Generating CFDP_SOURCES")
    print("=" * 80)
    cfdp_sources, cfdp_not_found = generate_cmake_sources(ion_dtn_dir, 'cfdp', cfdp_files)

    if cfdp_sources:
        print("\nset(CFDP_SOURCES")
        for line in cfdp_sources:
            print(line)
        print(")")

    if cfdp_not_found:
        print("\n# WARNING: The following files were not found:")
        for filename in cfdp_not_found:
            print(f"#   {filename}")

    print("\n" + "=" * 80)
    print("Summary")
    print("=" * 80)
    print(f"BP files found: {len(bp_sources)}/{len(bp_files)}")
    print(f"CFDP files found: {len(cfdp_sources)}/{len(cfdp_files)}")

    if bp_not_found or cfdp_not_found:
        print("\nWARNING: Some files were not found. They may have been:")
        print("  - Renamed in the ION-DTN version")
        print("  - Moved to a different location")
        print("  - No longer needed")
        print("\nPlease review and update the file lists in CMakeLists.txt")

if __name__ == '__main__':
    main()
