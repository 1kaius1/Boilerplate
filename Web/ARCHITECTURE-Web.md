# Architecture

This document describes the technical architecture of this project. It is a stable
reference - update it when structural changes are made, not for every commit. Claude
Code should read this alongside CLAUDE.md at the start of every session.

---

## Overview

<!-- Two to four sentences. What does this application do at a technical level,
what is the architectural pattern (monolith, API + SPA, SSR, etc.), and what are
the hard constraints it operates under (latency, scale, consistency, etc.). -->

---

## Application Lifecycle

```
Start
 |
 v
[Entry Point]
 |
 v
[Config / Env Validation]    <-- fail fast if required env vars are missing
 |
 v
[Database Connection Pool]   <-- establish and verify DB connectivity
 |
 v
[Run Migrations]             <-- optional at startup; see ops conventions below
 |
 v
[Middleware Stack Init]      <-- logging, auth, CORS, rate limiting, etc.
 |
 v
[Route Registration]         <-- all routes registered before accepting traffic
 |
 v
[Start HTTP Listener]        <-- begin serving requests
 |
 v
[Block on Signal]            <-- SIGTERM / SIGINT triggers shutdown
 |
 v
[Graceful Shutdown]          <-- drain in-flight requests, close DB pool, exit
 |
 v
exit(0)
```

### Signal Handling

| Signal  | Behavior                                                      |
|---------|---------------------------------------------------------------|
| SIGTERM | Graceful shutdown - drain in-flight requests, then exit       |
| SIGINT  | Graceful shutdown - same as SIGTERM                           |

Graceful shutdown drains in-flight requests within <!-- N --> seconds before the
process exits. The load balancer or reverse proxy should be configured to stop
sending new requests before SIGTERM is sent.

---

## Component Breakdown

### Entry Point (`cmd/app_name` or `app_name/main.py`)

Reads environment variables, validates required config, initializes subsystems in
dependency order, registers routes, and starts the listener. Contains no business
logic - it is the composition root.

### Configuration (`internal/config` or `src/config.py`)

Reads all configuration from environment variables. Validates required values at
startup and fails fast with a clear error message if any are missing or invalid.
Exposes a single typed config struct/object - never reads `os.Environ` outside
this package.

### Middleware Stack (`internal/middleware` or `src/middleware/`)

Ordered chain of middleware applied to all or selected routes:

| Middleware        | Purpose                                              |
|-------------------|------------------------------------------------------|
| Request ID        | Attaches a unique ID to every request for log correlation |
| Logger            | Logs method, path, status, latency, request ID       |
| Recovery          | Catches panics / unhandled exceptions, returns 500   |
| CORS              | Cross-origin resource sharing headers                |
| Auth              | Validates session / JWT; populates request context   |
| Rate Limiter      | Per-IP or per-user request rate limiting             |
| <!-- other -->    | <!-- purpose -->                                     |

### Router and Handlers (`internal/handler` or `src/routers/`)

Routes incoming HTTP requests to the correct handler. Handlers are thin: they
parse and validate the request, call into the service layer, and serialize the
response. They contain no business logic.

### Service Layer (`internal/service` or `src/services/`)

Contains all business logic. Services are called by handlers and call into the
repository layer for persistence. Services are independent of HTTP - they can be
called from handlers, background workers, or tests without an HTTP context.

### Repository / Data Access Layer (`internal/repository` or `src/repositories/`)

Abstracts all database access behind an interface. Each repository owns one
domain entity. Business logic never constructs raw SQL - all queries go through
a repository. Enables test doubles (mocks) for unit testing the service layer.

### Database (`internal/db` or `src/db/`)

Manages the connection pool and migration state. Exposes a connection/pool
object to the repository layer. Does not expose raw connections outside this
package.

### Frontend (`web/`)

<!-- Describe the frontend architecture. Examples below - keep what applies. -->

- <!-- SPA (React/Vue): built separately, served as static files from web/dist/ -->
- <!-- SSR: templates in templates/, rendered server-side per request -->
- <!-- HTMX: HTML fragments returned from dedicated endpoints -->
- <!-- MPA: full page HTML responses, minimal JS -->

