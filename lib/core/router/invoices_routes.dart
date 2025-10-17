// ========== INVOICES ROUTES ==========
// lib/core/router/invoices_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/invoices/presentation/pages/invoices_list_page.dart';
import '../../features/invoices/presentation/pages/create_invoice_page.dart';

/// Invoices routes
class InvoicesRoutes {
  static List<GoRoute> get routes => [
        // ========== INVOICES ROUTES ==========

        GoRoute(
          path: '/invoices',
          name: 'invoices-list',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: InvoicesListPage(),
          ),
        ),

        GoRoute(
          path: '/invoices/create',
          name: 'create-invoice',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateInvoicePage(),
          ),
        ),
      ];
}
