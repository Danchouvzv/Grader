#!/bin/bash

# Xcode Cloud CI Script
# This script runs during the build process

echo "🚀 Starting Xcode Cloud build for Grader..."

# Set environment variables
export FLUTTER_ROOT=/opt/homebrew/bin/flutter
export PATH=$FLUTTER_ROOT/bin:$PATH

# Navigate to project directory
cd $CI_WORKSPACE

# Verify Flutter installation
echo "🔍 Checking Flutter installation..."
flutter --version

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Clean and prepare
echo "🧹 Cleaning project..."
flutter clean
flutter pub get

# Setup iOS
echo "🍎 Setting up iOS..."
cd ios
pod install --repo-update
cd ..

# Create Generated.xcconfig if missing
if [ ! -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "📝 Creating Generated.xcconfig..."
    cp ios/Flutter/Generated.xcconfig.template ios/Flutter/Generated.xcconfig
fi

echo "✅ Xcode Cloud setup complete!"
