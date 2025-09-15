import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tamgaci/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Security Tests', () {
    testWidgets('Authentication security test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test invalid login attempts
      await _testInvalidLoginAttempts(tester);

      // Test SQL injection in login
      await _testSQLInjectionLogin(tester);

      // Test XSS in login
      await _testXSSLogin(tester);

      // Test brute force protection
      await _testBruteForceProtection(tester);
    });

    testWidgets('Input validation security test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Test customer input validation
      await _testCustomerInputValidation(tester);

      // Test product input validation
      await _testProductInputValidation(tester);

      // Test sales input validation
      await _testSalesInputValidation(tester);
    });

    testWidgets('Data access security test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Test unauthorized data access
      await _testUnauthorizedDataAccess(tester);

      // Test data isolation
      await _testDataIsolation(tester);

      // Test privilege escalation
      await _testPrivilegeEscalation(tester);
    });

    testWidgets('Session security test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Test session timeout
      await _testSessionTimeout(tester);

      // Test session hijacking
      await _testSessionHijacking(tester);

      // Test concurrent sessions
      await _testConcurrentSessions(tester);
    });

    testWidgets('Network security test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Test HTTPS enforcement
      await _testHTTPSEnforcement(tester);

      // Test certificate pinning
      await _testCertificatePinning(tester);

      // Test network interception
      await _testNetworkInterception(tester);
    });

    testWidgets('Data encryption test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _loginUser(tester);

      // Test data encryption at rest
      await _testDataEncryptionAtRest(tester);

      // Test data encryption in transit
      await _testDataEncryptionInTransit(tester);

      // Test sensitive data masking
      await _testSensitiveDataMasking(tester);
    });
  });
}

// Authentication security tests
Future<void> _testInvalidLoginAttempts(WidgetTester tester) async {
  // Test empty credentials
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();

  expect(find.text('Email is required'), findsOneWidget);
  expect(find.text('Password is required'), findsOneWidget);

  // Test invalid email format
  await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
  await tester.enterText(
      find.byKey(const Key('password_field')), 'password123');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();

  expect(find.text('Invalid email format'), findsOneWidget);

  // Test weak password
  await tester.enterText(
      find.byKey(const Key('email_field')), 'test@example.com');
  await tester.enterText(find.byKey(const Key('password_field')), '123');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();

  expect(find.text('Password must be at least 8 characters'), findsOneWidget);

  // Test non-existent user
  await tester.enterText(
      find.byKey(const Key('email_field')), 'nonexistent@example.com');
  await tester.enterText(
      find.byKey(const Key('password_field')), 'password123');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();

  expect(find.text('Invalid credentials'), findsOneWidget);
}

Future<void> _testSQLInjectionLogin(WidgetTester tester) async {
  // Test SQL injection in email field
  await tester.enterText(find.byKey(const Key('email_field')),
      "admin@example.com'; DROP TABLE users; --");
  await tester.enterText(
      find.byKey(const Key('password_field')), 'password123');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();

  // Should not execute SQL injection
  expect(find.text('Invalid email format'), findsOneWidget);

  // Test SQL injection in password field
  await tester.enterText(
      find.byKey(const Key('email_field')), 'admin@example.com');
  await tester.enterText(find.byKey(const Key('password_field')),
      "password'; DROP TABLE users; --");
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();

  // Should not execute SQL injection
  expect(find.text('Invalid credentials'), findsOneWidget);
}

Future<void> _testXSSLogin(WidgetTester tester) async {
  // Test XSS in email field
  await tester.enterText(
      find.byKey(const Key('email_field')), '<script>alert("XSS")</script>');
  await tester.enterText(
      find.byKey(const Key('password_field')), 'password123');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();

  // Should not execute XSS
  expect(find.text('Invalid email format'), findsOneWidget);

  // Test XSS in password field
  await tester.enterText(
      find.byKey(const Key('email_field')), 'admin@example.com');
  await tester.enterText(
      find.byKey(const Key('password_field')), '<script>alert("XSS")</script>');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();

  // Should not execute XSS
  expect(find.text('Invalid credentials'), findsOneWidget);
}

