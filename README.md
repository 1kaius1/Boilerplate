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
your project, pick the language variant of `CLAUDE.md` and `.clauderules` that
matches your stack, rename files by removing the type/language suffix, and fill in
the placeholders.

### Universals

These files are identical across all project types and languages. Copy them as-is.

| File | Purpose |
|------|---------|
| `Universal/CHANGELOG.md` | Keep a Changelog format with versioned sections and diff links |
| `Universal/PLANNING.md` | Living document for goals, milestones, decisions, and open questions |
| `Universal/CONTRIBUTING.md` | Contributor workflow, code style, commit format, and CLA reference |
| `Universal/CLA.md` | Contributor License Agreement with copyright assignment and patent grant |

### Per-Type Sets

Each type directory contains one `ARCHITECTURE.md` and one `README.md`, plus a
`CLAUDE.md` and a `.clauderules` file **per supported language** so that a project
only ever pulls in guidance for the stack it actually uses.

| File | Purpose |
|------|---------|
| `CLAUDE-<Type>-<Language>.md` | Project onboarding document for Claude Code AI sessions, scoped to one language |
| `.clauderules-<Language>.md` | Behavioral rules and guardrails for Claude Code agentic sessions, scoped to one language |
| `ARCHITECTURE.md` | Technical reference: components, data flow, key design decisions |
| `README.md` | Public-facing documentation for the project |

| Directory | For | Language variants |
|-----------|-----|--------------------|
| `CLI/` | Command-line tools and utilities | Go, Python, C#, BASH |
| `GUI/` | Desktop GUI applications | Go, Python, C# |
| `Web/` | Web applications (backend API + frontend) | Go, Python, C#, PHP (Laravel) |
| `Service/` | Long-running background services and daemons | Go, Python, C# |

Only copy the one `CLAUDE-<Type>-<Language>.md` and one `.clauderules-<Language>.md`
that match your stack; the Usage section below covers this. The Web language
variants of `.clauderules` are fully self-contained - Laravel-specific rules are
included directly in `.clauderules-PHP.md`, and there is no separate addendum file
to append.

---

## Design Decisions

**Separate variants per project type rather than one universal template.**
The architecture of a CLI tool and the architecture of a web application have almost
nothing in common. Generic templates produce generic documents. Each variant here
reflects the actual structure of that project type.

**Very opinionated `.clauderules`.**
Each `.clauderules-<Language>.md` variant enforces strict rules about branch workflow,
scope control, destructive operations, dependency discipline, and license headers. The
intent is that Claude Code sessions require as little supervision as possible on
process - you should be able to focus on what to build, not on correcting what it touched.

**One `CLAUDE.md` and `.clauderules` per language, not one file covering all of them.**
Earlier versions of this boilerplate had a single `CLAUDE.md` and `.clauderules` per
project type with every supported language's guidance interleaved (Go build commands
next to Python build commands next to BASH build commands; CLI/GUI/Service behavioral
rules all present regardless of which type you picked). That meant every project
shipped with dead, irrelevant instructions for stacks and app types it didn't use -
exactly the "generic template" problem this boilerplate exists to avoid. Splitting by
language means the file you copy in only ever contains guidance for your actual stack.

**AGPLv3 / Commercial dual licensing as the default.**
The license blocks, CLA, and CONTRIBUTING.md are written for projects that are open
source under AGPLv3 but also available under a commercial license. Adjust the license
sections if your project uses a different model.

**`~/.app_name/` for local application data; environment variables for web.**
CLI tools, GUI applications, and daemons store persistent config and data under
`~/.app_name/`. Web applications follow twelve-factor conventions and are configured
exclusively via environment variables. This distinction is explicit in both the
`.clauderules` and the `CLAUDE.md` variants.

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

### Starting a New Project

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

# Pick the CLAUDE.md and .clauderules variant that match your language,
# rename them, and delete the variants you are not using.
# Example for a Go CLI tool (CLI also offers Python, C#, and BASH variants):
mv CLAUDE-CLI-Go.md CLAUDE.md
mv .clauderules-Go.md .clauderules
rm CLAUDE-CLI-Python.md CLAUDE-CLI-CSharp.md CLAUDE-CLI-BASH.md
rm .clauderules-Python.md .clauderules-CSharp.md .clauderules-BASH.md

# Remove the remaining type suffix from the other per-type files
mv ARCHITECTURE-CLI.md ARCHITECTURE.md
mv README-CLI.md README.md

# Search for placeholders and fill them in
grep -rn "<!-- " .
grep -rn "OWNER\|REPO\|app_name\|APP_NAME\|PROJECT_OWNER" .
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

## Languages and Tooling

These templates assume projects written in one or more of:

- **Go** - `go build`, `go test`, `go mod`, `gofmt`
- **Python** - `pip`, `pytest`, `black`, `flake8` / `ruff`
- **C# / .NET** - `dotnet build`, `dotnet test`, `dotnet format`, `dotnet ef` (web projects)
- **PHP** - `composer`, `php artisan`, `phpunit`, `pint` (web projects only)
- **BASH** - `set -euo pipefail`, shellcheck (CLI projects only)

`CLAUDE.md` and `.clauderules` are already split one file per language (see
What Is Included), so there is nothing to trim there. `ARCHITECTURE.md` is a
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
