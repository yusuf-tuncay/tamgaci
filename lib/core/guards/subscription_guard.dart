// ========== SUBSCRIPTION GUARD ==========
// lib/core/guards/subscription_guard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import '../services/subscription/firestore_subscription_service.dart';
import '../providers/subscription_state_provider.dart';

/// Abonelik durumu kontrol eden guard widget'ı
class SubscriptionGuard extends ConsumerWidget {
  /// Korunan widget
  final Widget child;

  /// Deneme süresi kullanıcılarına izin ver
  final bool allowTrial;

  /// Süresi dolan kullanıcılara izin ver
  final bool allowExpired;

  /// Yükleniyor durumunda gösterilecek widget
  final Widget? loadingWidget;

  /// Hata durumunda gösterilecek widget
  final Widget? errorWidget;

  const SubscriptionGuard({
    super.key,
    required this.child,
    this.allowTrial = true,
    this.allowExpired = false,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          // Kullanıcı giriş yapmamış - login sayfasına yönlendir
          return _buildRedirectToLogin(context);
        }

        // Cache'lenmiş abonelik durumunu kullan
        final subscriptionState = ref.watch(subscriptionStateProvider);
        
        if (subscriptionState.isLoading) {
          return loadingWidget ?? _buildLoadingWidget();
        }
        
        if (subscriptionState.error != null) {
          // Hata durumunda kullanıcı entity'sindeki veriyi kullan
          final fallbackCheck = _checkSubscriptionStatus(user);
          if (fallbackCheck.hasAccess) {
            return child;
          } else {
            return _buildRedirectToSubscription(context, fallbackCheck);
          }
        }
        
        if (subscriptionState.subscriptionResult != null) {
          final subscriptionCheck = subscriptionState.subscriptionResult!;
          
          if (subscriptionCheck.hasAccess) {
            return child;
          } else {
            return _buildRedirectToSubscription(context, subscriptionCheck);
          }
        }
        
        // Fallback: Kullanıcı entity'sindeki veriyi kullan
        final fallbackCheck = _checkSubscriptionStatus(user);
        if (fallbackCheck.hasAccess) {
          return child;
        } else {
          return _buildRedirectToSubscription(context, fallbackCheck);
        }
      },
      loading: () => loadingWidget ?? _buildLoadingWidget(),
      error: (error, stack) => errorWidget ?? _buildErrorWidget(error),
    );
  }

  /// Subscription durumunu kontrol et
  SubscriptionCheckResult _checkSubscriptionStatus(User user) {
    final now = DateTime.now();

    // print('🔍 _checkSubscriptionStatus Debug:');
    // print('  - Subscription Status: ${user.subscriptionStatus}');
    // print('  - Trial End At: ${user.trialEndAt}');
    // print('  - Subscription End At: ${user.subscriptionEndAt}');
    // print('  - Now: $now');

    // Aktif abonelik var mı?
    if (user.subscriptionStatus == SubscriptionStatus.active) {
      // print('✅ Active subscription found');
      return const SubscriptionCheckResult(
        hasAccess: true,
        reason: 'Aktif abonelik',
      );
    }

    // Deneme süresi kontrolü
    if (user.subscriptionStatus == SubscriptionStatus.trial) {
      if (user.trialEndAt != null && now.isBefore(user.trialEndAt!)) {
        // print('✅ Active trial found');
        // Deneme süresi aktif
        if (allowTrial) {
          return SubscriptionCheckResult(
            hasAccess: true,
            reason: 'Aktif deneme süresi',
            remainingDays: user.trialEndAt!.difference(now).inDays,
          );
        } else {
          return const SubscriptionCheckResult(
            hasAccess: false,
            reason: 'Deneme süresi kullanıcılarına izin verilmiyor',
          );
        }
      } else {
        // print('❌ Trial expired');
        // Deneme süresi dolmuş
        return SubscriptionCheckResult(
          hasAccess: allowExpired,
          reason: 'Deneme süresi dolmuş',
          isTrialExpired: true,
        );
      }
    }

    // Süresi dolan abonelik - ama hala kullanım süresi var mı kontrol et
    if (user.subscriptionStatus == SubscriptionStatus.expired) {
      // print('🔍 Checking expired subscription with usage time');
      // Eğer subscriptionEndAt tarihi varsa ve henüz geçmemişse erişim ver
      if (user.subscriptionEndAt != null &&
          now.isBefore(user.subscriptionEndAt!)) {
        // print('✅ Expired but still has usage time');
        return const SubscriptionCheckResult(
          hasAccess: true,
          reason: 'Kullanım süresi devam ediyor',
        );
      }

      // print('❌ Expired and no usage time left');
      return SubscriptionCheckResult(
        hasAccess: allowExpired,
        reason: 'Abonelik süresi dolmuş',
        isExpired: true,
      );
    }

    // print(
    //     '❌ No subscription found - checking Firestore for active subscriptions');

    // Firestore'dan kullanıcının aktif aboneliklerini kontrol et
    // Bu durumda kullanıcının gerçek subscription durumunu kontrol etmek için
    // Firestore'dan subscription verilerini alıp kontrol edelim

    // Şimdilik geçici olarak erişim ver (gerçek kontrol için Firestore'dan veri alınmalı)
    // TODO: Firestore'dan subscription verilerini alıp gerçek kontrol yap
    return const SubscriptionCheckResult(
      hasAccess: true,
      reason: 'Geçici erişim - Firestore kontrolü gerekli',
    );
  }

  /// Login sayfasına yönlendirme
  Widget _buildRedirectToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/login');
    });
    return _buildLoadingWidget();
  }

  /// Subscription sayfasına yönlendirme
  Widget _buildRedirectToSubscription(
      BuildContext context, SubscriptionCheckResult result) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SubscriptionPage(
            isTrialExpired: result.isTrialExpired,
            isExpired: result.isExpired,
            reason: result.reason,
          ),
        ),
      );
    });
    return _buildLoadingWidget();
  }

  /// Yükleniyor widget'ı
  Widget _buildLoadingWidget() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Abonelik durumu kontrol ediliyor...'),
          ],
        ),
      ),
    );
  }

  /// Hata widget'ı
  Widget _buildErrorWidget(Object error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Hata: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Ana sayfaya dön
              },
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    );
  }
}
