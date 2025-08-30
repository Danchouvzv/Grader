class Achievement {
  final int? id;
  final int userId;
  final String achievementType;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedAt;

  const Achievement({
    this.id,
    required this.userId,
    required this.achievementType,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
  });

  Achievement copyWith({
    int? id,
    int? userId,
    String? achievementType,
    String? title,
    String? description,
    String? icon,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementType: achievementType ?? this.achievementType,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'achievement_type': achievementType,
      'title': title,
      'description': description,
      'icon': icon,
      'unlocked_at': unlockedAt.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      achievementType: map['achievement_type'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      unlockedAt: DateTime.parse(map['unlocked_at']),
    );
  }

  // Predefined achievements
  static List<Achievement> getAllPossibleAchievements(int userId) {
    return [
      // First steps
      Achievement(
        userId: userId,
        achievementType: 'first_session',
        title: 'First Steps',
        description: 'Complete your first IELTS practice session',
        icon: '🎯',
        unlockedAt: DateTime.now(),
      ),
      
      // Session milestones
      Achievement(
        userId: userId,
        achievementType: 'sessions_5',
        title: 'Getting Started',
        description: 'Complete 5 practice sessions',
        icon: '🌟',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'sessions_10',
        title: 'Dedicated Learner',
        description: 'Complete 10 practice sessions',
        icon: '📚',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'sessions_25',
        title: 'Committed Student',
        description: 'Complete 25 practice sessions',
        icon: '🎓',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'sessions_50',
        title: 'IELTS Warrior',
        description: 'Complete 50 practice sessions',
        icon: '⚔️',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'sessions_100',
        title: 'Century Club',
        description: 'Complete 100 practice sessions',
        icon: '💯',
        unlockedAt: DateTime.now(),
      ),
      
      // Streak achievements
      Achievement(
        userId: userId,
        achievementType: 'streak_3',
        title: 'On Fire',
        description: 'Maintain a 3-day practice streak',
        icon: '🔥',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'streak_7',
        title: 'Weekly Warrior',
        description: 'Maintain a 7-day practice streak',
        icon: '📅',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'streak_30',
        title: 'Monthly Master',
        description: 'Maintain a 30-day practice streak',
        icon: '🏆',
        unlockedAt: DateTime.now(),
      ),
      
      // Band score achievements
      Achievement(
        userId: userId,
        achievementType: 'band_6',
        title: 'Competent User',
        description: 'Achieve Band 6.0 or higher',
        icon: '🎖️',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'band_7',
        title: 'Good User',
        description: 'Achieve Band 7.0 or higher',
        icon: '🥉',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'band_8',
        title: 'Very Good User',
        description: 'Achieve Band 8.0 or higher',
        icon: '🥈',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'band_9',
        title: 'Expert User',
        description: 'Achieve Band 9.0 - Perfect Score!',
        icon: '🥇',
        unlockedAt: DateTime.now(),
      ),
      
      // Time-based achievements
      Achievement(
        userId: userId,
        achievementType: 'time_1hour',
        title: 'Hour of Practice',
        description: 'Practice for over 1 hour total',
        icon: '⏰',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'time_5hours',
        title: 'Dedicated Hours',
        description: 'Practice for over 5 hours total',
        icon: '⏳',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'time_10hours',
        title: 'Time Master',
        description: 'Practice for over 10 hours total',
        icon: '🕐',
        unlockedAt: DateTime.now(),
      ),
      
      // Special achievements
      Achievement(
        userId: userId,
        achievementType: 'all_parts',
        title: 'Complete Speaker',
        description: 'Practice all 3 IELTS Speaking parts',
        icon: '🎤',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'improvement',
        title: 'Rising Star',
        description: 'Improve your average band by 1.0 point',
        icon: '📈',
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        userId: userId,
        achievementType: 'perfectionist',
        title: 'Perfectionist',
        description: 'Score 8.0+ in all four skills in one session',
        icon: '💎',
        unlockedAt: DateTime.now(),
      ),
    ];
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(unlockedAt);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${unlockedAt.day}/${unlockedAt.month}/${unlockedAt.year}';
    }
  }
}
