#!/bin/bash

echo "🔍 Downloading latest Windows build with UI fixes..."
echo ""

# Get the latest successful workflow run
WORKFLOW_ID=$(gh run list --workflow="debug-windows-build.yml" --status=completed --limit=1 --json databaseId --jq='.[0].databaseId')

if [ -z "$WORKFLOW_ID" ]; then
    echo "❌ No successful workflow runs found"
    exit 1
fi

echo "📦 Found workflow run: $WORKFLOW_ID"

# Get artifacts from the workflow run
ARTIFACT_INFO=$(gh api repos/adventHymnals/adventhymnals-monorepo/actions/runs/$WORKFLOW_ID/artifacts)
ARTIFACT_ID=$(echo "$ARTIFACT_INFO" | jq -r '.artifacts[0].id')
ARTIFACT_NAME=$(echo "$ARTIFACT_INFO" | jq -r '.artifacts[0].name')

if [ -z "$ARTIFACT_ID" ] || [ "$ARTIFACT_ID" == "null" ]; then
    echo "❌ No artifacts found in workflow run"
    exit 1
fi

echo "📥 Downloading artifact: $ARTIFACT_NAME"

# Download the artifact
gh api repos/adventHymnals/adventhymnals-monorepo/actions/artifacts/$ARTIFACT_ID/zip > windows-build.zip

if [ $? -eq 0 ]; then
    echo "✅ Downloaded successfully"
    
    # Extract the artifact
    echo "📂 Extracting build..."
    
    # Remove old build if it exists
    if [ -d "latest-windows-build" ]; then
        rm -rf latest-windows-build
    fi
    
    # Extract to latest-windows-build directory
    unzip -q windows-build.zip -d latest-windows-build
    
    if [ $? -eq 0 ]; then
        echo "✅ Extracted to latest-windows-build/"
        
        # Check if executable exists
        if [ -f "latest-windows-build/AdventHymnals.exe" ]; then
            echo "✅ Executable found: latest-windows-build/AdventHymnals.exe"
            
            # Show file info
            echo "🔍 File info:"
            ls -la latest-windows-build/AdventHymnals.exe
            
            # Check assets
            if [ -d "latest-windows-build/data/flutter_assets" ]; then
                echo "✅ Flutter assets found"
            else
                echo "⚠️  Flutter assets not found in expected location"
                echo "🔍 Contents of latest-windows-build/:"
                ls -la latest-windows-build/
            fi
            
            echo ""
            echo "🎉 Ready to test! Run: ./debug_windows.sh"
        else
            echo "❌ Executable not found in extracted files"
            echo "🔍 Contents of latest-windows-build/:"
            ls -la latest-windows-build/
        fi
    else
        echo "❌ Failed to extract artifact"
    fi
    
    # Clean up zip file
    rm -f windows-build.zip
else
    echo "❌ Failed to download artifact"
    exit 1
fi

echo ""
echo "📊 Artifact details:"
echo "  - ID: $ARTIFACT_ID"
echo "  - Name: $ARTIFACT_NAME"
echo "  - Workflow: $WORKFLOW_ID"
echo "  - Contains UI fixes for blank window issue"