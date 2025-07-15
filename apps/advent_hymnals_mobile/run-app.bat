@echo off
echo Starting Advent Hymnals Windows App...
echo.

REM Check if the executable exists
if not exist "build\windows\x64\runner\Debug\AdventHymnals.exe" (
    echo Error: AdventHymnals.exe not found!
    echo Please run: flutter build windows --debug
    pause
    exit /b 1
)

REM Run the app
echo Launching app...
start "" "build\windows\x64\runner\Debug\AdventHymnals.exe"

echo App launched successfully!
echo Check your taskbar or desktop for the Advent Hymnals window.
pause