param(
  [string]$ManifestPath = ".\tools\wu-manifest.json",
  [string]$DriversRoot  = ".\drivers"
)

if (!(Test-Path $ManifestPath)) {
  throw "Manifest not found: $ManifestPath"
}

$manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json

foreach ($entry in $manifest.PSObject.Properties) {
  $relPath = $entry.Name
  $meta    = $entry.Value
  $url     = $meta.url
  $expect  = $meta.sha256.ToLower()

  $dest = Join-Path $DriversRoot $relPath
  $dir  = Split-Path $dest -Parent

  New-Item -ItemType Directory -Force -Path $dir | Out-Null

  Write-Host "⬇️  Downloading $relPath"
  Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing

  Write-Host "🔐 Verifying SHA-256"
  $actual = (Get-FileHash $dest -Algorithm SHA256).Hash.ToLower()

  if ($actual -ne $expect) {
    Remove-Item $dest -Force
    throw "SHA-256 mismatch for $relPath`nExpected: $expect`nActual:   $actual"
  }

  Write-Host "✅ Verified"
}

Write-Host "🎉 All CABs downloaded and verified successfully"
