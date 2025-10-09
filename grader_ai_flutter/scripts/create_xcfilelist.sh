#!/bin/bash

# Create missing .xcfilelist files for Xcode Cloud
# This script ensures all required CocoaPods files exist

echo "🔧 Creating missing .xcfilelist files..."

PODS_DIR="ios/Pods/Target Support Files/Pods-Runner"

# Create directory if it doesn't exist
mkdir -p "$PODS_DIR"

# Create empty .xcfilelist files if they don't exist
create_xcfilelist() {
    local file="$PODS_DIR/$1"
    if [ ! -f "$file" ]; then
        echo "📝 Creating $file"
        touch "$file"
    else
        echo "✅ $file already exists"
    fi
}

# Create all required .xcfilelist files
create_xcfilelist "Pods-Runner-frameworks-Release-input-files.xcfilelist"
create_xcfilelist "Pods-Runner-frameworks-Release-output-files.xcfilelist"
create_xcfilelist "Pods-Runner-resources-Release-input-files.xcfilelist"
create_xcfilelist "Pods-Runner-resources-Release-output-files.xcfilelist"

# Also create Debug and Profile versions
create_xcfilelist "Pods-Runner-frameworks-Debug-input-files.xcfilelist"
create_xcfilelist "Pods-Runner-frameworks-Debug-output-files.xcfilelist"
create_xcfilelist "Pods-Runner-resources-Debug-input-files.xcfilelist"
create_xcfilelist "Pods-Runner-resources-Debug-output-files.xcfilelist"

create_xcfilelist "Pods-Runner-frameworks-Profile-input-files.xcfilelist"
create_xcfilelist "Pods-Runner-frameworks-Profile-output-files.xcfilelist"
create_xcfilelist "Pods-Runner-resources-Profile-input-files.xcfilelist"
create_xcfilelist "Pods-Runner-resources-Profile-output-files.xcfilelist"

echo "✅ All .xcfilelist files created/verified"
