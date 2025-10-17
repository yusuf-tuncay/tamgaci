// ========== PAYMENT ROUTES ==========
// lib/core/router/payment_routes.dart

import 'package:go_router/go_router.dart';
import '../../features/subscription/presentation/pages/payment_success_page.dart';
import '../../features/subscription/presentation/pages/payment_fail_page.dart';

/// Payment routes (NO AUTH REQUIRED)
class PaymentRoutes {
  static List<GoRoute> get routes => [
        // ========== PAYMENT ROUTES (NO AUTH REQUIRED) ==========

        GoRoute(
          path: '/payment/success',
          name: 'payment-success',
          builder: (context, state) => const PaymentSuccessPage(),
        ),

        GoRoute(
          path: '/payment/fail',
          name: 'payment-fail',
          builder: (context, state) => const PaymentFailPage(),
        ),
      ];
}
