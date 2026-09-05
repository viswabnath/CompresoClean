# CompresoClean — Build Documentation
**Built by Viswanath Bodasakurthi | OneMark Agency**
**Date: April 2026 (updated September 2026) | Version: 1.4**

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

---

## Changelog — v1.3 (August 2026)

### New feature: Smart Scan

Previously, cache cleanup only ran for the ~28 creative apps hardcoded into the script.
Any other heavy app (browsers, IDEs, chat apps, etc.) was invisible to CompresoClean even
if it was hoarding gigabytes of cache. v1.3 adds a generic scan that covers every installed
app, on top of the existing curated cleanup (which is unchanged).

### How Smart Scan works

1. Finds every `.app` bundle in `/Applications` and `~/Applications`, including apps
   nested inside a folder (e.g. `Adobe Photoshop 2025/Adobe Photoshop 2025.app`), using:

       find /Applications "$HOME/Applications" \( -iname "*.app" -type d \) -prune -print

   `-prune` stops `find` from descending into a matched `.app`, so helper apps bundled
   inside `Contents/` aren't double-counted.

2. For each app, reads its bundle ID directly from `Info.plist`:

       bundle_id=$(defaults read "$app/Contents/Info" CFBundleIdentifier 2>/dev/null)

3. Sizes up only known junk locations for that app — never the app bundle itself, and
   never general user data:
   - `~/Library/Caches/<bundle_id>*`
   - `~/Library/Logs/<app_name>*`
   - `~/Library/Saved Application State/<bundle_id>*.savedState`
   - `~/Library/Containers/<bundle_id>/Data/Library/Caches/*` (sandboxed apps)
   - Junk-named subfolders only (`Cache`, `Caches`, `Cache Files`, `GPUCache`,
     `Code Cache`, `tmp`, `temp`) inside `~/Library/Application Support/<app_name>` —
     the rest of Application Support (real settings, projects, licenses) is left alone

4. Ranks the top 15 apps by total reclaimable size and prints them as a numbered list
   in the terminal.

5. Prompts for input: type comma-separated numbers (`1,3,5`), `all`, or press Enter to
   skip. Only the apps you pick are cleaned, and each one is logged individually to
   `~/.compresoclean.log`.

### Bug fixes found while building Smart Scan

- **bash 3.2 compatibility**: macOS ships bash 3.2 by default (`/bin/bash`), which does
  not have `mapfile`/`readarray` (added in bash 4.0). The script originally used
  `mapfile -t arr < <(cmd)`; this silently failed with `mapfile: command not found` on a
  stock Mac. Replaced with a portable pattern:

        arr=()
        while IFS= read -r line; do arr+=("$line"); done < <(cmd)

