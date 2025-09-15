# Monitoring ve Logging Setup Kılavuzu

Bu kılavuz, Tamgaci uygulaması için kapsamlı monitoring ve logging sisteminin kurulumunu açıklar.

## 📋 İçindekiler

- [Monitoring Overview](#monitoring-overview)
- [Error Tracking](#error-tracking)
- [Performance Monitoring](#performance-monitoring)
- [Analytics](#analytics)
- [Logging System](#logging-system)
- [Alerting](#alerting)
- [Dashboard](#dashboard)
- [Troubleshooting](#troubleshooting)

## 🔍 Monitoring Overview

### Monitoring Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Firebase      │    │   External      │
│                 │    │   Services      │    │   Services      │
│ • Error Tracking│◄──►│ • Crashlytics   │    │ • Sentry        │
│ • Performance   │    │ • Performance   │    │ • DataDog       │
│ • Analytics     │    │ • Analytics     │    │ • New Relic     │
│ • Custom Events │    │ • Functions     │    │ • LogRocket     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Monitoring Stack

1. **Error Tracking**: Firebase Crashlytics + Sentry
2. **Performance**: Firebase Performance + Custom Metrics
3. **Analytics**: Firebase Analytics + Custom Events
4. **Logging**: Firebase Functions + Cloud Logging
5. **Alerting**: Firebase Functions + Email/SMS
6. **Dashboard**: Firebase Console + Custom Dashboard

## ⚠️ Error Tracking

### 1. Firebase Crashlytics

#### Setup
```dart
// lib/main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialization
  await Firebase.initializeApp();
  
  // Crashlytics initialization
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(MyApp());
}
```

#### Error Reporting
```dart
// lib/services/error_tracking_service.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ErrorTrackingService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  
  static Future<void> initialize() async {
    // Enable crashlytics
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
  }
  
  static Future<void> recordError(dynamic error, StackTrace? stackTrace, {String? context}) async {
    await _crashlytics.recordError(error, stackTrace);
    
    if (context != null) {
      await _crashlytics.setCustomKey('context', context);
    }
  }
  
  static Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }
  
  static Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }
  
  static Future<void> log(String message) async {
    await _crashlytics.log(message);
  }
  
  static Future<void> recordFlutterError(FlutterErrorDetails details) async {
    await _crashlytics.recordFlutterFatalError(details);
  }
}
```

### 2. Sentry Integration

#### Setup
```dart
// lib/main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://your-sentry-dsn@sentry.io/project-id';
      options.environment = 'production';
      options.release = '1.0.0';
      options.tracesSampleRate = 0.1;
      options.profilesSampleRate = 0.1;
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

#### Sentry Service
```dart
// lib/services/sentry_service.dart
import 'package:sentry/sentry.dart';

class SentryService {
  static Future<void> captureException(dynamic exception, StackTrace? stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  }
  
  static Future<void> captureMessage(String message) async {
    await Sentry.captureMessage(message);
  }
  
  static Future<void> setUser(String userId, String email) async {
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: userId, email: email));
    });
  }
  
  static Future<void> setTag(String key, String value) async {
    await Sentry.configureScope((scope) {
      scope.setTag(key, value);
    });
  }
  
  static Future<void> setContext(String key, Map<String, dynamic> context) async {
    await Sentry.configureScope((scope) {
      scope.setContext(key, context);
    });
  }
  
  static Future<void> addBreadcrumb(String message, {String? category}) async {
    await Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      timestamp: DateTime.now(),
    ));
  }
}
```

### 3. Custom Error Handler

```dart
// lib/services/custom_error_handler.dart
class CustomErrorHandler {
  static Future<void> handleError(dynamic error, StackTrace? stackTrace, {String? context}) async {
    // Log to console
    print('Error: $error');
    print('Stack: $stackTrace');
    
    // Send to Crashlytics
    await ErrorTrackingService.recordError(error, stackTrace, context: context);
    
    // Send to Sentry
    await SentryService.captureException(error, stackTrace);
    
    // Log to custom logging service
    await LoggingService.logError(error.toString(), stackTrace?.toString(), context: context);
    
    // Send alert if critical
    if (_isCriticalError(error)) {
      await AlertingService.sendCriticalAlert(error.toString(), context: context);
    }
  }
  
  static bool _isCriticalError(dynamic error) {
    final criticalErrors = [
      'OutOfMemoryError',
      'StackOverflowError',
      'NullPointerException',
      'DatabaseConnectionError',
    ];
    
    return criticalErrors.any((criticalError) => 
      error.toString().contains(criticalError));
  }
}
```

## ⚡ Performance Monitoring

### 1. Firebase Performance

#### Setup
```dart
// lib/main.dart
import 'package:firebase_performance/firebase_performance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialization
  await Firebase.initializeApp();
  
  // Performance monitoring
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  
  runApp(MyApp());
}
```

#### Performance Service
```dart
// lib/services/performance_service.dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;
  
  static Future<Trace> startTrace(String name) async {
    final trace = _performance.newTrace(name);
    await trace.start();
    return trace;
  }
  
  static Future<void> stopTrace(Trace trace) async {
    await trace.stop();
  }
  
  static Future<void> incrementCounter(Trace trace, String counterName) async {
    await trace.incrementCounter(counterName);
  }
  
  static Future<void> setMetric(Trace trace, String metricName, int value) async {
    await trace.setMetric(metricName, value);
  }
  
  // Custom performance tracking
  static Future<void> trackPageLoad(String pageName) async {
    final trace = await startTrace('page_load_$pageName');
    await stopTrace(trace);
  }
  
  static Future<void> trackApiCall(String endpoint, Duration duration) async {
    final trace = await startTrace('api_call_$endpoint');
    await setMetric(trace, 'duration_ms', duration.inMilliseconds);
    await stopTrace(trace);
  }
  
  static Future<void> trackDatabaseQuery(String query, Duration duration) async {
    final trace = await startTrace('db_query_$query');
    await setMetric(trace, 'duration_ms', duration.inMilliseconds);
    await stopTrace(trace);
  }
  
  static Future<void> trackImageLoad(String imageUrl, Duration duration) async {
    final trace = await startTrace('image_load');
    await setMetric(trace, 'duration_ms', duration.inMilliseconds);
    await setMetric(trace, 'image_url', imageUrl.hashCode);
    await stopTrace(trace);
  }
}
```

### 2. Custom Performance Metrics

```dart
// lib/services/custom_performance_service.dart
class CustomPerformanceService {
  static final Map<String, List<Duration>> _metrics = {};
  static final Map<String, int> _counters = {};
  
