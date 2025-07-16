#!/bin/bash

echo "🔍 Downloading latest Windows build with UI fixes..."
echo ""

# Set up paths - ensure we're in the repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TMP_DIR="$REPO_ROOT/tmp/advent-hymnals-windows-test"

# Change to repo root to ensure git commands work
cd "$REPO_ROOT"

# Clean up any existing tmp directory
if [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
fi

mkdir -p "$TMP_DIR"

# Get the latest successful workflow run
WORKFLOW_ID=$(gh run list --workflow="debug-windows-build.yml" --status=completed --limit=1 --json databaseId --jq='.[0].databaseId')

if [ -z "$WORKFLOW_ID" ]; then
    echo "❌ No successful workflow runs found"
    exit 1
fi

echo "📦 Found workflow run: $WORKFLOW_ID"

# Download artifacts directly using gh run download
echo "📥 Downloading artifacts from workflow run..."

# Change to tmp directory and download
cd "$TMP_DIR"
gh run download "$WORKFLOW_ID"

if [ $? -eq 0 ]; then
    echo "✅ Downloaded successfully"
    
    # Find the Windows build artifact directory
    ARTIFACT_DIR=$(find . -name "*windows-debug-build*" -type d | head -1)
    
    if [ -z "$ARTIFACT_DIR" ]; then
        echo "❌ No Windows build artifact found"
        echo "🔍 Available artifacts:"
        ls -la
        exit 1
    fi
    
    echo "📦 Found artifact directory: $ARTIFACT_DIR"
    
    # Find the zip file in the artifact
    ZIP_FILE=$(find "$ARTIFACT_DIR" -name "*.zip" | head -1)
    
    if [ -z "$ZIP_FILE" ]; then
        echo "❌ No zip file found in artifact"
        exit 1
    fi
    
    echo "📂 Extracting build from: $ZIP_FILE"
    
    # Extract to windows-build directory
    unzip -q "$ZIP_FILE" -d windows-build
    
    if [ $? -eq 0 ]; then
        echo "✅ Extracted to $TMP_DIR/windows-build/"
        
        # Check if executable exists
        if [ -f "windows-build/AdventHymnals.exe" ]; then
            echo "✅ Executable found: windows-build/AdventHymnals.exe"
            
            # Show file info
            echo "🔍 File info:"
            ls -la windows-build/AdventHymnals.exe
            
            # Check assets
            if [ -d "windows-build/data/flutter_assets" ]; then
                echo "✅ Flutter assets found"
            else
                echo "⚠️  Flutter assets not found in expected location"
                echo "🔍 Contents of windows-build/:"
                ls -la windows-build/
            fi
            
            echo ""
            echo "📊 Artifact details:"
            echo "  - Workflow: $WORKFLOW_ID"
            echo "  - Contains UI fixes for blank window issue"
            echo ""
            
            echo "🧪 Starting Windows app test..."
            echo "==============================================="
            
            # Test the executable (run for 5 seconds)
            echo "Testing if app runs without crashing..."
            timeout 5 "./windows-build/AdventHymnals.exe" &
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
            echo "🎯 Windows build test completed successfully!"
            echo "📍 Executable location: $TMP_DIR/windows-build/AdventHymnals.exe"
            
        else
            echo "❌ Executable not found in extracted files"
            echo "🔍 Contents of windows-build/:"
            ls -la windows-build/
            exit 1
        fi
    else
        echo "❌ Failed to extract artifact"
        exit 1
    fi
else
    echo "❌ Failed to download artifact"
    exit 1
fi