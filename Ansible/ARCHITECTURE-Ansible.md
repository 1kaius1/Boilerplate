# Architecture

This document describes the technical architecture of this project. It is a stable
reference - update it when structural changes are made, not for every commit. Claude
Code should read this alongside CLAUDE.md at the start of every session.

---

## Overview

<!-- Two to four sentences. What does this repository automate, what platform(s)
does it target (bare metal, a hypervisor, a cloud provider), and what is the
intended blast radius of a typical run (one host, a whole environment). -->

---

## Execution Lifecycle

```
Invocation
 |
 v
[Toolchain Activation]    <-- repo-local venv on PATH, ANSIBLE_COLLECTIONS_PATH set
 |
 v
[Config Resolution]       <-- ansible.cfg (current directory only - Ansible never
 |                              reads config from a parent directory)
 v
[Inventory Resolution]    <-- static inventory file, or a dynamic inventory plugin
 |
 v
[Variable Resolution]     <-- group_vars/ -> host_vars/ -> playbook vars ->
 |                              extra-vars (-e), in increasing precedence
 v
[Play Execution]          <-- tasks run host-by-host or in parallel, per the
 |                              play's `strategy` and `serial` settings
 |    |
 |    +-- role tasks (if any) run in the order roles are listed
 |    +-- handlers fire once, after all tasks in the play, in the order
 |    |   they were first notified (not the order notified this run)
 |    +-- failures halt that host by default; the rest of the play continues
 |        for other hosts unless `any_errors_fatal` is set
 v
[Result Reporting]        <-- per-host ok/changed/failed/skipped summary
```

---

## Component Breakdown

<!-- Describe each major role/playbook group, what it owns, and what it does not
own. Keep descriptions to 2-3 sentences per component. -->

### <!-- Role Name -->

<!-- What it provisions or configures, what it depends on (another role, an
external API, etc.), and what it explicitly does not handle. -->

### <!-- Entry-Point Playbook -->

<!-- What it orchestrates, which roles it applies, in what order, and against
which inventory group. -->

### <!-- Additional Component -->

<!-- Description -->

---

## Inventory and Variable Model

### Inventory

<!-- Static file, or a dynamic inventory plugin (e.g. a cloud provider's
inventory plugin)? How are hosts grouped, and what does each group represent? -->

### Variable Precedence in Use

- `group_vars/<group>/` - values shared by every host in a group
- `host_vars/<host>/` - overrides for one specific host
- Playbook-level `vars:` - values specific to one playbook's own logic, not
  meant to vary per host or group
- `-e` / extra-vars - one-off runtime overrides, never committed as the way a
  value is normally supplied

### Secrets

- Location: `<!-- e.g. group_vars/<group>/vault.yaml -->`
- Encrypted with Ansible Vault; the corresponding `.example` file ships with
  placeholder values and is the only version committed unencrypted
- <!-- Vault identity/password management approach for this project -->

---

## Role and Playbook Design

### Role Responsibilities

<!-- List each role and its single responsibility. A role that does several
unrelated things is a sign it should be split. -->

### Idempotency Approach

- <!-- Which modules/patterns this project relies on for idempotency -->
- <!-- Any tasks that are necessarily non-idempotent, and why, and what
  guards (creates/changed_when/check) keep re-runs safe anyway -->

### Handlers

<!-- What triggers each handler, and what it does. Handlers should be narrowly
scoped (restart one service, reload one config) - not a dumping ground for
"things to do eventually." -->

---

## Data Flow

```
Input sources:
- Inventory + group_vars/host_vars (target hosts and their configuration)
- Vault-encrypted secrets
- CLI extra-vars for one-off overrides
- <!-- external APIs this automation calls (e.g. a hypervisor API) -->

Processing:
- Playbooks orchestrate; roles implement; modules perform the actual idempotent
  operations against target hosts or external APIs

Output destinations:
- Configured state on target hosts (files, services, packages)
- <!-- external resources created/modified (VMs, DNS records, etc.) -->
- Ansible's own result/fact output (not persisted unless explicitly captured)
```

---

## Error Handling Strategy

- Preflight checks (`assert`, connectivity/precondition tasks) fail fast with a
  specific message before any state-changing task runs, rather than failing
  deep into a run with a confusing error
- Destructive or hard-to-reverse tasks (data-losing migrations, resource
  deletion) require an explicit flag or confirmation, never run unconditionally
  as part of a routine playbook
- A failure on one host does not silently abort the whole run unless
  `any_errors_fatal` is deliberately set - document if this project deviates
  from that default

---

## Dependencies

| Dependency | Purpose | Why This One |
|------------|---------|--------------|
| <!-- collection/role name --> | <!-- what it provides --> | <!-- why not alternatives --> |

### Dependency Philosophy

- Prefer Ansible's built-in modules over a third-party collection where the
  built-in module covers the need
- New collections/roles require discussion and explicit approval (see
  `.claude/rules/`)
- Pin collection versions in `requirements.yml` - do not float on `latest`
  for anything that provisions real infrastructure

---

## Testing Strategy

### Static Checks

- `ansible-playbook --syntax-check` on every playbook before commit
- `ansible-lint` for anti-patterns and deprecated syntax

### Dry Runs

- `--check` (and `--diff` where useful) before running for real against
  anything that matters

### Molecule (if adopted)

- <!-- Driver in use (docker/vagrant/cloud), what scenarios exist, and how to
  run them - or "not yet adopted, see PLANNING.md" -->

### Live Verification

- <!-- What "verified working" means for this project - a specific health
  check, a manual smoke test, a real end-to-end deploy - document it so
  "verified" means something consistent across contributors -->

---

## Cross-Platform / Target Considerations

- Target OS/distribution(s): <!-- e.g. Debian 13, Ubuntu 22.04+ -->
- Control node requirements: <!-- Python version, Ansible version floor -->
- <!-- Any target-specific module differences this project has to account for
  (e.g. apt vs dnf, systemd vs other init) -->

---

## Known Limitations

<!-- What does this architecture not handle well? What are the known trade-offs? -->

- <!-- Example: no automated rollback - a failed mid-run change must be fixed
  forward, not reverted automatically -->

---

## Future Architectural Considerations

<!-- Changes that are anticipated but not yet implemented. -->

- <!-- Example: Molecule test coverage planned before this role is considered
  stable -->
