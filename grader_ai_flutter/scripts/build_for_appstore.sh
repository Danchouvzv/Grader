#!/bin/bash

# App Store Build Script
# This script builds the app for App Store submission

echo "🍎 Building Grader for App Store submission..."

# Set environment variables
export FLUTTER_ROOT=/opt/homebrew/bin/flutter
export PATH=$FLUTTER_ROOT/bin:$PATH

# Navigate to project directory
cd "$(dirname "$0")/.."

# Clean and get dependencies
echo "🧹 Cleaning project..."
flutter clean
flutter pub get

# Update version
echo "📝 Updating version..."
flutter pub version

# Build iOS app for release
echo "🔨 Building iOS app for release..."
flutter build ios --release --no-codesign

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ iOS build completed successfully!"
    echo "📱 App ready for Xcode archiving"
    echo ""
    echo "Next steps:"
    echo "1. Open ios/Runner.xcworkspace in Xcode"
    echo "2. Select 'Any iOS Device' as target"
    echo "3. Product → Archive"
    echo "4. Upload to App Store Connect"
else
    echo "❌ iOS build failed!"
    exit 1
fi
