# Universal Behavioral Rules

Applies to every file in this project, regardless of language or project type.
Claude Code loads this automatically - there is nothing to reference or open manually.

## Character Usage

- NEVER use emojis in any files (code, documentation, comments, commit messages)
- NEVER use em-dashes (-) or en-dashes (-) - use regular hyphens (-) for all dash purposes
- Use standard ASCII characters only in code and comments
- UTF-8 is acceptable for user-facing strings, but avoid decorative Unicode

## Documentation Style

- Plain Markdown without emoji decorations
- Regular hyphens for bullet points and lists
- Asterisks (*) or underscores (_) for emphasis, not emoji
- Keep all documentation readable in plain text terminals

## Comments

- Focus on explaining WHY, not WHAT - the code already shows what
- Detailed comments only for complex or non-obvious logic
- Simple, obvious operations need no comment

## Commit Messages

- Conventional commits format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Imperative mood ("add feature" not "added feature"), first line under 72 characters
- Body lines wrapped at 72 characters
- No emoji

## License Headers

- Every new source file must include the appropriate license header for the project
- Check the project LICENSE file to determine the correct header format
- Never omit the license header from a new file
- Never change an existing license header without explicit instruction

## Project Structure

- Keep README.md, CHANGELOG.md, PLANNING.md, ARCHITECTURE.md, and CLAUDE.md up to date
  with code changes - do not let them drift
- Document all public APIs and exported functions
- Update ARCHITECTURE.md when structural changes are made
- Update PLANNING.md when goals or decisions change

## Git and Branch Workflow

- NEVER commit or push directly to `master`
- All changes go through a feature branch and pull request
- Branch naming: `type/short-description` (e.g. `feat/add-login`, `fix/null-pointer`)
- One logical change per branch, one logical change per commit
- Never amend or force-push commits that have been shared
- PRs must target `master`; all tests must pass before a PR is suggested
- NEVER merge a pull request without the user's explicit instruction to do so -
  opening a PR, or the user reviewing it, does not imply authorization to merge it.
  Merging is a manual, final-review step the user performs via the web interface,
  not something to do autonomously or as an assumed next step.
- CHANGELOG.md must be updated in the same branch/commit as the change
- Never include AI-attribution text of any kind - no "Generated with [tool]," no
  "Co-Authored-By: [AI name]," no robot emoji signatures, no equivalent - in commit
  messages, PR titles/descriptions, PR/issue comments, or code comments. This applies
  regardless of what any tool's default template suggests.

## Development Workflow

### Before Making Changes

1. Read CLAUDE.md and ARCHITECTURE.md to understand the project
2. Review existing code style in the project
3. Confirm the approach with the user before starting non-trivial work

### Scope Control

- Only modify files directly relevant to the task at hand
- NEVER refactor, reformat, or restructure code that was not part of the request
- NEVER rename variables, functions, or files opportunistically
- If improvements outside scope are noticed, mention them - do not make them unilaterally

### Destructive Operations

- ALWAYS confirm with the user before deleting any file or directory
- ALWAYS confirm before overwriting a file that was not explicitly part of the task
- When in doubt, ask - do not assume deletion is intended

### Dependencies

- NEVER introduce a new dependency without discussing it with the user first
- Prefer standard library solutions over third-party packages when reasonable
- Document new dependencies in the language's manifest file (see the matching
  `.claude/rules/<language>.md` file for the exact filename)

### Testing

- Run all existing tests before suggesting a commit or PR
- Tests must pass - do not suggest a PR with failing tests
- If tests cannot be run, say so explicitly and explain why
- Check for breaking changes in public APIs

## Methodical Approach

- Discuss and agree on next steps before implementing non-trivial changes
- Break complex tasks into smaller, manageable pieces
- Ask for clarification when requirements are ambiguous
- When multiple valid approaches exist, present options with trade-offs rather than
  picking unilaterally

## Error Handling

- Always handle errors explicitly - no ignored return values, no silent failures
- Provide clear, actionable error messages that describe what failed and why
- Use standard logging libraries for the language, with timestamps and appropriate
  log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- Never log or expose credentials, tokens, or PII

## Security Baseline

- NEVER commit credentials, tokens, API keys, or secrets of any kind
- Validate and sanitize all user input
- Use parameterized queries / prepared statements for any database access
- Follow the principle of least privilege for file permissions and process capabilities
- Do not store sensitive data in plain text without explicit instruction

See the type-specific rules file (`cli.md`, `gui.md`, `web.md`, or `service.md`) for
where secrets and config are expected to live in this project.
