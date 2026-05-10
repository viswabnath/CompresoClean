# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

CompresoClean is a macOS disk-cleaning app distributed as a `.app` bundle and DMG. The entire cleaner logic is a single bash script (`src/CompresoClean`). There is no build system, package manager, or test suite.

## Commands

**Edit & rebuild:**
```bash
# 1. Edit the source script
nano src/CompresoClean

# 2. Rebuild .app bundle and create DMG
./build.sh          # uses default version (currently 1.2)
./build.sh 1.3      # pass a version number to bump
```

**Test the script directly without building:**
```bash
bash src/CompresoClean
```

**Edit inside the installed app directly:**
```bash
cd /Applications/CompresoClean.app/Contents/MacOS
# edit CompresoClean here, then run ./build.sh to sync back
```

**View the run log:**
```bash
cat ~/.compresoclean.log
```

## Creating a DMG

`build.sh` handles everything. It:
1. Validates `src/CompresoClean` exists
2. Copies it into `app/CompresoClean.app/Contents/MacOS/` and sets executable
3. Writes `Info.plist` if missing (bundle ID `in.onemark.compresoclean`, min macOS 12.0)
4. Prompts whether to sync the updated `.app` to `/Applications/`
5. Copies the `.app`, `docs/instructions.md`, and `README.md` into a temp staging dir
6. Runs `hdiutil create -format UDZO` to produce the DMG
7. Outputs the DMG to `~/Desktop/CompresoClean_v<version>.dmg`

To create the DMG manually without the script:
```bash
hdiutil create \
  -volname "CompresoClean v1.2 by OneMark" \
  -srcfolder app/ \
  -ov \
  -format UDZO \
  ~/Desktop/CompresoClean_v1.2.dmg
```

After building, upload the DMG to GitHub Releases manually.

## Architecture

The project has two representations of the same script — keep them in sync:

- `src/CompresoClean` — **source of truth**. Edit this.
- `app/CompresoClean.app/Contents/MacOS/CompresoClean` — the copy bundled into the `.app`. `build.sh` overwrites this from `src/` on every build.

**How the script works at runtime:**

The outer script shows an `osascript` confirmation dialog, then writes the actual cleanup logic to `~/.compresoclean_runner.sh` and launches it in a new Terminal window. This indirection is necessary because `/tmp/*` is wiped during cleanup, so the runner script must live in the home directory. The runner self-deletes on completion.

**App detection:** Uses `mdfind` (Spotlight) with two strategies — bundle ID (`detect_by_bundle`) preferred, display name (`detect_by_name`) as fallback. `detect_by_name` automatically tries year suffixes 2026 through 2022 before the bare name, handling Adobe's yearly versioning. `shopt -s nullglob` ensures unmatched glob patterns silently expand to nothing.

**Versioning:** Version string lives in two places — `VERSION=` at the top of `src/CompresoClean`, and the default in `build.sh` (`VERSION="${1:-1.2}"`). Update both when bumping.

## Distribution

- DMG is uploaded to GitHub Releases manually after running `build.sh`
- The `app/` directory in the repo contains the pre-built `.app` bundle (plug-and-play for users who clone)
- `files/` contains the icon SVG and reference screenshots — not used by the build
