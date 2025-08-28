// ========== SPLASH FEATURE ==========
// lib/features/splash/presentation/pages/splash_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/splash/presentation/pages/splash.dart'; // Önceki splash artifact'ından

/// Splash sayfası - önceki artifact'tan import edilecek
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SplashScreen(homeRoute: '/dashboard', loginRoute: '/login');
  }
}
