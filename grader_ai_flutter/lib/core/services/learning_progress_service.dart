import '../../features/ielts/domain/entities/ielts_result.dart';

class LearningProgressService {
  static final LearningProgressService _instance = LearningProgressService._internal();
  factory LearningProgressService() => _instance;
  LearningProgressService._internal();

  // User's learning data
  final List<IeltsResult> _sessionHistory = [];
  final Map<String, int> _topicPracticeCount = {};
  final Map<String, double> _skillProgress = {};
  final List<String> _achievements = [];
  int _studyStreak = 0;
  DateTime? _lastPracticeDate;

  // Getters
  List<IeltsResult> get sessionHistory => _sessionHistory;
  Map<String, int> get topicPracticeCount => _topicPracticeCount;
  Map<String, double> get skillProgress => _skillProgress;
  List<String> get achievements => _achievements;
  int get studyStreak => _studyStreak;
  DateTime? get lastPracticeDate => _lastPracticeDate;

  // Add new session result
  void addSessionResult(IeltsResult result, String topic) {
    _sessionHistory.add(result);
    _topicPracticeCount[topic] = (_topicPracticeCount[topic] ?? 0) + 1;
    
    // Update skill progress
    _updateSkillProgress(result);
    
    // Update study streak
    _updateStudyStreak();
    
    // Check for achievements
    _checkAchievements(result, topic);
  }

  // Update skill progress based on result
  void _updateSkillProgress(IeltsResult result) {
    final bands = result.bands;
    
    // Calculate average progress for each skill
    _skillProgress['fluency'] = _calculateAverageProgress('fluency', bands['fluency']?.toDouble() ?? 0);
    _skillProgress['lexical_resource'] = _calculateAverageProgress('lexical_resource', bands['lexical_resource']?.toDouble() ?? 0);
    _skillProgress['grammar'] = _calculateAverageProgress('grammar', bands['grammar']?.toDouble() ?? 0);
    _skillProgress['pronunciation'] = _calculateAverageProgress('pronunciation', bands['pronunciation']?.toDouble() ?? 0);
  }

  // Calculate average progress for a skill
  double _calculateAverageProgress(String skill, double currentScore) {
    final previousAverage = _skillProgress[skill] ?? 0.0;
    final sessionCount = _sessionHistory.length;
    
    if (sessionCount == 1) {
      return currentScore;
    }
    
    // Weighted average (recent sessions have more weight)
    return (previousAverage * (sessionCount - 1) + currentScore) / sessionCount;
  }

