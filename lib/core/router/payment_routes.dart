// ========== PAYMENT ROUTES ==========
// lib/core/router/payment_routes.dart

import 'package:flutter/foundation.dart';
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
          builder: (context, state) {
            // URL parametrelerini al
            final queryParams = state.uri.queryParameters;
            final fromPayment = queryParams['from'] == 'payment';

            debugPrint('🔍 PaymentSuccess: Query params: $queryParams');
            debugPrint('🔍 PaymentSuccess: From payment: $fromPayment');

            return PaymentSuccessPage(fromPayment: fromPayment);
          },
        ),

        GoRoute(
          path: '/payment/fail',
          name: 'payment-fail',
          builder: (context, state) => const PaymentFailPage(),
        ),
      ];
}
