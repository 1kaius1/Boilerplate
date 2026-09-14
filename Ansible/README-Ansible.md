# app_name

<!-- One sentence. What does this automation do and why would someone want it. -->

<!-- Badges - replace URLs with real ones -->
![Version](https://img.shields.io/github/v/release/OWNER/REPO)
![License](https://img.shields.io/badge/license-AGPL--3.0--or--later-blue)
![Build](https://img.shields.io/github/actions/workflow/status/OWNER/REPO/ci.yml)

---

## Overview

<!-- Two to four sentences expanding on the one-liner above. What does this
automate, what platform does it target, who is it for. -->

---

## Requirements

- Python <!-- version --> (control node)
- Ansible <!-- version floor -->
- <!-- Target OS/platform this automates, e.g. Debian 13, a Proxmox VE cluster,
  VMware, AWS, Azure, Vultr, Linode, Google Cloud -->
- <!-- Any other control-node requirement, e.g. a specific cloud CLI for a
  dynamic inventory plugin -->

---

## Getting Started

```bash
# Build the repo-local toolchain (venv + collections) - once per checkout
./bootstrap.sh

# Copy the example config/inventory and fill in real values
cp ansible.cfg.example ansible.cfg
cp inventory/hosts.ini.example inventory/hosts.ini
# Edit both with your real, site-specific values - never commit the real files
```

---

## Running

```bash
# Syntax check before anything else
ansible-playbook create-example.yaml --syntax-check

# Dry run - see what would change without changing anything
ansible-playbook create-example.yaml --check --diff

# Run for real
ansible-playbook create-example.yaml
```

---

## Secrets

Real, site-specific values (hostnames, IPs, credentials) are never committed - only
`.example` companion files are. Secrets are encrypted with Ansible Vault:

```bash
# Edit an encrypted file
ansible-vault edit group_vars/<group>/vault.yaml

# Run a playbook that needs the vault password
ansible-playbook create-example.yaml --ask-vault-pass
# or, with a configured vault_identity_list / password file:
ansible-playbook create-example.yaml
```

See [`docs/ANSIBLE_VAULT_GUIDE.md`](docs/ANSIBLE_VAULT_GUIDE.md) for full setup,
day-to-day use, password rotation, and troubleshooting.

---

## Testing

```bash
ansible-lint

# If Molecule is adopted for this project:
molecule test
```

---

## License

Copyright (C) <!-- YEAR --> <!-- AUTHOR / ORGANIZATION -->

This program is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.

A commercial license is also available for use cases that are incompatible with the
AGPL-3.0. Contact <!-- email or URL --> for details.

See [LICENSE](LICENSE) for the full license text.
