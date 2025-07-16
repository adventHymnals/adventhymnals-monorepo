#!/bin/bash

# Test script for Windows app
# Usage: ./test_windows_app.sh /path/to/windows-build

if [ $# -ne 1 ]; then
    echo "Usage: $0 <windows-build-directory>"
    exit 1
fi

BUILD_DIR="$1"
EXECUTABLE="$BUILD_DIR/AdventHymnals.exe"

echo "Starting Advent Hymnals Debug Test"
echo "=================================="
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
    echo "🔍 Contents of build directory:"
    ls -la "$BUILD_DIR"
    exit 1
fi

# Check assets
if [ -d "$BUILD_DIR/data/flutter_assets" ]; then
    echo "✓ Flutter assets found"
else
    echo "✗ Flutter assets NOT found"
    echo "🔍 Looking for assets in build directory:"
    find "$BUILD_DIR" -name "*flutter*" -type d 2>/dev/null || echo "No flutter directories found"
fi

echo ""
echo "🧪 Starting application with 60-second timeout..."
echo "Press Ctrl+C to stop if it hangs"
echo ""

# Change to build directory so app can find relative assets
cd "$BUILD_DIR"

# Start the application with timeout
timeout 60s ./AdventHymnals.exe &
PID=$!

# Monitor the process
counter=0
while kill -0 $PID 2>/dev/null; do
    sleep 1
    counter=$((counter + 1))
    if [ $((counter % 10)) -eq 0 ]; then
        echo "Still running... ($counter seconds)"
    fi
    if [ $counter -ge 60 ]; then
        echo "Application reached 60-second timeout. Killing process..."
        kill -9 $PID 2>/dev/null
        echo "Process killed"
        break
    fi
done

wait $PID 2>/dev/null
EXIT_CODE=$?

echo ""
echo "🔍 Test Results:"
echo "==============="
echo "Exit code: $EXIT_CODE"

case $EXIT_CODE in
    0)
        echo "✅ App exited normally"
        ;;
    124)
        echo "⏱️  App was terminated by timeout (60 seconds)"
        echo "   This suggests the app is running but may have UI issues"
        ;;
    *)
        echo "❌ App exited with error code: $EXIT_CODE"
        ;;
esac

echo ""
echo "💡 Next steps:"
echo "   - If exit code 124: App is running but check for blank window"
echo "   - If exit code 0: App may have completed initialization"
echo "   - If other codes: Check for startup errors"
echo ""
echo "🗂️  Build files remain in: $BUILD_DIR"

read -p "Press Enter to exit"