param(
  [ValidateSet('debug', 'profile', 'release')]
  [string]$Mode = 'release',

  [string]$Version,

  [switch]$Download,
  [switch]$Open
)

$ErrorActionPreference = 'Stop'

# ──────────────────────────────────────────────
# 1. Check gh CLI is installed
# ──────────────────────────────────────────────
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Error "GitHub CLI (gh) is required. Install from https://cli.github.com/"
  exit 1
}

# ──────────────────────────────────────────────
# 2. Determine remote
# ──────────────────────────────────────────────
$remote = gh repo view --json nameWithOwner 2>$null | ConvertFrom-Json | Select-Object -ExpandProperty nameWithOwner
if (-not $remote) {
  $remote = "origin"
  $url = gh repo view --json url 2>$null | ConvertFrom-Json | Select-Object -ExpandProperty url
  if (-not $url) {
    Write-Error "Not a GitHub repository or not authenticated."
    exit 1
  }
  $remote = ($url -replace 'https://github.com/', '')
}
Write-Host "Repository: $remote" -ForegroundColor Cyan

# ──────────────────────────────────────────────
# 3. Build workflow parameters
# ──────────────────────────────────────────────
$params = @{
  build_mode = $Mode
}
if ($Version) { $params.version = $Version }

Write-Host "Triggering iOS $Mode build..." -ForegroundColor Green
Write-Host "  Parameters: $($params | ConvertTo-Json -Compress)" -ForegroundColor Gray

# ──────────────────────────────────────────────
# 4. Trigger workflow_dispatch
# ──────────────────────────────────────────────
$run = gh workflow run "Build iOS IPA" --repo $remote --ref main --field build_mode=$Mode 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to trigger workflow: $run"
  exit 1
}

Write-Host "✓ Build triggered!" -ForegroundColor Green

if (-not $Download -and -not $Open) {
  Write-Host ""
  Write-Host "Run with -Download to wait and download the IPA automatically." -ForegroundColor Yellow
  Write-Host "Run with -Open to open the workflow run in browser." -ForegroundColor Yellow
  Write-Host ""
  Write-Host "To check status manually:" -ForegroundColor Gray
  Write-Host "  gh run list --repo $remote --workflow \"Build iOS IPA\"" -ForegroundColor Gray
  exit 0
}

# ──────────────────────────────────────────────
# 5. Open in browser (optional)
# ──────────────────────────────────────────────
if ($Open) {
  gh run view --repo $remote --web 2>$null
}

# ──────────────────────────────────────────────
# 6. Wait and download artifact (optional)
# ──────────────────────────────────────────────
if ($Download) {
  Write-Host "Waiting for build to complete... (this may take 10-20 minutes)" -ForegroundColor Yellow

  $attempts = 0
  $maxAttempts = 120  # 2 hours max (120 * 60s)
  $runId = $null

  while ($attempts -lt $maxAttempts) {
    $attempts++
    $runs = gh run list --repo $remote --workflow "Build iOS IPA" --limit 1 --json databaseId,status,conclusion 2>$null | ConvertFrom-Json

    if ($runs -and $runs.Count -gt 0) {
      $current = $runs[0]
      $runId = $current.databaseId

      if ($current.status -eq 'completed') {
        if ($current.conclusion -eq 'success') {
          Write-Host "✓ Build completed successfully!" -ForegroundColor Green
          break
        } else {
          Write-Error "Build failed with conclusion: $($current.conclusion)"
          Write-Host "  View details: gh run view $runId --repo $remote" -ForegroundColor Gray
          exit 1
        }
      }
    }

    Write-Host "  Waiting... ($attempts / $maxAttempts)" -NoNewline
    Start-Sleep -Seconds 60
    Write-Host "`r" -NoNewline
  }

  if (-not $runId) {
    Write-Error "Could not find the workflow run."
    exit 1
  }

  # ──────────────────────────────────────────────
  # 7. Download artifact
  # ──────────────────────────────────────────────
  $outDir = Join-Path $PSScriptRoot "..\build\ios"
  New-Item -ItemType Directory -Path $outDir -Force | Out-Null

  Write-Host "Downloading IPA artifact..." -ForegroundColor Cyan
  gh run download $runId --repo $remote --name "sbku_app_$Mode" --dir $outDir 2>&1

  if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to download artifact."
    exit 1
  }

  $ipa = Get-ChildItem -Path $outDir -Filter "*.ipa" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($ipa) {
    Write-Host "✓ IPA downloaded: $($ipa.FullName)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Install on device via Sideloadly, AltStore, or `"gh run download`""
    Write-Host "  2. The IPA is unsigned — use a free Apple ID to sign via Sideloadly"
    Write-Host "  3. For TestFlight/App Store, you need a paid Apple Developer Account"
  } else {
    Write-Warning "Artifact downloaded but no .ipa file found in $outDir"
  }
}
