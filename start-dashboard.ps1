$ErrorActionPreference = "Stop"

$projectRoot = "C:\Users\dixie\OneDrive\Documents\New project"
$backendHealthUrl = "http://127.0.0.1:8080/api/health"
$healthUrl = "http://127.0.0.1:3001/api/health"
$appUrl = "http://127.0.0.1:3001/?fresh=31"
$logPath = Join-Path $projectRoot "server-all.log"
$backendLogPath = Join-Path $projectRoot "backend-all.log"

Set-Location $projectRoot
Write-Host "Checking backend on port 8080..."

$backendListener = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $backendListener) {
  Write-Host "Starting Market AI backend in background..."
  Start-Process -WindowStyle Minimized -FilePath "cmd.exe" -ArgumentList "/c", "cd /d `"$projectRoot`" && npm run start:backend >> `"$backendLogPath`" 2>&1"
} else {
  Write-Host ("Backend already running (PID {0})." -f $backendListener.OwningProcess)
}

$backendReady = $false
for ($i = 1; $i -le 25; $i++) {
  try {
    $response = Invoke-WebRequest -UseBasicParsing $backendHealthUrl -TimeoutSec 2
    if ($response.StatusCode -eq 200) {
      $backendReady = $true
      break
    }
  } catch {
    Start-Sleep -Seconds 1
  }
}

if (-not $backendReady) {
  Write-Host "Backend did not become healthy in time. Check backend-all.log"
  exit 1
}

Write-Host "Checking web server on port 3001..."

$listener = Get-NetTCPConnection -LocalPort 3001 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $listener) {
  Write-Host "Starting web server in background..."
  Start-Process -WindowStyle Minimized -FilePath "cmd.exe" -ArgumentList "/c", "cd /d `"$projectRoot`" && set HTTP_PROXY= && set HTTPS_PROXY= && set ALL_PROXY= && node server.js >> `"$logPath`" 2>&1"
} else {
  Write-Host ("Web server already running (PID {0})." -f $listener.OwningProcess)
}

$ready = $false
for ($i = 1; $i -le 25; $i++) {
  try {
    $response = Invoke-WebRequest -UseBasicParsing $healthUrl -TimeoutSec 2
    if ($response.StatusCode -eq 200) {
      $ready = $true
      break
    }
  } catch {
    Start-Sleep -Seconds 1
  }
}

if ($ready) {
  Start-Process $appUrl
  Write-Host "Dashboard opened at $appUrl"
} else {
  Write-Host "Server did not become healthy in time. Check server-all.log"
  exit 1
}
