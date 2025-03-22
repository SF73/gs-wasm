#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

source /opt/emsdk/emsdk_env.sh

# Variables
GHOSTSCRIPT_VERSION="10.04.0"
SOURCE_DIR="ghostscript-$GHOSTSCRIPT_VERSION"
ARCH_HEADER="arch/wasm.h"
PATCH_DIR="code_patch"
BUILD_DIR="build"
INSTALL_DIR="output"
BUILD_DEBUG=false  # Toggle this variable to build the debug version

# Ensure EMScripten environment is set up
if ! command -v emcc &> /dev/null; then
    echo "Emscripten is not installed or not in the PATH. Please set up EMScripten before running this script."
    exit 1
fi

# Clone Ghostscript source code if not already present
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Cloning Ghostscript source code..."
    wget https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs10040/ghostscript-10.04.0.tar.gz
    tar -xvf "ghostscript-10.04.0.tar.gz"
fi

# Apply patches if the code_patch directory exists
if [ -d "$PATCH_DIR" ]; then
    echo "Applying patches from $PATCH_DIR..."
    cp -r "$PATCH_DIR"/* "$SOURCE_DIR"/
fi

# Navigate to source directory
cd "$SOURCE_DIR"

# Prepare the build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Run the emconfigure command to configure the build
echo "Configuring Ghostscript for EMScripten..."
emconfigure ../configure \
    --disable-threading \
    --disable-cups \
    --disable-dbus \
    --disable-gtk \
    --with-drivers=PS \
    --without-tesseract \
    --without-libtiff \
    CC=emcc \
    CCAUX=gcc \
    --with-arch_h="../arch/windows-x86-msvc.h"

# Run the emmake command to compile Ghostscript
echo "Building Ghostscript with EMScripten..."
emmake make XE=".js" GS_LDFLAGS="-s MODULARIZE=1 -s ALLOW_MEMORY_GROWTH=1 -s NO_EXIT_RUNTIME=1 -s EXPORTED_RUNTIME_METHODS=['callMain','FS'] -s INVOKE_RUN=0 -O2"

# Install the compiled files
echo "Installing compiled files to $INSTALL_DIR..."
mkdir -p "../../$INSTALL_DIR"
cp -r bin/* "../../$INSTALL_DIR"

# Conditionally build the debug version
if [ "$BUILD_DEBUG" = true ]; then
    echo "Building debug version..."
    emmake make debug XE=".js" GS_LDFLAGS="-s MODULARIZE=1 -s ALLOW_MEMORY_GROWTH=1 -s NO_EXIT_RUNTIME=1 -s EXPORTED_RUNTIME_METHODS=['callMain','FS'] -s ASSERTIONS=2 -g4"
    mkdir -p "../../$INSTALL_DIR/debug"
    cp -r debugbin/* "../../$INSTALL_DIR/debug"
fi

# Completion message
# echo "Ghostscript has been successfully cross-compiled to WebAssembly."
# echo "Compiled files are available in the $INSTALL_DIR directory."
