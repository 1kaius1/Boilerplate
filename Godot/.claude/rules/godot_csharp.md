---
paths:
  - "**/*.cs"
---

# Godot C# ("Mono"/.NET Build) Rules

Godot's C# support was called "Mono" in Godot 3.x; Godot 4.x calls the same
thing the ".NET" build - the download, the API, and the underlying idea
(a separate engine build with a Mono/.NET runtime for C# scripting) are the
same concept under a renamed label. This project targets the Godot 4.x .NET
build (4.3 or later recommended - earlier 4.x releases had rougher edges in
C# support).

## What Still Applies From the Generic C# Rules

`universal.md`'s language file for C# (naming conventions, `.csproj`
dependency tracking, the `// SPDX-License-Identifier` header syntax) is not
duplicated here and still applies unmodified - a Godot script is still an
ordinary C# class as far as those conventions are concerned. This file only
covers what is specific to writing C# inside Godot.

## What Godot C# Does Differently

- Every script attached to a node must be declared `partial class` - Godot's
  source generators add signal/property registration code to the class, and
  the build fails without `partial` once any Godot attribute is in use
- Override node lifecycle methods with their Godot 4 signatures:
  `_Ready()`, `_Process(double delta)`, `_PhysicsProcess(double delta)` - the
  delta parameter is `double`, not `float`; this is the single most common
  porting mistake from Godot 3 or from general C# game-dev habits elsewhere
- `[Export]` exposes a field or property to the editor Inspector (the C#
  equivalent of GDScript's `@export`)
- `[Signal]` on a delegate declares a custom signal; Godot 4 exposes signals
  as ordinary C# events - connect with `node.MySignal += OnMySignal;`, not a
  GDScript-style `.connect()` call
- `[GlobalClass]` registers a C# class project-wide (selectable in the
  "Attach Script" dialog, usable as a custom Resource type) - the C#
  equivalent of GDScript's `class_name`
- `GetNode<T>("path")` is generic - always specify the expected type; cache
  the result in a field set during `_Ready()` rather than calling `GetNode`
  repeatedly inside `_Process()`

## Path Handling Override

The generic C# rule to use `Path.Combine` for path handling still applies
once you have a real OS path to work with, but it is not how most Godot code
should touch the filesystem in the first place. Prefer:

- `res://` and `user://` virtual paths for anything resource- or
  save-data-related, not raw filesystem paths
- `ProjectSettings.GlobalizePath()` to convert a `res://`/`user://` path to a
  real OS path only when an API genuinely requires one
- `OS.GetUserDataDir()` if you need the real OS path behind `user://`
  directly, instead of hardcoding a platform-specific location

## Testing

Standard NUnit/xUnit runners cannot instantiate nodes or run inside the
scene tree - a Godot-aware test runner (GdUnit4 supports C#) is required for
any test that touches node lifecycle, signals, or the tree. Plain C# classes
with no Godot dependencies can still be tested with a normal .NET test
runner.
