#Requires -RunAsAdministrator
<#
  Starts the Audit services in order (storage, API, map, directions, web admin) and waits for each one's
  port. For after a reboot when something did not come up by itself. Does not change any settings.

  Run in an elevated PowerShell, from this folder:
    powershell -ExecutionPolicy Bypass -File .\start.ps1
#>
$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot
$cfg = Get-Content (Join-Path $Root 'settings.json') -Raw | ConvertFrom-Json
function Setting ($name, $default) { if ($null -ne $cfg.$name) { $cfg.$name } else { $default } }
$Suffix = if ($cfg.instance) { "-$($cfg.instance)" } else { '' }

function Wait-Port ($port, $seconds) {
  $deadline = (Get-Date).AddSeconds($seconds)
  while ((Get-Date) -lt $deadline) {
    $client = New-Object Net.Sockets.TcpClient
    try { $client.Connect('127.0.0.1', $port); return $true } catch { Start-Sleep -Milliseconds 500 } finally { $client.Dispose() }
  }
  return $false
}

# The database first, when it runs on this machine as a service.
$pg = Get-Service | Where-Object { $_.Name -like 'postgresql*' } | Select-Object -First 1
if ($pg -and $pg.Status -ne 'Running') { Write-Host "starting $($pg.Name)"; Start-Service $pg.Name }

$order = @(
  @("audit-storage$Suffix", $cfg.storagePort, 60),
  @("audit-api$Suffix", $cfg.apiPort, 90)
)
if (Setting 'installTiles' $true) { $order += , @("audit-tiles$Suffix", (Setting 'tilesPort' 3200), 60) }
if (Setting 'installRouting' $true) { $order += , @("audit-routing$Suffix", (Setting 'routingPort' 8989), 300) }
$order += , @("audit-web$Suffix", $cfg.webPort, 60)
$failed = @()
foreach ($entry in $order) {
  $name, $port, $wait = $entry
  if (-not (Get-Service -Name $name -ErrorAction SilentlyContinue)) {
    Write-Host "$name : not installed - run install.ps1" -ForegroundColor Red; $failed += $name; continue
  }
  if ((Get-Service $name).Status -ne 'Running') { Start-Service $name -ErrorAction Continue }
  if (Wait-Port $port $wait) { Write-Host "$name : up on port $port" -ForegroundColor Green }
  else { Write-Host "$name : NOT listening on port $port after $wait s - see logs\$name.*.log" -ForegroundColor Red; $failed += $name }
}
if ($failed.Count -eq 0) { Write-Host "`nAll services are up." -ForegroundColor Green }
else { Write-Host "`nNot running: $($failed -join ', '). Run diagnose.ps1 and send diagnose.txt." -ForegroundColor Yellow }
