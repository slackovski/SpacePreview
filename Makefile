SHELL := /bin/bash
.DEFAULT_GOAL := build

# ── Versions ──────────────────────────────────────────────────────────────────
HLJS_VERSION   := 11.10.0
MARKED_VERSION := 12.0.0

# ── Paths ─────────────────────────────────────────────────────────────────────
BUILD_DIR    := build
DMG_NAME     := SpacePreview.dmg
DMG_STAGING  := $(BUILD_DIR)/dmg-staging

# Container app (.app)
APP_NAME     := SpacePreview
APP_BUNDLE   := $(BUILD_DIR)/$(APP_NAME).app
APP_CONTENTS := $(APP_BUNDLE)/Contents
APP_BINARY   := $(APP_CONTENTS)/MacOS/$(APP_NAME)

# Quick Look extension (.appex) embedded inside the app
EXT_NAME     := SpacePreviewQL
EXT_BUNDLE   := $(APP_CONTENTS)/PlugIns/$(EXT_NAME).appex
EXT_CONTENTS := $(EXT_BUNDLE)/Contents
EXT_BINARY   := $(EXT_CONTENTS)/MacOS/$(EXT_NAME)
EXT_RES_DIR  := $(EXT_CONTENTS)/Resources

# Sources
EXT_SWIFT_SOURCES := Sources/PreviewProvider.swift \
                     Sources/FileRenderer.swift    \
                     Sources/LanguageMapping.swift

APP_SWIFT_SOURCES := Sources/AppStub/main.swift

# Old-style Quick Look generator (.qlgenerator) — handles public.mpeg-2-transport-stream
# so that .ts TypeScript files are previewed by us instead of Movie.qlgenerator.
QL_GEN_BUNDLE   := $(BUILD_DIR)/SpacePreview.qlgenerator
QL_GEN_CONTENTS := $(QL_GEN_BUNDLE)/Contents
QL_GEN_BINARY   := $(QL_GEN_CONTENTS)/MacOS/SpacePreview
QL_GEN_RES_DIR  := $(QL_GEN_CONTENTS)/Resources

QL_GEN_SWIFT_SOURCES := Sources/GeneratePreview.swift \
                        Sources/FileRenderer.swift    \
                        Sources/LanguageMapping.swift

QL_GEN_C_OBJ := $(BUILD_DIR)/PluginFactory.o

# ── Architecture ──────────────────────────────────────────────────────────────
ARCH := $(shell uname -m)
ifeq ($(ARCH),arm64)
    TARGET := arm64-apple-macosx13.0
else
    TARGET := x86_64-apple-macosx13.0
endif

# ── External dependencies (downloaded once) ───────────────────────────────────
HLJS_JS        := Resources/highlight.min.js
HLJS_LIGHT_CSS := Resources/atom-one-light.min.css
HLJS_DARK_CSS  := Resources/atom-one-dark.min.css
MARKED_JS      := Resources/marked.min.js
DEPS           := $(HLJS_JS) $(HLJS_LIGHT_CSS) $(HLJS_DARK_CSS) $(MARKED_JS)

CDNJS := https://cdnjs.cloudflare.com/ajax/libs

# ── Targets ───────────────────────────────────────────────────────────────────

.PHONY: all deps build build-qlgenerator build-universal dist install uninstall clean distclean help

all: build

## Download JS/CSS dependencies from cdnjs (run once, outputs cached in Resources/)
deps: $(DEPS)

$(HLJS_JS):
	@echo "→ Downloading highlight.js $(HLJS_VERSION)..."
	@curl -fsSL "$(CDNJS)/highlight.js/$(HLJS_VERSION)/highlight.min.js" -o "$@"

$(HLJS_LIGHT_CSS):
	@echo "→ Downloading atom-one-light theme..."
	@curl -fsSL "$(CDNJS)/highlight.js/$(HLJS_VERSION)/styles/atom-one-light.min.css" -o "$@"

