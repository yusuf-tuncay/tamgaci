// ========== GO ROUTER CONFIGURATION ==========
// lib/core/routing/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ========== LANDING PAGES ==========
import '../../features/landing/presentation/pages/landing_page.dart';
import '../../features/landing/presentation/pages/blog_page.dart';
import '../../features/landing/presentation/pages/blog_detail_page.dart';
import '../../features/landing/presentation/pages/faq_page.dart';

// ========== SHARED PAGES ==========
import '../../shared/pages/not_found_page.dart';
import '../../shared/pages/under_construction_page.dart';

// ========== FEATURE ROUTES ==========
import '../router/auth_routes.dart';
import '../router/dashboard_routes.dart';
import '../router/sales_routes.dart';
import '../router/customers_routes.dart';
import '../router/products_routes.dart';
import '../router/invoices_routes.dart';
import '../router/settings_routes.dart';
import '../router/payment_routes.dart';
import '../router/warehouse_routes.dart';
import '../router/inventory_routes.dart';
import '../router/purchases_routes.dart';
import '../router/suppliers_routes.dart';
import '../router/accounts_routes.dart';
import '../router/expenses_routes.dart';
import '../router/reports_routes.dart';
import '../router/employees_routes.dart';
import '../router/test_routes.dart';

/// Go Router configuration
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Router configuration
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // ========== PUBLIC ROUTES ==========

      // Landing
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),

      // Blog
      GoRoute(
        path: '/blog',
        name: 'blog',
        builder: (context, state) => const BlogPage(),
      ),

      // Blog Detail
      GoRoute(
        path: '/blog/:slug',
        name: 'blog-detail',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return BlogDetailPage(slug: slug);
        },
      ),

      // FAQ (Sıkça Sorulan Sorular)
      GoRoute(
        path: '/faq',
        name: 'faq',
        builder: (context, state) => const FAQPage(),
      ),

      // ========== FEATURE ROUTES ==========
      ...AuthRoutes.routes,
      ...DashboardRoutes.routes,
      ...SalesRoutes.routes,
      ...CustomersRoutes.routes,
      ...ProductsRoutes.routes,
      ...InvoicesRoutes.routes,
      ...SettingsRoutes.routes,
      ...PaymentRoutes.routes,
      ...WarehouseRoutes.routes,
      ...InventoryRoutes.routes,
      ...PurchasesRoutes.routes,
      ...SuppliersRoutes.routes,
      ...AccountsRoutes.routes,
      ...ExpensesRoutes.routes,
      ...ReportsRoutes.routes,
      ...EmployeesRoutes.routes,
      ...TestRoutes.routes,

      // ========== SHARED ROUTES ==========

      GoRoute(
        path: '/under-construction',
        name: 'under-construction',
        builder: (context, state) => const UnderConstructionPage(),
      ),
    ],

    // ========== ROUTE GUARDS ==========

    /// Redirect logic for authentication
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isAuthenticated = user != null;
      final currentPath = state.uri.path;
      final isOnPaymentPage = currentPath.startsWith('/payment/');
      
      // Blog sayfaları kontrolü - hem /blog hem de /blog/* için
      final isOnBlogPage = currentPath == '/blog' || currentPath.startsWith('/blog/');
      
      final isOnPublicPage = [
        '/',
        '/login',
        '/register',
        '/forgot-password',
        '/faq',
      ].contains(currentPath) || isOnBlogPage;

      debugPrint(
          '🔍 AppRouter: Redirect check - Location: ${state.matchedLocation}');
      debugPrint('🔍 AppRouter: Redirect check - Current path: $currentPath');
      debugPrint('🔍 AppRouter: Redirect check - Full location: ${state.uri}');
      debugPrint(
          '🔍 AppRouter: Redirect check - Is authenticated: $isAuthenticated');
      debugPrint(
          '🔍 AppRouter: Redirect check - Is payment page: $isOnPaymentPage');
      debugPrint(
          '🔍 AppRouter: Redirect check - Is blog page: $isOnBlogPage');
      debugPrint(
          '🔍 AppRouter: Redirect check - Is public page: $isOnPublicPage');

      // Payment sayfaları için hiçbir redirect yapma
      if (isOnPaymentPage) {
        debugPrint('🔍 AppRouter: Payment page detected, no redirect');
        return null;
      }

      // Public sayfalar için redirect yapma
      if (isOnPublicPage) {
        debugPrint('🔍 AppRouter: Public page detected, no redirect');
        return null;
      }

      // Protected sayfalar için authentication kontrolü
      if (!isAuthenticated) {
        debugPrint(
            '🔍 AppRouter: User not authenticated, redirecting to login');
        return '/login';
      }

      debugPrint('🔍 AppRouter: User authenticated, no redirect needed');
      return null;
    },

    // ========== ERROR HANDLING ==========

    /// 404 error handler
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}
