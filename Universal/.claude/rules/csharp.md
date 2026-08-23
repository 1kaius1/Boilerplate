---
paths:
  - "**/*.cs"
---

# C#-Specific Rules

- Use `Path.Combine`, never string concatenation, for path handling
- Class files use PascalCase matching the type name: `ConfigParser.cs`, not
  `config_parser.cs` or `config-parser.cs`
- License header: `// SPDX-License-Identifier: AGPL-3.0-or-later`
- Document new dependencies in the `.csproj` PackageReference list
