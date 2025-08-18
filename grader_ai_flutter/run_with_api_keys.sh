#!/bin/bash

# Script to run Flutter app with API keys
# Usage: ./run_with_api_keys.sh

echo "🚀 Starting Flutter app with API configuration..."

# Check if API keys are set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  Warning: OPENAI_API_KEY is not set"
    echo "   Please set it with: export OPENAI_API_KEY='sk-your-key-here'"
    echo "   Or run this script with: OPENAI_API_KEY='sk-your-key-here' ./run_with_api_keys.sh"
fi

if [ -z "$GOOGLE_CLOUD_PROJECT_ID" ]; then
    echo "ℹ️   Note: GOOGLE_CLOUD_PROJECT_ID is not set (optional)"
fi

if [ -z "$BACKEND_API_URL" ]; then
    echo "ℹ️   Note: BACKEND_API_URL not set, using default: http://localhost:8000"
fi

echo ""
echo "🔑 Current configuration:"
echo "   OpenAI API Key: ${OPENAI_API_KEY:0:8}... (${#OPENAI_API_KEY} chars)"
echo "   Google Cloud Project: ${GOOGLE_CLOUD_PROJECT_ID:-'Not set'}"
echo "   Backend URL: ${BACKEND_API_URL:-'http://localhost:8000'}"
echo ""

# Run Flutter app with API keys
echo "📱 Launching Flutter app..."
flutter run \
  --dart-define=OPENAI_API_KEY="$OPENAI_API_KEY" \
  --dart-define=GOOGLE_CLOUD_PROJECT_ID="$GOOGLE_CLOUD_PROJECT_ID" \
  --dart-define=BACKEND_API_URL="$BACKEND_API_URL"
