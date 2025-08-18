# IELTS Speaking Test App

A Flutter application for IELTS speaking test practice with AI-powered assessment using OpenAI's Whisper and GPT-4.

## Features

- 🎤 **Audio Recording**: Record your speaking responses
- 🗣️ **AI Transcription**: Uses OpenAI Whisper for accurate speech-to-text
- 📊 **AI Assessment**: GPT-4 powered IELTS band scoring and feedback
- 📱 **Cross-Platform**: Works on iOS, Android, and Web
- 🔄 **Real-time Processing**: Immediate feedback and results

## Quick Start

### 1. Prerequisites

- Flutter SDK (latest stable version)
- OpenAI API key
- Optional: Google Cloud Project ID for Speech-to-Text

### 2. Setup API Keys

#### Method 1: Environment Variables (Recommended)
```bash
export OPENAI_API_KEY="sk-your-actual-key-here"
export GOOGLE_CLOUD_PROJECT_ID="your-project-id"
export BACKEND_API_URL="http://localhost:8000"
```

#### Method 2: Use the provided script
```bash
# Make script executable
chmod +x run_with_api_keys.sh

# Run with your API key
OPENAI_API_KEY="sk-your-key-here" ./run_with_api_keys.sh
```

#### Method 3: Build arguments
```bash
flutter run --dart-define=OPENAI_API_KEY="sk-your-key-here"
```

### 3. Run the App

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
lib/
├── core/                    # Core services and configuration
│   ├── config/             # API configuration
│   ├── services/           # Business logic services
│   └── openai_service.dart # OpenAI integration
├── features/               # Feature modules
│   ├── ielts/             # IELTS test functionality
│   └── career/            # Career guidance features
├── presentation/           # UI components
│   ├── pages/             # Screen implementations
│   └── widgets/           # Reusable UI components
└── shared/                 # Shared resources
    └── themes/            # App styling and themes
```

## Configuration

### API Keys

The app uses environment variables for secure API key management:

- **OPENAI_API_KEY**: Required for transcription and assessment
- **GOOGLE_CLOUD_PROJECT_ID**: Optional for Speech-to-Text
- **BACKEND_API_URL**: Backend service URL (defaults to localhost:8000)

### Security

- API keys are never committed to version control
- Keys are loaded at build time only
- Use different keys for development and production

## Development

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

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

3. **Audio Recording Issues**
   - Check microphone permissions
   - Verify audio format compatibility
   - Check device audio settings

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Check the troubleshooting section
- Review the API_SETUP.md file
- Open an issue on GitHub
