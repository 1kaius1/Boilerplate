<#
.SYNOPSIS
    Scaffolds a new project from this boilerplate.
.DESCRIPTION
    Copies the chosen type directory plus Universal/, picks the matching
    CLAUDE.md/ARCHITECTURE.md/README.md variant, prunes unused
    .claude/rules/ language files, substitutes placeholders, and adds a
    LICENSE + .gitignore before the first commit. Optionally creates and
    configures the GitHub repository too (-InitRepo).

    First run: -Dest must not exist yet, or be empty (a pre-existing .git\
    is fine) - it gets scaffolded, then the
    script stops and lists the <!-- description --> placeholders left to
    fill in by hand.

    Re-run the same command with -InitRepo, pointed at that now-edited
    -Dest, to skip re-scaffolding and just create/push/configure the
    GitHub repo (requires the gh CLI).
.EXAMPLE
    ./New-Project.ps1 -Type Service -Language CSharp -Dest ~/projects/cool_game `
        -AppName cool_game -Owner myorg -Repo cool-game-server

    ./New-Project.ps1 -Type Service -Language CSharp -Dest ~/projects/cool_game `
        -AppName cool_game -Owner myorg -Repo cool-game-server -InitRepo
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidateSet('CLI', 'GUI', 'Web', 'Service', 'Godot', 'Ansible', 'WoW-AddOn', IgnoreCase = $true)]
    [string]$Type,

    [Parameter(Mandatory = $true)][ValidateSet('Go', 'Python', 'CSharp', 'BASH', 'PHP', 'GDScript', 'Lua', IgnoreCase = $true)]
    [string]$Language,

    [Parameter(Mandatory = $true)][string]$Dest,
    [Parameter(Mandatory = $true)][string]$AppName,
    [Parameter(Mandatory = $true)][string]$Owner,
    [Parameter(Mandatory = $true)][string]$Repo,

    [string]$ProjectOwnerName,
    [string]$ProjectOwnerEmail,
    [string]$GoverningLaw,
    [string]$DisputeJurisdiction,
    [switch]$InitRepo,
    [switch]$Private,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'

$BoilerplateRoot = Split-Path -Parent $PSScriptRoot

# --- Normalize casing ---
switch ($Type.ToLower()) {
    'cli'     { $Type = 'CLI' }
    'gui'     { $Type = 'GUI' }
    'web'     { $Type = 'Web' }
    'service' { $Type = 'Service' }
    'godot'   { $Type = 'Godot' }
    'ansible' { $Type = 'Ansible' }
    'wow-addon' { $Type = 'WoW-AddOn' }
}
switch ($Language.ToLower()) {
    'go'       { $Language = 'Go' }
    'python'   { $Language = 'Python' }
    'csharp'   { $Language = 'CSharp' }
    'bash'     { $Language = 'BASH' }
    'php'      { $Language = 'PHP' }
    'gdscript' { $Language = 'GDScript' }
    'lua'      { $Language = 'Lua' }
}

# --- Validate type/language combination ---
# Godot's language files live under Godot/.claude/rules/ rather than
# Universal/.claude/rules/, since GDScript is Godot-only and its C# rules
# (godot_csharp.md) are additive to, not a replacement for, the generic
# csharp.md - both stay for a Godot+CSharp project.
$validCombos = @{
    'CLI'     = @('Go', 'Python', 'CSharp', 'BASH')
    'GUI'     = @('Go', 'Python', 'CSharp')
    'Web'     = @('Go', 'Python', 'CSharp', 'PHP')
    'Service' = @('Go', 'Python', 'CSharp')
    'Godot'   = @('GDScript', 'CSharp')
    'Ansible' = @('Python')
    'WoW-AddOn' = @('Lua')
}
if ($validCombos[$Type] -notcontains $Language) {
    Write-Error "$Language is not a valid language for type $Type. Valid: $($validCombos[$Type] -join ', ')"
    exit 1
}

