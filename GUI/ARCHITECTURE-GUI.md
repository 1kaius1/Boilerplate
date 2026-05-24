# Architecture

This document describes the technical architecture of this project. It is a stable
reference - update it when structural changes are made, not for every commit. Claude
Code should read this alongside CLAUDE.md at the start of every session.

---

## Overview

<!-- Two to four sentences. What does this application do at a technical level, what
is the UI model (single window, multi-window, MDI, etc.), and what are the hard
constraints it operates under (responsiveness, data size, platform targets, etc.). -->

---

## Application Lifecycle

<!-- Describe the lifecycle from launch to exit. -->

```
Launch
 |
 v
[Entry Point]
 |
 v
[Config Loading]         <-- ~/.app_name/config.yaml
 |
 v
[Toolkit Initialization] <-- GTK/Qt/etc. initialized, CSS loaded
 |
 v
[Main Window Creation]   <-- UI loaded from definition files
 |
 v
[Event Loop]             <-- blocks here; all work is event-driven
 |    |
 |    +-- user events (clicks, keystrokes, menu actions)
 |    +-- background task completion callbacks
 |    +-- timer events
 |
 v
[Shutdown]               <-- save window state, flush config, clean up
 |
 v
exit(0)
```

---

## Component Breakdown

<!-- Describe each major component, what it owns, and what it does not own. -->
<!-- Keep descriptions to 2-3 sentences per component. -->

### Entry Point (`cmd/app_name` or `app_name.py`)

Initializes the toolkit, loads configuration, wires dependencies, creates the main
window, and starts the event loop. Contains no business logic - it is the composition
root.

### Configuration (`internal/config` or `src/config.py`)

Loads and validates `~/.app_name/config.yaml`. Provides typed access to config values
throughout the application. Persists changes (window geometry, user preferences) back
to disk on shutdown or when settings are changed.

### Main Window (`internal/ui/window` or `src/ui/window.py`)

Owns the top-level window and its child widgets. Handles menu/toolbar actions by
delegating to the appropriate controller. Does not contain business logic - it
translates user events into calls on the application layer.

### Application / Controller Layer (`internal/app` or `src/app/`)

Contains business logic decoupled from the UI toolkit. Receives user intent from the
UI layer, performs work, and returns results. Can be tested without a display. Does
not import toolkit packages directly.

### <!-- Additional Component (e.g. Document Model, Data Layer) -->

<!-- Description -->

---

## UI Architecture

### Toolkit

<!-- State the toolkit and version. Explain the key architectural pattern it imposes
(e.g. GTK4 uses a reactive signal/property model; Qt uses signals and slots). -->

### UI Definition Files

- Layout defined in `ui/` as <!-- .ui (GtkBuilder XML) / .qml / .ui (Qt Designer) -->
- UI files are the source of truth for widget structure and layout
- Code wires signals and populates data; it does not construct widget trees manually
- <!-- Any exceptions to the above rule -->

### Signal / Event Flow

```
User Action (click, keystroke, etc.)
 |
 v
Widget signal / event handler (ui layer)
 |
 v
Controller / Application method call
 |
 v
Business logic executes
 |
 v
Result returned to UI layer
 |
 v
Widget state updated
```

### Threading Model

<!-- GUI toolkits are typically single-threaded. Describe how background work is
handled without blocking the event loop. -->

- All UI updates must occur on the main thread / event loop thread
- Background work dispatched via <!-- GLib.idle_add / asyncio / QThreadPool / goroutine -->
- Results marshalled back to the main thread before touching any widget
- <!-- Specific patterns used in this project for async work -->

---

## Data Flow

```
Input sources:
- User interactions (widgets, keyboard, mouse)
- Config file: ~/.app_name/config.yaml
- <!-- files opened by user -->
- <!-- external APIs or databases -->

Processing:
- Application / controller layer handles business logic
- UI layer handles only presentation and event routing

Output destinations:
- Widget state updates (UI redraws)
- Config file: ~/.app_name/config.yaml (preferences, window state)
- <!-- files saved by user -->
- <!-- external APIs or databases -->
```

