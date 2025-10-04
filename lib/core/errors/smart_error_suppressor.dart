import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../services/remote_logging_service.dart';
import '../services/colorized_logger_service.dart';
import 'extension_pattern_mapper.dart';

/// Akıllı error suppression sistemi
/// Kategori bazlı suppression ile güvenli error handling
class SmartErrorSuppressionSystem {
  static bool _isInitialized = false;

  // Suppress edilecek kategoriler
  static final Map<String, ErrorCategory> _suppressionCategories = {
    'performance_api': const ErrorCategory(
      name: 'Performance API',
      patterns: [
        'Failed to execute \'measure\' on \'Performance\'',
        'The mark \'',
        'does not exist',
        'Performance',
        'measure',
        'mark',
        'listener-begin',
        'listener-end',
      ],
      shouldSuppress: true,
      shouldLog: true,
      logLevel: 'INFO',
    ),
    'disposed_view': const ErrorCategory(
      name: 'Disposed View',
      patterns: [
        'isDisposed',
        'disposed EngineFlutterView',
        'Trying to render a disposed',
        'RenderBox was not laid out',
        'hasSize',
        'NEEDS-LAYOUT',
        'NEEDS-PAINT',
        'NEEDS-COMPOSITING-BITS-UPDATE',
        '!_debugDoingThisLayout',
        'RenderPadding',
        'RenderRepaintBoundary',
        '!isDisposed',
        'Trying to render',
        'EngineFlutterView',
        'window.dart:99:12',
        'Assertion failed',
        'org-dartlang-sdk',
      ],
      shouldSuppress: true,
      shouldLog: false, // Disposed view hataları çok spam üretir
      logLevel: 'DEBUG',
    ),
    'image_loading': const ErrorCategory(
      name: 'Image Loading',
      patterns: [
        'image_cache',
        'image_stream',
        'network_image_web',
        'image_decoder',
        'image_cache.dart',
        'image_stream.dart',
        'network_image_web.dart',
        'image_decoder.dart',
      ],
      shouldSuppress: false, // Image hatalarını suppress etme, sadece logla
      shouldLog: true,
      logLevel: 'WARNING',
    ),
    'timeline_async': const ErrorCategory(
      name: 'Timeline Async',
      patterns: [
        'timeline',
        'developer_patch',
        'async_patch',
        'zone',
        'future_impl',
        'complete',
        'asyncReturn',
        'engine',
        'painting',
        'timeline.dart',
        'developer_patch.dart',
        'async_patch.dart',
        'zone.dart',
        'future_impl.dart',
      ],
      shouldSuppress: true,
      shouldLog: true,
      logLevel: 'DEBUG',
    ),
    'camera_errors': const ErrorCategory(
      name: 'Camera Errors',
      patterns: [
        'CameraException',
        'CameraAccessDenied',
        'CameraPermission',
        'Camera not available',
        'Camera initialization failed',
        'CameraController',
        'Camera preview',
        'Camera permission',
        'Camera access',
        'Camera error',
        'Camera failed',
        'Camera unavailable',
        'Camera denied',
        'Camera blocked',
        'Camera restricted',
      ],
      shouldSuppress: false, // Camera hatalarını suppress etme
      shouldLog: true,
      logLevel: 'ERROR',
    ),
    'map_errors': const ErrorCategory(
      name: 'Map Errors',
      patterns: [
        'MapController',
        'GoogleMap',
        'MapView',
        'LocationService',
        'Geolocator',
        'Map initialization',
        'Map rendering',
        'Map tiles',
        'Map error',
        'Map failed',
        'Map unavailable',
        'Map permission',
        'Map access',
        'Map denied',
        'Map blocked',
        'Map restricted',
        'Location permission',
        'Location access',
        'Location denied',
        'Location blocked',
        'Location restricted',
      ],
      shouldSuppress: false, // Map hatalarını suppress etme
      shouldLog: true,
      logLevel: 'WARNING',
    ),
    'webview_errors': const ErrorCategory(
      name: 'WebView Errors',
      patterns: [
        'WebView',
        'WebViewController',
        'WebView initialization',
        'WebView loading',
        'WebView navigation',
        'WebView JavaScript',
        'WebView security',
        'WebView error',
        'WebView failed',
        'WebView unavailable',
        'WebView permission',
        'WebView access',
        'WebView denied',
        'WebView blocked',
        'WebView restricted',
        'WebView timeout',
        'WebView connection',
        'WebView network',
        'WebView SSL',
        'WebView certificate',
      ],
      shouldSuppress: false, // WebView hatalarını suppress etme
      shouldLog: true,
      logLevel: 'WARNING',
    ),
  };

  /// Akıllı error suppression'ı başlat
  static Future<void> initialize({bool productionMode = false}) async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Extension pattern'ları yükle
    _loadExtensionPatterns();

    // Remote logging'i başlat
    await RemoteLoggingService.initialize();

