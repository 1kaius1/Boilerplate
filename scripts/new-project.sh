#!/usr/bin/env bash
# SPDX-License-Identifier: CC-BY-4.0
#
# Scaffolds a new project from this boilerplate: copies the chosen type
# directory plus Universal/, picks the matching CLAUDE.md/ARCHITECTURE.md/
# README.md variant, prunes unused .claude/rules/ language files,
# substitutes placeholders, and adds a LICENSE + .gitignore before the
# first commit. Optionally creates and configures the GitHub repository
# too (--init-repo). See --help for usage.
set -euo pipefail

BOILERPLATE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: new-project.sh --type <CLI|GUI|Web|Service> --language <Go|Python|CSharp|BASH|PHP> \
       --dest <path> --app-name <snake_case_name> --owner <github_owner> --repo <repo_name> \
       [--project-owner-name "<Display Name>"] [--project-owner-email <email>] \
       [--governing-law <jurisdiction>] [--dispute-jurisdiction <jurisdiction>] \
       [--init-repo] [--private] [--yes]

  --type                   Project type directory to copy (CLI, GUI, Web, Service)
  --language               Language variant to keep (Go, Python, CSharp, BASH, PHP)
                           Valid per type: CLI=Go,Python,CSharp,BASH  GUI=Go,Python,CSharp
                                           Web=Go,Python,CSharp,PHP   Service=Go,Python,CSharp
  --dest                   Target directory. First run: must not exist yet, gets scaffolded.
                           Re-run with --init-repo pointed at the same --dest to skip
                           scaffolding and just push/configure GitHub once you've filled
                           in the remaining placeholders.
  --app-name               Lowercase snake_case app name, e.g. cool_game
  --owner                  GitHub username or org that will own the repo
  --repo                   GitHub repository name
  --project-owner-name     Display name for PROJECT_OWNER_NAME placeholder (default: --owner)
  --project-owner-email    Fills PROJECT_OWNER_EMAIL in CLA.md (where signed CLAs go).
                           Optional - left as a placeholder to fill in by hand if omitted.
  --governing-law          Fills GOVERNING_LAW_JURISDICTION in CLA.md. Optional - left as
                           a placeholder to fill in by hand if omitted.
  --dispute-jurisdiction   Fills DISPUTE_RESOLUTION_JURISDICTION in CLA.md. Optional - left
                           as a placeholder to fill in by hand if omitted.
  --init-repo               Also create the GitHub repo, push, and configure branch
                           protection + squash-only merging (requires the gh CLI)
  --private                 With --init-repo, create the repo as private (default: public)
  --yes                     Skip confirmation prompts (before pushing, and before pushing
                           with unfilled placeholders still present)
  -h, --help                Show this help
EOF
}

TYPE="" LANGUAGE="" DEST="" APP_NAME="" OWNER="" REPO="" PROJECT_OWNER_NAME=""
PROJECT_OWNER_EMAIL="" GOVERNING_LAW="" DISPUTE_JURISDICTION=""
INIT_REPO=0 PRIVATE=0 ASSUME_YES=0

while [ $# -gt 0 ]; do
  case "$1" in
    --type) TYPE="$2"; shift 2 ;;
    --language) LANGUAGE="$2"; shift 2 ;;
    --dest) DEST="$2"; shift 2 ;;
    --app-name) APP_NAME="$2"; shift 2 ;;
    --owner) OWNER="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --project-owner-name) PROJECT_OWNER_NAME="$2"; shift 2 ;;
    --project-owner-email) PROJECT_OWNER_EMAIL="$2"; shift 2 ;;
    --governing-law) GOVERNING_LAW="$2"; shift 2 ;;
    --dispute-jurisdiction) DISPUTE_JURISDICTION="$2"; shift 2 ;;
    --init-repo) INIT_REPO=1; shift ;;
    --private) PRIVATE=1; shift ;;
    --yes) ASSUME_YES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

for required in TYPE LANGUAGE DEST APP_NAME OWNER REPO; do
  if [ -z "${!required}" ]; then
    flag="--$(echo "$required" | tr '[:upper:]' '[:lower:]' | tr '_' '-')"
    echo "Missing required argument: $flag" >&2
    usage
    exit 1
  fi