---

## Configuration and State

### Config File

- Location: `~/.app_name/config.yaml`
- Format: YAML
- Loaded at startup; written on shutdown and on explicit preference changes
- Stores: window geometry, user preferences, <!-- application-specific state -->

### Session State

<!-- What in-memory state does the application maintain during a session?
What happens to it if the application crashes? -->

- <!-- Example: currently open document tracked in memory; not auto-saved -->
- <!-- Example: undo history kept in memory; lost on exit -->

### Persistent User Data

<!-- Any data written to ~/.app_name/ beyond the config file -->

- <!-- Example: ~/.app_name/history.json - recent files list -->
- <!-- Example: no persistent data beyond config -->

---

## Asset and Resource Pipeline

### Assets

```
assets/
- icons/        SVG source icons (and raster fallbacks at 16/32/48/64/128/256px)
- images/       Static images used in the UI
- style.css     Custom CSS/QSS overrides (minimal - prefer system theme)
```

### Resource Bundling

<!-- How are assets embedded in the binary or distributed alongside it? -->

- <!-- Example: GLib gresource - compiled by glib-compile-resources into resources.c -->
- <!-- Example: Go embed directive - assets embedded at compile time via //go:embed -->
- <!-- Example: Qt resources - compiled via pyrcc6 / rcc -->
- <!-- Example: shipped alongside binary in assets/ directory -->

---

## Error Handling Strategy

- Errors in the application layer are returned to the UI layer, never silently swallowed
- UI layer presents errors to the user via dialog or status bar - never crashes silently
- Fatal startup errors (config unreadable, toolkit unavailable) exit with a non-zero code
  and print a plain-text message to stderr before the window is shown
- All errors logged at the appropriate level regardless of whether they are shown in the UI

---

## Dependencies

| Dependency | Purpose | Why This One |
|------------|---------|--------------|
| <!-- toolkit --> | <!-- UI framework --> | <!-- why --> |
| <!-- name --> | <!-- what it does --> | <!-- why not alternatives --> |

### Dependency Philosophy

- Prefer standard library solutions over third-party packages
- New dependencies require discussion and explicit approval (see .clauderules)
- Toolkit version pinned to the version available in the target Linux distribution's
  repos to avoid packaging complexity

---

## Testing Strategy

### Unit Tests

- Application / controller layer tested in isolation without a display
- Config loading and validation tested with fixture files
- Business logic fully unit-testable - no toolkit imports in the application layer

### UI / Integration Tests

<!-- How are UI interactions tested, if at all? -->

- <!-- Example: manual test checklist in docs/manual_test_plan.md -->
- <!-- Example: automated with pytest-gtk / Qt Test Framework -->
- <!-- Example: no automated UI tests yet - see PLANNING.md -->

### Headless Testing

- Unit tests must run without a display (no toolkit initialization in unit test paths)
- CI runs tests headless; use offscreen renderer or Xvfb if toolkit must be initialized

---

## Cross-Platform Considerations

- Path handling: `os.path.join` (Python) / `filepath.Join` (Go) - never string concatenation
- Home directory: `os.path.expanduser("~")` (Python) / `os.UserHomeDir()` (Go)
- Never hardcode font names, sizes, colors, or pixel dimensions
- Keyboard shortcuts: account for Ctrl (Linux/Windows) vs Cmd (macOS) differences
- HiDPI: use scalable assets (SVG); never hardcode pixel sizes in layout
- Window geometry saved and restored from config to respect per-platform conventions
- Test on all three platforms before tagging a release

---

## Known Limitations

<!-- What does this architecture not handle well? What are the known trade-offs? -->

- <!-- Example: undo history is unbounded in memory -->
- <!-- Example: UI blocks during file I/O larger than ~10MB - background loading not yet implemented -->

---

## Future Architectural Considerations

<!-- Changes that are anticipated but not yet implemented. -->

- <!-- Example: document model will need an auto-save mechanism in a future release -->
- <!-- Example: plugin API considered for v2.0 -->
