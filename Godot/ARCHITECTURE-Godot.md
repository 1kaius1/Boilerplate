# Architecture

This document describes the technical architecture of this project. It is a stable
reference - update it when structural changes are made, not for every commit. Claude
Code should read this alongside CLAUDE.md at the start of every session.

---

## Overview

<!-- Two to four sentences. What kind of game/application is this, what is the core
gameplay/interaction loop, and what are the hard constraints it operates under
(target platforms, performance budget, multiplayer or single-player, etc.). -->

---

## Engine Lifecycle

```
Launch
 |
 v
[Engine Boot]            <-- project.godot read: engine version, autoloads,
 |                             input map, rendering settings
 v
[Autoload Instantiation]  <-- singletons created in the order configured in
 |                             Project Settings > Autoload
 v
[Main Scene Load]         <-- the scene configured as "Main Scene" is instanced
 |
 v
[_Ready() Propagation]    <-- called bottom-up through the newly-entered
 |                             scene tree (children before parents)
 v
[Main Loop]               <-- runs every frame until quit
 |    |
 |    +-- _Process(delta) / _process(delta) - variable-rate, once per frame
 |    +-- _PhysicsProcess(delta) / _physics_process(delta) - fixed-rate
 |    +-- input events dispatched to focused/relevant nodes
 |    +-- signals fired and handled synchronously within the frame
 |
 v
[Shutdown]                <-- NOTIFICATION_WM_CLOSE_REQUEST or SceneTree.quit();
 |                             save state, clean up autoloads
 v
exit(0)
```

---

## Component Breakdown

<!-- Describe each major scene/system, what it owns, and what it does not own.
Keep descriptions to 2-3 sentences per component. -->

### Main Scene (`<!-- scenes/main.tscn -->`)

Root of the active scene tree once gameplay starts. Owns top-level composition of
its child scenes; contains no gameplay logic of its own beyond wiring children
together.

### Autoloads / Singletons (`<!-- autoload/ or scripts/autoload/ -->`)

<!-- List each autoload and its one-sentence responsibility. Example: -->
<!-- - GameState - current run/session state, save/load orchestration -->
<!-- - AudioManager - bus control and one-shot SFX playback -->
<!-- - SceneManager - scene transitions and loading screens -->

### <!-- Feature Scene (e.g. Player, Level, UI/HUD) -->

<!-- Description: what it owns, what signals it exposes, what it depends on -->

### <!-- Additional Component -->

<!-- Description -->

---

## Scene and Node Architecture

### Composition Strategy

- Prefer instancing reusable scenes over deep node-inheritance chains
- <!-- Describe this project's convention for splitting logic vs. presentation
  scenes, if one exists -->

### Signal Flow

```
Input / event source (player input, timer, area/body entering, etc.)
 |
 v
Node's own script handles it, or emits a signal
 |
 v
Connected listener(s) react (may be a parent, an autoload, or a sibling
via a signal bus pattern)
 |
 v
State updated / new signal emitted downstream
```

### Autoload Usage Policy

- Autoloads hold genuinely global state or services only - not a shortcut
  around signals for ordinary parent/child communication
- <!-- List anything this project explicitly forbids or requires of autoloads -->

---

## Data Flow

```
Input sources:
- Player input (mapped through the Input Map, not raw key/button codes)
- Config/save data: user://<!-- save file name -->
- <!-- network messages, if multiplayer -->

Processing:
- Gameplay logic lives in node scripts and/or a dedicated logic layer
- UI/presentation nodes handle only display and input forwarding

Output destinations:
- Scene tree / node state (what gets rendered)
- Save data: user://<!-- save file name -->
- <!-- network messages sent, if multiplayer -->
```

---

## Configuration and State

### Save Data

- Location: `user://<!-- save file name, e.g. save_slot_1.tres -->`
- Format: <!-- ConfigFile / Resource (.tres) / custom binary / JSON -->
- <!-- Versioning strategy: how are older save files migrated forward? -->

### Session State

<!-- What in-memory state exists only for the current session and is lost on
exit/crash? -->

- <!-- Example: current level's destructible-object state is not persisted -->

### Persistent Settings

- Location: `user://<!-- settings file, e.g. settings.cfg -->`
- <!-- What does it store: video/audio settings, key bindings, etc. -->

---

## Asset and Resource Pipeline

### Assets

