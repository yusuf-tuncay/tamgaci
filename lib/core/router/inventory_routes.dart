// ========== INVENTORY ROUTES ==========
// lib/core/router/inventory_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/inventory/presentation/pages/stock_list_page.dart';
import '../../features/inventory/presentation/pages/warehouse_list_page.dart';
import '../../features/inventory/presentation/pages/warehouse_detail_page.dart';
import '../../features/inventory/presentation/pages/stock_detail_page.dart';
import '../../features/inventory/presentation/pages/inventory_items_list_page.dart';
import '../../features/inventory/presentation/pages/create_stock_page.dart';
import '../../features/inventory/presentation/pages/stock_count_page.dart';
import '../../features/inventory/presentation/pages/stock_counts_list_page.dart';
import '../../features/warehouses/domain/entities/warehouse.dart';

/// Inventory routes
class InventoryRoutes {
  static List<GoRoute> get routes => [
        // ========== INVENTORY ROUTES ==========

        GoRoute(
          path: '/inventory',
          name: 'inventory',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: StockListPage(),
          ),
        ),

        GoRoute(
          path: '/inventory/stock',
          name: 'stock-list',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: StockListPage(),
          ),
        ),

        GoRoute(
          path: '/inventory/warehouses',
          name: 'warehouse-list',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: WarehouseListPage(),
          ),
        ),

        GoRoute(
          path: '/inventory/warehouses/detail/:id',
          name: 'inventory-warehouse-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: WarehouseDetailPage(warehouseId: id),
            );
          },
        ),

        GoRoute(
          path: '/inventory/stock/detail/:id',
          name: 'stock-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: StockDetailPage(stockId: id),
            );
          },
        ),

        GoRoute(
          path: '/inventory/items',
          name: 'inventory-items',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: InventoryItemsListPage(),
          ),
        ),

        GoRoute(
          path: '/inventory/stock/create',
          name: 'create-stock',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateStockPage(),
          ),
        ),

        GoRoute(
          path: '/inventory/stock-count',
          name: 'stock-count',
          builder: (context, state) => SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: StockCountPage(
              warehouse: Warehouse(
                id: 'default',
                name: 'Varsayılan Depo',
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
          ),
        ),

        GoRoute(
          path: '/inventory/stock-counts',
          name: 'stock-counts-list',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: StockCountsListPage(),
          ),
        ),
      ];
}
