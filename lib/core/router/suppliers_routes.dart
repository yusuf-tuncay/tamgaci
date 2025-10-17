// ========== SUPPLIERS ROUTES ==========
// lib/core/router/suppliers_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/suppliers/presentation/pages/enhanced_suppliers_list_page.dart';
import '../../features/suppliers/presentation/pages/enhanced_supplier_detail_page.dart';

/// Suppliers routes
class SuppliersRoutes {
  static List<GoRoute> get routes => [
        // ========== SUPPLIERS ROUTES ==========

        GoRoute(
          path: '/suppliers',
          name: 'suppliers-list',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedSuppliersListPage(),
          ),
        ),

        GoRoute(
          path: '/suppliers/detail/:id',
          name: 'supplier-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: EnhancedSupplierDetailPage(supplierId: id),
            );
          },
        ),
      ];
}
