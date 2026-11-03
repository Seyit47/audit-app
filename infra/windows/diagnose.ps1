#Requires -RunAsAdministrator
<#
  Collects what is needed to see why the Audit services are not running: the services and how Windows
  starts them, what is listening, the Service Control Manager events since the last boot, and the end of
  every service log. Everything is also written to diagnose.txt next to this script - send that file.

  Run in an elevated PowerShell, from this folder:
    powershell -ExecutionPolicy Bypass -File .\diagnose.ps1
#>
$Root = $PSScriptRoot
$out = Join-Path $Root 'diagnose.txt'
$cfg = Get-Content (Join-Path $Root 'settings.json') -Raw | ConvertFrom-Json
$Suffix = if ($cfg.instance) { "-$($cfg.instance)" } else { '' }
Start-Transcript -Path $out -Force | Out-Null

function Title ($t) { Write-Host "`n== $t" -ForegroundColor Cyan }

Title 'Windows'
$boot = (Get-Date) - [TimeSpan]::FromMilliseconds([Environment]::TickCount64)
Write-Host "last boot: $boot   now: $(Get-Date)"

Title 'Clock'
# The API stamps 'last activity' and when pings arrive with this clock: it must agree with real UTC.
Write-Host "time zone : $((Get-TimeZone).Id)  ($((Get-TimeZone).DisplayName))"
Write-Host "local time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "UTC       : $([DateTime]::UtcNow.ToString('yyyy-MM-dd HH:mm:ss'))   <- compare with https://time.is/UTC"
try {
  $r = Invoke-WebRequest -UseBasicParsing -Method Head 'https://www.google.com' -TimeoutSec 10
  $real = [DateTime]::Parse($r.Headers['Date']).ToUniversalTime()
  $off = [Math]::Round(([DateTime]::UtcNow - $real).TotalMinutes)
  Write-Host "internet UTC: $($real.ToString('yyyy-MM-dd HH:mm:ss'))   this server is $off minutes $(if ($off -ge 0) { 'ahead' } else { 'behind' })"
  if ([Math]::Abs($off) -gt 2) { Write-Host 'CLOCK IS WRONG: fix with  w32tm /resync  (or set the time by hand) - see README-SERVICES.txt' -ForegroundColor Red }
} catch { Write-Host "could not read the internet time: $_" }

Title 'Services'
Get-Service | Where-Object { $_.Name -like 'audit-*' -or $_.Name -like 'postgresql*' } |
  Format-Table Name, Status, StartType, DisplayName -AutoSize | Out-String | Write-Host
$own = @('audit-storage', 'audit-api', 'audit-web') + $(if ($cfg.installTiles -eq $false) { @() } else { @('audit-tiles') }) + $(if ($cfg.installRouting -eq $false) { @() } else { @('audit-routing') })
foreach ($s in ($own | ForEach-Object { "$_$Suffix" })) {
  if (-not (Get-Service -Name $s -ErrorAction SilentlyContinue)) { Write-Host "$s : NOT INSTALLED (run install.ps1)" -ForegroundColor Yellow; continue }
  Write-Host "-- $s"
  & sc.exe qc $s | Select-String 'START_TYPE|DEPENDENCIES|BINARY_PATH_NAME' | ForEach-Object { $_.ToString().Trim() }
  & sc.exe qfailure $s | Select-String 'RESET_PERIOD|FAILURE_ACTIONS|RESTART' | ForEach-Object { $_.ToString().Trim() }
}

Title 'Listening TCP ports'
$ports = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners() | ForEach-Object { $_.Port } | Sort-Object -Unique
Write-Host ($ports -join ' ')
foreach ($p in @($cfg.storagePort, $cfg.apiPort, $cfg.webPort, $(if ($cfg.tilesPort) { $cfg.tilesPort } else { 3200 }), $(if ($cfg.routingPort) { $cfg.routingPort } else { 8989 }), 5432)) {
  Write-Host ("port {0,-6} {1}" -f $p, $(if ($ports -contains $p) { 'listening' } else { 'closed' }))
}

Title 'Service Control Manager events since boot (audit / postgres)'
try {
  Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'Service Control Manager'; StartTime = $boot } -ErrorAction Stop |
    Where-Object { $_.Message -match 'audit|postgres' } | Select-Object -First 60 TimeCreated, Id, Message |
    Format-Table -Wrap -AutoSize | Out-String -Width 200 | Write-Host
} catch { Write-Host "no events: $_" }

Title 'Service logs (last 40 lines of the newest files)'
$logs = Join-Path $Root 'logs'
if (Test-Path $logs) {
  Get-ChildItem $logs -Filter 'audit-*' | Sort-Object LastWriteTime -Descending | Select-Object -First 10 | ForEach-Object {
    Write-Host "`n---- $($_.Name)  ($($_.LastWriteTime), $([math]::Round($_.Length / 1KB)) KB)" -ForegroundColor Yellow
    Get-Content $_.FullName -Tail 40
  }
} else { Write-Host "no logs folder at $logs" }

Stop-Transcript | Out-Null
Write-Host "`nWritten to $out - send this file." -ForegroundColor Green
