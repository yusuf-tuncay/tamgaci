import 'package:flutter/foundation.dart';

// ========== FIRESTORE SUBSCRIPTION SERVICE ==========
// lib/core/services/subscription/firestore_subscription_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore'dan subscription verilerini alan servis
class FirestoreSubscriptionService {
  static final FirestoreSubscriptionService _instance =
      FirestoreSubscriptionService._internal();
  factory FirestoreSubscriptionService() => _instance;
  FirestoreSubscriptionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Kullanıcının aktif aboneliklerini kontrol et
  Future<SubscriptionCheckResult> checkUserSubscriptionStatus(
      String userId) async {
    try {
      debugPrint(
          '🔍 FirestoreSubscriptionService: Checking subscription for user: $userId');

      final now = DateTime.now();

      // 1. Kullanıcının subscriptions koleksiyonundaki aboneliklerini al
      final subscriptionsSnapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .get();

      debugPrint('📊 Found ${subscriptionsSnapshot.docs.length} subscriptions');

      // 2. En son aboneliği kontrol et (createdAt'e göre sırala)
      if (subscriptionsSnapshot.docs.isNotEmpty) {
        // En son oluşturulan aboneliği bul
        final sortedDocs = subscriptionsSnapshot.docs.toList()
          ..sort((a, b) {
            final aCreatedAt = a.data()['createdAt'] as Timestamp?;
            final bCreatedAt = b.data()['createdAt'] as Timestamp?;
            if (aCreatedAt == null || bCreatedAt == null) return 0;
            return bCreatedAt.compareTo(aCreatedAt); // Descending order
          });
        final latestSubscription = sortedDocs.first;
        final subscriptionData = latestSubscription.data();

        debugPrint('📋 Latest subscription: ${subscriptionData['status']}');
        debugPrint('📅 End date: ${subscriptionData['endDate']}');

        final status = subscriptionData['status'] as String?;
        final endDate = subscriptionData['endDate'] as Timestamp?;

        if (status == 'active' && endDate != null) {
          final endDateTime = endDate.toDate();
          debugPrint('⏰ Subscription end date: $endDateTime');
          debugPrint('⏰ Current time: $now');

          if (now.isBefore(endDateTime)) {
            debugPrint('✅ Active subscription found with remaining time');
            return SubscriptionCheckResult(
              hasAccess: true,
              reason: 'Aktif abonelik - Firestore kontrolü',
              remainingDays: endDateTime.difference(now).inDays,
            );
          } else {
            debugPrint('❌ Subscription expired');
            // Aboneliği expired olarak işaretle
            await latestSubscription.reference.update({
              'status': 'expired',
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      // 3. Kullanıcının trial durumunu kontrol et
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final trialEndAt = userData['trialEndAt'] as Timestamp?;
        debugPrint(
            '👤 User data - subscriptionStatus: ${userData['subscriptionStatus']}, trialEndAt: $trialEndAt, subscriptionEndAt: ${userData['subscriptionEndAt']}');

        if (trialEndAt != null) {
          final trialEndDateTime = trialEndAt.toDate();
          debugPrint('🎯 Trial end date: $trialEndDateTime');

          if (now.isBefore(trialEndDateTime)) {
            debugPrint('✅ Active trial found');
            return SubscriptionCheckResult(
              hasAccess: true,
              reason: 'Aktif deneme süresi - Firestore kontrolü',
              remainingDays: trialEndDateTime.difference(now).inDays,
            );
          }
        }
      }

      debugPrint('❌ No active subscription or trial found');
      return const SubscriptionCheckResult(
        hasAccess: false,
        reason: 'Abonelik bulunamadı - Firestore kontrolü',
        needsSubscription: true,
      );
    } catch (e) {
      debugPrint('❌ FirestoreSubscriptionService error: $e');
      return SubscriptionCheckResult(
        hasAccess: false,
        reason: 'Abonelik kontrolü başarısız: $e',
        needsSubscription: true,
      );
    }
  }
}

/// Subscription kontrol sonucu
class SubscriptionCheckResult {
  final bool hasAccess;
  final String reason;
  final int? remainingDays;
  final bool needsSubscription;
  final bool isTrialExpired;
  final bool isExpired;

  const SubscriptionCheckResult({
    required this.hasAccess,
    required this.reason,
    this.remainingDays,
    this.needsSubscription = false,
    this.isTrialExpired = false,
    this.isExpired = false,
  });
}
