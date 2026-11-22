---
name: ship
description: Take the current change from working tree to an open pull request - feature branch, CHANGELOG entry, tests, conventional commit, push, PR - with the user approving every commit message, the PR text, and the push itself, and stopping before merge.
disable-model-invocation: true
argument-hint: "[short description of the change]"
---

# Ship the current change

Follow these steps in order. Stop and report to the user at the first step that
fails - do not skip ahead, and do not work around a failure.

This skill has three approval gates: every commit message, the pull request title and
body, and the push. At each gate, stop and wait for the user's explicit approval.
Showing a draft is not approval, and neither is silence, approval given at an earlier
gate, or approval of an earlier draft. If the user asks for changes, revise and ask
again.

1. **Check the branch.** Run `git branch --show-current`. If it is `master` or `main`,
   create a feature branch named `type/short-description` from the change (use
   `$ARGUMENTS` if given) with `git switch -c`. Never commit on `master`/`main`.

2. **Review what is being shipped.** Run `git status` and `git diff`. If the diff
   contains changes unrelated to this one logical change, stop and ask the user how to
   split them. If it touches anything that looks like a secret (`.env`, keys, tokens,
   credentials), stop and tell the user.

3. **Update CHANGELOG.md.** Add an entry under `## [Unreleased]` in the right Keep a
   Changelog group (Added, Changed, Deprecated, Removed, Fixed, Security). Do not create
   a version heading. Skip only if the change is invisible to users (e.g. a CI tweak)
   and say so.

4. **Keep docs in step.** If the change alters structure, public APIs, commands, or
   config, update ARCHITECTURE.md, README.md, CLAUDE.md, or PLANNING.md to match.

5. **Run the tests.** Use the test command from CLAUDE.md's Running Tests section. If
   any test fails, stop - do not commit, do not open a PR. If tests cannot be run, say
   so explicitly and why, and ask the user whether to continue.

6. **Gate 1 - approve each commit.** Stage only the files for this change (never
   `git add -A` blindly). Draft a conventional commit: `type(scope): description`,
   imperative mood, first line under 72 characters, body wrapped at 72, no AI
   attribution of any kind. Show the user the staged file list and the full message
   exactly as it will be committed, then stop and wait. Commit only after the user
   approves that exact text, and use it verbatim. If the work has distinct logical
   steps, repeat this gate for each commit - approval of one commit does not cover
   the next.

7. **Gate 2 - approve the PR text.** Draft a PR against `master`: a title matching the
   main commit, and a body saying what changed, why, and how it was tested, with no AI
   attribution. Show the user the title and full body exactly as they will be posted,
   then stop and wait for approval of that exact text.

8. **Gate 3 - approve the push.** Tell the user exactly what will be pushed: the branch
   name, the remote, and the list of commits (`git log --oneline master..HEAD`). Then
   stop and wait. Do not push until the user explicitly approves the push - approving
   the commits or the PR text does not authorize it.

9. **Push and open the PR.** `git push -u origin <branch>`, then `gh pr create` with the
   approved title and body verbatim.

10. **Stop before merge.** Report the PR URL and end. Do not merge the PR, enable
    auto-merge, or approve it - merging is the user's manual final step, done outside
    this skill.
