#!/usr/bin/env bash
# SPDX-License-Identifier: CC-BY-4.0
#
# Smoke test for the scaffolders. For every valid type/language combination,
# runs both new-project.sh and New-Project.ps1 into (a) a destination that
# doesn't exist and (b) a pre-created, git-init'd destination, then checks:
#
#   - the expected top-level files exist and no type/language variants or a
#     nested template directory were left behind
#   - exactly the right language rule files survived pruning
#   - settings.json is valid JSON and the hooks/skill shipped
#   - no required placeholder token survived substitution
#   - re-running into the now-populated destination is refused
#   - the bash and PowerShell outputs are identical (LICENSE excluded - it's
#     downloaded, so it depends on the network, not on the scripts)
#
# Finally runs shellcheck and PSScriptAnalyzer over the scripts if they're
# installed. Needs bash, git, and pwsh; jq is used for the JSON check if present.
#
# Usage: scripts/test-scaffold.sh [--keep]   (--keep leaves the work dir behind)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SH="$ROOT/scripts/new-project.sh"
PS="$ROOT/scripts/New-Project.ps1"
KEEP=0
[ "${1:-}" = "--keep" ] && KEEP=1

command -v pwsh >/dev/null 2>&1 || { echo "pwsh is required (PowerShell 7+)" >&2; exit 1; }

# Make the LICENSE download fail instantly instead of waiting out its 10s
# timeout per run on a slow or offline network: both curl and PowerShell's
# Invoke-WebRequest honor these, and port 9 (discard) refuses connections.
# LICENSE is excluded from the comparison below for the same reason.
export HTTPS_PROXY="http://127.0.0.1:9" https_proxy="http://127.0.0.1:9"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/test-scaffold.XXXXXX")"
cleanup() { if [ "$KEEP" -eq 1 ]; then echo "Work dir kept: $WORK"; else rm -rf "$WORK"; fi; }
trap cleanup EXIT

COMBOS=(
  CLI:Go CLI:Python CLI:CSharp CLI:BASH
  GUI:Go GUI:Python GUI:CSharp
  Web:Go Web:Python Web:CSharp Web:PHP
  Service:Go Service:Python Service:CSharp
  Godot:GDScript Godot:CSharp
  Ansible:Python
  WoW-AddOn:Lua
)
ALL_LANG_RULES=(go python csharp bash php gdscript godot_csharp lua)

FAILURES=0
fail() { echo "  FAIL: $*" >&2; FAILURES=$((FAILURES + 1)); }

expected_lang_rules() {
  case "$1:$2" in
    Godot:GDScript) echo "gdscript" ;;
    Godot:CSharp) echo "csharp godot_csharp" ;;
    WoW-AddOn:Lua) echo "lua" ;;
    *) echo "$2" | tr '[:upper:]' '[:lower:]' ;;
  esac
}

# Every optional placeholder gets a value, so none should remain afterwards.
common_args() {
  local type="$1" lang="$2" dest="$3" style="$4"
  if [ "$style" = sh ]; then
    printf '%s\0' --type "$type" --language "$lang" --dest "$dest" \
      --app-name smoke_app --owner smoke-owner --repo smoke-repo \
      --project-owner-name "Smoke Owner" --project-owner-email smoke@example.invalid \
      --governing-law "Smoke Law" --dispute-jurisdiction "Smoke Court" --yes
  else
    printf '%s\0' -Type "$type" -Language "$lang" -Dest "$dest" \
      -AppName smoke_app -Owner smoke-owner -Repo smoke-repo \
      -ProjectOwnerName "Smoke Owner" -ProjectOwnerEmail smoke@example.invalid \
      -GoverningLaw "Smoke Law" -DisputeJurisdiction "Smoke Court" -Yes
  fi
}

run_scaffolder() {
  local style="$1" type="$2" lang="$3" dest="$4" log="$5"
  local -a args
  mapfile -d '' args < <(common_args "$type" "$lang" "$dest" "$style")
  if [ "$style" = sh ]; then
    bash "$SH" "${args[@]}" >"$log" 2>&1
  else
    pwsh -NoProfile -NonInteractive -File "$PS" "${args[@]}" >"$log" 2>&1
  fi
}

