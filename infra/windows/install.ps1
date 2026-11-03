#Requires -RunAsAdministrator
<#
  Installs (or updates) the Audit server on this Windows machine as Windows services:
    audit-storage  SeaweedFS: photo and export files (S3-compatible), files in storage\data
    audit-api      the API (Node.js), which the mobile app and the web admin talk to
    audit-web      the web admin (Next.js)
    audit-tiles    the street map (Martin: vector tiles and label fonts from tiles\)
    audit-routing  directions to shops (GraphHopper, with its own Java in routing\jre; 127.0.0.1 only)
  Settings come from settings.json. Run it again after editing settings.json or copying a newer bundle.

  Run in an elevated PowerShell, from this folder:
    powershell -ExecutionPolicy Bypass -File .\install.ps1
#>
$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot
$cfg = Get-Content (Join-Path $Root 'settings.json') -Raw | ConvertFrom-Json
$Node = Join-Path $Root 'node\node.exe'
# A second copy of the server on this machine (new-instance.ps1) has a name: its services, firewall rules
# and wrapper files carry it (audit-api-demo). The first copy has none. Such a copy can also use the first
# one's map and directions services instead of its own (installTiles / installRouting = false).
$Suffix = if ($cfg.instance) { "-$($cfg.instance)" } else { '' }
$Services = @('audit-web', 'audit-tiles', 'audit-routing', 'audit-api', 'audit-storage') | ForEach-Object { "$_$Suffix" }   # stop order

function Step ($text) { Write-Host "`n== $text" -ForegroundColor Cyan }
function X ([string]$s) { [System.Security.SecurityElement]::Escape($s) }

function Wait-Port ($port, $seconds) {
  $deadline = (Get-Date).AddSeconds($seconds)
  while ((Get-Date) -lt $deadline) {
    $client = New-Object Net.Sockets.TcpClient
    try { $client.Connect('127.0.0.1', $port); return $true } catch { Start-Sleep -Milliseconds 500 } finally { $client.Dispose() }
  }
  return $false
}