```
<!-- assets/ or art/, audio/, etc. - adjust to this project's layout -->
assets/
- sprites/          Source art (import settings tracked in .godot/, not committed)
- audio/             SFX and music source files
- fonts/             Font resources
```

### Resource Bundling

- `res://` resources are bundled into the export automatically based on what
  is referenced by scenes/scripts, or explicitly included/excluded via export
  presets (see `export_presets.cfg`)
- <!-- Note any resources loaded dynamically at runtime (ResourceLoader.load)
  vs. preloaded, and why -->

---

## Error Handling Strategy

- Recoverable gameplay errors are logged and degrade gracefully (skip the
  broken content, do not crash the session)
- Fatal startup errors (corrupt save data, missing required resources) exit
  with a clear message rather than a silent crash or an unhandled exception
  dialog reaching a player
- <!-- This project's specific error/crash reporting mechanism, if any -->

---

## Dependencies

| Dependency | Purpose | Why This One |
|------------|---------|--------------|
| <!-- addon/plugin name --> | <!-- what it does --> | <!-- why not alternatives --> |

### Dependency Philosophy

- Prefer the engine's built-in nodes/systems over an addon where feasible
- New addons/plugins require discussion and explicit approval (see
  `.claude/rules/`)
- Engine version is pinned (see `project.godot`'s `config/features`) - do not
  upgrade the engine version as a side effect of an unrelated change

---

## Testing Strategy

### Unit Tests

- <!-- Test framework in use: GUT, GdUnit4, or a plain runner for
  node-independent logic classes -->
- Logic that does not depend on the scene tree is tested without
  instantiating any nodes

### Scene / Integration Tests

- <!-- How are node/scene interactions tested, if at all -->
- <!-- Example: GdUnit4 scene runner instantiates a test scene and asserts on
  node state after simulated frames -->

### Headless Testing

- `godot --headless` runs the engine without a display - this is what CI uses
  for both automated tests and export
- <!-- Any test that genuinely requires a display/GPU and how it is handled -->

---

## Cross-Platform / Export Considerations

- Path handling: `res://` and `user://` virtual paths, not raw OS paths;
  `ProjectSettings.GlobalizePath()` / `OS.GetUserDataDir()` when a real OS
  path is genuinely required (C#) - GDScript's equivalents are
  `ProjectSettings.globalize_path()` / `OS.get_user_data_dir()`
- Input: define actions in the Input Map so remapping and multiple input
  devices (keyboard/mouse, gamepad, touch) do not require per-script changes
- Resolution/aspect ratio: anchors, containers, and the stretch/scale project
  settings - never a hardcoded resolution assumption
- Export templates matching the engine version must be installed wherever
  the project is built (locally and in CI) - a version mismatch is a common
  source of export failures
- <!-- Target platforms and any platform-specific export notes (e.g. mobile
  touch controls, web export limitations, console certification requirements) -->

---

## File-Based Data Formats

<!-- Save file format, if custom. Document schema, version field, example, and
migration strategy for format changes. Remove if using a simple ConfigFile
with no versioning concerns. -->

<!-- Example: -->
<!-- ### Save File (user://save_slot_N.tres) -->
<!-- A Godot Resource (.tres) with a version field: -->
<!-- ```gdscript -->
<!-- class_name SaveData -->
<!-- extends Resource -->
<!-- @export var version: int = 1 -->
<!-- @export var player_data: Dictionary -->
<!-- ``` -->
<!-- - `version` is required - bump on breaking schema changes -->
<!-- - Older save versions are migrated forward at load time -->

---

## Extension and Integration Points

<!-- What does this project expose beyond normal gameplay? -->

- Modding / plugin support: <!-- addon-based, or "none - not extensible by design" -->
- Automation / scripting for CI: <!-- e.g. --headless export, automated
  playtesting hooks, or "none beyond export" -->
- Multiplayer / networking: <!-- protocol, authority model, or "none - single-player" -->

---

## Known Limitations

<!-- What does this architecture not handle well? What are the known trade-offs? -->

- <!-- Example: no object pooling yet - projectile-heavy scenes may stutter
  at high enemy counts -->

---

## Future Architectural Considerations

<!-- Changes that are anticipated but not yet implemented. -->

- <!-- Example: save file versioning/migration not yet needed pre-1.0, will be
  required before the first schema-breaking update -->
