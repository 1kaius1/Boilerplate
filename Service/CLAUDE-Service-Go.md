# CLAUDE.md - Service / Daemon (Go)

This file provides project context and conventions for AI-assisted development sessions.
Read this file and ARCHITECTURE.md before making any changes. Behavioral rules and
guardrails are auto-loaded from `.claude/rules/` - there is nothing else to open.

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
| Language        | Go                        | <!-- Why this language -->              |
| Config format   | <!-- YAML/JSON/TOML -->   | <!-- Why -->                            |
| Transport       | <!-- HTTP, gRPC, Unix socket, etc. --> | <!-- Why -->             |
| Key dependency  | <!-- name -->             | <!-- What it provides -->               |
| Key dependency  | <!-- name -->             | <!-- What it provides -->               |

---

## Repository Layout

```
project_name/
- cmd/                  # Entry point
- internal/             # Private packages
- pkg/                  # Exported packages
- init/                 # Service manager files (systemd, launchd, Windows service)
- scripts/              # Helper, packaging, and deployment scripts
- tests/                # Test suite
- docs/                 # Additional documentation
- .claude/              # Auto-loaded rules (.claude/rules/) and settings.json
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
# Go 1.22+
```

### Build

```bash
go build -o bin/app_name ./cmd/app_name
```

### Install (local development)

```bash
# Install to GOPATH/bin
go install ./cmd/app_name
```

### Install (system)

```bash
# Copy binary
sudo cp bin/app_name /usr/local/bin/app_name

# Install systemd unit (Linux)
sudo cp init/app_name.service /etc/systemd/system/
sudo systemctl daemon-reload

# Install launchd plist (macOS) - LaunchDaemon, not LaunchAgent: a daemon must
# start at boot and run independent of any user session
sudo cp init/com.example.app_name.plist /Library/LaunchDaemons/
sudo launchctl load /Library/LaunchDaemons/com.example.app_name.plist

# Install Windows service
# sc create app_name binPath= "C:\path\to\app_name.exe"
```

---

## Running the Service

### Development (foreground)

```bash
# Run in foreground with verbose logging (easiest for development)
app_name --verbose

# Point the whole root at a local dev directory instead of /opt/app_name
# (no root access required for local development)
APP_NAME_HOME=./devdata app_name --verbose

# Or override individual paths
APP_NAME_LOG_LEVEL=debug app_name --config ./devdata/config/config.yaml
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
go test ./...

# With race detector (important for concurrent services)
go test -race ./...

# With coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Integration tests (requires running dependencies)
# Document how to spin up dependencies for integration tests
# Example: docker compose up -d && go test ./tests/integration/...
```

---

## Configuration and Data Storage

- Runtime overrides via CLI flags (always take highest precedence)
- Environment variable overrides supported (see table below)
- Root directory for everything below: `/opt/app_name/` (override with `APP_NAME_HOME`)
- Persistent config stored at: `/opt/app_name/config/config.yaml`
- Persistent application data stored under: `/opt/app_name/data/`
- Logs stored under: `/opt/app_name/logs/` (if not writing to stdout/journald)
- PID file (when daemonizing): `/opt/app_name/run/app_name.pid`
- Never hardcode paths - resolve them relative to `APP_NAME_HOME` at runtime
- Config format preference order: YAML > JSON > TOML
- Config is reloaded on SIGHUP without restarting the process

### Environment Variables

| Variable                  | Default         | Description                         |
|---------------------------|-----------------|-------------------------------------|
| `APP_NAME_HOME`           | `/opt/app_name` | Root directory for config, data, logs, and run |
| `APP_NAME_CONFIG`         | `$APP_NAME_HOME/config/config.yaml` | Path to config file |
| `APP_NAME_LOG_LEVEL`      | `info`          | Log verbosity                       |
| `APP_NAME_LOG_FORMAT`     | `text`          | Log format: text or json            |
| <!-- APP_NAME_XXXX -->    | <!-- default --> | <!-- description -->               |

### Config File Structure

```yaml
# /opt/app_name/config/config.yaml
# Document expected keys and their defaults here
# Example:
# log_level: info
# log_format: text
# listen_address: "127.0.0.1:8080"
# shutdown_timeout_seconds: 30
```

---

## Service Architecture Notes

<!-- Describe the concurrency model and main loop before touching any service code: -->
<!-- startup sequence, subsystem init order, and shutdown sequence on SIGTERM/SIGINT. -->

### Concurrency Notes

```
<!-- Document any specific concurrency patterns enforced in this project -->
<!-- (e.g. context.Context propagation, WaitGroup tracking for shutdown) -->
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
- app_name_windows.go   # Windows service wrapper (if applicable)
```

When modifying service behavior (startup, shutdown, dependencies), update the
init files to match. Do not leave init files out of sync with the binary's behavior.

---

## Code Style and Conventions

Behavioral rules and guardrails are auto-loaded from `.claude/rules/` - see
`universal.md` plus the language and type rule files that apply to this project.

### Language-Specific Notes

```
<!-- Add any project-specific style deviations or enforced patterns here -->
<!-- Example: -->
<!-- All errors wrapped with fmt.Errorf("context: %w", err) -->
<!-- context.Context is always the first argument -->
```

---

## Current Focus

See PLANNING.md for active goals, open questions, and pending decisions.

<!-- Optionally note the current sprint or immediate next task here so Claude -->
<!-- picks up context quickly at the start of a session. -->
<!-- Example: -->
<!-- Currently working on: implementing config reload on SIGHUP. -->