### Background Workers (`internal/worker` or `src/workers/`)

<!-- Does this application have background jobs? Describe them here, or remove
this section if not applicable. -->

- <!-- Example: email sender worker - processes send_email jobs from a queue -->
- <!-- Example: no background workers - all work is synchronous and request-scoped -->

---

## Request Lifecycle

```
Client Request
 |
 v
[Reverse Proxy / Load Balancer]   <-- TLS termination, static file serving
 |
 v
[HTTP Listener]
 |
 v
[Middleware Chain]                <-- request ID, logging, recovery, auth
 |
 v
[Router]                          <-- matches path and method to handler
 |
 v
[Handler]                         <-- parse request, validate input
 |
 v
[Service Layer]                   <-- business logic
 |
 v
[Repository Layer]                <-- database read/write
 |
 v
[Database]
 |
 (result flows back up the chain)
 |
 v
[Handler]                         <-- serialize response
 |
 v
HTTP Response to Client
```

---

## Authentication and Authorization

<!-- Describe the auth model. -->

- Mechanism: <!-- JWT / session cookie / API key / OAuth2 -->
- Token storage: <!-- HttpOnly cookie / Authorization header / localStorage -->
- Session store: <!-- in-memory / database / Redis -->
- Auth check performed in: <!-- middleware (all routes) / per-handler -->
- Authorization model: <!-- RBAC / ABAC / simple owner check / none -->

### Auth Flow

```
<!-- Describe the login / token issuance flow -->
<!-- Example (JWT): -->
<!-- POST /api/v1/auth/login -->
<!--   -> validate credentials against database -->
<!--   -> issue signed JWT with claims { user_id, roles, exp } -->
<!--   -> return token in response body -->
<!--   -> subsequent requests: Authorization: Bearer <token> -->
<!--   -> auth middleware validates signature and expiry on every request -->
```

---

## Data Flow

```
Inbound:
- HTTP requests from browser / API clients
- <!-- webhook callbacks (if applicable) -->

Processing:
- Request -> middleware -> handler -> service -> repository -> database

Outbound:
- HTTP responses (JSON / HTML)
- <!-- emails, push notifications (if applicable) -->
- <!-- events published to queue (if applicable) -->
- Logs: stderr (development) / structured JSON (production)
```

---

## Database

- Engine: <!-- PostgreSQL / SQLite / MySQL -->
- Connection: `DATABASE_URL` environment variable
- Connection pool: <!-- min N, max N connections -->
- Migrations: sequential numbered SQL files in `migrations/`
- Query approach: <!-- raw SQL via sqlc / GORM / SQLAlchemy / psycopg2 -->

### Schema Conventions

- Table names: plural snake_case (`users`, `session_tokens`)
- Primary keys: `id` (UUID or serial integer - pick one and be consistent)
- Timestamps: `created_at`, `updated_at` on every table (set by database)
- Soft deletes: <!-- `deleted_at` nullable timestamp / hard deletes only -->
- Foreign keys: explicitly declared with appropriate ON DELETE behavior

### Migration Conventions

- Files: `migrations/NNN_description.sql` (e.g. `001_create_users.sql`)
- Every migration has an up and a down section
- Never edit a migration that has been applied to any environment
- Schema changes that require data migration are split into separate files

---

## Frontend Architecture

<!-- Expand on the frontend approach chosen for this project. -->

### Rendering Strategy

<!-- Choose one and expand: -->
<!-- SPA: all rendering client-side; backend is pure API -->
<!-- SSR: pages rendered server-side; JS hydrates on the client -->
<!-- MPA: server renders full pages; minimal or no client-side JS -->
<!-- HTMX: server renders HTML fragments; HTMX swaps them in -->

### State Management

<!-- How is application state managed on the frontend? -->
<!-- Example: React Context for auth state; local component state for everything else -->
<!-- Example: no client-side state - server is the source of truth -->

### API Communication

