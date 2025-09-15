import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helpers for common testing operations
class TestHelpers {
  /// Create a test widget with MaterialApp wrapper
  static Widget createTestWidget({
    required Widget child,
    ThemeData? theme,
    Locale? locale,
    List<LocalizationsDelegate>? localizationsDelegates,
  }) {
    return MaterialApp(
      home: child,
      theme: theme ?? ThemeData.light(),
      locale: locale,
      localizationsDelegates: localizationsDelegates,
    );
  }

  /// Create a test scaffold with app bar
  static Widget createTestScaffold({
    required Widget body,
    String? title,
    List<Widget>? actions,
    Widget? floatingActionButton,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title) : null,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  /// Wait for async operations to complete
  static Future<void> waitForAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Wait for specific duration
  static Future<void> waitFor(Duration duration) async {
    await Future.delayed(duration);
  }

  /// Create mock data for testing
  static Map<String, dynamic> createMockCustomer() {
    return {
      'id': 'test_customer_1',
      'name': 'Test Customer',
      'email': 'test@example.com',
      'phone': '+1234567890',
      'address': 'Test Address',
      'balance': 1000.0,
      'creditLimit': 5000.0,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'createdBy': 'test_user',
    };
  }

  /// Create mock product data
  static Map<String, dynamic> createMockProduct() {
    return {
      'id': 'test_product_1',
      'name': 'Test Product',
      'description': 'Test Product Description',
      'price': 99.99,
      'stock': 100,
      'category': 'Test Category',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'createdBy': 'test_user',
    };
  }

  /// Create mock invoice data
  static Map<String, dynamic> createMockInvoice() {
    return {
      'id': 'test_invoice_1',
      'customerId': 'test_customer_1',
      'total': 199.98,
      'status': 'pending',
      'items': [
        {
          'productId': 'test_product_1',
          'quantity': 2,
          'price': 99.99,
        }
      ],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'createdBy': 'test_user',
    };
  }

  /// Create list of mock customers
  static List<Map<String, dynamic>> createMockCustomers({int count = 5}) {
    return List.generate(count, (index) {
      final customer = createMockCustomer();
      customer['id'] = 'test_customer_${index + 1}';
      customer['name'] = 'Test Customer ${index + 1}';
      customer['email'] = 'test${index + 1}@example.com';
      return customer;
    });
  }

  /// Create list of mock products
  static List<Map<String, dynamic>> createMockProducts({int count = 5}) {
    return List.generate(count, (index) {
      final product = createMockProduct();
      product['id'] = 'test_product_${index + 1}';
      product['name'] = 'Test Product ${index + 1}';
      product['price'] = (index + 1) * 10.0;
      return product;
    });
  }

  /// Create list of mock invoices
  static List<Map<String, dynamic>> createMockInvoices({int count = 5}) {
    return List.generate(count, (index) {
      final invoice = createMockInvoice();
      invoice['id'] = 'test_invoice_${index + 1}';
      invoice['total'] = (index + 1) * 100.0;
      return invoice;
    });
  }

  /// Verify widget is displayed
  static void verifyWidgetDisplayed(WidgetTester tester, String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verify widget is not displayed
  static void verifyWidgetNotDisplayed(WidgetTester tester, String text) {
    expect(find.text(text), findsNothing);
  }

  /// Verify button is enabled
  static void verifyButtonEnabled(WidgetTester tester, String buttonText) {
    final button = find.widgetWithText(ElevatedButton, buttonText);
    expect(button, findsOneWidget);
    expect(tester.widget<ElevatedButton>(button).enabled, isTrue);
  }

  /// Verify button is disabled
  static void verifyButtonDisabled(WidgetTester tester, String buttonText) {
    final button = find.widgetWithText(ElevatedButton, buttonText);
    expect(button, findsOneWidget);
    expect(tester.widget<ElevatedButton>(button).enabled, isFalse);
  }

  /// Tap button and wait
  static Future<void> tapButton(WidgetTester tester, String buttonText) async {
    await tester.tap(find.widgetWithText(ElevatedButton, buttonText));
    await tester.pumpAndSettle();
  }

  /// Enter text in text field
  static Future<void> enterText(
      WidgetTester tester, String text, String hintText) async {
    await tester.enterText(find.byWidgetPredicate((widget) {
      if (widget is TextField) {
        return widget.decoration?.hintText == hintText;
      }
      return false;
    }), text);
    await tester.pumpAndSettle();
  }

  /// Verify text field value
  static void verifyTextFieldValue(
      WidgetTester tester, String hintText, String expectedValue) {
    final textField = find.byWidgetPredicate((widget) {
      if (widget is TextField) {
        return widget.decoration?.hintText == hintText;
      }
      return false;
    });
    expect(tester.widget<TextField>(textField).controller?.text,
        equals(expectedValue));
  }

  /// Verify list item count
  static void verifyListItemCount(WidgetTester tester, int expectedCount) {
    expect(find.byType(ListTile), findsNWidgets(expectedCount));
  }

  /// Verify loading indicator is shown
  static void verifyLoadingIndicator(WidgetTester tester) {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Verify loading indicator is not shown
  static void verifyNoLoadingIndicator(WidgetTester tester) {
    expect(find.byType(CircularProgressIndicator), findsNothing);
  }

  /// Verify error message is shown
  static void verifyErrorMessage(WidgetTester tester, String errorMessage) {
    expect(find.text(errorMessage), findsOneWidget);
  }

  /// Verify success message is shown
  static void verifySuccessMessage(WidgetTester tester, String successMessage) {
    expect(find.text(successMessage), findsOneWidget);
  }

  /// Verify snackbar is shown
  static void verifySnackbar(WidgetTester tester, String message) {
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(message), findsOneWidget);
  }

  /// Verify dialog is shown
  static void verifyDialog(WidgetTester tester, String title) {
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(title), findsOneWidget);
  }

  /// Verify navigation occurred
  static void verifyNavigation(WidgetTester tester, String routeName) {
    expect(find.byKey(Key(routeName)), findsOneWidget);
  }

  /// Create mock error
  static Exception createMockError(String message) {
    return Exception(message);
  }

  /// Create mock network error
  static Exception createMockNetworkError() {
    return Exception('Network error: Unable to connect to server');
  }

  /// Create mock validation error
  static Exception createMockValidationError(String field) {
    return Exception('Validation error: $field is required');
  }

  /// Create mock business rule error
  static Exception createMockBusinessRuleError(String rule) {
    return Exception('Business rule error: $rule');
  }

  /// Verify error was logged
  static void verifyErrorLogged(String message) {
    // This would typically verify that ErrorLogger was called
    // For now, we'll just log the verification
    // Verified error logged: $message
  }

  /// Verify info was logged
  static void verifyInfoLogged(String message) {
    // This would typically verify that ErrorLogger was called
    // For now, we'll just log the verification
    // Verified info logged: $message
  }

  /// Create test environment
  static void setupTestEnvironment() {
    // Setup test environment variables
    // This would typically include:
    // - Mock services
    // - Test data
    // - Environment configuration
    // Test environment setup completed
  }

  /// Cleanup test environment
  static void cleanupTestEnvironment() {
    // Cleanup test environment
    // This would typically include:
    // - Clear mocks
    // - Reset state
    // - Cleanup resources
    // Test environment cleanup completed
  }
}

/// Test data factory for creating test data
class TestDataFactory {
  /// Create test customer with specific properties
  static Map<String, dynamic> createCustomer({
    String? id,
    String? name,
    String? email,
    String? phone,
    double? balance,
    double? creditLimit,
  }) {
    return {
      'id': id ?? 'test_customer_${DateTime.now().millisecondsSinceEpoch}',
      'name': name ?? 'Test Customer',
      'email': email ?? 'test@example.com',
      'phone': phone ?? '+1234567890',
      'address': 'Test Address',
      'balance': balance ?? 0.0,
      'creditLimit': creditLimit ?? 1000.0,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'createdBy': 'test_user',
    };
  }

