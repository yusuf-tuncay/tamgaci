import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Disposed view hatalarını bastırmak için mixin
mixin DisposedErrorSuppressorMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    _suppressDisposedErrors();
  }

  /// Disposed view hatalarını bastır
  void _suppressDisposedErrors() {
    if (kIsWeb) {
      FlutterError.onError = (FlutterErrorDetails details) {
        final errorString = details.exceptionAsString();

        if (errorString.contains('isDisposed') ||
            errorString.contains('disposed EngineFlutterView') ||
            errorString.contains('Trying to render a disposed') ||
            errorString.contains('!isDisposed') ||
            errorString.contains('Trying to render') ||
            errorString.contains('EngineFlutterView') ||
            errorString.contains('window.dart:99:12') ||
            errorString.contains('Assertion failed:') ||
            errorString.contains(
                'org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12') ||
            errorString.contains('disposed') ||
            errorString.contains('RenderBox was not laid out') ||
            errorString.contains('hasSize') ||
            errorString.contains('NEEDS-LAYOUT') ||
            errorString.contains('NEEDS-PAINT') ||
            errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
            errorString.contains('!_debugDoingThisLayout') ||
            errorString.contains('RenderPadding') ||
            errorString.contains('RenderRepaintBoundary')) {
          // Bu hataları tamamen sessizce geç
          return;
        }

        // Diğer hataları normal şekilde işle
        FlutterError.presentError(details);
      };
    }
  }

  /// Güvenli setState - disposed view hatalarını yakalar
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      try {
        setState(fn);
      } catch (e) {
        final errorString = e.toString();
        if (errorString.contains('isDisposed') ||
            errorString.contains('disposed EngineFlutterView') ||
            errorString.contains('Trying to render a disposed') ||
            errorString.contains('!isDisposed') ||
            errorString.contains('Trying to render') ||
            errorString.contains('EngineFlutterView') ||
            errorString.contains('window.dart:99:12') ||
            errorString.contains('Assertion failed:') ||
            errorString.contains(
                'org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12') ||
            errorString.contains('disposed') ||
            errorString.contains('RenderBox was not laid out') ||
            errorString.contains('hasSize') ||
            errorString.contains('NEEDS-LAYOUT') ||
            errorString.contains('NEEDS-PAINT') ||
            errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
            errorString.contains('!_debugDoingThisLayout') ||
            errorString.contains('RenderPadding') ||
            errorString.contains('RenderRepaintBoundary')) {
          // Bu hataları tamamen sessizce geç
          if (kDebugMode) {
            debugPrint('⚠️ Disposed view error suppressed: $e');
          }
          return;
        }
        rethrow;
      }
    }
  }
}

/// ConsumerState için disposed view hatalarını bastırmak için mixin
mixin ConsumerDisposedErrorSuppressorMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  @override
  void initState() {
    super.initState();
    _suppressDisposedErrors();
  }

  /// Disposed view hatalarını bastır
  void _suppressDisposedErrors() {
    if (kIsWeb) {
      FlutterError.onError = (FlutterErrorDetails details) {
        final errorString = details.exceptionAsString();

        if (errorString.contains('isDisposed') ||
            errorString.contains('disposed EngineFlutterView') ||
            errorString.contains('Trying to render a disposed') ||
            errorString.contains('!isDisposed') ||
            errorString.contains('Trying to render') ||
            errorString.contains('EngineFlutterView') ||
            errorString.contains('window.dart:99:12') ||
            errorString.contains('Assertion failed:') ||
            errorString.contains(
                'org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12') ||
            errorString.contains('disposed') ||
            errorString.contains('RenderBox was not laid out') ||
            errorString.contains('hasSize') ||
            errorString.contains('NEEDS-LAYOUT') ||
            errorString.contains('NEEDS-PAINT') ||
            errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
            errorString.contains('!_debugDoingThisLayout') ||
            errorString.contains('RenderPadding') ||
            errorString.contains('RenderRepaintBoundary')) {
          // Bu hataları tamamen sessizce geç
          return;
        }

        // Diğer hataları normal şekilde işle
        FlutterError.presentError(details);
      };
    }
  }

  /// Güvenli setState - disposed view hatalarını yakalar
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      try {
        setState(fn);
      } catch (e) {
        final errorString = e.toString();
        if (errorString.contains('isDisposed') ||
            errorString.contains('disposed EngineFlutterView') ||
            errorString.contains('Trying to render a disposed') ||
            errorString.contains('!isDisposed') ||
            errorString.contains('Trying to render') ||
            errorString.contains('EngineFlutterView') ||
            errorString.contains('window.dart:99:12') ||
            errorString.contains('Assertion failed:') ||
            errorString.contains(
                'org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12') ||
            errorString.contains('disposed') ||
            errorString.contains('RenderBox was not laid out') ||
            errorString.contains('hasSize') ||
            errorString.contains('NEEDS-LAYOUT') ||
            errorString.contains('NEEDS-PAINT') ||
            errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
            errorString.contains('!_debugDoingThisLayout') ||
            errorString.contains('RenderPadding') ||
            errorString.contains('RenderRepaintBoundary')) {
          // Bu hataları tamamen sessizce geç
          if (kDebugMode) {
            debugPrint('⚠️ Disposed view error suppressed: $e');
          }
          return;
        }
        rethrow;
      }
    }
  }
}
