enum SwipeAction { like, dislike, superlike }

class Profession {
  final String id;
  final String title;
  final String subtitle;
  final String matchLabel; // "85% Match"
  final double matchPercentage; // 0.85
  final List<String> skills;
  final String education;
  final String salaryRange;
  final List<String> pros;
  final List<String> cons;
  final String heroImage;
  final String category; // "Business", "Creative", "Technical"
  final List<String> actionableAdvice; // Конкретные шаги
  final Map<String, String> ctaLinks; // "jobs": "https://...", "courses": "..."
  final int priority; // Для сортировки рекомендаций
  
  const Profession({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.matchLabel,
    required this.matchPercentage,
    required this.skills,
    required this.education,
    required this.salaryRange,
    required this.pros,
    required this.cons,
    required this.heroImage,
    required this.category,
    required this.actionableAdvice,
    required this.ctaLinks,
    required this.priority,
  });

  // Цвет акцента по категории
  Color get accentColor {
    switch (category.toLowerCase()) {
      case 'business':
        return const Color(0xFF3B82F6); // Blue
      case 'creative':
        return const Color(0xFF10B981); // Green
      case 'technical':
        return const Color(0xFF8B5CF6); // Purple
      case 'healthcare':
        return const Color(0xFFEF4444); // Red
      case 'education':
        return const Color(0xFFF59E0B); // Orange
      default:
        return const Color(0xFF6366F1); // Indigo
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'matchLabel': matchLabel,
      'matchPercentage': matchPercentage,
      'skills': skills,
      'education': education,
      'salaryRange': salaryRange,
      'pros': pros,
      'cons': cons,
      'heroImage': heroImage,
      'category': category,
      'actionableAdvice': actionableAdvice,
      'ctaLinks': ctaLinks,
      'priority': priority,
    };
  }

  factory Profession.fromJson(Map<String, dynamic> json) {
    return Profession(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      matchLabel: json['matchLabel'] ?? '',
      matchPercentage: (json['matchPercentage'] ?? 0.0).toDouble(),
      skills: List<String>.from(json['skills'] ?? []),
      education: json['education'] ?? '',
      salaryRange: json['salaryRange'] ?? '',
      pros: List<String>.from(json['pros'] ?? []),
      cons: List<String>.from(json['cons'] ?? []),
      heroImage: json['heroImage'] ?? '',
      category: json['category'] ?? '',
      actionableAdvice: List<String>.from(json['actionableAdvice'] ?? []),
      ctaLinks: Map<String, String>.from(json['ctaLinks'] ?? {}),
      priority: json['priority'] ?? 0,
    );
  }
}

class SwipeSession {
  final String userId;
  final DateTime startTime;
  final List<String> liked;
  final List<String> disliked;
  final List<String> superliked;
  final List<String> viewed;
  final Map<String, DateTime> swipeTimestamps;
  
  SwipeSession({
    required this.userId,
    required this.startTime,
    required this.liked,
    required this.disliked,
    required this.superliked,
    required this.viewed,
    required this.swipeTimestamps,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'liked': liked,
      'disliked': disliked,
      'superliked': superliked,
      'viewed': viewed,
      'swipeTimestamps': swipeTimestamps.map((k, v) => MapEntry(k, v.toIso8601String())),
    };
  }

  factory SwipeSession.fromJson(Map<String, dynamic> json) {
    return SwipeSession(
      userId: json['userId'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      liked: List<String>.from(json['liked'] ?? []),
      disliked: List<String>.from(json['disliked'] ?? []),
      superliked: List<String>.from(json['superliked'] ?? []),
      viewed: List<String>.from(json['viewed'] ?? []),
      swipeTimestamps: (json['swipeTimestamps'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, DateTime.parse(v))),
    );
  }
}