  // Update study streak
  void _updateStudyStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastPracticeDate == null) {
      _studyStreak = 1;
    } else {
      final lastDate = DateTime(_lastPracticeDate!.year, _lastPracticeDate!.month, _lastPracticeDate!.day);
      final daysDifference = today.difference(lastDate).inDays;
      
      if (daysDifference == 1) {
        _studyStreak++;
      } else if (daysDifference > 1) {
        _studyStreak = 1;
      }
      // If daysDifference == 0, streak remains the same
    }
    
    _lastPracticeDate = now;
  }

  // Check for achievements
  void _checkAchievements(IeltsResult result, String topic) {
    // First practice achievement
    if (_sessionHistory.length == 1 && !_achievements.contains('first_practice')) {
      _achievements.add('first_practice');
    }
    
    // Band score achievements
    if (result.overallBand >= 6.0 && !_achievements.contains('band_6')) {
      _achievements.add('band_6');
    }
    if (result.overallBand >= 7.0 && !_achievements.contains('band_7')) {
      _achievements.add('band_7');
    }
    if (result.overallBand >= 8.0 && !_achievements.contains('band_8')) {
      _achievements.add('band_8');
    }
    
    // Session count achievements
    if (_sessionHistory.length >= 5 && !_achievements.contains('5_sessions')) {
      _achievements.add('5_sessions');
    }
    if (_sessionHistory.length >= 10 && !_achievements.contains('10_sessions')) {
      _achievements.add('10_sessions');
    }
    if (_sessionHistory.length >= 25 && !_achievements.contains('25_sessions')) {
      _achievements.add('25_sessions');
    }
    
    // Streak achievements
    if (_studyStreak >= 3 && !_achievements.contains('3_day_streak')) {
      _achievements.add('3_day_streak');
    }
    if (_studyStreak >= 7 && !_achievements.contains('7_day_streak')) {
      _achievements.add('7_day_streak');
    }
    if (_studyStreak >= 30 && !_achievements.contains('30_day_streak')) {
      _achievements.add('30_day_streak');
    }
    
    // Topic mastery achievements
    if (_topicPracticeCount[topic] != null && _topicPracticeCount[topic]! >= 5 && !_achievements.contains('${topic}_master')) {
      _achievements.add('${topic}_master');
    }
  }

  // Get personalized recommendations
  List<LearningRecommendation> getPersonalizedRecommendations() {
    final recommendations = <LearningRecommendation>[];
    
    // Analyze weak areas
    final weakSkills = _skillProgress.entries
        .where((entry) => entry.value < 6.0)
        .map((entry) => entry.key)
        .toList();
    
    if (weakSkills.contains('fluency')) {
      recommendations.add(LearningRecommendation(
        title: 'Improve Fluency',
        description: 'Practice speaking more smoothly and naturally',
        type: RecommendationType.practice,
        priority: Priority.high,
        exercises: [
          'Daily speaking practice',
          'Shadowing exercises',
          'Record yourself speaking',
        ],
      ));
    }
    
    if (weakSkills.contains('lexical_resource')) {
      recommendations.add(LearningRecommendation(
        title: 'Expand Vocabulary',
        description: 'Learn more varied and precise words',
        type: RecommendationType.vocabulary,
        priority: Priority.high,
        exercises: [
          'Word families practice',
          'Collocations exercises',
          'Topic-specific vocabulary',
        ],
      ));
    }
    
    if (weakSkills.contains('grammar')) {
      recommendations.add(LearningRecommendation(
        title: 'Grammar Practice',
        description: 'Focus on sentence structure and accuracy',
        type: RecommendationType.grammar,
        priority: Priority.medium,
        exercises: [
          'Complex sentence practice',
          'Tense exercises',
          'Error correction',
        ],
      ));
    }
    
    if (weakSkills.contains('pronunciation')) {
      recommendations.add(LearningRecommendation(
        title: 'Pronunciation Practice',
        description: 'Work on clear speech and intonation',
        type: RecommendationType.pronunciation,
        priority: Priority.medium,
        exercises: [
          'Phonetic exercises',
          'Intonation practice',
          'Tongue twisters',
        ],
      ));
    }
    
    // Topic-based recommendations
    final leastPracticedTopic = _topicPracticeCount.entries
        .reduce((a, b) => a.value < b.value ? a : b);
    
    if (leastPracticedTopic.value < 3) {
      recommendations.add(LearningRecommendation(
        title: 'Practice ${leastPracticedTopic.key}',
        description: 'You haven\'t practiced this topic much',
        type: RecommendationType.topic,
        priority: Priority.low,
        exercises: [
          '${leastPracticedTopic.key} questions',
          'Related vocabulary',
          'Sample answers',
        ],
      ));
    }
    
    // Streak-based recommendations
    if (_studyStreak < 3) {
      recommendations.add(LearningRecommendation(
        title: 'Build Study Habit',
        description: 'Practice daily to build a consistent routine',
        type: RecommendationType.habit,
        priority: Priority.high,
        exercises: [
          'Daily 10-minute practice',
          'Set reminders',
          'Track progress',
        ],
      ));
    }
    
    return recommendations;
  }

  // Get progress statistics
  LearningStats getLearningStats() {
    final totalSessions = _sessionHistory.length;
    final averageBand = totalSessions > 0 
        ? _sessionHistory.map((r) => r.overallBand).reduce((a, b) => a + b) / totalSessions
        : 0.0;
    
    final bestBand = totalSessions > 0
        ? _sessionHistory.map((r) => r.overallBand).reduce((a, b) => a > b ? a : b)
        : 0.0;
    
    final mostPracticedTopic = _topicPracticeCount.isNotEmpty
        ? _topicPracticeCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'None';
    
    return LearningStats(
      totalSessions: totalSessions,
      averageBand: averageBand,
      bestBand: bestBand,
      studyStreak: _studyStreak,
      mostPracticedTopic: mostPracticedTopic,
      achievementsCount: _achievements.length,
      skillProgress: Map.from(_skillProgress),
    );
  }

  // Get next practice suggestions
  List<String> getNextPracticeSuggestions() {
    final suggestions = <String>[];
    
    // Based on weak skills
    final weakSkills = _skillProgress.entries
        .where((entry) => entry.value < 6.0)
        .map((entry) => entry.key)
        .toList();
    
    if (weakSkills.contains('fluency')) {
      suggestions.add('Try Part 1 questions for fluency practice');
    }
    if (weakSkills.contains('lexical_resource')) {
      suggestions.add('Practice Part 2 with topic-specific vocabulary');
    }
    if (weakSkills.contains('grammar')) {
      suggestions.add('Focus on Part 3 complex sentence structures');
    }
    
    // Based on topic practice
    final leastPracticedTopic = _topicPracticeCount.entries
        .reduce((a, b) => a.value < b.value ? a : b);
    
    if (leastPracticedTopic.value < 3) {
      suggestions.add('Practice more ${leastPracticedTopic.key} questions');
    }
    
    // Based on recent performance
    if (_sessionHistory.isNotEmpty) {
      final lastResult = _sessionHistory.last;
      if (lastResult.overallBand < 6.0) {
        suggestions.add('Try easier topics to build confidence');
      } else if (lastResult.overallBand >= 7.0) {
        suggestions.add('Challenge yourself with advanced topics');
      }
    }
    
    return suggestions.isEmpty ? ['Keep practicing to improve!'] : suggestions;
  }

  // Reset all data (for testing)
  void resetData() {
    _sessionHistory.clear();
    _topicPracticeCount.clear();
    _skillProgress.clear();
    _achievements.clear();
    _studyStreak = 0;
    _lastPracticeDate = null;
  }
}

// Data models
class LearningRecommendation {
  final String title;
  final String description;
  final RecommendationType type;
  final Priority priority;
  final List<String> exercises;

  LearningRecommendation({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.exercises,
  });
}

enum RecommendationType {
  practice,
  vocabulary,
  grammar,
  pronunciation,
  topic,
  habit,
}

enum Priority {
  low,
  medium,
  high,
}

class LearningStats {
  final int totalSessions;
  final double averageBand;
  final double bestBand;
  final int studyStreak;
  final String mostPracticedTopic;
  final int achievementsCount;
  final Map<String, double> skillProgress;

  LearningStats({
    required this.totalSessions,
    required this.averageBand,
    required this.bestBand,
    required this.studyStreak,
    required this.mostPracticedTopic,
    required this.achievementsCount,
    required this.skillProgress,
  });
}
