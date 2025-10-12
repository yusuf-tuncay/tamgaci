// ========== MOBILE LANDING ROUTE ==========
// lib/features/landing/presentation/pages/mobile_landing_route.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/routes/routes.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Mobil uygulamadan girildiğinde authentication kontrolü yapan route
/// Kullanıcı giriş yapmışsa dashboard'a, yapmamışsa splash'e yönlendirir
class MobileLandingRoute extends ConsumerStatefulWidget {
  const MobileLandingRoute({super.key});

  @override
  ConsumerState<MobileLandingRoute> createState() => _MobileLandingRouteState();
}

class _MobileLandingRouteState extends ConsumerState<MobileLandingRoute> {
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
          Navigator.of(context).pushReplacementNamed(TamgaciRoutes.dashboard);
        }
      });
    } else {
      // Kullanıcı giriş yapmamış - splash'e yönlendir
      AppLogger.info('User is not signed in, navigating to splash');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(TamgaciRoutes.splash);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading indicator göster
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
