#!/bin/bash

# Flutter verbose debug script with console output capture
# Usage: ./debug_flutter_verbose.sh /path/to/windows-build

if [ $# -ne 1 ]; then
    echo "Usage: $0 <windows-build-directory>"
    exit 1
fi

BUILD_DIR="$1"
EXECUTABLE="$BUILD_DIR/AdventHymnals.exe"
LOG_FILE="/tmp/advent-hymnals-debug.log"

echo "🔍 Flutter Verbose Debug Test"
echo "============================="
echo ""
echo "App ID: com.adventhymnals.org"
echo "Expected hymns: 1099"
echo "Build directory: $BUILD_DIR"
echo "Log file: $LOG_FILE"
echo ""

# Check if executable exists
if [ -f "$EXECUTABLE" ]; then
    echo "✓ Executable found: $EXECUTABLE"
else
    echo "✗ Executable NOT found: $EXECUTABLE"
    exit 1
fi

# Clear previous log
> "$LOG_FILE"

echo "🚀 Starting app with verbose logging..."
echo "Press Ctrl+C to stop"
echo ""

# Change to build directory
cd "$BUILD_DIR"

# Set Flutter debug environment variables
export FLUTTER_ENGINE_SWITCH_1="--verbose-logging"
export FLUTTER_ENGINE_SWITCH_2="--enable-dart-profiling"
export FLUTTER_ENGINE_SWITCH_3="--trace-startup"
export FLUTTER_ENGINE_SWITCH_4="--enable-software-rendering"

# Run with different debugging approaches
echo "🔍 Method 1: Direct execution with output capture"
echo "================================================"

# Start the application with output redirection
(./AdventHymnals.exe 2>&1 | tee "$LOG_FILE") &
PID=$!

# Monitor for 30 seconds
counter=0
while kill -0 $PID 2>/dev/null && [ $counter -lt 30 ]; do
    sleep 1
    counter=$((counter + 1))
    
    if [ $((counter % 5)) -eq 0 ]; then
        echo "⏱️  Running... ($counter/30 seconds)"
        
        # Check if log file has new content
        if [ -s "$LOG_FILE" ]; then
            echo "📝 Recent log entries:"
            tail -3 "$LOG_FILE" | sed 's/^/   /'
        fi
        
        # Check for Flutter-specific processes
        if command -v ps >/dev/null 2>&1; then
            flutter_procs=$(ps aux | grep -i flutter | grep -v grep | wc -l)
            if [ $flutter_procs -gt 0 ]; then
                echo "🎯 Flutter processes detected: $flutter_procs"
            fi
        fi
    fi
done

# Kill if still running
if kill -0 $PID 2>/dev/null; then
    echo "⏰ Stopping after 30 seconds..."
    kill -9 $PID 2>/dev/null
fi

wait $PID 2>/dev/null
EXIT_CODE=$?

echo ""
echo "🔍 Results - Method 1:"
echo "Exit code: $EXIT_CODE"

# Show log file contents
echo ""
echo "📋 Complete Log Output:"
echo "======================="
if [ -s "$LOG_FILE" ]; then
    cat "$LOG_FILE"
else
    echo "❌ No log output captured"
fi

echo ""
echo "🔍 Method 2: Windows console mode"
echo "================================="

# Try running with console allocation (if on Windows/WSL)
if command -v cmd.exe >/dev/null 2>&1; then
    echo "🪟 Trying Windows console mode..."
    cmd.exe /c "cd /d \"$(wslpath -w "$BUILD_DIR")\" && AdventHymnals.exe" &
    WIN_PID=$!
    
    sleep 10
    
    if kill -0 $WIN_PID 2>/dev/null; then
        echo "✅ Windows console mode is running"
        kill -9 $WIN_PID 2>/dev/null
    else
        echo "❌ Windows console mode failed"
    fi
fi

echo ""
echo "🔍 Method 3: Process tree analysis"
echo "=================================="

# Show process tree
if command -v pstree >/dev/null 2>&1; then
    echo "📊 Process tree:"
    pstree -p $$ | grep -A 5 -B 5 "AdventHymnals\|flutter"
elif command -v ps >/dev/null 2>&1; then
    echo "📊 Related processes:"
    ps aux | grep -i "advent\|flutter\|dart" | grep -v grep
fi

echo ""
echo "💡 Debugging Summary:"
echo "   - Check log file for Flutter engine messages"
echo "   - Look for any error patterns in output"
echo "   - Process analysis shows if Flutter engine starts"
echo "   - Try different execution methods"

read -p "Press Enter to exit"