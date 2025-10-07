// ========== SUBSCRIPTION GUARD ==========
// lib/core/guards/subscription_guard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';

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

        // Subscription durumunu kontrol et
        final subscriptionCheck = _checkSubscriptionStatus(user);

        if (subscriptionCheck.hasAccess) {
          return child;
        } else {
          // Erişim yok - subscription sayfasına yönlendir
          return _buildRedirectToSubscription(context, subscriptionCheck);
        }
      },
      loading: () => loadingWidget ?? _buildLoadingWidget(),
      error: (error, stack) => errorWidget ?? _buildErrorWidget(error),
    );
  }

  /// Subscription durumunu kontrol et
  SubscriptionCheckResult _checkSubscriptionStatus(User user) {
    final now = DateTime.now();

    // Admin kullanıcılar her zaman erişebilir
    if (user.role == UserRole.admin) {
      return const SubscriptionCheckResult(
        hasAccess: true,
        reason: 'Admin kullanıcı',
      );
    }

    // Aktif abonelik var mı?
    if (user.subscriptionStatus == SubscriptionStatus.active) {
      return const SubscriptionCheckResult(
        hasAccess: true,
        reason: 'Aktif abonelik',
      );
    }

    // Deneme süresi kontrolü
    if (user.subscriptionStatus == SubscriptionStatus.trial) {
      if (user.trialEndAt != null && now.isBefore(user.trialEndAt!)) {
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
        // Deneme süresi dolmuş
        return SubscriptionCheckResult(
          hasAccess: allowExpired,
          reason: 'Deneme süresi dolmuş',
          isTrialExpired: true,
        );
      }
    }

    // Süresi dolan abonelik
    if (user.subscriptionStatus == SubscriptionStatus.expired) {
      return SubscriptionCheckResult(
        hasAccess: allowExpired,
        reason: 'Abonelik süresi dolmuş',
        isExpired: true,
      );
    }

    // Hiç abonelik yok
    return const SubscriptionCheckResult(
      hasAccess: false,
      reason: 'Abonelik bulunamadı',
      needsSubscription: true,
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

/// Subscription kontrol sonucu
class SubscriptionCheckResult {
  /// Erişim izni var mı?
  final bool hasAccess;

  /// Kontrol sebebi
  final String reason;

  /// Kalan gün sayısı (deneme süresi için)
  final int? remainingDays;

  /// Deneme süresi dolmuş mu?
  final bool isTrialExpired;

  /// Abonelik süresi dolmuş mu?
  final bool isExpired;

  /// Abonelik gerekli mi?
  final bool needsSubscription;

  const SubscriptionCheckResult({
    required this.hasAccess,
    required this.reason,
    this.remainingDays,
    this.isTrialExpired = false,
    this.isExpired = false,
    this.needsSubscription = false,
  });
}
