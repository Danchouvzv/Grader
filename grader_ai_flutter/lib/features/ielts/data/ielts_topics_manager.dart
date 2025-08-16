import '../models/ielts_speaking_test.dart';
import 'ielts_topics_data.dart';
import 'ielts_topics_extended.dart';

class IeltsTopicsManager {
  // Получить все доступные топики
  static List<IeltsSpeakingTest> getAllTopics() {
    final List<IeltsSpeakingTest> allTopics = [];
    allTopics.addAll(IeltsTopicsData.allTests);
    allTopics.addAll(IeltsTopicsExtended.additionalTests);
    return allTopics;
  }

  // Получить топики по категории
  static List<IeltsSpeakingTest> getTopicsByCategory(String category) {
    final allTopics = getAllTopics();
    return allTopics.where((test) => test.tags.contains(category)).toList();
  }

  // Получить топики по сложности
  static List<IeltsSpeakingTest> getTopicsByDifficulty(String difficulty) {
    final allTopics = getAllTopics();
    return allTopics.where((test) => test.difficulty == difficulty).toList();
  }

  // Получить случайный топик
  static IeltsSpeakingTest getRandomTopic() {
    final allTopics = getAllTopics();
    final random = DateTime.now().millisecondsSinceEpoch;
    return allTopics[random % allTopics.length];
  }

  // Поиск топиков по ключевым словам
  static List<IeltsSpeakingTest> searchTopics(String query) {
    final allTopics = getAllTopics();
    final lowercaseQuery = query.toLowerCase();
    return allTopics.where((test) {
      return test.title.toLowerCase().contains(lowercaseQuery) ||
          test.description.toLowerCase().contains(lowercaseQuery) ||
          test.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Получить топики по тегам
  static List<IeltsSpeakingTest> getTopicsByTags(List<String> tags) {
    final allTopics = getAllTopics();
    return allTopics.where((test) => 
      test.tags.any((tag) => tags.contains(tag))
    ).toList();
  }

  // Получить популярные топики (по умолчанию первые 6)
  static List<IeltsSpeakingTest> getPopularTopics({int limit = 6}) {
    final allTopics = getAllTopics();
    if (allTopics.length <= limit) return allTopics;
    return allTopics.take(limit).toList();
  }

  // Получить новые топики (созданные в последние 30 дней)
  static List<IeltsSpeakingTest> getRecentTopics() {
    final allTopics = getAllTopics();
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return allTopics.where((test) => test.createdAt.isAfter(thirtyDaysAgo)).toList();
  }

  // Получить топики для начинающих (Easy + Medium)
  static List<IeltsSpeakingTest> getTopicsForBeginners() {
    final allTopics = getAllTopics();
    return allTopics.where((test) => 
      test.difficulty == 'Easy' || test.difficulty == 'Medium'
    ).toList();
  }

  // Получить топики для продвинутых (Medium + Hard)
  static List<IeltsSpeakingTest> getTopicsForAdvanced() {
    final allTopics = getAllTopics();
    return allTopics.where((test) => 
      test.difficulty == 'Medium' || test.difficulty == 'Hard'
    ).toList();
  }

  // Получить статистику по топикам
  static Map<String, dynamic> getTopicsStatistics() {
    final allTopics = getAllTopics();
    
    // Подсчет по сложности
    final difficultyCount = <String, int>{};
    for (final test in allTopics) {
      difficultyCount[test.difficulty] = (difficultyCount[test.difficulty] ?? 0) + 1;
    }
    
    // Подсчет по тегам
    final tagCount = <String, int>{};
    for (final test in allTopics) {
      for (final tag in test.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }
    
    // Общая статистика
    return {
      'totalTopics': allTopics.length,
      'difficultyDistribution': difficultyCount,
      'tagDistribution': tagCount,
      'averageDuration': allTopics.fold(0.0, (sum, test) => sum + test.totalDuration) / allTopics.length,
    };
  }

  // Получить рекомендуемые топики на основе предпочтений пользователя
  static List<IeltsSpeakingTest> getRecommendedTopics({
    List<String>? preferredTags,
    String? preferredDifficulty,
    int limit = 3,
  }) {
    final allTopics = getAllTopics();
    List<IeltsSpeakingTest> recommended = [];
    
    // Если есть предпочтения по тегам, используем их
    if (preferredTags != null && preferredTags.isNotEmpty) {
      recommended = getTopicsByTags(preferredTags);
    }
    
    // Если есть предпочтения по сложности, фильтруем по ней
    if (preferredDifficulty != null) {
      recommended = recommended.where((test) => test.difficulty == preferredDifficulty).toList();
    }
    
    // Если рекомендаций мало, добавляем случайные топики
    if (recommended.length < limit) {
      final remaining = allTopics.where((test) => !recommended.contains(test)).toList();
      remaining.shuffle();
      recommended.addAll(remaining.take(limit - recommended.length));
    }
    
    // Ограничиваем количество
    return recommended.take(limit).toList();
  }

  // Получить топики для быстрой практики (короткие, простые)
  static List<IeltsSpeakingTest> getQuickPracticeTopics() {
    final allTopics = getAllTopics();
    return allTopics
        .where((test) => test.difficulty == 'Easy' && test.totalDuration <= 12)
        .take(4)
        .toList();
  }

  // Получить топики для глубокой практики (длинные, сложные)
  static List<IeltsSpeakingTest> getDeepPracticeTopics() {
    final allTopics = getAllTopics();
    return allTopics
        .where((test) => test.difficulty == 'Hard' || test.totalDuration >= 18)
        .take(4)
        .toList();
  }
}
