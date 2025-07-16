# Force generation of app.so file using multiple methods
Write-Host "🔧 Force generating app.so file..." -ForegroundColor Green

# Method 1: Clean build with explicit kernel compilation
Write-Host "`n📋 Method 1: Clean build with kernel compilation" -ForegroundColor Yellow
flutter clean
flutter pub get

# Generate kernel first
Write-Host "Generating kernel..." -ForegroundColor Gray
flutter assemble debug_bundle_flutter_assets

# Build for Windows
Write-Host "Building Windows debug..." -ForegroundColor Gray
flutter build windows --debug --verbose

# Check result
$appSoPath = "build\windows\x64\runner\Debug\data\app.so"
if (Test-Path $appSoPath) {
    Write-Host "✅ Method 1 SUCCESS: app.so generated" -ForegroundColor Green
    Get-Item $appSoPath | Format-List Name, Length, LastWriteTime
} else {
    Write-Host "❌ Method 1 failed" -ForegroundColor Red
    
    # Method 2: Use flutter run to force compilation
    Write-Host "`n📋 Method 2: Force compilation via flutter run" -ForegroundColor Yellow
    Write-Host "Starting flutter run and immediately stopping..." -ForegroundColor Gray
    
    # Start flutter run in background and kill it after compilation
    $job = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        flutter run -d windows --debug -t lib\main_empty.dart
    }
    
    # Wait for compilation to complete (usually takes 10-20 seconds)
    Start-Sleep -Seconds 15
    
    # Stop the job
    Stop-Job $job -Force
    Remove-Job $job -Force
    
    # Check if app.so was created
    if (Test-Path $appSoPath) {
        Write-Host "✅ Method 2 SUCCESS: app.so generated via flutter run" -ForegroundColor Green
        Get-Item $appSoPath | Format-List Name, Length, LastWriteTime
    } else {
        Write-Host "❌ Method 2 failed" -ForegroundColor Red
        
        # Method 3: Try with release build then copy
        Write-Host "`n📋 Method 3: Generate from release build" -ForegroundColor Yellow
        flutter build windows --release
        
        $releaseAppSo = "build\windows\x64\runner\Release\data\app.so"
        if (Test-Path $releaseAppSo) {
            Write-Host "Found app.so in release build, copying to debug..." -ForegroundColor Gray
            Copy-Item $releaseAppSo $appSoPath -Force
            
            if (Test-Path $appSoPath) {
                Write-Host "✅ Method 3 SUCCESS: app.so copied from release" -ForegroundColor Green
            } else {
                Write-Host "❌ Method 3 failed to copy" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ Method 3 failed - no app.so in release either" -ForegroundColor Red
        }
    }
}

# Final check
Write-Host "`n🔍 Final verification:" -ForegroundColor Yellow
if (Test-Path $appSoPath) {
    $appSo = Get-Item $appSoPath
    Write-Host "✅ app.so exists: $($appSo.Length) bytes" -ForegroundColor Green
    
    # List all files in data directory
    Write-Host "`n📁 Contents of data directory:" -ForegroundColor Gray
    Get-ChildItem "build\windows\x64\runner\Debug\data" | Format-Table Name, Length, LastWriteTime
} else {
    Write-Host "❌ app.so still missing!" -ForegroundColor Red
    Write-Host "This indicates a deeper issue with the Flutter toolchain or project setup" -ForegroundColor Red
}