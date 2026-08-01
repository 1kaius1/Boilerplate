# CLAUDE.md - CLI Application (C# / .NET)

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
| Language        | C# / .NET          | <!-- Why this language -->                  |
| Arg parsing     | <!-- System.CommandLine, Spectre.Console.Cli, etc. --> | <!-- Why -->     |
| Config format   | <!-- YAML/JSON/TOML --> | <!-- Why -->                           |
| Key dependency  | <!-- name -->      | <!-- What it provides -->                   |
| Key dependency  | <!-- name -->      | <!-- What it provides -->                   |

---

## Repository Layout

```
project_name/
- src/
  - AppName/             # Main project (Program.cs, AppName.csproj)
- tests/
  - AppName.Tests/        # Test project
- scripts/              # Helper and maintenance scripts
- docs/                 # Additional documentation
- AppName.sln           # Solution file
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
# .NET 8 SDK or later
```

### Build

```bash
dotnet build

# Release build
dotnet build -c Release
```

### Install (local development)

```bash
# Publish a self-contained single-file binary
dotnet publish src/AppName -c Release -r <RID> --self-contained -p:PublishSingleFile=true -o bin/
# <RID>: linux-x64, osx-x64, osx-arm64, win-x64, etc.
```

---

## Running the Application

```bash
# Basic invocation (development)
dotnet run --project src/AppName -- [flags] [arguments]

# Basic invocation (published binary)
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
dotnet test

# With coverage
dotnet test --collect:"XPlat Code Coverage"
```

All tests must pass before committing or opening a pull request. Never suggest a PR
with failing tests. If tests cannot be run, say so explicitly.

---

## Configuration and Data Storage

- Runtime overrides via CLI flags (always take highest precedence)
- Persistent config stored at: `~/.app_name/config.yaml`
- Application data stored under: `~/.app_name/`
- Never hardcode paths - resolve the home directory at runtime (`Environment.GetFolderPath`)
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
- File names are PascalCase and match the class they contain (standard .NET convention)
- Explain WHY in comments, not WHAT
- Errors must be handled explicitly - no silent failures, no swallowed exceptions
- stderr for errors, stdout for data output
- Conventional commits: `type(scope): description`

### Language-Specific Notes

```
<!-- Add any project-specific style deviations or enforced patterns here -->
<!-- Example: -->
<!-- Nullable reference types enabled project-wide -->
<!-- Async methods suffixed with Async and awaited all the way up the call stack -->
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
