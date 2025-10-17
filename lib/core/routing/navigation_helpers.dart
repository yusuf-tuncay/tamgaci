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

  // ========== ACCOUNTS NAVIGATION ==========

  /// Accounts list'e git
  static void goToAccountsList(BuildContext context) {
    context.goNamed('accounts-list');
  }

  /// Accounts home'e git
  static void goToAccountsHome(BuildContext context) {
    context.goNamed('accounts-home');
  }

  /// Create account'e git
  static void goToCreateAccount(BuildContext context) {
    context.goNamed('create-account');
  }

  /// Account detail'e git
  static void goToAccountDetail(BuildContext context, String accountId) {
    context.goNamed('account-detail', pathParameters: {'id': accountId});
  }

  // ========== SUPPLIERS NAVIGATION ==========

  /// Suppliers list'e git
  static void goToSuppliersList(BuildContext context) {
    context.goNamed('suppliers-list');
  }

  /// Create supplier'e git
  static void goToCreateSupplier(BuildContext context) {
    context.goNamed('create-supplier');
  }

  /// Supplier detail'e git
  static void goToSupplierDetail(BuildContext context, String supplierId) {
    context.goNamed('supplier-detail', pathParameters: {'id': supplierId});
  }

  // ========== PURCHASES NAVIGATION ==========

  /// Purchases list'e git
  static void goToPurchasesList(BuildContext context) {
    context.goNamed('purchases-list');
  }

  /// Create purchase'e git
  static void goToCreatePurchase(BuildContext context) {
    context.goNamed('create-purchase');
  }

  /// Purchase detail'e git
  static void goToPurchaseDetail(BuildContext context, String purchaseId) {
    context.goNamed('purchase-detail', pathParameters: {'id': purchaseId});
  }

  // ========== WAREHOUSE NAVIGATION ==========

  /// Warehouses home'e git
  static void goToWarehousesHome(BuildContext context) {
    context.goNamed('warehouses-home');
  }

  /// Create warehouse'e git
  static void goToCreateWarehouse(BuildContext context) {
    context.goNamed('create-warehouse');
  }

  /// Warehouse detail'e git
  static void goToWarehouseDetail(BuildContext context, String warehouseId) {
    context.goNamed('warehouse-detail', pathParameters: {'id': warehouseId});
  }

  /// Inventory warehouse detail'e git
  static void goToInventoryWarehouseDetail(
      BuildContext context, String warehouseId) {
    context.goNamed('inventory-warehouse-detail',
        pathParameters: {'id': warehouseId});
  }

  // ========== INVENTORY NAVIGATION ==========

  /// Inventory'e git
  static void goToInventory(BuildContext context) {
    context.goNamed('inventory');
  }

  /// Stock list'e git
  static void goToStockList(BuildContext context) {
    context.goNamed('stock-list');
  }

  /// Create stock'e git
  static void goToCreateStock(BuildContext context) {
    context.goNamed('create-stock');
  }

  /// Stock detail'e git
  static void goToStockDetail(BuildContext context, String stockId) {
    context.goNamed('stock-detail', pathParameters: {'id': stockId});
  }

  /// Stock count'e git
  static void goToStockCount(BuildContext context) {
    context.goNamed('stock-count');
  }

  /// Stock counts list'e git
  static void goToStockCountsList(BuildContext context) {
    context.goNamed('stock-counts-list');
  }

  // ========== INVOICES NAVIGATION ==========

  /// Invoices list'e git
  static void goToInvoicesList(BuildContext context) {
    context.goNamed('invoices-list');
  }

  /// Create invoice'e git
  static void goToCreateInvoice(BuildContext context) {
    context.goNamed('create-invoice');
  }
}
