# CLAUDE.md - Web Application (C# / ASP.NET Core)

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
| Language        | C# / ASP.NET Core                                 | <!-- Why -->              |
| API style       | <!-- Minimal APIs / MVC Controllers -->          | <!-- Why -->              |
| Database        | <!-- PostgreSQL / SQLite / MySQL -->             | <!-- Why -->              |
| ORM / query     | <!-- Entity Framework Core, Dapper, etc. -->     | <!-- Why -->              |
| Auth            | <!-- JWT, cookie auth, ASP.NET Core Identity, OAuth2 --> | <!-- Why -->      |
| Key dependency  | <!-- name -->                                    | <!-- What it provides --> |

### Frontend

| Component       | Choice                                                  | Reason       |
|-----------------|---------------------------------------------------------|--------------|
| Approach        | <!-- SPA, Razor Pages, Blazor Server, Blazor WASM -->    | <!-- Why --> |
| Framework       | <!-- React, Vue, Blazor, Razor -->                      | <!-- Why --> |
| Build tool      | <!-- Vite, esbuild, none -->                            | <!-- Why --> |
| CSS approach    | <!-- Tailwind, plain CSS, etc. -->                      | <!-- Why --> |

---

## Repository Layout

```
project_name/
- src/
  - AppName.Api/          # Entry point, Controllers or Minimal API endpoints
  - AppName.Application/  # Business logic / services layer
  - AppName.Infrastructure/ # EF Core DbContext, repositories, external clients
  - AppName.Domain/       # Domain entities, value objects
- web/                    # All frontend source (if not using Razor/Blazor)
  - src/                  # Frontend source files (JS/TS/CSS)
  - public/               # Static files served as-is
  - dist/                 # Built frontend output (gitignored)
- tests/
  - AppName.Tests/         # Test project
- migrations/              # EF Core migrations (generated, do not hand-edit)
- scripts/                # Helper, build, and deployment scripts
- .env.example             # Example environment variables (never .env itself)
- AppName.sln
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
# .NET 8 SDK or later
# Node.js 20+ (if using a separate frontend build)
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

# Apply EF Core migrations
dotnet ef database update --project src/AppName.Infrastructure --startup-project src/AppName.Api
```

### Backend

```bash
dotnet run --project src/AppName.Api
```

### Frontend

```bash
# Only applicable if using a separate frontend build (not Razor/Blazor Server)
npm install
npm run dev
npm run build
```

---

## Running Tests

```bash
dotnet test

# With coverage
dotnet test --collect:"XPlat Code Coverage"

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
`appsettings.json` holds only non-secret defaults; secrets and per-environment
overrides always come from environment variables (`appsettings.{Environment}.json`
is not committed with real values).

- `.env` - local development values; never committed
- `.env.example` - committed; all keys present, no real secrets, descriptive placeholders

### Environment Variables

| Variable        | Required | Default     | Description                                    |
|-----------------|----------|-------------|--------------------------------------------------|
| `ConnectionStrings__Default` | Yes | -    | Full database connection string                 |
| `SECRET_KEY`    | Yes      | -           | Secret key for JWT signing / data protection      |
| `ASPNETCORE_URLS` | No     | `http://+:8080` | Address(es) to listen on                     |
| `ASPNETCORE_ENVIRONMENT` | No | `Production` | Development, Staging, Production            |
| `LOG_LEVEL`     | No       | `Information` | Log verbosity                                  |
| <!-- VAR -->    |          |             | <!-- description -->                             |

---

## Database Migrations

```bash
# Add a new migration
dotnet ef migrations add MigrationName --project src/AppName.Infrastructure --startup-project src/AppName.Api

# Apply pending migrations
dotnet ef database update --project src/AppName.Infrastructure --startup-project src/AppName.Api

# Roll back to a specific migration
dotnet ef database update PreviousMigrationName --project src/AppName.Infrastructure --startup-project src/AppName.Api
```

**Never run a destructive migration against production without explicit instruction.**

---

## API Conventions

- Style: <!-- REST / GraphQL / RPC -->
- Base path: <!-- /api/v1 -->
- Auth: <!-- Bearer token / cookie auth -->
- Error response format:

```json
{
  "error": "human-readable message",
  "code": "MACHINE_READABLE_CODE",
  "request_id": "uuid"
}
```

- All responses include a `X-Request-ID` header for log correlation
- Use `ProblemDetails` (RFC 7807) for structured error responses where the framework supports it

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
<!-- Nullable reference types enabled project-wide -->
<!-- Controllers/endpoints are thin; all logic in Application layer services -->
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
