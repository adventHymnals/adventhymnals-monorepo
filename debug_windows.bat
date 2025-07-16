@echo off
echo Starting Advent Hymnals with debug output...
echo.
echo App ID: com.adventhymnals.org
echo Expected hymns: 1099
echo.
echo Starting application...
echo.
advent-hymnals-test\AdventHymnals.exe
echo.
echo Application exited with code: %ERRORLEVEL%
pause