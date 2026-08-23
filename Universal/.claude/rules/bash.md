---
paths:
  - "**/*.sh"
---

# BASH-Specific Rules

- `set -euo pipefail` at the top of every script
- Quote all variable expansions: `"${var}"`, not `$var`
- Use `[[ ]]` for conditionals, not `[ ]`
- Avoid GNU-only flags when portability to macOS/BSD userland is required
- Filenames use underscores and lowercase: `config_parser.sh`, not `ConfigParser.sh`
  or `config-parser.sh`
- License header: `# SPDX-License-Identifier: AGPL-3.0-or-later`
- Prefer POSIX/coreutils solutions over third-party tools when reasonable
- Document new external command dependencies in the Prerequisites section of CLAUDE.md
