class UserProfile {
  final int? id;
  final String name;
  final String? email;
  final String? avatarPath;
  final double targetBand;
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final int totalPracticeTime; // in seconds
  final double averageBand;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    this.id,
    required this.name,
    this.email,
    this.avatarPath,
    this.targetBand = 7.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.totalPracticeTime = 0,
    this.averageBand = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarPath,
    double? targetBand,
    int? currentStreak,
    int? longestStreak,
    int? totalSessions,
    int? totalPracticeTime,
    double? averageBand,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      targetBand: targetBand ?? this.targetBand,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalSessions: totalSessions ?? this.totalSessions,
      totalPracticeTime: totalPracticeTime ?? this.totalPracticeTime,
      averageBand: averageBand ?? this.averageBand,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_path': avatarPath,
      'target_band': targetBand,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_sessions': totalSessions,
      'total_practice_time': totalPracticeTime,
      'average_band': averageBand,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      email: map['email'],
      avatarPath: map['avatar_path'],
      targetBand: (map['target_band'] as num?)?.toDouble() ?? 7.0,
      currentStreak: map['current_streak']?.toInt() ?? 0,
      longestStreak: map['longest_streak']?.toInt() ?? 0,
      totalSessions: map['total_sessions']?.toInt() ?? 0,
      totalPracticeTime: map['total_practice_time']?.toInt() ?? 0,
      averageBand: (map['average_band'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Helper methods
  String get formattedPracticeTime {
    final hours = totalPracticeTime ~/ 3600;
    final minutes = (totalPracticeTime % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get streakText {
    if (currentStreak == 0) return 'Start your streak!';
    if (currentStreak == 1) return '1 day streak';
    return '$currentStreak days streak';
  }

  String get bandText {
    if (averageBand == 0.0) return 'No scores yet';
    return averageBand.toStringAsFixed(1);
  }

  // Achievement progress
  double get progressToTarget {
    if (targetBand == 0.0) return 0.0;
    return (averageBand / targetBand).clamp(0.0, 1.0);
  }

  // Level calculation based on total sessions
  int get level {
    if (totalSessions < 5) return 1;
    if (totalSessions < 15) return 2;
    if (totalSessions < 30) return 3;
    if (totalSessions < 50) return 4;
    if (totalSessions < 75) return 5;
    if (totalSessions < 100) return 6;
    if (totalSessions < 150) return 7;
    if (totalSessions < 200) return 8;
    if (totalSessions < 300) return 9;
    return 10;
  }

  String get levelTitle {
    switch (level) {
      case 1: return 'Beginner';
      case 2: return 'Novice';
      case 3: return 'Learner';
      case 4: return 'Student';
      case 5: return 'Intermediate';
      case 6: return 'Advanced';
      case 7: return 'Expert';
      case 8: return 'Master';
      case 9: return 'Champion';
      case 10: return 'Legend';
      default: return 'Beginner';
    }
  }

  int get sessionsToNextLevel {
    final thresholds = [5, 15, 30, 50, 75, 100, 150, 200, 300];
    for (final threshold in thresholds) {
      if (totalSessions < threshold) {
        return threshold - totalSessions;
      }
    }
    return 0; // Max level reached
  }
}
