import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'colorized_logger_service.dart';
import 'logger_output_formatter.dart';
import 'advanced_remote_logging_service.dart';
import 'log_level_storage_service.dart';
import 'memory_log_collector.dart';
import '../errors/extension_pattern_mapper.dart';

/// Renkli logger test sayfası
class ColorizedLoggerTestPage extends ConsumerStatefulWidget {
  const ColorizedLoggerTestPage({super.key});

  @override
  ConsumerState<ColorizedLoggerTestPage> createState() =>
      _ColorizedLoggerTestPageState();
}

class _ColorizedLoggerTestPageState
    extends ConsumerState<ColorizedLoggerTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renkli Logger Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Renkli Logger Test Sayfası',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            const Text(
              'Bu sayfa renkli logger sistemini test etmek için kullanılır. '
              'Aşağıdaki butonlara tıklayarak farklı log seviyelerini test edebilirsiniz.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Test butonları
            _buildTestButton(
              'Test All Colors',
              Colors.purple,
              () => ColorizedLoggerService.testColors(),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'ERROR Test',
              Colors.red,
              () => ColorizedLoggerService.error(
                  'This is an ERROR test message',
                  category: 'Test'),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'WARNING Test',
              Colors.orange,
              () => ColorizedLoggerService.warning(
                  'This is a WARNING test message',
                  category: 'Test'),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'INFO Test',
              Colors.blue,
              () => ColorizedLoggerService.info('This is an INFO test message',
                  category: 'Test'),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'DEBUG Test',
              Colors.green,
              () => ColorizedLoggerService.debug('This is a DEBUG test message',
                  category: 'Test'),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'SUPPRESSED Test',
              Colors.grey,
              () => ColorizedLoggerService.suppressed(
                  'This is a SUPPRESSED test message',
                  category: 'Test'),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'REMOTE Test',
              Colors.pink,
              () => ColorizedLoggerService.remote(
                  'This is a REMOTE test message',
                  category: 'Test'),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'PERFORMANCE Test',
              Colors.cyan,
              () => ColorizedLoggerService.performance(
                  'This is a PERFORMANCE test message',
                  category: 'Test'),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'SUCCESS Test',
              Colors.teal,
              () => ColorizedLoggerService.success(
                  'This is a SUCCESS test message',
                  category: 'Test'),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'Extension Patterns Test',
              Colors.orange,
              () => _testExtensionPatterns(),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'Output Format Test',
              Colors.purple,
              () => _testOutputFormats(),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'Logger Formatter Test',
              Colors.indigo,
              () => _testLoggerFormatter(),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'Advanced Remote Logging Test',
              Colors.red,
              () => _testAdvancedRemoteLogging(),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'Log Level Storage Test',
              Colors.green,
              () => _testLogLevelStorage(),
            ),
            const SizedBox(height: 16),

            _buildTestButton(
              'Memory Log Collector Test',
              Colors.blue,
              () => _testMemoryLogCollector(),
            ),
            const SizedBox(height: 30),

            const Text(
              'Console\'da renkli çıktıları görmek için debug modda çalıştırın.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Extension pattern'ları test et
  void _testExtensionPatterns() {
    ColorizedLoggerService.info('Testing Extension Patterns...',
        category: 'ExtensionTest');

    // Camera patterns test
    ColorizedLoggerService.warning('CameraException: Camera not available',
        category: 'Camera');
    ColorizedLoggerService.error('CameraAccessDenied: Permission denied',
        category: 'Camera');

    // Map patterns test
    ColorizedLoggerService.warning('MapController: Map initialization failed',
        category: 'Map');
    ColorizedLoggerService.error('LocationService: Location permission denied',
        category: 'Map');

    // WebView patterns test
    ColorizedLoggerService.warning('WebView: WebView loading failed',
        category: 'WebView');
    ColorizedLoggerService.error('WebViewController: WebView security error',
        category: 'WebView');

    // Extension pattern mapper test
    final patterns = ExtensionPatternMapper.getAllExtensionPatterns();
    ColorizedLoggerService.info(
        'Extension patterns loaded: ${patterns.length} categories',
        category: 'ExtensionTest');

    for (final entry in patterns.entries) {
      ColorizedLoggerService.debug(
          '${entry.key}: ${entry.value.length} patterns',
          category: 'ExtensionTest');
    }
  }

  /// Output format'ları test et
  void _testOutputFormats() {
    ColorizedLoggerService.info('Testing Output Formats...',
        category: 'FormatTest');

    // Default format
    LoggerOutputFormatter.useDefaultFormat();
    ColorizedLoggerService.info('Default format test', category: 'FormatTest');

    // Compact format
    LoggerOutputFormatter.useCompactFormat();
    ColorizedLoggerService.info('Compact format test', category: 'FormatTest');

    // Detailed format
    LoggerOutputFormatter.useDetailedFormat();
    ColorizedLoggerService.info('Detailed format test', category: 'FormatTest');

    // JSON format
    LoggerOutputFormatter.useJsonFormat();
    ColorizedLoggerService.info('JSON format test', category: 'FormatTest');

    // Reset to default
    LoggerOutputFormatter.useDefaultFormat();
    ColorizedLoggerService.info('Format test completed',
        category: 'FormatTest');
  }

  /// Logger formatter'ı test et
  void _testLoggerFormatter() {
    ColorizedLoggerService.info('Testing Logger Formatter...',
        category: 'FormatterTest');

    // Test log parsing
    const testLog =
        '[2024-01-01 12:00:00.000] ERROR [Test](FormatterTest) This is a test message';
    final parsed = LoggerOutputFormatter.parseLog(testLog);

    ColorizedLoggerService.info('Parsed log: $parsed',
        category: 'FormatterTest');

    // Test log validation
    final isValid = LoggerOutputFormatter.validateLog(testLog);
    ColorizedLoggerService.info('Log validation: $isValid',
        category: 'FormatterTest');

    // Test log cleaning
    const dirtyLog =
        '  \x1B[31mERROR\x1B[0m [Test] This is a dirty log  \n\r  ';
    final cleanLog = LoggerOutputFormatter.cleanLog(dirtyLog);
    ColorizedLoggerService.info('Cleaned log: $cleanLog',
        category: 'FormatterTest');

    // Test log colorizing
    final coloredLog = LoggerOutputFormatter.colorizeLog(
        'ERROR This is a colored log', 'ERROR');
    ColorizedLoggerService.info('Colored log: $coloredLog',
        category: 'FormatterTest');

    ColorizedLoggerService.info('Formatter test completed',
        category: 'FormatterTest');
  }

  /// Advanced remote logging'i test et
  void _testAdvancedRemoteLogging() async {
    ColorizedLoggerService.info('Testing Advanced Remote Logging...',
        category: 'AdvancedRemoteLoggingTest');

    // Advanced remote logging'i başlat
    await AdvancedRemoteLoggingService.initialize(
      productionMode: false,
      appVersion: '1.0.0',
      platform: 'Flutter Web',
    );

    // Kullanıcı bilgilerini ayarla
    await AdvancedRemoteLoggingService.setUserInfo(
      userId: 'test_user_123',
      userEmail: 'test@example.com',
      userName: 'Test User',
      customAttributes: {
        'role': 'admin',
        'department': 'engineering',
      },
    );

    // Breadcrumb ekle
    AdvancedRemoteLoggingService.addBreadcrumb(
      'Advanced remote logging test started',
      category: 'Test',
      context: 'AdvancedRemoteLoggingTest',
      data: {'testId': '123'},
    );

    // Kritik hata logla
    await AdvancedRemoteLoggingService.logCriticalError(
      'Test critical error',
      StackTrace.current,
      reason: 'Test critical error for advanced remote logging',
      category: 'Test',
      severity: 'CRITICAL',
      customKeys: {
        'testType': 'critical',
        'testId': '123',
      },
    );

    // Warning logla
    await AdvancedRemoteLoggingService.logWarning(
      'Test warning',
      StackTrace.current,
      reason: 'Test warning for advanced remote logging',
      category: 'Test',
      severity: 'WARNING',
      customKeys: {
        'testType': 'warning',
        'testId': '123',
      },
    );

    // Info logla
    await AdvancedRemoteLoggingService.logInfo(
      'Test info message',
      category: 'Test',
      severity: 'INFO',
      customKeys: {
        'testType': 'info',
        'testId': '123',
      },
    );

    ColorizedLoggerService.info('Advanced remote logging test completed',
        category: 'AdvancedRemoteLoggingTest');
  }

  /// Log level storage'ı test et
  void _testLogLevelStorage() async {
    ColorizedLoggerService.info('Testing Log Level Storage...',
        category: 'LogLevelStorageTest');

    // Log level storage'ı başlat
    await LogLevelStorageService.initialize(
      productionMode: false,
      storageMode: 'debug',
    );

    // Debug mode test
    await LogLevelStorageService.storeLog(
      level: 'DEBUG',
      message: 'Debug message for log level storage test',
      category: 'Test',
      context: 'LogLevelStorageTest',
      customData: {'testType': 'debug'},
    );

    // Info mode test
    await LogLevelStorageService.storeLog(
      level: 'INFO',
      message: 'Info message for log level storage test',
      category: 'Test',
      context: 'LogLevelStorageTest',
      customData: {'testType': 'info'},
    );

    // Warning mode test
    await LogLevelStorageService.storeLog(
      level: 'WARNING',
      message: 'Warning message for log level storage test',
      category: 'Test',
      context: 'LogLevelStorageTest',
      customData: {'testType': 'warning'},
    );

    // Error mode test
    await LogLevelStorageService.storeLog(
      level: 'ERROR',
      message: 'Error message for log level storage test',
      category: 'Test',
      context: 'LogLevelStorageTest',
      customData: {'testType': 'error'},
    );

    // Local logları al
    final localLogs = LogLevelStorageService.getLocalLogs();
    ColorizedLoggerService.info('Local logs count: ${localLogs.length}',
        category: 'LogLevelStorageTest');

    // Logları export et
    final exportedLogs = await LogLevelStorageService.exportLogs();
    ColorizedLoggerService.info(
        'Logs exported: ${exportedLogs.length} characters',
        category: 'LogLevelStorageTest');

    // Storage mode'u değiştir
    await LogLevelStorageService.setStorageMode('error');
    ColorizedLoggerService.info('Storage mode changed to error',
        category: 'LogLevelStorageTest');

    ColorizedLoggerService.info('Log level storage test completed',
        category: 'LogLevelStorageTest');
  }

  /// Memory log collector'ı test et
  void _testMemoryLogCollector() async {
    ColorizedLoggerService.info('Testing Memory Log Collector...',
        category: 'MemoryLogCollectorTest');

    // Memory log collector'ı başlat
    await MemoryLogCollector.initialize();

    // Test logları ekle
    MemoryLogCollector.addLogEntry(
      level: 'DEBUG',
      message: 'Debug message for memory log collector test',
      category: 'Test',
      context: 'MemoryLogCollectorTest',
      customData: {'testType': 'debug'},
    );

    MemoryLogCollector.addLogEntry(
      level: 'INFO',
      message: 'Info message for memory log collector test',
      category: 'Test',
      context: 'MemoryLogCollectorTest',
      customData: {'testType': 'info'},
    );

    MemoryLogCollector.addLogEntry(
      level: 'WARNING',
      message: 'Warning message for memory log collector test',
      category: 'Test',
      context: 'MemoryLogCollectorTest',
      customData: {'testType': 'warning'},
    );

    MemoryLogCollector.addLogEntry(
      level: 'ERROR',
      message: 'Error message for memory log collector test',
      category: 'Test',
      context: 'MemoryLogCollectorTest',
      customData: {'testType': 'error'},
      stackTrace: StackTrace.current,
    );

    // Session bilgilerini al
    final sessionInfo = MemoryLogCollector.getSessionInfo();
    ColorizedLoggerService.info('Session info: $sessionInfo',
        category: 'MemoryLogCollectorTest');

    // Son hataları al
    final lastErrors = MemoryLogCollector.getLastErrors(5);
    ColorizedLoggerService.info('Last errors count: ${lastErrors.length}',
        category: 'MemoryLogCollectorTest');

    // Kategoriye göre logları al
    final testLogs = MemoryLogCollector.getLogsByCategory('Test');
    ColorizedLoggerService.info('Test logs count: ${testLogs.length}',
        category: 'MemoryLogCollectorTest');

    // Seviyeye göre logları al
    final errorLogs = MemoryLogCollector.getLogsByLevel('ERROR');
    ColorizedLoggerService.info('Error logs count: ${errorLogs.length}',
        category: 'MemoryLogCollectorTest');

    // Log istatistikleri
    final statistics = MemoryLogCollector.getLogStatistics();
    ColorizedLoggerService.info('Log statistics: $statistics',
        category: 'MemoryLogCollectorTest');

    // Logları export et
    final exportedLogs = MemoryLogCollector.exportLogs();
    ColorizedLoggerService.info(
        'Logs exported: ${exportedLogs.length} characters',
        category: 'MemoryLogCollectorTest');

    // UI'da okunabilir format'ta al
    final readableLogs = MemoryLogCollector.getLogsAsReadableText();
    ColorizedLoggerService.info(
        'Readable logs length: ${readableLogs.length} characters',
        category: 'MemoryLogCollectorTest');

    ColorizedLoggerService.info('Memory log collector test completed',
        category: 'MemoryLogCollectorTest');
  }
}
