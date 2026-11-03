#Requires -RunAsAdministrator
<#
  Brings every other Audit server on this machine (C:\audit-server-<name>, made by new-instance.ps1) to
  this folder's version: stops its services, mirrors the program folders (api, web, node, and the map
  folders when it runs its own map services) and the scripts, keeps its settings.json, photos, logs and
  updates, then runs its install.ps1. The first server's install.ps1 runs this at its end, so one update
  covers every copy; it can also be run on its own.

  Run in an elevated PowerShell, from the first server's folder:
    powershell -ExecutionPolicy Bypass -File .\update-instances.ps1
#>
$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot
$cfg = Get-Content (Join-Path $Root 'settings.json') -Raw | ConvertFrom-Json
if ($cfg.instance) { throw "Run this from the first (unnamed) server copy, not from instance '$($cfg.instance)'." }

$parent = Split-Path $Root -Parent
$leaf = Split-Path $Root -Leaf
$instances = @(Get-ChildItem $parent -Directory -Filter "$leaf-*" | Where-Object { Test-Path (Join-Path $_.FullName 'settings.json') } |
  ForEach-Object {
    $icfg = Get-Content (Join-Path $_.FullName 'settings.json') -Raw | ConvertFrom-Json
    if ($icfg.instance) { [pscustomobject]@{ Dir = $_.FullName; Name = $_.Name; Cfg = $icfg } }
  })
if ($instances.Count -eq 0) { Write-Host 'No other instances on this machine.'; return }

# Mirrors a folder: files that changed are copied, files gone from the source are removed. Few retries:
# a locked file must fail fast, not hang (the copy's services are stopped first for that reason).
function Mirror ($from, $to, [string[]]$excludeDirs) {
  $args = @($from, $to, '/MIR', '/NFL', '/NDL', '/NJH', '/NJS', '/NP', '/R:2', '/W:2')
  if ($excludeDirs) { $args += '/XD'; $args += ($excludeDirs | ForEach-Object { Join-Path $from $_ }) }
  & robocopy @args | Out-Null
  if ($LASTEXITCODE -ge 8) { throw "Copying $from failed (robocopy code $LASTEXITCODE)" }
}

$failed = @()
foreach ($inst in $instances) {
  $suffix = "-$($inst.Cfg.instance)"
  Write-Host "`n== $($inst.Name) (instance '$($inst.Cfg.instance)')" -ForegroundColor Cyan
  try {
    foreach ($s in 'audit-web', 'audit-tiles', 'audit-routing', 'audit-api', 'audit-storage') {
      if (Get-Service -Name "$s$suffix" -ErrorAction SilentlyContinue) { Stop-Service -Name "$s$suffix" -Force -ErrorAction SilentlyContinue }
    }
    Start-Sleep -Seconds 2
    foreach ($dir in 'api', 'web', 'node') { Mirror (Join-Path $Root $dir) (Join-Path $inst.Dir $dir) $null; Write-Host "  $dir updated" }
    if ($inst.Cfg.installTiles -ne $false -and (Test-Path (Join-Path $Root 'tiles'))) { Mirror (Join-Path $Root 'tiles') (Join-Path $inst.Dir 'tiles') $null; Write-Host '  tiles updated' }
    if ($inst.Cfg.installRouting -ne $false -and (Test-Path (Join-Path $Root 'routing'))) { Mirror (Join-Path $Root 'routing') (Join-Path $inst.Dir 'routing') @('graph-cache'); Write-Host '  routing updated' }
    # Scripts and notes; never settings.json or database.sql (the copy's own).
    Get-ChildItem $Root -File | Where-Object { $_.Extension -in '.ps1', '.txt' } | Copy-Item -Destination $inst.Dir -Force
    & powershell -ExecutionPolicy Bypass -File (Join-Path $inst.Dir 'install.ps1')
    if ($LASTEXITCODE -ne 0) { throw "its install.ps1 failed (see above)" }
    Write-Host "  $($inst.Name): up to date" -ForegroundColor Green
  } catch {
    Write-Host "  $($inst.Name): FAILED - $_" -ForegroundColor Red
    $failed += $inst.Name
  }
}
if ($failed.Count -gt 0) { throw "Not updated: $($failed -join ', ')" }
Write-Host "`nAll instances are up to date." -ForegroundColor Green