- All API calls centralized in `web/src/api/`
- One module per backend resource (e.g. `api/users.js`, `api/posts.js`)
- Never fetch directly from components or pages
- Auth token attached automatically by the API client module

### Asset Pipeline

- Source: `web/src/`
- Build output: `web/dist/` (gitignored)
- Build tool: <!-- Vite / esbuild / none -->
- Backend serves `web/dist/` as static files in production
- In development: frontend dev server proxies API calls to backend

---

## Configuration and Secrets

- All configuration via environment variables - no config files
- `.env` for local development (never committed)
- `.env.example` committed with all keys and safe placeholder values
- Secrets (DATABASE_URL, SECRET_KEY, etc.) never hardcoded or logged
- Production secrets managed by <!-- deployment platform / Vault / secrets manager -->

---

## Logging

- All log output to stderr
- Development: `text` format (human-readable)
- Production: `json` format (structured, for log aggregators)
- Every log line within a request includes the `request_id`
- Log levels: DEBUG, INFO, WARNING, ERROR, CRITICAL
- Never log: passwords, tokens, full request bodies containing sensitive fields, PII

---

## Error Handling Strategy

- Handler-level errors return structured JSON with `error`, `code`, and `request_id`
- 4xx errors: client errors (bad input, unauthorized, not found) - logged at INFO
- 5xx errors: server errors - logged at ERROR with full context
- Unhandled panics (Go) / exceptions (Python) caught by recovery middleware,
  logged at CRITICAL, return 500 to client
- Database errors are never exposed directly to the client

### HTTP Status Code Conventions

| Situation                          | Status Code |
|------------------------------------|-------------|
| Success (with body)                | 200         |
| Created                            | 201         |
| Success (no body)                  | 204         |
| Validation error                   | 400         |
| Unauthenticated                    | 401         |
| Unauthorized (authenticated but no permission) | 403 |
| Not found                          | 404         |
| Conflict (duplicate, constraint)   | 409         |
| Internal server error              | 500         |

---

## Security Considerations

- All user input validated and sanitized before use
- All database queries use parameterized statements - no string interpolation
- CSRF protection: <!-- SameSite cookie / CSRF token / stateless JWT (no CSRF needed) -->
- CORS: restricted to known origins via `ALLOWED_HOSTS`
- Security headers set on all responses: <!-- list headers or reference middleware -->
- Sensitive routes rate-limited (auth endpoints especially)
- Dependency versions pinned and audited regularly

---

## Deployment Model

<!-- Describe how this application is deployed. -->

- Packaging: <!-- Docker container / binary / Python package -->
- Reverse proxy: <!-- nginx / caddy / cloud load balancer -->
- TLS termination: <!-- at reverse proxy / at load balancer -->
- Static files: <!-- served by reverse proxy / CDN / backend -->
- Database: <!-- managed service / self-hosted -->
- Migrations: <!-- run manually before deploy / run automatically at startup -->

See README.md for deployment instructions.

---

## Testing Strategy

### Unit Tests

- Service layer tested in isolation with mocked repositories
- Repository layer tested against a real test database (separate from dev DB)
- Handlers tested with an HTTP test client - no real network calls

### Integration Tests

- Start a real instance against a test database
- Exercise full request -> handler -> service -> database path
- Require: running database (and any other external dependencies)

### End-to-End Tests

- Drive a real browser against the full running stack
- Tool: <!-- Playwright / Cypress -->
- Cover critical user flows only - not exhaustive UI coverage
- Run in CI against a staging-like environment

---

## Known Limitations

<!-- Honest trade-offs and known weak spots. -->

- <!-- Example: no caching layer - all reads hit the database -->
- <!-- Example: session store is in-memory - sessions lost on restart -->
- <!-- Example: migrations run at startup - requires careful deploy ordering -->

---

## Future Architectural Considerations

<!-- Anticipated but not yet implemented changes. -->

- <!-- Example: Redis cache layer for high-read endpoints planned for v0.4.0 -->
- <!-- Example: background job queue (pgqueue / Redis) needed before email feature -->
- <!-- Example: CDN for static assets before public launch -->
