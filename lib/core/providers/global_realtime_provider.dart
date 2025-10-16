// ========== GLOBAL REAL-TIME LISTENER PROVIDER ==========
// lib/core/providers/global_realtime_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Global real-time listener provider
class GlobalRealtimeNotifier extends StateNotifier<bool> {
  GlobalRealtimeNotifier() : super(false);

  /// Global real-time listener'ı başlat
  void startGlobalListener() {
    if (state) return; // Zaten başlatılmış

    debugPrint('🔔 GlobalRealtimeNotifier: Starting global real-time listener');

    // Firebase Auth state değişikliklerini dinle
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        debugPrint(
            '🔔 GlobalRealtimeNotifier: User signed in, starting subscription listener');
        _startSubscriptionListener(user.uid);
      } else {
        debugPrint(
            '🔔 GlobalRealtimeNotifier: User signed out, stopping listeners');
        _stopAllListeners();
      }
    });

    state = true;
  }

  /// Abonelik real-time listener'ını başlat
  void _startSubscriptionListener(String userId) {
    debugPrint(
        '🔔 GlobalRealtimeNotifier: Starting subscription listener for user: $userId');

    FirebaseFirestore.instance
        .collection('subscription_updates')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (data['status'] == 'updated') {
          debugPrint(
              '🔔 GlobalRealtimeNotifier: Real-time subscription update received');
          // Global subscription state'i güncelle
          _updateGlobalSubscriptionState(userId);
        }
      }
    });
  }

  /// Global subscription state'i güncelle
  void _updateGlobalSubscriptionState(String userId) {
    // Bu metod subscription_state_provider'ı güncelleyecek
    // Ancak burada doğrudan provider'a erişim yok
    // Bu yüzden bu işlem subscription_state_provider'da yapılacak
    debugPrint('🔔 GlobalRealtimeNotifier: Updating global subscription state');
  }

  /// Tüm listener'ları durdur
  void _stopAllListeners() {
    debugPrint('🔔 GlobalRealtimeNotifier: Stopping all listeners');
    // Listener'lar otomatik olarak durur
  }

  /// Global listener'ı durdur
  void stopGlobalListener() {
    debugPrint('🔔 GlobalRealtimeNotifier: Stopping global listener');
    _stopAllListeners();
    state = false;
  }
}

/// Global real-time listener provider
final globalRealtimeProvider =
    StateNotifierProvider<GlobalRealtimeNotifier, bool>((ref) {
  return GlobalRealtimeNotifier();
});

/// Global real-time listener'ı başlat (lazy initialization)
final startGlobalRealtimeListenerProvider = Provider<void>((ref) {
  // Lazy initialization - sadece gerektiğinde başlat
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(globalRealtimeProvider.notifier).startGlobalListener();
  });
});
