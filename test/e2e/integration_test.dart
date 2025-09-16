import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tamgaci/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tamgaci Integration Tests', () {
    testWidgets('Complete application flow test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test complete user journey
      await _testCompleteUserJourney(tester);
    });

    testWidgets('Data persistence test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _testDataPersistence(tester);
    });

    testWidgets('Offline functionality test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _testOfflineFunctionality(tester);
    });

    testWidgets('Error handling test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _testErrorHandling(tester);
    });

    testWidgets('Performance test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _testPerformance(tester);
    });
  });
}

Future<void> _testCompleteUserJourney(WidgetTester tester) async {
  // 1. Login
  await _loginUser(tester);

  // 2. Dashboard overview
  await _testDashboardOverview(tester);

  // 3. Customer management
  await _testCustomerManagement(tester);

  // 4. Product management
  await _testProductManagement(tester);

  // 5. Sales process
  await _testSalesProcess(tester);

  // 6. Reports generation
  await _testReportsGeneration(tester);

  // 7. Settings update
  await _testSettingsUpdate(tester);

  // 8. Logout
  await _testLogout(tester);
}

Future<void> _loginUser(WidgetTester tester) async {
  // Wait for login screen
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('login_screen')), findsOneWidget);

  // Enter credentials
  await tester.enterText(
      find.byKey(const Key('email_field')), 'admin@tamgaci.com');
  await tester.enterText(find.byKey(const Key('password_field')), 'admin123');
  await tester.pumpAndSettle();

  // Tap login
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Verify login success
  expect(find.byKey(const Key('dashboard')), findsOneWidget);
}

Future<void> _testDashboardOverview(WidgetTester tester) async {
  // Wait for dashboard to load
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Check dashboard elements
  expect(find.byKey(const Key('dashboard')), findsOneWidget);
  expect(find.byKey(const Key('total_sales_metric')), findsOneWidget);
  expect(find.byKey(const Key('total_customers_metric')), findsOneWidget);
  expect(find.byKey(const Key('total_products_metric')), findsOneWidget);

  // Check navigation menu
  expect(find.byKey(const Key('navigation_drawer')), findsOneWidget);
  expect(find.byKey(const Key('customers_menu')), findsOneWidget);
  expect(find.byKey(const Key('products_menu')), findsOneWidget);
  expect(find.byKey(const Key('sales_menu')), findsOneWidget);
}

Future<void> _testCustomerManagement(WidgetTester tester) async {
  // Navigate to customers
  await tester.tap(find.byKey(const Key('customers_menu')));
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('customers_page')), findsOneWidget);

  // Create customer
  await tester.tap(find.byKey(const Key('add_customer_button')));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('customer_name_field')),
      'Integration Test Customer');
  await tester.enterText(
      find.byKey(const Key('customer_email_field')), 'integration@test.com');
  await tester.enterText(
      find.byKey(const Key('customer_phone_field')), '+905551234567');
  await tester.enterText(find.byKey(const Key('customer_address_field')),
      'Integration Test Address');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_customer_button')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify customer created
  expect(find.text('Integration Test Customer'), findsOneWidget);

  // Edit customer
  await tester.tap(find.text('Integration Test Customer'));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('edit_customer_button')));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('customer_name_field')),
      'Updated Integration Customer');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_customer_button')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify customer updated
  expect(find.text('Updated Integration Customer'), findsOneWidget);
}

Future<void> _testProductManagement(WidgetTester tester) async {
  // Navigate to products
  await tester.tap(find.byKey(const Key('products_menu')));
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('products_page')), findsOneWidget);

  // Create product
  await tester.tap(find.byKey(const Key('add_product_button')));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('product_code_field')), 'INT001');
  await tester.enterText(
      find.byKey(const Key('product_name_field')), 'Integration Test Product');
  await tester.enterText(
      find.byKey(const Key('product_category_field')), 'Integration Category');
  await tester.enterText(find.byKey(const Key('product_unit_field')), 'Adet');
  await tester.enterText(
      find.byKey(const Key('product_purchase_price_field')), '50.00');
  await tester.enterText(
      find.byKey(const Key('product_sale_price_field')), '100.00');
  await tester.enterText(find.byKey(const Key('product_stock_field')), '100');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_product_button')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify product created
  expect(find.text('Integration Test Product'), findsOneWidget);

  // Update stock
  await tester.tap(find.text('Integration Test Product'));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('update_stock_button')));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('stock_quantity_field')), '150');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_stock_button')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify stock updated
  expect(find.text('150'), findsOneWidget);
}

Future<void> _testSalesProcess(WidgetTester tester) async {
  // Navigate to sales
  await tester.tap(find.byKey(const Key('sales_menu')));
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('sales_page')), findsOneWidget);

  // Create sale
  await tester.tap(find.byKey(const Key('add_sale_button')));
  await tester.pumpAndSettle();

  // Select customer
  await tester.tap(find.byKey(const Key('sale_customer_field')));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Updated Integration Customer'));
  await tester.pumpAndSettle();

  // Add product
  await tester.tap(find.byKey(const Key('add_product_button')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('product_field')));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Integration Test Product'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('quantity_field')), '2');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_sale_button')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify sale created
  expect(find.text('Updated Integration Customer'), findsOneWidget);

  // Add payment
  await tester.tap(find.text('Updated Integration Customer'));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('add_payment_button')));
  await tester.pumpAndSettle();

  await tester.enterText(
      find.byKey(const Key('payment_amount_field')), '200.00');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_payment_button')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify payment added
  expect(find.text('200.00'), findsOneWidget);
}

