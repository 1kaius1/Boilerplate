---
paths:
  - "**/*.php"
---

# PHP / Laravel-Specific Rules

PHP in this boilerplate always means Laravel - these rules are self-contained and do
not require a separate framework addendum.

## Style and Naming

- PSR-12 coding standard enforced via Laravel Pint: `./vendor/bin/pint`
- Type hints required on all method signatures (PHP 8.x named arguments encouraged)
- Laravel class files follow PSR-4 naming exactly - filename must match class name
- Migration files use Laravel's generated name: `YYYY_MM_DD_HHMMSS_description.php`
- License header: `// SPDX-License-Identifier: AGPL-3.0-or-later`
- Document new dependencies in `composer.json` (or `package.json` for frontend)

## Configuration

- Never call `env()` outside of `config/` files - use `config('key')` everywhere else
- After any `.env` or config change in development, run: `php artisan config:clear`
- In production, config is cached (`php artisan config:cache`) - `env()` returns null
  outside config files after that point

## Architecture

- Controllers must be thin: parse input (via Form Request), call one Service method,
  return a response - nothing else
- No business logic in Controllers, Models, Middleware, Providers, or Observers
- No Eloquent queries or `DB::` facade calls outside of Repository classes
- All input validation lives in Form Request classes (`app/Http/Requests/`)
- All API responses are shaped by API Resource classes (`app/Http/Resources/`) -
  never return a Model or Collection directly from a controller
- Authorization checks belong in Form Request `authorize()` methods or Policies
- Every Eloquent Model must define `$fillable` or `$guarded` explicitly - never use
  `Model::unguard()`
- Never use `dd()`, `dump()`, `var_dump()`, or `ray()` in committed code

## Testing

- Use model factories (`database/factories/`) for all test data
- Use `RefreshDatabase` or `DatabaseTransactions` in all tests that write data
- Use `Mail::fake()`, `Notification::fake()`, `Event::fake()`, `Http::fake()` - never
  send real emails, notifications, events, or HTTP requests from tests
- Never use the production database in tests - a separate test database or SQLite
  in-memory only

## Deployment

- Never run `migrate:fresh`, `migrate:rollback`, or `db:seed` in production without
  explicit instruction
- Production optimization sequence on deploy: `composer install --no-dev
  --optimize-autoloader`, `php artisan config:cache`, `php artisan route:cache`,
  `php artisan view:cache`, `php artisan migrate --force`
- Never run `php artisan optimize:clear` in production without explicit instruction -
  it invalidates all caches and degrades performance until they rebuild

## Security Additions

- CSRF protection is on by default for web routes - do not disable it
- `APP_DEBUG=false` and `APP_ENV=production` verified in production
- Mass assignment protected via `$fillable` or `$guarded` on every Eloquent model
