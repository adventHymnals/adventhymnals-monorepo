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
            
            # Offer debugging options
            echo ""
            echo "Choose debug method:"
            echo "1) Basic test (default)"
            echo "2) Advanced debug with sound alerts and window detection"
            echo "3) Flutter verbose logging and console capture"
            echo "4) All methods"
            echo ""
            read -p "Enter choice (1-4) or press Enter for default: " choice
            
            case $choice in
                2)
                    echo "🔊 Running advanced debug..."
                    "$SCRIPT_DIR/debug_windows_advanced.sh" "$TMP_DIR/windows-build"
                    ;;
                3)
                    echo "📝 Running Flutter verbose debug..."
                    "$SCRIPT_DIR/debug_flutter_verbose.sh" "$TMP_DIR/windows-build"
                    ;;
                4)
                    echo "🔄 Running all debug methods..."
                    echo ""
                    echo "=== Basic Test ==="
                    "$SCRIPT_DIR/test_windows_app.sh" "$TMP_DIR/windows-build"
                    echo ""
                    echo "=== Advanced Debug ==="
                    "$SCRIPT_DIR/debug_windows_advanced.sh" "$TMP_DIR/windows-build"
                    echo ""
                    echo "=== Flutter Verbose ==="
                    "$SCRIPT_DIR/debug_flutter_verbose.sh" "$TMP_DIR/windows-build"
                    ;;
                *)
                    echo "📋 Running basic test..."
                    "$SCRIPT_DIR/test_windows_app.sh" "$TMP_DIR/windows-build"
                    ;;
            esac
            
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