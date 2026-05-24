# app_name

<!-- One sentence. What does this application do and why would someone want it. -->

<!-- Badges - replace URLs with real ones -->
![Version](https://img.shields.io/github/v/release/OWNER/REPO)
![License](https://img.shields.io/badge/license-AGPL--3.0--or--later-blue)
![Build](https://img.shields.io/github/actions/workflow/status/OWNER/REPO/ci.yml)

---

## Overview

<!-- Two to four sentences expanding on the one-liner above. What problem does
this application solve, who is it for, and what makes it worth deploying. -->

---

<!-- Screenshot or demo placeholder - replace before first release -->
<!--
![Screenshot](docs/screenshot.png)
-->

## Features

- <!-- feature -->
- <!-- feature -->
- <!-- feature -->

---

## Requirements

- <!-- Go 1.22+ / Python 3.11+ -->
- Node.js 20+ (for frontend build, if applicable)
- <!-- PostgreSQL 15+ / SQLite -->
- Linux, macOS, or Windows

---

## Quick Start (Development)

```bash
# 1. Clone
git clone https://github.com/OWNER/REPO.git
cd REPO

# 2. Configure environment
cp .env.example .env
# Edit .env and set required values (see Configuration below)

# 3. Set up the database
createdb app_name_dev          # PostgreSQL; skip for SQLite
# Run migrations (see Database Migrations below)

# 4. Build the frontend (if applicable)
npm install
npm run build

# 5. Start the server
# Go
go run ./cmd/app_name

# Python
pip install -e .
python -m app_name

# 6. Open in browser
# http://localhost:8080
```

---

## Configuration

Copy `.env.example` to `.env` and fill in the values. Never commit `.env`.

```bash
# Required
DATABASE_URL=postgres://user:password@localhost:5432/app_name_dev
SECRET_KEY=change-this-to-a-long-random-string

# Optional
PORT=8080
ALLOWED_HOSTS=localhost,127.0.0.1
DEBUG=false
LOG_LEVEL=info
LOG_FORMAT=text

# <!-- other variables -->
```

### Environment Variable Reference

| Variable        | Required | Default     | Description                              |
|-----------------|----------|-------------|------------------------------------------|
| `DATABASE_URL`  | Yes      | -           | Database connection string               |
| `SECRET_KEY`    | Yes      | -           | Secret key for sessions / JWT signing    |
| `PORT`          | No       | `8080`      | Port to listen on                        |
| `ALLOWED_HOSTS` | No       | `localhost` | Comma-separated allowed hostnames        |
| `DEBUG`         | No       | `false`     | Debug mode - never enable in production  |
| `LOG_LEVEL`     | No       | `info`      | Log verbosity: debug, info, warning, error |
| `LOG_FORMAT`    | No       | `text`      | Log format: text or json                 |
| <!-- VAR -->    |          |             | <!-- description -->                     |

---

## Database Migrations

```bash
# Apply all pending migrations
# Go (migrate)
migrate -path migrations/ -database "${DATABASE_URL}" up

# Python (Alembic)
alembic upgrade head

# Check current migration version
# Go
migrate -path migrations/ -database "${DATABASE_URL}" version

# Python
alembic current

# Roll back one migration
# Go
migrate -path migrations/ -database "${DATABASE_URL}" down 1

# Python
alembic downgrade -1
```

Always run migrations before starting the server after pulling changes that
include new migration files.

---

## Deployment

### Docker

```bash
# Build image
docker build -t app_name:latest .

# Run container
docker run -d \
  --name app_name \
  -p 8080:8080 \
  --env-file .env.production \
  app_name:latest
```

### Docker Compose

```bash
# Start all services (app + database)
docker compose up -d

# Run migrations
docker compose exec app migrate -path migrations/ -database "${DATABASE_URL}" up

# View logs
docker compose logs -f app

# Stop
docker compose down
```

### Manual Deployment

```bash
# Build binary (Go)
go build -o bin/app_name ./cmd/app_name

# Build frontend
npm run build

# Copy files to server
rsync -av bin/app_name web/dist/ migrations/ user@server:/opt/app_name/

# On the server: run migrations then start
/opt/app_name/app_name --help
```

### Reverse Proxy (nginx example)

```nginx
server {
    listen 80;
    server_name example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name example.com;

    # TLS configuration omitted - use certbot or equivalent

    # Serve static frontend files directly
    location /assets/ {
        root /opt/app_name/web/dist;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Proxy all other requests to the application
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### systemd (Linux)

```bash
# Install unit file
sudo cp init/app_name.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now app_name

# Check status
sudo systemctl status app_name

# View logs
journalctl -u app_name -f
```

---

## Running Tests

```bash
# Backend unit tests
# Go
go test ./...

# Python
pytest tests/unit/

# Integration tests (requires running database)
# Go
go test ./tests/integration/...

# Python
pytest tests/integration/

# Frontend tests
npm run test

# End-to-end tests (requires full stack)
npm run test:e2e
```

---

## API Reference

<!-- Link to full API documentation if it exists, or provide a brief summary. -->

- Base URL: `http://localhost:8080/api/v1` (development)
- Auth: <!-- Bearer token in Authorization header / session cookie -->
- <!-- Link to docs/api.md or OpenAPI spec -->

---

## License

Copyright (C) <!-- YEAR --> <!-- AUTHOR / ORGANIZATION -->

This program is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.

Note: The AGPL-3.0 requires that the complete source code of any modified version
be made available to users who interact with it over a network. If this requirement
is incompatible with your use case, a commercial license is available.
Contact <!-- email or URL --> for details.

See [LICENSE](LICENSE) for the full license text.
