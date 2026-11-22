# CLAUDE.md - Godot Project (GDScript)

This file provides project context and conventions for AI-assisted development sessions.
Read this file and ARCHITECTURE.md before making any changes. Behavioral rules and
guardrails are auto-loaded from `.claude/rules/` - there is nothing else to open.

---

## Project Overview

<!-- One paragraph. What kind of game/application is this, what is the core loop or
main purpose, who is it for. -->
<!-- Example: -->
<!-- my_game is a 2D top-down roguelike built in Godot 4. It solves the "one more -->
<!-- run" itch by generating a new dungeon layout every attempt. -->

---

## Tech Stack

| Component       | Choice                        | Reason                              |
|-----------------|--------------------------------|--------------------------------------|
| Engine          | Godot 4.x                     | <!-- Why this engine/version -->     |
| Scripting       | GDScript                       | <!-- Why not C# for this project --> |
| Rendering       | <!-- Forward+/Mobile/Compatibility --> | <!-- Why -->                 |
| Test framework  | <!-- GUT/GdUnit4/none yet --> | <!-- Why -->                         |
| Key addon       | <!-- name -->                 | <!-- What it provides -->            |

---

## Repository Layout

```
project_name/
- scenes/               # .tscn scene files
- scripts/               # .gd scripts (or colocated with their scene - note which)
- autoload/              # Singleton scripts registered in Project Settings
- assets/
  - sprites/             # Source art
  - audio/               # SFX and music
  - fonts/               # Font resources
- addons/                # Third-party and in-house plugins
- tests/                 # Test suite
- docs/                  # Additional documentation
- .claude/               # Auto-loaded rules (.claude/rules/) and settings.json
- ARCHITECTURE.md        # Component and data flow reference
- CHANGELOG.md           # Version history (Keep a Changelog format)
- CLAUDE.md              # This file
- CONTRIBUTING.md        # Contribution guidelines
- PLANNING.md            # Goals, milestones, open questions
- README.md              # Public-facing documentation
- LICENSE                # Project license
- project.godot          # Engine project manifest
- export_presets.cfg     # Export target configuration (review before committing -
                         # can contain machine-specific paths/signing credentials)
```

<!-- Annotate any non-obvious directories or files specific to this project. -->

---

## Opening and Running

### Prerequisites

```bash
# Godot 4.x (4.3+ recommended) - https://godotengine.org/download
```

### Open in the Editor

```bash
godot --editor project.godot
```

### Run Without Opening the Editor

```bash
godot --path .
```

### Export

```bash
# Requires export templates matching the project's engine version installed first
godot --headless --export-release "Linux/X11" build/app_name.x86_64
godot --headless --export-release "Windows Desktop" build/app_name.exe
godot --headless --export-release "macOS" build/app_name.app
```

---

## Running Tests

```bash
# Document the actual command for whichever test framework this project uses.
# Example (GUT):
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit

# Example (GdUnit4):
godot --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests
```

---

## Save Data and Settings

- Save data and settings live under `user://` - never a literal `~/.app_name/` or
  any other hardcoded path; `user://` resolves automatically per platform
- Prefer `ConfigFile` or a `.tres` Resource for structured save data over
  hand-rolled JSON/YAML parsing, unless external tooling needs to read the file
- `res://` project resources are read-only at runtime in an exported build - do
  not attempt to write there

### Save File Structure

```
<!-- Document the save file name, format, and top-level fields. -->
<!-- Example: -->
<!-- user://save_slot_1.tres - a Resource with fields: version, player_data -->
```

---

## Code Style and Conventions

Behavioral rules and guardrails are auto-loaded from `.claude/rules/` - see
`universal.md` plus `godot.md` and `gdscript.md`.

### Project-Specific Notes

```
<!-- Add any project-specific style deviations or enforced patterns here -->
<!-- Example: -->
<!-- Signal bus pattern used for cross-system events - see autoload/EventBus.gd -->
```

---

## Current Focus

See PLANNING.md for active goals, open questions, and pending decisions.

<!-- Optionally note the current sprint or immediate next task here so Claude -->
<!-- picks up context quickly at the start of a session. -->
<!-- Example: -->
<!-- Currently working on: procedural dungeon generation for floor 2. -->
