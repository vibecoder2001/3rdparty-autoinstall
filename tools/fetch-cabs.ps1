#requires -Version 5.1
[CmdletBinding()]
param(
  [string]$ManifestPath = ".\tools\wu-manifest.json",
  [string]$DriversRoot  = ".\drivers"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-Sha256([string]$Path) {
  return (Get-FileHash -Path $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

if (!(Test-Path -LiteralPath $ManifestPath)) {
  throw "Manifest not found: $ManifestPath"
}

$manifest = (Get-Content -LiteralPath $ManifestPath -Raw) | ConvertFrom-Json
$DriversRoot = (Resolve-Path -LiteralPath $DriversRoot).Path

foreach ($prop in $manifest.PSObject.Properties) {
  $relPath = $prop.Name
  $entry   = $prop.Value

  if (-not ($entry -is [pscustomobject])) {
    throw "Manifest entry '$relPath' must be an object with 'url' and 'sha256'"
  }

  if ([string]::IsNullOrWhiteSpace($entry.url)) {
    throw "Manifest entry '$relPath' is missing required 'url'"
  }

  if ([string]::IsNullOrWhiteSpace($entry.sha256)) {
    throw "Manifest entry '$relPath' is missing required 'sha256'"
  }

  $url        = [string]$entry.url
  $expectHash = ([string]$entry.sha256).ToLowerInvariant()

  if ($expectHash -notmatch '^[0-9a-f]{64}$') {
    throw "Manifest entry '$relPath' has invalid sha256 (expected 64 hex chars): $expectHash"
  }

  $dest    = Join-Path $DriversRoot $relPath
  $destDir = Split-Path -Path $dest -Parent
  New-Item -ItemType Directory -Force -Path $destDir | Out-Null

  Write-Host "Fetching: $relPath"
  Write-Host "  URL: $url"

  $download = $true

  if (Test-Path -LiteralPath $dest) {
    $actual = Get-Sha256 $dest
    if ($actual -eq $expectHash) {
      Write-Host "  OK: already present and verified"
      $download = $false
    } else {
      Write-Host "  ERROR: existing file hash mismatch"
      Remove-Item -LiteralPath $dest -Force
    }
  }

  if ($download) {
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing

    Write-Host "  Verifying SHA-256..."
    $actual = Get-Sha256 $dest

    if ($actual -ne $expectHash) {
      Remove-Item -LiteralPath $dest -Force
      throw "SHA-256 mismatch for '$relPath'. Expected $expectHash but got $actual"
    }

    Write-Host "  OK: verified"
  }
}

Write-Host "All CABs downloaded and verified successfully."
