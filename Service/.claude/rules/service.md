# Service / Daemon Rules

## Configuration and Data Storage

Services default to a single self-contained root: `/opt/<app_name>/`. This differs
from the CLI/GUI `~/.app_name/` convention on purpose - a daemon runs under a service
account, not an interactive login session, so a per-user home directory is often
unresolvable (or meaningless) in that execution context.

- `/opt/<app_name>/config/` - configuration files
- `/opt/<app_name>/data/` - persistent application state/data
- `/opt/<app_name>/logs/` - log files (if not writing to stdout/journald)
- `/opt/<app_name>/run/` - PID file and other transient runtime state
- The whole root is overridable via a single `APP_NAME_HOME` environment variable
  (default `/opt/app_name`) - useful for local development without root access
- CLI flags and environment variable overrides for individual paths still take
  highest precedence
- Config format preference order: YAML, JSON, TOML
- Config is reloaded on SIGHUP without restarting the process where supported
- Secrets and credentials also live under `/opt/<app_name>/` (with restrictive file
  permissions) or environment variables - never hardcoded

## Services and Daemons

- Handle SIGTERM and SIGINT for graceful shutdown; SIGHUP for config reload where
  appropriate
- Provide a systemd unit file (and launchd plist / Windows service wrapper for
  cross-platform)
- Log to stderr by default; support a configurable log destination
- Never block the main loop on non-critical work
- Every background worker/goroutine/thread must have a defined exit condition - no
  leaks on shutdown
- Document all runtime flags and environment variables
