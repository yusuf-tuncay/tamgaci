// ========== LANDING ROUTE ==========
// lib/features/landing/presentation/pages/landing_route.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'landing_page.dart';

/// Web'den girildiğinde görünecek landing page route'u
class LandingRoute extends StatelessWidget {
  const LandingRoute({super.key});

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
