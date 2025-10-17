// ========== REPORTS ROUTES ==========
// lib/core/router/reports_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../shared/pages/under_construction_page.dart';
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

        // ========== ADDITIONAL REPORT ROUTES ==========

        GoRoute(
          path: '/reports/sales-performance',
          name: 'sales-performance-report',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: UnderConstructionPage(),
          ),
        ),

        GoRoute(
          path: '/reports/cash-flow',
          name: 'cash-flow-report',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: UnderConstructionPage(),
          ),
        ),

        GoRoute(
          path: '/reports/profit-loss',
          name: 'profit-loss-report',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: UnderConstructionPage(),
          ),
        ),

        GoRoute(
          path: '/reports/inventory-status',
          name: 'inventory-status-report',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: UnderConstructionPage(),
          ),
        ),

        GoRoute(
          path: '/reports/inventory-movement',
          name: 'inventory-movement-report',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: UnderConstructionPage(),
          ),
        ),

        GoRoute(
          path: '/reports/customer-payments',
          name: 'customer-payments-report',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: UnderConstructionPage(),
          ),
        ),

        GoRoute(
          path: '/reports/customer-analysis',
          name: 'customer-analysis-report',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: UnderConstructionPage(),
          ),
        ),
      ];
}
