import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileService {
  static const String _profileKey = 'user_profile';
  static const String _avatarKey = 'user_avatar';

  // Получить профиль пользователя
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);
      
      if (profileJson != null) {
        return UserProfile.fromJson(jsonDecode(profileJson));
      }
      
      // Если профиля нет, создаем демо-профиль
      return _createDemoProfile();
    } catch (e) {
      print('Error loading profile: $e');
      return _createDemoProfile();
    }
  }

  // Сохранить профиль пользователя
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(profile.toJson());
      await prefs.setString(_profileKey, profileJson);
    } catch (e) {
      print('Error saving profile: $e');
      throw Exception('Failed to save profile');
    }
  }

  // Обновить аватар
  Future<String?> updateAvatar(File imageFile) async {
    try {
      // В реальном приложении здесь была бы загрузка на сервер
      // Сейчас просто сохраняем путь к локальному файлу
      final prefs = await SharedPreferences.getInstance();
      final avatarPath = imageFile.path;
      await prefs.setString(_avatarKey, avatarPath);
      return avatarPath;
    } catch (e) {
      print('Error updating avatar: $e');
      throw Exception('Failed to update avatar');
    }
  }

  // Обновить настройки
  Future<void> updateSettings(UserSettings settings) async {
    try {
      final profile = await getUserProfile('current_user');
      final updatedProfile = profile.copyWith(settings: settings);
      await saveUserProfile(updatedProfile);
    } catch (e) {
      print('Error updating settings: $e');
      throw Exception('Failed to update settings');
    }
  }

  // Добавить новую сессию обучения
  Future<void> addLearningSession(LearningSession session) async {
    try {
      final profile = await getUserProfile('current_user');
      final updatedSessions = [session, ...profile.recentSessions];
      
      // Ограничиваем количество сессий до 10
      if (updatedSessions.length > 10) {
        updatedSessions.removeRange(10, updatedSessions.length);
      }
      
      final updatedProfile = profile.copyWith(
        recentSessions: updatedSessions,
        stats: _updateStatsAfterSession(profile.stats, session),
      );
      
      await saveUserProfile(updatedProfile);
    } catch (e) {
      print('Error adding learning session: $e');
      throw Exception('Failed to add learning session');
    }
  }

  // Добавить карьерную оценку
  Future<void> addCareerAssessment(CareerAssessment assessment) async {
    try {
      final profile = await getUserProfile('current_user');
      final updatedAssessments = [assessment, ...profile.careerAssessments];
      
      // Ограничиваем количество оценок до 5
      if (updatedAssessments.length > 5) {
        updatedAssessments.removeRange(5, updatedAssessments.length);
      }
      
      final updatedProfile = profile.copyWith(
        careerAssessments: updatedAssessments,
      );
      
      await saveUserProfile(updatedProfile);
    } catch (e) {
      print('Error adding career assessment: $e');
      throw Exception('Failed to add career assessment');
    }
  }

  // Добавить цель
  Future<void> addGoal(Goal goal) async {
    try {
      final profile = await getUserProfile('current_user');
      final updatedGoals = [goal, ...profile.goals];
      final updatedProfile = profile.copyWith(goals: updatedGoals);
      await saveUserProfile(updatedProfile);
    } catch (e) {
      print('Error adding goal: $e');
      throw Exception('Failed to add goal');
    }
  }

  // Обновить цель
  Future<void> updateGoal(Goal goal) async {
    try {
      final profile = await getUserProfile('current_user');
      final updatedGoals = profile.goals.map((g) => g.id == goal.id ? goal : g).toList();
      final updatedProfile = profile.copyWith(goals: updatedGoals);
      await saveUserProfile(updatedProfile);
    } catch (e) {
      print('Error updating goal: $e');
      throw Exception('Failed to update goal');
    }
  }

  // Удалить цель
  Future<void> deleteGoal(String goalId) async {
    try {
      final profile = await getUserProfile('current_user');
      final updatedGoals = profile.goals.where((g) => g.id != goalId).toList();
      final updatedProfile = profile.copyWith(goals: updatedGoals);
      await saveUserProfile(updatedProfile);
    } catch (e) {
      print('Error deleting goal: $e');
      throw Exception('Failed to delete goal');
    }
  }

  // Обновить статистику после сессии
  UserStats _updateStatsAfterSession(UserStats stats, LearningSession session) {
    return UserStats(
      totalSessions: stats.totalSessions + 1,
      totalMinutes: stats.totalMinutes + session.durationMinutes,
      averageScore: _calculateNewAverage(stats.averageScore, stats.totalSessions, session.score),
      currentStreak: _calculateNewStreak(stats.currentStreak, session.date),
      longestStreak: stats.longestStreak,
      totalAchievements: stats.totalAchievements,
      skillLevels: stats.skillLevels,
      progressByCategory: _updateProgressByCategory(stats.progressByCategory, session),
    );
  }

  // Вычислить новое среднее значение
  double _calculateNewAverage(double currentAverage, int currentCount, double newScore) {
    if (currentCount == 0) return newScore;
    return ((currentAverage * currentCount) + newScore) / (currentCount + 1);
  }

  // Вычислить новую серию
  int _calculateNewStreak(int currentStreak, DateTime sessionDate) {
    final now = DateTime.now();
    final difference = now.difference(sessionDate).inDays;
    
    if (difference <= 1) {
      return currentStreak + 1;
    } else {
      return 1; // Сбрасываем серию
    }
  }

  // Обновить прогресс по категориям
  Map<String, double> _updateProgressByCategory(
    Map<String, double> currentProgress,
    LearningSession session,
  ) {
    final updatedProgress = Map<String, double>.from(currentProgress);
    
    // Обновляем прогресс для типа сессии
    final sessionType = session.type.toLowerCase();
    final currentValue = updatedProgress[sessionType] ?? 0.0;
    updatedProgress[sessionType] = currentValue + (session.score / 100.0);
    
    return updatedProgress;
  }

  // Создать демо-профиль
  UserProfile _createDemoProfile() {
    return UserProfile(
      id: 'demo_user_001',
      username: 'demo_user',
      email: 'demo@example.com',
      fullName: 'Demo User',
      avatarUrl: null,
      bio: 'Passionate learner exploring AI-powered education',
      joinDate: DateTime.now().subtract(const Duration(days: 30)),
      stats: UserStats(
        totalSessions: 12,
        totalMinutes: 180,
        averageScore: 7.5,
        currentStreak: 5,
        longestStreak: 8,
        totalAchievements: 6,
        skillLevels: {
          'speaking': 7,
          'listening': 6,
          'reading': 8,
          'writing': 7,
        },
        progressByCategory: {
          'ielts': 0.75,
          'career': 0.60,
          'general': 0.80,
        },
      ),
      achievements: [
        Achievement(
          id: '1',
          title: 'First Steps',
          description: 'Complete your first learning session',
          icon: '🎯',
          earnedAt: DateTime.now().subtract(const Duration(days: 25)),
          type: AchievementType.milestone,
          points: 10,
        ),
        Achievement(
          id: '2',
          title: 'Streak Master',
          description: 'Maintain a 5-day learning streak',
          icon: '🔥',
          earnedAt: DateTime.now().subtract(const Duration(days: 2)),
          type: AchievementType.streak,
          points: 25,
        ),
        Achievement(
          id: '3',
          title: 'Speaking Champion',
          description: 'Complete 10 speaking sessions',
          icon: '🎤',
          earnedAt: DateTime.now().subtract(const Duration(days: 1)),
          type: AchievementType.speaking,
          points: 50,
        ),
        Achievement(
          id: '4',
          title: 'Career Explorer',
          description: 'Complete your first career assessment',
          icon: '🧠',
          earnedAt: DateTime.now().subtract(const Duration(days: 15)),
          type: AchievementType.career,
          points: 30,
        ),
        Achievement(
          id: '5',
          title: 'Consistent Learner',
          description: 'Learn for 7 consecutive days',
          icon: '📚',
          earnedAt: DateTime.now().subtract(const Duration(days: 7)),
          type: AchievementType.streak,
          points: 40,
        ),
        Achievement(
          id: '6',
          title: 'High Achiever',
          description: 'Score 8.0 or higher in a session',
          icon: '⭐',
          earnedAt: DateTime.now().subtract(const Duration(days: 3)),
          type: AchievementType.speaking,
          points: 75,
        ),
      ],
      settings: UserSettings(
        notificationsEnabled: true,
        emailNotifications: true,
        pushNotifications: true,
        language: 'en',
        theme: 'system',
        autoSave: true,
        sessionReminderMinutes: 30,
      ),
      recentSessions: [
        LearningSession(
          id: '1',
          type: 'IELTS Speaking',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          durationMinutes: 15,
          score: 7.5,
          feedback: 'Good fluency, work on pronunciation',
          details: {'topic': 'Technology', 'band': 7.5},
        ),
        LearningSession(
          id: '2',
          type: 'IELTS Speaking',
          date: DateTime.now().subtract(const Duration(days: 1)),
          durationMinutes: 12,
          score: 8.0,
          feedback: 'Excellent performance!',
          details: {'topic': 'Environment', 'band': 8.0},
        ),
        LearningSession(
          id: '3',
          type: 'Career Assessment',
          date: DateTime.now().subtract(const Duration(days: 2)),
          durationMinutes: 20,
          score: 85.0,
          feedback: 'Strong analytical skills detected',
          details: {'assessment_type': 'RIASEC + Big Five'},
        ),
      ],
      careerAssessments: [
        CareerAssessment(
          id: '1',
          date: DateTime.now().subtract(const Duration(days: 2)),
          type: 'RIASEC + Big Five',
          scores: {'R': 75, 'I': 85, 'A': 60, 'S': 70, 'E': 80, 'C': 65},
          recommendations: ['Software Engineer', 'Data Scientist', 'Product Manager'],
          overallScore: 85.0,
        ),
      ],
      goals: [
        Goal(
          id: '1',
          title: 'Achieve IELTS Band 8.0',
          description: 'Improve speaking skills to reach Band 8.0',
          type: GoalType.speaking,
          status: GoalStatus.inProgress,
          targetDate: DateTime.now().add(const Duration(days: 60)),
          progress: 0.75,
          milestones: ['Complete 20 speaking sessions', 'Practice pronunciation daily', 'Take mock tests'],
        ),
        Goal(
          id: '2',
          title: 'Complete Career Assessment',
          description: 'Finish comprehensive career guidance assessment',
          type: GoalType.career,
          status: GoalStatus.completed,
          targetDate: DateTime.now().subtract(const Duration(days: 2)),
          completedDate: DateTime.now().subtract(const Duration(days: 2)),
          progress: 1.0,
          milestones: ['Take RIASEC test', 'Complete Big Five assessment', 'Review recommendations'],
        ),
        Goal(
          id: '3',
          title: 'Maintain Learning Streak',
          description: 'Keep learning for 30 consecutive days',
          type: GoalType.learning,
          status: GoalStatus.inProgress,
          targetDate: DateTime.now().add(const Duration(days: 25)),
          progress: 0.17,
          milestones: ['Learn daily', 'Track progress', 'Stay motivated'],
        ),
      ],
    );
  }

  // Экспорт профиля
  Future<String> exportProfile() async {
    try {
      final profile = await getUserProfile('current_user');
      return jsonEncode(profile.toJson());
    } catch (e) {
      print('Error exporting profile: $e');
      throw Exception('Failed to export profile');
    }
  }

  // Импорт профиля
  Future<void> importProfile(String profileJson) async {
    try {
      final profileData = jsonDecode(profileJson);
      final profile = UserProfile.fromJson(profileData);
      await saveUserProfile(profile);
    } catch (e) {
      print('Error importing profile: $e');
      throw Exception('Failed to import profile');
    }
  }

  // Сброс профиля к демо-версии
  Future<void> resetToDemo() async {
    try {
      final demoProfile = _createDemoProfile();
      await saveUserProfile(demoProfile);
    } catch (e) {
      print('Error resetting profile: $e');
      throw Exception('Failed to reset profile');
    }
  }
}
