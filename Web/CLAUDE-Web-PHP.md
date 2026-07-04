# CLAUDE.md - Web Application (PHP / Laravel)

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

| Component       | Choice                                           | Reason                    |
|-----------------|--------------------------------------------------|---------------------------|
| Language        | PHP                                               | <!-- Why -->              |
| Framework       | Laravel                                           | <!-- Why -->              |
| Database        | <!-- PostgreSQL / SQLite / MySQL -->             | <!-- Why -->              |
| ORM / query     | Eloquent (via Repositories)                       | <!-- Why -->              |
| Auth            | <!-- Laravel Sanctum / Laravel Passport -->      | <!-- Why -->              |
| Key dependency  | <!-- name -->                                    | <!-- What it provides --> |

### Frontend

| Component       | Choice                                                  | Reason       |
|-----------------|---------------------------------------------------------|--------------|
| Approach        | <!-- Blade, Inertia.js, API-only -->                    | <!-- Why --> |
| Framework       | <!-- Blade templates, Vue, React -->                    | <!-- Why --> |
| Build tool      | Vite                                                     | <!-- Why --> |
| CSS approach    | <!-- Tailwind, plain CSS, etc. -->                      | <!-- Why --> |

---

## Repository Layout

```
project_name/
- app/
  - Console/            # Artisan commands
  - Exceptions/         # Exception handler
  - Http/
    - Controllers/      # Thin controllers - no business logic
    - Middleware/        # HTTP middleware
    - Requests/         # Form request validation classes
    - Resources/        # API resource transformers
  - Models/             # Eloquent models
  - Providers/          # Service providers
  - Services/           # Business logic layer (not a Laravel default - always create this)
  - Repositories/       # Data access layer (always use; never query Eloquent in controllers)
- bootstrap/            # Framework bootstrap files (do not edit)
- config/               # Application config files
- database/
  - factories/          # Model factories for testing
  - migrations/         # Laravel migration files
  - seeders/            # Database seeders
- public/               # Web server document root (index.php, compiled assets)
- resources/
  - css/                # Source CSS
  - js/                 # Source JS (compiled by Vite)
  - views/              # Blade templates (full-stack only)
- routes/
  - api.php             # API routes
  - web.php             # Web/Blade routes (full-stack only)
  - console.php         # Artisan route closures
- storage/              # Logs, cache, uploaded files (gitignored except for .gitkeep)
- tests/
  - Feature/            # Feature/integration tests
  - Unit/               # Unit tests
- .env.example          # Example environment variables (never .env itself)
- .clauderules
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
# PHP 8.2+
# Composer 2.x
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
# Create the database first if using PostgreSQL or MySQL:
# createdb app_name_dev  (PostgreSQL)
# mysql -e "CREATE DATABASE app_name_dev;"  (MySQL)

php artisan key:generate
php artisan migrate

# Seed development data (if seeders exist)
php artisan db:seed
```

### Backend

```bash
php artisan serve
# Default: http://localhost:8000
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

### Laravel-Specific Development Commands

```bash
# List all available Artisan commands
php artisan list

# Clear all caches (run after config or route changes)
php artisan optimize:clear

# Run queue worker (required if the app dispatches jobs)
php artisan queue:work

# Run the scheduler locally (required if scheduled tasks are defined)
php artisan schedule:work

# Open a REPL (Tinker)
php artisan tinker

# Generate a new controller / model / migration / etc.
php artisan make:controller ExampleController
php artisan make:model Example --migration
php artisan make:request StoreExampleRequest
php artisan make:resource ExampleResource
php artisan make:service ExampleService   # requires a custom stub or manual creation
```

---

## Running Tests

```bash
php artisan test
# or
./vendor/bin/phpunit

# Specific test suite
php artisan test --testsuite=Unit
php artisan test --testsuite=Feature

# With coverage (requires Xdebug or PCOV)
php artisan test --coverage

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

### Laravel Configuration Notes

- Laravel's config files in `config/` read from `.env` via the `env()` helper
- Never call `env()` outside of `config/` files - use `config('key')` everywhere else
- After any change to `.env` or config files in development, run:
  `php artisan config:clear`
- In production, config is cached: `php artisan config:cache` - never call `env()`
  in code that runs after this point, as it will return null

### Environment Variables

