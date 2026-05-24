# CLAUDE.md - Web Application

This file provides project context and conventions for AI-assisted development sessions.
Read this file and ARCHITECTURE.md before making any changes. See .clauderules for
behavioral rules that govern this session.

---

## Project Overview

<!-- One paragraph. What does this application do, what problem does it solve,
who uses it, and what is the rough scale it is designed for. -->

---

## Tech Stack

### Backend

| Component       | Choice                        | Reason                              |
|-----------------|-------------------------------|-------------------------------------|
| Language        | <!-- Go/Python -->            | <!-- Why -->                        |
| Web framework   | <!-- gin, chi, FastAPI, Flask, etc. --> | <!-- Why -->           |
| Database        | <!-- PostgreSQL/SQLite/etc. --> | <!-- Why -->                       |
| ORM / query     | <!-- sqlc, GORM, SQLAlchemy, etc. --> | <!-- Why -->               |
| Auth            | <!-- JWT, session, OAuth2, etc. --> | <!-- Why -->                   |
| Key dependency  | <!-- name -->                 | <!-- What it provides -->           |

### Frontend

| Component       | Choice                        | Reason                              |
|-----------------|-------------------------------|-------------------------------------|
| Approach        | <!-- SPA, SSR, MPA, HTMX, templates --> | <!-- Why -->            |
| Framework       | <!-- React, Vue, HTMX, Jinja2, etc. --> | <!-- Why -->            |
| Build tool      | <!-- Vite, esbuild, none -->  | <!-- Why -->                        |
| CSS approach    | <!-- Tailwind, plain CSS, etc. --> | <!-- Why -->                   |
| Key dependency  | <!-- name -->                 | <!-- What it provides -->           |

---

## Repository Layout

```
project_name/
- cmd/                  # Entry point(s) (Go)
- internal/             # Private backend packages (Go)
- pkg/                  # Exported backend packages (Go)
- src/                  # Backend source modules (Python)
- web/                  # All frontend source
  - src/                # Frontend source files (JS/TS/CSS)
  - public/             # Static files served as-is
  - dist/               # Built frontend output (do not edit; gitignored)
- templates/            # Server-side HTML templates (if applicable)
- migrations/           # Database migration files (numbered, sequential)
- scripts/              # Helper, build, and deployment scripts
- tests/                # Test suite
  - unit/               # Unit tests
  - integration/        # Integration tests (require running dependencies)
  - e2e/                # End-to-end tests (require full stack)
- docs/                 # Additional documentation
- .clauderules          # AI session behavioral rules
- ARCHITECTURE.md       # Component and data flow reference
- CHANGELOG.md          # Version history (Keep a Changelog format)
- CLAUDE.md             # This file
- CONTRIBUTING.md       # Contribution guidelines
- PLANNING.md           # Goals, milestones, open questions
- README.md             # Public-facing documentation
- LICENSE               # Project license
- .env.example          # Example environment variables (never .env itself)
```

<!-- Annotate any non-obvious directories or files specific to this project. -->

---

## Build and Run

### Prerequisites

```bash
# Backend
# Go 1.22+ or Python 3.11+

# Frontend (if applicable)
# Node.js 20+ and npm/pnpm

# Database
# PostgreSQL 15+ / SQLite (no server required)
```

### Environment Setup

```bash
# Copy the example env file and fill in values
cp .env.example .env
# Edit .env - never commit .env to version control
```

### Database Setup

```bash
# Create the database (PostgreSQL example)
createdb app_name_dev

# Run migrations
# Go (migrate / goose / atlas)
migrate -path migrations/ -database "${DATABASE_URL}" up

# Python (Alembic)
alembic upgrade head
```

### Backend

```bash
# Go
go build -o bin/app_name ./cmd/app_name
./bin/app_name

# Or run directly
go run ./cmd/app_name

# Python
pip install -e .
python -m app_name
# or
uvicorn app_name.main:app --reload  # FastAPI/Starlette
flask run                            # Flask
```

### Frontend

```bash
# Install dependencies
npm install

# Development server with hot reload
npm run dev

# Production build (outputs to web/dist/)
npm run build
```

### Full Stack Development

```bash
# Run backend and frontend concurrently
# Option A: two terminals
#   Terminal 1: go run ./cmd/app_name  (or equivalent)
#   Terminal 2: npm run dev

# Option B: process manager
# scripts/dev.sh  (if provided)
```

---

## Running Tests

