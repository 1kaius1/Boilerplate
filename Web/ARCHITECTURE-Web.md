# Architecture

This document describes the technical architecture of this project. It is a stable
reference - update it when structural changes are made, not for every commit. Claude
Code should read this alongside CLAUDE.md at the start of every session.

---

## Overview

<!-- Two to four sentences. What does this application do at a technical level,
what is the architectural pattern (monolith, API + SPA, SSR, Inertia, etc.),
what stack is in use, and what are the hard constraints it operates under. -->

---

## Application Lifecycle

### Go / Python

```
Start
 |
 v
[Entry Point]
 |
 v
[Config / Env Validation]      <-- fail fast if required env vars are missing
 |
 v
[Database Connection Pool]     <-- establish and verify DB connectivity
 |
 v
[Middleware Stack Init]        <-- logging, auth, CORS, rate limiting, etc.
 |
 v
[Route Registration]           <-- all routes registered before accepting traffic
 |
 v
[Start HTTP Listener]
 |
 v
[Block on Signal]              <-- SIGTERM / SIGINT triggers shutdown
 |
 v
[Graceful Shutdown]            <-- drain in-flight requests, close pool, exit
 |
 v
exit(0)
```

### Laravel

```
Public request hits public/index.php
 |
 v
[Bootstrap / Service Container]  <-- service providers registered and booted
 |
 v
[HTTP Kernel]                    <-- global middleware applied
 |
 v
[Router]                         <-- route matched; route middleware applied
 |
 v
[Form Request Validation]        <-- input validated before controller is called
 |
 v
[Controller]                     <-- thin; delegates to Service immediately
 |
 v
[Service Layer]                  <-- all business logic lives here
 |
 v
[Repository Layer]               <-- all Eloquent / database access lives here
 |
 v
[API Resource / Blade View]      <-- response shaped and returned
 |
 v
HTTP Response
```

### Signal Handling (Go / Python)

| Signal  | Behavior                                                      |
|---------|---------------------------------------------------------------|
| SIGTERM | Graceful shutdown - drain in-flight requests, then exit       |
| SIGINT  | Graceful shutdown - same as SIGTERM                           |

Graceful shutdown drains in-flight requests within <!-- N --> seconds.

---

## Component Breakdown

### Go / Python

#### Entry Point
Reads environment, validates config, initializes subsystems, registers routes, starts
the listener. No business logic - composition root only.

#### Configuration
Reads all config from environment variables. Validates required values at startup,
fails fast on missing or invalid config. No other package reads `os.Environ` directly.

#### Middleware Stack
Ordered chain applied to all or selected routes:

| Middleware     | Purpose                                                   |
|----------------|-----------------------------------------------------------|
| Request ID     | Attaches a unique ID to every request for log correlation |
| Logger         | Logs method, path, status, latency, request ID            |
| Recovery       | Catches panics / unhandled exceptions, returns 500        |
| CORS           | Cross-origin resource sharing headers                     |
| Auth           | Validates session / JWT; populates request context        |
| Rate Limiter   | Per-IP or per-user request rate limiting                  |
| <!-- other --> | <!-- purpose -->                                          |

#### Handler Layer
Routes requests to handlers. Handlers parse and validate input, call the service
layer, and serialize the response. No business logic in handlers.

#### Service Layer
All business logic. Called by handlers; calls repositories for data. Independent of
HTTP - testable without a server.

#### Repository Layer
All database access behind an interface. Each repository owns one domain entity.
No raw SQL outside repositories. Enables mocking in unit tests.

---

### Laravel

#### Service Container and Providers
Laravel's IoC container wires dependencies automatically. Service providers in
`app/Providers/` register bindings, event listeners, and boot services. Do not
put business logic in providers.

#### HTTP Kernel and Middleware (`app/Http/Middleware/`)
Global and route-level middleware. Responsible for: authentication, CORS, rate
limiting, request logging, and session handling. Add new cross-cutting concerns
here, not in controllers.

#### Form Requests (`app/Http/Requests/`)
All input validation lives here - never validate in controllers. Form Requests also
handle authorization checks (`authorize()` method). A controller method that accepts
a Form Request can assume the input is valid and the user is authorized.

#### Controllers (`app/Http/Controllers/`)
Thin. Receive a validated request, call one Service method, return a response via an
API Resource or Blade view. A controller method should rarely exceed ten lines.
No Eloquent queries, no business logic, no conditional branching on domain rules.

#### Service Layer (`app/Services/`)
All business logic. Not a Laravel default directory - always create it. Services are
plain PHP classes injected via the container. They call Repositories for data access
and may dispatch Jobs, send Notifications, or fire Events. Services must not import
`Illuminate\Http` classes - they are HTTP-agnostic.

