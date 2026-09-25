# Architecture

This document describes the technical architecture of this project. It is a stable
reference - update it when structural changes are made, not for every commit. Claude
Code should read this alongside CLAUDE.md at the start of every session.

---

## Overview

<!-- Two to four sentences. What does this addon do, what problem does it solve for
players, and what WoW client/build does it target. -->

---

## Addon Lifecycle

```
Game Launch
 |
 v
[TOC Parsed]              <-- WoW reads MyAddon.toc: Interface number checked,
 |                              file load order determined, SavedVariables declared
 v
[Files Loaded in Order]   <-- Lua/XML files executed top-to-bottom per the TOC's
 |                              file list; anything a file depends on is listed
 |                              before it
 v
[ADDON_LOADED fires]      <-- once, for this addon; SavedVariables tables now
 |                              populated from the WTF file (or empty on first run)
 v
[Initialize SavedVariables] <-- create the table if nil, merge in defaults
 |
 v
[Event Frame Registers]   <-- CreateFrame("Frame"):RegisterEvent(...) for
 |                              PLAYER_LOGIN / PLAYER_ENTERING_WORLD
 v
[PLAYER_LOGIN / ENTERING_WORLD fires] <-- world/character state now available;
 |                              register remaining gameplay events; begin normal
 |                              operation
 v
[Runtime Event Loop]      <-- registered events fire as gameplay happens; no
 |    |                        polling - addons are event-driven
 |    +-- OnEvent dispatch table routes each event to its handler
 |    +-- C_Timer.After / C_Timer.NewTicker for deferred/periodic work
 |    +-- avoid OnUpdate - it runs every frame and is budget-sensitive
 |    +-- slash command callbacks
 v
[Logout / Reload UI]      <-- SavedVariables tables serialized to the WTF file by
 |                              the client automatically - no addon code required
 v
exit / reload
```

---

## Component Breakdown

<!-- Describe each major component, what it owns, and what it does not own. Keep
descriptions to 2-3 sentences per component. -->

### Core (`Core.lua`)

Entry point: creates the addon's namespace table, creates the event frame, and
wires `ADDON_LOADED`/`PLAYER_LOGIN` to SavedVariables initialization and startup.
Contains no feature logic of its own.

### <!-- Feature Module (e.g. Core.lua, Tracking.lua, UI.lua) -->

<!-- What it owns, what events it responds to, what it does not handle. Feature
modules are plain Lua files that extend the shared addon table - there is no
formal module-registration system unless one becomes genuinely necessary. -->

### Locales (`Locales/`)

Per-locale `L = {}` tables keyed by `GetLocale()`. Contains only user-facing
strings - no logic.

### Options

<!-- How options are exposed: Blizzard's native Settings API, slash commands only,
or both. Describe what's configurable and where it's surfaced. -->

---

## Data Flow

```
Input sources:
- Player input (slash commands, options UI if any)
- WoW game events (combat log, unit events, zone changes, etc.)
- SavedVariables (loaded once at ADDON_LOADED)

Processing:
- Event frame's OnEvent dispatch table routes events to feature-module handlers
- Feature modules read/write the addon's own SavedVariables table directly

Output destinations:
- UI updates (frames, text, alerts)
- SavedVariables (written by the client automatically at logout - addons only
  ever mutate the in-memory table)
```

---

## Dependencies

| Dependency | Purpose | Why This One |
|------------|---------|--------------|
| <!-- library name, if any --> | <!-- what it provides --> | <!-- why hand-rolling this was unreasonable --> |

### Dependency Philosophy

- Hand-roll first - see `.claude/rules/wow-addon.md` for the exact bar (a
  significant undertaking to implement well locally, not just extra code)
- New dependencies require discussion and explicit approval before adding
- If this table is empty, that's the expected default - not every addon needs one

---

## Testing Strategy

### Static Analysis

- `luacheck` against a WoW API globals whitelist - <!-- name the specific list this
  project uses, if adopted -->

### Manual / In-Game Verification

<!-- What "verified working" means for this addon - a specific in-game scenario,
a manual test checklist, etc. Genuinely automating in-game behavior isn't
practical without the client running, so this is the primary verification method
for anything beyond static analysis. -->

---

## Client Parity

- Windows and macOS run identical addon code - the client abstracts OS
  differences, and addon Lua has no filesystem/OS access to diverge on in the
  first place
- The Interface number this project targets is beta-current (see
  `.claude/rules/wow-addon.md`) - it will need updating as WoW Forever progresses
  through its beta and into release

---

## Known Limitations

<!-- What does this architecture not handle well? What are the known trade-offs? -->

- <!-- Example: no automated in-game testing - regressions are only caught by
  manual play-testing or static analysis -->

---

## Future Architectural Considerations

<!-- Changes that are anticipated but not yet implemented. -->

- <!-- Example: revisit the no-framework decision if a specific feature turns out
  to be a significant undertaking to implement well locally -->