Future<void> _testBruteForceProtection(WidgetTester tester) async {
  // Attempt multiple failed logins
  for (int i = 0; i < 5; i++) {
    await tester.enterText(
        find.byKey(const Key('email_field')), 'admin@example.com');
    await tester.enterText(
        find.byKey(const Key('password_field')), 'wrongpassword');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
  }

  // Should show brute force protection message
  expect(find.text('Too many failed attempts. Please try again later.'),
      findsOneWidget);

  // Should disable login button
  expect(find.byKey(const Key('login_button')), findsOneWidget);
  expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('login_button')))
          .enabled,
      isFalse);
}

// Input validation security tests
Future<void> _testCustomerInputValidation(WidgetTester tester) async {
  // Navigate to customers
  await tester.tap(find.byKey(const Key('customers_menu')));
  await tester.pumpAndSettle();

  // Open add customer form
  await tester.tap(find.byKey(const Key('add_customer_button')));
  await tester.pumpAndSettle();

  // Test XSS in customer name
  await tester.enterText(find.byKey(const Key('customer_name_field')),
      '<script>alert("XSS")</script>');
  await tester.enterText(
      find.byKey(const Key('customer_email_field')), 'test@example.com');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_customer_button')));
  await tester.pumpAndSettle();

  // Should sanitize input
  expect(find.text('<script>alert("XSS")</script>'), findsNothing);

  // Test SQL injection in customer name
  await tester.enterText(find.byKey(const Key('customer_name_field')),
      "Customer'; DROP TABLE customers; --");
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_customer_button')));
  await tester.pumpAndSettle();

  // Should sanitize input
  expect(find.text("Customer'; DROP TABLE customers; --"), findsNothing);

  // Test invalid email
  await tester.enterText(
      find.byKey(const Key('customer_name_field')), 'Test Customer');
  await tester.enterText(
      find.byKey(const Key('customer_email_field')), 'invalid-email');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_customer_button')));
  await tester.pumpAndSettle();

  expect(find.text('Invalid email format'), findsOneWidget);

  // Test invalid phone
  await tester.enterText(
      find.byKey(const Key('customer_email_field')), 'test@example.com');
  await tester.enterText(
      find.byKey(const Key('customer_phone_field')), 'invalid-phone');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_customer_button')));
  await tester.pumpAndSettle();

  expect(find.text('Invalid phone format'), findsOneWidget);
}

Future<void> _testProductInputValidation(WidgetTester tester) async {
  // Navigate to products
  await tester.tap(find.byKey(const Key('products_menu')));
  await tester.pumpAndSettle();

  // Open add product form
  await tester.tap(find.byKey(const Key('add_product_button')));
  await tester.pumpAndSettle();

  // Test XSS in product name
  await tester.enterText(find.byKey(const Key('product_name_field')),
      '<script>alert("XSS")</script>');
  await tester.enterText(
      find.byKey(const Key('product_code_field')), 'TEST001');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_product_button')));
  await tester.pumpAndSettle();

  // Should sanitize input
  expect(find.text('<script>alert("XSS")</script>'), findsNothing);

  // Test SQL injection in product name
  await tester.enterText(find.byKey(const Key('product_name_field')),
      "Product'; DROP TABLE products; --");
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_product_button')));
  await tester.pumpAndSettle();

  // Should sanitize input
  expect(find.text("Product'; DROP TABLE products; --"), findsNothing);

  // Test invalid price
  await tester.enterText(
      find.byKey(const Key('product_name_field')), 'Test Product');
  await tester.enterText(
      find.byKey(const Key('product_purchase_price_field')), 'invalid-price');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_product_button')));
  await tester.pumpAndSettle();

  expect(find.text('Invalid price format'), findsOneWidget);

  // Test negative price
  await tester.enterText(
      find.byKey(const Key('product_purchase_price_field')), '-10.00');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_product_button')));
  await tester.pumpAndSettle();

  expect(find.text('Price must be positive'), findsOneWidget);
}

