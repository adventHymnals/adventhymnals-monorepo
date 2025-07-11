# PowerShell script to generate app.so for Flutter Windows app
Write-Host "🚀 Generating app.so file for Flutter Windows app..." -ForegroundColor Green

# Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Try to build the app which should generate app.so
Write-Host "🔨 Building Windows app (this should generate app.so)..." -ForegroundColor Yellow
flutter build windows --debug --verbose

# Check if app.so was created
$appSoPath = "build\windows\x64\runner\Debug\data\app.so"
if (Test-Path $appSoPath) {
    Write-Host "✅ app.so successfully generated!" -ForegroundColor Green
    Write-Host "📍 Location: $appSoPath" -ForegroundColor Cyan
    Get-ChildItem $appSoPath | Format-List Name, Length, LastWriteTime
} else {
    Write-Host "❌ app.so not found at expected location" -ForegroundColor Red
    Write-Host "🔍 Searching for any .so files..." -ForegroundColor Yellow
    
    $soFiles = Get-ChildItem -Path "build" -Filter "*.so" -Recurse -ErrorAction SilentlyContinue
    if ($soFiles) {
        Write-Host "Found .so files:" -ForegroundColor Cyan
        $soFiles | ForEach-Object { Write-Host "  $($_.FullName)" -ForegroundColor White }
    } else {
        Write-Host "No .so files found in build directory" -ForegroundColor Red
        
        Write-Host "🔄 Trying alternative approach..." -ForegroundColor Yellow
        Write-Host "Building with kernel compilation..." -ForegroundColor Yellow
        
        # Try kernel compilation
        flutter assemble --output=build\kernel debug_bundle_flutter_assets
        flutter assemble --output=build\windows\x64\runner\Debug\data debug_windows_bundle_flutter_assets
        
        # Check again
        if (Test-Path $appSoPath) {
            Write-Host "✅ app.so generated via kernel compilation!" -ForegroundColor Green
        } else {
            Write-Host "❌ Still no app.so. This may require a full Windows Flutter SDK setup." -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "📁 Current build directory contents:"
if (Test-Path "build\windows\x64\runner\Debug\data") {
    Get-ChildItem "build\windows\x64\runner\Debug\data" | Format-Table Name, Length, LastWriteTime
} else {
    Write-Host "Debug data directory does not exist" -ForegroundColor Red
}