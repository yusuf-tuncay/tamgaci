// ========== DASHBOARD ROUTES ==========
// lib/core/router/dashboard_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

/// Dashboard routes
class DashboardRoutes {
  static List<GoRoute> get routes => [
        // ========== DASHBOARD ROUTES ==========

        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: DashboardPage(),
          ),
        ),
      ];
}
