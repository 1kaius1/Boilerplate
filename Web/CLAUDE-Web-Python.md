# CLAUDE.md - Web Application (Python)

This file provides project context and conventions for AI-assisted development sessions.
Read this file and ARCHITECTURE.md before making any changes. Behavioral rules and
guardrails are auto-loaded from `.claude/rules/` - there is nothing else to open.

---

## Project Overview

<!-- One paragraph. What does this application do, what problem does it solve,
who uses it, and what is the rough scale it is designed for. -->

---

## Tech Stack

### Backend

| Component       | Choice                                           | Reason                    |
|-----------------|--------------------------------------------------|---------------------------|
| Language        | Python                                            | <!-- Why -->              |
| Framework       | <!-- FastAPI, Flask, Django, etc. -->            | <!-- Why -->              |
| Database        | <!-- PostgreSQL / SQLite / MySQL -->             | <!-- Why -->              |
| ORM / query     | <!-- SQLAlchemy, Django ORM, etc. -->            | <!-- Why -->              |
| Auth            | <!-- JWT, session, OAuth2 -->                    | <!-- Why -->              |
| Key dependency  | <!-- name -->                                    | <!-- What it provides --> |

### Frontend

| Component       | Choice                                                  | Reason       |
|-----------------|---------------------------------------------------------|--------------|
| Approach        | <!-- SPA, SSR, MPA, HTMX -->                             | <!-- Why --> |
| Framework       | <!-- React, Vue, HTMX, etc. -->                         | <!-- Why --> |
| Build tool      | <!-- Vite, esbuild, none -->                            | <!-- Why --> |
| CSS approach    | <!-- Tailwind, plain CSS, etc. -->                      | <!-- Why --> |

---

## Repository Layout

```
project_name/
- src/                  # Backend source modules
- web/                  # All frontend source
  - src/                # Frontend source files (JS/TS/CSS)
  - public/             # Static files served as-is
  - dist/               # Built frontend output (gitignored)
- templates/            # Server-side HTML templates (if applicable)
- migrations/           # Database migration files (numbered, sequential)
- scripts/              # Helper, build, and deployment scripts
- tests/                # Test suite
- .env.example          # Example environment variables (never .env itself)
- .claude/              # Auto-loaded rules (.claude/rules/) and settings.json
- ARCHITECTURE.md
- CHANGELOG.md
- CLAUDE.md
- CONTRIBUTING.md
- PLANNING.md
- README.md
- LICENSE
```

<!-- Annotate any non-obvious directories specific to this project. -->

---

## Build and Run

### Prerequisites

```bash
# Python 3.11+, pip
# Node.js 20+ (for Vite asset compilation)
# A supported database: PostgreSQL, MySQL, or SQLite
```

### Environment Setup

```bash
cp .env.example .env
# Edit .env and fill in required values - never commit .env
```

### Database Setup

```bash
createdb app_name_dev

# Run migrations
alembic upgrade head
```

### Backend

```bash
# FastAPI / Starlette
uvicorn app_name.main:app --reload

# Flask
flask run
```

### Frontend

```bash
# Install dependencies
npm install

# Development server with hot reload
npm run dev

# Production build
npm run build
```

---

## Running Tests

```bash
pytest tests/unit/
pytest tests/integration/

# Frontend
npm run test

# End-to-end (full stack required)
npm run test:e2e
```

All tests must pass before committing or opening a pull request. Never suggest a PR
with failing tests. If tests cannot be run, say so explicitly.

---

## Configuration and Environment Variables

Web applications are configured exclusively via environment variables and the `.env`
file. The `~/.app_name/` home directory convention does not apply here.

- `.env` - local development values; never committed
- `.env.example` - committed; all keys present, no real secrets, descriptive placeholders

### Environment Variables

| Variable        | Required | Default     | Description                                    |
|-----------------|----------|-------------|------------------------------------------------|
| `DATABASE_URL`  | Yes      | -           | Full database connection string                |
| `SECRET_KEY`    | Yes      | -           | Secret key for sessions / JWT signing           |
| `PORT`          | No       | `8080`      | Port to listen on                               |
| `ALLOWED_HOSTS` | No       | -           | Comma-separated allowed hostnames               |
| `DEBUG`         | No       | `false`     | Debug mode - never true in production           |
| `LOG_LEVEL`     | No       | `info`      | Log verbosity                                   |
| <!-- VAR -->    |          |             | <!-- description -->                            |

---

## Database Migrations

```bash
alembic upgrade head
alembic current
alembic downgrade -1
```

**Never run a destructive migration against production without explicit instruction.**

---

## API Conventions

- Style: <!-- REST / GraphQL / RPC -->
- Base path: <!-- /api/v1 -->
- Auth: <!-- Bearer token / session cookie -->
- Error response format:

```json
{
  "error": "human-readable message",
  "code": "MACHINE_READABLE_CODE",
  "request_id": "uuid"
}
```

- All responses include a `X-Request-ID` header for log correlation

---

## Frontend Conventions

```
web/src/
- components/     # Reusable UI components
- pages/          # Page-level components / route handlers
- api/            # API client functions - one file per resource
- styles/         # Global styles and theme definitions
- utils/          # Shared utility functions
```

- API calls centralized in `api/` - never fetch from components directly
- No inline styles - use Tailwind classes / CSS modules / stylesheet
- <!-- Any other project-specific frontend conventions -->

---

## Code Style and Conventions

Behavioral rules and guardrails are auto-loaded from `.claude/rules/` - see
`universal.md` plus the language and type rule files that apply to this project.

### Language-Specific Notes

```
<!-- Add project-specific style notes here -->
<!-- Example: -->
<!-- Type hints required on all public functions -->
```

---

## Changelog and Versioning

- Format: Keep a Changelog (https://keepachangelog.com)
- Versioning: Semantic Versioning (https://semver.org)
- CHANGELOG.md updated in the same commit as the change
- Unreleased changes go under `## [Unreleased]`
- Do not create a new version entry - that is the maintainer's decision

---

## Current Focus

See PLANNING.md for active goals, open questions, and pending decisions.

<!-- Example: Currently working on: user authentication flow. -->
