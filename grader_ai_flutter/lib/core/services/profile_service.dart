import '../database/database_helper.dart';
import '../models/user_profile.dart';
import '../models/session_record.dart';
import '../models/achievement.dart';
import 'firestore_service.dart';

class ProfileService {
  final DatabaseHelper _db = DatabaseHelper();

  // Initialize user profile (call this on first app launch)
  Future<UserProfile> initializeProfile(String name, {String? email}) async {
    final existingProfile = await _db.getFirstUserProfile();
    if (existingProfile != null) {
      return existingProfile;
    }

    final now = DateTime.now();
    final profile = UserProfile(
      name: name,
      email: email,
      createdAt: now,
      updatedAt: now,
    );

    final id = await _db.insertUserProfile(profile);
    return profile.copyWith(id: id);
  }

  // Get current user profile
  Future<UserProfile?> getCurrentProfile() async {
    // First try to get from Firebase
    final firebaseProfile = await FirestoreService.instance.getUserProfile();
    if (firebaseProfile != null) {
      // Sync Firebase data to local database
      final localProfile = await _db.getFirstUserProfile();
      if (localProfile != null) {
        final updatedProfile = localProfile.copyWith(
          name: firebaseProfile['fullName'] ?? localProfile.name,
          email: firebaseProfile['email'] ?? localProfile.email,
          avatarPath: firebaseProfile['avatarPath'] ?? localProfile.avatarPath,
          updatedAt: DateTime.now(),
        );
        await _db.updateUserProfile(updatedProfile);
        return updatedProfile;
      }
    }
    
    // Fallback to local database
    return await _db.getFirstUserProfile();
  }

  // Update profile
  Future<void> updateProfile(UserProfile profile) async {
    final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
    await _db.updateUserProfile(updatedProfile);
  }

  // Update profile with name and avatar
  Future<void> updateProfileFields({required String name, String? avatarPath}) async {
    // Update local database
    final profile = await getCurrentProfile();
    if (profile == null) return;

    final updatedProfile = profile.copyWith(
      name: name,
      avatarPath: avatarPath,
      updatedAt: DateTime.now(),
    );
    await _db.updateUserProfile(updatedProfile);

    // Update Firebase
    await FirestoreService.instance.updateUserProfile(
      fullName: name,
      avatarPath: avatarPath,
    );
  }

  // Update target band
  Future<void> updateTargetBand(double targetBand) async {
    final profile = await getCurrentProfile();
    if (profile == null) return;

    final updatedProfile = profile.copyWith(
      targetBand: targetBand,
      updatedAt: DateTime.now(),
    );
    await _db.updateUserProfile(updatedProfile);
  }

  // Record a new session
  Future<void> recordSession({
    required int userId,
    required String sessionType,
    required String partType,
    required int durationSeconds,
    required double overallBand,
    required double fluencyBand,
    required double lexicalBand,
    required double grammarBand,
    required double pronunciationBand,
    String? transcript,
    String? feedback,
    String? audioPath,
  }) async {
    final record = SessionRecord(
      userId: userId,
      sessionType: sessionType,
      partType: partType,
      durationSeconds: durationSeconds,
      overallBand: overallBand,
      fluencyBand: fluencyBand,
      lexicalBand: lexicalBand,
      grammarBand: grammarBand,
      pronunciationBand: pronunciationBand,
      transcript: transcript,
      feedback: feedback,
      audioPath: audioPath,
      createdAt: DateTime.now(),
    );

    await _db.insertSessionRecord(record);
    await _db.updateDailyStats(userId, record);
    await _updateProfileStats(userId);
    await _checkAndUnlockAchievements(userId, record);
    await _db.updateStreaks(userId);
  }

  // Get recent sessions
  Future<List<SessionRecord>> getRecentSessions(int userId, {int limit = 10}) async {
    return await _db.getSessionRecords(userId, limit: limit);
  }

