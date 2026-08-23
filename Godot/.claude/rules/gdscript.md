---
paths:
  - "**/*.gd"
---

# GDScript-Specific Rules

- Use static typing (`var health: int = 100`, typed function signatures and
  return types) rather than leaving variables untyped - it improves editor
  autocompletion, catches type errors before runtime, and is the modern
  GDScript style
- Filenames are snake_case (`player_controller.gd`), matching Godot's own
  style guide; if the script needs to be usable as a type name elsewhere
  (e.g. as an exported field's type), give it a `class_name` in PascalCase -
  the file/class-name case mismatch is expected and correct, not an error
- Godot 4 signal syntax: `signal health_changed(new_value)` to declare,
  `health_changed.emit(new_value)` to fire, `target.health_changed.connect(callable)`
  to connect - this replaced Godot 3's string-based `emit_signal("name", ...)` /
  `connect("name", target, "method")` API
- License header: `# SPDX-License-Identifier: AGPL-3.0-or-later`
- There is no external package manager for GDScript itself - addons are
  either installed from the AssetLib or placed manually under `addons/`;
  document new addons in ARCHITECTURE.md rather than a dependency manifest
  file, since none exists
- Avoid `get_node("../../SomeNode")`-style deep relative paths - use
  `%UniqueName` or an exported `NodePath`/node reference set once in the
  editor or in `_ready()`