done

[ -n "$PROJECT_OWNER_NAME" ] || PROJECT_OWNER_NAME="$OWNER"

if [[ ! "$APP_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Error: --app-name must be lowercase snake_case (e.g. cool_game), got: $APP_NAME" >&2
  exit 1
fi
if [[ ! "$OWNER" =~ ^[A-Za-z0-9._-]+$ ]] || [[ ! "$REPO" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "Error: --owner and --repo may only contain letters, digits, '.', '_', '-'" >&2
  exit 1
fi

case "$(echo "$TYPE" | tr '[:upper:]' '[:lower:]')" in
  cli) TYPE="CLI" ;;
  gui) TYPE="GUI" ;;
  web) TYPE="Web" ;;
  service) TYPE="Service" ;;
  *) echo "Error: --type must be one of CLI, GUI, Web, Service" >&2; exit 1 ;;
esac

case "$(echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]')" in
  go) LANGUAGE="Go" ;;
  python) LANGUAGE="Python" ;;
  csharp|c#) LANGUAGE="CSharp" ;;
  bash) LANGUAGE="BASH" ;;
  php) LANGUAGE="PHP" ;;
  *) echo "Error: --language must be one of Go, Python, CSharp, BASH, PHP" >&2; exit 1 ;;
esac

case "$TYPE:$LANGUAGE" in
  CLI:Go|CLI:Python|CLI:CSharp|CLI:BASH) ;;
  GUI:Go|GUI:Python|GUI:CSharp) ;;
  Web:Go|Web:Python|Web:CSharp|Web:PHP) ;;
  Service:Go|Service:Python|Service:CSharp) ;;
  *) echo "Error: $LANGUAGE is not a valid language for type $TYPE (see --help)" >&2; exit 1 ;;
esac

# --- Case variants of the app name, used by different placeholder tokens ---
APP_NAME_UPPER="$(echo "$APP_NAME" | tr '[:lower:]' '[:upper:]')"
APP_NAME_PASCAL="$(echo "$APP_NAME" | awk -F'_' '{s="";for(i=1;i<=NF;i++) s=s toupper(substr($i,1,1)) substr($i,2); print s}')"

sed_escape() { printf '%s' "$1" | sed -e 's/[&/\]/\\&/g'; }

scaffold() {
  echo "Scaffolding $TYPE/$LANGUAGE project at $DEST"
  mkdir -p "$(dirname "$DEST")"
  cp -r "$BOILERPLATE_ROOT/$TYPE/" "$DEST/"
  cp -r "$BOILERPLATE_ROOT/Universal/." "$DEST/"

  cd "$DEST"

  mv "CLAUDE-${TYPE}-${LANGUAGE}.md" CLAUDE.md
  find . -maxdepth 1 -name "CLAUDE-${TYPE}-*.md" -delete

  mv "ARCHITECTURE-${TYPE}.md" ARCHITECTURE.md
  mv "README-${TYPE}.md" README.md

  # Prune .claude/rules/ language files that were not chosen. universal.md
  # and the type file (e.g. cli.md) always stay - only language files vary.
  KEEP_LANG="$(echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]')"
  for lang in go python csharp bash php; do
    if [ "$lang" != "$KEEP_LANG" ] && [ -f ".claude/rules/${lang}.md" ]; then
      rm ".claude/rules/${lang}.md"
    fi
  done

  # --- Placeholder substitution ---
  # PROJECT_OWNER_NAME must be replaced before OWNER - it contains OWNER as
  # a substring, so doing OWNER first would corrupt the longer token.
  # Longer/more-specific tokens must be replaced before the shorter tokens
  # they contain as a substring (PROJECT_OWNER_NAME and PROJECT_OWNER_EMAIL
  # both contain OWNER; APP_NAME_CONFIG etc. deliberately DO get the APP_NAME
  # prefix substituted, that part is intentional substring replacement).
  # PROJECT_OWNER_EMAIL, GOVERNING_LAW_JURISDICTION, and
  # DISPUTE_RESOLUTION_JURISDICTION are optional - if not supplied, skip
  # substituting them so they surface in the remaining-placeholders check
  # instead of silently keeping a stale value.
  local sed_script
  sed_script="s/PROJECT_OWNER_NAME/$(sed_escape "$PROJECT_OWNER_NAME")/g"
  [ -n "$PROJECT_OWNER_EMAIL" ] && sed_script="${sed_script}; s/PROJECT_OWNER_EMAIL/$(sed_escape "$PROJECT_OWNER_EMAIL")/g"
  [ -n "$GOVERNING_LAW" ] && sed_script="${sed_script}; s/GOVERNING_LAW_JURISDICTION/$(sed_escape "$GOVERNING_LAW")/g"
  [ -n "$DISPUTE_JURISDICTION" ] && sed_script="${sed_script}; s/DISPUTE_RESOLUTION_JURISDICTION/$(sed_escape "$DISPUTE_JURISDICTION")/g"
  sed_script="${sed_script}; s/OWNER/$(sed_escape "$OWNER")/g"
  sed_script="${sed_script}; s/REPO/$(sed_escape "$REPO")/g"
  sed_script="${sed_script}; s/APP_NAME/$(sed_escape "$APP_NAME_UPPER")/g"
  sed_script="${sed_script}; s/app_name/$(sed_escape "$APP_NAME")/g"
  sed_script="${sed_script}; s/AppName/$(sed_escape "$APP_NAME_PASCAL")/g"

  find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" \) -print0 |
    while IFS= read -r -d '' f; do
      tmp="$(mktemp)"
      sed -e "$sed_script" "$f" > "$tmp"
      mv "$tmp" "$f"
    done

  write_gitignore
  fetch_license

  echo ""
  echo "Local scaffolding complete."
  print_remaining_placeholders
  if [ "$INIT_REPO" -ne 1 ]; then
    echo ""
    echo "Next: fill in the placeholders above, then either follow README.md's"
    echo "Repository Setup section by hand, or re-run this exact command with"
    echo "--init-repo to create and push the GitHub repo."
  fi
}

