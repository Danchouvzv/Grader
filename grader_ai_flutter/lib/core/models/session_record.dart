class SessionRecord {
  final int? id;
  final int userId;
  final String sessionType; // 'practice', 'mock_test', 'quick_practice'
  final String partType; // 'part1', 'part2', 'part3'
  final int durationSeconds;
  final double overallBand;
  final double fluencyBand;
  final double lexicalBand;
  final double grammarBand;
  final double pronunciationBand;
  final String? transcript;
  final String? feedback;
  final String? audioPath;
  final DateTime createdAt;

  const SessionRecord({
    this.id,
    required this.userId,
    required this.sessionType,
    required this.partType,
    required this.durationSeconds,
    required this.overallBand,
    required this.fluencyBand,
    required this.lexicalBand,
    required this.grammarBand,
    required this.pronunciationBand,
    this.transcript,
    this.feedback,
    this.audioPath,
    required this.createdAt,
  });

  SessionRecord copyWith({
    int? id,
    int? userId,
    String? sessionType,
    String? partType,
    int? durationSeconds,
    double? overallBand,
    double? fluencyBand,
    double? lexicalBand,
    double? grammarBand,
    double? pronunciationBand,
    String? transcript,
    String? feedback,
    String? audioPath,
    DateTime? createdAt,
  }) {
    return SessionRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionType: sessionType ?? this.sessionType,
      partType: partType ?? this.partType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      overallBand: overallBand ?? this.overallBand,
      fluencyBand: fluencyBand ?? this.fluencyBand,
      lexicalBand: lexicalBand ?? this.lexicalBand,
      grammarBand: grammarBand ?? this.grammarBand,
      pronunciationBand: pronunciationBand ?? this.pronunciationBand,
      transcript: transcript ?? this.transcript,
      feedback: feedback ?? this.feedback,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'session_type': sessionType,
      'part_type': partType,
      'duration_seconds': durationSeconds,
      'overall_band': overallBand,
      'fluency_band': fluencyBand,
      'lexical_band': lexicalBand,
      'grammar_band': grammarBand,
      'pronunciation_band': pronunciationBand,
      'transcript': transcript,
      'feedback': feedback,
      'audio_path': audioPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SessionRecord.fromMap(Map<String, dynamic> map) {
    return SessionRecord(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      sessionType: map['session_type'] ?? '',
      partType: map['part_type'] ?? '',
      durationSeconds: map['duration_seconds']?.toInt() ?? 0,
      overallBand: (map['overall_band'] as num?)?.toDouble() ?? 0.0,
      fluencyBand: (map['fluency_band'] as num?)?.toDouble() ?? 0.0,
      lexicalBand: (map['lexical_band'] as num?)?.toDouble() ?? 0.0,
      grammarBand: (map['grammar_band'] as num?)?.toDouble() ?? 0.0,
      pronunciationBand: (map['pronunciation_band'] as num?)?.toDouble() ?? 0.0,
      transcript: map['transcript'],
      feedback: map['feedback'],
      audioPath: map['audio_path'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Helper methods
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String get partTitle {
    switch (partType) {
      case 'part1':
        return 'Part 1: Introduction';
      case 'part2':
        return 'Part 2: Long Turn';
      case 'part3':
        return 'Part 3: Discussion';
      default:
        return 'IELTS Speaking';
    }
  }

  String get sessionTypeTitle {
    switch (sessionType) {
      case 'practice':
        return 'Practice Session';
      case 'mock_test':
        return 'Mock Test';
      case 'quick_practice':
        return 'Quick Practice';
      default:
        return 'Speaking Session';
    }
  }

  String get bandColor {
    if (overallBand >= 8.0) return '#10B981'; // Green
    if (overallBand >= 7.0) return '#3B82F6'; // Blue
    if (overallBand >= 6.0) return '#F59E0B'; // Orange
    if (overallBand >= 5.0) return '#EF4444'; // Red
    return '#6B7280'; // Gray
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  // Performance indicators
  bool get isGoodPerformance => overallBand >= 6.5;
  bool get isExcellentPerformance => overallBand >= 7.5;
  bool get needsImprovement => overallBand < 5.5;

  // Get weakest skill
  String get weakestSkill {
    final skills = {
      'Fluency': fluencyBand,
      'Vocabulary': lexicalBand,
      'Grammar': grammarBand,
      'Pronunciation': pronunciationBand,
    };
    
    return skills.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  // Get strongest skill
  String get strongestSkill {
    final skills = {
      'Fluency': fluencyBand,
      'Vocabulary': lexicalBand,
      'Grammar': grammarBand,
      'Pronunciation': pronunciationBand,
    };
    
    return skills.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
