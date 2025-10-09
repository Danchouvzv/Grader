#!/bin/bash

# Complete Xcode Cloud setup script
# This script ensures everything is ready for Xcode Cloud

echo "🚀 Complete Xcode Cloud setup for Grader..."

# Set environment variables
export FLUTTER_ROOT=/opt/homebrew/bin/flutter
export PATH=$FLUTTER_ROOT/bin:$PATH

# Navigate to project directory
cd $CI_WORKSPACE

# Step 1: Flutter setup
echo "📱 Setting up Flutter..."
flutter --version
flutter clean
flutter pub get

# Step 2: Create Generated.xcconfig
echo "📝 Creating Generated.xcconfig..."
mkdir -p ios/Flutter
cp ios/Flutter/Generated.xcconfig.template ios/Flutter/Generated.xcconfig

# Step 3: iOS CocoaPods setup
echo "🍎 Setting up iOS CocoaPods..."
cd ios

# Clean everything
rm -rf Pods
rm -f Podfile.lock

# Install pods
pod install --verbose --repo-update

# Step 4: Verify installation
echo "🔍 Verifying installation..."

# Check if Pods directory exists
if [ ! -d "Pods" ]; then
    echo "❌ Pods directory not found"
    exit 1
fi

# Check if Target Support Files exist
if [ ! -d "Pods/Target Support Files/Pods-Runner" ]; then
    echo "❌ Target Support Files not found"
    exit 1
fi

# Create missing .xcfilelist files
echo "🔧 Creating missing .xcfilelist files..."
mkdir -p "Pods/Target Support Files/Pods-Runner"

# Create all required .xcfilelist files
touch "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist"
touch "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-output-files.xcfilelist"
touch "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Release-input-files.xcfilelist"
touch "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Release-output-files.xcfilelist"

# Also create Debug and Profile versions
touch "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Debug-input-files.xcfilelist"
touch "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Debug-output-files.xcfilelist"
touch "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Debug-input-files.xcfilelist"
touch "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Debug-output-files.xcfilelist"

touch "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Profile-input-files.xcfilelist"
touch "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Profile-output-files.xcfilelist"
touch "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Profile-input-files.xcfilelist"
touch "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Profile-output-files.xcfilelist"

echo "✅ All .xcfilelist files created"

cd ..

# Step 5: Final verification
echo "🔍 Final verification..."

# Check Generated.xcconfig
if [ -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "✅ Generated.xcconfig exists"
else
    echo "❌ Generated.xcconfig not found"
    exit 1
fi

# Check Pods
if [ -d "ios/Pods" ]; then
    echo "✅ Pods directory exists"
else
    echo "❌ Pods directory not found"
    exit 1
fi

# Check Target Support Files
if [ -d "ios/Pods/Target Support Files/Pods-Runner" ]; then
    echo "✅ Target Support Files exist"
    ls -la "ios/Pods/Target Support Files/Pods-Runner/"
else
    echo "❌ Target Support Files not found"
    exit 1
fi

echo "🎉 Xcode Cloud setup complete!"
echo "📋 Summary:"
echo "   - Flutter dependencies: ✅"
echo "   - Generated.xcconfig: ✅"
echo "   - CocoaPods: ✅"
echo "   - Target Support Files: ✅"
echo "   - .xcfilelist files: ✅"
