import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final DateTime joinDate;
  final UserStats stats;
  final List<Achievement> achievements;
  final UserSettings settings;
  final List<LearningSession> recentSessions;
  final List<CareerAssessment> careerAssessments;
  final List<Goal> goals;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    required this.joinDate,
    required this.stats,
    required this.achievements,
    required this.settings,
    required this.recentSessions,
    required this.careerAssessments,
    required this.goals,
  });

  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? bio,
    DateTime? joinDate,
    UserStats? stats,
    List<Achievement>? achievements,
    UserSettings? settings,
    List<LearningSession>? recentSessions,
    List<CareerAssessment>? careerAssessments,
    List<Goal>? goals,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      joinDate: joinDate ?? this.joinDate,
      stats: stats ?? this.stats,
      achievements: achievements ?? this.achievements,
      settings: settings ?? this.settings,
      recentSessions: recentSessions ?? this.recentSessions,
      careerAssessments: careerAssessments ?? this.careerAssessments,
      goals: goals ?? this.goals,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      achievements: (json['achievements'] as List?)
          ?.map((a) => Achievement.fromJson(a))
          .toList() ?? [],
      settings: UserSettings.fromJson(json['settings'] ?? {}),
      recentSessions: (json['recentSessions'] as List?)
          ?.map((s) => LearningSession.fromJson(s))
          .toList() ?? [],
      careerAssessments: (json['careerAssessments'] as List?)
          ?.map((c) => CareerAssessment.fromJson(c))
          .toList() ?? [],
      goals: (json['goals'] as List?)
          ?.map((g) => Goal.fromJson(g))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'joinDate': joinDate.toIso8601String(),
      'stats': stats.toJson(),
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'settings': settings.toJson(),
      'recentSessions': recentSessions.map((s) => s.toJson()).toList(),
      'careerAssessments': careerAssessments.map((c) => c.toJson()).toList(),
      'goals': goals.map((g) => g.toJson()).toList(),
    };
  }
}

class UserStats {
  final int totalSessions;
  final int totalMinutes;
  final double averageScore;
  final int currentStreak;
  final int longestStreak;
  final int totalAchievements;
  final Map<String, int> skillLevels;
  final Map<String, double> progressByCategory;

  UserStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.averageScore,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalAchievements,
    required this.skillLevels,
    required this.progressByCategory,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalSessions: json['totalSessions'] ?? 0,
      totalMinutes: json['totalMinutes'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalAchievements: json['totalAchievements'] ?? 0,
      skillLevels: Map<String, int>.from(json['skillLevels'] ?? {}),
      progressByCategory: Map<String, double>.from(json['progressByCategory'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'averageScore': averageScore,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalAchievements': totalAchievements,
      'skillLevels': skillLevels,
      'progressByCategory': progressByCategory,
    };
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime earnedAt;
  final AchievementType type;
  final int points;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earnedAt,
    required this.type,
    required this.points,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      earnedAt: DateTime.parse(json['earnedAt'] ?? DateTime.now().toIso8601String()),
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == 'AchievementType.${json['type']}',
        orElse: () => AchievementType.general,
      ),
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'earnedAt': earnedAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'points': points,
    };
  }
}

enum AchievementType { general, speaking, career, streak, milestone }

class UserSettings {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final String language;
  final String theme;
  final bool autoSave;
  final int sessionReminderMinutes;
  final bool soundEnabled;
  final int reminderHour;
  final bool darkMode;
  final String preferredLanguage;
  final String audioQuality;
  final List<String> reminderDays;

  UserSettings({
    required this.notificationsEnabled,
    required this.emailNotifications,
    required this.pushNotifications,
    required this.language,
    required this.theme,
    required this.autoSave,
    required this.sessionReminderMinutes,
    required this.soundEnabled,
    required this.reminderHour,
    required this.darkMode,
    required this.preferredLanguage,
    required this.audioQuality,
    required this.reminderDays,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'system',
      autoSave: json['autoSave'] ?? true,
      sessionReminderMinutes: json['sessionReminderMinutes'] ?? 30,
      soundEnabled: json['soundEnabled'] ?? true,
      reminderHour: json['reminderHour'] ?? 9,
      darkMode: json['darkMode'] ?? false,
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      audioQuality: json['audioQuality'] ?? 'high',
      reminderDays: List<String>.from(json['reminderDays'] ?? ['monday', 'wednesday', 'friday']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'language': language,
      'theme': theme,
      'autoSave': autoSave,
      'sessionReminderMinutes': sessionReminderMinutes,
      'soundEnabled': soundEnabled,
      'reminderHour': reminderHour,
      'darkMode': darkMode,
      'preferredLanguage': preferredLanguage,
      'audioQuality': audioQuality,
      'reminderDays': reminderDays,
    };
  }

  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    String? language,
    String? theme,
    bool? autoSave,
    int? sessionReminderMinutes,
    bool? soundEnabled,
    int? reminderHour,
    bool? darkMode,
    String? preferredLanguage,
    String? audioQuality,
    List<String>? reminderDays,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      autoSave: autoSave ?? this.autoSave,
      sessionReminderMinutes: sessionReminderMinutes ?? this.sessionReminderMinutes,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      darkMode: darkMode ?? this.darkMode,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      audioQuality: audioQuality ?? this.audioQuality,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }
}

class LearningSession {
  final String id;
  final String type;
  final DateTime date;
  final int durationMinutes;
  final double score;
  final String? feedback;
  final Map<String, dynamic> details;

  LearningSession({
    required this.id,
    required this.type,
    required this.date,
    required this.durationMinutes,
    required this.score,
    this.feedback,
    required this.details,
  });

  factory LearningSession.fromJson(Map<String, dynamic> json) {
    return LearningSession(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      durationMinutes: json['durationMinutes'] ?? 0,
      score: (json['score'] ?? 0.0).toDouble(),
      feedback: json['feedback'],
      details: Map<String, dynamic>.from(json['details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'score': score,
      'feedback': feedback,
      'details': details,
    };
  }
}

class CareerAssessment {
  final String id;
  final DateTime date;
  final String type;
  final Map<String, double> scores;
  final List<String> recommendations;
  final double overallScore;

  CareerAssessment({
    required this.id,
    required this.date,
    required this.type,
    required this.scores,
    required this.recommendations,
    required this.overallScore,
  });

  factory CareerAssessment.fromJson(Map<String, dynamic> json) {
    return CareerAssessment(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      type: json['type'] ?? '',
      scores: Map<String, double>.from(json['scores'] ?? {}),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      overallScore: (json['overallScore'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'scores': scores,
      'recommendations': recommendations,
      'overallScore': overallScore,
    };
  }
}

class Goal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final GoalStatus status;
  final DateTime targetDate;
  final DateTime? completedDate;
  final double progress;
  final List<String> milestones;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.targetDate,
    this.completedDate,
    required this.progress,
    required this.milestones,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: GoalType.values.firstWhere(
        (e) => e.toString() == 'GoalType.${json['type']}',
        orElse: () => GoalType.general,
      ),
      status: GoalStatus.values.firstWhere(
        (e) => e.toString() == 'GoalStatus.${json['status']}',
        orElse: () => GoalStatus.inProgress,
      ),
      targetDate: DateTime.parse(json['targetDate'] ?? DateTime.now().toIso8601String()),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      progress: (json['progress'] ?? 0.0).toDouble(),
      milestones: List<String>.from(json['milestones'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'targetDate': targetDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'progress': progress,
      'milestones': milestones,
    };
  }
}

enum GoalType { general, speaking, career, learning, personal }
enum GoalStatus { notStarted, inProgress, completed, cancelled }
