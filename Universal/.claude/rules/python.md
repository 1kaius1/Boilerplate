---
paths:
  - "**/*.py"
---

# Python-Specific Rules

- Use `os.path.join` (or `pathlib`), never string concatenation, for path handling
- Filenames use underscores and lowercase: `config_parser.py`, not `ConfigParser.py`
  or `config-parser.py`
- License header: `# SPDX-License-Identifier: AGPL-3.0-or-later`
- Document new dependencies in `requirements.txt` (or `pyproject.toml`)
