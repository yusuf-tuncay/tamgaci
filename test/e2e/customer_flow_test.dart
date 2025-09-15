import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tamgaci/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Customer Management E2E Tests', () {
    testWidgets('Complete customer lifecycle test',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test 1: Login
      await _testLogin(tester);

      // Test 2: Navigate to customers
      await _testNavigateToCustomers(tester);

      // Test 3: Create new customer
      await _testCreateCustomer(tester);

      // Test 4: View customer details
      await _testViewCustomerDetails(tester);

      // Test 5: Edit customer
      await _testEditCustomer(tester);

      // Test 6: Create sale for customer
      await _testCreateSaleForCustomer(tester);

      // Test 7: View customer transactions
      await _testViewCustomerTransactions(tester);

      // Test 8: Delete customer
      await _testDeleteCustomer(tester);
    });

    testWidgets('Customer search and filter test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _testLogin(tester);
      await _testNavigateToCustomers(tester);

      // Test search functionality
      await _testCustomerSearch(tester);

      // Test filter functionality
      await _testCustomerFilter(tester);

      // Test sorting functionality
      await _testCustomerSorting(tester);
    });

    testWidgets('Customer export test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _testLogin(tester);
      await _testNavigateToCustomers(tester);

      // Test Excel export
      await _testExportCustomersToExcel(tester);

      // Test PDF export
      await _testExportCustomersToPDF(tester);
    });
  });

  group('Product Management E2E Tests', () {
    testWidgets('Complete product lifecycle test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _testLogin(tester);

      // Test 1: Navigate to products
      await _testNavigateToProducts(tester);

      // Test 2: Create new product
      await _testCreateProduct(tester);

      // Test 3: View product details
      await _testViewProductDetails(tester);

      // Test 4: Edit product
      await _testEditProduct(tester);

      // Test 5: Update stock
      await _testUpdateStock(tester);

      // Test 6: Delete product
      await _testDeleteProduct(tester);
    });

    testWidgets('Product search and filter test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _testLogin(tester);
      await _testNavigateToProducts(tester);

      await _testProductSearch(tester);
      await _testProductFilter(tester);
      await _testProductSorting(tester);
    });
  });

  group('Sales Management E2E Tests', () {
    testWidgets('Complete sales flow test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _testLogin(tester);

      // Test 1: Navigate to sales
      await _testNavigateToSales(tester);

      // Test 2: Create new sale
      await _testCreateSale(tester);

      // Test 3: View sale details
      await _testViewSaleDetails(tester);

      // Test 4: Edit sale
      await _testEditSale(tester);

      // Test 5: Add payment
      await _testAddPayment(tester);

      // Test 6: Delete sale
      await _testDeleteSale(tester);
    });
  });

  group('Dashboard E2E Tests', () {
    testWidgets('Dashboard functionality test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _testLogin(tester);

      // Test dashboard loading
      await _testDashboardLoading(tester);

      // Test dashboard metrics
      await _testDashboardMetrics(tester);

      // Test dashboard charts
      await _testDashboardCharts(tester);

      // Test dashboard navigation
      await _testDashboardNavigation(tester);
    });
  });
}

// Helper functions for customer tests
Future<void> _testLogin(WidgetTester tester) async {
  // Find email field
  final emailField = find.byKey(const Key('email_field'));
  expect(emailField, findsOneWidget);

  // Enter email
  await tester.enterText(emailField, 'test@example.com');
  await tester.pumpAndSettle();

  // Find password field
  final passwordField = find.byKey(const Key('password_field'));
  expect(passwordField, findsOneWidget);

  // Enter password
  await tester.enterText(passwordField, 'password123');
  await tester.pumpAndSettle();

  // Find login button
  final loginButton = find.byKey(const Key('login_button'));
  expect(loginButton, findsOneWidget);

  // Tap login button
  await tester.tap(loginButton);
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Verify login success
  expect(find.byKey(const Key('dashboard')), findsOneWidget);
}

Future<void> _testNavigateToCustomers(WidgetTester tester) async {
  // Find customers menu item
  final customersMenu = find.byKey(const Key('customers_menu'));
  expect(customersMenu, findsOneWidget);

  // Tap customers menu
  await tester.tap(customersMenu);
  await tester.pumpAndSettle();

  // Verify customers page loaded
  expect(find.byKey(const Key('customers_page')), findsOneWidget);
}

