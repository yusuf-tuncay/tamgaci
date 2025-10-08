// ========== SUBSCRIPTION SYNC SERVICE ==========
// lib/core/services/subscription/subscription_sync_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/subscription/domain/entities/subscription_entity.dart';
import '../../../features/subscription/domain/entities/subscription_plan.dart';
import '../payment/paytr_service.dart';
import '../payment/app_store_service.dart';
import '../payment/play_store_service.dart';

/// Multi-platform abonelik senkronizasyon servisi
class SubscriptionSyncService {
  static final SubscriptionSyncService _instance =
      SubscriptionSyncService._internal();
  factory SubscriptionSyncService() => _instance;
  SubscriptionSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PaytrService _paytrService = PaytrService();
  final AppStoreService _appStoreService = AppStoreService();
  final PlayStoreService _playStoreService = PlayStoreService();

  /// Kullanıcının tüm aboneliklerini senkronize et
  Future<SubscriptionSyncResult> syncUserSubscriptions(String userId) async {
    try {
      debugPrint('🔄 Syncing subscriptions for user: $userId');

      // Firestore'dan mevcut abonelikleri al
      final existingSubscriptions = await _getUserSubscriptions(userId);

      // Platform-specific abonelikleri kontrol et
      final platformSubscriptions = await _checkPlatformSubscriptions(userId);

      // Senkronizasyon sonuçları
      final syncResults = <SubscriptionSyncResult>[];

      // Her platform için abonelik durumunu kontrol et
      for (final platformSub in platformSubscriptions) {
        final syncResult = await _syncPlatformSubscription(
          userId: userId,
          platformSubscription: platformSub,
          existingSubscriptions: existingSubscriptions,
        );
        syncResults.add(syncResult);
      }

      // En aktif aboneliği belirle
      final activeSubscription = _determineActiveSubscription(syncResults);

      // Firestore'u güncelle
      if (activeSubscription != null) {
        await _updateUserSubscriptionStatus(userId, activeSubscription);
      }

      return SubscriptionSyncResult(
        success: true,
        activeSubscription: activeSubscription,
        message: 'Abonelikler başarıyla senkronize edildi',
      );
    } catch (e) {
      debugPrint('❌ Subscription sync error: $e');
      return SubscriptionSyncResult(
        success: false,
        error: 'Senkronizasyon hatası: $e',
      );
    }
  }

  /// Platform-specific abonelikleri kontrol et
  Future<List<PlatformSubscription>> _checkPlatformSubscriptions(
      String userId) async {
    final platformSubscriptions = <PlatformSubscription>[];

    try {
      // PayTR abonelikleri (Web/Windows)
      if (_isWebOrWindows()) {
        try {
          final paytrSubscriptions = await _checkPaytrSubscriptions(userId);
          platformSubscriptions.addAll(paytrSubscriptions);
        } catch (e) {
          debugPrint('PayTR subscription check error: $e');
        }
      }

      // App Store abonelikleri (iOS)
      if (_isIOS()) {
        try {
          final appStoreSubscriptions = await _checkAppStoreSubscriptions(userId);
          platformSubscriptions.addAll(appStoreSubscriptions);
        } catch (e) {
          debugPrint('App Store subscription check error: $e');
        }
      }

      // Play Store abonelikleri (Android)
      if (_isAndroid()) {
        try {
          final playStoreSubscriptions =
              await _checkPlayStoreSubscriptions(userId);
          platformSubscriptions.addAll(playStoreSubscriptions);
        } catch (e) {
          debugPrint('Play Store subscription check error: $e');
        }
      }
    } catch (e) {
      debugPrint('Platform detection error: $e');
      // Platform detection başarısız olursa sadece PayTR'yi dene
      try {
        final paytrSubscriptions = await _checkPaytrSubscriptions(userId);
        platformSubscriptions.addAll(paytrSubscriptions);
      } catch (e) {
        debugPrint('Fallback PayTR subscription check error: $e');
      }
    }

    return platformSubscriptions;
  }

  /// Web veya Windows platform kontrolü
  bool _isWebOrWindows() {
    try {
      return kIsWeb || Platform.isWindows;
    } catch (e) {
      // Platform detection başarısız olursa web olarak varsay
      return kIsWeb;
    }
  }

