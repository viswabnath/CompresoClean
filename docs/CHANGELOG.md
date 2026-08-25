# Changelog — CompresoClean
All notable changes to CompresoClean are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.3] — 2026-08

### Added
- **Developer Tools cleanup** — explicit handling for Xcode and Android
  Studio/Gradle, whose real disk hogs live outside the generic Caches/Logs/
  Containers locations Smart Scan checks:
  - Xcode: `~/Library/Developer/Xcode/DerivedData`,
    `~/Library/Developer/CoreSimulator/Caches`, unavailable simulators
    (`xcrun simctl delete unavailable`), and its own app cache
  - Android Studio: `~/Library/Caches/Google/AndroidStudio*`, its
    Application Support caches, and `~/.gradle/caches`
  - Deliberately does **not** touch Xcode Archives (actual App Store
    submission builds) or Android AVDs (configured virtual devices) — both
    are real user artifacts, not junk, even though they're large
- **Smart Scan** — a generic scan of every installed app (not just the curated
  list), independent of the hand-picked per-app cleanup rules
  - Walks `/Applications` and `~/Applications`, including nested installs
    (e.g. `Adobe Photoshop 2025/Adobe Photoshop 2025.app`)
  - Reads each app's bundle ID via `defaults read` and sizes its reclaimable
    junk: `~/Library/Caches`, `~/Library/Logs`, `~/Library/Saved Application
    State`, sandboxed container caches under `~/Library/Containers`, and
    junk-named subfolders (`Cache`, `Caches`, `Cache Files`, `GPUCache`,
    `Code Cache`, `tmp`, `temp`) inside `Application Support`
  - Never touches the app bundle itself or real user data/settings in
    Application Support — only known junk subfolders
  - Ranks the top 15 apps by reclaimable size and presents them as a numbered
    list in the terminal; the user types comma-separated numbers (`1,3,5`),
    `all`, or presses Enter to skip
  - Cleaned apps are logged individually to `~/.compresoclean.log`

### Fixed
- Replaced `mapfile`/`readarray` (bash 4+ only) with a portable `while read`
  loop — macOS ships bash 3.2 by default, so `mapfile` silently failed
- Guarded the junk-path scan against an empty app name, which could otherwise
  widen the `Logs`/`Application Support` glob to match every installed app's
  files instead of just the one being scanned
- Replaced the AppleScript `choose from list` picker with a terminal numbered
  list — the GUI dialog only supported multi-select via Cmd/Shift-click,
  which isn't discoverable and read as "can't select multiple apps." Typing
  `1,3,5` works identically for one app or many

---

## [1.1] — 2025-06

### Added
- Confirmation dialog before any cleaning begins — no accidental wipes
- macOS notification after cleanup showing exact MB freed
- Run logging to `~/.compresoclean.log` with date/time per entry
- Dynamic creative app detection via `mdfind` Spotlight search
  - Supports: Photoshop, After Effects, Premiere Pro, DaVinci Resolve, Final Cut Pro
  - Works even if apps are installed outside `/Applications`
  - Shows detected app path in terminal output
  - Gracefully skips with message if app not found

### Fixed
- Dynamic path detection now works correctly for all team Macs
- Cleaned up output formatting for better readability

---

## [1.0] — 2025-05

### Added
- Initial release — internal OneMark team tool
- Cleans: system caches, app logs, npm cache, Homebrew leftovers, Trash, temp files
- Packaged as macOS `.app` bundle + DMG for AirDrop distribution
- Built using terminal + Claude Code

---

*Built by Viswanath Bodasakurthi · OneMark Agency*