Future<void> _testCreateCustomer(WidgetTester tester) async {
  // Find add customer button
  final addButton = find.byKey(const Key('add_customer_button'));
  expect(addButton, findsOneWidget);

  // Tap add button
  await tester.tap(addButton);
  await tester.pumpAndSettle();

  // Fill customer form
  await tester.enterText(
      find.byKey(const Key('customer_name_field')), 'Test Customer');
  await tester.enterText(
      find.byKey(const Key('customer_email_field')), 'customer@test.com');
  await tester.enterText(
      find.byKey(const Key('customer_phone_field')), '+905551234567');
  await tester.enterText(
      find.byKey(const Key('customer_address_field')), 'Test Address');
  await tester.enterText(
      find.byKey(const Key('customer_credit_limit_field')), '10000');

  await tester.pumpAndSettle();

  // Save customer
  final saveButton = find.byKey(const Key('save_customer_button'));
  expect(saveButton, findsOneWidget);

  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify customer created
  expect(find.text('Test Customer'), findsOneWidget);
}

Future<void> _testViewCustomerDetails(WidgetTester tester) async {
  // Find customer in list
  final customerTile = find.text('Test Customer');
  expect(customerTile, findsOneWidget);

  // Tap customer
  await tester.tap(customerTile);
  await tester.pumpAndSettle();

  // Verify customer details page
  expect(find.byKey(const Key('customer_details_page')), findsOneWidget);
  expect(find.text('Test Customer'), findsOneWidget);
  expect(find.text('customer@test.com'), findsOneWidget);
}

Future<void> _testEditCustomer(WidgetTester tester) async {
  // Find edit button
  final editButton = find.byKey(const Key('edit_customer_button'));
  expect(editButton, findsOneWidget);

  // Tap edit button
  await tester.tap(editButton);
  await tester.pumpAndSettle();

  // Update customer name
  final nameField = find.byKey(const Key('customer_name_field'));
  await tester.enterText(nameField, 'Updated Customer');
  await tester.pumpAndSettle();

  // Save changes
  final saveButton = find.byKey(const Key('save_customer_button'));
  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify update
  expect(find.text('Updated Customer'), findsOneWidget);
}

