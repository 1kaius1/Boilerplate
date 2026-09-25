# CLAUDE.md - WoW Addon (Lua)

This file provides project context and conventions for AI-assisted development sessions.
Read this file and ARCHITECTURE.md before making any changes. Behavioral rules and
guardrails are auto-loaded from `.claude/rules/` - there is nothing else to open.

---

## Project Overview

<!-- One paragraph. What does this addon do, what problem does it solve for
players, who is it for. -->
<!-- Example: -->
<!-- my_addon tracks X and alerts the player when Y happens, so they don't have -->
<!-- to watch for it manually. -->

---

## Tech Stack

| Component       | Choice                        | Reason                              |
|-----------------|--------------------------------|--------------------------------------|
| Client          | World of Warcraft: Forever (beta) | <!-- Why this branch -->         |
| Interface       | 16001 (beta-current - confirm before relying on it) | - |
| Scripting       | Lua 5.1                       | Fixed by the WoW client              |
| Framework       | None by default (vanilla + WoW API) | See `.claude/rules/wow-addon.md` for when a dependency is justified |
| Test tooling    | <!-- luacheck / none yet -->  | <!-- Why -->                         |

---

## Repository Layout

```
project_name/
- app_name.toc          # Table of Contents: Interface, metadata, load order, SavedVariables
- Core.lua               # Entry point: namespace, event frame, startup wiring
- Locales/               # Per-locale L = {} tables
- Media/                 # Textures, sounds
- Libs/                  # Embedded external libraries (only if one is justified -
                         # see .claude/rules/wow-addon.md - not present by default)
- docs/                  # Additional documentation
- .claude/               # Auto-loaded rules (.claude/rules/) and settings.json
- ARCHITECTURE.md        # Component and data flow reference
- CHANGELOG.md           # Version history (Keep a Changelog format)
- CLAUDE.md              # This file
- CONTRIBUTING.md        # Contribution guidelines
- PLANNING.md            # Goals, milestones, open questions
- README.md              # Public-facing documentation
```

<!-- Annotate any non-obvious directories or files specific to this project. -->

Note: this project defaults to no license / all rights reserved (see
`.claude/rules/wow-addon.md`) - `CONTRIBUTING.md`'s and `CLA.md`'s AGPLv3/Commercial
license sections do not apply as-is and need reconciling with whatever license is
eventually chosen, or removing if this project isn't accepting outside
contributions.

---

## Loading and Testing In-Game

```bash
# There is no build step - Lua is interpreted directly by the client.
# After editing, in-game:
/reload
```

### Static Analysis

```bash
luacheck .
```

All static checks must pass before committing or opening a pull request. Never
suggest a PR with failing checks. If checks cannot be run, say so explicitly.

---

## SavedVariables

- Declared in `app_name.toc` via `## SavedVariables: AppNameDB`
- Initialized on this addon's `ADDON_LOADED`: `AppNameDB = AppNameDB or {}`, then
  defaults merged in - see `.claude/rules/wow-addon.md` for the pattern
- Never accessed before `ADDON_LOADED` has fired for this addon

### SavedVariables Structure

```lua
-- AppNameDB (declared in app_name.toc)
-- Document expected keys and their defaults here
-- Example:
-- AppNameDB = {
--   enabled = true,
--   threshold = 50,
-- }
```

---

## Code Style and Conventions

Behavioral rules and guardrails are auto-loaded from `.claude/rules/` - see
`universal.md`, `wow-addon.md`, and `lua.md`.

### Project-Specific Notes

```
<!-- Add any project-specific style deviations or enforced patterns here -->
<!-- Example: -->
<!-- All combat-log parsing goes through a single CLEU dispatcher in Core.lua -->
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
<!-- Currently working on: the initial event-tracking core loop. -->
