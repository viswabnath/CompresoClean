# CompresoClean — Build Documentation
**Built by Viswanath Bodasakurthi | OneMark Agency**
**Date: April 2026 | Version: 1.0**

---

## What is CompresoClean?
A free macOS utility that cleans junk files, caches, logs, and temp files 
from your Mac using terminal commands — no subscription, no CleanMyMac needed.

---

## What it cleans
- User app caches (~/Library/Caches)
- System and app logs (~/Library/Logs)
- npm cache
- Homebrew cache
- Trash
- Temp files (/tmp and /private/var/tmp)

---

## How it was built — every command used

### 1. Created the .app structure
mkdir -p ~/Desktop/CompresoClean.app/Contents/MacOS
mkdir -p ~/Desktop/CompresoClean.app/Contents/Resources

### 2. Created the launcher script
cat > ~/Desktop/CompresoClean.app/Contents/MacOS/CompresoClean << 'SCRIPT'
#!/bin/bash
osascript -e 'tell application "Terminal"
    activate
    do script "..."
end tell'
SCRIPT
chmod +x ~/Desktop/CompresoClean.app/Contents/MacOS/CompresoClean

### 3. Created Info.plist (app metadata)
cat > ~/Desktop/CompresoClean.app/Contents/Info.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>CompresoClean</string>
    <key>CFBundleIdentifier</key><string>com.onemark.compresoclean</string>
    <key>CFBundleName</key><string>CompresoClean</string>
    <key>CFBundleVersion</key><string>1.0</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
</dict>
</plist>
PLIST

### 4. Created the icon
# Designed in Claude.ai as SVG
# Converted using:
brew install librsvg
rsvg-convert -w 512 -h 512 ~/Downloads/compresoclean_icon.svg -o /tmp/compreso_icon.png
mkdir -p /tmp/compreso.iconset
sips -z 16 16     /tmp/compreso_icon.png --out /tmp/compreso.iconset/icon_16x16.png
sips -z 32 32     /tmp/compreso_icon.png --out /tmp/compreso.iconset/icon_16x16@2x.png
sips -z 32 32     /tmp/compreso_icon.png --out /tmp/compreso.iconset/icon_32x32.png
sips -z 64 64     /tmp/compreso_icon.png --out /tmp/compreso.iconset/icon_32x32@2x.png
sips -z 128 128   /tmp/compreso_icon.png --out /tmp/compreso.iconset/icon_128x128.png
sips -z 256 256   /tmp/compreso_icon.png --out /tmp/compreso.iconset/icon_128x128@2x.png
sips -z 256 256   /tmp/compreso_icon.png --out /tmp/compreso.iconset/icon_256x256.png
sips -z 512 512   /tmp/compreso_icon.png --out /tmp/compreso.iconset/icon_256x256@2x.png
sips -z 512 512   /tmp/compreso_icon.png --out /tmp/compreso.iconset/icon_512x512.png
iconutil -c icns /tmp/compreso.iconset -o /tmp/compreso.icns
cp /tmp/compreso.icns /Applications/CompresoClean.app/Contents/Resources/AppIcon.icns

### 5. Moved to Applications and refreshed
mv ~/Desktop/CompresoClean.app /Applications/CompresoClean.app
touch /Applications/CompresoClean.app
killall Dock

### 6. Packaged as DMG
hdiutil create -volname "CompresoClean" \
  -srcfolder /Applications/CompresoClean.app \
  -ov -format UDZO \
  ~/Desktop/CompresoClean.dmg

---

## Adding support for creative apps (Photoshop, After Effects, DaVinci Resolve)

### Adobe Photoshop cache cleanup
rm -rf ~/Library/Application\ Support/Adobe/Adobe\ Photoshop*/Adobe\ Photoshop*\ Settings/Temp
rm -rf ~/Library/Caches/com.adobe.photoshop*