Future<void> _testCreateSaleForCustomer(WidgetTester tester) async {
  // Navigate to sales
  final salesMenu = find.byKey(const Key('sales_menu'));
  await tester.tap(salesMenu);
  await tester.pumpAndSettle();

  // Create new sale
  final addSaleButton = find.byKey(const Key('add_sale_button'));
  await tester.tap(addSaleButton);
  await tester.pumpAndSettle();

  // Select customer
  final customerField = find.byKey(const Key('sale_customer_field'));
  await tester.tap(customerField);
  await tester.pumpAndSettle();

  final customerOption = find.text('Updated Customer');
  await tester.tap(customerOption);
  await tester.pumpAndSettle();

  // Add product
  final addProductButton = find.byKey(const Key('add_product_button'));
  await tester.tap(addProductButton);
  await tester.pumpAndSettle();

  // Select product
  final productField = find.byKey(const Key('product_field'));
  await tester.tap(productField);
  await tester.pumpAndSettle();

  final productOption = find.text('Test Product');
  await tester.tap(productOption);
  await tester.pumpAndSettle();

  // Enter quantity
  final quantityField = find.byKey(const Key('quantity_field'));
  await tester.enterText(quantityField, '2');
  await tester.pumpAndSettle();

  // Save sale
  final saveSaleButton = find.byKey(const Key('save_sale_button'));
  await tester.tap(saveSaleButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify sale created
  expect(find.text('Updated Customer'), findsOneWidget);
}

Future<void> _testViewCustomerTransactions(WidgetTester tester) async {
  // Navigate back to customers
  final customersMenu = find.byKey(const Key('customers_menu'));
  await tester.tap(customersMenu);
  await tester.pumpAndSettle();

  // Open customer details
  final customerTile = find.text('Updated Customer');
  await tester.tap(customerTile);
  await tester.pumpAndSettle();

  // Navigate to transactions tab
  final transactionsTab = find.byKey(const Key('transactions_tab'));
  await tester.tap(transactionsTab);
  await tester.pumpAndSettle();

  // Verify transactions
  expect(find.byKey(const Key('transactions_list')), findsOneWidget);
}

Future<void> _testDeleteCustomer(WidgetTester tester) async {
  // Find delete button
  final deleteButton = find.byKey(const Key('delete_customer_button'));
  expect(deleteButton, findsOneWidget);

  // Tap delete button
  await tester.tap(deleteButton);
  await tester.pumpAndSettle();

  // Confirm deletion
  final confirmButton = find.byKey(const Key('confirm_delete_button'));
  expect(confirmButton, findsOneWidget);

  await tester.tap(confirmButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify customer deleted
  expect(find.text('Updated Customer'), findsNothing);
}

Future<void> _testCustomerSearch(WidgetTester tester) async {
  // Find search field
  final searchField = find.byKey(const Key('customer_search_field'));
  expect(searchField, findsOneWidget);

  // Enter search term
  await tester.enterText(searchField, 'Test');
  await tester.pumpAndSettle();

  // Verify search results
  expect(find.text('Test Customer'), findsOneWidget);
}

Future<void> _testCustomerFilter(WidgetTester tester) async {
  // Find filter button
  final filterButton = find.byKey(const Key('customer_filter_button'));
  expect(filterButton, findsOneWidget);

  // Tap filter button
  await tester.tap(filterButton);
  await tester.pumpAndSettle();

  // Select filter option
  final filterOption = find.text('Active Customers');
  await tester.tap(filterOption);
  await tester.pumpAndSettle();

  // Apply filter
  final applyButton = find.byKey(const Key('apply_filter_button'));
  await tester.tap(applyButton);
  await tester.pumpAndSettle();

  // Verify filter applied
  expect(find.byKey(const Key('filtered_customers')), findsOneWidget);
}

Future<void> _testCustomerSorting(WidgetTester tester) async {
  // Find sort button
  final sortButton = find.byKey(const Key('customer_sort_button'));
  expect(sortButton, findsOneWidget);

  // Tap sort button
  await tester.tap(sortButton);
  await tester.pumpAndSettle();

  // Select sort option
  final sortOption = find.text('Sort by Name');
  await tester.tap(sortOption);
  await tester.pumpAndSettle();

  // Verify sorting applied
  expect(find.byKey(const Key('sorted_customers')), findsOneWidget);
}

Future<void> _testExportCustomersToExcel(WidgetTester tester) async {
  // Find export button
  final exportButton = find.byKey(const Key('export_customers_button'));
  expect(exportButton, findsOneWidget);

  // Tap export button
  await tester.tap(exportButton);
  await tester.pumpAndSettle();

  // Select Excel format
  final excelOption = find.text('Export to Excel');
  await tester.tap(excelOption);
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Verify export success
  expect(find.text('Export completed successfully'), findsOneWidget);
}

Future<void> _testExportCustomersToPDF(WidgetTester tester) async {
  // Find export button
  final exportButton = find.byKey(const Key('export_customers_button'));
  expect(exportButton, findsOneWidget);

  // Tap export button
  await tester.tap(exportButton);
  await tester.pumpAndSettle();

  // Select PDF format
  final pdfOption = find.text('Export to PDF');
  await tester.tap(pdfOption);
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Verify export success
  expect(find.text('Export completed successfully'), findsOneWidget);
}

// Helper functions for product tests
Future<void> _testNavigateToProducts(WidgetTester tester) async {
  final productsMenu = find.byKey(const Key('products_menu'));
  expect(productsMenu, findsOneWidget);

  await tester.tap(productsMenu);
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('products_page')), findsOneWidget);
}

Future<void> _testCreateProduct(WidgetTester tester) async {
  final addButton = find.byKey(const Key('add_product_button'));
  expect(addButton, findsOneWidget);

  await tester.tap(addButton);
  await tester.pumpAndSettle();

  await tester.enterText(
      find.byKey(const Key('product_code_field')), 'TEST001');
  await tester.enterText(
      find.byKey(const Key('product_name_field')), 'Test Product');
  await tester.enterText(
      find.byKey(const Key('product_category_field')), 'Test Category');
  await tester.enterText(find.byKey(const Key('product_unit_field')), 'Adet');
  await tester.enterText(
      find.byKey(const Key('product_purchase_price_field')), '50.00');
  await tester.enterText(
      find.byKey(const Key('product_sale_price_field')), '100.00');
  await tester.enterText(find.byKey(const Key('product_stock_field')), '100');
  await tester.enterText(
      find.byKey(const Key('product_min_stock_field')), '10');

  await tester.pumpAndSettle();

  final saveButton = find.byKey(const Key('save_product_button'));
  expect(saveButton, findsOneWidget);

  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.text('Test Product'), findsOneWidget);
}

