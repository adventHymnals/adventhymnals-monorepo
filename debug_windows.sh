#!/bin/bash

echo "Starting Advent Hymnals Debug (Shell Script)"
echo ""
echo "App ID: com.adventhymnals.org"
echo "Expected hymns: 1099"
echo ""

# Check if executable exists
if [ -f "advent-hymnals-test/AdventHymnals.exe" ]; then
    echo "✓ Executable found"
else
    echo "✗ Executable NOT found"
    read -p "Press Enter to exit"
    exit 1
fi

# Check assets
if [ -d "advent-hymnals-test/data/flutter_assets" ]; then
    echo "✓ Flutter assets found"
else
    echo "✗ Flutter assets NOT found"
fi

echo ""
echo "Starting application with timeout..."
echo "Press Ctrl+C to stop if it hangs"
echo ""

# Start the application with timeout
timeout 60s ./advent-hymnals-test/AdventHymnals.exe &
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
        echo "Application hung after 60 seconds. Killing process..."
        kill -9 $PID 2>/dev/null
        echo "Process killed"
        break
    fi
done

wait $PID 2>/dev/null
EXIT_CODE=$?

echo ""
echo "Application exited with code: $EXIT_CODE"
read -p "Press Enter to exit"