| Variable        | Required | Default     | Description                                    |
|-----------------|----------|-------------|-------------------------------------------------|
| `APP_KEY`       | Yes      | -           | Laravel application key - generate with `php artisan key:generate` |
| `APP_ENV`       | Yes      | `local`     | Environment: local, staging, production          |
| `APP_DEBUG`     | No       | `false`     | Debug mode - never true in production            |
| `APP_URL`       | Yes      | -           | Full base URL of the application                 |
| `DB_CONNECTION` | Yes      | `mysql`     | Database driver: mysql, pgsql, sqlite            |
| `DB_HOST`       | Yes      | `127.0.0.1` | Database host                                    |
| `DB_PORT`       | Yes      | `3306`      | Database port                                    |
| `DB_DATABASE`   | Yes      | -           | Database name                                    |
| `DB_USERNAME`   | Yes      | -           | Database user                                    |
| `DB_PASSWORD`   | Yes      | -           | Database password                                |
| `LOG_LEVEL`     | No       | `info`      | Log verbosity                                    |
| <!-- VAR -->    |          |             | <!-- description -->                             |

---

## Database Migrations

```bash
# Apply pending migrations
php artisan migrate

# Check migration status
php artisan migrate:status

# Roll back the last batch
php artisan migrate:rollback

# Roll back all migrations and re-run (development only - destroys data)
php artisan migrate:fresh

# Roll back, re-run, and re-seed (development only)
php artisan migrate:fresh --seed
```

**Never run `migrate:fresh` or `migrate:rollback` in production without explicit
instruction. Never run seeders in production unless they are designated safe
production seeders.**

---

## API Conventions

- Style: <!-- REST / GraphQL / RPC -->
- Base path: `/api/v1` (defined in `routes/api.php`)
- Auth: <!-- Bearer token / Laravel Sanctum / Laravel Passport -->
- Error response format:

```json
{
  "error": "human-readable message",
  "code": "MACHINE_READABLE_CODE",
  "request_id": "uuid"
}
```

- All responses include a `X-Request-ID` header for log correlation
- Laravel API Resources (`app/Http/Resources/`) are used for all response shaping -
  never return Eloquent models directly from controllers

---

## Laravel Usage Modes

### API Backend Only

- Routes defined in `routes/api.php` only
- All responses via API Resources (`app/Http/Resources/`)
- Auth via Laravel Sanctum (token-based) or Passport (OAuth2)
- No Blade templates; `resources/views/` unused
- CORS configured via `config/cors.php`

### Full-Stack with Blade

- Web routes in `routes/web.php`; API routes in `routes/api.php`
- Views in `resources/views/` as `.blade.php` files
- Auth via Laravel's session-based auth (Sanctum with SPA or Breeze/Jetstream scaffold)
- Vite compiles `resources/css/` and `resources/js/` into `public/build/`

### Inertia.js (Vue / React)

- Web routes in `routes/web.php` return Inertia responses
- Frontend components in `resources/js/Pages/`
- Shared data passed via Inertia's `share()` in `HandleInertiaRequests` middleware
- Auth via Laravel Sanctum with SPA cookie authentication
- Vite compiles the frontend; no separate dev server routing needed

---

## Frontend Conventions

```
resources/js/
- components/     # Reusable UI components
- pages/          # Page-level components / route handlers
- styles/         # Global styles and theme definitions
- utils/          # Shared utility functions
```

- No inline styles - use Tailwind classes / CSS modules / stylesheet
- <!-- Any other project-specific frontend conventions -->

---

## Code Style and Conventions

Behavioral rules are in `.clauderules`. Key reminders:

- ASCII only in code and comments - no emoji, no em-dashes
- Explain WHY in comments, not WHAT
- Errors handled explicitly - no silent failures
- Conventional commits: `type(scope): description`

### PHP / Laravel Specific

- PSR-12 coding standard enforced via Laravel Pint: `./vendor/bin/pint`
- Type hints required on all method signatures (PHP 8.x named arguments encouraged)
- Controllers are thin - delegate immediately to a Service class
- No business logic in Models, Controllers, or Middleware
- No direct Eloquent queries outside of Repository classes
- Validation always in Form Request classes (`app/Http/Requests/`) - never in controllers
- Never use `dd()`, `dump()`, `var_dump()`, or `ray()` in committed code

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
