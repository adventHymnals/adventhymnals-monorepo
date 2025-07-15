@echo off
title Flutter Build Debug - Advent Hymnals Mobile
color 0A

echo ===================================================
echo Flutter Build Debug Script for Windows
echo ===================================================
echo.

cd /d "D:\Code\adventhymnals-monorepo\apps\advent_hymnals_mobile"

echo Current Directory: %CD%
echo.

echo === Step 1: Flutter Doctor ===
echo Running 'flutter doctor' to check Flutter installation...
flutter doctor
if %errorlevel% neq 0 (
    echo ERROR: Flutter doctor failed with error code %errorlevel%
    echo This may indicate Flutter is not installed or not in PATH
    echo.
) else (
    echo SUCCESS: Flutter doctor completed successfully!
    echo.
)

echo === Step 2: Flutter Doctor -v (Verbose) ===
echo Running 'flutter doctor -v' for detailed information...
flutter doctor -v
if %errorlevel% neq 0 (
    echo ERROR: Flutter doctor -v failed with error code %errorlevel%
    echo.
) else (
    echo SUCCESS: Flutter doctor -v completed successfully!
    echo.
)

echo === Step 3: Flutter Config ===
echo Enabling Windows desktop support...
flutter config --enable-windows-desktop
if %errorlevel% neq 0 (
    echo ERROR: Flutter config failed with error code %errorlevel%
    echo.
) else (
    echo SUCCESS: Windows desktop support enabled successfully!
    echo.
)

echo === Step 4: Flutter Pub Get ===
echo Running 'flutter pub get' to install dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed with error code %errorlevel%
    echo.
) else (
    echo SUCCESS: Flutter pub get completed successfully!
    echo.
)

echo === Step 5: Flutter Clean ===
echo Running 'flutter clean' to clear build cache...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed with error code %errorlevel%
    echo.
) else (
    echo SUCCESS: Flutter clean completed successfully!
    echo.
)

echo === Step 6: Flutter Build Windows Debug ===
echo Running 'flutter build windows --debug --verbose' to build Windows app...
flutter build windows --debug --verbose
if %errorlevel% neq 0 (
    echo ERROR: Flutter build windows debug failed with error code %errorlevel%
    echo.
) else (
    echo SUCCESS: Flutter build windows debug completed successfully!
    echo.
)

echo === Step 7: Flutter Build Windows Release ===
echo Running 'flutter build windows --release --verbose' to build Windows app...
flutter build windows --release --verbose
if %errorlevel% neq 0 (
    echo ERROR: Flutter build windows release failed with error code %errorlevel%
    echo.
) else (
    echo SUCCESS: Flutter build windows release completed successfully!
    echo.
)

echo === Build Summary ===
echo Checking for build outputs...
echo.

if exist "build\windows\x64\runner\Debug" (
    echo [SUCCESS] Debug build found at: build\windows\x64\runner\Debug
    dir "build\windows\x64\runner\Debug" /B
) else (
    echo [ERROR] Debug build not found at: build\windows\x64\runner\Debug
)

echo.

if exist "build\windows\x64\runner\Release" (
    echo [SUCCESS] Release build found at: build\windows\x64\runner\Release
    dir "build\windows\x64\runner\Release" /B
) else (
    echo [ERROR] Release build not found at: build\windows\x64\runner\Release
)

echo.
echo ===================================================
echo Script Complete
echo ===================================================
pause