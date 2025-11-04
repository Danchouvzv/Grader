import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionLimitService {
  static const String _keyDailySessions = 'daily_sessions';
  static const String _keyFirstSessionDate = 'first_session_date';
  static const String _keyIsPremium = 'is_premium';
  static const String _keyPremiumExpiry = 'premium_expiry';
  
  static const int _maxDailySessions = 2;
  static const int _freeTrialDays = 3;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if user can start a new session
  Future<bool> canStartSession() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // Check if user is premium
    if (await _isPremiumUser()) {
      return true;
    }

    // Check free trial limits
    return await _checkFreeTrialLimits();
  }

  /// Record a session start
  Future<void> recordSessionStart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    // Get current daily sessions
    final dailySessions = prefs.getInt('${_keyDailySessions}_$todayKey') ?? 0;
    
    // Increment session count
    await prefs.setInt('${_keyDailySessions}_$todayKey', dailySessions + 1);
    
    // Set first session date if not set
    if (!prefs.containsKey(_keyFirstSessionDate)) {
      await prefs.setString(_keyFirstSessionDate, todayKey);
    }

    // Update Firestore
    await _updateUserSessionData(user.uid, dailySessions + 1, todayKey);
  }

  /// Check if user is premium
  Future<bool> _isPremiumUser() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final prefs = await SharedPreferences.getInstance();
    
    // Check local cache first
    final isPremium = prefs.getBool(_keyIsPremium) ?? false;
    final premiumExpiry = prefs.getString(_keyPremiumExpiry);
    
    if (isPremium && premiumExpiry != null) {
      final expiryDate = DateTime.parse(premiumExpiry);
      if (expiryDate.isAfter(DateTime.now())) {
        return true;
      } else {
        // Premium expired, clear local cache
        await prefs.remove(_keyIsPremium);
        await prefs.remove(_keyPremiumExpiry);
      }
    }

    // Check Firestore
    try {
      final subscriptionRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscription');
      
      final doc = await subscriptionRef.doc('premium').get();

      if (doc.exists) {
        final data = doc.data()!;
        final expiryDate = (data['expiryDate'] as Timestamp).toDate();
        final isActive = data['isActive'] as bool? ?? false;
        
        if (isActive && expiryDate.isAfter(DateTime.now())) {
          // Cache the result
          await prefs.setBool(_keyIsPremium, true);
          await prefs.setString(_keyPremiumExpiry, expiryDate.toIso8601String());
          return true;
        }
      }
    } catch (e) {
      print('Error checking premium status: $e');
    }

    return false;
  }

  /// Check free trial limits
  Future<bool> _checkFreeTrialLimits() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    // Get first session date
    final firstSessionDate = prefs.getString(_keyFirstSessionDate);
    if (firstSessionDate == null) {
      return true; // First time user
    }

    // Check if trial period has expired
    final firstDate = DateTime.parse(firstSessionDate);
    final daysSinceFirst = today.difference(firstDate).inDays;
    
    if (daysSinceFirst >= _freeTrialDays) {
      return false; // Trial expired
    }

    // Check daily session limit
    final dailySessions = prefs.getInt('${_keyDailySessions}_$todayKey') ?? 0;
    return dailySessions < _maxDailySessions;
  }

  /// Get remaining sessions for today
  Future<int> getRemainingSessionsToday() async {
    if (await _isPremiumUser()) {
      return -1; // Unlimited
    }

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    final dailySessions = prefs.getInt('${_keyDailySessions}_$todayKey') ?? 0;
    return (_maxDailySessions - dailySessions).clamp(0, _maxDailySessions);
  }

  /// Get trial days remaining
  Future<int> getTrialDaysRemaining() async {
    if (await _isPremiumUser()) {
      return -1; // Premium user
    }

    final prefs = await SharedPreferences.getInstance();
    final firstSessionDate = prefs.getString(_keyFirstSessionDate);
    
    if (firstSessionDate == null) {
      return _freeTrialDays;
    }

    final firstDate = DateTime.parse(firstSessionDate);
    final daysSinceFirst = DateTime.now().difference(firstDate).inDays;
    return (_freeTrialDays - daysSinceFirst).clamp(0, _freeTrialDays);
  }

  /// Update user session data in Firestore
  Future<void> _updateUserSessionData(String userId, int sessionCount, String dateKey) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('session_limits')
          .doc(dateKey)
          .set({
        'sessionCount': sessionCount,
        'date': dateKey,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating session data: $e');
    }
  }

  /// Set user as premium (called when subscription is confirmed)
  Future<void> setPremiumUser(DateTime expiryDate) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    
    // Update local cache
    await prefs.setBool(_keyIsPremium, true);
    await prefs.setString(_keyPremiumExpiry, expiryDate.toIso8601String());

    // Update Firestore
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscription')
          .doc('premium')
          .set({
        'isActive': true,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error setting premium user: $e');
    }
  }

  /// Clear premium status
  Future<void> clearPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsPremium);
    await prefs.remove(_keyPremiumExpiry);
  }

  /// Get subscription status info
  Future<Map<String, dynamic>> getSubscriptionInfo() async {
    final isPremium = await _isPremiumUser();
    final remainingSessions = await getRemainingSessionsToday();
    final trialDaysRemaining = await getTrialDaysRemaining();

    return {
      'isPremium': isPremium,
      'remainingSessions': remainingSessions,
      'trialDaysRemaining': trialDaysRemaining,
      'maxDailySessions': _maxDailySessions,
      'freeTrialDays': _freeTrialDays,
    };
  }
}