if ($AppName -cnotmatch '^[a-z][a-z0-9_]*$') {
    Write-Error "-AppName must be lowercase snake_case (e.g. cool_game), got: $AppName"
    exit 1
}
if ($Owner -notmatch '^[A-Za-z0-9._-]+$' -or $Repo -notmatch '^[A-Za-z0-9._-]+$') {
    Write-Error "-Owner and -Repo may only contain letters, digits, '.', '_', '-'"
    exit 1
}
if (-not $ProjectOwnerName) { $ProjectOwnerName = $Owner }

# --- Case variants of the app name, used by different placeholder tokens ---
$AppNameUpper = $AppName.ToUpper()
$AppNamePascal = ($AppName -split '_' | ForEach-Object {
    if ($_.Length -gt 0) { $_.Substring(0,1).ToUpper() + $_.Substring(1) } else { '' }
}) -join ''

function Write-Gitignore {
    $lines = @(
        '# OS / editor'
        '.DS_Store'
        'Thumbs.db'
        '*.swp'
        '.idea/'
        ''
        '# Claude Code local/personal files - never shared, never committed'
        'CLAUDE.local.md'
        '.claude/settings.local.json'
        ''
    )
    switch ($Language) {
        'Go' {
            $lines += @('# Go', '/bin/', '*.exe', '*.test', '*.out', '')
        }
        'Python' {
            $lines += @('# Python', '__pycache__/', '*.pyc', '.venv/', 'venv/',
                        '*.egg-info/', '.pytest_cache/', '.mypy_cache/', 'dist/', 'build/', '')
        }
        'CSharp' {
            $lines += @('# .NET', 'bin/', 'obj/', '*.user', '.vs/', '')
        }
        'PHP' {
            $lines += @('# PHP / Laravel', '/vendor/', '/node_modules/', '/public/build/',
                        '/public/hot', '/storage/*.key', '/storage/framework/cache/',
                        '/storage/framework/sessions/', '/storage/framework/views/',
                        '/storage/logs/', '.phpunit.result.cache', '')
        }
    }
    if ($Type -eq 'Web') {
        $lines += @('# Web: never commit real environment values', '.env', '')
    }
    if ($Type -eq 'Godot') {
        $lines += @(
            '# Godot: generated editor cache, never committed'
            '.godot/'
            ''
            '# export_presets.cfg can contain machine-specific paths and signing'
            '# credentials (e.g. an Android keystore password) - gitignored by'
            '# default; remove this line if this project keeps it secret-free'
            '# and wants export config under version control'
            'export_presets.cfg'
            ''
        )
    }
    if ($Type -eq 'Ansible') {
        $lines += @(
            '# Ansible: repo-local collections cache (see bootstrap.sh)'
            '.ansible/'
            ''
            '# ansible.cfg often carries a vault_identity_list naming a real'
            '# credential label - gitignored by default, with a committed'
            '# ansible.cfg.example in its place. Remove this line if this'
            "# project's config is genuinely secret-free."
            'ansible.cfg'
            ''
            '# Real, site-specific vault/inventory files - only their .example'
            '# companions are committed. Bare patterns match at every directory'
            '# depth; adjust if this project names these files differently.'
            'vault.yaml'
            'hosts.ini'
            ''
        )
    }
    if ($Type -eq 'WoW-AddOn') {
        $lines += @(
            "# Don't commit a built package zip, regardless of which packager"
            '# (if any) this project eventually adopts'
            '*.zip'
            ''
        )
    }
    Set-Content -Path '.gitignore' -Value $lines
}

function Get-License {
    Write-Host 'Fetching AGPL-3.0 LICENSE text...'
    $url = 'https://www.gnu.org/licenses/agpl-3.0.txt'
    try {
        Invoke-WebRequest -Uri $url -OutFile 'LICENSE' -TimeoutSec 10 -UseBasicParsing
    } catch {
        Write-Warning 'Could not download LICENSE automatically.'
        Write-Warning 'Get the AGPL-3.0 text from https://choosealicense.com/licenses/agpl-3.0/'
        Write-Warning 'and save it as LICENSE, or adjust it if this project uses a different license.'
        Remove-Item -Path 'LICENSE' -ErrorAction SilentlyContinue
    }
}

