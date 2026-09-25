# Boilerplate

Opinionated project boilerplate for CLI tools, GUI applications, web applications,
and services. Built for projects written in Go, Python, C#, and BASH, targeting
Linux, macOS, and Windows.

---

## What This Is

Starting a new project means creating the same set of documents every time - a
README, a changelog, an architecture doc, contribution guidelines, and so on. Done
carelessly these files are useless. Done well they orient contributors, keep AI
coding assistants on track, and make the project easier to maintain over time.

This repository contains a complete, carefully considered set of boilerplate templates
covering that entire surface. Each template is opinionated by design - the choices
reflect real conventions rather than leaving everything as a blank placeholder.

---

## What Is Included

Each project type lives in its own subdirectory. Copy the relevant directory into
your project, pick the language variant of `CLAUDE.md` that matches your stack,
rename files by removing the type/language suffix, and fill in the placeholders.

Behavioral rules for Claude Code live under `.claude/rules/` and `.claude/settings.json`
- these are real Claude Code conventions that load automatically at session start, not
a bespoke file Claude has to be told to go read. See "How Claude Code Rules Actually
Load" below for why this matters and how the pieces fit together.

### Universals

These files are identical across all project types. Copy them as-is.

| File | Purpose |
|------|---------|
| `Universal/CHANGELOG.md` | Keep a Changelog format with versioned sections and diff links |
| `Universal/PLANNING.md` | Living document for goals, milestones, decisions, and open questions |
| `Universal/CONTRIBUTING.md` | Contributor workflow, code style, commit format, and CLA reference |
| `Universal/CLA.md` | Contributor License Agreement with copyright assignment and patent grant |
| `Universal/.claude/rules/universal.md` | Cross-cutting Claude Code rules: git workflow, scope control, destructive-op confirmation, commit format, security baseline - applies regardless of language or type |
| `Universal/.claude/rules/<language>.md` | Per-language rules (naming, path handling, license header syntax, dependency manifest) - one file per language (Go, Python, C#, BASH, PHP), auto-scoped by file extension via `paths:` frontmatter |
| `Universal/.claude/settings.json` | Permission guardrails Claude Code actually enforces (blocks force-push and hard reset, requires confirmation before `rm -rf`) |

### Per-Type Sets

Each type directory contains one `ARCHITECTURE.md`, one `README.md`, one `CLAUDE.md`
variant **per supported language**, and one type-specific rules file under `.claude/rules/`.

| File | Purpose |
|------|---------|
| `CLAUDE-<Type>-<Language>.md` | Project onboarding document for Claude Code AI sessions, scoped to one language |
| `.claude/rules/<type>.md` | Behavioral rules specific to this project type (CLI/GUI/Web/Service conventions, where secrets and config live) |
| `ARCHITECTURE.md` | Technical reference: components, data flow, key design decisions |
| `README.md` | Public-facing documentation for the project |

| Directory | For | Language variants |
|-----------|-----|--------------------|
| `CLI/` | Command-line tools and utilities | Go, Python, C#, BASH |
| `GUI/` | Desktop GUI applications | Go, Python, C# |
| `Web/` | Web applications (backend API + frontend) | Go, Python, C#, PHP (Laravel) |
| `Service/` | Long-running background services and daemons | Go, Python, C# |
| `Godot/` | Godot game projects | GDScript, C# (Godot's ".NET"/"Mono" build) |
| `Ansible/` | Ansible automation (playbooks, roles, infrastructure) | Python (for any custom modules/filters/plugins) |
| `WoW-AddOn/` | World of Warcraft addons | Lua |

Only copy the one `CLAUDE-<Type>-<Language>.md` that matches your stack; the Usage
section below covers this. The language rule files under `.claude/rules/` do not need
the same treatment - a rules file for a language you are not using is simply inert
(its `paths:` glob never matches anything in your repo), so there is no harm in
leaving it in place. That matters for the monorepo case covered below. The `php.md`
rules file is fully self-contained - Laravel-specific rules are included directly in
it, and there is no separate addendum file to append.

**`Godot/` and `WoW-AddOn/` are the exceptions to "language rule files live
under `Universal/.claude/rules/`."** Godot's language files (`gdscript.md`,
`godot_csharp.md`) and WoW-AddOn's (`lua.md`) live inside their own type
directory's `.claude/rules/` instead, for the same reason each time: GDScript
and Lua are each used by exactly one type here, so there's no reason for
either to be a `Universal/` file other types would ever pick. `godot_csharp.md`
has a second reason too - it's deliberately an *addendum* to the generic
`Universal/.claude/rules/csharp.md`, not a replacement for it - a Godot+C#
project keeps both, since ordinary C# conventions (naming, `.csproj`
dependency tracking, the SPDX header syntax) still apply to a script attached
to a node. Naming it anything ending in `csharp.md` would also collide at the
same destination path when `Universal/` is copied in after the type directory
(whichever copy runs last would silently overwrite the other) -
`godot_csharp.md` avoids that collision by construction.

