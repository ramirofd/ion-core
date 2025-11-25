#!/usr/bin/env bash
#
# setup-submodule.sh - Initialize and configure ION-DTN submodule for ion-core-dev
#
# This script replaces extract.sh in the submodule-based workflow.
# It initializes the ION-DTN submodule and configures sparse-checkout.
#
# Usage: ./scripts/setup-submodule.sh [--help]
#

set -e  # Exit on error

# Script directory and repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ION_DTN_PATH="$REPO_ROOT/external/ION-DTN"

# Read expected ION-DTN tag/commit from version file
VERSION_FILE="$REPO_ROOT/ION_DTN_VERSION"
if [ ! -f "$VERSION_FILE" ]; then
    print_error "ION_DTN_VERSION file not found at $VERSION_FILE"
    exit 1
fi
# Read the tag, skipping comments and empty lines
EXPECTED_TAG=$(grep -v '^#' "$VERSION_FILE" | grep -v '^[[:space:]]*$' | head -n1 | tr -d '[:space:]')
if [ -z "$EXPECTED_TAG" ]; then
    print_error "No valid tag found in $VERSION_FILE"
    exit 1
fi

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

Initialize and configure the ION-DTN submodule for ion-core-dev.

OPTIONS:
    --help          Show this help message
    --update        Update submodule to latest commit (use with caution)
    --verify-only   Only verify submodule status without making changes

DESCRIPTION:
    This script performs the following operations:
    1. Checks if git submodules are configured
    2. Initializes the ION-DTN submodule if needed
    3. Checks out the expected tag ($EXPECTED_TAG)
    4. Configures sparse-checkout to reduce repository size
    5. Verifies the submodule is ready for building

EXAMPLES:
    # Normal usage (run before building):
    $0

    # Verify submodule status:
    $0 --verify-only

    # Update submodule reference:
    $0 --update

EOF
}

verify_git_repo() {
    if [ ! -d "$REPO_ROOT/.git" ]; then
        print_error "Not in a git repository. Are you in the ion-core-dev directory?"
        exit 1
    fi
}

check_git_submodules() {
    if [ ! -f "$REPO_ROOT/.gitmodules" ]; then
        print_error ".gitmodules not found. Submodule configuration is missing."
        print_info "Expected submodule configuration in $REPO_ROOT/.gitmodules"
        exit 1
    fi

    if ! grep -q "external/ION-DTN" "$REPO_ROOT/.gitmodules"; then
        print_error "ION-DTN submodule not configured in .gitmodules"
        exit 1
    fi

    print_success "✓ Submodule configuration found"
}

initialize_submodule() {
    print_info "Initializing ION-DTN submodule..."

    cd "$REPO_ROOT"

    if [ ! -d "$ION_DTN_PATH/.git" ]; then
        # Sync submodule configuration first (in case it was cleaned)
        print_info "Syncing submodule configuration..."
        git submodule sync 2>/dev/null || true

        print_info "Submodule not initialized. Running: git submodule update --init (non-recursive)"
        if ! git submodule update --init external/ION-DTN; then
            print_error "Failed to initialize submodule"
            print_info "Try running: git submodule init && git submodule update external/ION-DTN"
            exit 1
        fi
        print_success "✓ Submodule initialized (without nested submodules)"
    else
        print_success "✓ Submodule already initialized"
    fi
}

checkout_expected_tag() {
    print_info "Checking out ION-DTN tag: $EXPECTED_TAG"

    cd "$ION_DTN_PATH"

    # Fetch tags if needed
    if ! git rev-parse "$EXPECTED_TAG" >/dev/null 2>&1; then
        print_info "Tag $EXPECTED_TAG not found locally. Fetching from remote..."
        git fetch --tags
    fi

    # Check if we're already on the expected tag
    current_ref=$(git describe --tags --exact-match 2>/dev/null || echo "")
    if [ "$current_ref" = "$EXPECTED_TAG" ]; then
        print_success "✓ Already on tag $EXPECTED_TAG"
    else
        print_info "Checking out tag $EXPECTED_TAG..."
        if ! git checkout "$EXPECTED_TAG" 2>/dev/null; then
            print_error "Failed to checkout tag $EXPECTED_TAG"
            exit 1
        fi
        print_success "✓ Checked out tag $EXPECTED_TAG"
    fi
}

