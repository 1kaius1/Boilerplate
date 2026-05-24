# Web Application Addendum
#
# Append this section to the base .clauderules for web application projects.
# It overrides or extends rules that do not apply to web apps, and adds
# web-specific rules that the base file does not cover.

## Configuration and Secrets (Web Override)

- Web applications are configured exclusively via environment variables
- The ~/.app_name/ home directory convention does NOT apply to web applications
- Local config lives in .env (never committed - always in .gitignore)
- .env.example is committed with all keys present and safe placeholder values
- Never hardcode any secret, key, token, or credential in source files
- Production secrets are managed by the deployment environment - never in the repo
- If a new environment variable is added, it must also be added to .env.example
  with a descriptive placeholder value and a comment explaining it

## Database and Migrations

- All schema changes must be expressed as migration files
- Migration files are never edited after being applied to any environment -
  create a new migration instead
- Never write raw SQL strings outside the repository layer (Go/Python) or
  outside Eloquent Repository classes (Laravel)
- All queries must use parameterized statements - no string interpolation or
  concatenation to build queries
- The repository layer is the only place that accesses the database directly

## Laravel Configuration Rules

- Never call env() outside of config/ files - use config('key') everywhere else
- After any .env or config change in development, run: php artisan config:clear
- In production, config is cached - env() returns null outside config files after
  php artisan config:cache has been run
- Never commit a .env file; never commit a config file containing real secrets

## Laravel Architecture Rules

- Controllers must be thin: parse input (via Form Request), call one Service
  method, return a response - nothing else
- No business logic in Controllers, Models, Middleware, Providers, or Observers
- No Eloquent queries or DB:: facade calls outside of Repository classes
- All input validation must live in Form Request classes (app/Http/Requests/)
  not in controllers, services, or models
- All API responses must be shaped by API Resource classes (app/Http/Resources/)
  never return a Model or Collection directly from a controller
- Authorization checks belong in Form Request authorize() methods or Policies -
  not in Services or Repositories
- Mass assignment must be explicitly controlled on every Model via $fillable or
  $guarded - never use Model::unguard()
- Every Eloquent Model must define $fillable or $guarded explicitly

## Laravel Testing Rules

- Use model factories for all test data - never insert hardcode records manually
- Use RefreshDatabase or DatabaseTransactions trait in all tests that write data
- Use Mail::fake(), Notification::fake(), Event::fake(), Http::fake() in tests -
  never send real emails, notifications, events, or HTTP requests from tests
- Never use the production database in tests - always a separate test database
  or SQLite in-memory

## Laravel Deployment Rules

- Never run php artisan migrate:fresh or migrate:rollback in production without
  explicit instruction - these are destructive operations
- Never run php artisan db:seed in production unless the seeder is explicitly
  designated as a production-safe seeder
- Always run the full production optimization sequence on deploy:
  composer install --no-dev --optimize-autoloader
  php artisan config:cache
  php artisan route:cache
  php artisan view:cache
  php artisan migrate --force
- Never run php artisan optimize:clear in production without explicit instruction
  as it invalidates all caches and will degrade performance until they rebuild

## Security (Web Additions)

- Validate and sanitize all user input before use - never trust request data
- CSRF protection must be in place for all state-changing endpoints
  (Laravel provides this by default for web routes - do not disable it)
- CORS must be explicitly configured - never use wildcard (*) in production
- Security headers applied via middleware - never set them per-handler
- Rate limiting applied to all authentication and password reset endpoints
- Never expose raw database errors, stack traces, or internal paths to clients
- Never log full request bodies that may contain passwords, tokens, or PII
- Passwords must be hashed with bcrypt or argon2 - never store plain or with
  weak hashing (MD5, SHA1)
- File uploads must be validated for MIME type and size, and stored outside the
  web root or in cloud storage - never directly in public/

## HTTP and API Conventions

- Handlers / controllers must be thin: parse, delegate, respond
- No business logic in handlers or controllers
- No database access in handlers or controllers
- All API errors return structured JSON with error, code, and request_id fields
- Use appropriate HTTP status codes (see ARCHITECTURE.md)
- All responses must include X-Request-ID header for log correlation
- Never return a 200 with an error body

## Frontend Conventions

- All API calls centralized in the api/ module (Go/Python) or a dedicated
  service layer (Laravel Inertia/SPA) - never fetch directly from components
- Never store secrets, tokens, or sensitive data in localStorage or
  sessionStorage unless there is no alternative and the risk is documented
- HttpOnly cookies preferred over localStorage for auth tokens
- Never inline sensitive values in HTML or JavaScript source

## File Naming (Web Additions)

- Backend files: underscores (Go/Python); PSR-4 PascalCase for PHP classes
- Laravel class files follow PSR-4 naming exactly - filename must match class name
- Migration files: Laravel generated names (YYYY_MM_DD_HHMMSS_description.php)
  or NNN_snake_case.sql for Go/Python projects
- Frontend files: follow the existing convention in the project
- Never mix naming conventions within the same layer

## What Claude Must Not Do in Web Projects

- Must not run database migrations automatically without explicit instruction
- Must not run migrate:fresh, migrate:rollback, or db:seed without explicit
  instruction - these are potentially destructive
- Must not modify .env - suggest changes to .env.example only
- Must not add a new dependency (npm, Composer, or backend) without discussion
- Must not bypass the repository layer to query the database directly
- Must not put business logic in a Laravel Controller, Model, or Middleware
- Must not call env() outside of Laravel config/ files
- Must not add inline styles or hardcoded colors to frontend code
- Must not expose a new endpoint without considering auth and rate limiting
- Must not change CORS, CSP, or CSRF configuration without explicit instruction
- Must not use dd(), dump(), var_dump(), or ray() in committed PHP code
