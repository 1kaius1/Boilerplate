#!/usr/bin/env bash
# SPDX-License-Identifier: CC-BY-4.0
#
# PreToolUse hook (Bash): refuses `git commit` while the current branch is
# master or main. Permission rules in settings.json can match a command's
# text but not the branch it runs on, so this is the only way to enforce
# the "never commit directly to master" rule rather than just state it.
#
# Exit 2 blocks the tool call and feeds stderr back to Claude; exit 0 allows
# it. Any failure to parse input or read the branch fails open (exit 0) -
# a broken hook must never wedge every Bash call in the session.

set -uo pipefail
# No -e: every failure path below is handled explicitly so the hook fails
# open, and an unexpected non-zero mid-script must not turn into a block.

input="$(cat)"

# Prefer jq; fall back to a plain text match on the raw JSON, which is good
# enough to decide whether the command mentions `git commit` at all.
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"
  cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
else
  cmd="$input"
  cwd=""
fi

# Match `git commit` as a command, including after &&, ;, |, or a leading
# `git -C <dir>`-style global option, but not e.g. `git commit-graph`.
if ! printf '%s' "$cmd" | grep -Eq '(^|[;&|"[:space:]])git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+commit([[:space:]"]|$)'; then
  exit 0
fi

branch="$(git -C "${cwd:-.}" branch --show-current 2>/dev/null)" || exit 0

case "$branch" in
  master|main)
    echo "Blocked: committing directly to '$branch' is not allowed in this project." >&2
    echo "Create a feature branch first (git switch -c type/short-description)," >&2
    echo "then commit there. See .claude/rules/universal.md, Git and Branch Workflow." >&2
    exit 2
    ;;
esac

exit 0
