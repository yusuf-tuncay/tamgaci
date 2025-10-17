// ========== WAREHOUSE ROUTES ==========
// lib/core/router/warehouse_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/warehouses/domain/entities/warehouse.dart';
import '../../features/warehouses/presentation/pages/warehouses_home_page.dart';
import '../../features/warehouses/presentation/pages/create_warehouse_page.dart';
import '../../features/warehouses/presentation/pages/warehouse_detail_page.dart';

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

        GoRoute(
          path: '/warehouses/create',
          name: 'create-warehouse',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateWarehousePage(),
          ),
        ),

        GoRoute(
          path: '/warehouses/detail/:id',
          name: 'warehouse-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: WarehouseDetailPage(
                warehouse: Warehouse(
                  id: id,
                  name: '',
                  type: WarehouseType.main,
                  status: WarehouseStatus.active,
                  address: '',
                  isActive: true,
                  createdBy: '',
                  createdAt: DateTime.now(),
                  updatedBy: '',
                  updatedAt: DateTime.now(),
                  tenantId: '',
                ),
              ),
            );
          },
        ),
      ];
}
