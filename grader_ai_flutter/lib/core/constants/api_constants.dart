class ApiConstants {
  static const String baseUrl = 'http://localhost:8000';
  
  // IELTS endpoints
  static const String getTask = '/task';
  static const String assessAudio = '/assess';
  
  // Career endpoints
  static const String careerAssessmentQuestions = '/career-assessment-questions';
  static const String careerGuidance = '/career-guidance';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);
}
