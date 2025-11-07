# ION-Core-Dev Submodule Workflow Guide

This guide explains how to work with the ion-core-dev repository now that it uses ION-DTN as a git submodule.

## Table of Contents

1. [Overview](#overview)
2. [Initial Setup](#initial-setup)
3. [Building ion-core-dev](#building-ion-core-dev)
4. [Working with the Submodule](#working-with-the-submodule)
5. [Contributing Changes to ION-DTN](#contributing-changes-to-ion-dtn)
6. [Updating ION-DTN Version](#updating-ion-dtn-version)
7. [Troubleshooting](#troubleshooting)

---

## Overview

### What Changed?

Previously, ion-core-dev used an `extract.sh` script that downloaded ION-DTN source files and created symlinks. Now, ION-DTN is integrated as a **git submodule** located at `external/ION-DTN/`.

**Benefits of the submodule approach:**
- Cleaner version tracking (submodule points to specific ION-DTN tag/commit)
- Better git integration (no manual download step)
- Sparse-checkout reduces disk usage (only needed directories)
- Bi-directional development (changes can be pushed back to ION-DTN)
- Simplified dependency management

### Architecture

```
ion-core-dev/
  external/
    ION-DTN/           # Git submodule (ION-DTN repository)
      ici/             # Checked out via sparse-checkout
      bpv7/            # Checked out via sparse-checkout
      ltp/             # Checked out via sparse-checkout
      cfdp/            # Checked out via sparse-checkout
      restart/         # Checked out via sparse-checkout
      tests/           # Checked out via sparse-checkout
  scripts/
    setup-submodule.sh # Submodule initialization script
  Makefile             # References external/ION-DTN
  CMakeLists.txt       # References external/ION-DTN
  ...
```

---

## Initial Setup

### For New Clones

When cloning ion-core-dev for the first time:

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/nasa-jpl/ion-core-dev.git
cd ion-core-dev

# Setup and verify submodule
./scripts/setup-submodule.sh

# You're ready to build!
make
```

### For Existing Clones (Migration)

If you already have an ion-core-dev clone from before the submodule migration:

```bash
cd /path/to/ion-core-dev

# Pull the latest changes
git pull origin integration

# Initialize the new submodule
git submodule update --init --recursive

# Setup sparse-checkout and verify
./scripts/setup-submodule.sh

# Clean up old extracted files (optional)
rm -rf tmp/          # Old ION-DTN downloads
rm -rf src/          # Old symlinked source files
rm -rf inc/          # Old symlinked headers

# You're ready to build!
make
```

---

## Building ion-core-dev

### Using Makefile (Traditional Build)

```bash
# Setup submodule (first time or after git pull)
./scripts/setup-submodule.sh

# Build everything
make

# Build libraries
make static    # Static libraries (.a)
make shared    # Shared libraries (.so)

# Install
sudo make install
sudo make install-lib

# Generate man pages
make man

# Run tests
make test

# Clean
make clean
make distclean
```

### Using CMake (Prototype Build)

```bash
# Setup submodule (first time or after git pull)
./scripts/setup-submodule.sh

# Create build directory
mkdir -p build
cd build

# Configure
cmake ..

# Build
make

# Generate man pages
make man

# Install
sudo make install

# Run tests
make test

# Clean
cd ..
rm -rf build
```

---

## Working with the Submodule

### Checking Submodule Status

```bash
# Show current submodule commit
git submodule status

# Show which ION-DTN tag/version is checked out
cd external/ION-DTN
git describe --tags
```

### Viewing Sparse-Checkout Configuration

```bash
cd external/ION-DTN
git sparse-checkout list
```

Expected output:
```
bpv7
cfdp
ici
ltp
restart
tests
```

### Disabling Sparse-Checkout (Full ION-DTN Checkout)

If you need access to all ION-DTN files temporarily:

```bash
cd external/ION-DTN
git sparse-checkout disable
git checkout .
```

To re-enable:

```bash
./scripts/setup-submodule.sh
```

---

## Contributing Changes to ION-DTN

The submodule approach supports **bi-directional development**: you can make changes in ion-core-dev and push them back to ION-DTN upstream.

### Workflow for ION-DTN Contributions

1. **Make changes in the submodule:**

   ```bash
   cd external/ION-DTN

   # Create a branch for your changes
   git checkout -b my-feature-branch

   # Make your edits (e.g., fix a bug in bpv7/library/libbp.c)
   vim bpv7/library/libbp.c

   # Commit your changes
   git add bpv7/library/libbp.c
   git commit -m "Fix buffer overflow in libbp"
   ```

2. **Test your changes in ion-core-dev:**

   ```bash
   cd ../..  # Back to ion-core-dev root
   make clean
   make
   make test
   ```

3. **Push changes to ION-DTN (requires write access):**

   ```bash
   cd external/ION-DTN

   # Push to your fork or directly to ION-DTN (if you have access)
   git push origin my-feature-branch
   ```

4. **Create a Pull Request to ION-DTN:**

   - Go to https://github.com/nasa-jpl/ION-DTN
   - Create a PR from your branch
   - Once merged, update ion-core-dev to use the new ION-DTN commit

5. **Update ion-core-dev's submodule reference:**

   ```bash
   cd /path/to/ion-core-dev

   # After ION-DTN PR is merged, update submodule to new commit
   cd external/ION-DTN
   git fetch origin
   git checkout <new-commit-or-tag>
   cd ../..

   # Commit the submodule reference update
   git add external/ION-DTN
   git commit -m "Update ION-DTN submodule to include <feature>"
   git push
   ```

### Important Notes

- **Detached HEAD**: The submodule is often in "detached HEAD" state (pointing to a tag). This is normal. Create a branch if you plan to make changes.

- **Commit Separately**: Changes to files in `external/ION-DTN/` are committed **to the ION-DTN repository**, not ion-core-dev. The ion-core-dev repository only stores the submodule commit reference.

- **Coordinate with ION-DTN Team**: For upstream changes, follow ION-DTN's contribution guidelines.

---

## Updating ION-DTN Version

When a new ION-DTN release is available (e.g., 4.1.4), follow these steps:

### Standard Update Process

1. **Update submodule to new tag:**

   ```bash
   cd external/ION-DTN

   # Fetch latest tags
   git fetch --tags

   # Checkout new tag
   git checkout ion-open-source-4.1.4  # Replace with actual tag
   cd ../..
   ```

2. **Update ion-core-dev version references:**

   ```bash
   # Edit build-list.mk
   vim build-list.mk
   # Change: VER := -DVNAME=ION-CORE-4.1.3s
   # To:     VER := -DVNAME=ION-CORE-4.1.4

   # Edit build-list.cmake
   vim build-list.cmake
   # Change: set(VER "-DVNAME=ION-CORE-4.1.3s")
   # To:     set(VER "-DVNAME=ION-CORE-4.1.4")

   # Edit setup-submodule.sh
   vim scripts/setup-submodule.sh
   # Change: EXPECTED_TAG="ion-open-source-4.1.3s"
   # To:     EXPECTED_TAG="ion-open-source-4.1.4"
   ```

3. **Test thoroughly:**

   ```bash
   make clean
   make
   make test

   # Also test CMake build
   rm -rf build
   mkdir build && cd build
   cmake ..
   make
   make test
   cd ..
   ```

4. **Commit the update:**

   ```bash
   git add external/ION-DTN build-list.mk build-list.cmake scripts/setup-submodule.sh
   git commit -m "Update to ION-DTN 4.1.4"
   git push
   ```

5. **Update documentation:**

   Update README.md, release notes, etc. to reflect the new version.

---

## Troubleshooting

### Problem: "ION-DTN submodule not initialized"

**Error:**
```
ION-DTN submodule not initialized. Run: git submodule update --init --recursive
```

**Solution:**
```bash
git submodule update --init --recursive
./scripts/setup-submodule.sh
```

---

### Problem: Submodule is empty or has no files

**Symptoms:**
- `external/ION-DTN/` exists but is empty
- Build fails with "No such file or directory" errors

**Solution:**
```bash
# Remove and reinitialize submodule
rm -rf external/ION-DTN
git submodule update --init --recursive
./scripts/setup-submodule.sh
```

---

### Problem: "error: pathspec 'ion-open-source-4.1.3s' did not match"

**Symptoms:**
- Tag checkout fails in setup-submodule.sh

**Solution:**
```bash
cd external/ION-DTN
git fetch --all --tags
git checkout ion-open-source-4.1.3s
cd ../..
```

---

### Problem: Build fails with missing header files

**Symptoms:**
```
fatal error: ion.h: No such file or directory
```

**Solution:**

Check if sparse-checkout is configured correctly:
```bash
cd external/ION-DTN
git sparse-checkout list
```

If empty or missing directories:
```bash
./scripts/setup-submodule.sh
```

---

### Problem: Changes to ION-DTN files don't persist

**Symptoms:**
- You edit a file in `external/ION-DTN/` but changes disappear

**Cause:**
- Submodule is in detached HEAD state
- Git operations (like checkout) discard uncommitted changes

**Solution:**

Always commit changes in the submodule:
```bash
cd external/ION-DTN
git checkout -b my-changes  # Create a branch
vim bpv7/library/libbp.c    # Make your edits
git add bpv7/library/libbp.c
git commit -m "My changes"
```

---

### Problem: Submodule shows modifications in git status

**Symptoms:**
```
$ git status
modified:   external/ION-DTN (modified content)
```

**Cause:**
- You have uncommitted changes in the submodule
- OR the submodule is on a different commit than what ion-core-dev expects

**Solution:**

Check submodule status:
```bash
cd external/ION-DTN
git status
git diff
```

Either:
- **Commit the changes**: `git add . && git commit -m "..."`
- **Discard the changes**: `git checkout .`
- **Reset to expected commit**: `git checkout ion-open-source-4.1.3s`

---

### Problem: CI/CD pipeline fails with submodule errors

**Symptoms:**
- GitHub Actions fails with "submodule not found"

**Solution:**

Ensure workflows check out submodules:
```yaml
- name: Checkout repository
  uses: actions/checkout@v4
  with:
    submodules: 'recursive'  # This line is critical!
```

All ion-core-dev CI workflows have been updated to include this.

---

### Problem: Sparse-checkout doesn't seem to work

**Symptoms:**
- `external/ION-DTN/` contains all ION-DTN files (not just selected directories)

**Cause:**
- Sparse-checkout was disabled or not configured

**Solution:**
```bash
./scripts/setup-submodule.sh
```

Or manually:
```bash
cd external/ION-DTN
git sparse-checkout init --cone
git sparse-checkout set ici/ bpv7/ ltp/ cfdp/ restart/ tests/
```

---

## Additional Resources

- **ION-DTN Repository**: https://github.com/nasa-jpl/ION-DTN
- **Git Submodules Documentation**: https://git-scm.com/book/en/v2/Git-Tools-Submodules
- **Git Sparse-Checkout**: https://git-scm.com/docs/git-sparse-checkout

---

## FAQ

### Q: Why use a submodule instead of extract.sh?

**A:** Submodules provide:
- Better version control (git tracks exact ION-DTN commit)
- No manual download step (git handles it)
- Easier updates (just checkout a new tag)
- Bi-directional development (contribute back to ION-DTN)
- Industry-standard approach

### Q: Can I still use extract.sh?

**A:** No, `extract.sh` has been deprecated. The old script is archived in `scripts/legacy/` for reference only.

### Q: What if I need files outside the sparse-checkout directories?

**A:** You can temporarily disable sparse-checkout:
```bash
cd external/ION-DTN
git sparse-checkout disable
```

Or add specific paths:
```bash
git sparse-checkout add path/to/additional/dir/
```

### Q: How do I know which ION-DTN version ion-core uses?

**A:** Check the submodule commit:
```bash
cd external/ION-DTN
git describe --tags
```

Or check `scripts/setup-submodule.sh` for `EXPECTED_TAG`.

### Q: What happens if ION-DTN changes significantly?

**A:** Ion-core-dev is pinned to a specific ION-DTN tag (currently `ion-open-source-4.1.3s`). The submodule won't automatically update unless you explicitly check out a new tag.

---

## Summary

**For most users**, the workflow is simple:

1. Clone: `git clone --recurse-submodules <repo>`
2. Setup: `./scripts/setup-submodule.sh`
3. Build: `make`

The submodule approach makes ion-core-dev easier to maintain and more aligned with standard git workflows.