function Get-ProsePlaceholderFiles {
    # -Force so hidden directories (.claude/) are searched too, matching the
    # bash version's `grep -r .` - without it, placeholders under .claude/
    # would never be reported.
    Get-ChildItem -Recurse -Force -Filter '*.md' -File |
        Select-String -Pattern '<!-- ' -List |
        Select-Object -ExpandProperty Path |
        ForEach-Object { Resolve-Path -Relative $_ }
}

function Get-TokenPlaceholderFiles {
    # Bare SCREAMING_SNAKE_CASE tokens that were never substituted - catches
    # the optional ones (ProjectOwnerEmail, GoverningLaw, DisputeJurisdiction)
    # if no value was given for them, plus a safety net for the required ones.
    # -CaseSensitive matters here: Select-String is case-insensitive by
    # default, and "Owner" (title case) appears throughout CLA.md's ordinary
    # legal prose ("the Project Owner accepts...") - without it, every one
    # of those false-matches CLA.md as still containing the OWNER token.
    $pattern = '\b(OWNER|REPO|APP_NAME|PROJECT_OWNER_NAME|PROJECT_OWNER_EMAIL|GOVERNING_LAW_JURISDICTION|DISPUTE_RESOLUTION_JURISDICTION)\b'
    Get-ChildItem -Recurse -Force -File -Include '*.md', '*.json' |
        Select-String -Pattern $pattern -List -CaseSensitive |
        Select-Object -ExpandProperty Path |
        ForEach-Object { Resolve-Path -Relative $_ }
}

function Show-RemainingPlaceholders {
    $proseFiles = Get-ProsePlaceholderFiles
    $tokenFiles = Get-TokenPlaceholderFiles
    $found = $false
    if ($proseFiles) {
        $found = $true
        Write-Host 'Files with unfilled <!-- description --> placeholders:'
        $proseFiles | ForEach-Object { Write-Host "  $_" }
    }
    if ($tokenFiles) {
        $found = $true
        Write-Host 'Files with unfilled SCREAMING_SNAKE_CASE placeholders:'
        $tokenFiles | ForEach-Object { Write-Host "  $_" }
    }
    if (-not $found) {
        Write-Host 'No placeholders remain.'
    }
    return $found
}