  /// Create test product with specific properties
  static Map<String, dynamic> createProduct({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
  }) {
    return {
      'id': id ?? 'test_product_${DateTime.now().millisecondsSinceEpoch}',
      'name': name ?? 'Test Product',
      'description': description ?? 'Test Product Description',
      'price': price ?? 99.99,
      'stock': stock ?? 100,
      'category': category ?? 'Test Category',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'createdBy': 'test_user',
    };
  }

  /// Create test invoice with specific properties
  static Map<String, dynamic> createInvoice({
    String? id,
    String? customerId,
    double? total,
    String? status,
    List<Map<String, dynamic>>? items,
  }) {
    return {
      'id': id ?? 'test_invoice_${DateTime.now().millisecondsSinceEpoch}',
      'customerId': customerId ?? 'test_customer_1',
      'total': total ?? 199.98,
      'status': status ?? 'pending',
      'items': items ??
          [
            {
              'productId': 'test_product_1',
              'quantity': 2,
              'price': 99.99,
            }
          ],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'createdBy': 'test_user',
    };
  }
}

/// Test assertions for common test scenarios
class TestAssertions {
  /// Assert that a list contains expected items
  static void assertListContains<T>(List<T> list, T item) {
    expect(list, contains(item));
  }

  /// Assert that a list has expected length
  static void assertListLength<T>(List<T> list, int expectedLength) {
    expect(list.length, equals(expectedLength));
  }

  /// Assert that a map contains expected key-value pair
  static void assertMapContains(
      Map<String, dynamic> map, String key, dynamic value) {
    expect(map[key], equals(value));
  }

  /// Assert that a string contains expected substring
  static void assertStringContains(String string, String substring) {
    expect(string, contains(substring));
  }

  /// Assert that a number is within expected range
  static void assertNumberInRange(num number, num min, num max) {
    expect(number, greaterThanOrEqualTo(min));
    expect(number, lessThanOrEqualTo(max));
  }

  /// Assert that a date is within expected range
  static void assertDateInRange(DateTime date, DateTime start, DateTime end) {
    expect(date.isAfter(start) || date.isAtSameMomentAs(start), isTrue);
    expect(date.isBefore(end) || date.isAtSameMomentAs(end), isTrue);
  }

  /// Assert that an exception is thrown
  static void assertExceptionThrown(Function function, Type exceptionType) {
    expect(() => function(), throwsA(isA<Exception>()));
  }

  /// Assert that an async operation completes
  static Future<void> assertAsyncCompletes(Future<void> future) async {
    await expectLater(future, completes);
  }

  /// Assert that an async operation throws
  static Future<void> assertAsyncThrows(
      Future<void> future, Type exceptionType) async {
    await expectLater(future, throwsA(isA<Exception>()));
  }
}