Future<void> _testReportsGeneration(WidgetTester tester) async {
  // Navigate to reports
  await tester.tap(find.byKey(const Key('reports_menu')));
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('reports_page')), findsOneWidget);

  // Generate sales report
  await tester.tap(find.byKey(const Key('sales_report_button')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('generate_report_button')));
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Verify report generated
  expect(find.byKey(const Key('report_content')), findsOneWidget);

  // Export report
  await tester.tap(find.byKey(const Key('export_report_button')));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Export to Excel'));
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Verify export success
  expect(find.text('Export completed successfully'), findsOneWidget);
}

Future<void> _testSettingsUpdate(WidgetTester tester) async {
  // Navigate to settings
  await tester.tap(find.byKey(const Key('settings_menu')));
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('settings_page')), findsOneWidget);

  // Update company settings
  await tester.tap(find.byKey(const Key('company_settings_button')));
  await tester.pumpAndSettle();

  await tester.enterText(
      find.byKey(const Key('company_name_field')), 'Updated Company Name');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_settings_button')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify settings updated
  expect(find.text('Updated Company Name'), findsOneWidget);
}

Future<void> _testLogout(WidgetTester tester) async {
  // Navigate to profile
  await tester.tap(find.byKey(const Key('profile_menu')));
  await tester.pumpAndSettle();

  // Logout
  await tester.tap(find.byKey(const Key('logout_button')));
  await tester.pumpAndSettle();

  // Confirm logout
  await tester.tap(find.byKey(const Key('confirm_logout_button')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify logout success
  expect(find.byKey(const Key('login_screen')), findsOneWidget);
}

Future<void> _testDataPersistence(WidgetTester tester) async {
  // Login
  await _loginUser(tester);

  // Create test data
  await tester.tap(find.byKey(const Key('customers_menu')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('add_customer_button')));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('customer_name_field')),
      'Persistence Test Customer');
  await tester.enterText(
      find.byKey(const Key('customer_email_field')), 'persistence@test.com');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_customer_button')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Restart app
  app.main();
  await tester.pumpAndSettle();

  // Login again
  await _loginUser(tester);

  // Verify data persisted
  await tester.tap(find.byKey(const Key('customers_menu')));
  await tester.pumpAndSettle();

  expect(find.text('Persistence Test Customer'), findsOneWidget);
}

Future<void> _testOfflineFunctionality(WidgetTester tester) async {
  // Login
  await _loginUser(tester);

  // Simulate offline mode
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('flutter/platform'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'SystemChrome.setEnabledSystemUIMode') {
        return null;
      }
      return null;
    },
  );

  // Test offline functionality
  await tester.tap(find.byKey(const Key('customers_menu')));
  await tester.pumpAndSettle();

  // Should show cached data
  expect(find.byKey(const Key('customers_page')), findsOneWidget);
  expect(find.byKey(const Key('offline_indicator')), findsOneWidget);
}

Future<void> _testErrorHandling(WidgetTester tester) async {
  // Login
  await _loginUser(tester);

  // Test invalid data entry
  await tester.tap(find.byKey(const Key('customers_menu')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('add_customer_button')));
  await tester.pumpAndSettle();

  // Enter invalid email
  await tester.enterText(
      find.byKey(const Key('customer_name_field')), 'Error Test Customer');
  await tester.enterText(
      find.byKey(const Key('customer_email_field')), 'invalid-email');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_customer_button')));
  await tester.pumpAndSettle();

  // Should show error message
  expect(find.text('Invalid email format'), findsOneWidget);

  // Test network error
  await tester.enterText(
      find.byKey(const Key('customer_email_field')), 'test@example.com');
  await tester.pumpAndSettle();

  // Simulate network error
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('flutter/platform'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'SystemChrome.setEnabledSystemUIMode') {
        throw PlatformException(code: 'NETWORK_ERROR');
      }
      return null;
    },
  );

  await tester.tap(find.byKey(const Key('save_customer_button')));
  await tester.pumpAndSettle();

  // Should show network error message
  expect(find.text('Network error occurred'), findsOneWidget);
}

Future<void> _testPerformance(WidgetTester tester) async {
  // Login
  await _loginUser(tester);

  // Test dashboard loading performance
  final stopwatch = Stopwatch()..start();

  await tester.tap(find.byKey(const Key('customers_menu')));
  await tester.pumpAndSettle();

  stopwatch.stop();

  // Dashboard should load within 2 seconds
  expect(stopwatch.elapsedMilliseconds, lessThan(2000));

  // Test list scrolling performance
  stopwatch.reset();
  stopwatch.start();

  // Scroll through customer list
  await tester.drag(
      find.byKey(const Key('customers_list')), const Offset(0, -500));
  await tester.pumpAndSettle();

  stopwatch.stop();

  // Scrolling should be smooth
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));

  // Test search performance
  stopwatch.reset();
  stopwatch.start();

  await tester.enterText(
      find.byKey(const Key('customer_search_field')), 'Test');
  await tester.pumpAndSettle();

  stopwatch.stop();

  // Search should be fast
  expect(stopwatch.elapsedMilliseconds, lessThan(500));
}
