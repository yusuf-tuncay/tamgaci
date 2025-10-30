// ========== EMPLOYEES ROUTES ==========
// lib/core/router/employees_routes.dart

import 'package:go_router/go_router.dart';
import '../../features/employees/presentation/pages/employees_list_page.dart';

/// Personeller modülü route'ları
class EmployeesRoutes {
  static List<GoRoute> get routes => [
        GoRoute(
          path: '/employees',
          name: 'employees-list',
          builder: (context, state) => const EmployeesListPage(),
        ),
      ];
}