Future<void> _testViewProductDetails(WidgetTester tester) async {
  final productTile = find.text('Test Product');
  expect(productTile, findsOneWidget);

  await tester.tap(productTile);
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('product_details_page')), findsOneWidget);
  expect(find.text('Test Product'), findsOneWidget);
  expect(find.text('TEST001'), findsOneWidget);
}

Future<void> _testEditProduct(WidgetTester tester) async {
  final editButton = find.byKey(const Key('edit_product_button'));
  expect(editButton, findsOneWidget);

  await tester.tap(editButton);
  await tester.pumpAndSettle();

  final nameField = find.byKey(const Key('product_name_field'));
  await tester.enterText(nameField, 'Updated Product');
  await tester.pumpAndSettle();

  final saveButton = find.byKey(const Key('save_product_button'));
  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.text('Updated Product'), findsOneWidget);
}

Future<void> _testUpdateStock(WidgetTester tester) async {
  final updateStockButton = find.byKey(const Key('update_stock_button'));
  expect(updateStockButton, findsOneWidget);

  await tester.tap(updateStockButton);
  await tester.pumpAndSettle();

  final stockField = find.byKey(const Key('stock_quantity_field'));
  await tester.enterText(stockField, '150');
  await tester.pumpAndSettle();

  final saveStockButton = find.byKey(const Key('save_stock_button'));
  await tester.tap(saveStockButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.text('150'), findsOneWidget);
}

Future<void> _testDeleteProduct(WidgetTester tester) async {
  final deleteButton = find.byKey(const Key('delete_product_button'));
  expect(deleteButton, findsOneWidget);

  await tester.tap(deleteButton);
  await tester.pumpAndSettle();

  final confirmButton = find.byKey(const Key('confirm_delete_button'));
  expect(confirmButton, findsOneWidget);

  await tester.tap(confirmButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.text('Updated Product'), findsNothing);
}

Future<void> _testProductSearch(WidgetTester tester) async {
  final searchField = find.byKey(const Key('product_search_field'));
  expect(searchField, findsOneWidget);

  await tester.enterText(searchField, 'Test');
  await tester.pumpAndSettle();

  expect(find.text('Test Product'), findsOneWidget);
}

Future<void> _testProductFilter(WidgetTester tester) async {
  final filterButton = find.byKey(const Key('product_filter_button'));
  expect(filterButton, findsOneWidget);

  await tester.tap(filterButton);
  await tester.pumpAndSettle();

  final filterOption = find.text('Test Category');
  await tester.tap(filterOption);
  await tester.pumpAndSettle();

  final applyButton = find.byKey(const Key('apply_filter_button'));
  await tester.tap(applyButton);
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('filtered_products')), findsOneWidget);
}

Future<void> _testProductSorting(WidgetTester tester) async {
  final sortButton = find.byKey(const Key('product_sort_button'));
  expect(sortButton, findsOneWidget);

  await tester.tap(sortButton);
  await tester.pumpAndSettle();

  final sortOption = find.text('Sort by Name');
  await tester.tap(sortOption);
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('sorted_products')), findsOneWidget);
}

// Helper functions for sales tests
Future<void> _testNavigateToSales(WidgetTester tester) async {
  final salesMenu = find.byKey(const Key('sales_menu'));
  expect(salesMenu, findsOneWidget);

  await tester.tap(salesMenu);
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('sales_page')), findsOneWidget);
}