  /// iOS platform kontrolü
  bool _isIOS() {
    try {
      return Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  /// Android platform kontrolü
  bool _isAndroid() {
    try {
      return Platform.isAndroid;
    } catch (e) {
      return false;
    }
  }

  /// PayTR aboneliklerini kontrol et
  Future<List<PlatformSubscription>> _checkPaytrSubscriptions(
      String userId) async {
    // PayTR'den abonelik durumunu sorgula
    // Bu gerçek implementasyonda PayTR API'si ile yapılacak
    return [];
  }

  /// App Store aboneliklerini kontrol et
  Future<List<PlatformSubscription>> _checkAppStoreSubscriptions(
      String userId) async {
    final subscriptions = <PlatformSubscription>[];

    for (final planType in SubscriptionPlanType.values) {
      if (planType == SubscriptionPlanType.none) continue;

      final result = await _appStoreService.checkPurchaseStatus(
        'com.tamgaci.${planType.name}',
      );

      if (result.success && result.productId != null) {
        subscriptions.add(PlatformSubscription(
          platform: PaymentProvider.appStore,
          planType: planType,
          isActive: true,
          startDate: DateTime.now(), // Gerçek tarih App Store'dan gelecek
          endDate: DateTime.now().add(
              const Duration(days: 30)), // Gerçek tarih App Store'dan gelecek
          transactionId: result.productId!,
        ));
      }
    }

    return subscriptions;
  }

  /// Play Store aboneliklerini kontrol et
  Future<List<PlatformSubscription>> _checkPlayStoreSubscriptions(
      String userId) async {
    final subscriptions = <PlatformSubscription>[];

    for (final planType in SubscriptionPlanType.values) {
      if (planType == SubscriptionPlanType.none) continue;

      final result = await _playStoreService.checkPurchaseStatus(
        'com.tamgaci.${planType.name}',
      );

      if (result.success && result.productId != null) {
        subscriptions.add(PlatformSubscription(
          platform: PaymentProvider.playStore,
          planType: planType,
          isActive: true,
          startDate: DateTime.now(), // Gerçek tarih Play Store'dan gelecek
          endDate: DateTime.now().add(
              const Duration(days: 30)), // Gerçek tarih Play Store'dan gelecek
          transactionId: result.productId!,
        ));
      }
    }

    return subscriptions;
  }

  /// Platform aboneliğini senkronize et
  Future<SubscriptionSyncResult> _syncPlatformSubscription({
    required String userId,
    required PlatformSubscription platformSubscription,
    required List<SubscriptionEntity> existingSubscriptions,
  }) async {
    try {
      // Mevcut abonelik var mı kontrol et
      final existingSub = existingSubscriptions.firstWhere(
        (sub) =>
            sub.provider == platformSubscription.platform &&
            sub.planType == platformSubscription.planType,
        orElse: () => SubscriptionEntity(
          id: '',
          userId: userId,
          planType: SubscriptionPlanType.none,
          status: SubscriptionStatus.none,
          provider: PaymentProvider.manual,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          amount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (platformSubscription.isActive) {
        // Aktif abonelik - güncelle veya oluştur
        final updatedSub = existingSub.copyWith(
          status: SubscriptionStatus.active,
          startDate: platformSubscription.startDate,
          endDate: platformSubscription.endDate,
          updatedAt: DateTime.now(),
        );

        await _saveSubscription(updatedSub);

        return SubscriptionSyncResult(
          success: true,
          activeSubscription: updatedSub,
          message:
              '${platformSubscription.platform.name} aboneliği güncellendi',
        );
      } else {
        // Pasif abonelik - süresi dolmuş olarak işaretle
        final expiredSub = existingSub.copyWith(
          status: SubscriptionStatus.expired,
          updatedAt: DateTime.now(),
        );

        await _saveSubscription(expiredSub);

        return SubscriptionSyncResult(
          success: true,
          message:
              '${platformSubscription.platform.name} aboneliği süresi dolmuş',
        );
      }
    } catch (e) {
      debugPrint('Platform sync error: $e');
      return SubscriptionSyncResult(
        success: false,
        error: 'Platform senkronizasyon hatası: $e',
      );
    }
  }

  /// En aktif aboneliği belirle
  SubscriptionEntity? _determineActiveSubscription(
      List<SubscriptionSyncResult> results) {
    final activeSubscriptions = results
        .where((result) => result.activeSubscription != null)
        .map((result) => result.activeSubscription!)
        .toList();

    if (activeSubscriptions.isEmpty) return null;

    // En uzun süreli aboneliği seç
    return activeSubscriptions.reduce((a, b) {
      return a.endDate.isAfter(b.endDate) ? a : b;
    });
  }

  /// Kullanıcının aboneliklerini Firestore'dan al
  Future<List<SubscriptionEntity>> _getUserSubscriptions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => SubscriptionEntity.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Get user subscriptions error: $e');
      return [];
    }
  }

  /// Aboneliği Firestore'a kaydet
  Future<void> _saveSubscription(SubscriptionEntity subscription) async {
    try {
      await _firestore
          .collection('subscriptions')
          .doc(subscription.id)
          .set(subscription.toJson());
    } catch (e) {
      debugPrint('Save subscription error: $e');
      rethrow;
    }
  }

  /// Kullanıcının abonelik durumunu güncelle
  Future<void> _updateUserSubscriptionStatus(
      String userId, SubscriptionEntity subscription) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'subscriptionStatus': subscription.status.name,
        'subscriptionPlan': subscription.planType.name,
        'subscriptionEndAt': subscription.endDate.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Update user subscription status error: $e');
      rethrow;
    }
  }
}

/// Platform aboneliği
class PlatformSubscription {
  final PaymentProvider platform;
  final SubscriptionPlanType planType;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final String transactionId;

  const PlatformSubscription({
    required this.platform,
    required this.planType,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.transactionId,
  });
}

/// Abonelik senkronizasyon sonucu
class SubscriptionSyncResult {
  final bool success;
  final SubscriptionEntity? activeSubscription;
  final String? message;
  final String? error;

  const SubscriptionSyncResult({
    required this.success,
    this.activeSubscription,
    this.message,
    this.error,
  });
}