$(HLJS_DARK_CSS):
	@echo "→ Downloading atom-one-dark theme..."
	@curl -fsSL "$(CDNJS)/highlight.js/$(HLJS_VERSION)/styles/atom-one-dark.min.css" -o "$@"

$(MARKED_JS):
	@echo "→ Downloading marked.js $(MARKED_VERSION)..."
	@curl -fsSL "$(CDNJS)/marked/$(MARKED_VERSION)/marked.min.js" -o "$@"

## Compile and assemble the .app + embedded .appex
build: deps $(EXT_BINARY) $(APP_BINARY)
	@echo "→ Ad-hoc signing extension (with sandbox entitlements)..."
	codesign --force --sign - \
		--entitlements SpacePreviewQL.entitlements \
		--identifier "com.spacepreview.qlextension" \
		"$(EXT_BUNDLE)"

	@echo "→ Ad-hoc signing app (with sandbox entitlements)..."
	codesign --force --sign - \
		--entitlements SpacePreview.entitlements \
		--identifier "com.spacepreview" \
		"$(APP_BUNDLE)"

	@echo "✓ Bundle ready: $(APP_BUNDLE)"

# ── Extension binary ──────────────────────────────────────────────────────────
$(EXT_BINARY): $(EXT_SWIFT_SOURCES) $(DEPS) Resources/preview.html Resources/style.css Extension-Info.plist
	@mkdir -p "$(EXT_CONTENTS)/MacOS"
	@mkdir -p "$(EXT_RES_DIR)"

	@echo "→ Compiling extension sources ($(TARGET))..."
	swiftc \
		-target "$(TARGET)" \
		-framework Foundation \
		-framework QuickLookUI \
		-Xlinker -e -Xlinker _NSExtensionMain \
		-suppress-warnings \
		$(EXT_SWIFT_SOURCES) \
		-o "$(EXT_BINARY)"

	@echo "→ Copying extension resources..."
	cp -f Extension-Info.plist              "$(EXT_CONTENTS)/Info.plist"
	cp -f Resources/preview.html           "$(EXT_RES_DIR)/"
	cp -f Resources/style.css              "$(EXT_RES_DIR)/"
	cp -f Resources/highlight.min.js       "$(EXT_RES_DIR)/"
	cp -f Resources/marked.min.js          "$(EXT_RES_DIR)/"
	cp -f Resources/atom-one-light.min.css "$(EXT_RES_DIR)/"
	cp -f Resources/atom-one-dark.min.css  "$(EXT_RES_DIR)/"
	cp -f Resources/AppIcon.icns           "$(EXT_RES_DIR)/"

# ── Container app stub binary ─────────────────────────────────────────────────
$(APP_BINARY): $(APP_SWIFT_SOURCES) App-Info.plist
	@mkdir -p "$(APP_CONTENTS)/MacOS"

	@echo "→ Compiling stub app ($(TARGET))..."
	swiftc \
		-target "$(TARGET)" \
		-framework Foundation \
		-framework AppKit \
		-framework UserNotifications \
		-suppress-warnings \
		$(APP_SWIFT_SOURCES) \
		-o "$(APP_BINARY)"

	cp -f App-Info.plist "$(APP_CONTENTS)/Info.plist"

# ── Old-style Quick Look generator ────────────────────────────────────────────

## Compile the old-style .qlgenerator bundle (exact-UTI match for .ts TypeScript)
build-qlgenerator: deps $(QL_GEN_BINARY)

# Compile the C factory glue to an object file
$(QL_GEN_C_OBJ): Sources/PluginFactory.c
	@mkdir -p "$(BUILD_DIR)"
	@echo "→ Compiling PluginFactory.c ($(TARGET))..."
	clang -c \
		-target "$(TARGET)" \
		Sources/PluginFactory.c \
		-o "$(QL_GEN_C_OBJ)"