function Write-Service ($id, $name, $description, $exe, $arguments, $workdir, [hashtable]$envVars, $depends) {
  $envXml = ($envVars.GetEnumerator() | Sort-Object Name | ForEach-Object { "  <env name=`"$($_.Name)`" value=`"$(X $_.Value)`"/>" }) -join "`r`n"
  $dependXml = (@($depends) | Where-Object { $_ } | ForEach-Object { "  <depend>$_</depend>" }) -join "`r`n"
  $xml = @"
<service>
  <id>$id</id>
  <name>$name</name>
  <description>$description</description>
  <executable>$(X $exe)</executable>
  <arguments>$(X $arguments)</arguments>
  <workingdirectory>$(X $workdir)</workingdirectory>
  <startmode>Automatic</startmode>
  <delayedAutoStart>true</delayedAutoStart>
  <stoptimeout>20 sec</stoptimeout>
  <onfailure action="restart" delay="10 sec"/>
  <onfailure action="restart" delay="30 sec"/>
  <onfailure action="restart" delay="60 sec"/>
  <resetfailure>1 hour</resetfailure>
  <logpath>$(X (Join-Path $Root 'logs'))</logpath>
  <log mode="roll-by-size"><sizeThreshold>10240</sizeThreshold><keepFiles>8</keepFiles></log>
$dependXml
$envXml
</service>
"@
  Set-Content -Path (Join-Path $Root "services\$id.xml") -Value $xml -Encoding UTF8
  # The service wrapper (WinSW) is one program under each service's name: a named instance gets its own copies.
  $wrapper = Join-Path $Root "services\$id.exe"
  if (-not (Test-Path $wrapper)) { Copy-Item (Get-ChildItem (Join-Path $Root 'services') -Filter '*.exe' | Select-Object -First 1).FullName $wrapper }
}

# SeaweedFS's internal servers (127.0.0.1 only), on uncommon ports so they don't clash with other web servers.
# Each also uses its port + 10000 for gRPC. Override in settings.json if needed.
function Setting ($name, $default) { if ($null -ne $cfg.$name) { $cfg.$name } else { $default } }
$masterPort = Setting 'storageMasterPort' 29333
$volumePort = Setting 'storageVolumePort' 28080
$filerPort = Setting 'storageFilerPort' 28888
# The street map (Martin), served to the web admin and the mobile app.
$tilesPort = Setting 'tilesPort' 3200
$tilesBase = "http://$($cfg.publicHost):$tilesPort"
# Directions (GraphHopper), asked only by the API on this machine; its admin port is the next one.
$routingPort = Setting 'routingPort' 8989
$installTiles = Setting 'installTiles' $true
$installRouting = Setting 'installRouting' $true

$publicStorage = "http://$($cfg.publicHost):$($cfg.storagePort)"
$webOrigin = "http://$($cfg.publicHost):$($cfg.webPort)"

Step 'Stopping the running Audit services (if any)'
# Only stopped here. Each service is replaced right before its own (re)install below, so a run that fails
# midway (migrations, a busy port) leaves every service registered and starting with Windows.
foreach ($s in $Services) {
  if (Get-Service -Name $s -ErrorAction SilentlyContinue) {
    Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
    Write-Host "stopped $s"
  }
}
Start-Sleep -Seconds 2

# Replaces the service registration with the XML just written, then starts it.
function Install-Service ($id) {
  if (Get-Service -Name $id -ErrorAction SilentlyContinue) {
    Stop-Service -Name $id -Force -ErrorAction SilentlyContinue
    & sc.exe delete $id | Out-Null
    Start-Sleep -Seconds 1
  }
  & (Join-Path $Root "services\$id.exe") install | Out-Null
  Start-Service $id
}

# The database server on this machine, if any: the API waits for it at boot.
$dbHost = ([Uri]$cfg.databaseUrl).Host
$pgService = if ($dbHost -in @('localhost', '127.0.0.1', '::1')) { (Get-Service | Where-Object { $_.Name -like 'postgresql*' } | Select-Object -First 1).Name } else { $null }
if ($pgService) { Write-Host "database service: $pgService" }

Step 'Checking the ports are free'
# API, web, storage (S3 and its gRPC port), and SeaweedFS's internal master / volume / filer ports (+ gRPC).
# Read straight from .NET: Get-NetTCPConnection goes through WMI, which can hang on busy servers.
$ports = @($cfg.apiPort, $cfg.webPort, $cfg.storagePort, ($cfg.storagePort + 10000), $masterPort, ($masterPort + 10000), $volumePort, ($volumePort + 10000), $filerPort, ($filerPort + 10000))
if ($installTiles) { $ports += $tilesPort }
if ($installRouting) { $ports += @($routingPort, ($routingPort + 1)) }
$listening = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners() | ForEach-Object { $_.Port }
$busy = foreach ($p in $ports | Where-Object { $listening -contains $_ }) {
  $owner = netstat -ano -p tcp | Select-String 'LISTENING' | Where-Object { $_ -match ":$p\s" } | Select-Object -First 1
  $procId = if ($owner) { ($owner.ToString().Trim() -split '\s+')[-1] } else { $null }
  $name = if ($procId) { (Get-Process -Id $procId -ErrorAction SilentlyContinue).ProcessName } else { '?' }
  "$p (used by $name, PID $procId)"
}
if ($busy) { throw "These ports are already in use: $($busy -join ', '). Free them or change the ports in settings.json." }
Write-Host 'ok'

Step 'Writing the service definitions'
New-Item -ItemType Directory -Force -Path (Join-Path $Root 'logs'), (Join-Path $Root 'storage\data') | Out-Null
@{ identities = @(@{ name = 'audit'; credentials = @(@{ accessKey = $cfg.storageAccessKey; secretKey = $cfg.storageSecretKey }); actions = @('Admin', 'Read', 'Write', 'List', 'Tagging') }) } |
  ConvertTo-Json -Depth 6 | Set-Content -Path (Join-Path $Root 'storage\s3.json') -Encoding ASCII

# SeaweedFS: internal servers on 127.0.0.1 only; the S3 port on all interfaces (phones and browsers load photos from it).
$weedArgs = "server -dir=`"$(Join-Path $Root 'storage\data')`" -ip=127.0.0.1 -s3 -s3.ip.bind=0.0.0.0 -s3.port=$($cfg.storagePort) " +
  "-master.port=$masterPort -volume.port=$volumePort -filer.port=$filerPort " +
  "-s3.config=`"$(Join-Path $Root 'storage\s3.json')`" -s3.port.iceberg=0 -s3.port.lance=0 -master.volumeSizeLimitMB=1024 -volume.max=0"
Write-Service "audit-storage$Suffix" "Audit storage$Suffix" 'Photo and export files (SeaweedFS, S3 API)' (Join-Path $Root 'storage\weed.exe') $weedArgs (Join-Path $Root 'storage') @{} $null

New-Item -ItemType Directory -Force -Path (Join-Path $Root 'updates') | Out-Null
$apiEnv = @{
  NODE_ENV = 'production'
  # Times are shown in the company's time zone, whatever the server's own setting is.
  TZ = 'Asia/Ashgabat'
  DATABASE_URL = $cfg.databaseUrl
  JWT_SECRET = $cfg.jwtSecret
  S3_ENDPOINT = "http://127.0.0.1:$($cfg.storagePort)"
  S3_PUBLIC_ENDPOINT = $publicStorage
  S3_BUCKET = $cfg.storageBucket
  S3_ACCESS_KEY = $cfg.storageAccessKey
  S3_SECRET_KEY = $cfg.storageSecretKey
  WEB_ORIGIN = $webOrigin
  SATELLITE_TILES_URL = $cfg.satelliteTilesUrl
  ROUTING_URL = "http://127.0.0.1:$routingPort"
  # The mobile app's updates: latest.json and the APK, uploaded by FTP (FTP-UPDATES.txt).
  UPDATES_DIR = (Join-Path $Root 'updates')
}
$apiArgs = "`"$(Join-Path $Root 'api\node_modules\fastify-cli\cli.js')`" start --options -a 0.0.0.0 -p $($cfg.apiPort) -l info dist/app.js"
Write-Service "audit-api$Suffix" "Audit API$Suffix" 'API for the mobile app and the web admin' $Node $apiArgs (Join-Path $Root 'api') $apiEnv @("audit-storage$Suffix", $pgService)

$webEnv = @{
  NODE_ENV = 'production'
  # Times are shown in the company's time zone, whatever the server's own setting is.
  TZ = 'Asia/Ashgabat'
  PORT = "$($cfg.webPort)"
  HOSTNAME = '0.0.0.0'
  API_URL = "http://127.0.0.1:$($cfg.apiPort)"
  SECURE_COOKIES = 'false'
  # Browsers share cookies between ports of one host: a named instance keeps its session cookies apart.
  COOKIE_PREFIX = $(if ($Suffix) { "$($cfg.instance)_" } else { '' })
  SATELLITE_TILES_URL = $cfg.satelliteTilesUrl
  MAP_TILES_URL = "$tilesBase/openmaptiles"
  MAP_GLYPHS_URL = "$tilesBase/font/{fontstack}/{range}"
}
Write-Service "audit-web$Suffix" "Audit web admin$Suffix" 'Web admin (Next.js)' $Node "`"$(Join-Path $Root 'web\server.js')`"" (Join-Path $Root 'web') $webEnv "audit-api$Suffix"

if ($installTiles) {
# Martin: the Turkmenistan street map (OpenMapTiles schema) and its label font. Single-quoted YAML keeps
# Windows backslashes as they are.
$martinYaml = @"
listen_addresses: '0.0.0.0:$tilesPort'
cache_size_mb: 128
mbtiles:
  sources:
    openmaptiles: '$(Join-Path $Root 'tiles\data\turkmenistan.mbtiles')'
fonts:
  - '$(Join-Path $Root 'tiles\fonts')'
"@
Set-Content -Path (Join-Path $Root 'tiles\martin.yaml') -Value $martinYaml -Encoding ASCII
Write-Service "audit-tiles$Suffix" "Audit map tiles$Suffix" 'Street map tiles and fonts (Martin)' (Join-Path $Root 'tiles\martin.exe') "--config `"$(Join-Path $Root 'tiles\martin.yaml')`"" (Join-Path $Root 'tiles') @{} $null
}

if ($installRouting) {
# GraphHopper: car routes on the roads of routing\turkmenistan.osm.pbf, its graph in routing\graph-cache.
$routingYaml = @"
graphhopper:
  datareader.file: '$(Join-Path $Root 'routing\turkmenistan.osm.pbf')'
  graph.location: '$(Join-Path $Root 'routing\graph-cache')'
  profiles:
    - name: car
      custom_model_files: [car.json]
  profiles_ch:
    - profile: car
  graph.encoded_values: car_access, car_average_speed, road_access
  prepare.min_network_size: 200
  import.osm.ignored_highways: footway,cycleway,path,pedestrian,steps,bridleway
  graph.dataaccess.default_type: RAM_STORE
server:
  application_connectors:
    - type: http
      port: $routingPort
      bind_host: 127.0.0.1
  admin_connectors:
    - type: http
      port: $($routingPort + 1)
      bind_host: 127.0.0.1
  request_log:
    appenders: []
logging:
  level: WARN
  loggers:
    com.graphhopper: INFO
"@
Set-Content -Path (Join-Path $Root 'routing\config.yml') -Value $routingYaml -Encoding ASCII
$routingArgs = "-Xms256m -Xmx1g -jar `"$(Join-Path $Root 'routing\graphhopper-web.jar')`" server `"$(Join-Path $Root 'routing\config.yml')`""
Write-Service "audit-routing$Suffix" "Audit directions$Suffix" 'Directions to shops (GraphHopper)' (Join-Path $Root 'routing\jre\bin\java.exe') $routingArgs (Join-Path $Root 'routing') @{} $null
}

Step 'Starting storage'
Install-Service "audit-storage$Suffix"
if (-not (Wait-Port $cfg.storagePort 60)) { throw "Storage did not start: see logs\audit-storage$Suffix.*.log" }
Write-Host "storage is up on port $($cfg.storagePort)"

Step 'Updating the database (migrations)'
$env:DATABASE_URL = $cfg.databaseUrl
$env:PRISMA_SCHEMA_ENGINE_BINARY = Join-Path $Root 'api\engines\schema-engine.exe'
$env:CHECKPOINT_DISABLE = '1'
Push-Location (Join-Path $Root 'api')
try {
  & $Node 'node_modules\prisma\build\index.js' migrate deploy
  if ($LASTEXITCODE -ne 0) { throw 'Database migrations failed: check databaseUrl in settings.json and that database.sql was run.' }
} finally { Pop-Location }

Step 'Starting the API'
Install-Service "audit-api$Suffix"
$deadline = (Get-Date).AddSeconds(90); $healthy = $false
while (-not $healthy -and (Get-Date) -lt $deadline) {
  try { $r = Invoke-WebRequest -UseBasicParsing "http://127.0.0.1:$($cfg.apiPort)/health" -TimeoutSec 5; $healthy = $r.StatusCode -eq 200 } catch { Start-Sleep -Seconds 2 }
}
if (-not $healthy) { throw "The API is not healthy: see logs\audit-api$Suffix.*.log" }
Write-Host "API is up on port $($cfg.apiPort)"

if ($installTiles) {
  Step 'Starting the map'
  Install-Service "audit-tiles$Suffix"
  if (-not (Wait-Port $tilesPort 60)) { throw "The map did not start: see logs\audit-tiles$Suffix.*.log" }
  Write-Host "map is up on port $tilesPort"
} else { Write-Host "map: using the service already on port $tilesPort" }

if ($installRouting) {
  Step 'Starting directions'
  Install-Service "audit-routing$Suffix"
  # The first start builds the road graph (a minute or two); later starts load it.
  if (-not (Wait-Port $routingPort 300)) { throw "Directions did not start: see logs\audit-routing$Suffix.*.log" }
  Write-Host "directions are up (127.0.0.1:$routingPort)"
} else { Write-Host "directions: using the service already on 127.0.0.1:$routingPort" }

Step 'Starting the web admin'
Install-Service "audit-web$Suffix"
if (-not (Wait-Port $cfg.webPort 60)) { throw "The web admin did not start: see logs\audit-web$Suffix.*.log" }
Write-Host "web admin is up on port $($cfg.webPort)"

Step 'Opening the firewall'
$rules = @{ "Audit API$Suffix ($($cfg.apiPort))" = $cfg.apiPort; "Audit web admin$Suffix ($($cfg.webPort))" = $cfg.webPort; "Audit storage$Suffix ($($cfg.storagePort))" = $cfg.storagePort }
if ($installTiles) { $rules["Audit map$Suffix ($tilesPort)"] = $tilesPort }
foreach ($name in $rules.Keys) {
  # netsh, not the NetSecurity cmdlets: those go through WMI too.
  & netsh advfirewall firewall show rule name="$name" | Out-Null
  if ($LASTEXITCODE -ne 0) {
    & netsh advfirewall firewall add rule name="$name" dir=in action=allow protocol=TCP localport=$($rules[$name]) | Out-Null
    Write-Host "allowed $name"
  }
}

# The first copy brings the other instances on this machine (new-instance.ps1) to this version too, so
# one update covers all of them. "updateInstances": false in settings.json turns that off.
if (-not $Suffix -and (Setting 'updateInstances' $true) -and (Test-Path (Join-Path $Root 'update-instances.ps1'))) {
  Step 'Updating the other instances on this machine'
  & powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'update-instances.ps1')
  if ($LASTEXITCODE -ne 0) { Write-Host 'Some instances were not updated: see above, then run update-instances.ps1 again.' -ForegroundColor Yellow }
}

Step 'Done'
Write-Host "Web admin:  $webOrigin"
Write-Host "API:        http://$($cfg.publicHost):$($cfg.apiPort)   (mobile app server address)"
Write-Host "Map:        $tilesBase/catalog"
Write-Host "First admin account (once):  .\admin.ps1 create you@company.tm <password>"
