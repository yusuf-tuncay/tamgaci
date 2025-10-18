// ========== ACCOUNTS ROUTES ==========
// lib/core/router/accounts_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/accounts/presentation/pages/accounts_home_page.dart';
import '../../features/accounts/presentation/pages/create_account_page.dart'
    as accounts;
import '../../features/accounts/presentation/pages/account_detail_page_wrapper.dart';

/// Accounts routes
class AccountsRoutes {
  static List<GoRoute> get routes => [
        // ========== ACCOUNTS ROUTES ==========

        GoRoute(
          path: '/accounts',
          name: 'accounts-list',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: AccountsHomePage(),
          ),
        ),

        GoRoute(
          path: '/accounts/home',
          name: 'accounts-home',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: AccountsHomePage(),
          ),
        ),

        GoRoute(
          path: '/accounts/create',
          name: 'create-account',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: accounts.CreateAccountPage(),
          ),
        ),

        GoRoute(
          path: '/accounts/detail/:id',
          name: 'account-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: AccountDetailPageWrapper(accountId: id),
            );
          },
        ),
      ];
}
