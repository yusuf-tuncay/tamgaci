// ========== REPORTS ROUTES ==========
// lib/core/router/reports_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/reports/presentation/pages/reports_overview_page.dart';
import '../../features/reports/presentation/pages/income_expense_report_page.dart';
import '../../features/reports/presentation/pages/customer_report_page.dart';
import '../../features/reports/presentation/pages/supplier_report_page.dart';
import '../../features/reports/presentation/pages/product_report_page.dart';

/// Reports routes
class ReportsRoutes {
  static List<GoRoute> get routes => [
        // ========== REPORTS ROUTES ==========

        GoRoute(
          path: '/reports',
          name: 'reports-overview',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ReportsOverviewPage(),
          ),
        ),

        GoRoute(
          path: '/reports/income-expense',
          name: 'income-expense-report',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: IncomeExpenseReportPage(),
          ),
        ),

        GoRoute(
          path: '/reports/customers',
          name: 'customer-report',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CustomerReportPage(),
          ),
        ),

        GoRoute(
          path: '/reports/suppliers',
          name: 'supplier-report',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: SupplierReportPage(),
          ),
        ),

        GoRoute(
          path: '/reports/products',
          name: 'product-report',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ProductReportPage(),
          ),
        ),
      ];
}
