#!/bin/bash

# Download Latest Windows Debug Build Script
# Downloads the most recent successful Windows build artifact and extracts it for testing

set -e  # Exit on any error

TEMP_DIR="tmp"
EXTRACT_DIR="latest-windows-build"

echo "🔍 Finding latest successful Windows build..."

# Get the latest successful debug build run ID
LATEST_RUN_ID=$(gh run list --workflow=debug-windows-build.yml --limit 10 --json databaseId,status,conclusion --jq '.[] | select(.conclusion == "success") | .databaseId' | head -1)

if [ -z "$LATEST_RUN_ID" ]; then
    echo "❌ No successful Windows debug builds found"
    exit 1
fi

echo "✅ Found latest successful run: $LATEST_RUN_ID"

# Clean up and create temp directory
rm -rf "$TEMP_DIR"
rm -rf "$EXTRACT_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo "📥 Downloading artifacts from run $LATEST_RUN_ID..."

# Download the artifacts
gh run download "$LATEST_RUN_ID"

# Find the Windows build artifact directory
ARTIFACT_DIR=$(find . -name "*windows-debug-build*" -type d | head -1)

if [ -z "$ARTIFACT_DIR" ]; then
    echo "❌ No Windows build artifact found"
    exit 1
fi

echo "📦 Found artifact directory: $ARTIFACT_DIR"

# Find the zip file
ZIP_FILE=$(find "$ARTIFACT_DIR" -name "*.zip" | head -1)

if [ -z "$ZIP_FILE" ]; then
    echo "❌ No zip file found in artifact"
    exit 1
fi

echo "📦 Found zip file: $ZIP_FILE"

# Clean up previous extraction
echo "📂 Extracting Windows build..."

# Extract the zip file (we're currently in tmp directory)
unzip "$ZIP_FILE" -d "../$EXTRACT_DIR"
cd ..

# Find the executable
EXE_FILE=$(find "$EXTRACT_DIR" -name "*.exe" | head -1)

if [ -z "$EXE_FILE" ]; then
    echo "❌ No executable found in extracted files"
    exit 1
fi

echo "✅ Windows build ready!"
echo "📍 Executable location: $EXE_FILE"
echo ""
echo "🧪 Testing if app runs..."

# Test the executable (run for 5 seconds)
timeout 5 "$EXE_FILE" &
APP_PID=$!

sleep 5

if kill -0 $APP_PID 2>/dev/null; then
    echo "✅ SUCCESS: App is running without crashes!"
    kill $APP_PID 2>/dev/null
    wait $APP_PID 2>/dev/null
else
    wait $APP_PID 2>/dev/null
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 124 ]; then
        echo "✅ SUCCESS: App ran successfully (timeout reached)"
    else
        echo "❌ FAILED: App crashed or exited (exit code: $EXIT_CODE)"
        exit 1
    fi
fi

echo ""
echo "🎯 Summary:"
echo "  - Run ID: $LATEST_RUN_ID"
echo "  - Executable: $EXE_FILE"
echo "  - Status: Ready for testing"
echo ""
echo "💡 To run the app manually:"
echo "   ./$EXE_FILE"
echo ""
echo "💡 To run with timeout:"
echo "   timeout 10 ./$EXE_FILE"