# Compile Swift sources + link C glue as a loadable bundle
$(QL_GEN_BINARY): $(QL_GEN_SWIFT_SOURCES) $(QL_GEN_C_OBJ) $(DEPS) \
                  Resources/preview.html Resources/style.css Info.plist
	@mkdir -p "$(QL_GEN_CONTENTS)/MacOS"
	@mkdir -p "$(QL_GEN_RES_DIR)"

	@echo "→ Compiling QL generator Swift sources ($(TARGET))..."
	swiftc \
		-target "$(TARGET)" \
		-framework Foundation \
		-framework QuickLook \
		-Xlinker -bundle \
		-suppress-warnings \
		$(QL_GEN_SWIFT_SOURCES) \
		"$(QL_GEN_C_OBJ)" \
		-o "$(QL_GEN_BINARY)"

	@echo "→ Copying QL generator resources..."
	cp -f Info.plist                       "$(QL_GEN_CONTENTS)/Info.plist"
	cp -f Resources/preview.html          "$(QL_GEN_RES_DIR)/"
	cp -f Resources/style.css             "$(QL_GEN_RES_DIR)/"
	cp -f Resources/highlight.min.js      "$(QL_GEN_RES_DIR)/"
	cp -f Resources/marked.min.js         "$(QL_GEN_RES_DIR)/"
	cp -f Resources/atom-one-light.min.css "$(QL_GEN_RES_DIR)/"
	cp -f Resources/atom-one-dark.min.css  "$(QL_GEN_RES_DIR)/"

	@echo "→ Ad-hoc signing QL generator..."
	codesign --force --sign - \
		--identifier "com.spacepreview.qlgenerator" \
		"$(QL_GEN_BUNDLE)"

	@echo "✓ QL generator ready: $(QL_GEN_BUNDLE)"

## Build a universal (Intel + Apple Silicon) binary
build-universal: deps
	@echo "→ Creating bundle structure..."
	@mkdir -p "$(APP_CONTENTS)/MacOS"
	@mkdir -p "$(EXT_CONTENTS)/MacOS"
	@mkdir -p "$(EXT_RES_DIR)"
	@mkdir -p "$(BUILD_DIR)/arm64" "$(BUILD_DIR)/x86_64"

	@echo "→ Compiling extension (arm64)..."
	swiftc -target arm64-apple-macosx13.0 \
		-framework Foundation -framework QuickLookUI \
		-Xlinker -e -Xlinker _NSExtensionMain \
		-suppress-warnings \
		$(EXT_SWIFT_SOURCES) \
		-o "$(BUILD_DIR)/arm64/$(EXT_NAME)"

	@echo "→ Compiling extension (x86_64)..."
	swiftc -target x86_64-apple-macosx13.0 \
		-framework Foundation -framework QuickLookUI \
		-Xlinker -e -Xlinker _NSExtensionMain \
		-suppress-warnings \
		$(EXT_SWIFT_SOURCES) \
		-o "$(BUILD_DIR)/x86_64/$(EXT_NAME)"

	@echo "→ Creating universal extension binary with lipo..."
	lipo -create \
		"$(BUILD_DIR)/arm64/$(EXT_NAME)" \
		"$(BUILD_DIR)/x86_64/$(EXT_NAME)" \
		-output "$(EXT_BINARY)"

	@echo "→ Compiling stub app (arm64)..."
	swiftc -target arm64-apple-macosx13.0 \
		-framework Foundation -framework AppKit -framework UserNotifications -suppress-warnings \
		$(APP_SWIFT_SOURCES) \
		-o "$(BUILD_DIR)/arm64/$(APP_NAME)"

	@echo "→ Compiling stub app (x86_64)..."
	swiftc -target x86_64-apple-macosx13.0 \
		-framework Foundation -framework AppKit -framework UserNotifications -suppress-warnings \
		$(APP_SWIFT_SOURCES) \
		-o "$(BUILD_DIR)/x86_64/$(APP_NAME)"

	@echo "→ Creating universal app binary with lipo..."
	lipo -create \
		"$(BUILD_DIR)/arm64/$(APP_NAME)" \
		"$(BUILD_DIR)/x86_64/$(APP_NAME)" \
		-output "$(APP_BINARY)"

	@echo "→ Copying resources..."
	@mkdir -p "$(APP_CONTENTS)/Resources"
	cp -f Extension-Info.plist              "$(EXT_CONTENTS)/Info.plist"
	cp -f App-Info.plist                    "$(APP_CONTENTS)/Info.plist"
	cp -f Resources/preview.html           "$(EXT_RES_DIR)/"
	cp -f Resources/style.css              "$(EXT_RES_DIR)/"
	cp -f Resources/highlight.min.js       "$(EXT_RES_DIR)/"
	cp -f Resources/marked.min.js          "$(EXT_RES_DIR)/"
	cp -f Resources/atom-one-light.min.css "$(EXT_RES_DIR)/"
	cp -f Resources/atom-one-dark.min.css  "$(EXT_RES_DIR)/"
	cp -f Resources/AppIcon.icns           "$(EXT_RES_DIR)/"
	cp -f Resources/AppIcon.icns           "$(APP_CONTENTS)/Resources/"

	@echo "→ Signing extension (with sandbox entitlements)..."
	codesign --force --sign - \
		--entitlements SpacePreviewQL.entitlements \
		--identifier "com.spacepreview.qlextension" \
		"$(EXT_BUNDLE)"

	@echo "→ Signing app (with sandbox entitlements)..."
	codesign --force --sign - \
		--entitlements SpacePreview.entitlements \
		--identifier "com.spacepreview" \
		"$(APP_BUNDLE)"

	@echo "✓ Universal bundle ready: $(APP_BUNDLE)"

