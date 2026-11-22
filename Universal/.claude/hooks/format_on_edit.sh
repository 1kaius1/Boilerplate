#!/usr/bin/env bash
# SPDX-License-Identifier: CC-BY-4.0
#
# PostToolUse hook (Edit|Write|MultiEdit): runs the language's standard
# formatter on the file Claude just changed, so formatting never depends on
# Claude remembering to do it and never shows up as noise in a later diff.
#
# Dispatches on file extension, so one script serves every project type.
# Each formatter is optional - if it isn't installed, the file is left as-is
# and the hook exits 0. Formatter failures are reported to Claude (exit 2
# with stderr) rather than silently swallowed, since they usually mean the
# edit left the file syntactically broken.

set -uo pipefail
# No -e: every failure path below is handled explicitly so the hook fails
# open, and an unexpected non-zero mid-script must not turn into a block.

input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
else
  # Minimal fallback: pull "file_path": "..." out of the JSON and undo the
  # backslash escaping JSON applies to Windows paths.
  file="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
  file="${file//\\\\/\\}"
fi

[[ -n "$file" && -f "$file" ]] || exit 0

have() { command -v "$1" >/dev/null 2>&1; }

run() {
  local out
  if ! out="$("$@" 2>&1)"; then
    echo "Formatter failed on $file: $*" >&2
    printf '%s\n' "$out" >&2
    exit 2
  fi
}

case "$file" in
  *.go)
    have gofmt && run gofmt -w "$file" ;;
  *.py)
    have ruff && run ruff format --quiet "$file" ;;
  *.cs)
    # dotnet format works per project, not per file; --include narrows it.
    # Skipped silently when no project/solution is found above the file.
    if have dotnet; then
      dir="$(dirname "$file")"
      while [[ "$dir" != "/" && "$dir" != "." && -z "$(find "$dir" -maxdepth 1 \( -name '*.csproj' -o -name '*.sln' \) -print -quit 2>/dev/null)" ]]; do
        dir="$(dirname "$dir")"
      done
      proj="$(find "$dir" -maxdepth 1 \( -name '*.sln' -o -name '*.csproj' \) -print -quit 2>/dev/null)"
      [[ -n "$proj" ]] && run dotnet format "$proj" --include "$file"
    fi
    ;;
  *.sh|*.bash)
    # shellcheck lints rather than formats - surfacing its findings is the point.
    have shellcheck && run shellcheck "$file" ;;
  *.php)
    have php-cs-fixer && run php-cs-fixer fix --quiet "$file" ;;
  *.lua)
    have stylua && run stylua "$file" ;;
  *.gd)
    have gdformat && run gdformat "$file" ;;
esac

exit 0
