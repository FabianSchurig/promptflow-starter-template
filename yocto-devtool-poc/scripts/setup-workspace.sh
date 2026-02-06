#!/bin/bash
# Setup script for Yocto devtool workspace

set -e

echo "=========================================="
echo "Yocto devtool Multi-Repository Workflow"
echo "Setup Script"
echo "=========================================="
echo ""

# Configuration - adjust these paths as needed
POKY_DIR="${POKY_DIR:-$HOME/poky}"
BUILD_DIR="${BUILD_DIR:-$POKY_DIR/build}"
MY_LIB_REPO="${MY_LIB_REPO:-$HOME/my-lib}"
MY_APP_REPO="${MY_APP_REPO:-$HOME/my-app}"
RECIPES_LAYER="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/recipes-example"

echo "Configuration:"
echo "  Poky directory:   $POKY_DIR"
echo "  Build directory:  $BUILD_DIR"
echo "  my-lib repo:      $MY_LIB_REPO"
echo "  my-app repo:      $MY_APP_REPO"
echo "  Recipes layer:    $RECIPES_LAYER"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if [ ! -d "$POKY_DIR" ]; then
    echo "ERROR: Poky directory not found at $POKY_DIR"
    echo ""
    echo "Please clone Poky first:"
    echo "  git clone git://git.yoctoproject.org/poky $POKY_DIR"
    echo "  cd $POKY_DIR"
    echo "  git checkout kirkstone  # or your preferred branch"
    echo ""
    exit 1
fi

if [ ! -d "$MY_LIB_REPO" ]; then
    echo "ERROR: my-lib repository not found at $MY_LIB_REPO"
    echo ""
    echo "Please clone my-lib first:"
    echo "  git clone <my-lib-repo-url> $MY_LIB_REPO"
    echo ""
    exit 1
fi

if [ ! -d "$MY_APP_REPO" ]; then
    echo "ERROR: my-app repository not found at $MY_APP_REPO"
    echo ""
    echo "Please clone my-app first:"
    echo "  git clone <my-app-repo-url> $MY_APP_REPO"
    echo ""
    exit 1
fi

echo "✓ All prerequisites met"
echo ""

# Source the build environment
echo "Sourcing Yocto build environment..."
cd "$POKY_DIR"
source oe-init-build-env "$BUILD_DIR"

# Add our custom layer if not already added
echo ""
echo "Adding recipes layer to build configuration..."
if ! bitbake-layers show-layers 2>/dev/null | grep -q "yocto-devtool-poc"; then
    bitbake-layers add-layer "$RECIPES_LAYER"
    echo "✓ Layer added successfully"
else
    echo "✓ Layer already present"
fi

# Initialize devtool workspace for my-lib
echo ""
echo "=========================================="
echo "Initializing devtool workspace for my-lib"
echo "=========================================="
if devtool status | grep -q "my-lib"; then
    echo "✓ my-lib already in workspace"
else
    devtool modify my-lib "$MY_LIB_REPO"
    echo "✓ my-lib added to workspace"
fi

# Initialize devtool workspace for my-app
echo ""
echo "=========================================="
echo "Initializing devtool workspace for my-app"
echo "=========================================="
if devtool status | grep -q "my-app"; then
    echo "✓ my-app already in workspace"
else
    devtool modify my-app "$MY_APP_REPO"
    echo "✓ my-app added to workspace"
fi

# Build my-lib (required for sysroot population)
echo ""
echo "=========================================="
echo "Building my-lib (populating sysroot)"
echo "=========================================="
echo "This may take a few minutes on first run..."
devtool build my-lib
echo "✓ my-lib built successfully"

# Verify sysroot population
echo ""
echo "Verifying sysroot population..."
SYSROOT_LIB="$BUILD_DIR/workspace/recipes/my-lib/recipe-sysroot/usr/lib/cmake/MyLib/MyLibConfig.cmake"
if [ -f "$SYSROOT_LIB" ]; then
    echo "✓ MyLibConfig.cmake found in sysroot"
else
    echo "WARNING: MyLibConfig.cmake not found in expected location"
    echo "  Expected: $SYSROOT_LIB"
fi

# Generate IDE SDK configuration
echo ""
echo "=========================================="
echo "Generating IDE SDK configuration"
echo "=========================================="
devtool ide-sdk my-lib my-app core-image-minimal
echo "✓ IDE SDK configuration generated"

# Check for generated presets
echo ""
echo "Checking for CMakeUserPresets.json files..."
if [ -f "$MY_LIB_REPO/CMakeUserPresets.json" ]; then
    echo "✓ $MY_LIB_REPO/CMakeUserPresets.json"
else
    echo "⚠ CMakeUserPresets.json not found in my-lib"
fi

if [ -f "$MY_APP_REPO/CMakeUserPresets.json" ]; then
    echo "✓ $MY_APP_REPO/CMakeUserPresets.json"
else
    echo "⚠ CMakeUserPresets.json not found in my-app"
fi

# Display workspace status
echo ""
echo "=========================================="
echo "Workspace Status"
echo "=========================================="
devtool status

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Open VSCode in the my-app directory:"
echo "   code $MY_APP_REPO"
echo ""
echo "2. Select the CMake preset:"
echo "   - Open Command Palette (Ctrl+Shift+P)"
echo "   - Run: 'CMake: Select Configure Preset'"
echo "   - Choose: 'yocto-debug' or 'yocto-release'"
echo ""
echo "3. Build and debug using VSCode CMake Tools"
echo "   - Press F7 to build"
echo "   - Press F5 to debug"
echo ""
echo "4. To iterate on changes:"
echo "   - Edit sources in my-lib or my-app"
echo "   - Run: devtool build my-lib  (if library changed)"
echo "   - Run: devtool build my-app"
echo "   - Test without full image rebuild!"
echo ""
echo "For more information, see:"
echo "  - README.md"
echo "  - docs/WORKFLOW.md"
echo ""
