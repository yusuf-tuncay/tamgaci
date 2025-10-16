// ========== GLOBAL SUBSCRIPTION STATE PROVIDER ==========
// lib/core/providers/subscription_state_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Cache kontrolü - 10 dakika içinde tekrar kontrol etme (log yoğunluğunu azalt)
      if (state.lastChecked != null) {
        final timeSinceLastCheck = DateTime.now().difference(state.lastChecked!);
        if (timeSinceLastCheck.inMinutes < 10) {
          // Cache hala geçerli, tekrar kontrol etme
          return;
        }
      }

      state = state.copyWith(isLoading: true, error: null);

      final result =
          await _subscriptionService.checkUserSubscriptionStatus(userId);

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

  /// Cache'i yenile (sadece real-time listener tetiklenmediğinde)
  Future<void> refreshSubscription(String userId) async {
    debugPrint('🔄 SubscriptionStateNotifier: Manual refresh requested');
    await checkUserSubscription(userId);
  }

  /// Otomatik abonelik durumu güncelleme (sadece ilk yüklemede)
  Future<void> autoRefreshSubscription(String userId) async {
    // Sadece ilk kez yüklendiğinde veya cache süresi dolmuşsa kontrol et
    if (state.subscriptionResult == null || 
        (state.lastChecked != null && 
         DateTime.now().difference(state.lastChecked!).inMinutes >= 10)) {
      await checkUserSubscription(userId);
    }
  }

  /// Real-time abonelik güncellemelerini dinle
  void listenToSubscriptionUpdates(String userId) {
    debugPrint(
        '🔔 SubscriptionStateNotifier: Starting real-time listener for user: $userId');

    // Kullanıcı verilerini dinle (asıl abonelik verisi burada)
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        // Log yoğunluğunu azalt - sadece önemli değişiklikleri logla
        debugPrint('🔔 SubscriptionStateNotifier: User data updated for user: $userId');
        // Detaylı log'ları kaldır - performans için
        
        // Cache'i temizle ve abonelik durumunu yenile
        state = state.copyWith(
          subscriptionResult: null,
          lastChecked: null,
        );
        checkUserSubscription(userId);
      }
    }, onError: (error) {
      debugPrint('❌ SubscriptionStateNotifier: Users collection listener error: $error');
    });

    // Ek olarak subscription_updates collection'ını da dinle
    FirebaseFirestore.instance
        .collection('subscription_updates')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (data['status'] == 'updated') {
          debugPrint(
              '🔔 SubscriptionStateNotifier: Real-time update received for user: $userId');
          // Cache'i temizle ve abonelik durumunu yenile
          state = state.copyWith(
            subscriptionResult: null,
            lastChecked: null,
          );
          checkUserSubscription(userId);
        }
      }
    }, onError: (error) {
      debugPrint('❌ SubscriptionStateNotifier: Subscription updates listener error: $error');
    });

    // Her 5 dakikada bir manuel kontrol et (fallback) - log yoğunluğunu azalt
    Timer.periodic(const Duration(minutes: 5), (timer) {
      debugPrint('🔔 SubscriptionStateNotifier: Periodic check for user: $userId (5min interval)');
      checkUserSubscription(userId);
    });
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
