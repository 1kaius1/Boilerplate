# CLAUDE.md - GUI Application (C# / .NET)

This file provides project context and conventions for AI-assisted development sessions.
Read this file and ARCHITECTURE.md before making any changes. See .clauderules for
behavioral rules that govern this session.

---

## Project Overview

<!-- One paragraph. What does this application do, what problem does it solve, who uses it. -->
<!-- Example: -->
<!-- my_app is a desktop GUI application that does X for Y users. It solves Z by doing W. -->

---

## Tech Stack

| Component       | Choice                        | Reason                              |
|-----------------|-------------------------------|-------------------------------------|
| Language        | C# / .NET                     | <!-- Why this language -->          |
| GUI toolkit     | <!-- Avalonia/MAUI/WPF (Windows-only) --> | <!-- Why this toolkit -->  |
| Config format   | <!-- YAML/JSON/TOML -->       | <!-- Why -->                        |
| Key dependency  | <!-- name -->                 | <!-- What it provides -->           |
| Key dependency  | <!-- name -->                 | <!-- What it provides -->           |

Note: WPF and WinForms are Windows-only. For a cross-platform GUI targeting
Linux, macOS, and Windows, use Avalonia or .NET MAUI.

---

## Repository Layout

```
project_name/
- src/
  - AppName/             # Main project (Program.cs, App.axaml, AppName.csproj)
- tests/
  - AppName.Tests/        # Test project
- assets/               # Icons, images, and static resources
- scripts/              # Build helpers and packaging scripts
- docs/                 # Additional documentation
- AppName.sln           # Solution file
- .clauderules          # AI session behavioral rules
- ARCHITECTURE.md       # Component and data flow reference
- CHANGELOG.md          # Version history (Keep a Changelog format)
- CLAUDE.md             # This file
- CONTRIBUTING.md       # Contribution guidelines
- PLANNING.md           # Goals, milestones, open questions
- README.md             # Public-facing documentation
- LICENSE               # Project license
```

<!-- Annotate any non-obvious directories or files specific to this project. -->

---

## Build and Install

### Prerequisites

```bash
# .NET 8 SDK or later
```

### Build

```bash
dotnet build

# Release build
dotnet build -c Release
```

### Run in Development

```bash
dotnet run --project src/AppName

# With verbose logging
dotnet run --project src/AppName -- --verbose
```

### Package for Distribution

```bash
# Document the release packaging process here
# Examples:
# Self-contained publish: dotnet publish src/AppName -c Release -r <RID> --self-contained -p:PublishSingleFile=true
# Linux AppImage / Flatpak: scripts/build_linux.sh
# Windows installer (MSIX or Wix): scripts/build_installer.ps1
# macOS .app bundle: scripts/build_macos.sh
```

---

## Running Tests

```bash
dotnet test

# With coverage
dotnet test --collect:"XPlat Code Coverage"

# UI/integration tests (if applicable)
# Document the test runner for UI automation here
```

All tests must pass before committing or opening a pull request. Never suggest a PR
with failing tests. If tests cannot be run, say so explicitly.

Note: UI rendering tests may require a display. On headless systems use Xvfb or the
toolkit's headless/offscreen rendering mode where available.

---

## Configuration and Data Storage

- Persistent config stored at: `~/.app_name/config.yaml`
- User data and application state stored under: `~/.app_name/`
- Never hardcode paths - resolve the home directory at runtime (`Environment.GetFolderPath`)
- Config format preference order: YAML > JSON > TOML
- Do not use platform config APIs (XDG, NSUserDefaults, Registry, `Environment.SpecialFolder.ApplicationData`) - always `~/.app_name/`

### Config File Structure

```yaml
# ~/.app_name/config.yaml
# Document expected keys and their defaults here
# Example:
# log_level: info
# window_width: 1024
# window_height: 768
# theme: system
```

---

## UI Architecture

<!-- Describe the high-level UI structure so Claude understands the layout -->
<!-- before touching any UI code. Example: -->

<!--
The application uses a single main window with:
- A headerbar/menubar at the top
- A sidebar for navigation (left)
- A main content area (center/right)
- A statusbar at the bottom

UI definitions live in src/AppName/Views/ as .axaml (Avalonia) / .xaml (MAUI/WPF).
The main window class is in src/AppName/Views/MainWindow.axaml.cs.
-->

### Toolkit-Specific Notes

```
<!-- Document any toolkit-specific conventions enforced in this project -->
<!-- Example (Avalonia): -->
<!-- - MVVM pattern: Views bind to ViewModels via {Binding}; no code-behind business logic -->
<!-- - CommunityToolkit.Mvvm for ObservableObject / RelayCommand -->
<!-- - Styles/themes in Styles/ only -->

<!-- Example (MAUI): -->
<!-- - MVVM pattern with CommunityToolkit.Mvvm -->
<!-- - Platform-specific code isolated to Platforms/ folders -->
```

### Cross-Platform UI Notes

- Test layout on Linux, macOS, and Windows before marking a UI task complete
- Never hardcode font names, sizes, or colors in code - use theme/system defaults
- Keyboard shortcuts must work on all three platforms (account for Ctrl vs Cmd)
- HiDPI / scaling must be handled correctly - never hardcode pixel sizes
- Window geometry saved and restored from `~/.app_name/config.yaml`

---

## Assets and Resources

```
assets/
- icons/                # Application and toolbar icons (SVG preferred)
- images/               # Static images used in UI
- styles/                # Custom style/theme overrides (minimal - prefer system theme)
```

- Icons must be provided in SVG format where the toolkit supports it
- Raster fallbacks at 16, 32, 48, 64, 128, 256px where needed
- Assets embedded via `<AvaloniaResource>` / `<MauiAsset>` items in the .csproj, not loaded from disk at runtime

---

## Code Style and Conventions

Behavioral rules are in `.clauderules`. Key reminders for this project:

- ASCII only in code and comments - no emoji, no em-dashes
- File names are PascalCase and match the class they contain (standard .NET convention)
- Explain WHY in comments, not WHAT
- Errors must be handled explicitly - no silent failures, no swallowed exceptions
- Conventional commits: `type(scope): description`

### Language-Specific Notes

```
<!-- Add any project-specific style deviations or enforced patterns here -->
<!-- Example: -->
<!-- Nullable reference types enabled project-wide -->
<!-- All business logic behind an interface for testability -->
```

---

## Changelog and Versioning

- Format: Keep a Changelog (https://keepachangelog.com)
- Versioning: Semantic Versioning (https://semver.org)
- CHANGELOG.md must be updated in the same commit as the change
- Unreleased changes go under `## [Unreleased]`
- Do not create a new version entry - that is the maintainer's decision

---

## Current Focus

See PLANNING.md for active goals, open questions, and pending decisions.

<!-- Optionally note the current sprint or immediate next task here so Claude -->
<!-- picks up context quickly at the start of a session. -->
<!-- Example: -->
<!-- Currently working on: implementing the preferences dialog. -->
