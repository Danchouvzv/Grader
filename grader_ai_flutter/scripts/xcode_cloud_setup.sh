#!/bin/bash

# Xcode Cloud script to fix Generated.xcconfig
# This script runs before the build process

echo "🔧 Fixing Generated.xcconfig for Xcode Cloud..."

# Check if Generated.xcconfig exists
if [ ! -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "📝 Generated.xcconfig not found, creating from template..."
    
    # Copy template to Generated.xcconfig
    cp ios/Flutter/Generated.xcconfig.template ios/Flutter/Generated.xcconfig
    
    echo "✅ Generated.xcconfig created successfully"
else
    echo "✅ Generated.xcconfig already exists"
fi

# Verify the file exists
if [ -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "📋 Generated.xcconfig contents:"
    cat ios/Flutter/Generated.xcconfig
else
    echo "❌ Failed to create Generated.xcconfig"
    exit 1
fi

echo "🎉 Xcode Cloud setup complete!"
