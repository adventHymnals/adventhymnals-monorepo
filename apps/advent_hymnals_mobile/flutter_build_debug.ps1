# Flutter Build Debug Script for Windows
# This script will run Flutter doctor and attempt to build the Windows app with verbose output

Write-Host "=== Flutter Build Debug Script ===" -ForegroundColor Cyan
Write-Host "Current Directory: $(Get-Location)" -ForegroundColor Yellow
Write-Host "Target Directory: C:\Users\surgb\Code\adventhymnals-monorepo\apps\advent_hymnals_mobile" -ForegroundColor Yellow

# Change to the Flutter project directory
Set-Location -Path "D:\Code\adventhymnals-monorepo\apps\advent_hymnals_mobile"

Write-Host "`n=== Step 1: Flutter Doctor ===" -ForegroundColor Green
Write-Host "Running 'flutter doctor' to check Flutter installation..." -ForegroundColor Yellow
try {
    flutter doctor
    Write-Host "Flutter doctor completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error running flutter doctor: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "This may indicate Flutter is not installed or not in PATH" -ForegroundColor Red
}

Write-Host "`n=== Step 2: Flutter Doctor -v (Verbose) ===" -ForegroundColor Green
Write-Host "Running 'flutter doctor -v' for detailed information..." -ForegroundColor Yellow
try {
    flutter doctor -v
    Write-Host "Flutter doctor -v completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error running flutter doctor -v: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Step 3: Flutter Config ===" -ForegroundColor Green
Write-Host "Enabling Windows desktop support..." -ForegroundColor Yellow
try {
    flutter config --enable-windows-desktop
    Write-Host "Windows desktop support enabled successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error enabling Windows desktop support: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Step 4: Flutter Pub Get ===" -ForegroundColor Green
Write-Host "Running 'flutter pub get' to install dependencies..." -ForegroundColor Yellow
try {
    flutter pub get
    Write-Host "Flutter pub get completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error running flutter pub get: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Step 5: Flutter Clean ===" -ForegroundColor Green
Write-Host "Running 'flutter clean' to clear build cache..." -ForegroundColor Yellow
try {
    flutter clean
    Write-Host "Flutter clean completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error running flutter clean: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Step 6: Flutter Build Windows (Debug) ===" -ForegroundColor Green
Write-Host "Running 'flutter build windows --debug --verbose' to build Windows app..." -ForegroundColor Yellow
try {
    flutter build windows --debug --verbose
    Write-Host "Flutter build windows (debug) completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error running flutter build windows (debug): $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Step 7: Flutter Build Windows (Release) ===" -ForegroundColor Green
Write-Host "Running 'flutter build windows --release --verbose' to build Windows app..." -ForegroundColor Yellow
try {
    flutter build windows --release --verbose
    Write-Host "Flutter build windows (release) completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error running flutter build windows (release): $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Build Summary ===" -ForegroundColor Cyan
Write-Host "Checking for build outputs..." -ForegroundColor Yellow

# Check for build outputs
$debugPath = "build\windows\x64\runner\Debug"
$releasePath = "build\windows\x64\runner\Release"

if (Test-Path $debugPath) {
    Write-Host "✓ Debug build found at: $debugPath" -ForegroundColor Green
    Get-ChildItem -Path $debugPath -Name | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
} else {
    Write-Host "✗ Debug build not found at: $debugPath" -ForegroundColor Red
}

if (Test-Path $releasePath) {
    Write-Host "✓ Release build found at: $releasePath" -ForegroundColor Green
    Get-ChildItem -Path $releasePath -Name | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
} else {
    Write-Host "✗ Release build not found at: $releasePath" -ForegroundColor Red
}

Write-Host "`n=== Script Complete ===" -ForegroundColor Cyan
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")