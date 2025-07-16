#!/bin/bash

# Advanced Windows debug script with sound alerts and window detection
# Usage: ./debug_windows_advanced.sh /path/to/windows-build

if [ $# -ne 1 ]; then
    echo "Usage: $0 <windows-build-directory>"
    exit 1
fi

BUILD_DIR="$1"
EXECUTABLE="$BUILD_DIR/AdventHymnals.exe"

echo "🔍 Advanced Windows Debug Test"
echo "=============================="
echo ""
echo "App ID: com.adventhymnals.org"
echo "Expected hymns: 1099"
echo "Build directory: $BUILD_DIR"
echo ""

# Check if executable exists
if [ -f "$EXECUTABLE" ]; then
    echo "✓ Executable found: $EXECUTABLE"
else
    echo "✗ Executable NOT found: $EXECUTABLE"
    exit 1
fi

# Play sound alert function (if available)
play_sound() {
    local message="$1"
    echo "🔊 $message"
    
    # Try different sound methods
    if command -v paplay >/dev/null 2>&1; then
        echo -e "\a" # Bell sound
    elif command -v aplay >/dev/null 2>&1; then
        echo -e "\a"
    elif command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -c "[console]::beep(800,300)" 2>/dev/null || true
    else
        echo -e "\a\a\a" # Multiple bells
    fi
}

# Window detection function
detect_windows() {
    echo "🪟 Detecting windows..."
    
    # Try different window detection methods
    if command -v wmctrl >/dev/null 2>&1; then
        echo "📋 Window list (wmctrl):"
        wmctrl -l | grep -i "advent\|hymnal" || echo "   No Advent Hymnals windows found"
    fi
    
    if command -v xwininfo >/dev/null 2>&1; then
        echo "📋 Window tree (xwininfo):"
        xwininfo -tree -root | grep -i "advent\|hymnal" || echo "   No Advent Hymnals windows found"
    fi
    
    if command -v powershell.exe >/dev/null 2>&1; then
        echo "📋 Windows processes (PowerShell):"
        powershell.exe -c "Get-Process | Where-Object {$_.MainWindowTitle -like '*Advent*' -or $_.ProcessName -like '*Advent*'} | Select-Object ProcessName,MainWindowTitle,Id" 2>/dev/null || echo "   PowerShell detection failed"
    fi
}

# Process monitoring function
monitor_process() {
    local pid=$1
    local counter=0
    
    while kill -0 $pid 2>/dev/null; do
        sleep 1
        counter=$((counter + 1))
        
        # Status updates every 10 seconds
        if [ $((counter % 10)) -eq 0 ]; then
            echo "⏱️  Still running... ($counter seconds)"
            
            # Check memory usage
            if command -v ps >/dev/null 2>&1; then
                memory=$(ps -p $pid -o pid,ppid,rss,vsz,comm --no-headers 2>/dev/null | awk '{print $3/1024 " MB"}')
                echo "   Memory: $memory"
            fi
            
            # Sound alert every 30 seconds
            if [ $((counter % 30)) -eq 0 ]; then
                play_sound "App still running at $counter seconds"
            fi
            
            # Window detection every 20 seconds
            if [ $((counter % 20)) -eq 0 ]; then
                detect_windows
            fi
        fi
        
        # Key milestone alerts
        case $counter in
            5)
                play_sound "App survived 5 seconds - startup phase"
                ;;
            15)
                play_sound "App running 15 seconds - initialization phase"
                ;;
            30)
                play_sound "App running 30 seconds - data import phase"
                ;;
            60)
                play_sound "App running 60 seconds - should be ready"
                ;;
        esac
        
        # Auto-kill after 90 seconds
        if [ $counter -ge 90 ]; then
            echo "⏰ Reached 90-second limit. Killing process..."
            play_sound "Timeout reached - killing process"
            kill -9 $pid 2>/dev/null
            echo "Process killed"
            break
        fi
    done
}

echo "🧪 Starting advanced debug test..."
echo "Press Ctrl+C to stop manually"
echo ""

# Change to build directory
cd "$BUILD_DIR"

# Initial window detection
echo "🔍 Pre-launch window detection:"
detect_windows

play_sound "Starting Advent Hymnals debug test"

# Start the application
echo "🚀 Launching application..."
./AdventHymnals.exe &
PID=$!

echo "📊 Process started with PID: $PID"

# Brief pause to let app start
sleep 2

# Post-launch window detection
echo "🔍 Post-launch window detection:"
detect_windows

# Monitor the process
monitor_process $PID

wait $PID 2>/dev/null
EXIT_CODE=$?

echo ""
echo "🔍 Final Results:"
echo "==============="
echo "Exit code: $EXIT_CODE"

# Final window detection
echo "🔍 Final window detection:"
detect_windows

case $EXIT_CODE in
    0)
        play_sound "App exited normally"
        echo "✅ App exited normally"
        ;;
    124)
        play_sound "App was terminated by timeout"
        echo "⏱️  App was terminated by timeout"
        echo "   This suggests the app is running but may have UI issues"
        ;;
    *)
        play_sound "App exited with error"
        echo "❌ App exited with error code: $EXIT_CODE"
        ;;
esac

echo ""
echo "💡 Debug Summary:"
echo "   - Sound alerts help track app lifecycle"
echo "   - Window detection shows if UI is created"
echo "   - Process monitoring shows resource usage"
echo "   - Check for any window flashes or brief appearances"

read -p "Press Enter to exit"