check_output() {
  local type="$1" lang="$2" dest="$3"
  local f r keep

  for f in CLAUDE.md ARCHITECTURE.md README.md CHANGELOG.md PLANNING.md CONTRIBUTING.md \
           CLA.md .gitignore .claude/settings.json .claude/rules/universal.md \
           .claude/hooks/block_default_branch_commit.sh .claude/hooks/format_on_edit.sh \
           .claude/skills/ship/SKILL.md; do
    [ -e "$dest/$f" ] || fail "$f missing"
  done
  [ ! -e "$dest/$type" ] || fail "template nested at $type/"
  [ ! -e "$dest/Universal" ] || fail "template nested at Universal/"
  if compgen -G "$dest/CLAUDE-*.md" >/dev/null || compgen -G "$dest/ARCHITECTURE-*.md" >/dev/null \
     || compgen -G "$dest/README-*.md" >/dev/null; then
    fail "type/language variant files left behind"
  fi

  keep=" $(expected_lang_rules "$type" "$lang") "
  for r in "${ALL_LANG_RULES[@]}"; do
    if [[ "$keep" == *" $r "* ]]; then
      [ -f "$dest/.claude/rules/$r.md" ] || fail "rule $r.md should have been kept"
    else
      [ ! -f "$dest/.claude/rules/$r.md" ] || fail "rule $r.md should have been pruned"
    fi
  done

  if command -v jq >/dev/null 2>&1; then
    jq empty "$dest/.claude/settings.json" 2>/dev/null || fail "settings.json is not valid JSON"
  fi

  if grep -rlE '\b(OWNER|REPO|APP_NAME|PROJECT_OWNER_NAME|PROJECT_OWNER_EMAIL|GOVERNING_LAW_JURISDICTION|DISPUTE_RESOLUTION_JURISDICTION)\b' \
       --include='*.md' --include='*.json' "$dest" >/dev/null 2>&1; then
    fail "unsubstituted placeholder tokens remain"
  fi
}

for combo in "${COMBOS[@]}"; do
  type="${combo%%:*}" lang="${combo##*:}"
  for mode in fresh pregit; do
    echo "== $type/$lang ($mode)"
    for style in sh ps; do
      dest="$WORK/$style/$type-$lang-$mode"
      mkdir -p "$(dirname "$dest")"
      [ "$mode" = pregit ] && git init -q "$dest"
      if ! run_scaffolder "$style" "$type" "$lang" "$dest" "$dest.log"; then
        fail "$style scaffolder exited non-zero (see $dest.log)"
        continue
      fi
      check_output "$type" "$lang" "$dest"
      if run_scaffolder "$style" "$type" "$lang" "$dest" "$dest.rerun.log"; then
        fail "$style re-run into a populated destination was not refused"
      fi
    done
    if ! diff -r --strip-trailing-cr -x .git -x LICENSE \
           "$WORK/sh/$type-$lang-$mode" "$WORK/ps/$type-$lang-$mode" >"$WORK/diff.out" 2>&1; then
      fail "bash and PowerShell outputs differ:"
      sed 's/^/    /' "$WORK/diff.out" | head -n 40 >&2
    fi
  done
done

echo "== static analysis"
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$SH" "$ROOT/scripts/test-scaffold.sh" "$ROOT"/Universal/.claude/hooks/*.sh \
    || fail "shellcheck reported issues"
else
  echo "  shellcheck not installed - skipped"
fi
if pwsh -NoProfile -NonInteractive -Command 'exit [int](-not (Get-Module -ListAvailable PSScriptAnalyzer))'; then
  # Error severity only: at Warning it flags the script's deliberate
  # Write-Host use for user-facing progress output.
  pwsh -NoProfile -NonInteractive -Command "\$r = Invoke-ScriptAnalyzer -Path '$PS' -Severity Error; \$r | Format-Table -AutoSize | Out-String | Write-Host; exit [int](\$r.Count -gt 0)" \
    || fail "PSScriptAnalyzer reported issues"
else
  echo "  PSScriptAnalyzer not installed - skipped"
fi

echo ""
if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES check(s) failed."
  exit 1
fi
echo "All checks passed."