configure_sparse_checkout() {
    print_info "Configuring sparse-checkout..."

    cd "$ION_DTN_PATH"

    # Check if sparse-checkout is already configured
    if git sparse-checkout list >/dev/null 2>&1; then
        current_patterns=$(git sparse-checkout list | tr '\n' ' ')
        print_info "Current sparse-checkout patterns: $current_patterns"

        # Check if our required directories are included
        required_dirs=("ici" "bpv7" "ltp" "cfdp" "restart" "tests")
        all_present=true
        for dir in "${required_dirs[@]}"; do
            if ! git sparse-checkout list | grep -q "^$dir$"; then
                all_present=false
                break
            fi
        done

        if [ "$all_present" = true ]; then
            print_success "✓ Sparse-checkout already configured correctly"
            return 0
        fi
    fi

    print_info "Setting up sparse-checkout patterns..."

    # Initialize sparse-checkout in cone mode
    if ! git sparse-checkout init --cone 2>/dev/null; then
        print_warning "Sparse-checkout init returned non-zero, continuing..."
    fi

    # Set sparse-checkout paths
    if ! git sparse-checkout set ici/ bpv7/ ltp/ cfdp/ restart/ tests/; then
        print_error "Failed to configure sparse-checkout"
        exit 1
    fi

    print_success "✓ Sparse-checkout configured"
    print_info "  Checked out directories: ici, bpv7, ltp, cfdp, restart, tests"
}

verify_submodule_contents() {
    print_info "Verifying submodule contents..."

    required_dirs=("ici" "bpv7" "ltp" "cfdp" "restart" "tests")
    missing_dirs=()

    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$ION_DTN_PATH/$dir" ]; then
            missing_dirs+=("$dir")
        fi
    done

    if [ ${#missing_dirs[@]} -gt 0 ]; then
        print_error "Missing required directories: ${missing_dirs[*]}"
        print_info "Try running: git sparse-checkout disable && git checkout ."
        exit 1
    fi

    # Check for key source files
    if [ ! -f "$ION_DTN_PATH/ici/library/ion.c" ]; then
        print_error "Critical file missing: ici/library/ion.c"
        exit 1
    fi

    if [ ! -f "$ION_DTN_PATH/bpv7/library/libbp.c" ]; then
        print_error "Critical file missing: bpv7/library/libbp.c"
        exit 1
    fi

    print_success "✓ Submodule contents verified"
}

print_summary() {
    print_info ""
    print_success "========================================="
    print_success "ION-DTN Submodule Setup Complete"
    print_success "========================================="
    print_info ""
    print_info "Submodule location: $ION_DTN_PATH"
    print_info "ION-DTN version:    $EXPECTED_TAG"
    print_info ""
    print_info "The ion-core-dev build system is now ready."
    print_info "You can proceed with:"
    print_info "  - make           (for Makefile build)"
    print_info "  - cmake ..       (for CMake build from build/ directory)"
    print_info ""
}

# Main script
main() {
    local verify_only=false
    local update_mode=false

    # Parse arguments
    for arg in "$@"; do
        case $arg in
            --help)
                print_usage
                exit 0
                ;;
            --verify-only)
                verify_only=true
                ;;
            --update)
                update_mode=true
                ;;
            *)
                print_error "Unknown option: $arg"
                print_usage
                exit 1
                ;;
        esac
    done

    print_info "ION-Core-Dev: ION-DTN Submodule Setup"
    print_info "========================================"
    print_info ""

    # Step 1: Verify git repository
    verify_git_repo

    # Step 2: Check submodule configuration
    check_git_submodules

    if [ "$verify_only" = true ]; then
        print_info "Verify-only mode: checking submodule status"
        if [ -d "$ION_DTN_PATH/.git" ]; then
            cd "$ION_DTN_PATH"
            current_ref=$(git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD)
            print_info "Current submodule ref: $current_ref"
            print_info "Expected tag: $EXPECTED_TAG"

            if [ "$current_ref" = "$EXPECTED_TAG" ]; then
                print_success "✓ Submodule is on expected tag"
            else
                print_warning "⚠ Submodule is NOT on expected tag"
            fi
        else
            print_warning "⚠ Submodule not initialized"
        fi
        exit 0
    fi

    # Step 3: Initialize submodule
    initialize_submodule

    # Step 4: Checkout expected tag
    if [ "$update_mode" = true ]; then
        print_warning "Update mode: will fetch latest changes"
        cd "$ION_DTN_PATH"
        git fetch --all --tags
    fi
    checkout_expected_tag

    # Step 5: Configure sparse-checkout
    configure_sparse_checkout

    # Step 6: Verify contents
    verify_submodule_contents

    # Step 7: Print summary
    print_summary
}

# Run main function
main "$@"
