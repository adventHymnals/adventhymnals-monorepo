# PowerShell script to run the Flutter app directly and capture crash info
param(
    [switch]$AsAdmin,
    [string]$TestApp = "main_empty"
)

Write-Host "🚀 Running Flutter Windows app directly..." -ForegroundColor Green

# Check if we need to run as admin
if (-not $AsAdmin -and -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "⚠️  Not running as Administrator. Restarting with admin privileges..." -ForegroundColor Yellow
    Start-Process PowerShell -Verb RunAs -ArgumentList "-File `"$PSCommandPath`" -AsAdmin -TestApp `"$TestApp`""
    exit
}

Write-Host "👑 Running as Administrator" -ForegroundColor Green

# Build the specified test app
Write-Host "🔨 Building test app: $TestApp.dart" -ForegroundColor Yellow
$buildResult = & flutter build windows --debug -t "lib\$TestApp.dart" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    Write-Host $buildResult
    exit 1
}

Write-Host "✅ Build completed" -ForegroundColor Green

# Check for required files
$exePath = "build\windows\x64\runner\Debug\AdventHymnals.exe"
$appSoPath = "build\windows\x64\runner\Debug\data\app.so"

Write-Host "`n📁 Checking build outputs:" -ForegroundColor Yellow
if (Test-Path $exePath) {
    $exeInfo = Get-Item $exePath
    Write-Host "✅ AdventHymnals.exe ($($exeInfo.Length) bytes)" -ForegroundColor Green
} else {
    Write-Host "❌ AdventHymnals.exe missing!" -ForegroundColor Red
    exit 1
}

if (Test-Path $appSoPath) {
    $appSoInfo = Get-Item $appSoPath
    Write-Host "✅ app.so ($($appSoInfo.Length) bytes)" -ForegroundColor Green
} else {
    Write-Host "❌ app.so missing! This is likely the cause of the crash." -ForegroundColor Red
    
    # Try to find app.so anywhere in build directory
    Write-Host "🔍 Searching for app.so in build directory..." -ForegroundColor Yellow
    $foundAppSo = Get-ChildItem -Path "build" -Name "app.so" -Recurse -ErrorAction SilentlyContinue
    if ($foundAppSo) {
        Write-Host "Found app.so at: $foundAppSo" -ForegroundColor Cyan
    } else {
        Write-Host "No app.so found anywhere in build directory" -ForegroundColor Red
    }
}

# Try to run the executable directly
Write-Host "`n🎯 Attempting to run executable directly..." -ForegroundColor Yellow
Write-Host "If it crashes, check Windows Event Viewer > Application logs for details" -ForegroundColor Gray

try {
    # Set working directory to the executable's directory
    Push-Location "build\windows\x64\runner\Debug"
    
    Write-Host "Working directory: $(Get-Location)" -ForegroundColor Gray
    Write-Host "Starting AdventHymnals.exe..." -ForegroundColor Cyan
    
    # Start the process and wait briefly to see if it crashes immediately
    $process = Start-Process -FilePath ".\AdventHymnals.exe" -PassThru -WindowStyle Normal
    
    Start-Sleep -Seconds 2
    
    if ($process.HasExited) {
        Write-Host "❌ Process exited immediately with code: $($process.ExitCode)" -ForegroundColor Red
        Write-Host "This confirms the app is crashing on startup" -ForegroundColor Red
    } else {
        Write-Host "✅ Process is running (PID: $($process.Id))" -ForegroundColor Green
        Write-Host "Waiting 5 more seconds to see if it remains stable..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        
        if ($process.HasExited) {
            Write-Host "❌ Process crashed after a few seconds" -ForegroundColor Red
        } else {
            Write-Host "✅ Process appears stable! Letting it run..." -ForegroundColor Green
            Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Gray
            $process.WaitForExit()
        }
    }
} catch {
    Write-Host "❌ Error starting process: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Pop-Location
}

Write-Host "`n📋 Next steps if app crashed:" -ForegroundColor Yellow
Write-Host "1. Check Windows Event Viewer > Application for crash details" -ForegroundColor White
Write-Host "2. Install Visual C++ Redistributable if not present" -ForegroundColor White
Write-Host "3. Try with a completely fresh Flutter project" -ForegroundColor White
Write-Host "4. Verify Flutter installation with 'flutter doctor -v'" -ForegroundColor White