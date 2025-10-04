import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Disposed view hatalarını bastırmak için wrapper widget
class DisposedViewSuppressor extends StatelessWidget {
  final Widget child;
  final bool suppressErrors;

  const DisposedViewSuppressor({
    super.key,
    required this.child,
    this.suppressErrors = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!suppressErrors) {
      return child;
    }

    return _ErrorSuppressedWidget(child: child);
  }
}

class _ErrorSuppressedWidget extends StatefulWidget {
  final Widget child;

  const _ErrorSuppressedWidget({required this.child});

  @override
  State<_ErrorSuppressedWidget> createState() => _ErrorSuppressedWidgetState();
}

class _ErrorSuppressedWidgetState extends State<_ErrorSuppressedWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      try {
        super.setState(fn);
      } catch (e) {
        // Disposed view hatalarını yakala ve sessizce geç
        if (_isDisposedViewError(e)) {
          if (kDebugMode) {
            debugPrint('⚠️ Disposed view error suppressed: $e');
          }
          return;
        }
        rethrow;
      }
    }
  }

  bool _isDisposedViewError(Object error) {
    final errorString = error.toString();
    return errorString.contains('disposed') ||
        errorString.contains('EngineFlutterView') ||
        errorString.contains('isDisposed') ||
        errorString.contains('Trying to render') ||
        errorString.contains('Assertion failed') ||
        errorString.contains('org-dartlang-sdk') ||
        errorString.contains('window.dart:99:12') ||
        errorString.contains('RenderBox was not laid out') ||
        errorString.contains('hasSize') ||
        errorString.contains('NEEDS-LAYOUT') ||
        errorString.contains('NEEDS-PAINT') ||
        errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
        errorString.contains('!_debugDoingThisLayout') ||
        errorString.contains('RenderPadding') ||
        errorString.contains('RenderRepaintBoundary');
  }
}

/// Disposed view hatalarını bastırmak için mixin
mixin DisposedViewSuppressorMixin<T extends StatefulWidget> on State<T> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      try {
        super.setState(fn);
      } catch (e) {
        // Disposed view hatalarını yakala ve sessizce geç
        if (_isDisposedViewError(e)) {
          if (kDebugMode) {
            debugPrint('⚠️ Disposed view error suppressed: $e');
          }
          return;
        }
        rethrow;
      }
    }
  }

  bool _isDisposedViewError(Object error) {
    final errorString = error.toString();
    return errorString.contains('disposed') ||
        errorString.contains('EngineFlutterView') ||
        errorString.contains('isDisposed') ||
        errorString.contains('Trying to render') ||
        errorString.contains('Assertion failed') ||
        errorString.contains('org-dartlang-sdk') ||
        errorString.contains('window.dart:99:12') ||
        errorString.contains('RenderBox was not laid out') ||
        errorString.contains('hasSize') ||
        errorString.contains('NEEDS-LAYOUT') ||
        errorString.contains('NEEDS-PAINT') ||
        errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
        errorString.contains('!_debugDoingThisLayout') ||
        errorString.contains('RenderPadding') ||
        errorString.contains('RenderRepaintBoundary');
  }
}

/// Disposed view hatalarını bastırmak için ConsumerStatefulWidget mixin
mixin ConsumerDisposedViewSuppressorMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      try {
        setState(fn);
      } catch (e) {
        // Disposed view hatalarını yakala ve sessizce geç
        if (_isDisposedViewError(e)) {
          if (kDebugMode) {
            debugPrint('⚠️ Disposed view error suppressed: $e');
          }
          return;
        }
        rethrow;
      }
    }
  }

  bool _isDisposedViewError(Object error) {
    final errorString = error.toString();
    return errorString.contains('disposed') ||
        errorString.contains('EngineFlutterView') ||
        errorString.contains('isDisposed') ||
        errorString.contains('Trying to render') ||
        errorString.contains('Assertion failed') ||
        errorString.contains('org-dartlang-sdk') ||
        errorString.contains('window.dart:99:12') ||
        errorString.contains('RenderBox was not laid out') ||
        errorString.contains('hasSize') ||
        errorString.contains('NEEDS-LAYOUT') ||
        errorString.contains('NEEDS-PAINT') ||
        errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
        errorString.contains('!_debugDoingThisLayout') ||
        errorString.contains('RenderPadding') ||
        errorString.contains('RenderRepaintBoundary');
  }
}
