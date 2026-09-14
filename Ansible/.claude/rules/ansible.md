# Ansible Project Rules

## Toolchain

- Ansible runs from a repo-local virtualenv (`.venv/`, built by a bootstrap script),
  never the system Python - installing Ansible or its dependencies (especially
  `cryptography`, needed for Vault) on the system Python risks breaking unrelated
  distro packages that depend on a specific system Python state
- Collections install to a repo-local path (e.g. `.ansible/collections/`), declared
  in `ansible.cfg` and populated from `requirements.yml` - never relies on
  collections installed globally or on another project's path
- Both the venv and the collections path are gitignored; nothing about the toolchain
  itself is committed, only the manifests that reproduce it

## Project Structure

- Playbooks and scripts take a CRUD-verb prefix - `create-`, `read-`, `update-`,
  `delete-` (e.g. `create-example.yaml`, `update-example-config.yaml`) - a
  playbook's name states its blast radius before anyone opens it
- YAML files use the `.yaml` extension, never `.yml` - one consistent extension
  across the repo, not a per-file coin flip
- Roles follow the standard Ansible role layout (`tasks/`, `handlers/`, `defaults/`,
  `vars/`, `templates/`, `files/`, `meta/`) - do not invent a project-specific
  variant of this structure

## Secrets and Public-Repo Hygiene

- Real, site-specific values (hostnames, IPs, internal domains, credentials) are
  never committed - only a `.example` companion file is, with placeholder values
- Secrets always go through Ansible Vault - encrypted ciphertext is safe to commit;
  the corresponding real inventory/vars files that reference them are not, unless
  every sensitive value in them is itself vault-encrypted
- `ansible.cfg` is typically gitignored (it often carries a `vault_identity_list`
  naming a real credential label) with a committed `ansible.cfg.example` in its
  place, unless the project's own config genuinely carries nothing sensitive
- Never call `ansible-vault` in a way that prints decrypted content to a log a CI
  system or shell history would retain
- See `docs/ANSIBLE_VAULT_GUIDE.md` for the full walkthrough - setup, day-to-day
  use, rotation, and troubleshooting - before improvising a Vault workflow

## Idempotency

- Every playbook and role must be safely re-runnable - a second run against
  already-converged state reports no changes, not errors or duplicate side effects
- Prefer Ansible's built-in modules (which are idempotent by design) over `shell`/
  `command` tasks; when `shell`/`command` is unavoidable, guard it with `creates`,
  `changed_when`, or an explicit check so re-runs do not misreport or repeat work
- Verify idempotency explicitly before considering a playbook done - run it twice
  and confirm the second run reports zero changes, not just that the first run
  succeeded

## Testing

- `ansible-playbook <playbook> --syntax-check` before every commit that touches a
  playbook - cheap, fast, and catches typos immediately
- A `--check` (dry-run) pass where the target supports it, before running for real
  against anything that matters
- For deeper testing, Molecule is the standard framework for exercising a role in
  an isolated environment (Docker/container driver, or a cloud/VM driver where the
  role needs a real OS) - document the choice and how to run it if adopted
- ansible-lint catches common anti-patterns and deprecated syntax statically -
  complements, does not replace, actually running the playbook

## Inventory and Variables

- Group and host variables live in `group_vars/`/`host_vars/`, not hardcoded inside
  playbooks - a playbook should read the same regardless of which environment it
  targets
- Prefer one inventory group per real distinction that affects behavior (per
  cluster, per environment) over a single flat inventory with conditionals sprinkled
  through every playbook
