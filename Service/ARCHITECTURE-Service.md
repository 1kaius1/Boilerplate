# Architecture

This document describes the technical architecture of this project. It is a stable
reference - update it when structural changes are made, not for every commit. Claude
Code should read this alongside CLAUDE.md at the start of every session.

---

## Overview

<!-- Two to four sentences. What does this service do at a technical level, what is
the concurrency model, what transport/protocol does it use, and what are the hard
constraints it operates under (latency, throughput, availability, consistency, etc.). -->

---

## Service Lifecycle

```
Start
 |
 v
[Entry Point]
 |
 v
[Config Loading]          <-- ~/.app_name/config.yaml + env vars + flags
 |
 v
[Subsystem Initialization] <-- database, cache, clients, listeners, etc.
 |                             (in dependency order)
 v
[Write PID File]          <-- ~/.app_name/app_name.pid
 |
 v
[Start Listener]          <-- begin accepting requests / messages
 |
 v
[Block on Signal]         <-- SIGTERM / SIGINT triggers shutdown path
 |
 v
[Graceful Shutdown]       <-- stop accepting, drain in-flight work,
 |                             shut down subsystems in reverse order,
 |                             remove PID file
 v
exit(0)
```

### Signal Handling

| Signal   | Behavior                                                        |
|----------|-----------------------------------------------------------------|
| SIGTERM  | Graceful shutdown - finish in-flight work, then exit cleanly    |
| SIGINT   | Graceful shutdown - same as SIGTERM                             |
| SIGHUP   | Reload configuration without restarting                         |
| SIGUSR1  | <!-- document any custom signals, or remove this row -->        |

Graceful shutdown must complete within <!-- N --> seconds. After that the process
may be killed by the service manager.

---

## Component Breakdown

<!-- Describe each major component, what it owns, and what it does not own.
Keep descriptions to 2-3 sentences per component. -->

### Entry Point (`cmd/app_name` or `app_name.py`)

Parses flags, loads configuration, initializes subsystems in dependency order, starts
the listener, and blocks on the signal channel. Contains no business logic - it is
the composition root and wiring layer.

### Configuration (`internal/config` or `src/config.py`)

Loads and merges configuration from `~/.app_name/config.yaml`, environment variables,
and CLI flag overrides (in increasing precedence order). Validates all values at
startup and fails fast on invalid config. Supports live reload on SIGHUP.

### <!-- Transport Layer (e.g. HTTP Server, gRPC Server, Unix Socket Listener) -->

<!-- Describe the transport: protocol, address/port, TLS, auth. -->
<!-- What does it accept? What does it hand off to? -->

### <!-- Request Handler / Router -->

<!-- Describe how incoming requests are routed to handlers. -->
<!-- What is the handler interface? What context is passed to handlers? -->

### <!-- Business Logic / Domain Layer -->

<!-- The core of what the service does. Describe its inputs, outputs, and
what it explicitly does not handle (transport, persistence, etc.). -->

### <!-- Persistence Layer (if applicable) -->

<!-- Database, file store, cache. What does it abstract? What guarantees does
it provide to callers? What are the failure modes? -->

### <!-- Additional Component -->

<!-- Description -->

---

## Concurrency Model

<!-- Describe how the service handles concurrent work. Be specific about the
pattern used so Claude does not introduce conflicting patterns. -->

### Request Handling

<!-- How are concurrent requests handled? -->
<!-- Examples: -->
<!-- Go: each request handled in its own goroutine; worker pool for CPU-bound work -->
<!-- Python: asyncio event loop; one coroutine per request; blocking calls in thread pool -->
<!-- Go: fixed worker pool of N goroutines pulling from a work queue -->

### Shared State

<!-- What state is shared between goroutines/threads? How is it protected? -->

- <!-- Example: in-memory cache protected by sync.RWMutex -->
- <!-- Example: request counter protected by sync/atomic -->
- <!-- Example: no shared mutable state - all state in database -->

### Context and Cancellation

<!-- How is cancellation propagated? -->

- <!-- Go: context.Context threaded through all goroutines; cancelled on shutdown -->
- <!-- Python: asyncio.CancelledError propagated through task tree -->
- In-flight requests respect the shutdown deadline and cancel via context on timeout

---

## Data Flow

```
Inbound:
- <!-- HTTP/gRPC/Unix socket requests -->
- <!-- message queue / event stream (if applicable) -->
- Config: ~/.app_name/config.yaml (loaded at start, reloaded on SIGHUP)

Processing path:
  Request received by transport layer
   |
   v
  Authentication / authorization check (if applicable)
   |
   v
  Request routing to handler
   |
   v
  Business logic execution
   |
   v
  Persistence read/write (if applicable)
   |
   v
  Response returned to caller

Outbound:
- <!-- HTTP/gRPC responses -->
- <!-- downstream service calls -->
- <!-- events published to message queue (if applicable) -->
- Logs: stderr (development) / log file or journald (production)
```

---

## Configuration and State

### Config File

- Location: `~/.app_name/config.yaml`
- Format: YAML
- Loaded at startup; reloaded on SIGHUP without restart
- Environment variables override config file values
- CLI flags override environment variables
- Service fails fast on invalid or missing required config values

### Environment Variable Overrides

