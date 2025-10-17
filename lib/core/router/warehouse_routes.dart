// ========== WAREHOUSE ROUTES ==========
// lib/core/router/warehouse_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/warehouses/presentation/pages/warehouses_home_page.dart';

/// Warehouse routes
class WarehouseRoutes {
  static List<GoRoute> get routes => [
        // ========== WAREHOUSE ROUTES ==========

        GoRoute(
          path: '/warehouses',
          name: 'warehouses-home',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: WarehousesHomePage(),
          ),
        ),
      ];
}
