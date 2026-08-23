# Web Application Rules

## Configuration and Secrets

Web applications are configured exclusively via environment variables. The
`~/.app_name/` convention used by CLI/GUI/Service projects does NOT apply here.

- Local config lives in `.env` (never committed - always in `.gitignore`)
- `.env.example` is committed with all keys present and safe placeholder values
- Never hardcode any secret, key, token, or credential in source files
- Production secrets are managed by the deployment environment - never in the repo
- If a new environment variable is added, add it to `.env.example` too, with a
  descriptive placeholder value and a comment explaining it

## Database and Migrations

- All schema changes are expressed as migration files
- Migration files are never edited after being applied to any environment - create a
  new migration instead
- Never write raw SQL or ORM queries outside the repository/data-access layer
- All queries use parameterized statements - no string interpolation or
  concatenation to build queries

## HTTP and API Conventions

- Handlers/controllers are thin: parse, delegate, respond - no business logic, no
  direct database access
- All API errors return structured JSON with `error`, `code`, and `request_id` fields
- Use appropriate HTTP status codes (see ARCHITECTURE.md); never return a 200 with an
  error body
- All responses include an `X-Request-ID` header for log correlation

## Frontend Conventions

- All API calls centralized in one service/API module - never fetch directly from
  components
- HttpOnly cookies preferred over localStorage/sessionStorage for auth tokens
- Never inline sensitive values in HTML or JavaScript source

## Security Additions (on top of the universal security baseline)

- CSRF protection in place for all state-changing endpoints
- CORS explicitly configured - never a wildcard (`*`) in production
- Security headers applied via middleware - never set per-handler
- Rate limiting applied to all authentication and password-reset endpoints
- Never expose raw database errors, stack traces, or internal paths to clients
- Passwords hashed with bcrypt or argon2 - never plain or weakly hashed (MD5, SHA1)
- File uploads validated for MIME type and size, stored outside the web root or in
  cloud storage - never directly in `public/`

## What Claude Must Not Do in Web Projects

- Must not run database migrations automatically without explicit instruction
- Must not modify `.env` - suggest changes to `.env.example` only
- Must not bypass the repository/data-access layer to query the database directly
- Must not expose a new endpoint without considering auth and rate limiting
- Must not change CORS, CSP, or CSRF configuration without explicit instruction