### Adobe After Effects cache cleanup  
rm -rf ~/Library/Application\ Support/Adobe/After\ Effects/*/disk\ cache
rm -rf ~/Library/Caches/com.adobe.AfterEffects*
# Note: Also clear disk cache from inside After Effects:
# Preferences > Media & Disk Cache > Empty Disk Cache

### DaVinci Resolve cache cleanup
rm -rf ~/Library/Application\ Support/Blackmagic\ Design/DaVinci\ Resolve/Support/CacheClip
rm -rf ~/Library/Caches/com.blackmagic-design.DaVinciResolve*
# Note: Also clear from inside Resolve:
# Playback > Delete Render Cache > All

### Adobe Premiere Pro cache cleanup
rm -rf ~/Library/Application\ Support/Adobe/Common/Media\ Cache
rm -rf ~/Library/Application\ Support/Adobe/Common/Media\ Cache\ Files
rm -rf ~/Library/Caches/com.adobe.AdobePremierePro*

### Final Cut Pro cache cleanup
rm -rf ~/Movies/Final\ Cut\ Backups
rm -rf ~/Library/Caches/com.apple.FinalCut*

---

## GUI alternative (for coworkers who prefer no terminal)

For team members who are not comfortable with terminal:

1. **OnyX** (free) — https://www.titanium-software.fr/en/onyx.html
   Best free CleanMyMac alternative. GUI based, safe, trusted.

2. **DiskDiag** (free on App Store)
   Shows disk usage visually, helps identify large files.

3. **Hand brake** (free) — https://handbrake.fr
   For compressing video files before archiving.

4. **ImageOptim** (free) — https://imageoptim.com
   Drag and drop image compression. Great for designers.

---

## Storage tips for creative teams

- Photoshop scratch disk: keep it on an external SSD if Mac storage is low
- After Effects: always purge image cache before closing (Edit > Purge > All)
- DaVinci Resolve: set cache to an external drive in Preferences > Media Storage
- Never store raw footage on Mac SSD — use external drives or NAS

---

## Built with
- macOS Sequoia
- Terminal (zsh)
- Claude.ai (AI pair programming)
- OneMark internal tooling

---

*CompresoClean is an OneMark internal tool. Free to use and share within the team.*
*For issues or additions contact: viswanathbodasakurthi@gmail.com*

---

## Changelog — v1.1 (April 2, 2026)

### Bug fix
**Fixed: 2 out of 5 machines were skipping DaVinci Resolve and Final Cut Pro because they
were installed in non-default paths. Fixed by switching from hardcoded /Applications/ paths
to mdfind Spotlight search which finds apps anywhere on the Mac.**

### New features added
- **Confirmation prompt** — a macOS dialog prompts "Clean Now / Cancel" before any cleanup runs
- **Dynamic app detection via mdfind** — Spotlight scans the entire Mac for installed creative
  apps regardless of where they are installed (see "Dynamic detection" section below)
- **Creative app cleanups with skip if not found** — each of the five creative apps is cleaned
  only if detected; otherwise a skip message is printed and logged
  - Adobe Photoshop (Settings/Temp + com.adobe.photoshop* caches)
  - Adobe After Effects (disk cache + com.adobe.AfterEffects* caches)
  - Adobe Premiere Pro (Media Cache, Media Cache Files + com.adobe.AdobePremierePro* caches)
  - DaVinci Resolve (CacheClip + com.blackmagic-design.DaVinciResolve* caches)
  - Final Cut Pro (Final Cut Backups + com.apple.FinalCut* caches)
- **Cleanup log at ~/.compresoclean.log** — every run appends a timestamped entry; each
  creative app result (cleaned or skipped) is also logged individually
- **macOS notification with MB freed** — a system notification fires after cleanup showing
  exactly how many MB were freed

---

## Dynamic detection — how mdfind works in v1.1

### Why mdfind was chosen over hardcoded paths

v1.0 used hardcoded checks like `[ -d "/Applications/DaVinci Resolve.app" ]`. This broke
on machines where users had installed apps to external drives, a second internal volume, or
a custom folder like `/Applications/Creative/`. Two out of five team Macs were silently
skipping DaVinci Resolve and Final Cut Pro for this reason.

mdfind queries Spotlight's metadata index, which tracks every application on every mounted
volume. It does not care where the app lives — it will find it.

### The find_app() function

    # Dynamic app finder using Spotlight
    find_app() {
        mdfind "kMDItemKind == 'Application' && kMDItemDisplayName == '$1'" 2>/dev/null | head -1
    }

- `kMDItemKind == 'Application'` — limits results to .app bundles
- `kMDItemDisplayName == '$1'` — matches the visible app name exactly
- `head -1` — takes the first result if multiple copies are installed
- `2>/dev/null` — suppresses Spotlight permission warnings silently

### App variables set at runtime

    PHOTOSHOP=$(find_app "Adobe Photoshop 2025")
    [ -z "$PHOTOSHOP" ] && PHOTOSHOP=$(find_app "Adobe Photoshop 2024")
    [ -z "$PHOTOSHOP" ] && PHOTOSHOP=$(find_app "Adobe Photoshop 2023")

    AFTEREFFECTS=$(find_app "After Effects")
    DAVINCI=$(find_app "DaVinci Resolve")

    PREMIERE=$(find_app "Adobe Premiere Pro 2025")
    [ -z "$PREMIERE" ] && PREMIERE=$(find_app "Adobe Premiere Pro 2024")
    [ -z "$PREMIERE" ] && PREMIERE=$(find_app "Adobe Premiere Pro 2023")

    FINALCUT=$(find_app "Final Cut Pro")

Adobe apps include the year in their display name, so the script tries recent years in
descending order and stops at the first match. Apps with stable names (After Effects,
DaVinci Resolve, Final Cut Pro) need only one lookup.

---

## How to view cleanup history

    cat ~/.compresoclean.log

Each line is in the format:

    [YYYY-MM-DD HH:MM:SS] Cleanup complete — X MB freed

Per-app lines are indented:

      ✓ Photoshop cache cleared
      ⊘ DaVinci Resolve not found — skipped

---

## How to add a new app in future versions

Use the find_app() pattern. This is the full template for adding any new creative app:

    # 1. Detect the app via Spotlight
    MYAPP=$(find_app "Exact App Display Name")

    # 2. Clean if found, skip if not
    if [ -n "$MYAPP" ]; then
        echo "→ Found MyApp at: $MYAPP"
        echo "→ Clearing MyApp cache..."
        rm -rf ~/Library/Caches/com.vendor.myapp* 2>/dev/null
        rm -rf ~/Library/Application\ Support/Vendor/MyApp/Cache 2>/dev/null
        echo "✓ MyApp cache cleared"
        echo "  ✓ MyApp cache cleared" >> $LOGFILE
    else
        echo "⊘ MyApp not found on this Mac — skipping"
        echo "  ⊘ MyApp not found — skipped" >> $LOGFILE
    fi

To find the exact display name to pass to find_app(), run this in Terminal:

    mdfind "kMDItemKind == 'Application'" | xargs -I{} mdls -name kMDItemDisplayName "{}" | grep -i "appname"

Or simply check the app name as it appears in Spotlight search (Cmd+Space).
