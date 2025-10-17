// ========== LANDING ROUTE ==========
// lib/features/landing/presentation/pages/landing_route.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'landing_page.dart';

/// Web'den girildiğinde görünecek landing page route'u
/// Kullanıcı giriş yapmışsa dashboard'a yönlendirir
class LandingRoute extends ConsumerStatefulWidget {
  const LandingRoute({super.key});

  @override
  ConsumerState<LandingRoute> createState() => _LandingRouteState();
}

class _LandingRouteState extends ConsumerState<LandingRoute> {
  @override
  void initState() {
    super.initState();
    // Authentication durumunu kontrol et
    _checkAuthStatus();
  }

  /// Authentication durumunu kontrol et
  void _checkAuthStatus() {
    // Firebase Auth durumunu kontrol et
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Kullanıcı giriş yapmış - dashboard'a yönlendir
      AppLogger.info('User is signed in, navigating to dashboard');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/dashboard');
        }
      });
    } else {
      // Kullanıcı giriş yapmamış - landing page'i göster
      AppLogger.info('User is not signed in, showing landing page');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sadece web'de göster
    if (kIsWeb) {
      return const LandingPage();
    } else {
      // Mobil uygulamada normal uygulamaya yönlendir
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
