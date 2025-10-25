class FirestoreConstants {
  // Time periods
  static const Duration weeklyProgressDays = Duration(days: 6); // Last 7 days (0-6)
  static const Duration streakCheckDays = Duration(days: 30);
  static const Duration streakGracePeriod = Duration(days: 1); // Can skip today if did yesterday
  
  // Limits
  static const int defaultRecentResultsLimit = 10;
  static const int maxRecentResultsLimit = 100;
  
  // Validation
  static const double minBandScore = 0.0;
  static const double maxBandScore = 9.0;
  static const int minMatchPercentage = 0;
  static const int maxMatchPercentage = 100;
  
  // Collections
  static const String usersCollection = 'users';
  static const String ieltsResultsCollection = 'ielts_results';
  static const String careerSwipesCollection = 'career_swipes';
  static const String coachCollection = 'coach';
  static const String statsCollection = 'stats';
  
  // Documents
  static const String weeklyPlanDoc = 'weekly_plan';
  static const String streaksDoc = 'streaks';
  
  // Fields
  static const String isTestDataField = 'isTestData';
  static const String createdAtField = 'createdAt';
  static const String lastActiveAtField = 'lastActiveAt';
  static const String totalIeltsSessionsField = 'totalIeltsSessions';
  static const String bestIeltsScoreField = 'bestIeltsScore';
  static const String currentStreakField = 'currentStreak';
}
