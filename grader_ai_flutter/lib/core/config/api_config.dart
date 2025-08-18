class ApiConfig {
  // OpenAI Configuration
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '', // Empty default for security
  );
  
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String openAiModel = 'gpt-4o'; // Latest model for best results
  
  // Google Cloud Speech-to-Text Configuration  
  static const String googleCloudProjectId = String.fromEnvironment(
    'GOOGLE_CLOUD_PROJECT_ID',
    defaultValue: '',
  );
  
  static const String googleCloudRegion = 'us-central1';
  static const String speechRecognizer = 'projects/$googleCloudProjectId/locations/$googleCloudRegion/recognizers/ielts-recognizer';
  
  // Backend API Configuration
  static const String backendApiUrl = String.fromEnvironment(
    'BACKEND_API_URL',
    defaultValue: 'http://localhost:8000',
  );
  
  // Audio Configuration
  static const int sampleRate = 44100; // 44.1 kHz for iOS compatibility
  static const int channels = 1; // Mono
  static const String audioFormat = 'm4a'; // AAC for iOS
  
  // Assessment Configuration
  static const int maxRecordingDuration = 180; // 3 minutes max
  static const int minRecordingDuration = 30; // 30 seconds minimum
  
  // Features flags
  static const bool enableRealTimeTranscription = true;
  static const bool enableOfflineMode = false;
  static const bool enableAnalytics = true;
  
  // Validation
  static bool get isOpenAiConfigured => 
    openAiApiKey.isNotEmpty && 
    openAiApiKey != 'sk-your-openai-api-key-here';
    
  static bool get isGoogleCloudConfigured =>
    googleCloudProjectId.isNotEmpty &&
    googleCloudProjectId != 'your-project-id';
    
  static bool get isBackendConfigured =>
    backendApiUrl.isNotEmpty &&
    backendApiUrl != 'http://localhost:8000';
}
