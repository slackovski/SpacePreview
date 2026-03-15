#!/usr/bin/env bash
# install.sh — One-shot build + install script for SpacePreview
# Usage: bash install.sh
#
# Requires: macOS 13+, Xcode Command Line Tools

set -euo pipefail

APP_NAME="SpacePreview"
EXT_NAME="SpacePreviewQL"
INSTALL_DIR="$HOME/Applications"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   SpacePreview — Quick Look Extension    ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Prerequisites check ───────────────────────────────────────────────────────
if ! command -v swiftc &>/dev/null; then
    echo "✗ swiftc not found."
    echo "  Install Xcode Command Line Tools:  xcode-select --install"
    exit 1
fi

if ! command -v curl &>/dev/null; then
    echo "✗ curl not found. Please install it and retry."
    exit 1
fi

SWIFT_VER=$(swiftc --version 2>&1 | head -1 | awk '{print $4}')
echo "✓ Prerequisites OK (Swift ${SWIFT_VER})"

# ── Build ─────────────────────────────────────────────────────────────────────
echo ""
echo "Step 1/3  Downloading dependencies..."
make deps

echo ""
echo "Step 2/3  Compiling..."
make build

# ── Install ───────────────────────────────────────────────────────────────────
echo ""
echo "Step 3/3  Installing..."
mkdir -p "$INSTALL_DIR"
cp -rf "build/${APP_NAME}.app" "$INSTALL_DIR/"

# Remove quarantine flag (prevents loading after direct download)
xattr -r -d com.apple.quarantine "$INSTALL_DIR/${APP_NAME}.app" 2>/dev/null || true

# Register the Quick Look extension with the system
APPEX="$INSTALL_DIR/${APP_NAME}.app/Contents/PlugIns/${EXT_NAME}.appex"
pluginkit -a "$APPEX" 2>/dev/null || true

# Reset Quick Look cache
qlmanage -r 2>/dev/null || true
qlmanage -r cache 2>/dev/null || true

echo ""
echo "══════════════════════════════════════════════"
echo "  ✓ SpacePreview installed successfully!"
echo ""
echo "  How to use:"
echo "    1. Open Finder"
echo "    2. Select any supported file (.ts, .go, .md, ...)"
echo "    3. Press Space"
echo ""
echo "  If nothing happens after a few seconds, run:"
echo "    make fix-perms"
echo ""
echo "  To uninstall:"
echo "    make uninstall"
echo "══════════════════════════════════════════════"
echo ""