  // Get user stats
  Future<Map<String, dynamic>> getUserStats(int userId) async {
    return await _db.getUserStats(userId);
  }

  // Get weekly progress
  Future<List<Map<String, dynamic>>> getWeeklyProgress(int userId) async {
    try {
      // Prefer Firestore if signed-in
      final cloud = await FirestoreService.instance.fetchWeeklyProgress();
      if (cloud.isNotEmpty) return cloud;
    } catch (_) {
      // ignore and fallback
    }
    // Fallback to local DB aggregation
    return await _db.getWeeklyProgress(userId);
  }

  // Get achievements
  Future<List<Achievement>> getAchievements(int userId) async {
    return await _db.getAchievements(userId);
  }

  // Private methods
  Future<void> _updateProfileStats(int userId) async {
    final profile = await _db.getUserProfile(userId);
    if (profile == null) return;

    final stats = await _db.getUserStats(userId);
    
    await _db.updateUserProfile(profile.copyWith(
      totalSessions: stats['totalSessions'],
      totalPracticeTime: stats['totalPracticeTime'],
      averageBand: stats['averageBand'],
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> _checkAndUnlockAchievements(int userId, SessionRecord record) async {
    final stats = await _db.getUserStats(userId);
    final existingAchievements = await _db.getAchievements(userId);
    final existingTypes = existingAchievements.map((a) => a.achievementType).toSet();

    print('🏆 Checking achievements for user $userId');
    print('   Total sessions: ${stats['totalSessions']}');
    print('   Overall band: ${record.overallBand}');
    print('   Existing achievements: ${existingTypes.length}');

    // Check for new achievements
    final achievementsToUnlock = <Achievement>[];

    // First session
    if (stats['totalSessions'] == 1 && !existingTypes.contains('first_session')) {
      achievementsToUnlock.add(Achievement(
        userId: userId,
        achievementType: 'first_session',
        title: 'First Steps',
        description: 'Complete your first IELTS practice session',
        icon: '🎯',
        unlockedAt: DateTime.now(),
      ));
    }

    // Session milestones
    final sessionMilestones = {
      5: 'sessions_5',
      10: 'sessions_10',
      25: 'sessions_25',
      50: 'sessions_50',
      100: 'sessions_100',
    };

    for (final entry in sessionMilestones.entries) {
      if (stats['totalSessions'] >= entry.key && !existingTypes.contains(entry.value)) {
        final achievements = Achievement.getAllPossibleAchievements(userId);
        final achievement = achievements.firstWhere((a) => a.achievementType == entry.value);
        achievementsToUnlock.add(achievement.copyWith(unlockedAt: DateTime.now()));
      }
    }

    // Band achievements
    final bandMilestones = {
      6.0: 'band_6',
      7.0: 'band_7',
      8.0: 'band_8',
      9.0: 'band_9',
    };

    for (final entry in bandMilestones.entries) {
      if (record.overallBand >= entry.key && !existingTypes.contains(entry.value)) {
        final achievements = Achievement.getAllPossibleAchievements(userId);
        final achievement = achievements.firstWhere((a) => a.achievementType == entry.value);
        achievementsToUnlock.add(achievement.copyWith(unlockedAt: DateTime.now()));
      }
    }

    // Time achievements
    final timeMilestones = {
      3600: 'time_1hour', // 1 hour
      18000: 'time_5hours', // 5 hours
      36000: 'time_10hours', // 10 hours
    };

    for (final entry in timeMilestones.entries) {
      if (stats['totalPracticeTime'] >= entry.key && !existingTypes.contains(entry.value)) {
        final achievements = Achievement.getAllPossibleAchievements(userId);
        final achievement = achievements.firstWhere((a) => a.achievementType == entry.value);
        achievementsToUnlock.add(achievement.copyWith(unlockedAt: DateTime.now()));
      }
    }

    // Perfectionist achievement
    if (record.fluencyBand >= 8.0 && 
        record.lexicalBand >= 8.0 && 
        record.grammarBand >= 8.0 && 
        record.pronunciationBand >= 8.0 && 
        !existingTypes.contains('perfectionist')) {
      achievementsToUnlock.add(Achievement(
        userId: userId,
        achievementType: 'perfectionist',
        title: 'Perfectionist',
        description: 'Score 8.0+ in all four skills in one session',
        icon: '💎',
        unlockedAt: DateTime.now(),
      ));
    }

    // Unlock all new achievements
    for (final achievement in achievementsToUnlock) {
      await _db.insertAchievement(achievement);
      print('🎉 Achievement unlocked: ${achievement.title}');
    }
    
    if (achievementsToUnlock.isEmpty) {
      print('   No new achievements this session');
    } else {
      print('✅ Unlocked ${achievementsToUnlock.length} achievements!');
    }
  }

  // Check streak achievements
  Future<void> checkStreakAchievements(int userId, int currentStreak) async {
    final existingAchievements = await _db.getAchievements(userId);
    final existingTypes = existingAchievements.map((a) => a.achievementType).toSet();

    final streakMilestones = {
      3: 'streak_3',
      7: 'streak_7',
      30: 'streak_30',
    };

    for (final entry in streakMilestones.entries) {
      if (currentStreak >= entry.key && !existingTypes.contains(entry.value)) {
        final achievements = Achievement.getAllPossibleAchievements(userId);
        final achievement = achievements.firstWhere((a) => a.achievementType == entry.value);
        await _db.insertAchievement(achievement.copyWith(unlockedAt: DateTime.now()));
      }
    }
  }

  // Get performance insights
  Future<Map<String, dynamic>> getPerformanceInsights(int userId) async {
    final sessions = await _db.getSessionRecords(userId, limit: 10);
    if (sessions.isEmpty) {
      return {
        'trend': 'no_data',
        'recommendation': 'Start practicing to see your progress!',
        'weakestSkill': 'N/A',
        'strongestSkill': 'N/A',
      };
    }

    // Calculate trend
    String trend = 'stable';
    if (sessions.length >= 3) {
      final recent = sessions.take(3).map((s) => s.overallBand).toList();
      final older = sessions.skip(3).take(3).map((s) => s.overallBand).toList();
      
      if (older.isNotEmpty) {
        final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
        final olderAvg = older.reduce((a, b) => a + b) / older.length;
        
        if (recentAvg > olderAvg + 0.3) {
          trend = 'improving';
        } else if (recentAvg < olderAvg - 0.3) {
          trend = 'declining';
        }
      }
    }

    // Find weakest and strongest skills
    final allSessions = sessions.take(5).toList();
    final avgSkills = {
      'Fluency': allSessions.map((s) => s.fluencyBand).reduce((a, b) => a + b) / allSessions.length,
      'Vocabulary': allSessions.map((s) => s.lexicalBand).reduce((a, b) => a + b) / allSessions.length,
      'Grammar': allSessions.map((s) => s.grammarBand).reduce((a, b) => a + b) / allSessions.length,
      'Pronunciation': allSessions.map((s) => s.pronunciationBand).reduce((a, b) => a + b) / allSessions.length,
    };

    final weakestSkill = avgSkills.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    final strongestSkill = avgSkills.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Generate recommendation
    String recommendation;
    switch (trend) {
      case 'improving':
        recommendation = 'Great progress! Keep practicing to maintain your momentum.';
        break;
      case 'declining':
        recommendation = 'Focus on your $weakestSkill to improve your scores.';
        break;
      default:
        recommendation = 'Try focusing on $weakestSkill to boost your overall band score.';
    }

    return {
      'trend': trend,
      'recommendation': recommendation,
      'weakestSkill': weakestSkill,
      'strongestSkill': strongestSkill,
      'skillAverages': avgSkills,
    };
  }
}
