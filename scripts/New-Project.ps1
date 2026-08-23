<#
.SYNOPSIS
    Scaffolds a new project from this boilerplate.
.DESCRIPTION
    Copies the chosen type directory plus Universal/, picks the matching
    CLAUDE.md/ARCHITECTURE.md/README.md variant, prunes unused
    .claude/rules/ language files, substitutes placeholders, and adds a
    LICENSE + .gitignore before the first commit. Optionally creates and
    configures the GitHub repository too (-InitRepo).

    First run: -Dest must not exist yet - it gets scaffolded, then the
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
    [Parameter(Mandatory = $true)][ValidateSet('CLI', 'GUI', 'Web', 'Service', IgnoreCase = $true)]
    [string]$Type,

    [Parameter(Mandatory = $true)][ValidateSet('Go', 'Python', 'CSharp', 'BASH', 'PHP', IgnoreCase = $true)]
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
}
switch ($Language.ToLower()) {
    'go'     { $Language = 'Go' }
    'python' { $Language = 'Python' }
    'csharp' { $Language = 'CSharp' }
    'bash'   { $Language = 'BASH' }
    'php'    { $Language = 'PHP' }
}

# --- Validate type/language combination ---
$validCombos = @{
    'CLI'     = @('Go', 'Python', 'CSharp', 'BASH')
    'GUI'     = @('Go', 'Python', 'CSharp')
    'Web'     = @('Go', 'Python', 'CSharp', 'PHP')
    'Service' = @('Go', 'Python', 'CSharp')
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
    Get-ChildItem -Recurse -Filter '*.md' -File |
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
    Get-ChildItem -Recurse -File -Include '*.md', '*.json' |
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
    $destParent = Split-Path -Parent $Dest
    if ($destParent -and -not (Test-Path $destParent)) {
        New-Item -ItemType Directory -Path $destParent -Force | Out-Null
    }
    Copy-Item -Path (Join-Path $BoilerplateRoot $Type) -Destination $Dest -Recurse
    # Merge Universal/ (including dotfiles) into the same destination
    Copy-Item -Path (Join-Path $BoilerplateRoot 'Universal\*') -Destination $Dest -Recurse -Force
    $universalDotClaude = Join-Path $BoilerplateRoot 'Universal\.claude'
    if (Test-Path $universalDotClaude) {
        Copy-Item -Path $universalDotClaude -Destination $Dest -Recurse -Force
    }

    Push-Location $Dest
    try {
        Move-Item "CLAUDE-$Type-$Language.md" 'CLAUDE.md'
        Get-ChildItem -Filter "CLAUDE-$Type-*.md" -File | Remove-Item

        Move-Item "ARCHITECTURE-$Type.md" 'ARCHITECTURE.md'
        Move-Item "README-$Type.md" 'README.md'

        # Prune .claude/rules/ language files that were not chosen.
        # universal.md and the type file (e.g. cli.md) always stay.
        $keepLang = $Language.ToLower()
        foreach ($lang in @('go', 'python', 'csharp', 'bash', 'php')) {
            $ruleFile = ".claude/rules/$lang.md"
            if ($lang -ne $keepLang -and (Test-Path $ruleFile)) {
                Remove-Item $ruleFile
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
        $targets = Get-ChildItem -Recurse -File -Include '*.md', '*.json', '*.yaml', '*.yml'
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
        Get-License

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

if (Test-Path $Dest) {
    if ($InitRepo) {
        Write-Host 'Destination already exists - skipping scaffolding, going straight to GitHub setup.'
        Invoke-InitRepo
    } else {
        Write-Error "Destination already exists: $Dest`nRe-run with -InitRepo to skip scaffolding and just push/configure GitHub."
        exit 1
    }
} else {
    Invoke-Scaffold
    if ($InitRepo) {
        Invoke-InitRepo
    }
}
