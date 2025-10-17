// ========== AUTH GUARD WIDGET ==========
// lib/core/widgets/auth_guard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/splash/presentation/pages/splash.dart' show SplashScreen;

/// Auth Guard Widget
/// Kullanıcının oturum durumuna göre yönlendirme yapar
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final bool requireAuth;
  final String? redirectTo;

  const AuthGuard({
    super.key,
    required this.child,
    this.requireAuth = true,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isSignedIn = authState.isSignedIn;

    // Loading durumunda splash göster
    if (authState.isLoading) {
      return const SplashScreen(homeRoute: '/dashboard');
    }

    // Auth gerekiyorsa ve kullanıcı giriş yapmamışsa
    if (requireAuth && !isSignedIn) {
      // Redirect sayfası belirtilmişse oraya yönlendir
      if (redirectTo != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(redirectTo!);
        });
      } else {
        // Varsayılan olarak login sayfasına yönlendir
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
      }
      return const SplashScreen(homeRoute: '/dashboard');
    }

    // Auth gerekmeyen sayfalar için (login, register gibi)
    // Kullanıcı zaten giriş yapmışsa dashboard'a yönlendir
    if (!requireAuth && isSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/dashboard');
      });
      return const SplashScreen(homeRoute: '/dashboard');
    }

    // Normal durumda child widget'ı göster
    return child;
  }
}

/// Auth durumuna göre farklı widget'lar gösteren widget
class AuthBuilder extends ConsumerWidget {
  final Widget Function(BuildContext context, bool isSignedIn) builder;
  final Widget? loadingWidget;

  const AuthBuilder({
    super.key,
    required this.builder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Loading durumunda
    if (authState.isLoading) {
      return loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    // Auth durumuna göre widget oluştur
    return builder(context, authState.isSignedIn);
  }
}

/// Kullanıcı bilgilerini gösteren widget
class UserInfoWidget extends ConsumerWidget {
  const UserInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userEmail = ref.watch(userEmailProvider);
    final userDisplayName = ref.watch(userDisplayNameProvider);

    if (user.value == null) {
      return const Text('Kullanıcı bilgisi bulunamadı');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userDisplayName != null)
          Text(
            userDisplayName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        if (userEmail != null)
          Text(
            userEmail,
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

/// Çıkış yapma butonu
class LogoutButton extends ConsumerWidget {
  final VoidCallback? onLogout;

  const LogoutButton({
    super.key,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authLoadingProvider);

    return IconButton(
      onPressed: isLoading
          ? null
          : () async {
              try {
                await ref.read(authProvider.notifier).signOut();
                if (onLogout != null) {
                  onLogout!();
                } else {
                  // Varsayılan olarak login sayfasına yönlendir
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Çıkış yapılırken hata oluştu: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout),
      tooltip: 'Çıkış Yap',
    );
  }
}