## Package a distributable DMG (universal Intel + Apple Silicon)
dist: build-universal
	@echo "→ Creating DMG staging area..."
	@rm -rf "$(DMG_STAGING)"
	@mkdir -p "$(DMG_STAGING)"

	@cp -rf "$(APP_BUNDLE)" "$(DMG_STAGING)/"
	@ln -sf /Applications "$(DMG_STAGING)/Applications"

	@printf '%s\n' \
	  'SpacePreview — Quick Look Extension for Developer Files' \
	  '========================================================' \
	  '' \
	  'SETUP (3 easy steps)' \
	  '-------------------' \
	  '1. Drag SpacePreview.app to the Applications folder (use the alias in this window).' \
	  '2. Open SpacePreview.app once. It will automatically enable itself.' \
	  '3. Open Finder, select a code file (.go .py .ts .md …), press Space.' \
	  '' \
	  'That'\''s it! The extension is now active.' \
	  '' \
	  'SUPPORTED FILE TYPES' \
	  '--------------------' \
	  '• Code: .go, .rust, .py, .js, .ts, .tsx, .swift, .java, .cpp, .c, .cs, etc.' \
	  '• Web: .html, .css, .vue, .graphql' \
	  '• Data: .json, .yaml, .xml, .sql, .toml' \
	  '• DevOps: Dockerfile, .tf, Makefile, .gradle' \
	  '• Docs: .md, .rst, .tex' \
	  '• Subtitles: .srt, .vtt, .ass, .ssa' \
	  '' \
	  'TROUBLESHOOTING' \
	  '---------------' \
	  'If nothing happens after step 3:' \
	  '  1. Make sure you opened SpacePreview.app in step 2' \
	  '  2. Restart Finder (⌘Q to close, then reopen)' \
	  '  3. Try a different file format' \
	  '' \
	  'UNINSTALL' \
	  '---------' \
	  'Drag SpacePreview.app from /Applications to Trash.' \
	  > "$(DMG_STAGING)/How to Install.txt"

	@echo "→ Creating DMG..."
	@hdiutil create \
		-volname "SpacePreview" \
		-srcfolder "$(DMG_STAGING)" \
		-ov \
		-format UDZO \
		"$(BUILD_DIR)/$(DMG_NAME)" \
		>/dev/null
	@rm -rf "$(DMG_STAGING)"
	@echo ""
	@echo "✓ DMG ready: $(BUILD_DIR)/$(DMG_NAME)"
	@echo ""
	@echo "  Distribute this file. After users drag the app to Applications they"
	@echo "  must enable the extension in:"
	@echo "  System Settings → Privacy & Security → Extensions → Quick Look"
	@echo ""

