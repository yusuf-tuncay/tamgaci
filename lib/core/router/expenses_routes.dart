// ========== EXPENSES ROUTES ==========
// lib/core/router/expenses_routes.dart

import 'package:go_router/go_router.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';

/// Masraflar modülü route'ları
class ExpensesRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: '/expenses',
      name: 'expenses',
      builder: (context, state) => const ExpensesPage(),
    ),
  ];
}