write_gitignore() {
  {
    echo "# OS / editor"
    echo ".DS_Store"
    echo "Thumbs.db"
    echo "*.swp"
    echo ".idea/"
    echo ""
    echo "# Claude Code local/personal files - never shared, never committed"
    echo "CLAUDE.local.md"
    echo ".claude/settings.local.json"
    echo ""
    case "$LANGUAGE" in
      Go)
        echo "# Go"
        echo "/bin/"
        echo "*.exe"
        echo "*.test"
        echo "*.out"
        echo "" ;;
      Python)
        echo "# Python"
        echo "__pycache__/"
        echo "*.pyc"
        echo ".venv/"
        echo "venv/"
        echo "*.egg-info/"
        echo ".pytest_cache/"
        echo ".mypy_cache/"
        echo "dist/"
        echo "build/"
        echo "" ;;
      CSharp)
        echo "# .NET"
        echo "bin/"
        echo "obj/"
        echo "*.user"
        echo ".vs/"
        echo "" ;;
      PHP)
        echo "# PHP / Laravel"
        echo "/vendor/"
        echo "/node_modules/"
        echo "/public/build/"
        echo "/public/hot"
        echo "/storage/*.key"
        echo "/storage/framework/cache/"
        echo "/storage/framework/sessions/"
        echo "/storage/framework/views/"
        echo "/storage/logs/"
        echo ".phpunit.result.cache"
        echo "" ;;
    esac
    if [ "$TYPE" = "Web" ]; then
      echo "# Web: never commit real environment values"
      echo ".env"
      echo ""
    fi
  } > .gitignore
}

fetch_license() {
  echo "Fetching AGPL-3.0 LICENSE text..."
  local url="https://www.gnu.org/licenses/agpl-3.0.txt"
  local ok=0
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --max-time 10 -o LICENSE "$url" && ok=1
  elif command -v wget >/dev/null 2>&1; then
    wget -q -T 10 -O LICENSE "$url" && ok=1
  fi
  if [ "$ok" -ne 1 ]; then
    echo "Warning: could not download LICENSE automatically." >&2
    echo "Get the AGPL-3.0 text from https://choosealicense.com/licenses/agpl-3.0/" >&2
    echo "and save it as LICENSE, or adjust it if this project uses a different license." >&2
    rm -f LICENSE
  fi
}

