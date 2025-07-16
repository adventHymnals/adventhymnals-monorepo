@echo off
echo Starting Advent Hymnals with debug output...
echo.
echo App ID: com.adventhymnals.org
echo Expected hymns: 1099
echo.
echo Checking if executable exists...
if exist "advent-hymnals-test\AdventHymnals.exe" (
    echo ✓ Executable found
) else (
    echo ✗ Executable NOT found
    pause
    exit /b 1
)
echo.
echo Checking assets directory...
if exist "advent-hymnals-test\data\flutter_assets" (
    echo ✓ Flutter assets found
) else (
    echo ✗ Flutter assets NOT found
)
echo.
echo Starting application with timeout...
echo Press Ctrl+C to stop if it hangs
echo.
timeout /t 5 /nobreak >nul
start /wait "" "advent-hymnals-test\AdventHymnals.exe"
echo.
echo Application exited with code: %ERRORLEVEL%
pause