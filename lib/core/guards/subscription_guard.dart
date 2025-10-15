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
        SubscriptionState subscriptionState;
        try {
          subscriptionState = ref.watch(subscriptionStateProvider);
        } catch (e) {
          debugPrint('❌ SubscriptionGuard: Provider error: $e');
          // Fallback: Kullanıcı entity'sindeki veriyi kullan
          final fallbackCheck = _checkSubscriptionStatus(user);
          if (fallbackCheck.hasAccess) {
            return child;
          } else {
            return _buildRedirectToSubscription(context, fallbackCheck);
          }
        }

        // Debug log'ları sadece gerektiğinde yazdır
        if (subscriptionState.isLoading || subscriptionState.error != null) {
          debugPrint('🔍 SubscriptionGuard: User ID: ${user.id}');
          debugPrint(
              '🔍 SubscriptionGuard: Subscription state - isLoading: ${subscriptionState.isLoading}, error: ${subscriptionState.error}');
        }

        if (subscriptionState.isLoading) {
          debugPrint('⏳ SubscriptionGuard: Loading subscription state');
          return loadingWidget ?? _buildLoadingWidget();
        }

        if (subscriptionState.error != null) {
          debugPrint(
              '❌ SubscriptionGuard: Subscription state error: ${subscriptionState.error}');
          // Hata durumunda kullanıcı entity'sindeki veriyi kullan
          final fallbackCheck = _checkSubscriptionStatus(user);
          debugPrint(
              '🔄 SubscriptionGuard: Fallback check result: ${fallbackCheck.hasAccess} - ${fallbackCheck.reason}');
          if (fallbackCheck.hasAccess) {
            return child;
          } else {
            return _buildRedirectToSubscription(context, fallbackCheck);
          }
        }

        if (subscriptionState.subscriptionResult != null) {
          final subscriptionCheck = subscriptionState.subscriptionResult!;
          // Sadece hata durumunda log yazdır
          if (!subscriptionCheck.hasAccess) {
            debugPrint(
                '✅ SubscriptionGuard: Using cached subscription result: ${subscriptionCheck.hasAccess} - ${subscriptionCheck.reason}');
          }

          if (subscriptionCheck.hasAccess) {
            return child;
          } else {
            return _buildRedirectToSubscription(context, subscriptionCheck);
          }
        }

        // Fallback: Kullanıcı entity'sindeki veriyi kullan
        final fallbackCheck = _checkSubscriptionStatus(user);
        if (!fallbackCheck.hasAccess) {
          debugPrint(
              '🔄 SubscriptionGuard: Fallback check result: ${fallbackCheck.hasAccess} - ${fallbackCheck.reason}');
        }
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

    debugPrint('🔍 _checkSubscriptionStatus: User ID: ${user.id}');
    debugPrint(
        '🔍 _checkSubscriptionStatus: User createdAt: ${user.createdAt}');
    debugPrint(
        '🔍 _checkSubscriptionStatus: User subscriptionStatus: ${user.subscriptionStatus}');
    debugPrint(
        '🔍 _checkSubscriptionStatus: User subscriptionEndAt: ${user.subscriptionEndAt}');
    debugPrint(
        '🔍 _checkSubscriptionStatus: User trialEndAt: ${user.trialEndAt}');
    debugPrint('🔍 _checkSubscriptionStatus: Current time: $now');

    // 1. ÖNCE: Aktif abonelik kontrolü (en yüksek öncelik)
    if (user.subscriptionStatus == SubscriptionStatus.active) {
      debugPrint('🔍 _checkSubscriptionStatus: Active subscription found');
      // Aktif abonelik var mı ve süresi dolmamış mı?
      if (user.subscriptionEndAt != null &&
          now.isBefore(user.subscriptionEndAt!)) {
        final remainingDays = user.subscriptionEndAt!.difference(now).inDays;
        debugPrint(
            '✅ _checkSubscriptionStatus: Active subscription with remaining time - $remainingDays days');
        return SubscriptionCheckResult(
          hasAccess: true,
          reason: 'Aktif abonelik - $remainingDays gün kaldı',
          remainingDays: remainingDays,
        );
      } else {
        debugPrint(
            '❌ _checkSubscriptionStatus: Active subscription but expired, checking usage time');
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

    debugPrint(
        '🔍 _checkSubscriptionStatus: 30 days after registration: $thirtyDaysAfterRegistration');

    // Eğer kayıt tarihinden 30 gün geçmemişse, herkese erişim ver
    if (now.isBefore(thirtyDaysAfterRegistration)) {
      final remainingDays = thirtyDaysAfterRegistration.difference(now).inDays;
      debugPrint(
          '✅ _checkSubscriptionStatus: 30-day usage right found - $remainingDays days remaining');
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
