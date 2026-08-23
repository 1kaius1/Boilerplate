# GUI Application Rules

## Configuration and Data Storage

- CLI flags for runtime overrides
- User data and settings stored under: `~/.app_name/` (where `app_name` matches the
  application name)
- NEVER use `~/.config/app_name/`, XDG paths, or the Windows Registry - always
  `~/.app_name/`
- Config format preference order: YAML, JSON, TOML
- Secrets and credentials also live under `~/.app_name/` - never hardcoded

## GUI Conventions

- Must work cross-platform (Linux, macOS, Windows)
- Follow platform UI guidelines where possible
- Provide keyboard shortcuts for common actions
- Never hardcode font sizes, colors, or paths
- Present errors to the user via dialog or status bar - never crash silently
