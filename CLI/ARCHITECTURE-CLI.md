# Architecture

This document describes the technical architecture of this project. It is a stable
reference - update it when structural changes are made, not for every commit. Claude
Code should read this alongside CLAUDE.md at the start of every session.

---

## Overview

<!-- Two to four sentences. What does this tool do at a technical level, what is the
execution model (single invocation, long-running, pipeline stage, etc.), and what are
the hard constraints it operates under (latency, throughput, correctness, etc.). -->

---

## Execution Model

<!-- Describe the lifecycle of a single invocation from entry point to exit. -->

```
argv
 |
 v
[Argument Parsing]
 |
 v
[Config Loading]       <-- ~/.app_name/config.yaml merged with flag overrides
 |
 v
[Input Validation]
 |
 v
[Core Logic]           <-- main work happens here
 |
 v
[Output Formatting]    <-- stdout (data) / stderr (errors/logs)
 |
 v
exit(code)
```

<!-- Describe any branching in this flow - e.g. subcommands, modes, dry-run. -->

---

## Component Breakdown

<!-- Describe each major component, what it owns, and what it does not own. -->
<!-- Keep descriptions to 2-3 sentences per component. -->

### Entry Point (`cmd/app_name` or `app_name.py`)

Parses arguments, loads configuration, wires dependencies together, and calls into
the core logic. Contains no business logic itself - it is the composition root.

### Configuration (`internal/config` or `src/config.py`)

Loads and merges configuration from `~/.app_name/config.yaml` and CLI flag overrides.
Validates config values and returns a single validated config struct/object to the
caller. Responsible for resolving the config file path from the home directory.

### Core Logic (`internal/...` or `src/...`)

<!-- Describe the main logic component(s). What problem do they solve? -->
<!-- What are their inputs and outputs? What do they explicitly not handle? -->

### Output Formatter (`internal/output` or `src/output.py`)

Formats results for stdout. Supports <!-- text/json/csv/table --> output modes
selectable via `--output` flag. Writes errors and log messages to stderr only.

### <!-- Additional Component -->

<!-- Description -->

---

## Data Flow

<!-- Trace how data moves through the application from input to output. -->
<!-- Use a diagram if the flow is non-trivial. -->

```
Input sources:
- CLI arguments / flags
- stdin (if applicable)
- Config file: ~/.app_name/config.yaml
- <!-- other sources: files, APIs, databases -->

Processing:
- <!-- step 1 -->
- <!-- step 2 -->
- <!-- step 3 -->

Output destinations:
- stdout: structured data / results
- stderr: errors, warnings, log messages
- <!-- other: files, APIs, databases -->
```

---

## Configuration and State

### Config File

- Location: `~/.app_name/config.yaml`
- Format: YAML
- Loaded once at startup; not reloaded during execution
- CLI flags always override config file values
- Missing config file is not an error - defaults are used

### Persistent State

<!-- Does this tool write any state between invocations? -->
<!-- Examples: cache files, lock files, history, last-run metadata -->

- <!-- Example: cache stored at ~/.app_name/cache/ -->
- <!-- Example: no persistent state - stateless tool -->

### Temporary Files

<!-- Does this tool create temporary files? Where? Are they cleaned up? -->

- <!-- Example: temp files written to OS temp dir via os.TempDir(), always cleaned up -->
- <!-- Example: no temporary files -->

---

## Error Handling Strategy

- All errors are handled explicitly - no ignored return values
- User-facing errors written to stderr with a clear description of what failed
- Internal errors include context for debugging (wrapped with cause)
- Fatal errors exit with a non-zero status code
- Log verbosity controlled by `--verbose` / `--quiet` flags

### Exit Codes

| Code | Meaning                          |
|------|----------------------------------|
| 0    | Success                          |
| 1    | General / unhandled error        |
| 2    | Bad arguments or usage error     |
| <!-- N --> | <!-- domain-specific -->   |

---

## Dependencies

<!-- List non-stdlib dependencies, what they provide, and why they were chosen
over alternatives. This section should make it easy to audit the dependency surface. -->

| Dependency | Purpose | Why This One |
|------------|---------|--------------|
| <!-- name --> | <!-- what it does --> | <!-- why not alternatives --> |

### Dependency Philosophy

- Prefer standard library solutions over third-party packages
- New dependencies require discussion and explicit approval (see .clauderules)
- Each dependency must justify its maintenance burden

---

## Testing Strategy

### Unit Tests

<!-- What is unit tested? What is the boundary of a unit in this project? -->

- Business logic in `internal/` or `src/` tested in isolation
- Config loading and validation tested with fixture files
- Output formatting tested against known inputs

### Integration Tests

<!-- Are there integration tests? What do they test? What do they require to run? -->

- <!-- Example: end-to-end tests invoke the compiled binary and check stdout/stderr -->
- <!-- Example: no integration tests yet - see PLANNING.md -->

### Test Fixtures

- Test input files stored in `tests/fixtures/`
- Expected output stored in `tests/expected/`
- <!-- Any other fixture conventions -->

---

## Cross-Platform Considerations

- Path handling: `os.path.join` (Python) / `filepath.Join` (Go) - never string concatenation
- Home directory: `os.path.expanduser("~")` (Python) / `os.UserHomeDir()` (Go)
- Line endings: normalize on read, write platform-native on output
- Executable permissions: set correctly in install scripts for Linux/macOS
- <!-- Any other platform-specific concerns for this tool -->

---

## File-Based Data Formats

<!-- Does this tool read or write any file formats beyond its config file?
Document them here - schema, version field, example, and any migration
strategy for format changes. Remove this section if not applicable. -->

<!-- Example: -->
<!-- ### Input Format -->
<!-- Files passed via argument or stdin must conform to: -->
<!-- ```json -->
<!-- { -->
<!--   "version": 1, -->
<!--   "field": "value" -->
<!-- } -->
<!-- ``` -->
<!-- - `version` is required and must be `1` - used to detect incompatible future formats -->
<!-- - Unrecognized fields are ignored, not rejected -->

<!-- ### Output Format -->
<!-- With --output json, the tool writes: -->
<!-- ```json -->
<!-- { -->
<!--   "version": 1, -->
<!--   "results": [] -->
<!-- } -->
<!-- ``` -->

---

## Extension and Integration Points

<!-- What does this tool expose to external callers or other tools?
Document stdin/stdout contracts, exit codes used by calling scripts,
any environment variables it sets or reads from callers, and any
plugin or hook mechanisms. Remove this section if not applicable. -->

- Stdout contract: <!-- describe the machine-readable output format callers depend on -->
- Exit codes: <!-- list codes that callers are expected to branch on -->
- Environment variables read from caller: <!-- or "none" -->
- Plugin / hook mechanism: <!-- or "none - not extensible by design" -->

---

## Known Limitations

<!-- What does this architecture not handle well? What are the known trade-offs?
This is honest documentation, not a list of bugs. -->

- <!-- Example: config is loaded once at startup; changes require restart -->
- <!-- Example: no support for concurrent invocations sharing state -->

---

## Future Architectural Considerations

<!-- Changes that are anticipated but not yet implemented. Keeps PLANNING.md focused
on tasks while capturing the architectural intent here. -->

- <!-- Example: if throughput becomes a concern, the output formatter could be made streaming -->
- <!-- Example: plugin system considered for v2.0 -->
