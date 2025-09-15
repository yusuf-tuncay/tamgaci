# Security Configuration Kılavuzu

Bu kılavuz, Tamgaci uygulaması için kapsamlı güvenlik yapılandırmasını açıklar.

## 📋 İçindekiler

- [Security Overview](#security-overview)
- [Authentication Security](#authentication-security)
- [Data Security](#data-security)
- [Network Security](#network-security)
- [Input Validation](#input-validation)
- [Access Control](#access-control)
- [Audit Logging](#audit-logging)
- [Security Monitoring](#security-monitoring)

## 🔒 Security Overview

### Security Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client        │    │   Firebase      │    │   External      │
│   Security      │    │   Security      │    │   Security      │
│                 │    │                 │    │                 │
│ • Input Val.    │◄──►│ • Auth Rules    │    │ • SSL/TLS       │
│ • Data Encrypt. │    │ • Firestore     │    │ • CORS          │
│ • Local Storage │    │ • Storage       │    │ • Rate Limiting │
│ • Session Mgmt. │    │ • Functions     │    │ • DDoS Protect. │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Security Layers

1. **Client Security**: Input validation, data encryption, secure storage
2. **Transport Security**: HTTPS, TLS, secure communication
3. **Authentication**: Multi-factor authentication, session management
4. **Authorization**: Role-based access control, permission management
5. **Data Security**: Encryption at rest, data masking, backup security
6. **Network Security**: Firewall, DDoS protection, rate limiting
7. **Monitoring**: Security logging, intrusion detection, alerting

## 🔐 Authentication Security

### 1. Firebase Authentication

#### Security Rules
```javascript
// Authentication security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Business data - authenticated users only
    match /customers/{customerId} {
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
  }
}
```

#### Multi-Factor Authentication
```dart
// lib/services/auth_security_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthSecurityService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static Future<void> enableMFA() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Enable MFA for user
      await user.multiFactor.enroll(
        PhoneMultiFactorGenerator.getAssertion(),
        displayName: 'Phone',
      );
    }
  }
  
  static Future<bool> isMFAEnabled() async {
    final user = _auth.currentUser;
    if (user != null) {
      return user.multiFactor.enrolledFactors.isNotEmpty;
    }
    return false;
  }
  
  static Future<void> requireMFA() async {
    final user = _auth.currentUser;
    if (user != null && !await isMFAEnabled()) {
      throw Exception('Multi-factor authentication required');
    }
  }
}
```

### 2. Session Management

```dart
// lib/services/session_security_service.dart
class SessionSecurityService {
  static const Duration _sessionTimeout = Duration(hours: 8);
  static const Duration _idleTimeout = Duration(minutes: 30);
  
  static DateTime? _lastActivity;
  static Timer? _idleTimer;
  
  static void initialize() {
    _startIdleTimer();
  }
  
  static void updateActivity() {
    _lastActivity = DateTime.now();
    _resetIdleTimer();
  }
  
  static void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleTimeout, () {
      _handleIdleTimeout();
    });
  }
  
  static void _resetIdleTimer() {
    _startIdleTimer();
  }
  
  static void _handleIdleTimeout() async {
    await FirebaseAuth.instance.signOut();
    // Navigate to login page
  }
  
  static bool isSessionValid() {
    if (_lastActivity == null) return false;
    return DateTime.now().difference(_lastActivity!) < _sessionTimeout;
  }
}
```

## 🛡️ Data Security

### 1. Data Encryption

```dart
// lib/services/data_encryption_service.dart
import 'package:encrypt/encrypt.dart';

class DataEncryptionService {
  static final _encrypter = Encrypter(AES(Key.fromSecureRandom(32)));
  static final _iv = IV.fromSecureRandom(16);
  
  static String encrypt(String data) {
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }
  
  static String decrypt(String encryptedData) {
    final encrypted = Encrypted.fromBase64(encryptedData);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
  
  static String encryptSensitiveData(Map<String, dynamic> data) {
    final sensitiveFields = ['ssn', 'creditCard', 'bankAccount'];
    final encryptedData = Map<String, dynamic>.from(data);
    
    for (final field in sensitiveFields) {
      if (encryptedData.containsKey(field)) {
        encryptedData[field] = encrypt(encryptedData[field].toString());
      }
    }
    
    return jsonEncode(encryptedData);
  }
}
```

### 2. Secure Storage

```dart
// lib/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  static Future<void> storeSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }
  
  static Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }
  
  static Future<void> clearAllSecureData() async {
    await _storage.deleteAll();
  }
  
  static Future<Map<String, String>> getAllSecureData() async {
    return await _storage.readAll();
  }
}
```

### 3. Data Masking

```dart
// lib/services/data_masking_service.dart
class DataMaskingService {
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) return email;
    
    final maskedUsername = username[0] + '*' * (username.length - 2) + username[username.length - 1];
    return '$maskedUsername@$domain';
  }
  
  static String maskPhone(String phone) {
    if (phone.length < 4) return phone;
    
    final visibleDigits = phone.substring(phone.length - 4);
    final maskedDigits = '*' * (phone.length - 4);
    return '$maskedDigits$visibleDigits';
  }
  
  static String maskCreditCard(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;
    
    final visibleDigits = cardNumber.substring(cardNumber.length - 4);
    final maskedDigits = '*' * (cardNumber.length - 4);
    return '$maskedDigits$visibleDigits';
  }
  
  static String maskSSN(String ssn) {
    if (ssn.length < 4) return ssn;
    
    final visibleDigits = ssn.substring(ssn.length - 4);
    final maskedDigits = '*' * (ssn.length - 4);
    return '$maskedDigits$visibleDigits';
  }
}
```

## 🌐 Network Security

### 1. HTTPS Configuration

```dart
// lib/config/network_security_config.dart
class NetworkSecurityConfig {
  static const bool requireHttps = true;
  static const List<String> allowedHosts = [
    'tamgaci.com',
    'www.tamgaci.com',
    'api.tamgaci.com',
    'firebase.googleapis.com',
    'firestore.googleapis.com',
  ];
  
  static const Map<String, String> securityHeaders = {
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'",
  };
}
```

### 2. Certificate Pinning

```dart
// lib/services/certificate_pinning_service.dart
import 'package:dio/dio.dart';
import 'package:dio_certificate_pinning/dio_certificate_pinning.dart';

class CertificatePinningService {
  static Dio createSecureDio() {
    final dio = Dio();
    
    // Certificate pinning
    dio.interceptors.add(
      CertificatePinningInterceptor(
        allowedSHAFingerprints: [
          'SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
          'SHA256:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
        ],
      ),
    );
    
    return dio;
  }
}
```

### 3. Rate Limiting

```dart
// lib/services/rate_limiting_service.dart
class RateLimitingService {
  static final Map<String, List<DateTime>> _requests = {};
  static const int _maxRequests = 100;
  static const Duration _timeWindow = Duration(minutes: 15);
  
  static bool isRateLimited(String endpoint) {
    final now = DateTime.now();
    final requests = _requests[endpoint] ?? [];
    
    // Remove old requests
    requests.removeWhere((request) => 
      now.difference(request) > _timeWindow);
    
    // Check if rate limited
    if (requests.length >= _maxRequests) {
      return true;
    }
    
    // Add current request
    requests.add(now);
    _requests[endpoint] = requests;
    
    return false;
  }
  
  static void resetRateLimit(String endpoint) {
    _requests.remove(endpoint);
  }
}
```

## ✅ Input Validation

### 1. Input Validator

```dart
// lib/services/input_validator_service.dart
class InputValidatorService {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format';
    }
    
    return null;
  }
  
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Invalid phone format';
    }
    
    return null;
  }
  
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain uppercase letter';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain lowercase letter';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain number';
    }
    
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain special character';
    }
    
    return null;
  }
  
  static String? validateAmount(String? amount) {
    if (amount == null || amount.isEmpty) {
      return 'Amount is required';
    }
    
    final amountRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!amountRegex.hasMatch(amount)) {
      return 'Invalid amount format';
    }
    
    final value = double.tryParse(amount);
    if (value == null || value < 0) {
      return 'Amount must be positive';
    }
    
    return null;
  }
}
```

### 2. Data Sanitization

```dart
// lib/services/data_sanitization_service.dart
class DataSanitizationService {
  static String sanitizeString(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>"\']'), '') // Remove HTML/JS characters
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }
  
  static Map<String, dynamic> sanitizeMap(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    
    for (final entry in data.entries) {
      if (entry.value is String) {
        sanitized[entry.key] = sanitizeString(entry.value);
      } else if (entry.value is Map<String, dynamic>) {
        sanitized[entry.key] = sanitizeMap(entry.value);
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    
    return sanitized;
  }
  
  static String sanitizeHtml(String html) {
    // Remove potentially dangerous HTML tags
    return html
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<iframe[^>]*>.*?</iframe>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<object[^>]*>.*?</object>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<embed[^>]*>.*?</embed>', caseSensitive: false), '');
  }
}
```

## 🔑 Access Control

### 1. Role-Based Access Control

```dart
// lib/services/rbac_service.dart
enum UserRole {
  admin,
  manager,
  user,
  guest,
}

class RBACService {
  static final Map<UserRole, List<String>> _permissions = {
    UserRole.admin: [
      'users.create',
      'users.read',
      'users.update',
      'users.delete',
      'customers.create',
      'customers.read',
      'customers.update',
      'customers.delete',
      'products.create',
      'products.read',
      'products.update',
      'products.delete',
      'sales.create',
      'sales.read',
      'sales.update',
      'sales.delete',
      'reports.read',
      'settings.update',
    ],
    UserRole.manager: [
      'customers.create',
      'customers.read',
      'customers.update',
      'products.create',
      'products.read',
      'products.update',
      'sales.create',
      'sales.read',
      'sales.update',
      'reports.read',
    ],
    UserRole.user: [
      'customers.read',
      'products.read',
      'sales.read',
      'reports.read',
    ],
    UserRole.guest: [
      'products.read',
    ],
  };
  
  static bool hasPermission(UserRole role, String permission) {
    final rolePermissions = _permissions[role] ?? [];
    return rolePermissions.contains(permission);
  }
  
  static List<String> getPermissions(UserRole role) {
    return _permissions[role] ?? [];
  }
  
  static bool canAccess(String resource, String action, UserRole role) {
    final permission = '$resource.$action';
    return hasPermission(role, permission);
  }
}
```

### 2. Permission Manager

```dart
// lib/services/permission_manager_service.dart
class PermissionManagerService {
  static UserRole? _currentUserRole;
  
  static void setUserRole(UserRole role) {
    _currentUserRole = role;
  }
  
  static UserRole? getCurrentUserRole() {
    return _currentUserRole;
  }
  
  static bool hasPermission(String permission) {
    if (_currentUserRole == null) return false;
    return RBACService.hasPermission(_currentUserRole!, permission);
  }
  
  static bool canAccess(String resource, String action) {
    if (_currentUserRole == null) return false;
    return RBACService.canAccess(resource, action, _currentUserRole!);
  }
  
  static void requirePermission(String permission) {
    if (!hasPermission(permission)) {
      throw Exception('Insufficient permissions');
    }
  }
  
  static void requireAccess(String resource, String action) {
    if (!canAccess(resource, action)) {
      throw Exception('Access denied');
    }
  }
}
```

## 📝 Audit Logging

### 1. Audit Logger

```dart
// lib/services/audit_logger_service.dart
class AuditLoggerService {
  static Future<void> logUserAction(String action, Map<String, dynamic> details) async {
    final auditLog = {
      'action': action,
      'details': details,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'ipAddress': await _getIpAddress(),
      'userAgent': await _getUserAgent(),
    };
    
    await FirebaseFirestore.instance
        .collection('audit_logs')
        .add(auditLog);
  }
  
  static Future<void> logDataAccess(String resource, String action, String resourceId) async {
    await logUserAction('data_access', {
      'resource': resource,
      'action': action,
      'resourceId': resourceId,
    });
  }
  
  static Future<void> logDataModification(String resource, String action, String resourceId, Map<String, dynamic> changes) async {
    await logUserAction('data_modification', {
      'resource': resource,
      'action': action,
      'resourceId': resourceId,
      'changes': changes,
    });
  }
  
  static Future<void> logSecurityEvent(String event, Map<String, dynamic> details) async {
    await logUserAction('security_event', {
      'event': event,
      'details': details,
    });
  }
  
  static Future<String> _getIpAddress() async {
    // Implement IP address detection
    return 'unknown';
  }
  
  static Future<String> _getUserAgent() async {
    // Implement user agent detection
    return 'unknown';
  }
}
```

### 2. Security Event Logger

```dart
// lib/services/security_event_logger_service.dart
class SecurityEventLoggerService {
  static Future<void> logLoginAttempt(String email, bool success, String? reason) async {
    await AuditLoggerService.logSecurityEvent('login_attempt', {
      'email': email,
      'success': success,
      'reason': reason,
    });
  }
  
  static Future<void> logPasswordChange(String userId) async {
    await AuditLoggerService.logSecurityEvent('password_change', {
      'userId': userId,
    });
  }
  
  static Future<void> logPermissionDenied(String userId, String permission) async {
    await AuditLoggerService.logSecurityEvent('permission_denied', {
      'userId': userId,
      'permission': permission,
    });
  }
  
  static Future<void> logSuspiciousActivity(String activity, Map<String, dynamic> details) async {
    await AuditLoggerService.logSecurityEvent('suspicious_activity', {
      'activity': activity,
      'details': details,
    });
  }
}
```

## 🚨 Security Monitoring

### 1. Security Monitor

```dart
// lib/services/security_monitor_service.dart
class SecurityMonitorService {
  static final List<SecurityEvent> _securityEvents = [];
  
  static void initialize() {
    _startMonitoring();
  }
  
  static void _startMonitoring() {
    // Monitor for suspicious activities
    Timer.periodic(Duration(minutes: 5), (timer) {
      _checkForSuspiciousActivity();
    });
  }
  
  static void _checkForSuspiciousActivity() {
    // Check for multiple failed login attempts
    _checkFailedLogins();
    
    // Check for unusual data access patterns
    _checkDataAccessPatterns();
    
    // Check for permission violations
    _checkPermissionViolations();
  }
  
  static void _checkFailedLogins() {
    // Implement failed login detection
  }
  
  static void _checkDataAccessPatterns() {
    // Implement data access pattern analysis
  }
  
  static void _checkPermissionViolations() {
    // Implement permission violation detection
  }
  
  static void addSecurityEvent(SecurityEvent event) {
    _securityEvents.add(event);
    
    // Keep only last 1000 events
    if (_securityEvents.length > 1000) {
      _securityEvents.removeAt(0);
    }
    
    // Check if event requires immediate attention
    if (event.severity == SecuritySeverity.critical) {
      _handleCriticalEvent(event);
    }
  }
  
  static void _handleCriticalEvent(SecurityEvent event) {
    // Send immediate alert
    // Log to security team
    // Take automatic actions if necessary
  }
}

class SecurityEvent {
  final String type;
  final String description;
  final SecuritySeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic> details;
  
  SecurityEvent({
    required this.type,
    required this.description,
    required this.severity,
    required this.timestamp,
    required this.details,
  });
}

enum SecuritySeverity {
  low,
  medium,
  high,
  critical,
}
```

### 2. Intrusion Detection

```dart
// lib/services/intrusion_detection_service.dart
class IntrusionDetectionService {
  static final Map<String, List<DateTime>> _failedAttempts = {};
  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 30);
  
  static Future<bool> checkIntrusion(String identifier, String action) async {
    final now = DateTime.now();
    final attempts = _failedAttempts[identifier] ?? [];
    
    // Remove old attempts
    attempts.removeWhere((attempt) => 
      now.difference(attempt) > _lockoutDuration);
    
    // Check if locked out
    if (attempts.length >= _maxFailedAttempts) {
      await SecurityEventLoggerService.logSuspiciousActivity(
        'intrusion_detected',
        {
          'identifier': identifier,
          'action': action,
          'attempts': attempts.length,
        },
      );
      return true;
    }
    
    return false;
  }
  
  static void recordFailedAttempt(String identifier) {
    final now = DateTime.now();
    final attempts = _failedAttempts[identifier] ?? [];
    attempts.add(now);
    _failedAttempts[identifier] = attempts;
  }
  
  static void clearFailedAttempts(String identifier) {
    _failedAttempts.remove(identifier);
  }
}
```

## 📚 Additional Resources

### Documentation
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Flutter Security](https://docs.flutter.dev/security)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security-testing-guide/)
- [Firebase Security](https://firebase.google.com/docs/security)

### Tools
- [Firebase Security Rules Simulator](https://firebase.google.com/docs/firestore/security/test-rules-emulator)
- [OWASP ZAP](https://owasp.org/www-project-zap/)
- [Burp Suite](https://portswigger.net/burp)
- [Nmap](https://nmap.org/)

### Support
- [Firebase Support](https://firebase.google.com/support)
- [OWASP Community](https://owasp.org/community/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/firebase-security)
- [GitHub Security](https://github.com/security)