- **Empty app-name glob widening**: if an app's name were ever empty, the pattern
  `"$HOME"/Library/Logs/"$app_name"*` would collapse to `Logs/*`, which — with
  `nullglob` on — matches *every* file in `~/Library/Logs`, not nothing. Same issue
  existed for the `Application Support/$app_name` directory check. Fixed by returning
  early from the junk-path lookup whenever `app_name` is empty:

        [ -z "$app_name" ] && return

  In practice `app_name` always comes from `basename "$app" .app` on a real path, so
  this was a defensive fix rather than an observed failure — but the blast radius
  (deleting unrelated apps' logs) was high enough to guard against explicitly.

### Verification

Tested the scan functions in isolation against real apps on a dev Mac (not the packaged
`.app`, just the extracted bash functions) before shipping:
- Empty `bundle_id`/`app_name` inputs correctly produced zero candidate paths.
- A full scan across every installed app on the machine completed in about a second and
  surfaced sensible, real results (e.g. an 881 MB cache for one app, tens of MB for
  several others) — confirming the ranking and glob logic behave as intended.

### Follow-up: Xcode and Android Studio were invisible to Smart Scan

After shipping the above, real-world testing showed Xcode and Android Studio — both
installed and detected by `mdfind` — never appeared in the Smart Scan checklist at all.
Cause: neither app's real cache lives under `~/Library/Caches`, `~/Library/Logs`,
`~/Library/Saved Application State`, or `~/Library/Containers` — the only locations
Smart Scan's generic heuristic checks. Measured on the dev Mac:

    ~/Library/Developer/Xcode/DerivedData     2.7 GB
    ~/Library/Developer/CoreSimulator         6.4 GB
    ~/.gradle/caches                          4.6 GB
    ~/.android/avd                             10 GB

~24 GB combined, computed as 0 MB reclaimable by Smart Scan, and silently filtered out
before ever reaching the picker.

Fix: added an explicit "Developer Tools" block to the curated cleanup (same pattern as
Blender's dynamic cache-dir handling), rather than trying to generalize the heuristic
further:

- **Xcode** — `DerivedData`, `CoreSimulator/Caches`, `xcrun simctl delete unavailable`,
  and its own `~/Library/Caches/com.apple.dt.Xcode*`
- **Android Studio / Gradle** — `~/Library/Caches/Google/AndroidStudio*`,
  `~/Library/Application Support/Google/AndroidStudio*/caches`, `~/.gradle/caches`

Deliberately **not** touched (as of v1.3): Xcode Archives (`~/Library/Developer/Xcode/Archives`)
and Android AVDs (`~/.android/avd`). Both showed up as huge in the measurements above, but
they aren't cache — Archives are your actual App Store submission builds, and an AVD is
a configured virtual device with its own installed apps and data. Deleting either would
destroy real work, not reclaim junk, so they're out of scope for automatic cleanup.

### Follow-up (v1.4): simulators/AVDs were the single biggest miss, and a policy reversal

A manual storage audit in September 2026 found CompresoClean's own `xcrun simctl delete
unavailable` (v1.3) only removes device instances whose runtime is already missing —
not the actual runtime OS disk images themselves, and not any device whose runtime is
still installed and "available." Measured on the dev Mac:

    iOS: CoreSimulator/Devices (device instances)         6.8 GB
    iOS: CoreSimulator/Volumes (runtime OS disk images)     16 GB
    Android: ~/.android/avd (AVDs)                          12 GB
    Android SDK: system-images + emulator binary + skins  3.2 GB

~38 GB combined, none of it touched by v1.3 — more than every other category in this
document put together.

This forced a genuine policy reversal from the v1.3 "AVDs are real user data, not cache"
stance above. The reasoning that held for v1.3 (an AVD is a configured device with
installed apps and data) is true, but in practice both an AVD and a simulator are fully
regenerated on demand — Xcode/`sdkmanager` re-download the runtime image, and recreating
a device from a saved config takes under a minute.

Rather than making that reversal unconditional, it's a new prompt asked once up front:
"Delete ALL iOS simulators + Android emulators? [y/N]" (defaults to No). Reasoning:
"regenerable" is a good bar for what CAN be offered as reclaimable space, but a device you
configured on purpose is still a bigger, more visible change than a build cache silently
disappearing -- so it gets a real choice instead of joining DerivedData/Gradle caches in
the unconditional pile. `xcrun simctl delete unavailable` → (if yes) `xcrun simctl delete
all` + `xcrun simctl runtime delete all`; Android AVDs and the SDK's
`system-images`/`emulator`/`skins` follow the same yes/no. Everything else in this
section -- DerivedData, CoreSimulator/Gradle caches, each tool's own app cache -- is
unaffected by the answer and still runs unconditionally. The SDK toolchain itself
(build-tools, platform-tools, NDK, platforms) stays untouched either way, since it isn't
emulator-specific and is still needed to build.

Also added while investigating: `iOS DeviceSupport` (per-device debug symbols, 5.5 GB on
the dev Mac, re-synced on next device connect) and a `CoreDevice` install cache — both
found by the same audit and just as invisible to Smart Scan as Xcode/Gradle were in v1.3.

### Follow-up (v1.4): hidden dotfile caches were invisible to Smart Scan too

The same audit found a second, different-shaped gap: Smart Scan's per-app heuristic only
ever looks under `~/Library/Caches`, `~/Library/Logs`, `~/Library/Saved Application
State`, `~/Library/Containers/*/Data/Library/Caches`, and junk-named subfolders inside
`~/Library/Application Support` — all rooted under `~/Library`. A growing number of CLI
tools and Electron-style apps instead cache directly under `$HOME` as a dotfile
(`~/.cache`, `~/.foo`), which no amount of tuning the `~/Library`-rooted heuristic would
ever find. Measured: `~/.cache` 1.4 GB, `~/.pub-cache` (Flutter/Dart) 434 MB,
`~/.dartServer` 468 MB, `~/.npm/_npx` 12 MB, and — the largest single item —
`~/.gemini/antigravity-ide/browser_recordings` (AI-agent browser-session captures) at
6.3 GB, plus a dated full-state `antigravity-backup` snapshot at 3.0 GB and
`conversations` (chat history) at 903 MB.

Fix: a new explicit section, same pattern as Developer Tools — check each known dotfile
path exists, remove it, log it. `conversations` is chat history rather than pure cache,
included anyway since it was consistently the largest recurring offender in practice;
flagged in code and here in case that trade-off needs revisiting later.

### Follow-up: the multi-select dialog didn't feel like it supported multiple apps

Real-world testing also surfaced a usability bug in the Smart Scan picker. The AppleScript
`choose from list ... with multiple selections allowed` dialog does technically support
picking more than one item — but only via Cmd-click or Shift-click. A plain click on a
second row replaces the first selection instead of adding to it, which is standard macOS
list-box behavior but isn't discoverable, and reads as "the app won't let me select more
than one."

Fix: dropped the GUI dialog entirely in favor of a terminal numbered list, consistent with
the rest of CompresoClean's terminal-driven UX:

    heaviest apps found:
       1) Claude -- 881 MB reclaimable (app 320 MB)
       2) Antigravity -- 71 MB reclaimable (app 210 MB)
       3) WhatsApp -- 69 MB reclaimable (app 180 MB)

    Enter numbers to clean (e.g. 1,3,5), 'all', or press Enter to skip:

Typing `1,3,5` selects three apps as easily as one; `all` selects everything shown;
pressing Enter with no input skips cleanly. This removed the modifier-key requirement
entirely and also simplified the implementation -- selection is now matched by array
index instead of exact string comparison against AppleScript's returned list, so there's
no risk of two apps with visually similar labels being mismatched.
