// ========== CUSTOMERS ROUTES ==========
// lib/core/router/customers_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/customers/presentation/pages/enhanced_customers_list_page.dart';
import '../../features/customers/presentation/pages/create_customers_page.dart';
import '../../features/customers/presentation/pages/enhanced_customer_detail_page_v2.dart';
import '../../features/customers/presentation/pages/customer_all_transactions_page.dart';

/// Customers routes
class CustomersRoutes {
  static List<GoRoute> get routes => [
        // ========== CUSTOMERS ROUTES ==========

        GoRoute(
          path: '/customers',
          name: 'customers-list',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedCustomersListPage(),
          ),
        ),

        GoRoute(
          path: '/customers/create',
          name: 'create-customer',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateCustomerPage(),
          ),
        ),

        GoRoute(
          path: '/customers/detail/:id',
          name: 'customer-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: EnhancedCustomerDetailPageV2(customerId: id),
            );
          },
        ),

        GoRoute(
          path: '/customers/:id/all-transactions',
          name: 'customer-all-transactions',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: CustomerAllTransactionsPage(customerId: id),
            );
          },
        ),
      ];
}