### How Claude Code Rules Actually Load

Earlier versions of this boilerplate used a file named `.clauderules` for behavioral
rules. That filename is not a Claude Code convention - Claude Code never opens it on
its own. The only files Claude Code auto-loads are `CLAUDE.md`, `CLAUDE.local.md`, a
user-level `~/.claude/CLAUDE.md`, and `.claude/rules/*.md` (optionally scoped to a
glob of file paths via `paths:` frontmatter). Rules that only exist in a file Claude
never reads do not apply - which meant every rule in this boilerplate that mattered
most (branch workflow, no direct push to master, confirm before deleting files, no
AI-attribution in commits) previously had no effect unless someone manually told
Claude to go open `.clauderules` first.

The current layout fixes this: `.claude/rules/universal.md` and the per-language
files load automatically for every session, and `.claude/rules/<type>.md` does the
same. `.claude/settings.json` goes one step further for the handful of rules that
are load-bearing enough to deserve hard enforcement rather than a prose instruction -
Claude Code's permission system can outright deny an action (force-push, `git reset
--hard`) or require explicit confirmation (`rm -rf`), independent of whether the
model remembers the rule. Branch protection against direct pushes to `master` is
still handled server-side via GitHub branch protection (see Repository Setup below) -
that is the correct enforcement point for it, not a local permission rule.

---

## Design Decisions

**Separate variants per project type rather than one universal template.**
The architecture of a CLI tool and the architecture of a web application have almost
nothing in common. Generic templates produce generic documents. Each variant here
reflects the actual structure of that project type.

**Very opinionated `.claude/rules/`.**
The rules files enforce strict conventions about branch workflow, scope control,
destructive operations, dependency discipline, and license headers. The intent is
that Claude Code sessions require as little supervision as possible on process - you
should be able to focus on what to build, not on correcting what it touched. Unlike a
plain prose file, these actually auto-load every session (see "How Claude Code Rules
Actually Load" above), and the handful of rules worth hard-enforcing also live in
`.claude/settings.json` as permission rules rather than instructions Claude could
forget.

**One `CLAUDE.md` per language, and rules split by both language and type.**
Earlier versions of this boilerplate had a single `CLAUDE.md` and `.clauderules` per
project type with every supported language's guidance interleaved (Go build commands
next to Python build commands next to BASH build commands; CLI/GUI/Service behavioral
rules all present regardless of which type you picked). That meant every project
shipped with dead, irrelevant instructions for stacks and app types it didn't use -
exactly the "generic template" problem this boilerplate exists to avoid.

`CLAUDE.md` stays split one file per language, since it is project onboarding prose
that only makes sense once. Rules are split differently, along two independent axes -
language (`.claude/rules/go.md`, `python.md`, ...) and type (`.claude/rules/cli.md`,
`web.md`, ...) - because `.claude/rules/*.md` files can be scoped with `paths:`
frontmatter and safely coexist. A `web.md` file scoped to nothing in particular
applies repo-wide in a single-type project; scope it to `paths: ["web/**"]` and it
only fires inside that subtree of a monorepo. See "Combining Types in One Repository"
below.

**AGPLv3 / Commercial dual licensing as the default.**
The license blocks, CLA, and CONTRIBUTING.md are written for projects that are open
source under AGPLv3 but also available under a commercial license. Adjust the license
sections if your project uses a different model.

**`~/.app_name/` for CLI/GUI; `/opt/app_name/` for services; environment variables for web.**
CLI tools and GUI applications run interactively as the logged-in user, so their
persistent config and data live under that user's home directory: `~/.app_name/`.
Services and daemons run under a service account with no meaningful home directory,
so they get their own self-contained root instead: `/opt/app_name/`, split into
`config/`, `data/`, `logs/`, and `run/` subdirectories, overridable as a whole via
`APP_NAME_HOME`. Web applications follow twelve-factor conventions and are configured
exclusively via environment variables. This three-way distinction is explicit in both
the `.claude/rules/` type files and the `CLAUDE.md` variants.

**Godot is its own project type, not a language under `GUI/`.**
A Godot project's real structure - scenes, nodes, signals, the resource system,
`user://` for storage, export templates instead of `dotnet publish` - has nothing in
common with the desktop-toolkit assumptions `GUI/` is built around (MVVM,
Avalonia/MAUI/WPF, `~/.app_name/`, GTK/Qt "Toolkit-Specific Notes"). Folding Godot in
as a `GUI/` language would have meant `gui.md` was actively wrong the moment Godot was
chosen - it says config lives in `~/.app_name/`, but Godot's idiomatic storage is
`user://`, an engine-managed path that resolves differently per platform and has
nothing to do with a literal home directory. The type/language split already used
everywhere else in this boilerplate - type captures structural/architectural
convention, language captures syntax-level convention - puts Godot itself squarely in
"type."

**Godot's C# rules are an addendum to the generic C# rules, not a fork of them.**
Checked against `Universal/.claude/rules/csharp.md`: naming conventions, `.csproj`
dependency tracking, and the SPDX header syntax all still apply unmodified to a
script attached to a Godot node - a Godot C# script is still an ordinary C# class as
far as those conventions go. What's missing from the generic file is Godot-specific:
the `partial class` requirement Godot's source generators impose, `_Process(double
delta)` taking a `double` (not `float` - a common porting mistake from Godot 3 or
general C# game-dev habits), `[Export]`/`[Signal]`/`[GlobalClass]` attributes, and
that `Path.Combine` is not how most Godot code should touch the filesystem in the
first place (`res://`/`user://` virtual paths are). `Godot/.claude/rules/
godot_csharp.md` holds only that delta, and both files stay loaded together for a
Godot+C# project - see "What Is Included" above for why the file lives in `Godot/`
rather than `Universal/`.

**Ansible is its own project type, modeling one self-contained project, not a
mono-repo of many.** An Ansible playbook repo (playbooks, roles, inventory,
`group_vars`/`host_vars`, Vault-encrypted secrets) has nothing in common with
`CLI`/`GUI`/`Web`/`Service`'s assumptions, the same reasoning that put Godot in its
own type. It deliberately does *not* bake in a "shared foundation many sibling
projects depend on" pattern - that is a mono-repo-of-many-deployments shape some
real Ansible repos use, but it is not universal, and asserting it as the default
would be exactly the "generic template" problem this boilerplate exists to avoid.
A project that does want that shape can still build it; the template just does not
assume it.

**`docs/ANSIBLE_VAULT_GUIDE.md` is real, field-tested content, generalized, not
written from scratch.** The full walkthrough - setup, day-to-day use, password
rotation, multi-identity strategies, and a troubleshooting table - was carried over
from a real Ansible project's own guide (refined through actual incidents, not
hypothetical ones) and then stripped of every project-specific name, path, and
architectural assumption. What stayed is the tested part: the exact commands, and
the expected-output/failure-output pairs for each one.

**`WoW-AddOn/` is its own type, the same reasoning as Godot and Ansible.** A World
of Warcraft addon has its own TOC-driven load model, its own event-driven lifecycle
(`ADDON_LOADED`, `PLAYER_LOGIN`, SavedVariables serialized by the client on
logout), and its own language (Lua) that no other type here uses - the same
structural mismatch with `CLI`/`GUI`/`Web`/`Service` that put Godot and Ansible in
their own types.

**`WoW-AddOn/` defaults to no license / all rights reserved, not this
boilerplate's usual AGPLv3/Commercial.** A deliberate per-type exception, not an
oversight - AGPLv3/Commercial dual licensing was chosen for projects intended for
distribution under those terms, and an addon with no license decided yet doesn't fit
that default any better than it would fit MIT or GPL. The template leaves the
license section as an explicit placeholder instead of asserting a license nobody
has chosen.

**`WoW-AddOn/` assumes no framework by default - hand-roll first.** A plain Lua
table as the addon's namespace, a manually created event frame, and direct
SavedVariables access cover most of what an addon needs. An external library (Ace3
or any other) is added only when a specific function would be a significant
undertaking to implement well locally - not just extra code - and an existing
library already solves it; that's a case-by-case decision requiring discussion, per
the same dependency-approval rule every type here already has, not a dependency
every new addon starts with.

**Keep a Changelog format.**
All projects use [keepachangelog.com](https://keepachangelog.com/en/1.1.0/) with
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). The `CHANGELOG.md`
boilerplate ships with the skeleton already in place so there is no reason to
defer starting it.

**Copyright assignment CLA rather than a license grant.**
The included `CLA.md` requires contributors to assign copyright to the project owner.
This is the cleanest foundation for dual AGPLv3/Commercial licensing - it avoids
needing to track down contributors if the license terms ever change.

---

## Usage

### Automated Setup (Recommended)

`scripts/new-project.sh` (Bash) and `scripts/New-Project.ps1` (PowerShell) automate
everything in "Starting a New Project" below: copying the right type + language
files, pruning the ones you didn't pick, substituting every `OWNER`/`REPO`/`APP_NAME`/
`PROJECT_OWNER_NAME` placeholder (and the less obvious `PROJECT_OWNER_EMAIL`,
`GOVERNING_LAW_JURISDICTION`, and `DISPUTE_RESOLUTION_JURISDICTION` ones tucked into
`CLA.md`), generating a language-appropriate `.gitignore`, and fetching a real
`LICENSE` - all before the first commit, closing the gaps the fully-manual flow leaves
open (see "Starting a New Project" below for what those gaps are).

```bash
./scripts/new-project.sh --type CLI --language Go --dest ~/projects/my_tool \
  --app-name my_tool --owner OWNER --repo my_tool
```

```powershell
./scripts/New-Project.ps1 -Type CLI -Language Go -Dest ~/projects/my_tool `
  -AppName my_tool -Owner OWNER -Repo my_tool
```

This stops after local scaffolding and lists the `<!-- description -->` and any
unfilled `SCREAMING_SNAKE_CASE` placeholders left to fill in by hand (the free-text
ones like `GOVERNING_LAW_JURISDICTION` can't be guessed - pass them as flags or edit
them directly). Once you've filled those in, re-run the exact same command with
`--init-repo` / `-InitRepo` to create the GitHub repo, push, and configure branch
protection and squash-only merging - it detects the destination already exists and
skips straight to that step rather than re-scaffolding. Add `--private`/`-Private` for
a private repo, and `--yes`/`-Yes` to skip the confirmation prompts (useful for CI,
but skips the safety check that warns you before pushing with placeholders still
unfilled). See `--help` / `Get-Help ./scripts/New-Project.ps1 -Full` for every option,
including `--project-owner-email`.

### Starting a New Project (Manual)

The steps below are what the scripts above do automatically - useful if you don't
have Bash or PowerShell available, or want to understand or customize each step.

```bash
# Clone this repository
git clone https://github.com/1kaius1/Boilerplate.git

# Copy the relevant type directory into your new project
cp -r Boilerplate/CLI/ ~/projects/my_tool/
# or
cp -r Boilerplate/Web/ ~/projects/my_app/

# Copy the universal files (trailing /. includes dotfiles - a bare
# `Universal/*` glob would silently skip any that exist)
cp -r Boilerplate/Universal/. ~/projects/my_tool/

cd ~/projects/my_tool

# Pick the CLAUDE.md variant that matches your language, rename it, and
# delete the variants you are not using.
# Example for a Go CLI tool (CLI also offers Python, C#, and BASH variants):
mv CLAUDE-CLI-Go.md CLAUDE.md
rm CLAUDE-CLI-Python.md CLAUDE-CLI-CSharp.md CLAUDE-CLI-BASH.md

# Remove the language rule files you are not using. universal.md and
# .claude/rules/cli.md (the type-specific file) always stay; only trim the
# per-language ones. A rule file for a language you never use is inert - its
# `paths:` glob never matches - so this step is tidiness, not correctness.
rm .claude/rules/python.md .claude/rules/csharp.md .claude/rules/bash.md .claude/rules/php.md

# Remove the remaining type suffix from the other per-type files
mv ARCHITECTURE-CLI.md ARCHITECTURE.md
mv README-CLI.md README.md

# Search for placeholders and fill them in. PROJECT_OWNER_EMAIL,
# GOVERNING_LAW_JURISDICTION, and DISPUTE_RESOLUTION_JURISDICTION live in
# CLA.md specifically and are easy to miss in a quick skim.
grep -rn "<!-- " .
grep -rn "OWNER\|REPO\|app_name\|APP_NAME\|PROJECT_OWNER_NAME\|PROJECT_OWNER_EMAIL\|GOVERNING_LAW_JURISDICTION\|DISPUTE_RESOLUTION_JURISDICTION" .

# Add a LICENSE and a .gitignore before the first commit - neither is
# included in this boilerplate (see "What These Templates Do Not Cover"),
# and skipping this step is how build artifacts or a real .env end up
# committed by accident.
curl -fsSL -o LICENSE https://www.gnu.org/licenses/agpl-3.0.txt
# Generate .gitignore at https://www.toptal.com/developers/gitignore for
# your language, or use gitignore.io's API directly, e.g.:
curl -fsSL -o .gitignore "https://www.toptal.com/developers/gitignore/api/go"
```

### Placeholder Convention

All placeholders use one of two formats:

- `<!-- description -->` - HTML comment placeholders in Markdown; visible in editors,
  invisible when rendered
- `SCREAMING_SNAKE_CASE` - inline placeholders for values like `OWNER`, `REPO`,
  `APP_NAME`, `PROJECT_OWNER_NAME`

A fresh `grep` for both patterns after copying will find everything that needs
attention before the documents are useful.

---

### Repository Setup

Once the local files are in place and placeholders filled in, create and configure
the actual GitHub repository. This assumes the GitHub CLI (`gh`) is installed and
authenticated (`gh auth login`).

```bash
# Create an empty public repo - no --add-readme/--gitignore/--license, since those
# would have GitHub generate an initial commit itself rather than the one you're
# about to push
gh repo create REPO --public

# Initialize locally with the primary branch named explicitly, add the SSH remote,
# commit, and push
git init -b master
git add .
git commit -m "chore: initial commit"
git remote add origin git@github.com:OWNER/REPO.git
git push -u origin master
```

Branch protection has no dedicated `gh` subcommand - only `gh ruleset check/list/view`
exist for the newer rulesets system, nothing for creating classic branch protection -
so this goes through `gh api` directly. Run this only after the first push; a branch
cannot be protected before it exists.

```bash
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/OWNER/REPO/branches/master/protection \
  --input - <<'EOF'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0
  },
  "restrictions": null
}
EOF
```

Add `"required_status_checks": {"strict": true, "checks": [{"context": "test"}]}`
once CI exists, replacing `"test"` with the actual job name, to require a passing run
before merge.

Standardize on squash-only merging with the PR title and description as the commit
message, enforced structurally rather than left as a convention someone can ignore -
merge-commit and rebase-merge are disabled outright, leaving squash as the only
option the GitHub UI offers. `gh repo edit --squash-merge-commit-message` may not
exist depending on your installed `gh` version; the REST API works regardless:

```bash
gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  /repos/OWNER/REPO \
  --input - <<'EOF'
{
  "allow_squash_merge": true,
  "allow_merge_commit": false,
  "allow_rebase_merge": false,
  "delete_branch_on_merge": true,
  "squash_merge_commit_title": "PR_TITLE",
  "squash_merge_commit_message": "PR_BODY"
}
EOF
```

---

## Combining Types in One Repository

Everything above assumes one project type in one repository. A larger project - a
game server combining a Service (the game loop / world simulation), a Web backend
(accounts, website), and CLI tooling (admin scripts, migrations) in a single
monorepo - needs more than one type directory at once. Claude Code supports this
natively through two mechanisms this boilerplate is designed to use directly:

**Nested `CLAUDE.md` files.** Claude Code loads the root `CLAUDE.md` at session
start, and additionally auto-discovers a `CLAUDE.md` in a subdirectory as soon as
Claude reads a file within it. Give each subsystem its own directory and its own
`CLAUDE.md` copied from the matching type variant:

```
my_game/
- server/
  - CLAUDE.md         # from Service/CLAUDE-Service-Go.md
- web/
  - CLAUDE.md         # from Web/CLAUDE-Web-PHP.md
- tools/
  - CLAUDE.md         # from CLI/CLAUDE-CLI-BASH.md
- CLAUDE.md           # root: brief orientation + pointers to each subsystem
- .claude/
  - rules/
    - universal.md
    - go.md
    - php.md
    - bash.md
    - cli.md          # add `paths: ["tools/**"]` to scope it to that subtree
    - web.md          # add `paths: ["web/**"]`
    - service.md      # add `paths: ["server/**"]`
  - settings.json
```

Keep the root `CLAUDE.md` short - project-wide orientation and a one-line pointer
into each subsystem directory - and let the nested files carry the type- and
stack-specific detail. Do not duplicate the subsystem detail in both places.

**Path-scoped rules.** Without a `paths:` restriction, a `.claude/rules/*.md` file
applies to the whole repository - correct for the single-type case this boilerplate
defaults to. Add `paths:` frontmatter to scope a rule file to one subsystem, and
multiple type and language rule files can coexist without deleting any of them - Go's
`go.md` and PHP's `php.md` both stay in place, each firing only for files under its
own glob. This is why the Usage section only tells you to delete *language* rule
files you are not using at all, never to pick a single type file to keep.

---

## Languages and Tooling

These templates assume projects written in one or more of:

- **Go** - `go build`, `go test`, `go mod`, `gofmt`
- **Python** - `pip`, `pytest`, `black`, `flake8` / `ruff`
- **C# / .NET** - `dotnet build`, `dotnet test`, `dotnet format`, `dotnet ef` (web projects)
- **PHP** - `composer`, `php artisan`, `phpunit`, `pint` (web projects only)
- **BASH** - `set -euo pipefail`, shellcheck (CLI projects only)
- **GDScript** - Godot's built-in scripting language, no external toolchain beyond
  the Godot editor itself (Godot projects only)
- **C# / .NET on Godot** - same `dotnet`/NuGet tooling as generic C#, plus the Godot
  editor and matching export templates; Godot 4.x calls this build ".NET" (Godot 3.x
  called the same thing "Mono") (Godot projects only)
- **Ansible** - `ansible-playbook`, `ansible-vault`, `ansible-lint`, Molecule (if
  adopted); Python is the control-node language for any custom modules/filters, via
  a repo-local virtualenv rather than the system Python (Ansible projects only)
- **Lua** - the WoW client's embedded Lua 5.1 interpreter, no external toolchain;
  `luacheck` for static analysis against a WoW API globals whitelist. No framework
  assumed by default - see Design Decisions (WoW-AddOn projects only)

`CLAUDE.md` and the `.claude/rules/` language files are already split one file per
language (see What Is Included), so there is nothing to trim there. `ARCHITECTURE.md` is a
stable reference and still documents multiple stacks side by side (for example,
Go/Python and Laravel request lifecycles in the Web variant) - remove the
subsections that do not apply to your project.

---

## What These Templates Do Not Cover

- **Makefiles or task runners** - `make`, `just`, `task` are all reasonable choices
  and intentionally left to the project
- **CI/CD pipelines** - GitHub Actions, GitLab CI, and Forgejo workflows vary enough
  that generic templates add more noise than value
- **Container files** - `Dockerfile` and `docker-compose.yml` are included as
  placeholder references in the web README but not provided as standalone templates
- **License files** - the `LICENSE` file itself is not included; obtain the correct
  AGPLv3 or other license text from [choosealicense.com](https://choosealicense.com)
- **`.gitignore`** - use [gitignore.io](https://www.toptal.com/developers/gitignore)
  to generate one appropriate for your language and tooling

---

## Contributing

Improvements are welcome. If a convention is wrong, a section is missing, or a
template does not reflect how a project type actually works, open an issue or a pull
request.

Follow the same workflow described in `Universal/CONTRIBUTING.md`. The CLA applies.

---

## License

This repository (the templates, documentation, and boilerplate content itself)
is licensed under the [Creative Commons Attribution 4.0 International License
(CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

Copyright (c) 2026 Kaius

You are free to share and adapt this material for any purpose, even
commercially, as long as you give appropriate credit. See the `LICENSE` file
for the full terms.

Note that this only covers the boilerplate repository itself. The AGPLv3 /
commercial dual-license text found *inside* the templates (e.g.
`Universal/CLA.md`, `Universal/CONTRIBUTING.md`, and the license sections in
the per-variant `README`/`CLAUDE` files) is boilerplate content meant to be
copied into downstream projects — it describes the license those projects
should use, and is unaffected by this repository's own license.

---

The `Universal/CLA.md` template is provided as a starting point only and is not
legal advice. Have it reviewed by a qualified attorney before relying on it.
