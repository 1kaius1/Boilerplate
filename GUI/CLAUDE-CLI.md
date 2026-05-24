# CLAUDE.md - CLI Application

This file provides project context and conventions for AI-assisted development sessions.
Read this file and ARCHITECTURE.md before making any changes. See .clauderules for
behavioral rules that govern this session.

---

## Project Overview

<!-- One paragraph. What does this tool do, what problem does it solve, who uses it. -->
<!-- Example: -->
<!-- my_tool is a command-line utility that does X for Y users. It solves Z by doing W. -->

---

## Tech Stack

| Component       | Choice             | Reason                                      |
|-----------------|--------------------|---------------------------------------------|
| Language        | <!-- Go/Python/BASH --> | <!-- Why this language -->             |
| Arg parsing     | <!-- flag, cobra, argparse, etc. --> | <!-- Why -->            |
| Config format   | <!-- YAML/JSON/TOML --> | <!-- Why -->                           |
| Key dependency  | <!-- name -->      | <!-- What it provides -->                   |
| Key dependency  | <!-- name -->      | <!-- What it provides -->                   |

---

## Repository Layout

```
project_name/
- cmd/                  # Entry points (Go) or main script (Python/BASH)
- internal/             # Private packages not exported (Go)
- pkg/                  # Exported/reusable packages (Go)
- src/                  # Source modules (Python)
- scripts/              # Helper and maintenance scripts
- tests/                # Test suite
- docs/                 # Additional documentation
- .clauderules          # AI session behavioral rules
- ARCHITECTURE.md       # Component and data flow reference
- CHANGELOG.md          # Version history (Keep a Changelog format)
- CLAUDE.md             # This file
- CONTRIBUTING.md       # Contribution guidelines
- PLANNING.md           # Goals, milestones, open questions
- README.md             # Public-facing documentation
- LICENSE               # Project license
```

<!-- Annotate any non-obvious directories or files specific to this project. -->

---

## Build and Install

### Prerequisites

```bash
# List runtime and build dependencies
# Example:
# Go 1.22+
# Python 3.11+
# make
```

### Build

```bash
# Go
go build -o bin/app_name ./cmd/app_name

# Python - no build step required, install dependencies:
pip install -r requirements.txt

# BASH - no build step required
```

### Install (local development)

```bash
# Go - install to GOPATH/bin
go install ./cmd/app_name

# Python - install as editable package
pip install -e .

# BASH - symlink to PATH
ln -s "$(pwd)/app_name.sh" ~/.local/bin/app_name
```

---

## Running the Application

```bash
# Basic invocation
app_name [flags] [arguments]

# Show help
app_name --help

# Show version
app_name --version

# Verbose output
app_name --verbose [flags] [arguments]

# Example: <!-- replace with a real representative example -->
app_name --config ~/.app_name/config.yaml do-something
```

### Exit Codes

| Code | Meaning                        |
|------|--------------------------------|
| 0    | Success                        |
| 1    | General / unhandled error      |
| 2    | Bad arguments or usage error   |
| <!-- N --> | <!-- domain-specific -->  |

---

## Running Tests

```bash
# Go
go test ./...

# Go - with race detector
go test -race ./...

# Go - with coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Python
pytest

# Python - with coverage
pytest --cov=src tests/

# BASH
bash tests/run_tests.sh
```

All tests must pass before committing or opening a pull request. Never suggest a PR
with failing tests. If tests cannot be run, say so explicitly.

---

## Configuration and Data Storage

- Runtime overrides via CLI flags (always take highest precedence)
- Persistent config stored at: `~/.app_name/config.yaml`
- Application data stored under: `~/.app_name/`
- Never hardcode paths - resolve the home directory at runtime
- Config format preference order: YAML > JSON > TOML

### Config File Structure

```yaml
# ~/.app_name/config.yaml
# Document the expected keys and their defaults here
# Example:
# log_level: info
# output_format: text
# database_url: ""
```

---

## Code Style and Conventions

Behavioral rules are in `.clauderules`. Key reminders for this project:

- ASCII only in code and comments - no emoji, no em-dashes
- Underscores in all filenames
- Explain WHY in comments, not WHAT
- Errors must be handled explicitly - no silent failures
- stderr for errors, stdout for data output
- Conventional commits: `type(scope): description`

### Language-Specific Notes

```
<!-- Add any project-specific style deviations or enforced patterns here -->
<!-- Example: -->
<!-- Go: all errors wrapped with fmt.Errorf("context: %w", err) -->
<!-- Python: type hints required on all public functions -->
<!-- BASH: set -euo pipefail at top of every script -->
```

---

## Argument Parsing Conventions

- `--help` / `-h` - usage and flag reference (always supported)
- `--version` / `-v` - print version string and exit
- `--verbose` - increase log output
- `--quiet` - suppress non-error output
- `--config` - path to config file override
- Long flags preferred; short flags only for the most common options
- Positional arguments documented clearly in `--help` output

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
<!-- Currently working on: implementing the --output flag and JSON formatter. -->