## Install the plugin to ~/Applications/ and register the QL extension
install: build build-qlgenerator
	@echo "→ Installing app to ~/Applications/..."
	@mkdir -p "$$HOME/Applications"
	cp -rf "$(APP_BUNDLE)" "$$HOME/Applications/"

	@echo "→ Installing QL generator to ~/Library/QuickLook/..."
	@mkdir -p "$$HOME/Library/QuickLook"
	cp -rf "$(QL_GEN_BUNDLE)" "$$HOME/Library/QuickLook/"

	@echo "→ Removing quarantine flags..."
	xattr -r -d com.apple.quarantine "$$HOME/Applications/$(APP_NAME).app" 2>/dev/null || true
	xattr -r -d com.apple.quarantine "$$HOME/Library/QuickLook/SpacePreview.qlgenerator" 2>/dev/null || true

	@echo "→ Registering app UTIs with LaunchServices..."
	/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
		-f "$$HOME/Applications/$(APP_NAME).app" 2>/dev/null || true
	/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
		-f "$$HOME/Library/QuickLook/SpacePreview.qlgenerator" 2>/dev/null || true

	@echo "→ Registering Quick Look extension..."
	pluginkit -a "$$HOME/Applications/$(APP_NAME).app/Contents/PlugIns/$(EXT_NAME).appex" || true

	@echo "→ Restarting Quick Look..."
	qlmanage -r
	qlmanage -r cache
	@echo ""
	@echo "✓ SpacePreview installed!"
	@echo "  Select a supported file in Finder and press Space to try it."
	@echo ""
	@echo "  If nothing happens, run:  make fix-perms"
	@echo ""

## Fix permissions if the extension isn't loading
fix-perms:
	xattr -r -d com.apple.quarantine "$$HOME/Applications/$(APP_NAME).app" 2>/dev/null || true
	pluginkit -e use -i com.spacepreview.qlextension 2>/dev/null || true
	qlmanage -r
	qlmanage -r cache
	@echo "✓ Permissions fixed. Try pressing Space on a supported file."

## Remove the plugin from ~/Applications/ and ~/Library/QuickLook/
uninstall:
	@echo "→ Removing SpacePreview..."
	pluginkit -r "$$HOME/Applications/$(APP_NAME).app/Contents/PlugIns/$(EXT_NAME).appex" 2>/dev/null || true
	rm -rf "$$HOME/Applications/$(APP_NAME).app"
	rm -rf "$$HOME/Library/QuickLook/SpacePreview.qlgenerator"
	qlmanage -r
	@echo "✓ SpacePreview uninstalled."

## Remove all build artefacts (keeps downloaded dependencies)
clean:
	rm -rf "$(BUILD_DIR)"
	@echo "✓ Cleaned build directory."

## Remove build artefacts AND downloaded dependencies
distclean: clean
	rm -f Resources/highlight.min.js \
	      Resources/marked.min.js \
	      Resources/atom-one-light.min.css \
	      Resources/atom-one-dark.min.css
	@echo "✓ Removed downloaded dependencies."

## Print help
help:
	@echo ""
	@echo "SpacePreview – Quick Look plugin for developer files"
	@echo ""
	@echo "  make deps             Download JS/CSS dependencies (once)"
	@echo "  make build            Compile + assemble SpacePreview.app"
	@echo "  make build-universal  Universal binary (arm64 + x86_64)"
	@echo "  make dist             Build universal + package SpacePreview.dmg"
	@echo "  make install          Build + install to ~/Applications/"
	@echo "  make uninstall        Remove from ~/Applications/"
	@echo "  make fix-perms        Fix permissions if preview isn't showing"
	@echo "  make clean            Remove build artefacts"
	@echo "  make distclean        Remove build artefacts + dependencies"
	@echo ""
