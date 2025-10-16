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
      debugPrint(
          '🔍 FirestoreSubscriptionService: Current time: ${DateTime.now()}');

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
        debugPrint('📅 Plan type: ${subscriptionData['planType']}');
        debugPrint('📅 User ID: ${subscriptionData['userId']}');
        debugPrint('📅 Amount: ${subscriptionData['amount']}');

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
              subscriptionEndAt: endDateTime,
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

      // 3. Kullanıcının user dokümanındaki abonelik bilgilerini kontrol et
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final subscriptionStatus = userData['subscriptionStatus'] as String?;
        final subscriptionEndAt = userData['subscriptionEndAt'] as Timestamp?;
        final trialEndAt = userData['trialEndAt'] as Timestamp?;
        final createdAt = userData['createdAt'] as Timestamp?;

        debugPrint(
            '👤 User data - subscriptionStatus: $subscriptionStatus, subscriptionEndAt: $subscriptionEndAt, trialEndAt: $trialEndAt, createdAt: $createdAt');

        // 3.1. ÖNCE: Aktif abonelik kontrolü (user dokümanından) - en yüksek öncelik
        if (subscriptionStatus == 'active' && subscriptionEndAt != null) {
          final subscriptionEndDateTime = subscriptionEndAt.toDate();
          debugPrint('🎯 User subscription end date: $subscriptionEndDateTime');

          if (now.isBefore(subscriptionEndDateTime)) {
            final remainingDays =
                subscriptionEndDateTime.difference(now).inDays;
            debugPrint(
                '✅ Active user subscription found - $remainingDays days remaining');
            return SubscriptionCheckResult(
              hasAccess: true,
              reason: 'Aktif abonelik - $remainingDays gün kaldı',
              remainingDays: remainingDays,
              subscriptionEndAt: subscriptionEndDateTime,
            );
          } else {
            debugPrint('❌ User subscription expired');
          }
        }

        // 3.3. ÜÇÜNCÜ: 30 günlük kayıt sonrası kullanım hakkı kontrolü (sadece abonelik yoksa)
        if (createdAt != null) {
          final registrationDate = createdAt.toDate();
          final thirtyDaysAfterRegistration =
              registrationDate.add(const Duration(days: 30));

          if (now.isBefore(thirtyDaysAfterRegistration)) {
            final remainingDays =
                thirtyDaysAfterRegistration.difference(now).inDays;
            debugPrint(
                '✅ 30-day usage right found - $remainingDays days remaining');
            return SubscriptionCheckResult(
              hasAccess: true,
              reason: '30 günlük kullanım hakkı - $remainingDays gün kaldı',
              remainingDays: remainingDays,
              trialEndAt: thirtyDaysAfterRegistration,
            );
          }
        }

        // 3.4. DÖRDÜNCÜ: Deneme süresi kontrolü (backward compatibility)
        if (trialEndAt != null) {
          final trialEndDateTime = trialEndAt.toDate();
          debugPrint('🎯 Trial end date: $trialEndDateTime');

          if (now.isBefore(trialEndDateTime)) {
            final remainingDays = trialEndDateTime.difference(now).inDays;
            debugPrint('✅ Active trial found - $remainingDays days remaining');
            return SubscriptionCheckResult(
              hasAccess: true,
              reason: 'Aktif deneme süresi - $remainingDays gün kaldı',
              remainingDays: remainingDays,
              trialEndAt: trialEndDateTime,
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

      // Firestore erişim hatası durumunda kullanıcı entity'sindeki verileri kullan
      if (e.toString().contains('permission-denied') ||
          e.toString().contains('Missing or insufficient permissions')) {
        debugPrint(
            '🔄 FirestoreSubscriptionService: Permission denied, trying to get user data from cache');

        // Kullanıcı verilerini al (cache'den veya local'den)
        try {
          final userDoc =
              await _firestore.collection('users').doc(userId).get();
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final subscriptionStatus =
                userData['subscriptionStatus'] as String?;
            final subscriptionEndAt =
                userData['subscriptionEndAt'] as Timestamp?;
            final createdAt = userData['createdAt'] as Timestamp?;

            debugPrint(
                '🔄 FirestoreSubscriptionService: Using user data from cache');

            // Şimdiki zamanı al
            final now = DateTime.now();

            // 30 günlük kullanım hakkı kontrolü
            if (createdAt != null) {
              final registrationDate = createdAt.toDate();
              final thirtyDaysAfterRegistration =
                  registrationDate.add(const Duration(days: 30));

              if (now.isBefore(thirtyDaysAfterRegistration)) {
                final remainingDays =
                    thirtyDaysAfterRegistration.difference(now).inDays;
                debugPrint(
                    '✅ FirestoreSubscriptionService: 30-day usage right found via fallback - $remainingDays days remaining');
                return SubscriptionCheckResult(
                  hasAccess: true,
                  reason:
                      '30 günlük kullanım hakkı (fallback) - $remainingDays gün kaldı',
                  remainingDays: remainingDays,
                  trialEndAt: thirtyDaysAfterRegistration,
                );
              }
            }

            // Aktif abonelik kontrolü
            if (subscriptionStatus == 'active' && subscriptionEndAt != null) {
              final subscriptionEndDateTime = subscriptionEndAt.toDate();
              if (now.isBefore(subscriptionEndDateTime)) {
                final remainingDays =
                    subscriptionEndDateTime.difference(now).inDays;
                debugPrint(
                    '✅ FirestoreSubscriptionService: Active subscription found via fallback - $remainingDays days remaining');
                return SubscriptionCheckResult(
                  hasAccess: true,
                  reason:
                      'Aktif abonelik (fallback) - $remainingDays gün kaldı',
                  remainingDays: remainingDays,
                  subscriptionEndAt: subscriptionEndDateTime,
                );
              }
            }
          }
        } catch (fallbackError) {
          debugPrint(
              '❌ FirestoreSubscriptionService: Fallback also failed: $fallbackError');
        }
      }

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
  final DateTime? trialEndAt;
  final DateTime? subscriptionEndAt;

  const SubscriptionCheckResult({
    required this.hasAccess,
    required this.reason,
    this.remainingDays,
    this.needsSubscription = false,
    this.isTrialExpired = false,
    this.isExpired = false,
    this.trialEndAt,
    this.subscriptionEndAt,
  });
}
