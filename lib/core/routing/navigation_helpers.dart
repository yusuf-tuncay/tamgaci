// ========== GO ROUTER NAVIGATION HELPERS ==========
// lib/core/routing/navigation_helpers.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Go Router navigation helper methods
class NavigationHelpers {
  // ========== BASIC NAVIGATION ==========

  /// Push navigation - Yeni sayfa ekler
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return context.pushNamed<T>(routeName, extra: arguments);
  }

  /// Push replacement - Mevcut sayfayı değiştirir
  static Future<T?> pushReplacementNamed<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    context.goNamed(routeName, extra: arguments);
    return Future.value(null);
  }

  /// Push and remove until - Tüm geçmişi temizleyerek yeni sayfa
  static Future<T?> pushNamedAndClearAll<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    context.goNamed(routeName, extra: arguments);
    return Future.value(null);
  }

  /// Pop navigation - Geri git
  static void pop<T>(BuildContext context, [T? result]) {
    context.pop<T>(result);
  }

  /// Pop until - Belirli sayfaya kadar geri git
  static void popUntil(BuildContext context, String routeName) {
    context.goNamed(routeName);
  }

  // ========== ROUTE-SPECIFIC NAVIGATION ==========

  /// Dashboard'a git
  static void goToDashboard(BuildContext context) {
    context.goNamed('dashboard');
  }

  /// Login'e git
  static void goToLogin(BuildContext context) {
    context.goNamed('login');
  }

  /// Landing page'e git
  static void goToLanding(BuildContext context) {
    context.goNamed('landing');
  }

  /// Settings'e git
  static void goToSettings(BuildContext context) {
    context.goNamed('settings');
  }

  /// Profile'e git
  static void goToProfile(BuildContext context) {
    context.goNamed('profile');
  }

  /// Subscription'a git
  static void goToSubscription(BuildContext context) {
    context.goNamed('subscription');
  }

  // ========== SALES NAVIGATION ==========

  /// Sales list'e git
  static void goToSalesList(BuildContext context) {
    context.goNamed('sales-list');
  }

  /// Create sale'e git
  static void goToCreateSale(BuildContext context) {
    context.goNamed('create-sale');
  }

  /// Sale detail'e git
  static void goToSaleDetail(BuildContext context, String saleId) {
    context.goNamed('sale-detail', pathParameters: {'id': saleId});
  }

  // ========== CUSTOMERS NAVIGATION ==========

  /// Customers list'e git
  static void goToCustomersList(BuildContext context) {
    context.goNamed('customers-list');
  }

  /// Create customer'e git
  static void goToCreateCustomer(BuildContext context) {
    context.goNamed('create-customer');
  }

  /// Customer detail'e git
  static void goToCustomerDetail(BuildContext context, String customerId) {
    context.goNamed('customer-detail', pathParameters: {'id': customerId});
  }

  // ========== PRODUCTS NAVIGATION ==========

  /// Products list'e git
  static void goToProductsList(BuildContext context) {
    context.goNamed('products-list');
  }

  /// Create product'e git
  static void goToCreateProduct(BuildContext context) {
    context.goNamed('create-product');
  }

  /// Product detail'e git
  static void goToProductDetail(BuildContext context, String productId) {
    context.goNamed('product-detail', pathParameters: {'id': productId});
  }

  // ========== REPORTS NAVIGATION ==========

  /// Reports overview'e git
  static void goToReportsOverview(BuildContext context) {
    context.goNamed('reports-overview');
  }

  /// Income expense report'e git
  static void goToIncomeExpenseReport(BuildContext context) {
    context.goNamed('income-expense-report');
  }

  /// Customer report'e git
  static void goToCustomerReport(BuildContext context) {
    context.goNamed('customer-report');
  }

  // ========== PAYMENT NAVIGATION ==========

  /// Payment success'e git
  static void goToPaymentSuccess(BuildContext context) {
    context.goNamed('payment-success');
  }

  /// Payment fail'e git
  static void goToPaymentFail(BuildContext context) {
    context.goNamed('payment-fail');
  }
}
