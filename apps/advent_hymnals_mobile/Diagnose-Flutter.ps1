# PowerShell script to diagnose Flutter Windows setup
Write-Host "🔍 Diagnosing Flutter Windows setup..." -ForegroundColor Green

# Check Flutter version and configuration
Write-Host "`n📋 Flutter Doctor:" -ForegroundColor Yellow
flutter doctor -v

# Check if all required files exist
Write-Host "`n📁 Checking build files:" -ForegroundColor Yellow
$buildPath = "build\windows\x64\runner\Debug"
$requiredFiles = @(
    "AdventHymnals.exe",
    "flutter_windows.dll", 
    "data\flutter_assets",
    "data\icudtl.dat"
)

foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $buildPath $file
    if (Test-Path $fullPath) {
        Write-Host "✅ $file" -ForegroundColor Green
        if ($file.EndsWith(".dll") -or $file.EndsWith(".exe")) {
            $fileInfo = Get-Item $fullPath
            Write-Host "   Size: $($fileInfo.Length) bytes, Modified: $($fileInfo.LastWriteTime)" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ $file (MISSING)" -ForegroundColor Red
    }
}

# Check for app.so specifically
$appSoPath = "$buildPath\data\app.so"
if (Test-Path $appSoPath) {
    Write-Host "✅ app.so found" -ForegroundColor Green
    $appSo = Get-Item $appSoPath
    Write-Host "   Size: $($appSo.Length) bytes" -ForegroundColor Gray
} else {
    Write-Host "❌ app.so (MISSING - This is likely the problem!)" -ForegroundColor Red
}

# Check Visual C++ Redistributables
Write-Host "`n🔧 Checking Visual C++ Redistributables:" -ForegroundColor Yellow
$vcRedistKeys = @(
    "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64"
)

$vcFound = $false
foreach ($key in $vcRedistKeys) {
    if (Test-Path $key) {
        $version = (Get-ItemProperty $key -ErrorAction SilentlyContinue).Version
        if ($version) {
            Write-Host "✅ Visual C++ Redistributable found: $version" -ForegroundColor Green
            $vcFound = $true
            break
        }
    }
}

if (-not $vcFound) {
    Write-Host "❌ Visual C++ Redistributable not found" -ForegroundColor Red
    Write-Host "   Download from: https://aka.ms/vs/17/release/vc_redist.x64.exe" -ForegroundColor Cyan
}

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
Write-Host "`n👑 Running as Administrator: $(if($isAdmin){'✅ Yes'}else{'❌ No'})" -ForegroundColor $(if($isAdmin){'Green'}else{'Red'})

# Suggest fixes
Write-Host "`n🛠️  Suggested fixes:" -ForegroundColor Yellow
Write-Host "1. Ensure app.so is generated:" -ForegroundColor White
Write-Host "   flutter clean && flutter pub get && flutter build windows --debug" -ForegroundColor Gray
Write-Host "2. Install Visual C++ Redistributable if missing" -ForegroundColor White
Write-Host "3. Run as Administrator" -ForegroundColor White
Write-Host "4. Try with a completely minimal Flutter app to isolate the issue" -ForegroundColor White