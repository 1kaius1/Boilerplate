---
paths:
  - "**/*.lua"
---

# Lua-Specific Rules (WoW Addon)

- `local` by default for everything not intentionally shared - addons run in one
  shared global environment with every other installed addon; global pollution
  causes real cross-addon conflicts, not just style nitpicks
- Upvalue-cache frequently-called API functions at file scope (e.g.
  `local GetTime = GetTime`) - a standard WoW addon performance idiom given Lua
  5.1's global-lookup cost
- No `os`/`io` library access - WoW's embedded Lua sandbox strips filesystem access
  entirely; all persistence goes through SavedVariables, never direct file I/O
- Prefer `C_Timer.After`/`C_Timer.NewTicker` over `OnUpdate` polling for
  deferred/periodic work - `OnUpdate` runs every frame and is budget-sensitive
- File naming: PascalCase per file (`Core.lua`, `Config.lua`), matching common
  addon-community convention
- License header: none by default - no license has been chosen for this project
  yet (see `wow-addon.md`). Once one is chosen, add
  `-- SPDX-License-Identifier: <chosen>` (Lua's comment syntax) to every file,
  including retroactively to files that predate the choice
