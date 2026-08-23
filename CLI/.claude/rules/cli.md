# CLI Application Rules

## Configuration and Data Storage

- CLI flags for database connections and runtime overrides (highest precedence)
- User data and settings stored under: `~/.app_name/` (where `app_name` matches the
  application name)
- NEVER use `~/.config/app_name/` or any other path variant - always `~/.app_name/`
- Config format preference order: YAML, JSON, TOML
- Secrets and credentials also live under `~/.app_name/` or environment variables -
  never hardcoded

## CLI Conventions

- `--help` / `-h` and `--version` / `-v` always supported
- Use the standard/idiomatic argument-parsing approach for this language (see
  CLAUDE.md's Tech Stack table for the specific library chosen for this project)
- Exit with appropriate status codes: 0 success, non-zero failure
- stderr for errors, stdout for data output
- Support `--verbose` / `--quiet` flags for log verbosity