  static void recordMetric(String name, Duration duration) {
    _metrics[name] ??= [];
    _metrics[name]!.add(duration);
    
    // Keep only last 100 measurements
    if (_metrics[name]!.length > 100) {
      _metrics[name]!.removeAt(0);
    }
  }
  
  static void incrementCounter(String name) {
    _counters[name] = (_counters[name] ?? 0) + 1;
  }
  
  static double getAverageMetric(String name) {
    final durations = _metrics[name];
    if (durations == null || durations.isEmpty) return 0.0;
    
    final total = durations.fold(0, (sum, duration) => sum + duration.inMilliseconds);
    return total / durations.length;
  }
  
  static int getCounter(String name) {
    return _counters[name] ?? 0;
  }
  
  static Map<String, double> getAllMetrics() {
    final result = <String, double>{};
    for (final name in _metrics.keys) {
      result[name] = getAverageMetric(name);
    }
    return result;
  }
  
  static Map<String, int> getAllCounters() {
    return Map.from(_counters);
  }
  
  static void resetMetrics() {
    _metrics.clear();
    _counters.clear();
  }
}
```

### 3. Performance Widget

```dart
// lib/widgets/performance_monitor_widget.dart
class PerformanceMonitorWidget extends StatefulWidget {
  @override
  _PerformanceMonitorWidgetState createState() => _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  Map<String, double> _metrics = {};
  Map<String, int> _counters = {};
  
  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }
  
  void _loadMetrics() {
    setState(() {
      _metrics = CustomPerformanceService.getAllMetrics();
      _counters = CustomPerformanceService.getAllCounters();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance Metrics', style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 16),
            ..._metrics.entries.map((entry) => 
              ListTile(
                title: Text(entry.key),
                trailing: Text('${entry.value.toStringAsFixed(2)} ms'),
              ),
            ),
            SizedBox(height: 16),
            Text('Counters', style: Theme.of(context).textTheme.subtitle1),
            ..._counters.entries.map((entry) => 
              ListTile(
                title: Text(entry.key),
                trailing: Text('${entry.value}'),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMetrics,
              child: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 📊 Analytics

### 1. Firebase Analytics

#### Setup
```dart
// lib/main.dart
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialization
  await Firebase.initializeApp();
  
  // Analytics
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  
  runApp(MyApp());
}
```

#### Analytics Service
```dart
// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
  
  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }
  
  static Future<void> logPurchase(double value, String currency, String itemId) async {
    await _analytics.logPurchase(
      value: value,
      currency: currency,
      parameters: {'item_id': itemId},
    );
  }
  
  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
  
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
  
  // Custom events
  static Future<void> trackCustomerCreated() async {
    await logEvent('customer_created', {});
  }
  
  static Future<void> trackProductCreated() async {
    await logEvent('product_created', {});
  }
  
  static Future<void> trackSaleCompleted(double amount) async {
    await logEvent('sale_completed', {'amount': amount});
  }
  
  static Future<void> trackPurchaseCompleted(double amount) async {
    await logEvent('purchase_completed', {'amount': amount});
  }
  
  static Future<void> trackReportGenerated(String reportType) async {
    await logEvent('report_generated', {'report_type': reportType});
  }
  
  static Future<void> trackExportCompleted(String format) async {
    await logEvent('export_completed', {'format': format});
  }
  
  static Future<void> trackSearchPerformed(String query) async {
    await logEvent('search_performed', {'query': query});
  }
  
  static Future<void> trackFilterApplied(String filterType, String filterValue) async {
    await logEvent('filter_applied', {
      'filter_type': filterType,
      'filter_value': filterValue,
    });
  }
}
```

### 2. Custom Analytics

```dart
// lib/services/custom_analytics_service.dart
class CustomAnalyticsService {
  static final List<AnalyticsEvent> _events = [];
  
  static void trackEvent(String name, Map<String, dynamic> parameters) {
    final event = AnalyticsEvent(
      name: name,
      parameters: parameters,
      timestamp: DateTime.now(),
    );
    
    _events.add(event);
    
    // Keep only last 1000 events
    if (_events.length > 1000) {
      _events.removeAt(0);
    }
  }
  
  static List<AnalyticsEvent> getEvents({String? name, DateTime? since}) {
    var filteredEvents = _events;
    
    if (name != null) {
      filteredEvents = filteredEvents.where((event) => event.name == name).toList();
    }
    
    if (since != null) {
      filteredEvents = filteredEvents.where((event) => event.timestamp.isAfter(since)).toList();
    }
    
    return filteredEvents;
  }
  
  static Map<String, int> getEventCounts({DateTime? since}) {
    final events = getEvents(since: since);
    final counts = <String, int>{};
    
    for (final event in events) {
      counts[event.name] = (counts[event.name] ?? 0) + 1;
    }
    
    return counts;
  }
  
  static void clearEvents() {
    _events.clear();
  }
}

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  
  AnalyticsEvent({
    required this.name,
    required this.parameters,
    required this.timestamp,
  });
}
```

## 📝 Logging System

### 1. Firebase Functions Logging

#### Logging Function
```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Logging function
exports.logEvent = functions.https.onCall(async (data, context) => {
  const { level, message, context: logContext, userId } = data;
  
  // Validate user
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  // Log to Cloud Logging
  const logEntry = {
    severity: level,
    message: message,
    context: logContext,
    userId: userId || context.auth.uid,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  };
  
  // Store in Firestore
  await admin.firestore().collection('logs').add(logEntry);
  
  // Log to console
  console.log(JSON.stringify(logEntry));
  
  return { success: true };
});

// Error logging function
exports.logError = functions.https.onCall(async (data, context) => {
  const { error, stackTrace, context: errorContext, userId } = data;
  
  // Validate user
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  // Log to Cloud Logging
  const logEntry = {
    severity: 'ERROR',
    message: error,
    stackTrace: stackTrace,
    context: errorContext,
    userId: userId || context.auth.uid,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  };
  
  // Store in Firestore
  await admin.firestore().collection('error_logs').add(logEntry);
  
  // Log to console
  console.error(JSON.stringify(logEntry));
  
  return { success: true };
});
```

### 2. Client-Side Logging

```dart
// lib/services/logging_service.dart
import 'package:cloud_functions/cloud_functions.dart';

class LoggingService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  static Future<void> logInfo(String message, {Map<String, dynamic>? context}) async {
    await _log('INFO', message, context: context);
  }
  
  static Future<void> logWarning(String message, {Map<String, dynamic>? context}) async {
    await _log('WARNING', message, context: context);
  }
  
  static Future<void> logError(String message, {Map<String, dynamic>? context}) async {
    await _log('ERROR', message, context: context);
  }
  
  static Future<void> logDebug(String message, {Map<String, dynamic>? context}) async {
    await _log('DEBUG', message, context: context);
  }
  
  static Future<void> _log(String level, String message, {Map<String, dynamic>? context}) async {
    try {
      await _functions.httpsCallable('logEvent').call({
        'level': level,
        'message': message,
        'context': context,
      });
    } catch (e) {
      // Fallback to console logging
      print('Logging error: $e');
      print('$level: $message');
    }
  }
  
  static Future<void> logErrorWithStackTrace(String error, String stackTrace, {Map<String, dynamic>? context}) async {
    try {
      await _functions.httpsCallable('logError').call({
        'error': error,
        'stackTrace': stackTrace,
        'context': context,
      });
    } catch (e) {
      // Fallback to console logging
      print('Error logging error: $e');
      print('ERROR: $error');
      print('STACK: $stackTrace');
    }
  }
}
```

### 3. Local Logging

```dart
// lib/services/local_logging_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalLoggingService {
  static const String _logFileName = 'tamgaci.log';
  static const int _maxLogSize = 1024 * 1024; // 1MB
  static const int _maxLogFiles = 5;
  
  static Future<void> log(String level, String message, {Map<String, dynamic>? context}) async {
    try {
      final logEntry = _createLogEntry(level, message, context);
      await _writeToFile(logEntry);
    } catch (e) {
      print('Local logging error: $e');
    }
  }
  
  static String _createLogEntry(String level, String message, Map<String, dynamic>? context) {
    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context != null ? ' | Context: ${context.toString()}' : '';
    return '$timestamp | $level | $message$contextStr\n';
  }
  
  static Future<void> _writeToFile(String logEntry) async {
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/$_logFileName');
    
    // Check file size and rotate if necessary
    if (await logFile.exists()) {
      final fileSize = await logFile.length();
      if (fileSize > _maxLogSize) {
        await _rotateLogFile(logFile);
      }
    }
    
    // Write log entry
    await logFile.writeAsString(logEntry, mode: FileMode.append);
  }
  
  static Future<void> _rotateLogFile(File logFile) async {
    final directory = logFile.parent;
    
    // Rotate existing log files
    for (int i = _maxLogFiles - 1; i > 0; i--) {
      final oldFile = File('${directory.path}/$_logFileName.$i');
      final newFile = File('${directory.path}/$_logFileName.${i + 1}');
      
      if (await oldFile.exists()) {
        if (i == _maxLogFiles - 1) {
          await oldFile.delete();
        } else {
          await oldFile.rename(newFile.path);
        }
      }
    }
    
    // Move current log file
    final rotatedFile = File('${directory.path}/$_logFileName.1');
    await logFile.rename(rotatedFile.path);
  }
  
  static Future<List<String>> getLogs({int? limit}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/$_logFileName');
      
      if (!await logFile.exists()) {
        return [];
      }
      
      final content = await logFile.readAsString();
      final lines = content.split('\n').where((line) => line.isNotEmpty).toList();
      
      if (limit != null && limit > 0) {
        return lines.take(limit).toList();
      }
      
      return lines;
    } catch (e) {
      print('Error reading logs: $e');
      return [];
    }
  }
  
  static Future<void> clearLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/$_logFileName');
      
      if (await logFile.exists()) {
        await logFile.delete();
      }
      
      // Delete rotated log files
      for (int i = 1; i <= _maxLogFiles; i++) {
        final rotatedFile = File('${directory.path}/$_logFileName.$i');
        if (await rotatedFile.exists()) {
          await rotatedFile.delete();
        }
      }
    } catch (e) {
      print('Error clearing logs: $e');
    }
  }
}
```

## 🚨 Alerting

### 1. Alerting Service

```dart
// lib/services/alerting_service.dart
import 'package:cloud_functions/cloud_functions.dart';

class AlertingService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  static Future<void> sendCriticalAlert(String message, {Map<String, dynamic>? context}) async {
    await _sendAlert('CRITICAL', message, context: context);
  }
  
  static Future<void> sendWarningAlert(String message, {Map<String, dynamic>? context}) async {
    await _sendAlert('WARNING', message, context: context);
  }
  
  static Future<void> sendInfoAlert(String message, {Map<String, dynamic>? context}) async {
    await _sendAlert('INFO', message, context: context);
  }
  
  static Future<void> _sendAlert(String level, String message, {Map<String, dynamic>? context}) async {
    try {
      await _functions.httpsCallable('sendAlert').call({
        'level': level,
        'message': message,
        'context': context,
      });
    } catch (e) {
      print('Alerting error: $e');
    }
  }
}
```

### 2. Alerting Function

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

// Email configuration
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: 'alerts@tamgaci.com',
    pass: 'your-app-password'
  }
});

// Alerting function
exports.sendAlert = functions.https.onCall(async (data, context) => {
  const { level, message, context: alertContext } = data;
  
  // Validate user
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  // Create alert
  const alert = {
    level: level,
    message: message,
    context: alertContext,
    userId: context.auth.uid,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    sent: false,
  };
  
  // Store alert in Firestore
  const alertRef = await admin.firestore().collection('alerts').add(alert);
  
  // Send email if critical
  if (level === 'CRITICAL') {
    await _sendEmailAlert(alert);
  }
  
  // Send SMS if critical (using Twilio or similar)
  if (level === 'CRITICAL') {
    await _sendSMSAlert(alert);
  }
  
  // Update alert as sent
  await alertRef.update({ sent: true });
  
  return { success: true };
});

async function _sendEmailAlert(alert) {
  const mailOptions = {
    from: 'alerts@tamgaci.com',
    to: 'admin@tamgaci.com',
    subject: `[${alert.level}] Tamgaci Alert`,
    html: `
      <h2>Tamgaci Alert</h2>
      <p><strong>Level:</strong> ${alert.level}</p>
      <p><strong>Message:</strong> ${alert.message}</p>
      <p><strong>Context:</strong> ${JSON.stringify(alert.context, null, 2)}</p>
      <p><strong>Timestamp:</strong> ${alert.timestamp.toDate()}</p>
    `
  };
  
  try {
    await transporter.sendMail(mailOptions);
    console.log('Email alert sent successfully');
  } catch (error) {
    console.error('Error sending email alert:', error);
  }
}

async function _sendSMSAlert(alert) {
  // Implement SMS sending logic here
  // Using Twilio, AWS SNS, or similar service
  console.log('SMS alert would be sent:', alert);
}
```

## 📊 Dashboard

### 1. Monitoring Dashboard

```dart
// lib/pages/monitoring_dashboard_page.dart
class MonitoringDashboardPage extends StatefulWidget {
  @override
  _MonitoringDashboardPageState createState() => _MonitoringDashboardPageState();
}

class _MonitoringDashboardPageState extends State<MonitoringDashboardPage> {
  Map<String, double> _performanceMetrics = {};
  Map<String, int> _eventCounts = {};
  List<AnalyticsEvent> _recentEvents = [];
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  void _loadDashboardData() {
    setState(() {
      _performanceMetrics = CustomPerformanceService.getAllMetrics();
      _eventCounts = CustomAnalyticsService.getEventCounts();
      _recentEvents = CustomAnalyticsService.getEvents(limit: 10);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoring Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPerformanceMetrics(),
            SizedBox(height: 16),
            _buildEventCounts(),
            SizedBox(height: 16),
            _buildRecentEvents(),
            SizedBox(height: 16),
            _buildLogsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPerformanceMetrics() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance Metrics', style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 16),
            ..._performanceMetrics.entries.map((entry) => 
              ListTile(
                title: Text(entry.key),
                trailing: Text('${entry.value.toStringAsFixed(2)} ms'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEventCounts() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event Counts', style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 16),
            ..._eventCounts.entries.map((entry) => 
              ListTile(
                title: Text(entry.key),
                trailing: Text('${entry.value}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentEvents() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Events', style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 16),
            ..._recentEvents.map((event) => 
              ListTile(
                title: Text(event.name),
                subtitle: Text(event.timestamp.toString()),
                trailing: Text(event.parameters.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLogsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Logs', style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final logs = await LocalLoggingService.getLogs(limit: 50);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Recent Logs'),
                    content: SingleChildScrollView(
                      child: Text(logs.join('\n')),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('View Logs'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Crashlytics Not Working

**Problem**: Crashlytics not reporting crashes
**Solution**:
```dart
// Check if Crashlytics is enabled
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

// Test crash reporting
FirebaseCrashlytics.instance.crash();
```

#### 2. Performance Monitoring Issues

**Problem**: Performance traces not appearing
**Solution**:
```dart
// Check if Performance is enabled
await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

// Test performance tracking
final trace = await FirebasePerformance.instance.newTrace('test_trace');
await trace.start();
await Future.delayed(Duration(seconds: 1));
await trace.stop();
```

#### 3. Analytics Not Tracking

**Problem**: Analytics events not appearing
**Solution**:
```dart
// Check if Analytics is enabled
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

// Test analytics
await FirebaseAnalytics.instance.logEvent(name: 'test_event');
```

#### 4. Logging Issues

**Problem**: Logs not appearing in Firebase Functions
**Solution**:
```dart
// Check Firebase Functions configuration
// Ensure proper authentication
// Check network connectivity
// Verify function deployment
```

### Debug Commands

```bash
# Check Firebase project status
firebase projects:list
firebase use --list

# Check function logs
firebase functions:log

# Check hosting logs
firebase hosting:channel:open live

# Check Firestore logs
firebase firestore:indexes
```

### Performance Optimization

```dart
// Optimize performance monitoring
class OptimizedPerformanceService {
  static final Map<String, Trace> _activeTraces = {};
  
  static Future<void> startTrace(String name) async {
    if (_activeTraces.containsKey(name)) {
      await _activeTraces[name]!.stop();
    }
    
    final trace = await FirebasePerformance.instance.newTrace(name);
    await trace.start();
    _activeTraces[name] = trace;
  }
  
  static Future<void> stopTrace(String name) async {
    final trace = _activeTraces[name];
    if (trace != null) {
      await trace.stop();
      _activeTraces.remove(name);
    }
  }
  
  static Future<void> stopAllTraces() async {
    for (final trace in _activeTraces.values) {
      await trace.stop();
    }
    _activeTraces.clear();
  }
}
```

## 📚 Additional Resources

### Documentation
- [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
- [Firebase Performance](https://firebase.google.com/docs/perf-mon)
- [Firebase Analytics](https://firebase.google.com/docs/analytics)
- [Sentry Flutter](https://docs.sentry.io/platforms/flutter/)

### Tools
- [Firebase Console](https://console.firebase.google.com/)
- [Sentry Dashboard](https://sentry.io/)
- [Firebase Performance Dashboard](https://console.firebase.google.com/project/your-project/performance)
- [Firebase Analytics Dashboard](https://console.firebase.google.com/project/your-project/analytics)

### Support
- [Firebase Support](https://firebase.google.com/support)
- [Sentry Support](https://sentry.io/support/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/firebase)
- [GitHub Issues](https://github.com/firebase/firebase-tools/issues)
