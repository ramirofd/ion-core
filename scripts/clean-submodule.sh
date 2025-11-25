#!/usr/bin/env bash
#
# clean-submodule.sh - Clean and deinitialize ION-DTN submodule
#
# This script completely removes the ION-DTN submodule and cleans up
# all git submodule state, allowing for a fresh initialization.
#
# Usage: ./scripts/clean-submodule.sh [--help]
#

set -e  # Exit on error

# Script directory and repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ION_DTN_PATH="$REPO_ROOT/external/ION-DTN"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

print_info() {
    echo "$1"
}

print_usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Clean and deinitialize the ION-DTN submodule for fresh initialization.

OPTIONS:
    --help          Show this help message
    --force         Skip confirmation prompt

DESCRIPTION:
    This script performs the following operations:
    1. Deinitializes the ION-DTN submodule
    2. Removes the submodule directory
    3. Cleans git cache and configuration
    4. Prepares for fresh submodule initialization

EXAMPLES:
    # Normal usage (with confirmation):
    $0

    # Skip confirmation:
    $0 --force

    # After cleaning, reinitialize with:
    ./scripts/setup-submodule.sh

EOF
}

verify_git_repo() {
    if [ ! -d "$REPO_ROOT/.git" ]; then
        print_error "Not in a git repository. Are you in the ion-core-dev directory?"
        exit 1
    fi
}

# Main script
main() {
    local force=false

    # Parse arguments
    for arg in "$@"; do
        case $arg in
            --help)
                print_usage
                exit 0
                ;;
            --force)
                force=true
                ;;
            *)
                print_error "Unknown option: $arg"
                print_usage
                exit 1
                ;;
        esac
    done

    print_info "ION-Core-Dev: Clean ION-DTN Submodule"
    print_info "======================================"
    print_info ""

    # Step 1: Verify git repository
    verify_git_repo

    # Step 2: Check if submodule exists
    if [ ! -d "$ION_DTN_PATH" ]; then
        print_warning "ION-DTN submodule directory does not exist at $ION_DTN_PATH"
        print_info "Nothing to clean."
        exit 0
    fi

    # Step 3: Confirm with user (unless --force)
    if [ "$force" = false ]; then
        print_warning "This will remove the ION-DTN submodule at:"
        print_info "  $ION_DTN_PATH"
        print_info ""
        read -p "Are you sure you want to continue? (y/N): " -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Aborted."
            exit 0
        fi
    fi

    cd "$REPO_ROOT"

    print_info "Cleaning ION-DTN submodule..."
    print_info ""

    # Step 4: Deinitialize the submodule
    if [ -d "$ION_DTN_PATH/.git" ]; then
        print_info "Deinitializing submodule..."
        if git submodule deinit -f external/ION-DTN 2>/dev/null; then
            print_success "✓ Submodule deinitialized"
        else
            print_warning "Failed to deinitialize (may already be deinitialized)"
        fi
    else
        print_info "Submodule already deinitialized"
    fi

    # Step 5: Remove the submodule directory contents (but keep .git)
    if [ -d "$ION_DTN_PATH" ]; then
        print_info "Removing submodule directory..."
        if rm -rf "$ION_DTN_PATH"; then
            print_success "✓ Submodule directory removed"
        else
            print_error "Failed to remove $ION_DTN_PATH"
            exit 1
        fi
    fi

    # Note: We do NOT run 'git rm --cached' because that would remove the submodule
    # from git's index, making it impossible to reinitialize without re-adding it to .gitmodules

    # Step 7: Summary
    print_info ""
    print_success "========================================="
    print_success "ION-DTN Submodule Cleaned"
    print_success "========================================="
    print_info ""
    print_info "The ION-DTN submodule has been completely removed."
    print_info "To reinitialize the submodule, run:"
    print_info "  ./scripts/setup-submodule.sh"
    print_info ""
}

# Run main function
main "$@"
