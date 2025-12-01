// ========== SUBSCRIPTION GUARD ==========
// lib/core/guards/subscription_guard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/domain/entities/user.dart';
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

    // Abonelik sayfasının kendisi için guard'ı pasifleştir (sonsuz yönlendirmeyi önle)
    final currentLocation = GoRouterState.of(context).uri.path;
    if (currentLocation.startsWith('/settings/subscription')) {
      return child;
    }

    return userAsync.when(
      data: (user) {
        if (user == null) {
          // Kullanıcı giriş yapmamış - login sayfasına yönlendir
          return _buildRedirectToLogin(context);
        }

        // Real-time listener'ı başlat
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(subscriptionStateProvider.notifier)
              .listenToSubscriptionUpdates(user.id);
        });

        // ÖNCE: Kullanıcı entity'sindeki veriyi kullan (daha hızlı)
        final userCheck = _checkSubscriptionStatus(user);

        debugPrint(
            '🔍 SubscriptionGuard: User subscription status: ${user.subscriptionStatus}');
        debugPrint(
            '🔍 SubscriptionGuard: User subscription end: ${user.subscriptionEndAt}');
        debugPrint(
            '🔍 SubscriptionGuard: UserCheck hasAccess: ${userCheck.hasAccess}');
        debugPrint(
            '🔍 SubscriptionGuard: UserCheck reason: ${userCheck.reason}');

        // Her zaman subscription state provider'ı dinle (real-time güncellemeler için)
        debugPrint(
            '🔍 SubscriptionGuard: Checking subscription state provider for real-time updates');

        SubscriptionState subscriptionState;
        try {
          subscriptionState = ref.watch(subscriptionStateProvider);
        } catch (e) {
          debugPrint('❌ SubscriptionGuard: Provider error: $e');
          // Fallback: Kullanıcı entity'sindeki veriyi kullan
          if (userCheck.hasAccess) {
            return child;
          } else {
            return _buildRedirectToSubscription(context, userCheck);
          }
        }

        debugPrint(
            '🔍 SubscriptionGuard: Subscription state - isLoading: ${subscriptionState.isLoading}, hasResult: ${subscriptionState.subscriptionResult != null}, hasError: ${subscriptionState.error != null}');

        // Real-time listener'dan gelen güncellemeleri UI'ya yansıt
        if (subscriptionState.subscriptionResult != null) {
          final subscriptionCheck = subscriptionState.subscriptionResult!;
          debugPrint(
              '🔍 SubscriptionGuard: Using subscription result - hasAccess: ${subscriptionCheck.hasAccess}');
          if (subscriptionCheck.hasAccess) {
            return child;
          } else {
            return _buildRedirectToSubscription(context, subscriptionCheck);
          }
        }

        // Loading durumunda loading göster (real-time listener çalışıyor)
        if (subscriptionState.isLoading) {
          debugPrint(
              '🔍 SubscriptionGuard: Subscription state loading, showing loading screen');
          return loadingWidget ?? _buildLoadingWidget();
        }

        // Hata durumunda kullanıcı entity'sindeki veriyi kullan
        if (subscriptionState.error != null) {
          debugPrint(
              '🔍 SubscriptionGuard: Subscription state error, using user entity data as fallback');
          if (userCheck.hasAccess) {
            return child;
          } else {
            return _buildRedirectToSubscription(context, userCheck);
          }
        }

        // Son fallback: Kullanıcı entity'sindeki veriyi kullan
        debugPrint(
            '🔍 SubscriptionGuard: Using user entity data as final fallback');
        if (userCheck.hasAccess) {
          return child;
        } else {
          return _buildRedirectToSubscription(context, userCheck);
        }
      },
      loading: () => loadingWidget ?? _buildLoadingWidget(),
      error: (error, stack) {
        final errorText = error.toString();
        if (errorText.contains('AuthenticationFailure')) {
          return _buildRedirectToLogin(context);
        }
        return errorWidget ?? _buildErrorWidget(context, errorText);
      },
    );
  }

  /// Subscription durumunu kontrol et
  SubscriptionCheckResult _checkSubscriptionStatus(User user) {
    final now = DateTime.now();

    // Debug log'ları sadece hata durumunda yazdır
    // debugPrint('🔍 _checkSubscriptionStatus: User ID: ${user.id}');

    // 1. ÖNCE: Aktif abonelik kontrolü (en yüksek öncelik)
    if (user.subscriptionStatus == SubscriptionStatus.active) {
      // Aktif abonelik var mı ve süresi dolmamış mı?
      if (user.subscriptionEndAt != null &&
          now.isBefore(user.subscriptionEndAt!)) {
        final remainingDays = user.subscriptionEndAt!.difference(now).inDays;
        return SubscriptionCheckResult(
          hasAccess: true,
          reason: 'Aktif abonelik - $remainingDays gün kaldı',
          remainingDays: remainingDays,
        );
      } else {
        // Abonelik süresi dolmuş ama kullanım hakkı devam ediyor mu?
        return _checkUsageTimeAfterSubscription(user, now);
      }
    }

    // 3. ÜÇÜNCÜ: Deneme süresi kontrolü (eski sistem - backward compatibility)
    if (user.subscriptionStatus == SubscriptionStatus.trial) {
      if (user.trialEndAt != null && now.isBefore(user.trialEndAt!)) {
        if (allowTrial) {
          final remainingDays = user.trialEndAt!.difference(now).inDays;
          return SubscriptionCheckResult(
            hasAccess: true,
            reason: 'Aktif deneme süresi - $remainingDays gün kaldı',
            remainingDays: remainingDays,
          );
        } else {
          return const SubscriptionCheckResult(
            hasAccess: false,
            reason: 'Deneme süresi kullanıcılarına izin verilmiyor',
          );
        }
      } else {
        return SubscriptionCheckResult(
          hasAccess: allowExpired,
          reason: 'Deneme süresi dolmuş',
          isTrialExpired: true,
        );
      }
    }

    // 4. DÖRDÜNCÜ: 30 günlük kayıt sonrası kullanım hakkı kontrolü (sadece abonelik yoksa)
    final registrationDate = user.createdAt;
    final thirtyDaysAfterRegistration =
        registrationDate.add(const Duration(days: 30));

    // Eğer kayıt tarihinden 30 gün geçmemişse, herkese erişim ver
    if (now.isBefore(thirtyDaysAfterRegistration)) {
      final remainingDays = thirtyDaysAfterRegistration.difference(now).inDays;
      return SubscriptionCheckResult(
        hasAccess: true,
        reason: '30 günlük kullanım hakkı - $remainingDays gün kaldı',
        remainingDays: remainingDays,
      );
    }

    // 5. BEŞİNCİ: Süresi dolan abonelik - kullanım süresi kontrolü
    if (user.subscriptionStatus == SubscriptionStatus.expired) {
      return _checkUsageTimeAfterSubscription(user, now);
    }

    // 6. SON: Hiçbir abonelik yok - 30 günlük kullanım hakkı da dolmuş
    return const SubscriptionCheckResult(
      hasAccess: false,
      reason: '30 günlük kullanım hakkı ve abonelik süresi dolmuş',
      needsSubscription: true,
    );
  }

  /// Abonelik süresi dolduktan sonra kalan kullanım süresini kontrol et
  SubscriptionCheckResult _checkUsageTimeAfterSubscription(
      User user, DateTime now) {
    // Eğer subscriptionEndAt tarihi varsa ve henüz geçmemişse erişim ver
    if (user.subscriptionEndAt != null &&
        now.isBefore(user.subscriptionEndAt!)) {
      final remainingDays = user.subscriptionEndAt!.difference(now).inDays;
      return SubscriptionCheckResult(
        hasAccess: true,
        reason: 'Kullanım süresi devam ediyor - $remainingDays gün kaldı',
        remainingDays: remainingDays,
      );
    }

    // Kullanım süresi de dolmuş
    return SubscriptionCheckResult(
      hasAccess: allowExpired,
      reason: 'Abonelik ve kullanım süresi dolmuş',
      isExpired: true,
    );
  }

  /// Login sayfasına yönlendirme
  Widget _buildRedirectToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/login');
    });
    return _buildLoadingWidget();
  }

  /// Subscription sayfasına yönlendirme
  Widget _buildRedirectToSubscription(
      BuildContext context, SubscriptionCheckResult result) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/settings/subscription');
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
  Widget _buildErrorWidget(BuildContext context, String error) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = scheme.onSurface;
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: scheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              'Hata',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: textColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: textColor.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    );
  }
}
