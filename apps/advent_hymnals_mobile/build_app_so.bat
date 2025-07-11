@echo off
echo Generating app.so file for Flutter Windows app...

REM Clean previous builds
flutter clean

REM Get dependencies
flutter pub get

REM Generate the kernel snapshot (this creates app.dill)
flutter assemble --output=build\kernel debug_bundle_flutter_assets

REM Compile Dart code to native (this should create app.so)
flutter assemble --output=build\windows\x64\runner\Debug\data debug_windows_bundle_flutter_assets

REM Alternative: Try building for Windows (this should create app.so)
flutter build windows --debug

REM Check if app.so was created
if exist "build\windows\x64\runner\Debug\data\app.so" (
    echo ✅ app.so successfully generated at build\windows\x64\runner\Debug\data\app.so
    dir "build\windows\x64\runner\Debug\data\app.so"
) else (
    echo ❌ app.so not found. Trying alternative generation...
    
    REM Try compiling with minimal app
    flutter run -d windows --debug -t lib\main_minimal.dart --no-start-paused --disable-service-auth-codes
)

echo.
echo Build complete. Check for app.so in build\windows\x64\runner\Debug\data\
pause