| Variable                  | Config Key          | Description                         |
|---------------------------|---------------------|-------------------------------------|
| `APP_NAME_LOG_LEVEL`      | `log_level`         | Log verbosity                       |
| `APP_NAME_LOG_FORMAT`     | `log_format`        | Log format: text or json            |
| `APP_NAME_LISTEN_ADDRESS` | `listen_address`    | Address and port to listen on       |
| <!-- APP_NAME_XXXX -->    | <!-- key -->        | <!-- description -->                |

### Runtime Files

| File                         | Purpose                              |
|------------------------------|--------------------------------------|
| `~/.app_name/config.yaml`    | Primary configuration                |
| `~/.app_name/app_name.pid`   | PID file written at startup, removed at shutdown |
| `~/.app_name/<!-- other -->`  | <!-- purpose -->                    |

### Persistence

<!-- Describe what is persisted, where, and the failure characteristics. -->

- <!-- Example: PostgreSQL via DATABASE_URL - primary data store -->
- <!-- Example: local SQLite at ~/.app_name/data.db - embedded store -->
- <!-- Example: no persistence - stateless service -->

---

## Transport and Protocol

### Listener

<!-- Describe the network interface. -->

- Address: configurable via `listen_address` (default: `<!-- 127.0.0.1:PORT -->`)
- Protocol: <!-- HTTP/1.1, HTTP/2, gRPC, raw TCP, Unix domain socket -->
- TLS: <!-- enabled/disabled, how certs are configured -->
- Auth: <!-- API key, mTLS, none, etc. -->

### API Surface

<!-- Reference the API definition. Keep the description here brief; link to a
separate API doc or OpenAPI spec if one exists. -->

- <!-- Example: REST API defined in docs/api.md -->
- <!-- Example: gRPC service defined in proto/app_name.proto -->
- <!-- Example: internal service with no public API contract -->

---

## Logging

- Default destination: stderr (development); configurable via `--log-file` or
  `APP_NAME_LOG_FILE` for production
- Format: `text` (human-readable) or `json` (structured, for log aggregators)
- Levels: DEBUG, INFO, WARNING, ERROR, CRITICAL
- Every log line within a request context includes a correlation/request ID
- Sensitive data (credentials, tokens, PII) is never logged at any level

---

## Error Handling Strategy

- Errors in handlers are caught and translated to appropriate responses (e.g. HTTP 4xx/5xx)
- Unhandled panics (Go) / exceptions (Python) are caught at the transport boundary,
  logged as CRITICAL, and return a 500 / internal error response
- The service does not crash on a single bad request - only on unrecoverable startup
  failures or explicit shutdown signals
- Subsystem initialization failures at startup cause immediate exit with a non-zero code
  and a plain-text error to stderr

---

## Service Manager Integration

### systemd (Linux)

- Unit file: `init/app_name.service`
- Type: `simple` (process stays in foreground; systemd tracks the main PID)
- Restart policy: `on-failure` with a backoff
- Logging: stdout/stderr captured by journald

### launchd (macOS)

- Plist: `init/com.example.app_name.plist`
- Runs as user agent (LaunchAgents) or system daemon (LaunchDaemons) depending on use case

### Windows Service

- Wrapper: `<!-- cmd/app_name_windows.go or scripts/install_service.ps1 -->`
- <!-- Brief note on how the Windows service wrapper works -->

---

## Dependencies

| Dependency | Purpose | Why This One |
|------------|---------|--------------|
| <!-- name --> | <!-- what it does --> | <!-- why not alternatives --> |

### Dependency Philosophy

- Prefer standard library solutions over third-party packages
- New dependencies require discussion and explicit approval (see .clauderules)
- Each dependency must justify its maintenance and security audit burden

---

## Testing Strategy

### Unit Tests

- Business logic and domain layer tested in isolation with mocked dependencies
- Config loading and validation tested with fixture files
- Handler logic tested with request/response fixtures without starting a real listener

### Integration Tests

- Start a real instance of the service against a test database / mock dependencies
- Send real requests over the wire and assert on responses
- Require: <!-- list what must be running - e.g. PostgreSQL, Redis -->
- Run via: `<!-- command to run integration tests -->`

### Load / Stress Tests

- <!-- Document if load testing exists and how to run it, or note it is not yet implemented -->

---

## Cross-Platform Considerations

- Path handling: `os.path.join` (Python) / `filepath.Join` (Go) - never string concatenation
- Home directory: `os.path.expanduser("~")` (Python) / `os.UserHomeDir()` (Go)
- Signal handling: SIGTERM/SIGINT/SIGHUP are POSIX - Windows requires a separate
  shutdown mechanism (service stop event or SetConsoleCtrlHandler)
- PID files: meaningful on Linux/macOS; on Windows use the SCM for lifecycle management
- File permissions: set explicitly on sensitive files (config, data) - do not rely on umask

---

## Known Limitations

<!-- What does this architecture not handle well? What are the known trade-offs? -->

- <!-- Example: no horizontal scaling support - single instance only -->
- <!-- Example: config reload does not apply to listen address - requires restart -->
- <!-- Example: in-memory state is lost on restart - no persistence layer yet -->

---

## Future Architectural Considerations

<!-- Changes that are anticipated but not yet implemented. -->

- <!-- Example: metrics endpoint (Prometheus /metrics) planned for v0.3.0 -->
- <!-- Example: horizontal scaling via external queue considered for v2.0 -->
- <!-- Example: health check endpoint (GET /healthz) needed before production deployment -->
