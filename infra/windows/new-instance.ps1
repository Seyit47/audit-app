#Requires -RunAsAdministrator
<#
  Creates a second, independent copy of the Audit server on this machine: its own folder, database,
  photo storage, keys, Windows services and ports. The street map and directions services of this copy
  are shared with it (they hold the same Turkmenistan data), unless -OwnMapServices is given.

  Run in an elevated PowerShell, from the folder of the existing server (C:\audit-server):
    powershell -ExecutionPolicy Bypass -File .\new-instance.ps1 -Name demo
  Options:
    -Name <name>         letters and digits, used in the folder (C:\audit-server-demo), the services
                         (audit-api-demo), the database and its login (audit_demo)
    -PortOffset 100      ports of the new copy = this copy's ports + offset (API 3100, web 3101,
                         storage 8433 for the defaults); or give -ApiPort -WebPort -StoragePort
    -DbPassword <pw>     the new database login's password (generated when omitted)
    -PostgresPassword    the postgres superuser's password, to create the database here; without it the
                         SQL is written next to the new settings.json for you to run in pgAdmin
    -OwnMapServices      also install a separate map and directions service for the copy (more RAM)
#>
param(
  [Parameter(Mandatory)][ValidatePattern('^[A-Za-z][A-Za-z0-9]{0,15}$')][string]$Name,
  [int]$PortOffset = 100,
  [int]$ApiPort = 0,
  [int]$WebPort = 0,
  [int]$StoragePort = 0,
  [string]$DbPassword = '',
  [string]$PostgresPassword = '',
  [switch]$OwnMapServices
)
$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot
$cfg = Get-Content (Join-Path $Root 'settings.json') -Raw | ConvertFrom-Json
if ($cfg.instance) { throw "Run this from the first (unnamed) server copy, not from instance '$($cfg.instance)'." }
function Setting ($name, $default) { if ($null -ne $cfg.$name) { $cfg.$name } else { $default } }
function Step ($text) { Write-Host "`n== $text" -ForegroundColor Cyan }
function Secret ($length) {
  $buf = New-Object byte[] ($length * 2)
  [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($buf)
  $clean = [Convert]::ToBase64String($buf) -replace '[^A-Za-z0-9]', ''
  $clean.Substring(0, [Math]::Min($length, $clean.Length))
}

$lower = $Name.ToLower()
$Target = Join-Path (Split-Path $Root -Parent) "$(Split-Path $Root -Leaf)-$lower"
if (Test-Path $Target) { throw "$Target already exists. Remove it (or pick another name) first." }
if ($ApiPort -eq 0) { $ApiPort = $cfg.apiPort + $PortOffset }
if ($WebPort -eq 0) { $WebPort = $cfg.webPort + $PortOffset }
if ($StoragePort -eq 0) { $StoragePort = $cfg.storagePort + $PortOffset }
if ($DbPassword -eq '') { $DbPassword = Secret 28 }
$dbName = "audit_$lower"
$masterPort = (Setting 'storageMasterPort' 29333) + $PortOffset
$volumePort = (Setting 'storageVolumePort' 28080) + $PortOffset
$filerPort = (Setting 'storageFilerPort' 28888) + $PortOffset
$tilesPort = Setting 'tilesPort' 3200
$routingPort = Setting 'routingPort' 8989
if ($OwnMapServices) { $tilesPort += $PortOffset; $routingPort += $PortOffset }
$dbUri = [Uri]$cfg.databaseUrl
$dbHost = $dbUri.Host; $dbPort = if ($dbUri.Port -gt 0) { $dbUri.Port } else { 5432 }

Step "Copying the server to $Target"
# Everything but this copy's data, logs, service files and settings. Map data only when the copy runs
# its own map services (tiles\data and routing\* are large).
$exclude = @('storage\data', 'logs', 'updates', 'services', 'diagnose.txt', 'settings.json')
if (-not $OwnMapServices) { $exclude += @('tiles', 'routing') }
$xd = $exclude | Where-Object { Test-Path (Join-Path $Root $_) -PathType Container } | ForEach-Object { Join-Path $Root $_ }
$xf = $exclude | Where-Object { Test-Path (Join-Path $Root $_) -PathType Leaf } | ForEach-Object { Join-Path $Root $_ }
& robocopy $Root $Target /E /NFL /NDL /NJH /NJS /NP /XD @xd /XF @xf | Out-Null
if ($LASTEXITCODE -ge 8) { throw "Copy failed (robocopy code $LASTEXITCODE)" }
New-Item -ItemType Directory -Force -Path (Join-Path $Target 'services'), (Join-Path $Target 'logs'), (Join-Path $Target 'storage\data'), (Join-Path $Target 'updates') | Out-Null
# One service wrapper (WinSW) to clone from; install.ps1 makes the named copies.
Copy-Item (Get-ChildItem (Join-Path $Root 'services') -Filter '*.exe' | Select-Object -First 1).FullName (Join-Path $Target 'services\audit-storage.exe')
Write-Host 'copied'

Step 'Writing settings.json'
$new = [ordered]@{
  instance = $lower
  publicHost = $cfg.publicHost
  apiPort = $ApiPort
  webPort = $WebPort
  storagePort = $StoragePort
  storageMasterPort = $masterPort
  storageVolumePort = $volumePort
  storageFilerPort = $filerPort
  tilesPort = $tilesPort
  routingPort = $routingPort
  installTiles = [bool]$OwnMapServices
  installRouting = [bool]$OwnMapServices
  databaseUrl = "postgresql://$($dbName):$DbPassword@$($dbHost):$dbPort/$dbName"
  jwtSecret = Secret 48
  storageAccessKey = Secret 20
  storageSecretKey = Secret 40
  storageBucket = $cfg.storageBucket
  satelliteTilesUrl = $cfg.satelliteTilesUrl
}
$new | ConvertTo-Json | Set-Content -Path (Join-Path $Target 'settings.json') -Encoding UTF8
Write-Host "API $ApiPort, web $WebPort, storage $StoragePort, database $dbName"

Step 'Creating the database'
$sql = "CREATE ROLE $dbName LOGIN PASSWORD '$DbPassword';`r`nCREATE DATABASE $dbName OWNER $dbName ENCODING 'UTF8';`r`n"
$sqlFile = Join-Path $Target 'database.sql'
Set-Content -Path $sqlFile -Value ("-- Run once as the postgres superuser (pgAdmin Query Tool, or psql -U postgres -f database.sql).`r`n" + $sql) -Encoding ASCII
$psql = Get-ChildItem 'C:\Program Files\PostgreSQL\*\bin\psql.exe' -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1
$created = $false
if ($psql -and $PostgresPassword -ne '') {
  $env:PGPASSWORD = $PostgresPassword
  try {
    & $psql.FullName -h $dbHost -p $dbPort -U postgres -v ON_ERROR_STOP=1 -f $sqlFile
    $created = $LASTEXITCODE -eq 0
  } finally { Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue }
}
if (-not $created) {
  Write-Host "Not created here. Run $sqlFile as the postgres superuser (pgAdmin: Query Tool > open file > run)," -ForegroundColor Yellow
  Write-Host "then, in PowerShell as Administrator:  cd $Target ; powershell -ExecutionPolicy Bypass -File .\install.ps1" -ForegroundColor Yellow
  return
}
Write-Host "database $dbName created"

Step 'Installing the services'
Push-Location $Target
try { & powershell -ExecutionPolicy Bypass -File (Join-Path $Target 'install.ps1') } finally { Pop-Location }
if ($LASTEXITCODE -ne 0) { throw "install.ps1 failed in $Target - see its output above" }

Step 'Done'
Write-Host "Folder:     $Target"
Write-Host "Web admin:  http://$($cfg.publicHost):$WebPort"
Write-Host "API:        http://$($cfg.publicHost):$ApiPort   (mobile app server address: IP $($cfg.publicHost), port $ApiPort, HTTPS off)"
Write-Host "First admin (once):  cd $Target ; .\admin.ps1 create you@company.tm <password>"
Write-Host "Updates for it:      unzip a bundle's api, web, node and install.ps1 into $Target, then run its install.ps1"