function Invoke-Scaffold {
    Write-Host "Scaffolding $Type/$Language project at $Dest"
    # New-Item -Force is a no-op if $Dest already exists (e.g. a directory
    # that was pre-created and git-init'd before scaffolding). Both copies
    # below use a trailing "\*" wildcard with -Force deliberately - Force is
    # what makes wildcard expansion include hidden items like .claude/, and
    # without the wildcard, Copy-Item would nest the whole source directory
    # one level deep (Dest\WoW-AddOn\... instead of Dest\...) whenever $Dest
    # already exists, since it only copies a directory itself into an
    # *existing* target directory.
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    Copy-Item -Path (Join-Path $BoilerplateRoot "$Type\*") -Destination $Dest -Recurse -Force
    Copy-Item -Path (Join-Path $BoilerplateRoot 'Universal\*') -Destination $Dest -Recurse -Force

    Push-Location $Dest
    try {
        Move-Item "CLAUDE-$Type-$Language.md" 'CLAUDE.md'
        Get-ChildItem -Filter "CLAUDE-$Type-*.md" -File | Remove-Item

        Move-Item "ARCHITECTURE-$Type.md" 'ARCHITECTURE.md'
        Move-Item "README-$Type.md" 'README.md'

        # Prune .claude/rules/ language files that were not chosen.
        # universal.md and the type file (e.g. cli.md) always stay.
        if ($Type -eq 'Godot') {
            # Godot's language files live under Godot/.claude/rules/, not
            # Universal/.claude/rules/ - GDScript is Godot-only, and the
            # Godot C# rules (godot_csharp.md) are additive to the generic
            # csharp.md, not a replacement for it, so csharp.md stays for a
            # Godot+CSharp project. None of Universal's five language files
            # apply to a Godot+GDScript project.
            if ($Language -eq 'GDScript') {
                Remove-Item '.claude/rules/godot_csharp.md' -ErrorAction SilentlyContinue
                foreach ($lang in @('go', 'python', 'csharp', 'bash', 'php')) {
                    Remove-Item ".claude/rules/$lang.md" -ErrorAction SilentlyContinue
                }
            } else {
                Remove-Item '.claude/rules/gdscript.md' -ErrorAction SilentlyContinue
                foreach ($lang in @('go', 'python', 'bash', 'php')) {
                    Remove-Item ".claude/rules/$lang.md" -ErrorAction SilentlyContinue
                }
            }
        } elseif ($Type -eq 'WoW-AddOn') {
            # Lua lives under WoW-AddOn/.claude/rules/lua.md, not Universal/ - no
            # other type here uses Lua, so none of Universal's five language
            # files apply.
            foreach ($lang in @('go', 'python', 'csharp', 'bash', 'php')) {
                Remove-Item ".claude/rules/$lang.md" -ErrorAction SilentlyContinue
            }
        } else {
            $keepLang = $Language.ToLower()
            foreach ($lang in @('go', 'python', 'csharp', 'bash', 'php')) {
                $ruleFile = ".claude/rules/$lang.md"
                if ($lang -ne $keepLang -and (Test-Path $ruleFile)) {
                    Remove-Item $ruleFile
                }
            }
        }

        # --- Placeholder substitution ---
        # Longer/more-specific tokens must be replaced before the shorter
        # tokens they contain as a substring (PROJECT_OWNER_NAME and
        # PROJECT_OWNER_EMAIL both contain OWNER; APP_NAME_CONFIG etc.
        # deliberately DO get the APP_NAME prefix substituted, that part is
        # intentional). ProjectOwnerEmail, GoverningLaw, and
        # DisputeJurisdiction are optional - if not supplied, their tokens
        # are left alone so they surface in the remaining-placeholders check
        # instead of silently keeping a stale value.
        # -Force so hidden directories (.claude/) get substituted too,
        # matching the bash version's `find .`.
        $targets = Get-ChildItem -Recurse -Force -File -Include '*.md', '*.json', '*.yaml', '*.yml'
        foreach ($f in $targets) {
            $content = Get-Content -Path $f.FullName -Raw
            if ($null -eq $content) { continue }
            $content = $content.Replace('PROJECT_OWNER_NAME', $ProjectOwnerName)
            if ($ProjectOwnerEmail) { $content = $content.Replace('PROJECT_OWNER_EMAIL', $ProjectOwnerEmail) }
            if ($GoverningLaw) { $content = $content.Replace('GOVERNING_LAW_JURISDICTION', $GoverningLaw) }
            if ($DisputeJurisdiction) { $content = $content.Replace('DISPUTE_RESOLUTION_JURISDICTION', $DisputeJurisdiction) }
            $content = $content.Replace('OWNER', $Owner)
            $content = $content.Replace('REPO', $Repo)
            $content = $content.Replace('APP_NAME', $AppNameUpper)
            $content = $content.Replace('app_name', $AppName)
            $content = $content.Replace('AppName', $AppNamePascal)
            Set-Content -Path $f.FullName -Value $content -NoNewline
        }

        Write-Gitignore
        if ($Type -eq 'WoW-AddOn') {
            Write-Host 'Skipping LICENSE fetch - WoW-AddOn defaults to no license / all rights'
            Write-Host "reserved, not this boilerplate's usual AGPLv3/Commercial default (see"
            Write-Host "README-WoW-AddOn.md's License section)."
        } else {
            Get-License
        }

        Write-Host ''
        Write-Host 'Local scaffolding complete.'
        Show-RemainingPlaceholders | Out-Null

        if (-not $InitRepo) {
            Write-Host ''
            Write-Host "Next: fill in the placeholders above, then either follow README.md's"
            Write-Host 'Repository Setup section by hand, or re-run this exact command with'
            Write-Host '-InitRepo to create and push the GitHub repo.'
        }
    } finally {
        Pop-Location
    }
}

