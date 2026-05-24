# app_name

<!-- One sentence. What does this service do and why would someone want to run it. -->

<!-- Badges - replace URLs with real ones -->
![Version](https://img.shields.io/github/v/release/OWNER/REPO)
![License](https://img.shields.io/badge/license-AGPL--3.0--or--later-blue)
![Build](https://img.shields.io/github/actions/workflow/status/OWNER/REPO/ci.yml)

---

## Overview

<!-- Two to four sentences expanding on the one-liner above. What problem does
this service solve, who runs it, and what makes it worth deploying. -->

---

## Features

- <!-- feature -->
- <!-- feature -->
- <!-- feature -->

---

## Requirements

- <!-- Go 1.22+ / Python 3.11+ -->
- Linux, macOS, or Windows
- <!-- Any external dependencies: database, message queue, etc. -->

---

## Installation

### Pre-built Binary

```bash
# Download the latest release for your platform:
# https://github.com/OWNER/REPO/releases

# Linux / macOS
tar -xzf app_name_linux_amd64.tar.gz
sudo mv app_name /usr/local/bin/app_name
sudo chmod +x /usr/local/bin/app_name

# Verify
app_name --version
```

### From Source

```bash
# Go
git clone https://github.com/OWNER/REPO.git
cd REPO
go build -o bin/app_name ./cmd/app_name
sudo mv bin/app_name /usr/local/bin/app_name

# Python
git clone https://github.com/OWNER/REPO.git
cd REPO
pip install .
```

---

## Quick Start

Run in the foreground for testing:

```bash
app_name --config ~/.app_name/config.yaml --verbose
```

---

## Configuration

On first run, `app_name` creates a default config file at `~/.app_name/config.yaml`.

```yaml
# ~/.app_name/config.yaml

# Address and port to listen on (default: 127.0.0.1:<!-- PORT -->)
listen_address: "127.0.0.1:<!-- PORT -->"

# Log verbosity: debug, info, warning, error (default: info)
log_level: info

# Log format: text (human-readable) or json (structured) (default: text)
log_format: text

# Graceful shutdown timeout in seconds (default: 30)
shutdown_timeout_seconds: 30

# <!-- other config keys and their defaults -->
```

### Environment Variable Overrides

| Variable                  | Default         | Description                         |
|---------------------------|-----------------|-------------------------------------|
| `APP_NAME_CONFIG`         | `~/.app_name/config.yaml` | Path to config file       |
| `APP_NAME_LOG_LEVEL`      | `info`          | Log verbosity                       |
| `APP_NAME_LOG_FORMAT`     | `text`          | Log format: text or json            |
| <!-- APP_NAME_XXXX -->    | <!-- default --> | <!-- description -->               |

CLI flags take precedence over environment variables, which take precedence over
the config file.

---

## Running as a System Service

### systemd (Linux)

```bash
# Install the unit file
sudo cp init/app_name.service /etc/systemd/system/
sudo systemctl daemon-reload

# Enable on boot and start now
sudo systemctl enable --now app_name

# Check status
sudo systemctl status app_name

# View logs
journalctl -u app_name -f

# Reload configuration without restarting
sudo systemctl reload app_name

# Stop
sudo systemctl stop app_name
```

### launchd (macOS)

```bash
# Install as a user agent
cp init/com.example.app_name.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.example.app_name.plist

# Stop
launchctl unload ~/Library/LaunchAgents/com.example.app_name.plist
```

### Windows Service

```powershell
# Install
sc create app_name binPath= "C:\path\to\app_name.exe --config C:\Users\<user>\.app_name\config.yaml"
sc start app_name

# Stop
sc stop app_name

# Remove
sc delete app_name
```

---

## Signal Handling

| Signal   | Behavior                                                     |
|----------|--------------------------------------------------------------|
| SIGTERM  | Graceful shutdown - finishes in-flight work then exits       |
| SIGINT   | Graceful shutdown - same as SIGTERM                          |
| SIGHUP   | Reloads configuration without restarting                     |

---

## Logging

By default `app_name` logs to stderr. To log to a file:

```bash
app_name --log-file /var/log/app_name.log
# or
APP_NAME_LOG_FILE=/var/log/app_name.log app_name
```

Set `log_format: json` in the config for structured output suitable for log
aggregators (Loki, Splunk, Elasticsearch, etc.).

---

## License

Copyright (C) <!-- YEAR --> <!-- AUTHOR / ORGANIZATION -->

This program is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.

A commercial license is also available for use cases that are incompatible with the
AGPL-3.0. Contact <!-- email or URL --> for details.

See [LICENSE](LICENSE) for the full license text.
