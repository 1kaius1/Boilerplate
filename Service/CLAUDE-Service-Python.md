# CLAUDE.md - Service / Daemon (Python)

This file provides project context and conventions for AI-assisted development sessions.
Read this file and ARCHITECTURE.md before making any changes. See .clauderules for
behavioral rules that govern this session.

---

## Project Overview

<!-- One paragraph. What does this service do, what problem does it solve, who runs it. -->
<!-- Example: -->
<!-- my_service is a long-running background daemon that does X for Y operators. -->
<!-- It solves Z by listening on W and doing V. -->

---

## Tech Stack

| Component       | Choice                    | Reason                                  |
|-----------------|---------------------------|-------------------------------------------|
| Language        | Python                    | <!-- Why this language -->              |
| Config format   | <!-- YAML/JSON/TOML -->   | <!-- Why -->                            |
| Transport       | <!-- HTTP, gRPC, Unix socket, etc. --> | <!-- Why -->             |
| Key dependency  | <!-- name -->             | <!-- What it provides -->               |
| Key dependency  | <!-- name -->             | <!-- What it provides -->               |

---

## Repository Layout

```
project_name/
- src/                  # Source modules
- init/                 # Service manager files (systemd, launchd, Windows service)
- scripts/              # Helper, packaging, and deployment scripts
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
# Python 3.11+
```

### Build

```bash
# No build step required, install dependencies:
pip install -r requirements.txt
```

### Install (local development)

```bash
# Install as editable package
pip install -e .
```

### Install (system)

```bash
# Copy application (or install into a virtualenv at a system path)
sudo cp -r . /opt/app_name

# Install systemd unit (Linux)
sudo cp init/app_name.service /etc/systemd/system/
sudo systemctl daemon-reload

# Install launchd plist (macOS)
cp init/com.example.app_name.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.example.app_name.plist

# Install Windows service
# sc create app_name binPath= "C:\path\to\python.exe C:\path\to\app_name\main.py"
```

---

## Running the Service

### Development (foreground)

```bash
# Run in foreground with verbose logging (easiest for development)
app_name --config ~/.app_name/config.yaml --verbose

# With environment variable overrides
APP_NAME_LOG_LEVEL=debug app_name --config ~/.app_name/config.yaml
```

### Production (systemd)

```bash
# Start
sudo systemctl start app_name

# Stop
sudo systemctl stop app_name

# Reload config (SIGHUP)
sudo systemctl reload app_name

# Check status
sudo systemctl status app_name

# View logs
journalctl -u app_name -f
```

### Signal Handling

| Signal   | Behavior                                      |
|----------|-----------------------------------------------|
| SIGTERM  | Graceful shutdown - finish in-flight work     |
| SIGINT   | Graceful shutdown - same as SIGTERM           |
| SIGHUP   | Reload configuration without restart          |
| SIGUSR1  | <!-- document any custom signals or remove --> |

Graceful shutdown must complete within <!-- N --> seconds before the process is killed.

---

## Running Tests

```bash
pytest

# With coverage
pytest --cov=src tests/

# Integration tests (requires running dependencies)
# Document how to spin up dependencies for integration tests
# Example: docker compose up -d && pytest tests/integration/
```

All tests must pass before committing or opening a pull request. Never suggest a PR
with failing tests. If tests cannot be run, say so explicitly.

---

## Configuration and Data Storage

- Runtime overrides via CLI flags (always take highest precedence)
- Environment variable overrides supported (see table below)
- Persistent config stored at: `~/.app_name/config.yaml`
- Runtime state and data stored under: `~/.app_name/`
- PID file (when daemonizing): `~/.app_name/app_name.pid`
- Never hardcode paths - resolve the home directory at runtime
- Config format preference order: YAML > JSON > TOML
- Config is reloaded on SIGHUP without restarting the process

### Environment Variables

| Variable                  | Default         | Description                         |
|---------------------------|-----------------|-------------------------------------|
| `APP_NAME_CONFIG`         | `~/.app_name/config.yaml` | Path to config file       |
| `APP_NAME_LOG_LEVEL`      | `info`          | Log verbosity                       |
| `APP_NAME_LOG_FORMAT`     | `text`          | Log format: text or json            |
| <!-- APP_NAME_XXXX -->    | <!-- default --> | <!-- description -->               |

### Config File Structure

```yaml
# ~/.app_name/config.yaml
# Document expected keys and their defaults here
# Example:
# log_level: info
# log_format: text
# listen_address: "127.0.0.1:8080"
# shutdown_timeout_seconds: 30
```

---

## Service Architecture Notes

<!-- Describe the service's concurrency model and main loop so Claude understands -->
<!-- how the pieces fit together before touching any service code. Example: -->

<!--
The service starts an asyncio event loop that:
1. Loads configuration
2. Initializes subsystems (database, cache, etc.)
3. Starts the listener (HTTP/gRPC/Unix socket)
4. Blocks on the signal handlers
5. On SIGTERM/SIGINT: cancels all tasks and shuts down subsystems in reverse order

Worker tasks are managed by an asyncio task group or a bounded queue.
Each worker handles one request/job at a time.
-->

### Concurrency Notes

```
<!-- Document any specific concurrency patterns enforced in this project -->
<!-- Example: -->
<!-- asyncio event loop; one coroutine per request; blocking calls offloaded to thread pool -->
<!-- asyncio.run() only at the top level; never nested -->
```

---

## Logging

- Log to stderr by default in development
- Log destination configurable via `--log-file` flag or `APP_NAME_LOG_FILE` env var
- Format configurable: `text` (human-readable) or `json` (structured, for log aggregators)
- Log levels: DEBUG, INFO, WARNING, ERROR, CRITICAL
- Never log credentials, tokens, or PII at any log level
- Include a request/correlation ID in all log lines within a request context

---

## Init and Service Manager Files

```
init/
- app_name.service      # systemd unit file (Linux)
- com.example.app_name.plist  # launchd plist (macOS)
```

When modifying service behavior (startup, shutdown, dependencies), update the
init files to match. Do not leave init files out of sync with the application's behavior.

---

## Code Style and Conventions

Behavioral rules are in `.clauderules`. Key reminders for this project:

- ASCII only in code and comments - no emoji, no em-dashes
- Underscores in all filenames
- Explain WHY in comments, not WHAT
- Errors must be handled explicitly - no silent failures
- No dangling asyncio tasks - every task must be awaited or explicitly tracked
- Conventional commits: `type(scope): description`

### Language-Specific Notes

```
<!-- Add any project-specific style deviations or enforced patterns here -->
<!-- Example: -->
<!-- Type hints required on all public functions -->
<!-- asyncio.run() only at the top level; never nested -->
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
<!-- Currently working on: implementing config reload on SIGHUP. -->