```bash
# Backend unit tests
# Go
go test ./...
go test -race ./...

# Python
pytest tests/unit/

# Integration tests (requires running database)
# Go
go test ./tests/integration/...

# Python
pytest tests/integration/

# End-to-end tests (requires full stack running)
# playwright / cypress / etc.
npm run test:e2e

# Frontend tests
npm run test
```

All tests must pass before committing or opening a pull request. Never suggest a PR
with failing tests. If tests cannot be run, say so explicitly.

---

## Configuration and Environment Variables

Web applications are configured exclusively via environment variables and the `.env`
file. The `~/.app_name/` home directory convention does not apply here.

- `.env` - local development values; never committed to version control
- `.env.example` - committed to version control; all keys present, no real secrets
- Production values set via the deployment environment (see README.md)

### Environment Variables

| Variable            | Required | Default       | Description                         |
|---------------------|----------|---------------|-------------------------------------|
| `DATABASE_URL`      | Yes      | -             | Full database connection string     |
| `SECRET_KEY`        | Yes      | -             | Secret key for signing sessions/JWT |
| `ALLOWED_HOSTS`     | Yes      | `localhost`   | Comma-separated list of allowed hostnames |
| `DEBUG`             | No       | `false`       | Enable debug mode (never true in production) |
| `LOG_LEVEL`         | No       | `info`        | Log verbosity                       |
| `LOG_FORMAT`        | No       | `text`        | Log format: text or json            |
| `PORT`              | No       | `8080`        | Port to listen on                   |
| <!-- VAR -->        |          |               | <!-- description -->                |

Never hardcode secrets in source files. Never commit `.env`. Never log secret values.

---

## Database Migrations

- All schema changes must be expressed as migration files in `migrations/`
- Migrations are numbered sequentially: `001_create_users.sql`, `002_add_index.sql`
- Never edit a migration that has already been applied to any environment
- Migrations must be reversible where possible (include a down migration)
- Run migrations before starting the server after pulling new changes

```bash
# Check current migration state
# Go (migrate)
migrate -path migrations/ -database "${DATABASE_URL}" version

# Python (Alembic)
alembic current

# Apply pending migrations
# Go
migrate -path migrations/ -database "${DATABASE_URL}" up

# Python
alembic upgrade head
```

---

## API Conventions

<!-- Describe the API style and conventions used in this project. -->

- Style: <!-- REST / GraphQL / RPC -->
- Base path: <!-- /api/v1 -->
- Auth: <!-- Bearer token in Authorization header / session cookie -->
- Error response format:

```json
{
  "error": "human-readable message",
  "code": "MACHINE_READABLE_CODE",
  "request_id": "uuid"
}
```

- All responses include a `X-Request-ID` header for log correlation
- <!-- Any other API conventions -->

---

## Frontend Conventions

<!-- Describe the frontend structure and conventions. -->

```
web/src/
- components/     # Reusable UI components
- pages/          # Page-level components / route handlers
- api/            # API client functions (one file per resource)
- styles/         # Global styles and theme definitions
- utils/          # Shared utility functions
```

- API calls are centralized in `web/src/api/` - never fetch directly from components
- No inline styles - use <!-- Tailwind classes / CSS modules / stylesheet -->
- <!-- Any other frontend conventions -->

---

## Code Style and Conventions

Behavioral rules are in `.clauderules`. Key reminders for this project:

- ASCII only in code and comments - no emoji, no em-dashes
- Underscores in filenames for backend; frontend may follow its own ecosystem
  conventions (hyphens in component filenames are acceptable if consistent)
- Explain WHY in comments, not WHAT
- Errors must be handled explicitly - no silent failures
- Never log or expose secrets, tokens, or PII
- Conventional commits: `type(scope): description`

### Backend Language Notes

```
<!-- Add project-specific style notes here -->
<!-- Go: errors wrapped with fmt.Errorf("context: %w", err) -->
<!-- Go: context.Context is first argument on all handler and service functions -->
<!-- Python: type hints required on all public functions -->
```

### Frontend Notes

```
<!-- Add project-specific frontend style notes here -->
<!-- Example: components are functional only - no class components -->
<!-- Example: no direct DOM manipulation - always go through the framework -->
```

---

## Changelog and Versioning

- Format: Keep a Changelog (https://keepachangelog.com)
- Versioning: Semantic Versioning (https://semver.org)
- CHANGELOG.md must be updated in the same commit as the change
- Unreleased changes go under `## [Unreleased]`
- Do not create a new version entry - that is the maintainer's decision

---

## Current Focus

See PLANNING.md for active goals, open questions, and pending decisions.

<!-- Optionally note the current sprint or immediate next task here. -->
<!-- Example: Currently working on: user authentication flow. -->
