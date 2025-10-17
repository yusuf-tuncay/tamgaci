// ========== SETTINGS ROUTES ==========
// lib/core/router/settings_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/company_settings_page.dart';
import '../../features/settings/presentation/pages/permissions_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';

/// Settings routes
class SettingsRoutes {
  static List<GoRoute> get routes => [
        // ========== SETTINGS ROUTES ==========

        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: SettingsPage(),
          ),
        ),

        GoRoute(
          path: '/settings/profile',
          name: 'profile',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ProfilePage(),
          ),
        ),

        GoRoute(
          path: '/settings/subscription',
          name: 'subscription',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: SubscriptionPage(),
          ),
        ),

        GoRoute(
          path: '/settings/permissions',
          name: 'permissions',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: PermissionsPage(),
          ),
        ),

        GoRoute(
          path: '/settings/company',
          name: 'company-settings',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CompanySettingsPage(),
          ),
        ),
      ];
}
