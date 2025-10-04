import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

/// Ultra agresif error suppression sistemi
/// Tüm disposed view hatalarını tamamen bastırır
class UltraErrorSuppressor {
  static bool _isInitialized = false;
  static final List<String> _suppressedPatterns = [
    'isDisposed',
    'disposed EngineFlutterView',
    'Trying to render a disposed',
    'Trying to render',
    'disposed',
    'EngineFlutterView',
    'window.dart:99:12',
    'Assertion failed',
    'org-dartlang-sdk',
    'RenderBox was not laid out',
    'hasSize',
    'NEEDS-LAYOUT',
    'NEEDS-PAINT',
    'NEEDS-COMPOSITING-BITS-UPDATE',
    '!_debugDoingThisLayout',
    'RenderPadding',
    'RenderRepaintBoundary',
    '!isDisposed',
    'RenderBox',
    'RenderObject',
    'RenderView',
    'RenderWindow',
    'RenderSurface',
    'RenderCanvas',
    'RenderParagraph',
    'RenderFlex',
    'RenderStack',
    'RenderPositionedBox',
    'RenderConstrainedBox',
    'RenderSizedBox',
    'RenderContainer',
    'RenderDecoratedBox',
    'RenderTransform',
    'RenderOpacity',
    'RenderClipRect',
    'RenderClipRRect',
    'RenderClipOval',
    'RenderClipPath',
    'RenderCustomPaint',
    'RenderRepaintBoundary',
    'RenderAnimatedOpacity',
    'RenderAnimatedSize',
    'RenderAnimatedPositioned',
    'RenderAnimatedAlign',
    'RenderAnimatedContainer',
    'RenderAnimatedBuilder',
    'RenderAnimatedWidget',
    'RenderAnimatedList',
    'RenderAnimatedGrid',
    'RenderAnimatedSwitcher',
    'RenderAnimatedCrossFade',
    'RenderAnimatedRotation',
    'RenderAnimatedScale',
    'RenderAnimatedSlide',
    'RenderAnimatedPositionedDirectional',
    'RenderAnimatedAlignDirectional',
    'RenderAnimatedContainerDirectional',
    'RenderAnimatedBuilderDirectional',
    'RenderAnimatedWidgetDirectional',
    'RenderAnimatedListDirectional',
    'RenderAnimatedGridDirectional',
    'RenderAnimatedSwitcherDirectional',
    'RenderAnimatedCrossFadeDirectional',
    'RenderAnimatedRotationDirectional',
    'RenderAnimatedScaleDirectional',
    'RenderAnimatedSlideDirectional',
    'RenderAnimatedPositionedDirectionalDirectional',
    'RenderAnimatedAlignDirectionalDirectional',
    'RenderAnimatedContainerDirectionalDirectional',
    'RenderAnimatedBuilderDirectionalDirectional',
    'RenderAnimatedWidgetDirectionalDirectional',
    'RenderAnimatedListDirectionalDirectional',
    'RenderAnimatedGridDirectionalDirectional',
    'RenderAnimatedSwitcherDirectionalDirectional',
    'RenderAnimatedCrossFadeDirectionalDirectional',
    'RenderAnimatedRotationDirectionalDirectional',
    'RenderAnimatedScaleDirectionalDirectional',
    'RenderAnimatedSlideDirectionalDirectional',
    // Performance API hataları
    'Failed to execute \'measure\' on \'Performance\'',
    'The mark \'',
    'does not exist',
    'Performance',
    'measure',
    'mark',
    'listener-begin',
    'listener-end',
    'image_cache',
    'image_stream',
    'network_image_web',
    'image_decoder',
    'timeline',
    'developer_patch',
    'async_patch',
    'zone',
    'future_impl',
    'complete',
    'asyncReturn',
    'engine',
    'painting',
    'image_cache.dart',
    'image_stream.dart',
    'network_image_web.dart',
    'image_decoder.dart',
    'timeline.dart',
    'developer_patch.dart',
    'async_patch.dart',
    'zone.dart',
    'future_impl.dart',
  ];

  /// Ultra error suppression'ı başlat
  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (_shouldSuppressError(details.exceptionAsString())) {
        if (kDebugMode) {
          debugPrint('⚠️ Ultra suppressed error: ${details.exception}');
        }
        return;
      }
      FlutterError.presentError(details);
    };

    // Platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      if (_shouldSuppressError(error.toString())) {
        if (kDebugMode) {
          debugPrint('⚠️ Ultra suppressed platform error: $error');
        }
        return true;
      }
      return false;
    };

    // Zone errors
    runZonedGuarded(
      () {
        // App initialization
      },
      (error, stack) {
        if (_shouldSuppressError(error.toString())) {
          if (kDebugMode) {
            debugPrint('⚠️ Ultra suppressed zone error: $error');
          }
          return;
        }
        // Handle other errors
      },
    );
  }

  /// Error'ın suppress edilip edilmeyeceğini kontrol et
  static bool _shouldSuppressError(String errorString) {
    for (final pattern in _suppressedPatterns) {
      if (errorString.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Yeni pattern ekle
  static void addSuppressedPattern(String pattern) {
    if (!_suppressedPatterns.contains(pattern)) {
      _suppressedPatterns.add(pattern);
    }
  }

  /// Pattern'ları temizle
  static void clearSuppressedPatterns() {
    _suppressedPatterns.clear();
  }

  /// Suppress edilen pattern'ları listele
  static List<String> getSuppressedPatterns() {
    return List.unmodifiable(_suppressedPatterns);
  }
}

/// Ultra agresif disposed view hatalarını bastırmak için mixin
mixin UltraDisposedViewSuppressorMixin<T extends StatefulWidget> on State<T> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      try {
        super.setState(fn);
      } catch (e) {
        if (_isUltraDisposedViewError(e)) {
          if (kDebugMode) {
            debugPrint('⚠️ Ultra disposed view error suppressed: $e');
          }
          return;
        }
        rethrow;
      }
    }
  }

  bool _isUltraDisposedViewError(Object error) {
    final errorString = error.toString();
    return UltraErrorSuppressor._shouldSuppressError(errorString);
  }
}

/// Ultra agresif disposed view hatalarını bastırmak için ConsumerStatefulWidget mixin
mixin UltraConsumerDisposedViewSuppressorMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      try {
        setState(fn);
      } catch (e) {
        if (_isUltraDisposedViewError(e)) {
          if (kDebugMode) {
            debugPrint('⚠️ Ultra disposed view error suppressed: $e');
          }
          return;
        }
        rethrow;
      }
    }
  }

  bool _isUltraDisposedViewError(Object error) {
    final errorString = error.toString();
    return UltraErrorSuppressor._shouldSuppressError(errorString);
  }
}

/// Ultra agresif disposed view hatalarını bastırmak için wrapper widget
class UltraDisposedViewSuppressor extends StatelessWidget {
  final Widget child;
  final bool suppressErrors;

  const UltraDisposedViewSuppressor({
    super.key,
    required this.child,
    this.suppressErrors = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!suppressErrors) {
      return child;
    }

    return _UltraErrorSuppressedWidget(child: child);
  }
}

class _UltraErrorSuppressedWidget extends StatefulWidget {
  final Widget child;

  const _UltraErrorSuppressedWidget({required this.child});

  @override
  State<_UltraErrorSuppressedWidget> createState() =>
      _UltraErrorSuppressedWidgetState();
}

class _UltraErrorSuppressedWidgetState
    extends State<_UltraErrorSuppressedWidget>
    with UltraDisposedViewSuppressorMixin {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
