// ========== SUBSCRIPTION PROVIDERS ==========
// lib/features/subscription/presentation/providers/subscription_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../../core/services/subscription/subscription_sync_service.dart';
import '../../../../core/services/subscription/pricing_config.dart';
import '../../domain/entities/subscription_entity.dart' as sub_entity;
import '../../domain/entities/subscription_plan.dart' as sub;

/// Abonelik senkronizasyon servisi provider'ı
final subscriptionSyncServiceProvider =
    Provider<SubscriptionSyncService>((ref) {
  return SubscriptionSyncService();
});

/// Kullanıcının abonelik durumu provider'ı
final userSubscriptionProvider =
    FutureProvider.family<sub_entity.SubscriptionEntity?, String>(
        (ref, userId) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return sub_entity.SubscriptionEntity.fromJson(snapshot.docs.first.data());
  } catch (e) {
    return null;
  }
});

/// Kullanıcının tüm abonelikleri provider'ı
final userAllSubscriptionsProvider =
    FutureProvider.family<List<sub_entity.SubscriptionEntity>, String>(
        (ref, userId) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => sub_entity.SubscriptionEntity.fromJson(doc.data()))
        .toList();
  } catch (e) {
    return [];
  }
});

/// Abonelik planları provider'ı
final subscriptionPlansProvider = Provider<List<sub.SubscriptionPlan>>((ref) {
  return PricingConfig.getAllPlans();
});

/// Abonelik senkronizasyon durumu provider'ı
final subscriptionSyncStatusProvider =
    StateNotifierProvider<SubscriptionSyncNotifier, SubscriptionSyncState>(
        (ref) {
  return SubscriptionSyncNotifier(ref.read(subscriptionSyncServiceProvider));
});

/// Abonelik senkronizasyon notifier'ı
class SubscriptionSyncNotifier extends StateNotifier<SubscriptionSyncState> {
  final SubscriptionSyncService _syncService;

  SubscriptionSyncNotifier(this._syncService)
      : super(const SubscriptionSyncState());

  /// Kullanıcının aboneliklerini senkronize et
  Future<void> syncUserSubscriptions(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Cloud Function kullanarak senkronizasyon yap
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('syncSubscriptionStatus');
      final result = await callable.call({'userId': userId});

      if (result.data['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          lastSyncTime: DateTime.now(),
          message: result.data['message'],
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.data['message'] ?? 'Senkronizasyon başarısız',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Senkronizasyon hatası: $e',
      );
    }
  }

  /// Senkronizasyon durumunu temizle
  void clearStatus() {
    state = const SubscriptionSyncState();
  }
}

/// Abonelik senkronizasyon durumu
class SubscriptionSyncState {
  final bool isLoading;
  final String? error;
  final String? message;
  final DateTime? lastSyncTime;

  const SubscriptionSyncState({
    this.isLoading = false,
    this.error,
    this.message,
    this.lastSyncTime,
  });

  SubscriptionSyncState copyWith({
    bool? isLoading,
    String? error,
    String? message,
    DateTime? lastSyncTime,
  }) {
    return SubscriptionSyncState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      message: message ?? this.message,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Abonelik durumu kontrol provider'ı
final subscriptionStatusProvider =
    FutureProvider.family<sub_entity.SubscriptionStatus, String>(
        (ref, userId) async {
  try {
    final subscription =
        await ref.watch(userSubscriptionProvider(userId).future);

    if (subscription == null) {
      return sub_entity.SubscriptionStatus.none;
    }

    final now = DateTime.now();
    if (now.isAfter(subscription.endDate)) {
      return sub_entity.SubscriptionStatus.expired;
    }

    return subscription.status;
  } catch (e) {
    return sub_entity.SubscriptionStatus.none;
  }
});

/// Deneme süresi durumu provider'ı
final trialStatusProvider =
    FutureProvider.family<TrialStatus, String>((ref, userId) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final userDoc = await firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) return TrialStatus.none;

    final userData = userDoc.data()!;
    final trialEndAt = userData['trialEndAt'] as String?;

    if (trialEndAt == null) return TrialStatus.none;

    final trialEndDate = DateTime.parse(trialEndAt);
    final now = DateTime.now();

    if (now.isAfter(trialEndDate)) {
      return TrialStatus.expired;
    }

    return TrialStatus.active;
  } catch (e) {
    return TrialStatus.none;
  }
});

/// Deneme süresi durumu enum'u
enum TrialStatus {
  none,
  active,
  expired,
  converted,
}

/// Abonelik durumu enum'u
enum SubscriptionStatus {
  none,
  trial,
  active,
  expired,
  canceled,
  suspended,
}
