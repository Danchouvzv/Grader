class Achievement {
  final int? id;
  final int userId;
  final String achievementType;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedAt;
  final String? iconData; // Flutter IconData name
  final String? colorHex; // Hex color for the achievement

  const Achievement({
    this.id,
    required this.userId,
    required this.achievementType,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    this.iconData,
    this.colorHex,
  });

  Achievement copyWith({
    int? id,
    int? userId,
    String? achievementType,
    String? title,
    String? description,
    String? icon,
    DateTime? unlockedAt,
    String? iconData,
    String? colorHex,
  }) {
    return Achievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementType: achievementType ?? this.achievementType,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      iconData: iconData ?? this.iconData,
      colorHex: colorHex ?? this.colorHex,
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
      'icon_data': iconData,
      'color_hex': colorHex,
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
      iconData: map['icon_data'],
      colorHex: map['color_hex'],
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
        iconData: 'Icons.flag_rounded',
        colorHex: '#10B981',
      ),
      
      // Session milestones
      Achievement(
        userId: userId,
        achievementType: 'sessions_5',
        title: 'Getting Started',
        description: 'Complete 5 practice sessions',
        icon: '🌟',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.star_rounded',
        colorHex: '#F59E0B',
      ),
      Achievement(
        userId: userId,
        achievementType: 'sessions_10',
        title: 'Dedicated Learner',
        description: 'Complete 10 practice sessions',
        icon: '📚',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.school_rounded',
        colorHex: '#3B82F6',
      ),
      Achievement(
        userId: userId,
        achievementType: 'sessions_25',
        title: 'Committed Student',
        description: 'Complete 25 practice sessions',
        icon: '🎓',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.school_outlined',
        colorHex: '#8B5CF6',
      ),
      Achievement(
        userId: userId,
        achievementType: 'sessions_50',
        title: 'IELTS Warrior',
        description: 'Complete 50 practice sessions',
        icon: '⚔️',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.military_tech_rounded',
        colorHex: '#EF4444',
      ),
      Achievement(
        userId: userId,
        achievementType: 'sessions_100',
        title: 'Century Club',
        description: 'Complete 100 practice sessions',
        icon: '💯',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.emoji_events_rounded',
        colorHex: '#F59E0B',
      ),
      
      // Streak achievements
      Achievement(
        userId: userId,
        achievementType: 'streak_3',
        title: 'On Fire',
        description: 'Maintain a 3-day practice streak',
        icon: '🔥',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.local_fire_department_rounded',
        colorHex: '#F97316',
      ),
      Achievement(
        userId: userId,
        achievementType: 'streak_7',
        title: 'Weekly Warrior',
        description: 'Maintain a 7-day practice streak',
        icon: '📅',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.calendar_today_rounded',
        colorHex: '#EC4899',
      ),
      Achievement(
        userId: userId,
        achievementType: 'streak_30',
        title: 'Monthly Master',
        description: 'Maintain a 30-day practice streak',
        icon: '🏆',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.workspace_premium_rounded',
        colorHex: '#F59E0B',
      ),
      
      // Band score achievements
      Achievement(
        userId: userId,
        achievementType: 'band_6',
        title: 'Competent User',
        description: 'Achieve Band 6.0 or higher',
        icon: '🎖️',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.workspace_premium_outlined',
        colorHex: '#6B7280',
      ),
      Achievement(
        userId: userId,
        achievementType: 'band_7',
        title: 'Good User',
        description: 'Achieve Band 7.0 or higher',
        icon: '🥉',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.workspace_premium_rounded',
        colorHex: '#CD7F32',
      ),
      Achievement(
        userId: userId,
        achievementType: 'band_8',
        title: 'Very Good User',
        description: 'Achieve Band 8.0 or higher',
        icon: '🥈',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.workspace_premium_rounded',
        colorHex: '#C0C0C0',
      ),
      Achievement(
        userId: userId,
        achievementType: 'band_9',
        title: 'Expert User',
        description: 'Achieve Band 9.0 - Perfect Score!',
        icon: '🥇',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.workspace_premium_rounded',
        colorHex: '#FFD700',
      ),
      
      // Time-based achievements
      Achievement(
        userId: userId,
        achievementType: 'time_1hour',
        title: 'Hour of Practice',
        description: 'Practice for over 1 hour total',
        icon: '⏰',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.access_time_rounded',
        colorHex: '#06B6D4',
      ),
      Achievement(
        userId: userId,
        achievementType: 'time_5hours',
        title: 'Dedicated Hours',
        description: 'Practice for over 5 hours total',
        icon: '⏳',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.timer_rounded',
        colorHex: '#8B5CF6',
      ),
      Achievement(
        userId: userId,
        achievementType: 'time_10hours',
        title: 'Time Master',
        description: 'Practice for over 10 hours total',
        icon: '🕐',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.schedule_rounded',
        colorHex: '#10B981',
      ),
      
      // Special achievements
      Achievement(
        userId: userId,
        achievementType: 'all_parts',
        title: 'Complete Speaker',
        description: 'Practice all 3 IELTS Speaking parts',
        icon: '🎤',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.mic_rounded',
        colorHex: '#EC4899',
      ),
      Achievement(
        userId: userId,
        achievementType: 'improvement',
        title: 'Rising Star',
        description: 'Improve your average band by 1.0 point',
        icon: '📈',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.trending_up_rounded',
        colorHex: '#10B981',
      ),
      Achievement(
        userId: userId,
        achievementType: 'perfectionist',
        title: 'Perfectionist',
        description: 'Score 8.0+ in all four skills in one session',
        icon: '💎',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.diamond_rounded',
        colorHex: '#8B5CF6',
      ),
      
      // 🎯 NEW ACHIEVEMENTS - Advanced Milestones
      Achievement(
        userId: userId,
        achievementType: 'sessions_200',
        title: 'Double Century',
        description: 'Complete 200 practice sessions',
        icon: '🎯',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.gps_fixed_rounded',
        colorHex: '#DC2626',
      ),
      Achievement(
        userId: userId,
        achievementType: 'sessions_500',
        title: 'IELTS Legend',
        description: 'Complete 500 practice sessions',
        icon: '👑',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.king_bed_rounded',
        colorHex: '#7C3AED',
      ),
      
      // 🔥 NEW STREAK ACHIEVEMENTS
      Achievement(
        userId: userId,
        achievementType: 'streak_14',
        title: 'Two Week Champion',
        description: 'Maintain a 14-day practice streak',
        icon: '🔥',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.local_fire_department_rounded',
        colorHex: '#F97316',
      ),
      Achievement(
        userId: userId,
        achievementType: 'streak_60',
        title: 'Two Month Master',
        description: 'Maintain a 60-day practice streak',
        icon: '🌟',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.star_rounded',
        colorHex: '#F59E0B',
      ),
      Achievement(
        userId: userId,
        achievementType: 'streak_100',
        title: 'Century Streak',
        description: 'Maintain a 100-day practice streak',
        icon: '💯',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.emoji_events_rounded',
        colorHex: '#EF4444',
      ),
      
      // 🎤 SPEAKING SKILL ACHIEVEMENTS
      Achievement(
        userId: userId,
        achievementType: 'fluency_master',
        title: 'Fluency Master',
        description: 'Achieve 8.0+ in Fluency & Coherence',
        icon: '🗣️',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.record_voice_over_rounded',
        colorHex: '#10B981',
      ),
      Achievement(
        userId: userId,
        achievementType: 'vocabulary_expert',
        title: 'Vocabulary Expert',
        description: 'Achieve 8.0+ in Lexical Resource',
        icon: '📚',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.menu_book_rounded',
        colorHex: '#3B82F6',
      ),
      Achievement(
        userId: userId,
        achievementType: 'grammar_guru',
        title: 'Grammar Guru',
        description: 'Achieve 8.0+ in Grammar Range & Accuracy',
        icon: '📝',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.edit_rounded',
        colorHex: '#8B5CF6',
      ),
      Achievement(
        userId: userId,
        achievementType: 'pronunciation_pro',
        title: 'Pronunciation Pro',
        description: 'Achieve 8.0+ in Pronunciation',
        icon: '🎵',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.graphic_eq_rounded',
        colorHex: '#EC4899',
      ),
      
      // 🏆 SPECIAL ACHIEVEMENTS
      Achievement(
        userId: userId,
        achievementType: 'early_bird',
        title: 'Early Bird',
        description: 'Complete a session before 7 AM',
        icon: '🌅',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.wb_sunny_rounded',
        colorHex: '#F59E0B',
      ),
      Achievement(
        userId: userId,
        achievementType: 'night_owl',
        title: 'Night Owl',
        description: 'Complete a session after 11 PM',
        icon: '🦉',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.nights_stay_rounded',
        colorHex: '#1F2937',
      ),
      Achievement(
        userId: userId,
        achievementType: 'weekend_warrior',
        title: 'Weekend Warrior',
        description: 'Complete 5 sessions in one weekend',
        icon: '🏃‍♂️',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.directions_run_rounded',
        colorHex: '#10B981',
      ),
      Achievement(
        userId: userId,
        achievementType: 'consistency_king',
        title: 'Consistency King',
        description: 'Practice every day for 2 weeks',
        icon: '👑',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.king_bed_rounded',
        colorHex: '#7C3AED',
      ),
      
      // 🎯 IMPROVEMENT ACHIEVEMENTS
      Achievement(
        userId: userId,
        achievementType: 'rapid_improver',
        title: 'Rapid Improver',
        description: 'Improve band score by 1.5 points in one week',
        icon: '⚡',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.flash_on_rounded',
        colorHex: '#F59E0B',
      ),
      Achievement(
        userId: userId,
        achievementType: 'steady_progress',
        title: 'Steady Progress',
        description: 'Improve band score by 0.5 points for 5 consecutive sessions',
        icon: '📈',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.trending_up_rounded',
        colorHex: '#10B981',
      ),
      Achievement(
        userId: userId,
        achievementType: 'comeback_kid',
        title: 'Comeback Kid',
        description: 'Return after a 7+ day break and score higher than before',
        icon: '🔄',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.refresh_rounded',
        colorHex: '#3B82F6',
      ),
      
      // 🎪 FUN ACHIEVEMENTS
      Achievement(
        userId: userId,
        achievementType: 'lucky_seven',
        title: 'Lucky Seven',
        description: 'Score exactly 7.0 in overall band',
        icon: '🍀',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.casino_rounded',
        colorHex: '#10B981',
      ),
      Achievement(
        userId: userId,
        achievementType: 'perfect_timing',
        title: 'Perfect Timing',
        description: 'Complete a session in exactly 2 minutes',
        icon: '⏱️',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.timer_rounded',
        colorHex: '#8B5CF6',
      ),
      Achievement(
        userId: userId,
        achievementType: 'marathon_speaker',
        title: 'Marathon Speaker',
        description: 'Complete 10 sessions in one day',
        icon: '🏃‍♂️',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.directions_run_rounded',
        colorHex: '#EF4444',
      ),
      
      // 🌟 PREMIUM ACHIEVEMENTS
      Achievement(
        userId: userId,
        achievementType: 'premium_member',
        title: 'Premium Member',
        description: 'Upgrade to premium subscription',
        icon: '💎',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.diamond_rounded',
        colorHex: '#F59E0B',
      ),
      Achievement(
        userId: userId,
        achievementType: 'social_butterfly',
        title: 'Social Butterfly',
        description: 'Share your progress 5 times',
        icon: '🦋',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.share_rounded',
        colorHex: '#EC4899',
      ),
      
      // 🎓 EDUCATIONAL ACHIEVEMENTS
      Achievement(
        userId: userId,
        achievementType: 'topic_explorer',
        title: 'Topic Explorer',
        description: 'Practice with 20 different topics',
        icon: '🗺️',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.explore_rounded',
        colorHex: '#3B82F6',
      ),
      Achievement(
        userId: userId,
        achievementType: 'part_master',
        title: 'Part Master',
        description: 'Master all 3 IELTS Speaking parts',
        icon: '🎭',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.theater_comedy_rounded',
        colorHex: '#8B5CF6',
      ),
      Achievement(
        userId: userId,
        achievementType: 'feedback_fan',
        title: 'Feedback Fan',
        description: 'Review detailed feedback 50 times',
        icon: '📖',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.feedback_rounded',
        colorHex: '#10B981',
      ),
      
      // 🏅 ULTIMATE ACHIEVEMENTS
      Achievement(
        userId: userId,
        achievementType: 'ielts_god',
        title: 'IELTS God',
        description: 'Achieve Band 9.0 in all four skills',
        icon: '👑',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.workspace_premium_rounded',
        colorHex: '#FFD700',
      ),
      Achievement(
        userId: userId,
        achievementType: 'unstoppable',
        title: 'Unstoppable',
        description: 'Complete 1000 practice sessions',
        icon: '🚀',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.rocket_launch_rounded',
        colorHex: '#7C3AED',
      ),
      Achievement(
        userId: userId,
        achievementType: 'legendary_streak',
        title: 'Legendary Streak',
        description: 'Maintain a 365-day practice streak',
        icon: '🌟',
        unlockedAt: DateTime.now(),
        iconData: 'Icons.star_rounded',
        colorHex: '#F59E0B',
      ),
    ];
  }

  // Check if achievement is unlocked (unlockedAt is in the past)
  bool get isUnlocked {
    final now = DateTime.now();
    return unlockedAt.isBefore(now) || unlockedAt.isAtSameMomentAs(now);
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