#### Repository Layer (`app/Repositories/`)
All Eloquent queries. Not a Laravel default directory - always create it. Repositories
accept and return domain data; they do not know about HTTP requests or responses.
Controllers and Services never call Eloquent or `DB::` facades directly.

#### Models (`app/Models/`)
Eloquent models define relationships, casts, fillable/guarded lists, and scopes.
They do not contain business logic. Fat models are an antipattern here - logic belongs
in Services.

#### API Resources (`app/Http/Resources/`)
Shape every API response. Never return a Model or Collection directly from a controller
- always wrap in a Resource. Resources control what fields are exposed and how they
are formatted.

#### Jobs and Queues (`app/Jobs/`)
Deferred and background work dispatched from Services. Queue connection configured
via `QUEUE_CONNECTION` env var. A queue worker must be running for jobs to process:
`php artisan queue:work`.

#### Events and Listeners (`app/Events/`, `app/Listeners/`)
Used for decoupled side effects (send email after registration, log an audit event,
etc.). Prefer over calling secondary Services directly when the caller should not
depend on the side effect completing synchronously.

#### Console Commands (`app/Console/`)
Artisan commands for maintenance tasks, data imports, and scheduled operations.
Scheduled commands registered in `app/Console/Kernel.php` (Laravel 10) or
`routes/console.php` (Laravel 11+).

---

## Request Lifecycle

### Go / Python

```
Client -> Reverse Proxy (TLS termination) -> HTTP Listener
       -> Middleware Chain -> Router -> Handler
       -> Service Layer -> Repository -> Database
       -> (response flows back) -> HTTP Response
```

### Laravel

```
Client -> Web Server (nginx/Apache/Caddy, TLS termination)
       -> public/index.php -> Bootstrap -> HTTP Kernel
       -> Global Middleware -> Router -> Route Middleware
       -> Form Request (validate + authorize)
       -> Controller (delegate immediately)
       -> Service (business logic)
       -> Repository (Eloquent queries)
       -> Database
       -> (response flows back)
       -> API Resource or Blade View -> HTTP Response
```

---

## Authentication and Authorization

<!-- Describe the auth model in use. -->

### Options by Stack

| Stack          | Mechanism                        | Notes                                   |
|----------------|----------------------------------|-----------------------------------------|
| Go / Python    | JWT / session cookie             | Validated in auth middleware            |
| Laravel API    | Laravel Sanctum (token)          | Tokens stored in `personal_access_tokens` table |
| Laravel API    | Laravel Passport (OAuth2)        | For third-party OAuth flows             |
| Laravel SPA    | Laravel Sanctum (cookie)         | SPA auth via HttpOnly session cookie    |
| Laravel Blade  | Laravel session auth             | Standard session + remember-me cookie   |
| Inertia.js     | Laravel Sanctum (cookie)         | Same as Laravel SPA                     |

### Authorization

- Laravel: use Policies (`app/Policies/`) and Gates for authorization checks
- Authorization checked in Form Request `authorize()` or Policy before entering Service
- Never check authorization inside a Service or Repository

---

## Database

- Engine: <!-- PostgreSQL / MySQL / SQLite -->
- Migrations: sequential SQL files (Go/Python) or Laravel migration classes
- Query approach: <!-- sqlc / GORM / SQLAlchemy (Go/Python) or Eloquent via Repositories (Laravel) -->

### Schema Conventions

- Table names: plural snake_case (`users`, `session_tokens`, `password_reset_tokens`)
- Primary keys: `id` - UUID or auto-increment integer (pick one and be consistent)
- Timestamps: `created_at`, `updated_at` on every table
- Foreign keys: explicitly declared with appropriate ON DELETE behavior
- Soft deletes: `deleted_at` nullable timestamp where needed (Laravel: use `SoftDeletes` trait)

### Laravel Migration Conventions

- One migration per logical change - do not bundle unrelated schema changes
- Never edit a migration that has been committed - create a new one
- Data migrations that accompany schema changes go in a separate migration file
- Use `php artisan make:migration` to generate migration stubs with correct naming

---

## Frontend Architecture

### Rendering Strategies

#### API Backend + Separate SPA (Go / Python / Laravel API)
- Backend is a pure JSON API
- Frontend is a separate build (React, Vue, etc.) communicating over HTTP
- Auth via Bearer token (Sanctum token or JWT)
- CORS must be explicitly configured

#### Laravel Full-Stack with Blade
- Server renders complete HTML pages via Blade templates in `resources/views/`
- Vite compiles `resources/css/` and `resources/js/`; output served from `public/build/`
- Session-based auth; CSRF token included in every state-changing form
- Livewire optional for reactive components without writing an SPA

#### Laravel + Inertia.js
- Routes and auth remain server-side (Laravel); rendering is client-side (Vue / React)
- Controllers return `Inertia::render('PageName', $props)` instead of JSON or Blade
- Frontend page components in `resources/js/Pages/`
- Shared global data (auth user, flash messages) passed via `HandleInertiaRequests`
- Vite compiles the frontend; no separate frontend dev server needed for routing

