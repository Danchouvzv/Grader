# API Configuration Setup

## Overview
This Flutter application uses environment variables for API configuration, similar to the Python backend.

## Required API Keys

### 1. OpenAI API Key
- **Purpose**: For audio transcription (Whisper) and IELTS assessment (GPT-4)
- **How to get**: Visit [OpenAI Platform](https://platform.openai.com/api-keys)
- **Format**: `sk-...`

### 2. Google Cloud Project ID (Optional)
- **Purpose**: For Speech-to-Text services
- **How to get**: Visit [Google Cloud Console](https://console.cloud.google.com/)
- **Format**: `your-project-id`

## Configuration Methods

### Method 1: Environment Variables (Recommended)
Set environment variables before building the app:

```bash
# For development
export OPENAI_API_KEY="sk-your-actual-key-here"
export GOOGLE_CLOUD_PROJECT_ID="your-project-id"
export BACKEND_API_URL="http://localhost:8000"

# Build the app
flutter build apk --debug
```

### Method 2: Build Arguments
Pass API keys during build:

```bash
flutter build apk --debug \
  --dart-define=OPENAI_API_KEY="sk-your-actual-key-here" \
  --dart-define=GOOGLE_CLOUD_PROJECT_ID="your-project-id" \
  --dart-define=BACKEND_API_URL="http://localhost:8000"
```

### Method 3: IDE Configuration
In your IDE (VS Code, Android Studio), add to launch configuration:

```json
{
  "args": [
    "--dart-define=OPENAI_API_KEY=sk-your-actual-key-here",
    "--dart-define=GOOGLE_CLOUD_PROJECT_ID=your-project-id"
  ]
}
```

## Security Notes

⚠️ **IMPORTANT**: Never commit API keys to version control!

- The `.env` file is ignored by git
- API keys are only loaded at build time
- Use different keys for development and production
- Rotate keys regularly

## Verification

To verify your configuration is working:

1. Check the console output when the app starts
2. Look for: "OpenAI API Key loaded: sk-1234... (51 chars)"
3. If you see "Warning: OpenAI API Key not configured properly", check your setup

## Troubleshooting

### Common Issues

1. **"API Key not configured"**
   - Check environment variables are set
   - Verify build arguments are correct
   - Restart your IDE/terminal

2. **"Invalid API Key"**
   - Verify the key format (starts with `sk-`)
   - Check if the key is active in OpenAI dashboard
   - Ensure you have sufficient credits

3. **"Network Error"**
   - Check internet connection
   - Verify firewall settings
   - Check if OpenAI services are accessible from your location

## Backend Integration

The Flutter app can work with or without the Python backend:

- **With Backend**: Set `BACKEND_API_URL` to your backend URL
- **Without Backend**: The app will use OpenAI directly for transcription and assessment

## Production Deployment

For production builds:

1. Use production API keys
2. Set appropriate rate limits
3. Monitor API usage
4. Consider using a backend proxy for additional security


