// ========== GLOBAL SUBSCRIPTION STATE PROVIDER ==========
// lib/core/providers/subscription_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../services/subscription/firestore_subscription_service.dart';

/// Global abonelik durumu state'i
class SubscriptionState {
  final SubscriptionCheckResult? subscriptionResult;
  final bool isLoading;
  final String? error;
  final DateTime? lastChecked;

  const SubscriptionState({
    this.subscriptionResult,
    this.isLoading = false,
    this.error,
    this.lastChecked,
  });

  SubscriptionState copyWith({
    SubscriptionCheckResult? subscriptionResult,
    bool? isLoading,
    String? error,
    DateTime? lastChecked,
  }) {
    return SubscriptionState(
      subscriptionResult: subscriptionResult ?? this.subscriptionResult,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  /// Abonelik durumu var mı?
  bool get hasSubscription => subscriptionResult?.hasAccess ?? false;

  /// Kalan gün sayısı
  int? get remainingDays => subscriptionResult?.remainingDays;

  /// Abonelik nedeni
  String? get reason => subscriptionResult?.reason;
}

/// Global abonelik durumu notifier'ı
class SubscriptionStateNotifier extends StateNotifier<SubscriptionState> {
  final FirestoreSubscriptionService _subscriptionService;

  SubscriptionStateNotifier(this._subscriptionService)
      : super(const SubscriptionState());

  /// Kullanıcının abonelik durumunu kontrol et ve cache'le
  Future<void> checkUserSubscription(String userId) async {
    try {
      debugPrint(
          '🔍 SubscriptionStateNotifier: Checking subscription for user: $userId');

      state = state.copyWith(isLoading: true, error: null);

      final result =
          await _subscriptionService.checkUserSubscriptionStatus(userId);

      debugPrint(
          '✅ SubscriptionStateNotifier: Subscription check completed: ${result.hasAccess}');

      state = state.copyWith(
        subscriptionResult: result,
        isLoading: false,
        lastChecked: DateTime.now(),
        error: null,
      );
    } catch (e) {
      debugPrint('❌ SubscriptionStateNotifier: Subscription check failed: $e');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cache'i temizle (çıkış yaparken)
  void clearCache() {
    debugPrint('🗑️ SubscriptionStateNotifier: Clearing subscription cache');
    state = const SubscriptionState();
  }

  /// Cache'i yenile (manuel olarak)
  Future<void> refreshSubscription(String userId) async {
    debugPrint('🔄 SubscriptionStateNotifier: Refreshing subscription cache');
    await checkUserSubscription(userId);
  }

  /// Otomatik abonelik durumu güncelleme (sayfa değişimlerinde)
  Future<void> autoRefreshSubscription(String userId) async {
    // Sadece cache yoksa veya 5 dakikadan eskiyse güncelle
    if (state.subscriptionResult == null || 
        state.lastChecked == null || 
        DateTime.now().difference(state.lastChecked!).inMinutes > 5) {
      debugPrint('🔄 SubscriptionStateNotifier: Auto-refreshing subscription cache');
      await checkUserSubscription(userId);
    }
  }
}

/// Global abonelik durumu provider'ı
final subscriptionStateProvider =
    StateNotifierProvider<SubscriptionStateNotifier, SubscriptionState>((ref) {
  return SubscriptionStateNotifier(FirestoreSubscriptionService());
});

/// Kullanıcının abonelik durumunu al (cache'lenmiş)
final userSubscriptionStatusProvider = Provider<bool>((ref) {
  final subscriptionState = ref.watch(subscriptionStateProvider);
  return subscriptionState.hasSubscription;
});

/// Kullanıcının kalan gün sayısını al (cache'lenmiş)
final userRemainingDaysProvider = Provider<int?>((ref) {
  final subscriptionState = ref.watch(subscriptionStateProvider);
  return subscriptionState.remainingDays;
});

/// Abonelik durumu loading state'i
final subscriptionLoadingProvider = Provider<bool>((ref) {
  final subscriptionState = ref.watch(subscriptionStateProvider);
  return subscriptionState.isLoading;
});