    // Production/Debug ayrımı
    if (productionMode) {
      _initializeProductionMode();
    } else {
      _initializeDebugMode();
    }
  }

  /// Production modu - sadece kritik hataları bastır
  static void _initializeProductionMode() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorString = details.exceptionAsString();

      // Sadece disposed view hatalarını bastır
      if (errorString.contains('isDisposed') ||
          errorString.contains('disposed EngineFlutterView') ||
          errorString.contains('Trying to render a disposed')) {
        if (kDebugMode) {
          debugPrint('⚠️ Production: Suppressed disposed view error');
        }
        return;
      }

      // Diğer hataları normal şekilde işle
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      final errorString = error.toString();

      if (errorString.contains('isDisposed') ||
          errorString.contains('disposed EngineFlutterView') ||
          errorString.contains('Trying to render a disposed')) {
        if (kDebugMode) {
          debugPrint('⚠️ Production: Suppressed disposed view error');
        }
        return true;
      }

      return false;
    };
  }

  /// Debug modu - kategorik suppression
  static void _initializeDebugMode() {
    // FlutterError.onError için akıllı handler
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // PlatformDispatcher.onError için akıllı handler
    PlatformDispatcher.instance.onError = (error, stack) {
      return _handlePlatformError(error, stack);
    };

    // Zone error handler
    runZonedGuarded(() {}, (error, stack) {
      _handleZoneError(error, stack);
    });
  }

  /// Flutter error'ları için akıllı handling
  static void _handleFlutterError(FlutterErrorDetails details) {
    final errorString = details.exceptionAsString();
    final category = _categorizeError(errorString);

    if (category != null) {
      if (category.shouldLog) {
        _logError(category.logLevel, 'Flutter Error', details.exception,
            details.stack);

        // Remote logging'e gönder
        if (category.shouldSuppress) {
          RemoteLoggingService.logSuppressedError(
            details.exception,
            details.stack,
            category: category.name,
            reason: 'Smart suppression - ${category.name}',
          );
        } else {
          RemoteLoggingService.logError(
            details.exception,
            details.stack,
            reason: 'Flutter Error - ${category.name}',
            customKeys: {
              'category': category.name,
              'log_level': category.logLevel,
            },
          );
        }
      }

      if (category.shouldSuppress) {
        if (kDebugMode) {
          debugPrint(
              '⚠️ Suppressed ${category.name} error: ${details.exception}');
        }
        return; // Suppress et
      }
    }

    // Kritik hataları normal şekilde işle
    FlutterError.presentError(details);
  }

  /// Platform error'ları için akıllı handling
  static bool _handlePlatformError(Object error, StackTrace? stack) {
    final errorString = error.toString();
    final category = _categorizeError(errorString);

    if (category != null) {
      if (category.shouldLog) {
        _logError(category.logLevel, 'Platform Error', error, stack);
      }

      if (category.shouldSuppress) {
        if (kDebugMode) {
          debugPrint('⚠️ Suppressed ${category.name} error: $error');
        }
        return true; // Suppress et
      }
    }

    return false; // Normal şekilde işle
  }

  /// Zone error'ları için akıllı handling
  static void _handleZoneError(Object error, StackTrace? stack) {
    final errorString = error.toString();
    final category = _categorizeError(errorString);

    if (category != null) {
      if (category.shouldLog) {
        _logError(category.logLevel, 'Zone Error', error, stack);
      }

      if (category.shouldSuppress) {
        if (kDebugMode) {
          debugPrint('⚠️ Suppressed ${category.name} error: $error');
        }
        return; // Suppress et
      }
    }

    // Kritik zone hatalarını FlutterError'a yönlendir
    FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stack));
  }

  /// Extension pattern'ları yükle
  static void _loadExtensionPatterns() {
    // Extension pattern'ları suppression kategorilerine ekle
    final extensionPatterns = ExtensionPatternMapper.getAllExtensionPatterns();

    for (final entry in extensionPatterns.entries) {
      final extension = entry.key;
      final patterns = entry.value;

      // Extension pattern'ları suppression kategorilerine ekle
      _suppressionCategories['${extension}_extension'] = ErrorCategory(
        name: '${extension.toUpperCase()} Extension',
        patterns: patterns,
        shouldSuppress: false, // Extension hatalarını suppress etme
        shouldLog: true,
        logLevel: 'WARNING',
      );
    }
  }

  /// Error'ı kategorize et
  static ErrorCategory? _categorizeError(String errorString) {
    for (final entry in _suppressionCategories.entries) {
      final category = entry.value;
      if (category.patterns.any((pattern) => errorString.contains(pattern))) {
        return category;
      }
    }
    return null;
  }

  /// Error'ı logla
  static void _logError(
      String level, String type, Object error, StackTrace? stack) {
    if (kDebugMode) {
      // Renkli logging kullan
      ColorizedLoggerService.log(
        level,
        '$type: $error',
        category: 'SmartSuppressor',
        context: 'ErrorHandler',
      );

      if (stack != null && level == 'ERROR') {
        ColorizedLoggerService.debug('Stack: $stack',
            category: 'SmartSuppressor');
      }
    }
  }
}

/// Error kategorisi
class ErrorCategory {
  final List<String> patterns;
  final bool shouldSuppress;
  final bool shouldLog;
  final String logLevel;
  final String name;

  const ErrorCategory({
    required this.patterns,
    required this.shouldSuppress,
    required this.shouldLog,
    required this.logLevel,
    required this.name,
  });
}

/// Akıllı error suppression wrapper widget
class SmartErrorSuppressor extends StatelessWidget {
  final Widget child;
  final bool enableSuppression;

  const SmartErrorSuppressor({
    super.key,
    required this.child,
    this.enableSuppression = true,
  });

  @override
  Widget build(BuildContext context) {
    if (enableSuppression && kIsWeb) {
      return child;
    }
    return child;
  }
}

/// Akıllı error suppression mixin
mixin SmartErrorSuppressorMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      try {
        super.setState(fn);
      } catch (e) {
        final errorString = e.toString();
        final category =
            SmartErrorSuppressionSystem._categorizeError(errorString);

        if (category != null && category.shouldSuppress) {
          if (kDebugMode) {
            debugPrint('⚠️ Suppressed ${category.name} setState error: $e');
          }
          return;
        }
        rethrow;
      }
    }
  }
}
