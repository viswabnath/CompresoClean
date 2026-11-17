#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build.sh — CompresoClean build script
# Assembles the .app bundle from src/ and packages it as a DMG
# Usage: ./build.sh [version]
#
# Optional signing + notarization (removes the "Open Anyway" Gatekeeper warning;
# needs a paid Apple Developer ID). Without these env vars the DMG is unsigned.
#   CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
#   NOTARY_PROFILE="my-profile"   # created once via: xcrun notarytool store-credentials
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

VERSION="${1:-1.5}"
APP_NAME="CompresoClean"
DMG_NAME="${APP_NAME}_v${VERSION}.dmg"
VOLUME_NAME="${APP_NAME} v${VERSION} by OneMark"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_SCRIPT="${SCRIPT_DIR}/src/${APP_NAME}"
APP_BUNDLE="${SCRIPT_DIR}/app/${APP_NAME}.app"
PLIST="${APP_BUNDLE}/Contents/Info.plist"
ICON="${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
BUILD_DIR="${HOME}/Desktop/${APP_NAME}_DMG"
OUTPUT_DMG="${HOME}/Desktop/${DMG_NAME}"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   CompresoClean Build Script v${VERSION}       ║"
echo "║   OneMark Agency                         ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── 1. Validate source script ────────────────────────────────────────────────
if [[ ! -f "$SRC_SCRIPT" ]]; then
  echo "❌  Source script not found: $SRC_SCRIPT"
  echo "    Make sure src/CompresoClean exists before building."
  exit 1
fi

echo "✅  Source script found: $SRC_SCRIPT"

# ── 2. Build .app bundle structure ───────────────────────────────────────────
echo "🔨  Building .app bundle..."

mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy and set executable
cp "$SRC_SCRIPT" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

echo "✅  Script copied to .app bundle"

# ── 3. Write Info.plist if missing ───────────────────────────────────────────
if [[ ! -f "$PLIST" ]]; then
  echo "📝  Writing Info.plist..."
  cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleDisplayName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>in.onemark.compresoclean</string>
  <key>CFBundleVersion</key>
  <string>${VERSION}</string>
  <key>CFBundleShortVersionString</key>
  <string>${VERSION}</string>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleSignature</key>
  <string>????</string>
  <key>LSMinimumSystemVersion</key>
  <string>12.0</string>
  <key>LSUIElement</key>
  <false/>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
EOF
  echo "✅  Info.plist written"
else
  echo "✅  Info.plist already exists — skipping"
fi

# ── 4. Icon notice ───────────────────────────────────────────────────────────
if [[ ! -f "$ICON" ]]; then
  echo "⚠️   No AppIcon.icns found at: $ICON"
  echo "    The app will use the default macOS icon."
  echo "    To add an icon: place AppIcon.icns in app/${APP_NAME}.app/Contents/Resources/"
fi

# ── 5. Sync app/ bundle back to local /Applications (optional) ───────────────
read -rp "Sync updated .app to /Applications? [y/N] " sync_choice
if [[ "$(echo "$sync_choice" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
  echo "Copying to /Applications..."
  cp -r "${APP_BUNDLE}" /Applications/
  echo "/Applications/${APP_NAME}.app updated"
fi

# ── 6. Package as DMG ────────────────────────────────────────────────────────
echo ""
echo "📀  Packaging DMG..."

# Clean up any previous build dir
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Copy app bundle
cp -r "$APP_BUNDLE" "$BUILD_DIR/"

# Copy docs if present
[[ -f "${SCRIPT_DIR}/docs/instructions.md" ]] && cp "${SCRIPT_DIR}/docs/instructions.md" "$BUILD_DIR/"
[[ -f "${SCRIPT_DIR}/README.md" ]] && cp "${SCRIPT_DIR}/README.md" "$BUILD_DIR/"

# Sign the staged copy (not app/ in the repo, so the repo bundle stays unsigned)
if [[ -n "${CODESIGN_IDENTITY:-}" ]]; then
  echo "🔏  Signing app with: $CODESIGN_IDENTITY"
  codesign --force --deep --options runtime --timestamp \
    --sign "$CODESIGN_IDENTITY" "$BUILD_DIR/${APP_NAME}.app"
  codesign --verify --deep --strict "$BUILD_DIR/${APP_NAME}.app"
  echo "✅  App signed"
fi

# Remove old DMG if exists
[[ -f "$OUTPUT_DMG" ]] && rm "$OUTPUT_DMG"

hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$BUILD_DIR" \
  -ov \
  -format UDZO \
  "$OUTPUT_DMG"

# Clean temp dir
rm -rf "$BUILD_DIR"

# Sign and notarize the DMG
if [[ -n "${CODESIGN_IDENTITY:-}" ]]; then
  codesign --force --timestamp --sign "$CODESIGN_IDENTITY" "$OUTPUT_DMG"
  if [[ -n "${NOTARY_PROFILE:-}" ]]; then
    echo "📨  Submitting for notarization (this can take a few minutes)..."
    xcrun notarytool submit "$OUTPUT_DMG" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$OUTPUT_DMG"
    echo "✅  DMG notarized and stapled"
  else
    echo "⚠️   CODESIGN_IDENTITY set but NOTARY_PROFILE is not — DMG is signed but not notarized."
  fi
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   ✅  Build complete!                    ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "📦  DMG → $OUTPUT_DMG"
echo "🚀  Ready to upload to GitHub Releases"
echo ""