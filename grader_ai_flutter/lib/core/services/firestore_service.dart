import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../constants/firestore_constants.dart';
import '../models/swipe_action.dart';

class FirestoreService {
  FirestoreService._() 
      : _db = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;
  static final FirestoreService instance = FirestoreService._();
  
  // For testing
  @visibleForTesting
  FirestoreService.test({
    required FirebaseFirestore db,
    required FirebaseAuth auth,
  }) : _db = db, _auth = auth;

  late final FirebaseFirestore _db;
  late final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  /// Ensure user base document and initial collections exist (runs once)
  Future<void> ensureUserBootstrap() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userRef = _db.collection(FirestoreConstants.usersCollection).doc(user.uid);
      final snap = await userRef.get();
      final bool alreadyInitialized = snap.exists && (snap.data()?['initialized'] == true);
      
      if (alreadyInitialized) {
        // Always keep lastActiveAt fresh
        await userRef.set({
          FirestoreConstants.lastActiveAtField: FieldValue.serverTimestamp()
        }, SetOptions(merge: true));
        
        // Ensure subscription collection exists (migration for existing users)
        await _ensureSubscriptionCollection(user.uid);
        return;
      }

      final fullName = user.displayName ?? (user.email?.split('@').first ?? 'User');
      final email = user.email ?? '';
      await createUserProfile(userId: user.uid, email: email, fullName: fullName);
      await userRef.set({'initialized': true}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error in ensureUserBootstrap: $e');
      rethrow;
    }
  }

  /// Ensure subscription collection exists (for existing users migration)
  Future<void> _ensureSubscriptionCollection(String userId) async {
    try {
      final subscriptionRef = _db
          .collection('users')
          .doc(userId)
          .collection('subscription')
          .doc('premium');
      
      final exists = await subscriptionRef.get();
      
      if (!exists.exists) {
        await subscriptionRef.set({
          'isActive': false,
          'expiryDate': Timestamp.fromDate(DateTime(1970, 1, 1)),
          'updatedAt': FieldValue.serverTimestamp(),
          'months': 0,
        });
        debugPrint('✅ Created subscription collection for user: $userId');
      }
    } catch (e) {
      debugPrint('❌ Error ensuring subscription collection: $e');
    }
  }

  // Create user profile and test data on first login
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    try {
      await _db.collection(FirestoreConstants.usersCollection).doc(userId).set({
        'email': email,
        'fullName': fullName,
        FirestoreConstants.createdAtField: FieldValue.serverTimestamp(),
        FirestoreConstants.lastActiveAtField: FieldValue.serverTimestamp(),
        FirestoreConstants.totalIeltsSessionsField: 0,
        'totalCareerSwipes': 0,
        FirestoreConstants.currentStreakField: 0,
        FirestoreConstants.bestIeltsScoreField: 0.0,
      }, SetOptions(merge: true));

      // Create test IELTS result to populate collections
      await _db.collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection(FirestoreConstants.ieltsResultsCollection)
          .add({
        'overallBand': 6.5,
        'fluency': 6.0,
        'lexical': 7.0,
        'grammar': 6.5,
        'pronunciation': 6.5,
        'transcript': 'This is a sample IELTS speaking response for testing purposes.',
        'enhanced': {
          'improved_transcript': 'This represents an exemplary IELTS speaking response designed for comprehensive testing and evaluation purposes.',
          'advanced_phrases': ['exemplary', 'comprehensive testing', 'evaluation purposes'],
          'improvement_rationale': 'Enhanced vocabulary and more sophisticated sentence structures.',
        },
        'tips': {
          'overused_words': ['this', 'is', 'a'],
          'c1_synonyms': ['exemplary', 'comprehensive', 'sophisticated'],
          'top_priorities': ['Improve fluency', 'Use advanced vocabulary', 'Better pronunciation'],
        },
        FirestoreConstants.createdAtField: FieldValue.serverTimestamp(),
        FirestoreConstants.isTestDataField: true,
      });

      // Create test career swipe
      await _db.collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection(FirestoreConstants.careerSwipesCollection)
          .add({
        'professionId': 'test_profession_1',
        'title': 'Software Engineer',
        'category': 'Technology',
        'match': 85,
        'action': SwipeAction.like.value,
        'timestamp': FieldValue.serverTimestamp(),
        FirestoreConstants.isTestDataField: true,
      });

      // Create test coach plan
      await _db.collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection(FirestoreConstants.coachCollection)
          .doc(FirestoreConstants.weeklyPlanDoc)
          .set({
        'plan': {
          'plan_summary': 'A personalized 7-day IELTS Speaking plan focusing on fluency and vocabulary.',
          'daily_plans': [
            {
              'day': 1,
              'mission': 'Practice Part 1 questions about your hometown',
              'key_phrases': ['bustling metropolis', 'quaint neighborhood', 'vibrant community'],
              'checkpoints': ['Record 3-minute response', 'Use 5 advanced phrases', 'Focus on fluency'],
            },
            {
              'day': 2,
              'mission': 'Work on Part 2 describing a memorable experience',
              'key_phrases': ['unforgettable moment', 'profound impact', 'life-changing event'],
              'checkpoints': ['2-minute monologue', 'Avoid filler words', 'Use past tense correctly'],
            },
          ],
        },
        'updatedAt': FieldValue.serverTimestamp(),
        FirestoreConstants.isTestDataField: true,
      });

      // Initialize stats
      await _db.collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection(FirestoreConstants.statsCollection)
          .doc(FirestoreConstants.streaksDoc)
          .set({
        'ielts_practice_streak': 0,
        'career_swipe_streak': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Initialize subscription collection (for future premium activation)
      await _db.collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection('subscription')
          .doc('premium')
          .set({
        'isActive': false,
        'expiryDate': Timestamp.fromDate(DateTime(1970, 1, 1)), // Default expired
        'updatedAt': FieldValue.serverTimestamp(),
        'months': 0,
      });
    } catch (e) {
      debugPrint('❌ Error in createUserProfile: $e');
      rethrow;
    }
  }

  Future<void> saveIeltsResult({
    required double overallBand,
    required double fluency,
    required double lexical,
    required double grammar,
    required double pronunciation,
    required String transcript,
    Map<String, dynamic>? enhancedData,
    Map<String, dynamic>? actionableTips,
  }) async {
    try {
      // Validate input data
      _validateBandScore(overallBand, 'overallBand');
      _validateBandScore(fluency, 'fluency');
      _validateBandScore(lexical, 'lexical');
      _validateBandScore(grammar, 'grammar');
      _validateBandScore(pronunciation, 'pronunciation');
      
      if (transcript.trim().isEmpty) {
        throw ArgumentError('Transcript cannot be empty');
      }

      final uid = _uid;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      // Use batch to ensure atomicity
      final batch = _db.batch();
      
      // Save detailed IELTS result
      final resultRef = _db.collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.ieltsResultsCollection)
          .doc();
      
      batch.set(resultRef, {
        'overallBand': overallBand,
        'fluency': fluency,
        'lexical': lexical,
        'grammar': grammar,
        'pronunciation': pronunciation,
        'transcript': transcript,
        'enhanced': enhancedData,
        'tips': actionableTips,
        FirestoreConstants.createdAtField: FieldValue.serverTimestamp(),
        FirestoreConstants.isTestDataField: false,
      });

      // Update user stats with transaction for bestIeltsScore
      final userRef = _db.collection(FirestoreConstants.usersCollection).doc(uid);
      
      // First commit the batch
      await batch.commit();
      
      // Then update stats in transaction
      await _db.runTransaction((txn) async {
        final snap = await txn.get(userRef);
        final currentBest = (snap.data()?[FirestoreConstants.bestIeltsScoreField] as num?)?.toDouble() ?? 0.0;
        final newBest = overallBand > currentBest ? overallBand : currentBest;
        
        txn.set(userRef, {
          FirestoreConstants.totalIeltsSessionsField: FieldValue.increment(1),
          FirestoreConstants.bestIeltsScoreField: newBest,
          FirestoreConstants.lastActiveAtField: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      // Update IELTS practice streak (separate operation)
      await _db.collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.statsCollection)
          .doc(FirestoreConstants.streaksDoc)
          .set({
        'ielts_practice_streak': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
    } catch (e) {
      debugPrint('❌ Error in saveIeltsResult: $e');
      rethrow;
    }
  }

  void _validateBandScore(double score, String fieldName) {
    if (score < FirestoreConstants.minBandScore || score > FirestoreConstants.maxBandScore) {
      throw ArgumentError('$fieldName must be between ${FirestoreConstants.minBandScore} and ${FirestoreConstants.maxBandScore}, got $score');
    }
  }

  Future<void> saveSwipeAction({
    required String professionId,
    required String title,
    required String category,
    required int matchPercentage,
    required SwipeAction action,
  }) async {
    try {
      // Validate input data
      if (professionId.trim().isEmpty) {
        throw ArgumentError('ProfessionId cannot be empty');
      }
      if (title.trim().isEmpty) {
        throw ArgumentError('Title cannot be empty');
      }
      if (matchPercentage < FirestoreConstants.minMatchPercentage || 
          matchPercentage > FirestoreConstants.maxMatchPercentage) {
        throw ArgumentError('Match percentage must be between ${FirestoreConstants.minMatchPercentage} and ${FirestoreConstants.maxMatchPercentage}');
      }

      final uid = _uid;
      if (uid == null) {
        throw Exception('User not authenticated');
      }
      
      // Save detailed swipe action
      final col = _db.collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.careerSwipesCollection);
      
      await col.add({
        'professionId': professionId,
        'title': title,
        'category': category,
        'match': matchPercentage,
        'action': action.value,
        'timestamp': FieldValue.serverTimestamp(),
        FirestoreConstants.isTestDataField: false,
      });

      // Update user stats
      await _db.collection(FirestoreConstants.usersCollection).doc(uid).update({
        'totalCareerSwipes': FieldValue.increment(1),
        FirestoreConstants.lastActiveAtField: FieldValue.serverTimestamp(),
      });

      // Update career swipe streak
      await _db.collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.statsCollection)
          .doc(FirestoreConstants.streaksDoc)
          .set({
        'career_swipe_streak': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
    } catch (e) {
      debugPrint('❌ Error in saveSwipeAction: $e');
      rethrow;
    }
  }

  Future<void> updateStreak({required String key, required int value}) async {
    final uid = _uid;
    if (uid == null) return;
    final statsRef = _db.collection('users').doc(uid).collection('stats').doc('streaks');
    await statsRef.set({key: value, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<void> saveCoachPlan({
    required Map<String, dynamic> plan,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    
    // Save detailed coach plan
    await _db.collection('users').doc(uid).collection('coach').doc('weekly_plan').set({
      'plan': plan,
      'updatedAt': FieldValue.serverTimestamp(),
      'isTestData': false,
    }, SetOptions(merge: true));

    // Update user stats
    await _db.collection('users').doc(uid).update({
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> fetchCoachPlan() async {
    final uid = _uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).collection('coach').doc('weekly_plan').get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['plan'] is Map<String, dynamic>) {
        return data['plan'] as Map<String, dynamic>;
      }
    }
    return null;
  }

  Future<void> updateUserProfile({
    required String fullName,
    String? avatarPath,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    
    final userRef = _db.collection('users').doc(uid);
    final updateData = <String, dynamic>{
      'fullName': fullName,
      'lastActiveAt': FieldValue.serverTimestamp(),
    };
    
    if (avatarPath != null) {
      updateData['avatarPath'] = avatarPath;
    }
    
    await userRef.update(updateData);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = _uid;
    if (uid == null) return null;
    
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      
      // Calculate real stats excluding test data
      final realStats = await _calculateRealUserStats(uid);
      
      return {
        ...data,
        'totalIeltsSessions': realStats['totalSessions'],
        'currentStreak': realStats['currentStreak'],
        'bestIeltsScore': realStats['bestScore'],
      };
    }
    return null;
  }

  Future<Map<String, dynamic>> _calculateRealUserStats(String uid) async {
    // Get real IELTS results (excluding test data)
    final ieltsSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('ielts_results')
        .where('isTestData', isEqualTo: false)
        .get();

    final totalSessions = ieltsSnap.docs.length;
    final bestScore = ieltsSnap.docs.isEmpty 
        ? 0.0 
        : ieltsSnap.docs
            .map((doc) => (doc.data()['overallBand'] as num?)?.toDouble() ?? 0.0)
            .reduce((a, b) => a > b ? a : b);

    // Calculate current streak (simplified - you might want to implement proper streak logic)
    final currentStreak = await _calculateCurrentStreak(uid);

    return {
      'totalSessions': totalSessions,
      'bestScore': bestScore,
      'currentStreak': currentStreak,
    };
  }

  Future<int> _calculateCurrentStreak(String uid) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(FirestoreConstants.streakCheckDays);
      
      // Get all results for the last 30 days in one query
      final snap = await _db
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.ieltsResultsCollection)
          .where(FirestoreConstants.createdAtField, isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where(FirestoreConstants.isTestDataField, isEqualTo: false)
          .orderBy(FirestoreConstants.createdAtField, descending: true)
          .get();

      if (snap.docs.isEmpty) return 0;

      // Group results by day
      final Map<String, List<DocumentSnapshot>> resultsByDay = {};
      for (final doc in snap.docs) {
        final timestamp = doc.data()[FirestoreConstants.createdAtField] as Timestamp?;
        if (timestamp == null) continue;
        
        final date = timestamp.toDate();
        final dayKey = _dayKey(date);
        (resultsByDay[dayKey] ??= []).add(doc);
      }

      // Calculate streak with grace period
      int streak = 0;
      final today = DateTime(now.year, now.month, now.day);
      
      for (int i = 0; i < FirestoreConstants.streakCheckDays.inDays; i++) {
        final day = today.subtract(Duration(days: i));
        final dayKey = _dayKey(day);
        
        if (resultsByDay.containsKey(dayKey)) {
          streak++;
        } else {
          // Check grace period - if this is yesterday and we have activity today, continue
          if (i == 1 && resultsByDay.containsKey(_dayKey(today))) {
            streak++;
            continue;
          }
          break; // Streak broken
        }
      }
      
      return streak;
    } catch (e) {
      debugPrint('❌ Error in _calculateCurrentStreak: $e');
      return 0; // Return 0 on error rather than crashing
    }
  }

  /// Fetch last 7 days IELTS weekly progress: sessions per day and average band
  Future<List<Map<String, dynamic>>> fetchWeeklyProgress() async {
    try {
      final uid = _uid;
      if (uid == null) return [];

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day).subtract(FirestoreConstants.weeklyProgressDays);

      final snap = await _db
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.ieltsResultsCollection)
          .where(FirestoreConstants.createdAtField, isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where(FirestoreConstants.isTestDataField, isEqualTo: false) // Exclude test data
          .orderBy(FirestoreConstants.createdAtField)
          .get();

      // Aggregate by day
      final Map<String, List<double>> dayToBands = {};
      final Map<String, int> dayToCount = {};

      for (final doc in snap.docs) {
        final data = doc.data();
        final ts = data[FirestoreConstants.createdAtField] as Timestamp?;
        final bandNum = (data['overallBand'] as num?)?.toDouble();
        
        if (ts == null) continue;
        final dt = ts.toDate();
        final key = _dayKey(dt);
        dayToCount[key] = (dayToCount[key] ?? 0) + 1;
        if (bandNum != null) {
          (dayToBands[key] ??= []).add(bandNum);
        }
      }

      // Build 7-day series from start to today
      final List<Map<String, dynamic>> result = [];
      for (int i = 0; i < 7; i++) {
        final day = start.add(Duration(days: i));
        final key = _dayKey(day);
        final count = dayToCount[key] ?? 0;
        final bands = dayToBands[key] ?? const <double>[];
        final avg = bands.isEmpty ? 0.0 : (bands.reduce((a, b) => a + b) / bands.length);
        result.add({
          'date': key,
          'sessions_count': count,
          'average_band': avg,
        });
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error in fetchWeeklyProgress: $e');
      return []; // Return empty list on error rather than crashing
    }
  }

  Future<List<Map<String, dynamic>>> getRecentIeltsResults({int limit = FirestoreConstants.defaultRecentResultsLimit}) async {
    try {
      final uid = _uid;
      if (uid == null) return [];

      // Validate limit
      final validatedLimit = limit.clamp(1, FirestoreConstants.maxRecentResultsLimit);

      final snap = await _db
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.ieltsResultsCollection)
          .where(FirestoreConstants.isTestDataField, isEqualTo: false) // Exclude test data
          .orderBy(FirestoreConstants.createdAtField, descending: true)
          .limit(validatedLimit)
          .get();

      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('❌ Error in getRecentIeltsResults: $e');
      return []; // Return empty list on error rather than crashing
    }
  }

  String _dayKey(DateTime dt) {
    final d = DateTime(dt.year, dt.month, dt.day);
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}


