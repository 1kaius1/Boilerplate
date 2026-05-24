# Boilerplate

Opinionated project boilerplate for CLI tools, GUI applications, web applications,
and services. Built for projects written in Go, Python, and BASH, targeting Linux,
macOS, and Windows.

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
your project, rename files by removing the type suffix, and fill in the placeholders.

### Universals

These files are identical across all project types. Copy them as-is.

| File | Purpose |
|------|---------|
| `Universal/CHANGELOG.md` | Keep a Changelog format with versioned sections and diff links |
| `Universal/PLANNING.md` | Living document for goals, milestones, decisions, and open questions |
| `Universal/CONTRIBUTING.md` | Contributor workflow, code style, commit format, and CLA reference |
| `Universal/CLA.md` | Contributor License Agreement with copyright assignment and patent grant |

### Per-Type Sets

Each type directory contains four files tailored to that project type.

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project onboarding document for Claude Code AI sessions |
| `.clauderules` | Behavioral rules and guardrails for Claude Code agentic sessions |
| `ARCHITECTURE.md` | Technical reference: components, data flow, key design decisions |
| `README.md` | Public-facing documentation for the project |

| Directory | For |
|-----------|-----|
| `CLI/` | Command-line tools and utilities |
| `GUI/` | Desktop GUI applications |
| `Web/` | Web applications (backend API + frontend) — Go, Python, PHP / Laravel |
| `Service/` | Long-running background services and daemons |

The `Web/` directory also includes a `.clauderules-web-addendum` file that overrides
and extends the base `.clauderules` for web-specific concerns (environment variable
config, database migrations, HTTP layering rules, security constraints).

---

## Design Decisions

**Separate variants per project type rather than one universal template.**
The architecture of a CLI tool and the architecture of a web application have almost
nothing in common. Generic templates produce generic documents. Each variant here
reflects the actual structure of that project type.

**Very opinionated `.clauderules`.**
The base `.clauderules` enforces strict rules about branch workflow, scope control,
destructive operations, dependency discipline, and license headers. The intent is
that Claude Code sessions require as little supervision as possible on process - you
should be able to focus on what to build, not on correcting what it touched.

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
git clone https://github.com/OWNER/project-boilerplate.git

# Copy the relevant type directory into your new project
cp -r project-boilerplate/CLI/ ~/projects/my_tool/
# or
cp -r project-boilerplate/Web/ ~/projects/my_app/

# Copy the universal files
cp project-boilerplate/Universal/* ~/projects/my_tool/

# Remove the type suffixes from filenames
cd ~/projects/my_tool
mv CLAUDE-CLI.md CLAUDE.md
mv ARCHITECTURE-CLI.md ARCHITECTURE.md
mv README-CLI.md README.md

# The .clauderules file has no suffix - it is ready to use
# For web projects, append the addendum to .clauderules:
# cat .clauderules-web-addendum >> .clauderules
# rm .clauderules-web-addendum

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
- **PHP** - `composer`, `php artisan`, `phpunit`, `pint` (web projects only)
- **BASH** - `set -euo pipefail`, shellcheck

Build and test commands in each template cover all applicable languages. Remove
the sections that do not apply to your project.

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

Copyright (c) 2025 <!-- YOUR NAME -->

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

The `Universal/CLA.md` template is provided as a starting point only and is not
legal advice. Have it reviewed by a qualified attorney before relying on it.
