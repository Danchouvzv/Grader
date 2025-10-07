import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Ensure user base document and initial collections exist (runs once)
  Future<void> ensureUserBootstrap() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _db.collection('users').doc(user.uid);
    final snap = await userRef.get();
    final bool alreadyInitialized = snap.exists && (snap.data()?['initialized'] == true);
    if (alreadyInitialized) {
      // Always keep lastActiveAt fresh
      await userRef.set({'lastActiveAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      return;
    }

    final fullName = user.displayName ?? (user.email?.split('@').first ?? 'User');
    final email = user.email ?? '';
    await createUserProfile(userId: user.uid, email: email, fullName: fullName);
    await userRef.set({'initialized': true}, SetOptions(merge: true));
  }

  // Create user profile and test data on first login
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    await _db.collection('users').doc(userId).set({
      'email': email,
      'fullName': fullName,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
      'totalIeltsSessions': 0,
      'totalCareerSwipes': 0,
      'currentStreak': 0,
      'bestIeltsScore': 0.0,
    }, SetOptions(merge: true));

    // Create test IELTS result to populate collections
    await _db.collection('users').doc(userId).collection('ielts_results').add({
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
      'createdAt': FieldValue.serverTimestamp(),
      'isTestData': true,
    });

    // Create test career swipe
    await _db.collection('users').doc(userId).collection('career_swipes').add({
      'professionId': 'test_profession_1',
      'title': 'Software Engineer',
      'category': 'Technology',
      'match': 85,
      'action': 'like',
      'timestamp': FieldValue.serverTimestamp(),
      'isTestData': true,
    });

    // Create test coach plan
    await _db.collection('users').doc(userId).collection('coach').doc('weekly_plan').set({
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
      'isTestData': true,
    });

    // Initialize stats
    await _db.collection('users').doc(userId).collection('stats').doc('streaks').set({
      'ielts_practice_streak': 0,
      'career_swipe_streak': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
    final uid = _uid;
    if (uid == null) return;
    
    // Save detailed IELTS result
    final doc = _db.collection('users').doc(uid).collection('ielts_results').doc();
    await doc.set({
      'overallBand': overallBand,
      'fluency': fluency,
      'lexical': lexical,
      'grammar': grammar,
      'pronunciation': pronunciation,
      'transcript': transcript,
      'enhanced': enhancedData,
      'tips': actionableTips,
      'createdAt': FieldValue.serverTimestamp(),
      'isTestData': false,
    }, SetOptions(merge: true));

    // Update user stats with transaction to keep bestIeltsScore as max
    final userRef = _db.collection('users').doc(uid);
    await _db.runTransaction((txn) async {
      final snap = await txn.get(userRef);
      final currentBest = (snap.data()?['bestIeltsScore'] as num?)?.toDouble() ?? 0.0;
      final newBest = overallBand > currentBest ? overallBand : currentBest;
      txn.set(userRef, {
        'totalIeltsSessions': FieldValue.increment(1),
        'bestIeltsScore': newBest,
        'lastActiveAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    // Update IELTS practice streak
    await _db.collection('users').doc(uid).collection('stats').doc('streaks').update({
      'ielts_practice_streak': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveSwipeAction({
    required String professionId,
    required String title,
    required String category,
    required int matchPercentage,
    required String action, // like | dislike | superlike
  }) async {
    final uid = _uid;
    if (uid == null) return;
    
    // Save detailed swipe action
    final col = _db.collection('users').doc(uid).collection('career_swipes');
    await col.add({
      'professionId': professionId,
      'title': title,
      'category': category,
      'match': matchPercentage,
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
      'isTestData': false,
    });

    // Update user stats
    await _db.collection('users').doc(uid).update({
      'totalCareerSwipes': FieldValue.increment(1),
      'lastActiveAt': FieldValue.serverTimestamp(),
    });

    // Update career swipe streak
    await _db.collection('users').doc(uid).collection('stats').doc('streaks').update({
      'career_swipe_streak': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
      return doc.data();
    }
    return null;
  }

  /// Fetch last 7 days IELTS weekly progress: sessions per day and average band
  Future<List<Map<String, dynamic>>> fetchWeeklyProgress() async {
    final uid = _uid;
    if (uid == null) return [];

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('ielts_results')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .orderBy('createdAt')
        .get();

    // Aggregate by day
    final Map<String, List<double>> dayToBands = {};
    final Map<String, int> dayToCount = {};

    for (final doc in snap.docs) {
      final data = doc.data();
      final ts = data['createdAt'] as Timestamp?;
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
  }

  String _dayKey(DateTime dt) {
    final d = DateTime(dt.year, dt.month, dt.day);
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}


