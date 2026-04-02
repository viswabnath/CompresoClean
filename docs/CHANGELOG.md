# Changelog — CompresoClean
All notable changes to CompresoClean are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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