### Asset Pipeline

- Go / Python: source in `web/src/`; output to `web/dist/` (gitignored); served as
  static files by backend or reverse proxy
- Laravel: source in `resources/js/` and `resources/css/`; Vite outputs to
  `public/build/` (gitignored); referenced in Blade via `@vite()` directive

---

## Configuration and Secrets

- All configuration via environment variables - no config files committed with secrets
- `.env` for local development (never committed; always in `.gitignore`)
- `.env.example` committed with all keys and safe placeholder values
- Laravel: config files in `config/` read from `.env` via `env()` - never call
  `env()` outside `config/` files; use `config('key')` everywhere else
- Production config cached via `php artisan config:cache` - `env()` returns null
  after caching unless called in a config file

---

## Laravel Production Optimization

The following Artisan commands must be run as part of every production deployment:

```bash
composer install --no-dev --optimize-autoloader
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache    # Laravel 11+
npm run build              # if using Vite
php artisan migrate --force
php artisan storage:link   # if using local file storage
```

To clear all caches (e.g. after a bad deploy or config change):

```bash
php artisan optimize:clear
```

---

## Logging

- Go / Python: stderr; `text` in development, `json` in production
- Laravel: configured in `config/logging.php`; default channel is `stack`
  - Development: `single` or `daily` file driver
  - Production: `stderr` (for container/systemd capture) or a log aggregator channel
- Every log line within a request includes the request/correlation ID
- Never log: passwords, tokens, full request bodies with sensitive fields, PII

---

## Error Handling

### Go / Python
- Unhandled errors caught by recovery middleware; logged at CRITICAL; return 500
- 4xx logged at INFO; 5xx logged at ERROR with full context
- Raw database errors never exposed to client

### Laravel
- Exception handling in `app/Exceptions/Handler.php`
- `ValidationException` automatically returns 422 with field errors
- `AuthenticationException` returns 401 (API) or redirects to login (web)
- `AuthorizationException` returns 403
- Custom exceptions should extend `HttpException` or be registered in `Handler.php`
- `APP_DEBUG=false` in production - never expose stack traces to clients

### HTTP Status Code Conventions

| Situation                               | Status Code |
|-----------------------------------------|-------------|
| Success (with body)                     | 200         |
| Created                                 | 201         |
| Success (no body)                       | 204         |
| Validation error                        | 400 / 422   |
| Unauthenticated                         | 401         |
| Unauthorized (no permission)            | 403         |
| Not found                               | 404         |
| Conflict (duplicate, constraint)        | 409         |
| Internal server error                   | 500         |

---

## Security Considerations

- All user input validated before use (Form Requests in Laravel; validation layer in Go/Python)
- All queries use parameterized statements / Eloquent bindings - no string interpolation
- CSRF: Laravel includes CSRF protection by default for web routes; verify it is not
  disabled; API routes using Sanctum SPA auth use cookie-based CSRF
- CORS: restricted to known origins; never use wildcard `*` in production
- Security headers applied via middleware for all responses
- Auth endpoints rate-limited
- `APP_DEBUG=false` and `APP_ENV=production` verified in production
- File uploads validated for type, size, and stored outside the web root or in
  cloud storage - never in `public/`
- Mass assignment protected via `$fillable` or `$guarded` on every Eloquent model

---

## Deployment Model

<!-- Describe how this application is deployed. -->

- Packaging: <!-- Docker container / binary / PHP on shared host / PHP-FPM + nginx -->
- Web server: <!-- nginx / Apache / Caddy / Laravel Octane (Swoole / RoadRunner) -->
- TLS: <!-- at reverse proxy / at load balancer -->
- Static files: <!-- reverse proxy / CDN / public/ directory -->
- Database: <!-- managed service / self-hosted -->
- Queue worker: <!-- Supervisor / systemd / cloud worker -->
- Scheduler: <!-- cron calling `php artisan schedule:run` / Laravel Scheduler in Octane -->

See README.md for deployment instructions.

---

## Testing Strategy

### Unit Tests
- Go / Python: service layer with mocked repositories; no real DB or network
- Laravel: `tests/Unit/` - plain PHPUnit tests for Services and helpers; mock
  Repositories with Mockery or PHPUnit mocks; no database, no HTTP

### Feature / Integration Tests
- Go / Python: full request path against a real test database
- Laravel: `tests/Feature/` - drive requests through the full Laravel stack
  (HTTP Kernel, middleware, controller, service, repository) against a test
  database using `RefreshDatabase` or `DatabaseTransactions` trait
- Laravel test database: SQLite in-memory for speed, or a dedicated PostgreSQL/MySQL
  test database matching production engine

