import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/profession.dart';

class SwipeDeckController extends ChangeNotifier {
  final List<Profession> _originalDeck;
  List<Profession> _deck = [];
  int _index = 0;
  
  SwipeSession? _currentSession;
  final List<String> _liked = [];
  final List<String> _disliked = [];
  final List<String> _superliked = [];
  final List<String> _viewed = [];
  
  // Геймификация
  int _streakCount = 0;
  int _totalSwipes = 0;
  Map<String, int> _categoryStats = {};
  List<String> _unlockedBadges = [];
  
  SwipeDeckController(this._originalDeck) {
    _deck = List.from(_originalDeck);
    _shuffleDeck();
    _initSession();
  }

  // Getters
  int get index => _index;
  int get total => _deck.length;
  bool get hasMore => _index < _deck.length;
  Profession? get current => hasMore ? _deck[_index] : null;
  List<Profession> get remainingCards => _deck.sublist(_index.clamp(0, _deck.length));
  
  // Статистика
  List<String> get liked => List.unmodifiable(_liked);
  List<String> get disliked => List.unmodifiable(_disliked);
  List<String> get superliked => List.unmodifiable(_superliked);
  List<String> get viewed => List.unmodifiable(_viewed);
  
  // Геймификация
  int get streakCount => _streakCount;
  int get totalSwipes => _totalSwipes;
  double get completionPercentage => total == 0 ? 0 : _index / total;
  Map<String, int> get categoryStats => Map.unmodifiable(_categoryStats);
  List<String> get unlockedBadges => List.unmodifiable(_unlockedBadges);
  
  // Рекомендации
  List<Profession> get topMatches {
    final likedProfessions = _originalDeck.where((p) => _liked.contains(p.id) || _superliked.contains(p.id)).toList();
    likedProfessions.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    return likedProfessions.take(5).toList();
  }

  void _initSession() {
    _currentSession = SwipeSession(
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      startTime: DateTime.now(),
      liked: [],
      disliked: [],
      superliked: [],
      viewed: [],
      swipeTimestamps: {},
    );
  }

  void _shuffleDeck() {
    // Сортируем по приоритету и проценту совпадения, затем перемешиваем в группах
    _deck.sort((a, b) {
      final priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;
      return b.matchPercentage.compareTo(a.matchPercentage);
    });
    
    // Перемешиваем каждую группу из 3-4 карточек для разнообразия
    final random = Random();
    for (int i = 0; i < _deck.length - 3; i += 4) {
      final end = (i + 4).clamp(0, _deck.length);
      final sublist = _deck.sublist(i, end);
      sublist.shuffle(random);
      _deck.replaceRange(i, end, sublist);
    }
  }

  Future<void> loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Загружаем основные списки
      _liked.addAll(prefs.getStringList('career_liked') ?? []);
      _disliked.addAll(prefs.getStringList('career_disliked') ?? []);
      _superliked.addAll(prefs.getStringList('career_superliked') ?? []);
      _viewed.addAll(prefs.getStringList('career_viewed') ?? []);
      
      // Загружаем статистику
      _streakCount = prefs.getInt('career_streak') ?? 0;
      _totalSwipes = prefs.getInt('career_total_swipes') ?? 0;
      _unlockedBadges.addAll(prefs.getStringList('career_badges') ?? []);
      
      // Загружаем статистику по категориям
      final categoryStatsJson = prefs.getString('career_category_stats');
      if (categoryStatsJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(categoryStatsJson);
        _categoryStats = decoded.map((k, v) => MapEntry(k, v as int));
      }
      
      // Загружаем текущую сессию
      final sessionJson = prefs.getString('career_current_session');
      if (sessionJson != null) {
        _currentSession = SwipeSession.fromJson(jsonDecode(sessionJson));
      }
      
