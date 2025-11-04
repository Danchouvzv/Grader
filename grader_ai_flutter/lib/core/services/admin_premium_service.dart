import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'subscription_limit_service.dart';

/// Admin service to manually activate premium for users
/// This is used when user purchases subscription via Telegram
class AdminPremiumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SubscriptionLimitService _subscriptionService = SubscriptionLimitService();

  /// Activate premium for a user by email
  /// Call this when user pays via Telegram
  Future<bool> activatePremiumByEmail(String email, {int months = 1}) async {
    try {
      // Find user by email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        print('❌ User not found: $email');
        return false;
      }

      final userId = userQuery.docs.first.id;
      return await activatePremiumByUserId(userId, months: months);
    } catch (e) {
      print('❌ Error activating premium by email: $e');
      return false;
    }
  }

  /// Activate premium for a user by UID
  Future<bool> activatePremiumByUserId(String userId, {int months = 1}) async {
    try {
      final expiryDate = DateTime.now().add(Duration(days: 30 * months));
      
      // Update Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('subscription')
          .doc('premium')
          .set({
        'isActive': true,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'updatedAt': FieldValue.serverTimestamp(),
        'activatedBy': 'admin', // Mark as manually activated
        'months': months,
      });

      print('✅ Premium activated for user: $userId, expires: $expiryDate');
      return true;
    } catch (e) {
      print('❌ Error activating premium: $e');
      return false;
    }
  }

  /// Get premium status for a user by email
  Future<Map<String, dynamic>?> getPremiumStatus(String email) async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return null;
      }

      final userId = userQuery.docs.first.id;
      
      final subDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('subscription')
          .doc('premium')
          .get();

      if (!subDoc.exists) {
        return {'hasPremium': false, 'userId': userId};
      }

      final data = subDoc.data()!;
      final expiryDate = (data['expiryDate'] as Timestamp).toDate();
      final isActive = data['isActive'] as bool? ?? false;

      return {
        'hasPremium': isActive && expiryDate.isAfter(DateTime.now()),
        'userId': userId,
        'expiryDate': expiryDate,
        'isActive': isActive,
      };
    } catch (e) {
      print('❌ Error getting premium status: $e');
      return null;
    }
  }
}
