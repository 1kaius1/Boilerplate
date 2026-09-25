# WoW Addon Rules

Applies regardless of which specific WoW client build this project targets. See
`lua.md` for language-level rules, which are auto-scoped to `.lua` files and stay
loaded alongside this file.

## TOC Conventions

- `## Interface:` - currently `16001` for WoW Forever (beta) - **this is
  beta-current, not permanent; confirm the live number before relying on it**
- `## Title:` / `## Notes:` / `## Author:` / `## Version:` - standard metadata
- `## SavedVariables:` / `## SavedVariablesPerCharacter:` - declares which global
  table(s) the client persists to the WTF folder on logout and restores on next
  load
- `## Dependencies:` / `## OptionalDeps:` - other addons this one requires or
  benefits from being loaded after
- Files load in the order listed in the `.toc`, top to bottom - anything a file
  depends on must be listed before it

## Project Structure

- One `.toc` = one `Interface/AddOns/` folder = one addon
- `Locales/` for localization files
- `Media/` for textures/sounds
- A `Libs/` folder is only created once an external library is actually added (see
  Dependencies below) - not scaffolded empty by default

## Addon Object, Events, and SavedVariables (Vanilla-First)

- A plain Lua table (the addon's own name, or a name passed via the file-load
  vararg pattern WoW provides to every loaded file) serves as the addon's
  namespace - no assumed framework object
- One manually created frame (`CreateFrame("Frame")`) registered for
  `ADDON_LOADED`, `PLAYER_LOGIN`, and whatever gameplay events are needed,
  dispatching through a simple event-name-to-handler table in its `OnEvent` script
- SavedVariables are the raw global(s) declared in the `.toc` - initialize with
  `MyAddonDB = MyAddonDB or {}` on this addon's `ADDON_LOADED`, then merge in
  defaults with a small hand-written recursive merge (a `setmetatable`-with-
  `__index` fallback onto a defaults table is normally enough - this does not need
  a database library)
- Options UI, if any, goes through Blizzard's native Settings API directly rather
  than an abstraction layer; a slash-command-only interface is a legitimate choice
  too, and often the more reasonable one for a small addon
- Localization is a plain per-locale `local L = {}` table keyed by `GetLocale()`
  unless this addon's localization needs are genuinely complex enough to justify
  more

## WoW API Awareness

- Note the ongoing migration to `C_*`-namespaced APIs (`C_AddOns`, `C_Timer`,
  `C_Item`, etc.) over older bare globals
- This targets a beta branch - verify the current API surface directly rather than
  assuming full continuity with prior WoW versions' API behavior

## Testing

- `luacheck` is the recommended static-analysis tool, run against a WoW API
  globals whitelist (community-maintained lists exist - document whichever this
  project adopts)
- Genuinely testing an addon's actual behavior requires the game client - this is
  the practical ceiling for automation here, consistent with staying
  distribution-agnostic rather than assuming a specific CI setup

## Secrets

- Most addons have none. If this one integrates with an external service/API
  needing credentials, follow the same `.example`-file pattern used elsewhere in
  this boilerplate - never commit a real key/token/credential

## Dependencies

- Hand-roll first. Reach for an external library (Ace3 or otherwise) only when the
  needed functionality would be a significant undertaking to implement well
  locally - not just a little extra code - and an existing library already solves
  it cleanly
- Any such addition requires discussion before adding, same as every other type in
  this boilerplate
- Once a library is justified, embed it under `Libs/` rather than leaving it as a
  loose sibling folder under `Interface/AddOns/` - that's what happens when a
  library bundle (Ace3's own standalone distribution, for example) is dropped in
  unpackaged rather than embedded into this addon's own folder

## Licensing

- No license has been chosen for this project yet - default is no license granted
  / all rights reserved, not this boilerplate's usual AGPLv3/Commercial default
- Do not add license headers or license boilerplate text until a license is
  actually chosen (see `lua.md`)
