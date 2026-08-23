---
paths:
  - "**/*.go"
---

# Go-Specific Rules

- Use `filepath.Join`, never string concatenation, for path handling
- Filenames use underscores and lowercase: `config_parser.go`, not `ConfigParser.go`
  or `config-parser.go`
- License header: `// SPDX-License-Identifier: AGPL-3.0-or-later`
- Document new dependencies in `go.mod`
