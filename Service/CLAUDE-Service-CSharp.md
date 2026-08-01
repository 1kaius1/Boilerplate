# CLAUDE.md - Service / Daemon (C# / .NET)

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
| Language        | C# / .NET                 | <!-- Why this language -->              |
| Hosting model   | .NET Generic Host (BackgroundService) | <!-- Why -->                |
| Config format   | <!-- YAML/JSON/TOML -->   | <!-- Why -->                            |
| Transport       | <!-- HTTP, gRPC, Unix socket, etc. --> | <!-- Why -->             |
| Key dependency  | <!-- name -->             | <!-- What it provides -->               |
| Key dependency  | <!-- name -->             | <!-- What it provides -->               |

---

## Repository Layout

```
project_name/
- src/
  - AppName/             # Main project (Program.cs, Worker.cs, AppName.csproj)
- tests/
  - AppName.Tests/        # Test project
- init/                 # Service manager files (systemd unit, Windows service notes)
- scripts/              # Helper, packaging, and deployment scripts
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
dotnet build -c Release
```

### Install (local development)

```bash
dotnet run --project src/AppName
```

### Install (system)

```bash
# Publish a self-contained binary
dotnet publish src/AppName -c Release -r linux-x64 --self-contained -o /opt/app_name

# Install systemd unit (Linux) - requires the Microsoft.Extensions.Hosting.Systemd package
# and .UseSystemd() in Program.cs
sudo cp init/app_name.service /etc/systemd/system/
sudo systemctl daemon-reload

# Install as a Windows Service - requires the Microsoft.Extensions.Hosting.WindowsServices
# package and .UseWindowsService() in Program.cs
sc create app_name binPath= "C:\path\to\app_name.exe"
```

---

## Running the Service

### Development (foreground)

```bash
# Run in foreground with verbose logging (easiest for development)
dotnet run --project src/AppName -- --verbose

# With environment variable overrides
APP_NAME_LOG_LEVEL=Debug dotnet run --project src/AppName
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
| SIGTERM  | Graceful shutdown via IHostApplicationLifetime - finish in-flight work |
| SIGINT   | Graceful shutdown - same as SIGTERM           |
| SIGHUP   | Reload configuration without restart          |
| SIGUSR1  | <!-- document any custom signals or remove --> |

Graceful shutdown must complete within <!-- N --> seconds before the process is killed
(`HostOptions.ShutdownTimeout`).

---

## Running Tests

```bash
dotnet test

# With coverage
dotnet test --collect:"XPlat Code Coverage"

# Integration tests (requires running dependencies)
# Document how to spin up dependencies for integration tests
# Example: docker compose up -d && dotnet test tests/AppName.IntegrationTests
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
- Never hardcode paths - resolve the home directory at runtime (`Environment.GetFolderPath`)
- Config format preference order: YAML > JSON > TOML
- Config is reloaded on SIGHUP without restarting the process (`IOptionsMonitor`)

### Environment Variables

| Variable                  | Default         | Description                         |
|---------------------------|-----------------|-------------------------------------|
| `APP_NAME_CONFIG`         | `~/.app_name/config.yaml` | Path to config file       |
| `APP_NAME_LOG_LEVEL`      | `Information`   | Log verbosity                       |
| `APP_NAME_LOG_FORMAT`     | `text`          | Log format: text or json            |
| <!-- APP_NAME_XXXX -->    | <!-- default --> | <!-- description -->               |

### Config File Structure

```yaml
# ~/.app_name/config.yaml
# Document expected keys and their defaults here
# Example:
# log_level: Information
# log_format: text
# listen_address: "127.0.0.1:8080"
# shutdown_timeout_seconds: 30
```

---

## Service Architecture Notes

<!-- Describe the service's concurrency model and main loop so Claude understands -->
<!-- how the pieces fit together before touching any service code. Example: -->

<!--
The service is built on the .NET Generic Host. Program.cs configures the host,
registers a BackgroundService (Worker.cs) and any hosted subsystems, then calls
host.RunAsync(). The Generic Host wires up SIGTERM/SIGINT to
IHostApplicationLifetime, which the BackgroundService observes via the
CancellationToken passed to ExecuteAsync.

Background work is scheduled via IHostedService/BackgroundService instances or
Channel<T>-based worker queues with a configurable degree of parallelism.
-->

### Concurrency Notes

```
<!-- Document any specific concurrency patterns enforced in this project -->
<!-- Example: -->
<!-- CancellationToken propagated through all async calls for cooperative cancellation -->
<!-- Channel<T> used for producer/consumer work queues -->
```

---

## Logging

- Log to stderr by default in development
- Log destination configurable via `--log-file` flag or `APP_NAME_LOG_FILE` env var
- Format configurable: `text` (human-readable) or `json` (structured, for log aggregators)
- Log levels: Trace, Debug, Information, Warning, Error, Critical
- Never log credentials, tokens, or PII at any log level
- Include a request/correlation ID in all log lines within a request context

---

## Init and Service Manager Files

```
init/
- app_name.service      # systemd unit file (Linux, Type=notify or Type=simple)
- windows_service_notes.md  # Windows service registration notes (if applicable)
```

When modifying service behavior (startup, shutdown, dependencies), update the
init files to match. Do not leave init files out of sync with the binary's behavior.

---

## Code Style and Conventions

Behavioral rules are in `.clauderules`. Key reminders for this project:

- ASCII only in code and comments - no emoji, no em-dashes
- File names are PascalCase and match the class they contain (standard .NET convention)
- Explain WHY in comments, not WHAT
- Errors must be handled explicitly - no silent failures, no swallowed exceptions
- No unawaited async void methods outside event handlers - every Task must be observed
- Conventional commits: `type(scope): description`

### Language-Specific Notes

```
<!-- Add any project-specific style deviations or enforced patterns here -->
<!-- Example: -->
<!-- Nullable reference types enabled project-wide -->
<!-- CancellationToken is always the last parameter on async methods -->
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
