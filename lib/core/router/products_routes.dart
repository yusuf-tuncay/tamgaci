// ========== PRODUCTS ROUTES ==========
// lib/core/router/products_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/products/presentation/pages/products_home_page.dart';
import '../../features/products/presentation/pages/create_product_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/product_variants_page.dart';
import '../../features/products/presentation/pages/bulk_stock_update_page.dart';

/// Products routes
class ProductsRoutes {
  static List<GoRoute> get routes => [
        // ========== PRODUCTS ROUTES ==========

        GoRoute(
          path: '/products',
          name: 'products-list',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ProductsHomePage(),
          ),
        ),

        GoRoute(
          path: '/products/create',
          name: 'create-product',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateProductPage(),
          ),
        ),

        GoRoute(
          path: '/products/detail/:id',
          name: 'product-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: ProductDetailPage(productId: id),
            );
          },
        ),

        GoRoute(
          path: '/products/variants',
          name: 'product-variants',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ProductVariantsPage(),
          ),
        ),

        GoRoute(
          path: '/products/bulk-stock-update',
          name: 'bulk-stock-update',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: BulkStockUpdatePage(),
          ),
        ),
      ];
}
