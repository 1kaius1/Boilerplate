# CLAUDE.md - Ansible Automation (Python)

This file provides project context and conventions for AI-assisted development sessions.
Read this file and ARCHITECTURE.md before making any changes. Behavioral rules and
guardrails are auto-loaded from `.claude/rules/` - there is nothing else to open.

---

## Project Overview

<!-- One paragraph. What does this automation do, what platform does it target,
who runs it. -->
<!-- Example: -->
<!-- my_infra automates provisioning and configuration of X on Y platform. It -->
<!-- solves Z by doing W, so a fresh environment can be rebuilt without having -->
<!-- to remember how. -->

---

## Tech Stack

| Component       | Choice                        | Reason                              |
|-----------------|--------------------------------|--------------------------------------|
| Automation      | Ansible                       | <!-- Why -->                         |
| Target platform | <!-- e.g. Proxmox VE, VMware, bare metal, AWS, Azure, Vultr, Linode, Google Cloud --> | <!-- Why --> |
| Control node    | Python <!-- version -->       | <!-- Why this version -->            |
| Secrets         | Ansible Vault                 | <!-- Why, or note if something else is used --> |
| Test framework  | <!-- Molecule / ansible-lint only / none yet --> | <!-- Why -->     |

---

## Repository Layout

```
project_name/
- roles/                # Reusable roles (tasks/, handlers/, defaults/, templates/)
- playbooks/            # Entry-point playbooks (or at the repo root - note which)
- group_vars/           # Per-group variables, including vault-encrypted secrets
- host_vars/            # Per-host variable overrides
- inventory/            # Static inventory (or a dynamic inventory plugin config)
- tests/                # Molecule scenarios, if adopted
- docs/
  - ANSIBLE_VAULT_GUIDE.md  # Full Vault walkthrough - setup, day-to-day use, rotation, troubleshooting
- .claude/              # Auto-loaded rules (.claude/rules/) and settings.json
- ARCHITECTURE.md       # Component and data flow reference
- CHANGELOG.md          # Version history (Keep a Changelog format)
- CLAUDE.md             # This file
- CONTRIBUTING.md       # Contribution guidelines
- PLANNING.md           # Goals, milestones, open questions
- README.md             # Public-facing documentation
- LICENSE               # Project license
- ansible.cfg           # Gitignored - real config; ansible.cfg.example is committed
- requirements.yml      # Collection dependencies
- bootstrap.sh          # Builds the repo-local venv + collections
```

<!-- Annotate any non-obvious directories or files specific to this project. -->

---

## Toolchain

### Prerequisites

```bash
# Python 3.x (see ARCHITECTURE.md for the exact floor)
```

### Bootstrap

```bash
./bootstrap.sh
# Builds .venv/ (ansible-core, cryptography for Vault, any provider SDKs) and
# .ansible/collections/ from requirements.yml. Never installs onto the system
# Python - see .claude/rules/ansible.md for why.
```

### Activating the Toolchain

```bash
# Playbook wrapper scripts put .venv/bin on PATH and export
# ANSIBLE_COLLECTIONS_PATH themselves - no manual activation needed for those.
# For ad-hoc commands:
source .venv/bin/activate
```

---

## Running Playbooks

```bash
# Syntax check - always first
ansible-playbook create-example.yaml --syntax-check

# Dry run
ansible-playbook create-example.yaml --check --diff

# Run for real
ansible-playbook create-example.yaml

# With a specific inventory or extra-vars
ansible-playbook create-example.yaml -i inventory/hosts.ini -e "some_var=value"
```

---

## Running Tests

```bash
ansible-lint

# If Molecule is adopted:
molecule test
```

---

## Secrets and Public-Repo Hygiene

- Real, site-specific values (hostnames, IPs, credentials) are never committed -
  only `.example` companion files are
- Secrets are Ansible Vault-encrypted; see `docs/ANSIBLE_VAULT_GUIDE.md` for setup,
  day-to-day use, rotation, and troubleshooting - update it if this project's own
  vault-identity/password conventions diverge from its examples
- `ansible.cfg` is typically gitignored in favor of a committed
  `ansible.cfg.example`, unless this project's config is genuinely secret-free

### Environment Variables

| Variable                  | Default         | Description                         |
|---------------------------|-----------------|-------------------------------------|
| `ANSIBLE_COLLECTIONS_PATH`| `.ansible/collections` | Repo-local collections path   |
| `ANSIBLE_CONFIG`          | `./ansible.cfg` | Config file - current directory only, never a parent |
| <!-- PROJECT_VAR -->      | <!-- default --> | <!-- description -->               |

---

## Code Style and Conventions

Behavioral rules and guardrails are auto-loaded from `.claude/rules/` - see
`universal.md`, `python.md` (for any custom modules/filters/plugins), and
`ansible.md`.

### Project-Specific Notes

```
<!-- Add any project-specific style deviations or enforced patterns here -->
<!-- Example: -->
<!-- All playbooks target one specific inventory group, never "all" -->
```

---

## Current Focus

See PLANNING.md for active goals, open questions, and pending decisions.

<!-- Optionally note the current sprint or immediate next task here so Claude -->
<!-- picks up context quickly at the start of a session. -->
<!-- Example: -->
<!-- Currently working on: idempotency verification for the backup role. -->