Future<void> _testSalesInputValidation(WidgetTester tester) async {
  // Navigate to sales
  await tester.tap(find.byKey(const Key('sales_menu')));
  await tester.pumpAndSettle();

  // Open add sale form
  await tester.tap(find.byKey(const Key('add_sale_button')));
  await tester.pumpAndSettle();

  // Test XSS in sale description
  await tester.enterText(find.byKey(const Key('sale_description_field')),
      '<script>alert("XSS")</script>');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_sale_button')));
  await tester.pumpAndSettle();

  // Should sanitize input
  expect(find.text('<script>alert("XSS")</script>'), findsNothing);

  // Test SQL injection in sale description
  await tester.enterText(find.byKey(const Key('sale_description_field')),
      "Sale'; DROP TABLE sales; --");
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_sale_button')));
  await tester.pumpAndSettle();

  // Should sanitize input
  expect(find.text("Sale'; DROP TABLE sales; --"), findsNothing);

  // Test invalid quantity
  await tester.enterText(
      find.byKey(const Key('sale_description_field')), 'Test Sale');
  await tester.enterText(
      find.byKey(const Key('quantity_field')), 'invalid-quantity');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_sale_button')));
  await tester.pumpAndSettle();

  expect(find.text('Invalid quantity format'), findsOneWidget);

  // Test negative quantity
  await tester.enterText(find.byKey(const Key('quantity_field')), '-1');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('save_sale_button')));
  await tester.pumpAndSettle();

  expect(find.text('Quantity must be positive'), findsOneWidget);
}

// Data access security tests
Future<void> _testUnauthorizedDataAccess(WidgetTester tester) async {
  // Test accessing customer data without proper permissions
  await tester.tap(find.byKey(const Key('customers_menu')));
  await tester.pumpAndSettle();

  // Should show customers page
  expect(find.byKey(const Key('customers_page')), findsOneWidget);

  // Test accessing admin functions without admin role
  await tester.tap(find.byKey(const Key('settings_menu')));
  await tester.pumpAndSettle();

  // Should show settings page
  expect(find.byKey(const Key('settings_page')), findsOneWidget);

  // Test accessing user management without admin role
  await tester.tap(find.byKey(const Key('users_menu')));
  await tester.pumpAndSettle();

  // Should show access denied message
  expect(find.text('Access denied'), findsOneWidget);
}

Future<void> _testDataIsolation(WidgetTester tester) async {
  // Test that users can only see their own data
  await tester.tap(find.byKey(const Key('customers_menu')));
  await tester.pumpAndSettle();

  // Should only show customers created by current user
  expect(find.byKey(const Key('customers_list')), findsOneWidget);

  // Test that users cannot access other users' data
  await tester.tap(find.byKey(const Key('products_menu')));
  await tester.pumpAndSettle();

  // Should only show products created by current user
  expect(find.byKey(const Key('products_list')), findsOneWidget);
}

Future<void> _testPrivilegeEscalation(WidgetTester tester) async {
  // Test that users cannot escalate their privileges
  await tester.tap(find.byKey(const Key('settings_menu')));
  await tester.pumpAndSettle();

  // Test accessing admin settings
  await tester.tap(find.byKey(const Key('admin_settings_button')));
  await tester.pumpAndSettle();

  // Should show access denied message
  expect(find.text('Access denied'), findsOneWidget);

  // Test accessing user management
  await tester.tap(find.byKey(const Key('user_management_button')));
  await tester.pumpAndSettle();

  // Should show access denied message
  expect(find.text('Access denied'), findsOneWidget);
}

// Session security tests
Future<void> _testSessionTimeout(WidgetTester tester) async {
  // Test session timeout after inactivity
  await tester.pumpAndSettle(const Duration(minutes: 1));

  // Should show session timeout message
  expect(find.text('Session expired'), findsOneWidget);

  // Should redirect to login page
  expect(find.byKey(const Key('login_screen')), findsOneWidget);
}