### End-to-End Tests
- Drive a real browser against the full running stack
- Tool: <!-- Playwright / Cypress / Laravel Dusk -->
- Cover critical user flows only - not exhaustive UI coverage

### Laravel Testing Conventions
- Use model factories (`database/factories/`) for all test data - never hardcode records
- Use `RefreshDatabase` for tests that write data; `DatabaseTransactions` where faster
- Never make real HTTP calls to external services in tests - use Laravel's `Http::fake()`
- Never send real emails in tests - use `Mail::fake()` and `Notification::fake()`

---

## Audit Log

<!-- Does this application maintain an audit or event log? If so, document
what triggers it, what is recorded, what is explicitly not recorded, how
long records are retained, and whether it is append-only. -->

<!-- Example: -->
<!-- Every state-changing action on a domain object appends a record to the -->
<!-- audit_log table. Records are immutable - never updated or deleted. -->
<!-- -->
<!-- Each record stores: -->
<!-- - actor_id: the user or service account that performed the action -->
<!-- - action: a past-tense verb (e.g. "created", "updated", "deleted") -->
<!-- - object_type and object_id: what was affected -->
<!-- - diff: a JSON patch of changed fields (new value only; old value not stored) -->
<!-- - created_at: server timestamp -->
<!-- -->
<!-- Not recorded: read operations, failed auth attempts (logged but not audited), -->
<!-- internal system jobs. -->
<!-- -->
<!-- Retention: indefinite (no purge policy defined yet - see PLANNING.md). -->

---

## Deployment Topology

<!-- Describe the intended deployment model. Is this single-tenant (one instance
per customer) or multi-tenant (many customers sharing one instance)?
What isolation exists between tenants or users? -->

### Tenancy Model

<!-- Choose one and expand: -->
<!-- Single-tenant: one instance per customer; data isolation is total (separate DB) -->
<!-- Multi-tenant (shared DB): all tenants share one database; rows scoped by tenant_id -->
<!-- Multi-tenant (schema-per-tenant): one schema per tenant in a shared Postgres instance -->
<!-- Hybrid: self-hosted instances are single-tenant; hosted platform is multi-tenant -->

- Model: <!-- single-tenant / multi-tenant shared DB / multi-tenant schema-per-tenant / hybrid -->
- Tenant identifier: <!-- tenant_id column on every table / separate schema / separate database -->
- Data isolation mechanism: <!-- Row Level Security / application-layer scoping / separate DB -->
- Cross-tenant data access: <!-- never permitted / explicitly permitted for these admin roles -->

### Scaling Model

- Horizontal scaling: <!-- supported / not supported - single instance only -->
- Session affinity required: <!-- yes (sticky sessions) / no (stateless) -->
- Shared state between instances: <!-- Redis / database / none -->
- Static assets: <!-- served by reverse proxy / CDN -->

---

## Extension and Integration Points

<!-- What does this application expose beyond its primary user-facing API?
Document webhook outputs, plugin systems, public API contracts, event
streams, and any embedding interface. -->

- Inbound webhooks: <!-- e.g. accepts POST /webhooks/stripe for payment events, or "none" -->
- Outbound webhooks: <!-- e.g. POSTs event payloads to user-configured URLs, or "none" -->
- Public API: <!-- e.g. versioned REST API at /api/v1 documented in docs/api.md, or "internal only" -->
- Event stream: <!-- e.g. SSE at /api/v1/events, or "none" -->
- Plugin / extension mechanism: <!-- e.g. separate extension services communicate via API, or "none" -->
- API spec license: <!-- e.g. API specification published under MIT to allow third-party integrations -->

---

## File-Based Data Formats

<!-- Does this application import or export any file-based data formats
(CSV, JSON export, import files, attachments)? Document them here.
Remove if not applicable. -->

<!-- Example: -->
<!-- ### Data Export (.json) -->
<!-- Users can export their data via GET /api/v1/export. The response is: -->
<!-- ```json -->
<!-- { "version": 1, "exported_at": "ISO8601", "data": {} } -->
<!-- ``` -->
<!-- - `version` is bumped on breaking schema changes -->
<!-- - Exports are self-contained and can be used to seed a fresh instance -->
<!-- -->
<!-- ### Import -->
<!-- Imports accept the same format. Processed asynchronously via background job. -->

---

## Known Limitations

<!-- Honest trade-offs and known weak spots. -->

- <!-- Example: no caching layer - all reads hit the database -->
- <!-- Example: queue worker is a single process - not horizontally scaled yet -->
- <!-- Example: file uploads stored locally - not suitable for multi-server deployment -->

---

## Future Architectural Considerations

<!-- Anticipated but not yet implemented. -->

- <!-- Example: Redis cache layer for high-read endpoints -->
- <!-- Example: CDN for static assets before public launch -->
- <!-- Example: Laravel Octane for improved throughput if needed -->