print_remaining_placeholders() {
  local prose_files token_files found=0
  prose_files="$(grep -rln "<!-- " --include="*.md" . 2>/dev/null || true)"
  if [ -n "$prose_files" ]; then
    found=1
    echo "Files with unfilled <!-- description --> placeholders:"
    echo "$prose_files" | sed 's/^/  /'
  fi
  # Bare SCREAMING_SNAKE_CASE tokens that were never substituted - catches
  # the optional ones (PROJECT_OWNER_EMAIL, GOVERNING_LAW_JURISDICTION,
  # DISPUTE_RESOLUTION_JURISDICTION) if no value was given for them, plus a
  # safety net for the required ones in case something went wrong above.
  token_files="$(grep -rlE "\b(OWNER|REPO|APP_NAME|PROJECT_OWNER_NAME|PROJECT_OWNER_EMAIL|GOVERNING_LAW_JURISDICTION|DISPUTE_RESOLUTION_JURISDICTION)\b" \
    --include="*.md" --include="*.json" . 2>/dev/null || true)"
  if [ -n "$token_files" ]; then
    found=1
    echo "Files with unfilled SCREAMING_SNAKE_CASE placeholders:"
    echo "$token_files" | sed 's/^/  /'
  fi
  if [ "$found" -eq 0 ]; then
    echo "No placeholders remain."
    return 1
  fi
  return 0
}

init_repo() {
  cd "$DEST"

  if ! command -v gh >/dev/null 2>&1; then
    echo "Error: --init-repo requires the GitHub CLI (gh), which was not found." >&2
    exit 1
  fi

  if print_remaining_placeholders; then
    if [ "$ASSUME_YES" -ne 1 ]; then
      read -r -p "Push to GitHub anyway? [y/N] " confirm
      case "$confirm" in
        y|Y|yes|YES) ;;
        *) echo "Aborted. Fill in the placeholders, then re-run this command."; exit 0 ;;
      esac
    fi
  fi

  local visibility="--public"
  [ "$PRIVATE" -eq 1 ] && visibility="--private"

  echo ""
  echo "About to create $visibility GitHub repo ${OWNER}/${REPO} and push $DEST to it."
  if [ "$ASSUME_YES" -ne 1 ]; then
    read -r -p "Continue? [y/N] " confirm
    case "$confirm" in
      y|Y|yes|YES) ;;
      *) echo "Aborted before touching GitHub."; exit 0 ;;
    esac
  fi

  # Explicit OWNER/REPO, not just REPO - otherwise gh silently creates the repo
  # under whatever account the local gh CLI happens to be authenticated as,
  # ignoring --owner entirely.
  gh repo create "${OWNER}/${REPO}" $visibility

  git init -b master
  git add .
  git commit -m "chore: initial commit"
  git remote add origin "git@github.com:${OWNER}/${REPO}.git"
  git push -u origin master

  echo "Configuring branch protection on master..."
  gh api --method PUT -H "Accept: application/vnd.github+json" \
    "/repos/${OWNER}/${REPO}/branches/master/protection" --input - <<EOF
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 0 },
  "restrictions": null
}
EOF

  echo "Configuring squash-only merging..."
  gh api --method PATCH -H "Accept: application/vnd.github+json" \
    "/repos/${OWNER}/${REPO}" --input - <<EOF
{
  "allow_squash_merge": true,
  "allow_merge_commit": false,
  "allow_rebase_merge": false,
  "delete_branch_on_merge": true,
  "squash_merge_commit_title": "PR_TITLE",
  "squash_merge_commit_message": "PR_BODY"
}
EOF

  echo ""
  echo "Repository created and configured: https://github.com/${OWNER}/${REPO}"
  echo "Add branch-required-status-checks once CI exists (see README.md)."
}

if [ -e "$DEST" ]; then
  if [ "$INIT_REPO" -eq 1 ]; then
    echo "Destination already exists - skipping scaffolding, going straight to GitHub setup."
    init_repo
  else
    echo "Error: destination already exists: $DEST" >&2
    echo "Re-run with --init-repo to skip scaffolding and just push/configure GitHub." >&2
    exit 1
  fi
else
  scaffold
  if [ "$INIT_REPO" -eq 1 ]; then
    init_repo
  fi
fi
