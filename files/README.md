# CompresoClean v1.1
### Free Mac Cleaner by OneMark

## How to install
1. Open the DMG file
2. Drag CompresoClean to your Applications folder
3. Right-click → Open (first time only, to bypass Gatekeeper)
4. Double-click anytime to clean your Mac

## What it does
Cleans caches, logs, npm, brew, trash, temp files, and creative app caches in one click.
Shows how much space was freed before and after, sends a macOS notification, and logs every run.

## How it works
When you launch CompresoClean, it first asks for confirmation before touching anything.
It then uses macOS Spotlight (mdfind) to automatically scan your entire Mac for installed
creative apps — no hardcoded paths, no assumptions about where apps live. Each app is
only cleaned if Spotlight confirms it is present on the machine.

Works even if apps are installed on external drives or custom folders.

## Supported creative apps
- Adobe Photoshop
- Adobe After Effects
- Adobe Premiere Pro
- DaVinci Resolve
- Final Cut Pro

Each app is detected dynamically. If an app is not installed, it is skipped cleanly with a
log entry — no errors, no noise.

## What's new in v1.1
- Confirmation dialog before cleanup starts — no accidental runs
- Dynamic creative app detection via Spotlight — finds apps anywhere on the Mac
- Creative app cleanups: Adobe Photoshop, After Effects, Premiere Pro, DaVinci Resolve, Final Cut Pro
- Skips apps that are not installed rather than erroring out
- MB freed calculated and shown after every run
- macOS notification popup when cleanup completes
- Cleanup log saved to ~/.compresoclean.log with date and time on every run

## Cleanup log
Every run is logged automatically to:

    ~/.compresoclean.log

Each entry includes the date, time, and MB freed. View the log at any time:

    cat ~/.compresoclean.log

## Built by
Viswanath Bodasakurthi | OneMark Agency | 2026
