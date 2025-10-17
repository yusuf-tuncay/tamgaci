// ========== SALES ROUTES ==========
// lib/core/router/sales_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/sales/presentation/pages/enhanced_sales_list_page.dart';
import '../../features/sales/presentation/pages/create_sale_page.dart';
import '../../features/sales/presentation/pages/sale_detail_page.dart';

/// Sales routes
class SalesRoutes {
  static List<GoRoute> get routes => [
        // ========== SALES ROUTES ==========

        GoRoute(
          path: '/sales',
          name: 'sales-list',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedSalesListPage(),
          ),
        ),

        GoRoute(
          path: '/sales/create',
          name: 'create-sale',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateSalePage(),
          ),
        ),

        GoRoute(
          path: '/sales/detail/:id',
          name: 'sale-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: SaleDetailPage(saleId: id),
            );
          },
        ),
      ];
}
