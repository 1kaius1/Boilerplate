# CLAUDE.md - Boilerplate repository

This repo is a project template, not a project. Everything under the type directories
and `Universal/` is *output*: it gets copied into new projects by the scaffolders. The
rules in `Universal/.claude/` are rules for those generated projects - they do not
govern work on this repo itself (this repo has no `.claude/` of its own).

## Layout

- `<Type>/` - one per project type (`CLI`, `GUI`, `Web`, `Service`, `Godot`, `Ansible`,
  `WoW-AddOn`). Each holds `ARCHITECTURE-<Type>.md`, `README-<Type>.md`, one
  `CLAUDE-<Type>-<Language>.md` per supported language, and `.claude/rules/<type>.md`.
- `Universal/` - copied into every project after the type directory: shared docs,
  `.claude/settings.json`, `.claude/hooks/`, `.claude/skills/`, and `.claude/rules/`
  (`universal.md` plus one file per shared language). Godot's and WoW-AddOn's language
  rules live in their own type directory instead (see README.md for why).
- `scripts/new-project.sh` and `scripts/New-Project.ps1` - the two scaffolders. They
  copy, rename the chosen variants, prune unused language rules, substitute
  placeholders, write `.gitignore`, and fetch LICENSE.
- `scripts/test-scaffold.sh` - smoke test for both scaffolders (see below).

## Invariants

- **The two scaffolders must behave identically.** Any change to one goes into the
  other in the same commit. The smoke test diffs their output for every combination.
- **Help text, README, and code stay in sync.** The valid type/language matrix appears
  in `new-project.sh` (usage text and the `case` validation), `New-Project.ps1`
  (comment-based help and `ValidateSet`), and README.md's tables. Change all of them
  together.
- **Placeholder tokens are global.** Substitution replaces `OWNER`, `REPO`, `APP_NAME`,
  `app_name`, `AppName`, and the `PROJECT_OWNER_*` / `*_JURISDICTION` tokens in every
  `.md`, `.json`, `.yaml`, and `.yml` file, `.claude/` included. Don't use those strings
  in template files unless they are meant to be replaced.
- **Hidden files matter.** `.claude/` is a dotdir: in PowerShell, `Get-ChildItem` and
  `Copy-Item` wildcards need `-Force` to see it.
- **Generated-project rule files are always loaded** unless they have `paths:`
  frontmatter. Keep `universal.md` short and put language-specific rules in path-scoped
  files.
- **Rules go in rule files, facts go in CLAUDE.md variants.** Don't repeat behavioral
  rules from `universal.md` in `CLAUDE-*.md`. Those hold project facts: commands,
  layout, config paths.

## Adding a project type or language

1. Add the type directory (or the `CLAUDE-<Type>-<Language>.md` variant) and its rules.
2. Update both scaffolders: usage/help text, type and language validation, the valid
   combination list, rule pruning, and `.gitignore` entries.
3. Add the combination to `COMBOS` in `scripts/test-scaffold.sh` and, for a new
   language, to `ALL_LANG_RULES` and `expected_lang_rules`.
4. Add a formatter case to `Universal/.claude/hooks/format_on_edit.sh` if the language
   has a standard formatter.
5. Update README.md's tables.

## Testing

```bash
scripts/test-scaffold.sh          # needs bash, git, pwsh; jq/shellcheck/PSScriptAnalyzer optional
scripts/test-scaffold.sh --keep   # leave the generated projects behind to inspect
```

It takes about two minutes and runs fully offline. CI (`.github/workflows/scaffold.yml`)
runs it on Linux and Windows. Run it before suggesting a commit that touches
`scripts/`, `Universal/`, or any type directory.
