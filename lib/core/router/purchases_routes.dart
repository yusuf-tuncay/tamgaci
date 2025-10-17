// ========== PURCHASES ROUTES ==========
// lib/core/router/purchases_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/purchases/presentation/pages/enhanced_purchases_list_page.dart';
import '../../features/purchases/presentation/pages/create_purchase_page.dart';
import '../../features/purchases/presentation/pages/enhanced_purchase_detail_page.dart';

/// Purchases routes
class PurchasesRoutes {
  static List<GoRoute> get routes => [
        // ========== PURCHASES ROUTES ==========

        GoRoute(
          path: '/purchases',
          name: 'purchases-list',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedPurchasesListPage(),
          ),
        ),

        GoRoute(
          path: '/purchases/create',
          name: 'create-purchase',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreatePurchasePage(),
          ),
        ),

        GoRoute(
          path: '/purchases/detail/:id',
          name: 'purchase-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: EnhancedPurchaseDetailPage(purchaseId: id),
            );
          },
        ),
      ];
}
