import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tamgaci/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Load Tests', () {
    testWidgets('High volume customer creation test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Create 50 customers
      for (int i = 0; i < 50; i++) {
        await tester.tap(find.byKey(const Key('add_customer_button')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('customer_name_field')),
            'Load Test Customer $i');
        await tester.enterText(find.byKey(const Key('customer_email_field')),
            'loadtest$i@example.com');
        await tester.enterText(
            find.byKey(const Key('customer_phone_field')), '+905551234$i');
        await tester.enterText(find.byKey(const Key('customer_address_field')),
            'Load Test Address $i');
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_customer_button')));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      stopwatch.stop();

      // Should complete within 60 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(60000));

      print(
          'High volume customer creation time: ${stopwatch.elapsedMilliseconds}ms');
      print(
          'Average time per customer: ${stopwatch.elapsedMilliseconds / 50}ms');
    });

    testWidgets('High volume product creation test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to products
      await tester.tap(find.byKey(const Key('products_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Create 100 products
      for (int i = 0; i < 100; i++) {
        await tester.tap(find.byKey(const Key('add_product_button')));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.byKey(const Key('product_code_field')), 'LOAD$i');
        await tester.enterText(find.byKey(const Key('product_name_field')),
            'Load Test Product $i');
        await tester.enterText(find.byKey(const Key('product_category_field')),
            'Load Test Category');
        await tester.enterText(
            find.byKey(const Key('product_unit_field')), 'Adet');
        await tester.enterText(
            find.byKey(const Key('product_purchase_price_field')),
            '${50 + i}.00');
        await tester.enterText(
            find.byKey(const Key('product_sale_price_field')), '${100 + i}.00');
        await tester.enterText(
            find.byKey(const Key('product_stock_field')), '${100 + i}');
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_product_button')));
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
      }

      stopwatch.stop();

      // Should complete within 90 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(90000));

      print(
          'High volume product creation time: ${stopwatch.elapsedMilliseconds}ms');
      print(
          'Average time per product: ${stopwatch.elapsedMilliseconds / 100}ms');
    });

    testWidgets('High volume sales creation test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to sales
      await tester.tap(find.byKey(const Key('sales_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Create 25 sales
      for (int i = 0; i < 25; i++) {
        await tester.tap(find.byKey(const Key('add_sale_button')));
        await tester.pumpAndSettle();

        // Select customer
        await tester.tap(find.byKey(const Key('sale_customer_field')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Load Test Customer $i'));
        await tester.pumpAndSettle();

        // Add product
        await tester.tap(find.byKey(const Key('add_product_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('product_field')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Load Test Product $i'));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.byKey(const Key('quantity_field')), '${i + 1}');
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_sale_button')));
        await tester.pumpAndSettle(const Duration(milliseconds: 800));
      }

      stopwatch.stop();

      // Should complete within 120 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(120000));

      print(
          'High volume sales creation time: ${stopwatch.elapsedMilliseconds}ms');
      print('Average time per sale: ${stopwatch.elapsedMilliseconds / 25}ms');
    });

    testWidgets('Large dataset search performance test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Perform multiple searches
      final searchTerms = [
        'Load',
        'Test',
        'Customer',
        'Load Test',
        'Test Customer'
      ];

      for (final term in searchTerms) {
        await tester.enterText(
            find.byKey(const Key('customer_search_field')), term);
        await tester.pumpAndSettle();

        // Clear search
        await tester.enterText(
            find.byKey(const Key('customer_search_field')), '');
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // Should complete within 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      print('Large dataset search time: ${stopwatch.elapsedMilliseconds}ms');
      print(
          'Average time per search: ${stopwatch.elapsedMilliseconds / searchTerms.length}ms');
    });

    testWidgets('Large dataset filter performance test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Apply multiple filters
      final filters = [
        'Active Customers',
        'Inactive Customers',
        'All Customers'
      ];

      for (final filter in filters) {
        await tester.tap(find.byKey(const Key('customer_filter_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.text(filter));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('apply_filter_button')));
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // Should complete within 8 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(8000));

      print('Large dataset filter time: ${stopwatch.elapsedMilliseconds}ms');
      print(
          'Average time per filter: ${stopwatch.elapsedMilliseconds / filters.length}ms');
    });

    testWidgets('Large dataset sort performance test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Apply multiple sorts
      final sorts = [
        'Sort by Name',
        'Sort by Email',
        'Sort by Phone',
        'Sort by Date'
      ];

      for (final sort in sorts) {
        await tester.tap(find.byKey(const Key('customer_sort_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.text(sort));
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // Should complete within 6 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(6000));

      print('Large dataset sort time: ${stopwatch.elapsedMilliseconds}ms');
      print(
          'Average time per sort: ${stopwatch.elapsedMilliseconds / sorts.length}ms');
    });

    testWidgets('Large dataset scroll performance test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Scroll through large dataset
      for (int i = 0; i < 20; i++) {
        await tester.drag(
            find.byKey(const Key('customers_list')), const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // Should complete within 10 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));

      print('Large dataset scroll time: ${stopwatch.elapsedMilliseconds}ms');
      print('Average time per scroll: ${stopwatch.elapsedMilliseconds / 20}ms');
    });

    testWidgets('Concurrent user operations test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      final stopwatch = Stopwatch()..start();

      // Simulate concurrent operations
      final operations = <Future<void>>[];

      for (int i = 0; i < 10; i++) {
        operations.add(_simulateUserOperation(tester, i));
      }

      await Future.wait(operations);

      stopwatch.stop();

      // Should complete within 30 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(30000));

      print(
          'Concurrent user operations time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Memory stress test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      final stopwatch = Stopwatch()..start();

      // Perform memory-intensive operations
      for (int i = 0; i < 5; i++) {
        // Navigate to different pages
        await tester.tap(find.byKey(const Key('customers_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('products_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('sales_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('reports_menu')));
        await tester.pumpAndSettle();

        // Generate reports
        await tester.tap(find.byKey(const Key('sales_report_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('generate_report_button')));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Export data
        await tester.tap(find.byKey(const Key('export_report_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Export to Excel'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      stopwatch.stop();

      // Should complete within 60 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(60000));

      print('Memory stress test time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Network stress test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      final stopwatch = Stopwatch()..start();

      // Perform network-intensive operations
      for (int i = 0; i < 20; i++) {
        // Create customer
        await tester.tap(find.byKey(const Key('customers_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('add_customer_button')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('customer_name_field')),
            'Network Stress Customer $i');
        await tester.enterText(find.byKey(const Key('customer_email_field')),
            'networkstress$i@example.com');
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_customer_button')));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Search for customer
        await tester.enterText(
            find.byKey(const Key('customer_search_field')), 'Network Stress');
        await tester.pumpAndSettle();

        await tester.enterText(
            find.byKey(const Key('customer_search_field')), '');
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // Should complete within 45 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(45000));

      print('Network stress test time: ${stopwatch.elapsedMilliseconds}ms');
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

Future<void> _simulateUserOperation(WidgetTester tester, int index) async {
  // Simulate different user operations
  switch (index % 4) {
    case 0:
      // Navigate to customers
      await tester.tap(find.byKey(const Key('customers_menu')));
      await tester.pumpAndSettle();
      break;
    case 1:
      // Navigate to products
      await tester.tap(find.byKey(const Key('products_menu')));
      await tester.pumpAndSettle();
      break;
    case 2:
      // Navigate to sales
      await tester.tap(find.byKey(const Key('sales_menu')));
      await tester.pumpAndSettle();
      break;
    case 3:
      // Navigate to reports
      await tester.tap(find.byKey(const Key('reports_menu')));
      await tester.pumpAndSettle();
      break;
  }
}