function Invoke-InitRepo {
    Push-Location $Dest
    try {
        if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
            Write-Error '-InitRepo requires the GitHub CLI (gh), which was not found.'
            exit 1
        }

        if (Show-RemainingPlaceholders) {
            if (-not $Yes) {
                $confirm = Read-Host 'Push to GitHub anyway? [y/N]'
                if ($confirm -notmatch '^(y|yes)$') {
                    Write-Host 'Aborted. Fill in the placeholders, then re-run this command.'
                    exit 0
                }
            }
        }

        $visibility = if ($Private) { '--private' } else { '--public' }

        Write-Host ''
        Write-Host "About to create $visibility GitHub repo $Owner/$Repo and push $Dest to it."
        if (-not $Yes) {
            $confirm = Read-Host 'Continue? [y/N]'
            if ($confirm -notmatch '^(y|yes)$') {
                Write-Host 'Aborted before touching GitHub.'
                exit 0
            }
        }

        # Explicit Owner/Repo, not just Repo - otherwise gh silently creates
        # the repo under whatever account the local gh CLI happens to be
        # authenticated as, ignoring -Owner entirely.
        & gh repo create "$Owner/$Repo" $visibility

        & git init -b master
        & git add .
        & git commit -m 'chore: initial commit'
        & git remote add origin "git@github.com:$Owner/$Repo.git"
        & git push -u origin master

        Write-Host 'Configuring branch protection on master...'
        $protection = @"
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 0 },
  "restrictions": null
}
"@
        $protection | & gh api --method PUT -H 'Accept: application/vnd.github+json' `
            "/repos/$Owner/$Repo/branches/master/protection" --input -

        Write-Host 'Configuring squash-only merging...'
        $mergeSettings = @"
{
  "allow_squash_merge": true,
  "allow_merge_commit": false,
  "allow_rebase_merge": false,
  "delete_branch_on_merge": true,
  "squash_merge_commit_title": "PR_TITLE",
  "squash_merge_commit_message": "PR_BODY"
}
"@
        $mergeSettings | & gh api --method PATCH -H 'Accept: application/vnd.github+json' `
            "/repos/$Owner/$Repo" --input -

        Write-Host ''
        Write-Host "Repository created and configured: https://github.com/$Owner/$Repo"
        Write-Host 'Add branch-required-status-checks once CI exists (see README.md).'
    } finally {
        Pop-Location
    }
}

# A destination that doesn't exist yet, or that exists but is empty (or
# contains only a pre-existing .git\ - e.g. it was created and git-init'd
# before scaffolding, a common workflow), is safe to scaffold into. Anything
# else existing there means this looks like a re-run against an
# already-scaffolded project.
function Test-DestNeedsScaffold {
    if (-not (Test-Path $Dest)) { return $true }
    if (-not (Test-Path $Dest -PathType Container)) { return $false }
    $remaining = Get-ChildItem -Path $Dest -Force | Where-Object { $_.Name -ne '.git' }
    return -not $remaining
}

if (Test-DestNeedsScaffold) {
    Invoke-Scaffold
    if ($InitRepo) {
        Invoke-InitRepo
    }
} else {
    if ($InitRepo) {
        Write-Host 'Destination already exists - skipping scaffolding, going straight to GitHub setup.'
        Invoke-InitRepo
    } else {
        Write-Error "Destination already exists and is not empty: $Dest`nRe-run with -InitRepo to skip scaffolding and just push/configure GitHub."
        exit 1
    }
}
