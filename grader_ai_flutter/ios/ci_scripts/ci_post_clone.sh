#!/bin/bash

# Xcode Cloud CI Script
# This script runs during the build process

echo "🚀 Starting Xcode Cloud build for Grader..."

# Navigate to project directory
cd $CI_WORKSPACE

# Run complete setup script
echo "🔧 Running complete Xcode Cloud setup..."
./scripts/xcode_cloud_complete_setup.sh

if [ $? -eq 0 ]; then
    echo "✅ Xcode Cloud setup completed successfully!"
else
    echo "❌ Xcode Cloud setup failed!"
    exit 1
fi
