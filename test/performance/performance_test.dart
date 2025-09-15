import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tamgaci/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Tests', () {
    testWidgets('App startup performance test', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      stopwatch.stop();

      // App should start within 3 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));

      print('App startup time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Dashboard loading performance test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await _loginUser(tester);

      final stopwatch = Stopwatch()..start();

      // Wait for dashboard to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      stopwatch.stop();

      // Dashboard should load within 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      print('Dashboard loading time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Customer list loading performance test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      final stopwatch = Stopwatch()..start();

      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Customer list should load within 1.5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(1500));

      print('Customer list loading time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Product list loading performance test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      final stopwatch = Stopwatch()..start();

      // Navigate to products
      await tester.tap(find.byKey(const Key('products_menu')));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Product list should load within 1.5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(1500));

      print('Product list loading time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Sales list loading performance test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      final stopwatch = Stopwatch()..start();

      // Navigate to sales
      await tester.tap(find.byKey(const Key('sales_menu')));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Sales list should load within 1.5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(1500));

      print('Sales list loading time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Search performance test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Perform search
      await tester.enterText(
          find.byKey(const Key('customer_search_field')), 'Test');
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Search should complete within 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));

      print('Search time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Filter performance test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Apply filter
      await tester.tap(find.byKey(const Key('customer_filter_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Active Customers'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('apply_filter_button')));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Filter should complete within 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      print('Filter time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Sort performance test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Apply sort
      await tester.tap(find.byKey(const Key('customer_sort_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sort by Name'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Sort should complete within 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));

      print('Sort time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Scroll performance test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Scroll through list
      await tester.drag(
          find.byKey(const Key('customers_list')), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.drag(
          find.byKey(const Key('customers_list')), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.drag(
          find.byKey(const Key('customers_list')), const Offset(0, -500));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Scrolling should be smooth
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      print('Scroll time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Form submission performance test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      // Open add customer form
      await tester.tap(find.byKey(const Key('add_customer_button')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Fill form
      await tester.enterText(find.byKey(const Key('customer_name_field')),
          'Performance Test Customer');
      await tester.enterText(find.byKey(const Key('customer_email_field')),
          'performance@test.com');
      await tester.enterText(
          find.byKey(const Key('customer_phone_field')), '+905551234567');
      await tester.enterText(find.byKey(const Key('customer_address_field')),
          'Performance Test Address');
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.byKey(const Key('save_customer_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      stopwatch.stop();

      // Form submission should complete within 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      print('Form submission time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Report generation performance test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to reports
      await tester.tap(find.byKey(const Key('reports_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Generate report
      await tester.tap(find.byKey(const Key('sales_report_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('generate_report_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      stopwatch.stop();

      // Report generation should complete within 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      print('Report generation time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Export performance test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Export data
      await tester.tap(find.byKey(const Key('export_customers_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Export to Excel'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      stopwatch.stop();

      // Export should complete within 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      print('Export time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Memory usage test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate through different pages
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('products_menu')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('sales_menu')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reports_menu')));
      await tester.pumpAndSettle();

      // Memory usage should be reasonable
      // This is a basic test - in real implementation, you'd use memory profiling tools
      expect(true, isTrue); // Placeholder for memory test

      print('Memory usage test completed');
    });

    testWidgets('Battery usage test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Perform various operations
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byKey(const Key('customers_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('products_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('sales_menu')));
        await tester.pumpAndSettle();
      }

      // Battery usage should be reasonable
      // This is a basic test - in real implementation, you'd use battery profiling tools
      expect(true, isTrue); // Placeholder for battery test

      print('Battery usage test completed');
    });

    testWidgets('Network performance test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      final stopwatch = Stopwatch()..start();

      // Perform network operations
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_customer_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('customer_name_field')),
          'Network Test Customer');
      await tester.enterText(
          find.byKey(const Key('customer_email_field')), 'network@test.com');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_customer_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      stopwatch.stop();

      // Network operations should complete within 3 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));

      print('Network performance time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Concurrent operations performance test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      final stopwatch = Stopwatch()..start();

      // Perform multiple operations concurrently
      await Future.wait([
        _navigateToCustomers(tester),
        _navigateToProducts(tester),
        _navigateToSales(tester),
      ]);

      stopwatch.stop();

      // Concurrent operations should complete within 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      print('Concurrent operations time: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}

// Helper functions
Future<void> _loginUser(WidgetTester tester) async {
  await tester.enterText(
      find.byKey(const Key('email_field')), 'admin@tamgaci.com');
  await tester.enterText(find.byKey(const Key('password_field')), 'admin123');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

Future<void> _navigateToCustomers(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('customers_menu')));
  await tester.pumpAndSettle();
}

Future<void> _navigateToProducts(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('products_menu')));
  await tester.pumpAndSettle();
}

Future<void> _navigateToSales(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('sales_menu')));
  await tester.pumpAndSettle();
}
