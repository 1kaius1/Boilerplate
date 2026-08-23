# app_name

<!-- One sentence. What is this game/application and why would someone want it. -->

<!-- Badges - replace URLs with real ones -->
![Version](https://img.shields.io/github/v/release/OWNER/REPO)
![License](https://img.shields.io/badge/license-AGPL--3.0--or--later-blue)
![Build](https://img.shields.io/github/actions/workflow/status/OWNER/REPO/ci.yml)

---

## Overview

<!-- Two to four sentences expanding on the one-liner above. Genre, core loop,
what makes it worth playing/using. -->

---

<!-- Screenshot / gameplay GIF placeholder - replace before first release -->
<!--
![Screenshot](docs/screenshot.png)
-->

## Features

- <!-- feature -->
- <!-- feature -->
- <!-- feature -->

---

## Requirements

- Godot 4.x (4.3 or later recommended) - <!-- .NET / C# build required if using
  C# scripts; the standard build is sufficient for GDScript-only projects -->
- <!-- .NET SDK version, if using C# --> (only if building/exporting C# scripts)
- Linux, macOS, or Windows
- <!-- Minimum GPU/driver requirements, if any -->

---

## Playing a Pre-built Release

```bash
# Linux
chmod +x app_name.x86_64
./app_name.x86_64

# macOS
# Open app_name.app

# Windows
# Run app_name.exe
```

---

## Running From Source

```bash
# Install Godot 4.x (https://godotengine.org/download)
# If using C#, also install the matching .NET SDK

git clone https://github.com/OWNER/REPO.git
cd REPO

# Open in the editor
godot --editor project.godot

# Or run directly without opening the editor
godot --path .
```

### Exporting a Build

```bash
# Requires export templates matching the project's engine version
# (Editor > Manage Export Templates, or downloaded to match CI's engine version)

godot --headless --export-release "Linux/X11" build/app_name.x86_64
godot --headless --export-release "Windows Desktop" build/app_name.exe
godot --headless --export-release "macOS" build/app_name.app
```

---

## Quick Start

<!-- Walk through the first thing a new player/user should do after launching.
Keep it short - 3 to 5 steps. -->

1. Launch `app_name`
2. <!-- step -->
3. <!-- step -->

---

## Controls

| Action                  | Keyboard / Mouse    | Gamepad             |
|-------------------------|----------------------|----------------------|
| <!-- action -->         | `<!-- key -->`        | `<!-- button -->`     |
| <!-- action -->         | `<!-- key -->`        | `<!-- button -->`     |

<!-- All actions should be remappable via the Input Map - link to the in-game
key rebinding screen if one exists. -->

---

## Save Data and Settings

Save data and settings are stored under Godot's `user://` path, which resolves
automatically to:

| Platform | Location |
|----------|----------|
| Linux    | `~/.local/share/godot/app_userdata/<Project Name>/` |
| macOS    | `~/Library/Application Support/<Project Name>/` |
| Windows  | `%APPDATA%\<Project Name>\` |

<!-- Document the actual save file name(s) and format here. -->

---

## License

Copyright (C) <!-- YEAR --> <!-- AUTHOR / ORGANIZATION -->

This program is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.

A commercial license is also available for use cases that are incompatible with the
AGPL-3.0. Contact <!-- email or URL --> for details.

See [LICENSE](LICENSE) for the full license text.
