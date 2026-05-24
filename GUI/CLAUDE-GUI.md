# CLAUDE.md - GUI Application

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
| Language        | <!-- Go/Python -->            | <!-- Why this language -->          |
| GUI toolkit     | <!-- GTK4/Qt6/webview/etc. --> | <!-- Why this toolkit -->          |
| Bindings        | <!-- gotk4, PyGObject, etc. --> | <!-- Why -->                       |
| Config format   | <!-- YAML/JSON/TOML -->       | <!-- Why -->                        |
| Key dependency  | <!-- name -->                 | <!-- What it provides -->           |
| Key dependency  | <!-- name -->                 | <!-- What it provides -->           |

---

## Repository Layout

```
project_name/
- cmd/                  # Entry point (Go) or main script (Python)
- internal/             # Private packages (Go)
- pkg/                  # Exported packages (Go)
- src/                  # Source modules (Python)
- ui/                   # UI definition files (.ui, .glade, .qml, etc.)
- assets/               # Icons, images, and static resources
- resources/            # Compiled/embedded resource bundles
- scripts/              # Build helpers and packaging scripts
- tests/                # Test suite
- docs/                 # Additional documentation
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
# List runtime, build, and toolkit-specific dependencies
# Example (GTK4 on Linux):
# Go 1.22+ or Python 3.11+
# GTK4 development libraries: sudo apt install libgtk-4-dev
# gobject-introspection: sudo apt install libgirepository1.0-dev

# Example (Qt6 on Linux):
# Qt6 development libraries: sudo apt install qt6-base-dev
```

### Build

```bash
# Go + GTK4
go build -o bin/app_name ./cmd/app_name

# Python - install dependencies
pip install -r requirements.txt

# If using a resource compiler (e.g. glib-compile-resources):
glib-compile-resources --target=resources/resources.c \
    --generate-source resources/app_name.gresource.xml
```

### Run in Development

```bash
# Go
go run ./cmd/app_name

# Python
python -m app_name
# or
python src/app_name/main.py

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
# Go
go test ./...

# Go - with race detector
go test -race ./...

# Python
pytest

# Python - with coverage
pytest --cov=src tests/

# UI/integration tests (if applicable)
# Document the test runner for UI automation here
```

All tests must pass before committing or opening a pull request. Never suggest a PR
with failing tests. If tests cannot be run, say so explicitly.

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
The main window class is in src/window.py or internal/ui/window.go.
-->

### Toolkit-Specific Notes

```
<!-- Document any toolkit-specific conventions enforced in this project -->
<!-- Example (GTK4): -->
<!-- - Use GtkBuilder XML for all layout; no programmatic widget construction -->
<!-- - Signals connected in code, not in .ui files -->
<!-- - CSS overrides in assets/style.css only -->
<!-- - Never use deprecated GTK3 widgets -->

<!-- Example (Qt6): -->
<!-- - .ui files edited in Qt Designer only, not by hand -->
<!-- - Signals/slots in code using connect() -->
<!-- - QSS overrides in assets/style.qss only -->
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

Behavioral rules are in `.clauderules`. Key reminders for this project:

- ASCII only in code and comments - no emoji, no em-dashes
- Underscores in all filenames
- Explain WHY in comments, not WHAT
- Errors must be handled explicitly - no silent failures
- Conventional commits: `type(scope): description`

### Language-Specific Notes

```
<!-- Add any project-specific style deviations or enforced patterns here -->
<!-- Example: -->
<!-- Go: all errors wrapped with fmt.Errorf("context: %w", err) -->
<!-- Python: type hints required on all public functions -->
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
