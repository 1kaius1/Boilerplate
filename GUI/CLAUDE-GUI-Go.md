# CLAUDE.md - GUI Application (Go)

This file provides project context and conventions for AI-assisted development sessions.
Read this file and ARCHITECTURE.md before making any changes. Behavioral rules and
guardrails are auto-loaded from `.claude/rules/` - there is nothing else to open.

---

## Project Overview

<!-- One paragraph. What does this application do, what problem does it solve, who uses it. -->
<!-- Example: -->
<!-- my_app is a desktop GUI application that does X for Y users. It solves Z by doing W. -->

---

## Tech Stack

| Component       | Choice                        | Reason                              |
|-----------------|-------------------------------|-------------------------------------|
| Language        | Go                            | <!-- Why this language -->          |
| GUI toolkit     | <!-- GTK4/Qt6/webview/etc. --> | <!-- Why this toolkit -->          |
| Bindings        | <!-- gotk4, etc. -->          | <!-- Why -->                        |
| Config format   | <!-- YAML/JSON/TOML -->       | <!-- Why -->                        |
| Key dependency  | <!-- name -->                 | <!-- What it provides -->           |
| Key dependency  | <!-- name -->                 | <!-- What it provides -->           |

---

## Repository Layout

```
project_name/
- cmd/                  # Entry point
- internal/             # Private packages
- pkg/                  # Exported packages
- ui/                   # UI definition files (.ui, .qml, etc.)
- assets/               # Icons, images, and static resources
- resources/            # Compiled/embedded resource bundles
- scripts/              # Build helpers and packaging scripts
- tests/                # Test suite
- docs/                 # Additional documentation
- .claude/              # Auto-loaded rules (.claude/rules/) and settings.json
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
# Go 1.22+
# Plus whatever system dev libraries the chosen toolkit needs (e.g. GTK4:
# libgtk-4-dev + libgirepository1.0-dev; Qt6: qt6-base-dev)
```

### Build

```bash
go build -o bin/app_name ./cmd/app_name

# If using a resource compiler (e.g. glib-compile-resources):
glib-compile-resources --target=resources/resources.c \
    --generate-source resources/app_name.gresource.xml
```

### Run in Development

```bash
go run ./cmd/app_name

# With verbose logging
app_name --verbose
```

### Package for Distribution

```bash
# Document the release packaging process here
# Examples:
# Linux AppImage: scripts/build_appimage.sh
# Flatpak: flatpak-builder build-dir com.example.AppName.yaml
# Windows installer: scripts/build_installer.ps1
# macOS .app bundle: scripts/build_macos.sh
```

---

## Running Tests

```bash
go test ./...

# With race detector
go test -race ./...

# UI/integration tests (if applicable)
# Document the test runner for UI automation here
```

Note: UI rendering tests may require a display. On headless systems use Xvfb or the
toolkit's offscreen renderer where available.

---

## Configuration and Data Storage

- Persistent config stored at: `~/.app_name/config.yaml`
- User data and application state stored under: `~/.app_name/`
- Never hardcode paths - resolve the home directory at runtime
- Config format preference order: YAML > JSON > TOML
- Do not use platform config APIs (XDG, NSUserDefaults, Registry) - always `~/.app_name/`

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

UI definitions live in ui/ as .ui (GtkBuilder XML) / .qml / etc.
The main window struct is in internal/ui/window.go.
-->

### Toolkit-Specific Notes

```
<!-- Document the conventions enforced for the toolkit actually chosen above -->
<!-- (GtkBuilder/QML layout rules, signal wiring, stylesheet location, etc.) -->
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
- style.css             # Custom CSS/QSS overrides (minimal - prefer system theme)

resources/              # Compiled resource bundle (do not edit directly)
```

- Icons must be provided in SVG format where the toolkit supports it
- Raster fallbacks at 16, 32, 48, 64, 128, 256px where needed
- Do not embed binary assets in source files

---

## Code Style and Conventions

Behavioral rules and guardrails are auto-loaded from `.claude/rules/` - see
`universal.md` plus the language and type rule files that apply to this project.

### Language-Specific Notes

```
<!-- Add any project-specific style deviations or enforced patterns here -->
<!-- Example: -->
<!-- All errors wrapped with fmt.Errorf("context: %w", err) -->
```

---

## Current Focus

See PLANNING.md for active goals, open questions, and pending decisions.

<!-- Optionally note the current sprint or immediate next task here so Claude -->
<!-- picks up context quickly at the start of a session. -->
<!-- Example: -->
<!-- Currently working on: implementing the preferences dialog. -->
