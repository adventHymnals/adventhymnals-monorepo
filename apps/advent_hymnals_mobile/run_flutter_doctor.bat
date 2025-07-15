@echo off
cd /d "C:\Users\surgb\Code\adventhymnals-monorepo\apps\advent_hymnals_mobile"
echo Running Flutter doctor...
flutter doctor
echo.
echo Running Flutter build windows with verbose output...
flutter build windows --release --verbose
pause