      // Обновляем индекс на основе просмотренных карточек
      _updateIndexFromViewed();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved session: $e');
    }
  }

  void _updateIndexFromViewed() {
    // Находим первую непросмотренную карточку
    for (int i = 0; i < _deck.length; i++) {
      if (!_viewed.contains(_deck[i].id)) {
        _index = i;
        break;
      }
    }
  }

  Future<void> _persistSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Сохраняем основные списки
      await prefs.setStringList('career_liked', _liked);
      await prefs.setStringList('career_disliked', _disliked);
      await prefs.setStringList('career_superliked', _superliked);
      await prefs.setStringList('career_viewed', _viewed);
      
      // Сохраняем статистику
      await prefs.setInt('career_streak', _streakCount);
      await prefs.setInt('career_total_swipes', _totalSwipes);
      await prefs.setStringList('career_badges', _unlockedBadges);
      await prefs.setString('career_category_stats', jsonEncode(_categoryStats));
      
      // Сохраняем текущую сессию
      if (_currentSession != null) {
        await prefs.setString('career_current_session', jsonEncode(_currentSession!.toJson()));
      }
    } catch (e) {
      debugPrint('Error persisting session: $e');
    }
  }

  Future<void> swipe(SwipeAction action) async {
    final profession = current;
    if (profession == null) return;

    // Добавляем в просмотренные
    if (!_viewed.contains(profession.id)) {
      _viewed.add(profession.id);
    }

    // Обрабатываем действие
    switch (action) {
      case SwipeAction.like:
        if (!_liked.contains(profession.id)) {
          _liked.add(profession.id);
          _streakCount++;
          HapticFeedback.lightImpact();
        }
        break;
      case SwipeAction.dislike:
        if (!_disliked.contains(profession.id)) {
          _disliked.add(profession.id);
          _streakCount = 0; // Сбрасываем streak
          HapticFeedback.selectionClick();
        }
        break;
      case SwipeAction.superlike:
        if (!_superliked.contains(profession.id)) {
          _superliked.add(profession.id);
          _streakCount += 2; // Двойные очки за superlike
          HapticFeedback.mediumImpact();
        }
        break;
    }

    // Обновляем статистику
    _totalSwipes++;
    _updateCategoryStats(profession.category);
    _checkForNewBadges();
    
    // Обновляем сессию
    _updateCurrentSession(profession.id, action);
    
    // Сохраняем состояние
    await _persistSession();
    // Firestore: логируем действие
    await FirestoreService.instance.saveSwipeAction(
      professionId: profession.id,
      title: profession.title,
      category: profession.category,
      matchPercentage: profession.matchPercentage.round(),
      action: action.name,
    );
    // Firestore: обновляем streak
    await FirestoreService.instance.updateStreak(key: 'career_swipe_streak', value: _streakCount);
    
    // Переходим к следующей карточке
    _index = (_index + 1).clamp(0, _deck.length);
    
    // Отправляем аналитику (TODO: implement analytics service)
    _sendSwipeAnalytics(profession, action);
    
    notifyListeners();
  }

  void _updateCategoryStats(String category) {
    _categoryStats[category] = (_categoryStats[category] ?? 0) + 1;
  }

  void _checkForNewBadges() {
    final newBadges = <String>[];
    
    // Бейдж за первый свайп
    if (_totalSwipes == 1 && !_unlockedBadges.contains('first_swipe')) {
      newBadges.add('first_swipe');
    }
    
    // Бейдж за streak
    if (_streakCount >= 5 && !_unlockedBadges.contains('streak_5')) {
      newBadges.add('streak_5');
    }
    
    // Бейдж за количество лайков
    if (_liked.length >= 3 && !_unlockedBadges.contains('likes_3')) {
      newBadges.add('likes_3');
    }
    
    // Бейдж за разнообразие категорий
    if (_categoryStats.length >= 3 && !_unlockedBadges.contains('diverse_explorer')) {
      newBadges.add('diverse_explorer');
    }
    
    // Бейдж за завершение всех карточек
    if (_index >= _deck.length && !_unlockedBadges.contains('completionist')) {
      newBadges.add('completionist');
    }
    
    _unlockedBadges.addAll(newBadges);
    
    // Показываем уведомления о новых бейджах (TODO: implement badge notifications)
    for (final badge in newBadges) {
      debugPrint('🏆 New badge unlocked: $badge');
    }
  }

  void _updateCurrentSession(String professionId, SwipeAction action) {
    if (_currentSession == null) return;
    
    final timestamp = DateTime.now();
    
    switch (action) {
      case SwipeAction.like:
        _currentSession!.liked.add(professionId);
        break;
      case SwipeAction.dislike:
        _currentSession!.disliked.add(professionId);
        break;
      case SwipeAction.superlike:
        _currentSession!.superliked.add(professionId);
        break;
    }
    
    _currentSession!.viewed.add(professionId);
    _currentSession!.swipeTimestamps[professionId] = timestamp;
  }

  void _sendSwipeAnalytics(Profession profession, SwipeAction action) {
    // TODO: Implement analytics service
    final event = {
      'event': 'career_swipe',
      'profession_id': profession.id,
      'profession_title': profession.title,
      'profession_category': profession.category,
      'match_percentage': profession.matchPercentage,
      'action': action.name,
      'swipe_index': _index,
      'total_cards': _deck.length,
      'session_id': _currentSession?.userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    debugPrint('📊 Analytics: ${jsonEncode(event)}');
  }

  void rewind() {
    if (_index > 0) {
      _index--;
      
      // Убираем последнее действие из истории
      final lastProfession = _deck[_index];
      _liked.remove(lastProfession.id);
      _disliked.remove(lastProfession.id);
      _superliked.remove(lastProfession.id);
      _viewed.remove(lastProfession.id);
      
      if (_totalSwipes > 0) _totalSwipes--;
      
      HapticFeedback.lightImpact();
      _persistSession();
      notifyListeners();
    }
  }

  void reset() {
    _index = 0;
    _liked.clear();
    _disliked.clear();
    _superliked.clear();
    _viewed.clear();
    _streakCount = 0;
    _totalSwipes = 0;
    _categoryStats.clear();
    
    _shuffleDeck();
    _initSession();
    _persistSession();
    
    notifyListeners();
  }

  void skipToSummary() {
    _index = _deck.length;
    notifyListeners();
  }

  // Получение рекомендаций по развитию
  List<String> getPersonalizedAdvice() {
    final advice = <String>[];
    
    if (_liked.isEmpty && _superliked.isEmpty) {
      advice.add('🎯 Попробуйте лайкнуть несколько профессий, чтобы получить персональные рекомендации');
      return advice;
    }
    
    // Анализируем предпочтения по категориям
    final preferredCategories = <String>[];
    for (final profession in _originalDeck) {
      if (_liked.contains(profession.id) || _superliked.contains(profession.id)) {
        if (!preferredCategories.contains(profession.category)) {
          preferredCategories.add(profession.category);
        }
      }
    }
    
    // Генерируем персональные советы
    if (preferredCategories.contains('Technical')) {
      advice.add('💻 Пройдите бесплатный курс по программированию на Coursera или Udemy');
      advice.add('🔧 Создайте профиль на GitHub и начните делать pet-проекты');
    }
    
    if (preferredCategories.contains('Business')) {
      advice.add('📊 Изучите основы бизнес-аналитики и Excel/Google Sheets');
      advice.add('🤝 Найдите ментора в LinkedIn в сфере бизнеса');
    }
    
    if (preferredCategories.contains('Creative')) {
      advice.add('🎨 Создайте портфолио на Behance или Dribbble');
      advice.add('📝 Попробуйте фриланс на Upwork для набора опыта');
    }
    
    // Общие советы
    advice.add('📚 Читайте профильную литературу по выбранным направлениям');
    advice.add('🎓 Рассмотрите онлайн-курсы для развития soft skills');
    
    return advice.take(5).toList();
  }

  @override
  void dispose() {
    _persistSession();
    super.dispose();
  }
}
