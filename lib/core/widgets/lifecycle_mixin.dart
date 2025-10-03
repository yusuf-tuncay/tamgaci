import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget lifecycle yönetimi için mixin
/// Disposed view hatalarını önlemek için kullanılır
mixin LifecycleMixin<T extends StatefulWidget> on State<T> {
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Widget'ın dispose edilip edilmediğini kontrol eder
  bool get isDisposed => _isDisposed;

  /// Safe setState - sadece widget dispose edilmemişse çalışır
  void safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  /// Safe async operation - sadece widget dispose edilmemişse çalışır
  Future<void> safeAsyncOperation(Future<void> Function() operation) async {
    if (!_isDisposed && mounted) {
      try {
        await operation();
      } catch (e) {
        // Sadece widget hala mounted ise error'ı handle et
        if (!_isDisposed && mounted) {
          rethrow;
        }
      }
    }
  }

  /// Safe callback - sadece widget dispose edilmemişse çalışır
  void safeCallback(VoidCallback callback) {
    if (!_isDisposed && mounted) {
      callback();
    }
  }

  /// Safe async callback - sadece widget dispose edilmemişse çalışır
  Future<void> safeAsyncCallback(Future<void> Function() callback) async {
    if (!_isDisposed && mounted) {
      try {
        await callback();
      } catch (e) {
        // Sadece widget hala mounted ise error'ı handle et
        if (!_isDisposed && mounted) {
          rethrow;
        }
      }
    }
  }
}

/// Consumer widget'lar için lifecycle mixin
mixin ConsumerLifecycleMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Widget'ın dispose edilip edilmediğini kontrol eder
  bool get isDisposed => _isDisposed;

  /// Safe setState - sadece widget dispose edilmemişse çalışır
  void safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  /// Safe async operation - sadece widget dispose edilmemişse çalışır
  Future<void> safeAsyncOperation(Future<void> Function() operation) async {
    if (!_isDisposed && mounted) {
      try {
        await operation();
      } catch (e) {
        // Sadece widget hala mounted ise error'ı handle et
        if (!_isDisposed && mounted) {
          rethrow;
        }
      }
    }
  }

  /// Safe callback - sadece widget dispose edilmemişse çalışır
  void safeCallback(VoidCallback callback) {
    if (!_isDisposed && mounted) {
      callback();
    }
  }

  /// Safe async callback - sadece widget dispose edilmemişse çalışır
  Future<void> safeAsyncCallback(Future<void> Function() callback) async {
    if (!_isDisposed && mounted) {
      try {
        await callback();
      } catch (e) {
        // Sadece widget hala mounted ise error'ı handle et
        if (!_isDisposed && mounted) {
          rethrow;
        }
      }
    }
  }
}