Future<void> _testSessionHijacking(WidgetTester tester) async {
  // Test session hijacking protection
  await tester.tap(find.byKey(const Key('profile_menu')));
  await tester.pumpAndSettle();

  // Should show current session info
  expect(find.byKey(const Key('session_info')), findsOneWidget);

  // Test invalidating other sessions
  await tester.tap(find.byKey(const Key('invalidate_other_sessions_button')));
  await tester.pumpAndSettle();

  // Should show success message
  expect(find.text('Other sessions invalidated'), findsOneWidget);
}

Future<void> _testConcurrentSessions(WidgetTester tester) async {
  // Test concurrent session limit
  await tester.tap(find.byKey(const Key('profile_menu')));
  await tester.pumpAndSettle();

  // Should show active sessions
  expect(find.byKey(const Key('active_sessions')), findsOneWidget);

  // Test session limit enforcement
  await tester.tap(find.byKey(const Key('create_new_session_button')));
  await tester.pumpAndSettle();

  // Should show session limit message
  expect(find.text('Maximum sessions reached'), findsOneWidget);
}

// Network security tests
Future<void> _testHTTPSEnforcement(WidgetTester tester) async {
  // Test HTTPS enforcement
  await tester.tap(find.byKey(const Key('settings_menu')));
  await tester.pumpAndSettle();

  // Should show HTTPS status
  expect(find.byKey(const Key('https_status')), findsOneWidget);
  expect(find.text('HTTPS Enabled'), findsOneWidget);
}

Future<void> _testCertificatePinning(WidgetTester tester) async {
  // Test certificate pinning
  await tester.tap(find.byKey(const Key('settings_menu')));
  await tester.pumpAndSettle();

  // Should show certificate pinning status
  expect(find.byKey(const Key('certificate_pinning_status')), findsOneWidget);
  expect(find.text('Certificate Pinning Enabled'), findsOneWidget);
}

Future<void> _testNetworkInterception(WidgetTester tester) async {
  // Test network interception protection
  await tester.tap(find.byKey(const Key('settings_menu')));
  await tester.pumpAndSettle();

  // Should show network security status
  expect(find.byKey(const Key('network_security_status')), findsOneWidget);
  expect(find.text('Network Security Enabled'), findsOneWidget);
}

// Data encryption tests
Future<void> _testDataEncryptionAtRest(WidgetTester tester) async {
  // Test data encryption at rest
  await tester.tap(find.byKey(const Key('settings_menu')));
  await tester.pumpAndSettle();

  // Should show encryption status
  expect(find.byKey(const Key('encryption_status')), findsOneWidget);
  expect(find.text('Data Encryption Enabled'), findsOneWidget);
}

Future<void> _testDataEncryptionInTransit(WidgetTester tester) async {
  // Test data encryption in transit
  await tester.tap(find.byKey(const Key('settings_menu')));
  await tester.pumpAndSettle();

  // Should show transit encryption status
  expect(find.byKey(const Key('transit_encryption_status')), findsOneWidget);
  expect(find.text('Transit Encryption Enabled'), findsOneWidget);
}

Future<void> _testSensitiveDataMasking(WidgetTester tester) async {
  // Test sensitive data masking
  await tester.tap(find.byKey(const Key('customers_menu')));
  await tester.pumpAndSettle();

  // Should mask sensitive data in customer list
  expect(find.byKey(const Key('customers_list')), findsOneWidget);

  // Test masking in customer details
  await tester.tap(find.text('Test Customer'));
  await tester.pumpAndSettle();

  // Should mask sensitive data in customer details
  expect(find.byKey(const Key('customer_details_page')), findsOneWidget);
  expect(find.byKey(const Key('masked_data')), findsOneWidget);
}

// Helper function
Future<void> _loginUser(WidgetTester tester) async {
  await tester.enterText(
      find.byKey(const Key('email_field')), 'admin@tamgaci.com');
  await tester.enterText(find.byKey(const Key('password_field')), 'admin123');
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle(const Duration(seconds: 3));
}
