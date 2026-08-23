# Godot Project Rules

Applies regardless of scripting language (GDScript, C#, or a mix of both in the
same project). See `gdscript.md` and/or `godot_csharp.md` for language-specific
rules, which are auto-scoped by file extension and both stay loaded if the
project mixes languages.

## Project Structure

- `project.godot` is the project's manifest (engine version, autoloads, input
  map, rendering settings) - review it before assuming any project setting
- Scenes (`.tscn`) are the unit of composition - prefer instancing a scene
  inside another scene over deep node inheritance chains
- Scripts attach behavior to a node; they are not a substitute for scene
  composition - if a node tree structure is reusable, make it a scene, not a
  script that builds the tree in code
- `.tres` (text resource) is preferred over `.res` (binary resource) for any
  resource that benefits from being diffable in version control
- `addons/` holds third-party or in-house plugins - each addon's own
  `plugin.cfg` documents what it provides; do not edit inside a third-party
  addon's folder, submit changes upstream instead

## Version Control

- `.godot/` is the engine's generated cache (imported assets, editor state) -
  always gitignored, never committed
- `export_presets.cfg` frequently contains machine-specific paths and signing
  credentials (e.g. an Android keystore path and password) - review its
  contents before committing; keep secrets out of it and gitignore it if it
  cannot be kept secret-free
- `.tscn` files are text and diffable, but multiple people editing the same
  scene concurrently produces painful merge conflicts - avoid it where
  feasible, same as you would for generated code

## Scene and Node Architecture

- Prefer signals for communication between unrelated or loosely-related
  nodes; reserve direct node references (`GetNode` / `get_node` /
  `%UniqueName`) for tightly-coupled parent/child relationships
- Use unique names (`%NodeName` in the editor) or exported node path fields
  for node lookups that must survive scene restructuring - avoid long
  relative paths like `../../SomeNode` that break silently when the tree
  changes
- One clear responsibility per scene; a scene that both defines UI layout and
  contains unrelated gameplay logic is a sign it should be split
- Autoloads (singletons registered in Project Settings) are for state or
  services that are genuinely global (scene management, audio bus control,
  save system) - do not use them as a shortcut around signals for ordinary
  parent/child communication, and document what each autoload owns

## Storage and Configuration

- `user://` is the only place for save data, settings, and anything else
  written at runtime - it resolves automatically to the correct per-OS
  location (do not hardcode `~/.app_name/` or any other literal path; that is
  the CLI/GUI/Service convention, not Godot's)
- `res://` is for bundled project resources - treat it as read-only at
  runtime in an exported build; it is not writable on most export targets
  (web, consoles, and some app-store-distributed builds in particular)
- Prefer Godot's `ConfigFile` class or a `.tres` Resource for structured save
  data over hand-rolled JSON/YAML parsing, unless the save format needs to be
  read by tooling outside Godot

## Input and Rendering

- Define actions in the Input Map (`project.godot`) rather than hardcoding
  raw key/button codes in scripts - this is what makes remapping and
  multiple-device support possible without touching every script
- Use anchors, containers, and the stretch/scale project settings for UI
  layout - never assume a fixed resolution or hardcode pixel positions for
  anything that must adapt across aspect ratios or window sizes
- Profile before optimizing `_process`/`_physics_process` - object pooling for
  frequently spawned/destroyed nodes (projectiles, particles) is a real
  concern at scale, but do not pre-optimize before a profiler says so

## Testing

- There is no engine-bundled unit test framework; pick one community
  framework (commonly GUT for GDScript-only projects, or GdUnit4 for
  projects that need both GDScript and C# test support) and document the
  choice and how to run tests in this project's README.md
- Tests that need the scene tree or node lifecycle require a Godot-aware
  test runner (plain xUnit/NUnit/pytest cannot instantiate nodes); tests that
  only exercise plain data/logic classes with no node dependencies can often
  run under a language's normal test runner instead

## Export and CI

- `godot --headless --export-release "<preset>" <output>` runs an export
  from the command line without opening the editor - this is what CI uses
- Export templates matching the project's engine version must be installed
  in the CI environment; a version mismatch between the editor used to
  author the project and the export templates available in CI is a common
  and confusing failure mode - pin and document the exact engine version
