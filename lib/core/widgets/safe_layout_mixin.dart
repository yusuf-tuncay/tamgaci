import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Layout hatalarını önlemek için mixin
mixin SafeLayoutMixin<T extends StatefulWidget> on State<T> {
  bool _isLayoutSafe = true;

  @override
  void initState() {
    super.initState();
    _isLayoutSafe = true;
  }

  @override
  void dispose() {
    _isLayoutSafe = false;
    super.dispose();
  }

  /// Layout güvenli mi kontrol et
  bool get isLayoutSafe => _isLayoutSafe && mounted;

  /// Güvenli setState - sadece layout güvenliyse çalışır
  void safeSetState(VoidCallback fn) {
    if (isLayoutSafe) {
      try {
        setState(fn);
      } catch (e) {
        // Layout hatalarını yakala ve sessizce geç
        debugPrint('Layout error caught and ignored: $e');
      }
    }
  }

  /// Güvenli async operation - sadece layout güvenliyse çalışır
  Future<void> safeAsyncOperation(Future<void> Function() operation) async {
    if (isLayoutSafe) {
      try {
        await operation();
      } catch (e) {
        // Layout hatalarını yakala ve sessizce geç
        debugPrint('Async layout error caught and ignored: $e');
      }
    }
  }

  /// Güvenli callback - sadece layout güvenliyse çalışır
  void safeCallback(VoidCallback callback) {
    if (isLayoutSafe) {
      try {
        callback();
      } catch (e) {
        // Layout hatalarını yakala ve sessizce geç
        debugPrint('Callback layout error caught and ignored: $e');
      }
    }
  }

  /// Güvenli async callback - sadece layout güvenliyse çalışır
  Future<void> safeAsyncCallback(Future<void> Function() callback) async {
    if (isLayoutSafe) {
      try {
        await callback();
      } catch (e) {
        // Layout hatalarını yakala ve sessizce geç
        debugPrint('Async callback layout error caught and ignored: $e');
      }
    }
  }

  /// Güvenli widget build - layout hatalarını önler
  Widget safeBuild(Widget Function() builder) {
    if (!isLayoutSafe) {
      return const SizedBox.shrink();
    }

    try {
      return builder();
    } catch (e) {
      // Layout hatalarını yakala ve boş widget döndür
      debugPrint('Build layout error caught and ignored: $e');
      return const SizedBox.shrink();
    }
  }

  /// Güvenli widget build with fallback
  Widget safeBuildWithFallback(
    Widget Function() builder,
    Widget Function() fallback,
  ) {
    if (!isLayoutSafe) {
      return fallback();
    }

    try {
      return builder();
    } catch (e) {
      // Layout hatalarını yakala ve fallback widget döndür
      debugPrint('Build layout error caught, using fallback: $e');
      return fallback();
    }
  }
}

/// Consumer widget'lar için layout güvenli mixin
mixin ConsumerSafeLayoutMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _isLayoutSafe = true;

  @override
  void initState() {
    super.initState();
    _isLayoutSafe = true;
  }

  @override
  void dispose() {
    _isLayoutSafe = false;
    super.dispose();
  }

  /// Layout güvenli mi kontrol et
  bool get isLayoutSafe => _isLayoutSafe && mounted;

  /// Güvenli setState - sadece layout güvenliyse çalışır
  void safeSetState(VoidCallback fn) {
    if (isLayoutSafe) {
      try {
        setState(fn);
      } catch (e) {
        // Layout hatalarını yakala ve sessizce geç
        debugPrint('Layout error caught and ignored: $e');
      }
    }
  }

  /// Güvenli async operation - sadece layout güvenliyse çalışır
  Future<void> safeAsyncOperation(Future<void> Function() operation) async {
    if (isLayoutSafe) {
      try {
        await operation();
      } catch (e) {
        // Layout hatalarını yakala ve sessizce geç
        debugPrint('Async layout error caught and ignored: $e');
      }
    }
  }

  /// Güvenli callback - sadece layout güvenliyse çalışır
  void safeCallback(VoidCallback callback) {
    if (isLayoutSafe) {
      try {
        callback();
      } catch (e) {
        // Layout hatalarını yakala ve sessizce geç
        debugPrint('Callback layout error caught and ignored: $e');
      }
    }
  }

  /// Güvenli async callback - sadece layout güvenliyse çalışır
  Future<void> safeAsyncCallback(Future<void> Function() callback) async {
    if (isLayoutSafe) {
      try {
        await callback();
      } catch (e) {
        // Layout hatalarını yakala ve sessizce geç
        debugPrint('Async callback layout error caught and ignored: $e');
      }
    }
  }

  /// Güvenli widget build - layout hatalarını önler
  Widget safeBuild(Widget Function() builder) {
    if (!isLayoutSafe) {
      return const SizedBox.shrink();
    }

    try {
      return builder();
    } catch (e) {
      // Layout hatalarını yakala ve boş widget döndür
      debugPrint('Build layout error caught and ignored: $e');
      return const SizedBox.shrink();
    }
  }

  /// Güvenli widget build with fallback
  Widget safeBuildWithFallback(
    Widget Function() builder,
    Widget Function() fallback,
  ) {
    if (!isLayoutSafe) {
      return fallback();
    }

    try {
      return builder();
    } catch (e) {
      // Layout hatalarını yakala ve fallback widget döndür
      debugPrint('Build layout error caught, using fallback: $e');
      return fallback();
    }
  }
}
