#!/bin/bash
# Build script for testing the workflow

set -e

echo "=========================================="
echo "Building C++ Components"
echo "=========================================="
echo ""

# Configuration
POKY_DIR="${POKY_DIR:-$HOME/poky}"
BUILD_DIR="${BUILD_DIR:-$POKY_DIR/build}"

# Check if Poky is available
if [ ! -d "$POKY_DIR" ]; then
    echo "ERROR: Poky directory not found at $POKY_DIR"
    echo "Run setup-workspace.sh first"
    exit 1
fi

# Source the build environment
echo "Sourcing Yocto build environment..."
cd "$POKY_DIR"
source oe-init-build-env "$BUILD_DIR"

# Build the library
echo ""
echo "=========================================="
echo "Building my-lib"
echo "=========================================="
devtool build my-lib
echo "✓ my-lib built successfully"

# Build the application
echo ""
echo "=========================================="
echo "Building my-app"
echo "=========================================="
devtool build my-app
echo "✓ my-app built successfully"

echo ""
echo "=========================================="
echo "Build Complete!"
echo "=========================================="
echo ""
echo "To run the application:"
echo ""
echo "Option 1 - Deploy to target device:"
echo "  devtool deploy-target my-app user@target-ip"
echo ""
echo "Option 2 - Test locally (if same architecture):"
echo "  $BUILD_DIR/workspace/sources/my-app/build/my-app"
echo ""
echo "Option 3 - Use QEMU:"
echo "  runqemu qemux86-64 nographic"
echo "  (inside QEMU) /usr/bin/my-app"
echo ""
