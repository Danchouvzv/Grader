import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '../models/session_record.dart';
import '../models/achievement.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'grader_ai.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // User Profile table
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        avatar_path TEXT,
        target_band REAL DEFAULT 7.0,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        total_sessions INTEGER DEFAULT 0,
        total_practice_time INTEGER DEFAULT 0,
        average_band REAL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Session Records table
    await db.execute('''
      CREATE TABLE session_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        session_type TEXT NOT NULL,
        part_type TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        overall_band REAL NOT NULL,
        fluency_band REAL NOT NULL,
        lexical_band REAL NOT NULL,
        grammar_band REAL NOT NULL,
        pronunciation_band REAL NOT NULL,
        transcript TEXT,
        feedback TEXT,
        audio_path TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profile (id)
      )
    ''');

    // Achievements table
    await db.execute('''
      CREATE TABLE achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        achievement_type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        unlocked_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profile (id)
      )
    ''');

    // Daily Stats table
    await db.execute('''
      CREATE TABLE daily_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        sessions_count INTEGER DEFAULT 0,
        practice_time INTEGER DEFAULT 0,
        average_band REAL DEFAULT 0.0,
        FOREIGN KEY (user_id) REFERENCES user_profile (id),
        UNIQUE(user_id, date)
      )
    ''');
  }

  // User Profile methods
  Future<int> insertUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.insert('user_profile', profile.toMap());
  }

  Future<UserProfile?> getUserProfile(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<UserProfile?> getFirstUserProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profile',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    final db = await database;
    await db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // Session Records methods
  Future<int> insertSessionRecord(SessionRecord record) async {
    final db = await database;
    return await db.insert('session_records', record.toMap());
  }

  Future<List<SessionRecord>> getSessionRecords(int userId, {int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'session_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return SessionRecord.fromMap(maps[i]);
    });
  }

  Future<List<SessionRecord>> getTodaysSessions(int userId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'session_records',
      where: 'user_id = ? AND date(created_at) = ?',
      whereArgs: [userId, today],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return SessionRecord.fromMap(maps[i]);
    });
  }

  // Achievements methods
  Future<int> insertAchievement(Achievement achievement) async {
    final db = await database;
    return await db.insert('achievements', achievement.toMap());
  }

  Future<List<Achievement>> getAchievements(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'unlocked_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Achievement.fromMap(maps[i]);
    });
  }

  // Stats methods
  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final db = await database;
    
    // Get total sessions
    final totalSessions = await db.rawQuery('''
      SELECT COUNT(*) as count FROM session_records WHERE user_id = ?
    ''', [userId]);

    // Get total practice time
    final totalTime = await db.rawQuery('''
      SELECT SUM(duration_seconds) as total FROM session_records WHERE user_id = ?
    ''', [userId]);

    // Get average band
    final avgBand = await db.rawQuery('''
      SELECT AVG(overall_band) as average FROM session_records WHERE user_id = ?
    ''', [userId]);

    // Get best band
    final bestBand = await db.rawQuery('''
      SELECT MAX(overall_band) as best FROM session_records WHERE user_id = ?
    ''', [userId]);

    // Get streak data
    final profile = await getUserProfile(userId);

    return {
      'totalSessions': totalSessions.first['count'] ?? 0,
      'totalPracticeTime': totalTime.first['total'] ?? 0,
      'averageBand': (avgBand.first['average'] as double?) ?? 0.0,
      'bestBand': (bestBand.first['best'] as double?) ?? 0.0,
      'currentStreak': profile?.currentStreak ?? 0,
      'longestStreak': profile?.longestStreak ?? 0,
    };
  }

  // Update daily stats
  Future<void> updateDailyStats(int userId, SessionRecord record) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await db.rawInsert('''
      INSERT OR REPLACE INTO daily_stats (user_id, date, sessions_count, practice_time, average_band)
      VALUES (?, ?, 
        COALESCE((SELECT sessions_count FROM daily_stats WHERE user_id = ? AND date = ?), 0) + 1,
        COALESCE((SELECT practice_time FROM daily_stats WHERE user_id = ? AND date = ?), 0) + ?,
        (SELECT AVG(overall_band) FROM session_records WHERE user_id = ? AND date(created_at) = ?)
      )
    ''', [userId, today, userId, today, userId, today, record.durationSeconds, userId, today]);
  }

  // Get weekly progress
  Future<List<Map<String, dynamic>>> getWeeklyProgress(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT date, sessions_count, practice_time, average_band
      FROM daily_stats 
      WHERE user_id = ? AND date >= date('now', '-7 days')
      ORDER BY date ASC
    ''', [userId]);

    return result;
  }

  // Check and update streaks
  Future<void> updateStreaks(int userId) async {
    final db = await database;
    final profile = await getUserProfile(userId);
    if (profile == null) return;

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Check if user practiced today
    final todaySessions = await getTodaysSessions(userId);
    final yesterdaySessions = await db.query(
      'session_records',
      where: 'user_id = ? AND date(created_at) = ?',
      whereArgs: [userId, yesterday.toIso8601String().split('T')[0]],
    );

    int newStreak = profile.currentStreak;
    
    if (todaySessions.isNotEmpty) {
      // User practiced today
      if (yesterdaySessions.isNotEmpty || profile.currentStreak == 0) {
        // Continue or start streak
        newStreak = profile.currentStreak + 1;
      }
    } else {
      // User didn't practice today, reset streak
      newStreak = 0;
    }

    final newLongestStreak = newStreak > profile.longestStreak ? newStreak : profile.longestStreak;

    await updateUserProfile(profile.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      totalSessions: profile.totalSessions + (todaySessions.length > profile.totalSessions ? 1 : 0),
    ));
  }
}
