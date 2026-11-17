# Changelog — CompresoClean
All notable changes to CompresoClean are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.5] — 2026-11

### Added
- **Dry-run mode** — a "Preview (Dry Run)" button on the confirmation dialog,
  or `bash src/CompresoClean --dry-run`. Runs the full flow (including the
  simulator and Smart Scan prompts) but deletes nothing: every `rm -rf` is
  now an `rmx` helper that tallies sizes instead, items >= 10 MB are listed,
  and the summary shows approximate MB reclaimable (nested/overlapping paths
  counted once). Dry runs skip the per-item `[ok]` log lines.

- **Trash mode** — `--trash` flag, or answer `y` to the new runtime prompt.
  Anything under `$HOME` is moved to `~/.Trash` instead of deleted, so it can
  be restored; space is reclaimed once the Trash is emptied. A failed move
  leaves the item in place. Tool-driven cleanups (npm, brew, Docker, simctl)
  and paths outside `$HOME` (e.g. `/tmp`) are still permanent.
- **pnpm, Yarn (Berry/custom cache dir) and Docker cleanup** — pnpm store and
  Yarn caches are removed; Docker only prunes dangling images and build cache
  (containers and volumes are never touched).
- **Large-file finder (report only)** — lists the 15 largest files over
  200 MB under `$HOME`, with dates. Never deletes.
- **Orphaned app data finder (report only)** — flags `~/Library` leftovers
  (Application Support, Containers, Preferences, Saved State, HTTPStorages,
  WebKit) whose vendor prefix matches no installed app. Heuristic; never
  deletes.
- **Optional signing + notarization in `build.sh`** — set `CODESIGN_IDENTITY`
  and `NOTARY_PROFILE` to produce a signed, notarized, stapled DMG.

### Fixed
- Trash mode empties the existing Trash *before* moving new items into it
  (found in a real run: it was deleting what it had just moved).
- Runner banner, log line and notification showed "v1.3"; the version is now
  passed from the launcher (`CC_VERSION`).

## [1.4] — 2026-09

### Changed
- **Simulators/emulators can now be fully wiped, not just orphaned ones** — a
  real design-philosophy change from v1.3, which deliberately preserved
  configured devices as "real user artifacts, not junk". Gated behind a new
  prompt (see Added below) rather than made unconditional, since it's a
  bigger behavior change than the rest of this release:
  - iOS: `xcrun simctl delete unavailable` → `xcrun simctl delete all` +
    `xcrun simctl runtime delete all` (the runtime OS disk images are often
    the larger half — 10-20GB combined is common)
  - Android: AVDs (`~/.android/avd`) and the SDK's `system-images`,
    `emulator` binary, and `skins` (often another 10-15GB)
  - Rationale: both are fully regenerated on demand (Xcode/`sdkmanager`
    re-download the OS image; recreating a device takes under a minute), so
    offering them as reclaimable space is more useful than v1.3's blanket
    exclusion — but it's still a real behavior change from a device you may
    have deliberately configured, so it isn't silently unconditional either.
    The Android SDK toolchain itself (build-tools, platform-tools, NDK,
    platforms) is never touched either way — only the emulator-specific
    pieces.

### Added
- **"Delete ALL iOS simulators + Android emulators?" prompt** — asked once,
  up front, before either platform's device data is touched; defaults to No.
  DerivedData, CoreSimulator caches, Gradle caches, and each tool's own app
  cache are unaffected by the answer and always run — only the actual
  device/runtime wipe is gated on it.
- **iOS DeviceSupport cleanup** — per-device debug symbols
  (`~/Library/Developer/Xcode/iOS DeviceSupport`, `watchOS DeviceSupport`)
  that Xcode downloads when a physical device connects; re-synced
  automatically on next connect
- **CoreDevice install cache** — stashed test-build install cache under
  `~/Library/Containers/com.apple.CoreDevice.CoreDeviceService`
- **Hidden dotfile cache cleanup** — a new section for CLI/Electron-style
  tools that cache directly under `$HOME` as dotfiles instead of the
  standard `~/Library/Caches`/`~/Library/Application Support` locations
  Smart Scan actually checks, so they were previously invisible to it:
  - `~/.cache` (generic)
  - `~/.npm/_npx` (npx package-install cache)
  - `~/.pub-cache`, `~/.dartServer` (Flutter/Dart)
  - Antigravity IDE: `browser_recordings` (agent browser-session captures),
    `conversations` (chat history — included since it's consistently the
    largest recurring offender), and dated full-state backup snapshots

### Fixed
- The standard `~/Library/Caches/*` wipe would silently leave behind any
  cached item containing read-only files (e.g. a cached signed `.app`
  bundle) — `rm -rf` can't remove entries inside a directory it doesn't have
  write permission on. Now `chmod -R u+w` runs first.

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