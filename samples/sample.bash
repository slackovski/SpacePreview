#!/bin/bash

# Install SpacePreview dependencies
set -e

echo "Installing macOS dependencies..."
brew install librsvg cmake

# Build configuration
BUILD_DIR="${1:-./build}"
ARCH="${2:-arm64}"

if [ ! -d "$BUILD_DIR" ]; then
  mkdir -p "$BUILD_DIR"
fi

echo "Building for architecture: $ARCH"
export CFLAGS="-arch $ARCH"
export LDFLAGS="-arch $ARCH"

make -C . build ARCH=$ARCH

echo "✓ Build complete: $BUILD_DIR"
