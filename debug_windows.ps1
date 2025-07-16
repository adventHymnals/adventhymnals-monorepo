Write-Host "Starting Advent Hymnals Debug (PowerShell)" -ForegroundColor Green
Write-Host ""
Write-Host "App ID: com.adventhymnals.org"
Write-Host "Expected hymns: 1099"
Write-Host ""

# Check if executable exists
if (Test-Path "advent-hymnals-test\AdventHymnals.exe") {
    Write-Host "✓ Executable found" -ForegroundColor Green
} else {
    Write-Host "✗ Executable NOT found" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check assets
if (Test-Path "advent-hymnals-test\data\flutter_assets") {
    Write-Host "✓ Flutter assets found" -ForegroundColor Green
} else {
    Write-Host "✗ Flutter assets NOT found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Starting application with 60-second timeout..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop if it hangs"
Write-Host ""

# Start process with timeout
$process = Start-Process -FilePath "advent-hymnals-test\AdventHymnals.exe" -PassThru -NoNewWindow

# Wait for 60 seconds
$timeout = 60
$timer = 0
while (!$process.HasExited -and $timer -lt $timeout) {
    Start-Sleep -Seconds 1
    $timer++
    if ($timer % 10 -eq 0) {
        Write-Host "Still running... ($timer seconds)" -ForegroundColor Yellow
    }
}

if (!$process.HasExited) {
    Write-Host "Application hung after $timeout seconds. Killing process..." -ForegroundColor Red
    $process.Kill()
    Write-Host "Process killed" -ForegroundColor Red
} else {
    Write-Host "Application exited normally with code: $($process.ExitCode)" -ForegroundColor Green
}

Read-Host "Press Enter to exit"