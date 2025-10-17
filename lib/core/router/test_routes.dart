// ========== TEST ROUTES ==========
// lib/core/router/test_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/services/colorized_logger_test_page.dart';

/// Test routes
class TestRoutes {
  static List<GoRoute> get routes => [
        // ========== TEST ROUTES ==========

        GoRoute(
          path: '/test/colorized-logger',
          name: 'colorized-logger-test',
          builder: (context, state) => const ColorizedLoggerTestPage(),
        ),
      ];
}
