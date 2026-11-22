# CLAUDE.md - Godot Project (C# / .NET)

This file provides project context and conventions for AI-assisted development sessions.
Read this file and ARCHITECTURE.md before making any changes. Behavioral rules and
guardrails are auto-loaded from `.claude/rules/` - there is nothing else to open.

Godot's C# support was called "Mono" in Godot 3.x and is called ".NET" in Godot 4.x -
same underlying idea, renamed label. This project targets the Godot 4.x .NET build.

---

## Project Overview

<!-- One paragraph. What kind of game/application is this, what is the core loop or
main purpose, who is it for. -->
<!-- Example: -->
<!-- my_game is a 2D top-down roguelike built in Godot 4 (.NET build). It solves the -->
<!-- "one more run" itch by generating a new dungeon layout every attempt. -->

---

## Tech Stack

| Component       | Choice                        | Reason                              |
|-----------------|--------------------------------|--------------------------------------|
| Engine          | Godot 4.x (.NET build)         | <!-- Why this engine/version -->     |
| Scripting       | C#                              | <!-- Why not GDScript for this project --> |
| .NET SDK        | <!-- version -->                | <!-- Why -->                         |
| Rendering       | <!-- Forward+/Mobile/Compatibility --> | <!-- Why -->                 |
| Test framework  | <!-- GdUnit4/xUnit for node-independent logic/none yet --> | <!-- Why --> |

---

## Repository Layout

```
project_name/
- scenes/               # .tscn scene files
- scripts/               # .cs scripts (or colocated with their scene - note which)
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
- AppName.csproj         # .NET project file - dependencies go here (NuGet packages)
- export_presets.cfg     # Export target configuration (review before committing -
                         # can contain machine-specific paths/signing credentials)
```

<!-- Annotate any non-obvious directories or files specific to this project. -->

---

## Opening and Running

### Prerequisites

```bash
# Godot 4.x .NET build (4.3+ recommended) - https://godotengine.org/download
# Matching .NET SDK - https://dotnet.microsoft.com/download
```

### Open in the Editor

```bash
godot --editor project.godot
# The editor builds the C# project (via the .NET SDK) automatically on first open
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
# Plain C# classes with no Godot/node dependencies can run under a normal
# .NET test runner:
dotnet test

# Anything touching the scene tree, signals, or node lifecycle needs a
# Godot-aware runner (example: GdUnit4):
godot --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests
```

---

## Save Data and Settings

- Save data and settings live under `user://` - never a literal `~/.app_name/` or
  any other hardcoded path; `user://` resolves automatically per platform
- Use `ProjectSettings.GlobalizePath()` / `OS.GetUserDataDir()` only when an API
  genuinely requires a real OS path - most save/config code should stay in
  `user://`/`res://` terms
- `res://` project resources are read-only at runtime in an exported build - do
  not attempt to write there

### Save File Structure

```
<!-- Document the save file name, format, and top-level fields. -->
```

---

## Code Style and Conventions

Behavioral rules and guardrails are auto-loaded from `.claude/rules/` - see
`universal.md` plus `csharp.md` and `godot_csharp.md`. Remember: scripts attached
to nodes must be `partial class`, and `_Process`/`_PhysicsProcess` take a
`double delta`, not `float`.

### Project-Specific Notes

```
<!-- Add any project-specific style deviations or enforced patterns here -->
<!-- Example: -->
<!-- Signal bus pattern used for cross-system events - see autoload/EventBus.cs -->
```

---

## Current Focus

See PLANNING.md for active goals, open questions, and pending decisions.

<!-- Optionally note the current sprint or immediate next task here so Claude -->
<!-- picks up context quickly at the start of a session. -->
<!-- Example: -->
<!-- Currently working on: procedural dungeon generation for floor 2. -->