Future<void> _testCreateSale(WidgetTester tester) async {
  final addButton = find.byKey(const Key('add_sale_button'));
  expect(addButton, findsOneWidget);

  await tester.tap(addButton);
  await tester.pumpAndSettle();

  final customerField = find.byKey(const Key('sale_customer_field'));
  await tester.tap(customerField);
  await tester.pumpAndSettle();

  final customerOption = find.text('Test Customer');
  await tester.tap(customerOption);
  await tester.pumpAndSettle();

  final addProductButton = find.byKey(const Key('add_product_button'));
  await tester.tap(addProductButton);
  await tester.pumpAndSettle();

  final productField = find.byKey(const Key('product_field'));
  await tester.tap(productField);
  await tester.pumpAndSettle();

  final productOption = find.text('Test Product');
  await tester.tap(productOption);
  await tester.pumpAndSettle();

  final quantityField = find.byKey(const Key('quantity_field'));
  await tester.enterText(quantityField, '1');
  await tester.pumpAndSettle();

  final saveButton = find.byKey(const Key('save_sale_button'));
  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.text('Test Customer'), findsOneWidget);
}

Future<void> _testViewSaleDetails(WidgetTester tester) async {
  final saleTile = find.text('Test Customer');
  expect(saleTile, findsOneWidget);

  await tester.tap(saleTile);
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('sale_details_page')), findsOneWidget);
  expect(find.text('Test Customer'), findsOneWidget);
}

Future<void> _testEditSale(WidgetTester tester) async {
  final editButton = find.byKey(const Key('edit_sale_button'));
  expect(editButton, findsOneWidget);

  await tester.tap(editButton);
  await tester.pumpAndSettle();

  final quantityField = find.byKey(const Key('quantity_field'));
  await tester.enterText(quantityField, '2');
  await tester.pumpAndSettle();

  final saveButton = find.byKey(const Key('save_sale_button'));
  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.text('2'), findsOneWidget);
}

Future<void> _testAddPayment(WidgetTester tester) async {
  final addPaymentButton = find.byKey(const Key('add_payment_button'));
  expect(addPaymentButton, findsOneWidget);

  await tester.tap(addPaymentButton);
  await tester.pumpAndSettle();

  final amountField = find.byKey(const Key('payment_amount_field'));
  await tester.enterText(amountField, '100.00');
  await tester.pumpAndSettle();

  final savePaymentButton = find.byKey(const Key('save_payment_button'));
  await tester.tap(savePaymentButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.text('100.00'), findsOneWidget);
}

Future<void> _testDeleteSale(WidgetTester tester) async {
  final deleteButton = find.byKey(const Key('delete_sale_button'));
  expect(deleteButton, findsOneWidget);

  await tester.tap(deleteButton);
  await tester.pumpAndSettle();

  final confirmButton = find.byKey(const Key('confirm_delete_button'));
  expect(confirmButton, findsOneWidget);

  await tester.tap(confirmButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.text('Test Customer'), findsNothing);
}

// Helper functions for dashboard tests
Future<void> _testDashboardLoading(WidgetTester tester) async {
  expect(find.byKey(const Key('dashboard')), findsOneWidget);
  expect(find.byKey(const Key('dashboard_loading')), findsOneWidget);

  await tester.pumpAndSettle(const Duration(seconds: 3));

  expect(find.byKey(const Key('dashboard_loading')), findsNothing);
  expect(find.byKey(const Key('dashboard_content')), findsOneWidget);
}

Future<void> _testDashboardMetrics(WidgetTester tester) async {
  expect(find.byKey(const Key('total_sales_metric')), findsOneWidget);
  expect(find.byKey(const Key('total_customers_metric')), findsOneWidget);
  expect(find.byKey(const Key('total_products_metric')), findsOneWidget);
  expect(find.byKey(const Key('low_stock_metric')), findsOneWidget);
}

Future<void> _testDashboardCharts(WidgetTester tester) async {
  expect(find.byKey(const Key('sales_chart')), findsOneWidget);
  expect(find.byKey(const Key('purchase_chart')), findsOneWidget);
  expect(find.byKey(const Key('profit_chart')), findsOneWidget);
}

Future<void> _testDashboardNavigation(WidgetTester tester) async {
  final customersMenu = find.byKey(const Key('customers_menu'));
  expect(customersMenu, findsOneWidget);

  await tester.tap(customersMenu);
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('customers_page')), findsOneWidget);

  // Navigate back to dashboard
  final dashboardMenu = find.byKey(const Key('dashboard_menu'));
  await tester.tap(dashboardMenu);
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('dashboard')), findsOneWidget);
}
