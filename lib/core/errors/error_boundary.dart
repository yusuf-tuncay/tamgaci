import 'package:flutter/material.dart';
import 'package:tamgaci/core/errors/error_dialog.dart';
import 'package:tamgaci/core/errors/error_logger.dart';

/// Error boundary widget that catches and handles errors in its child widgets
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final String? context;
  final bool showErrorDialog;
  final VoidCallback? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.context,
    this.showErrorDialog = true,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  Object? error;
  StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return widget.fallback ?? _buildErrorWidget();
    }

    return widget.child;
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Bir hata oluştu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu bölümde beklenmeyen bir hata oluştu. Lütfen sayfayı yenileyin.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                hasError = false;
                error = null;
                stackTrace = null;
              });
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      hasError = true;
      this.error = error;
      this.stackTrace = stackTrace;
    });

    // Log the error
    ErrorLogger.logError(
      'Error boundary caught error',
      error: error,
      stackTrace: stackTrace,
      context: widget.context,
    );

    // Call onError callback
    widget.onError?.call();

    // Show error dialog if enabled
    if (widget.showErrorDialog && mounted) {
      ErrorDialog.showGenericError(
        context,
        message: 'Bu bölümde bir hata oluştu. Lütfen tekrar deneyin.',
        onRetry: () {
          setState(() {
            hasError = false;
            this.error = null;
            this.stackTrace = null;
          });
        },
      );
    }
  }
}

/// Error boundary for async operations
class AsyncErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? context;
  final bool showErrorDialog;
  final VoidCallback? onError;

  const AsyncErrorBoundary({
    super.key,
    required this.child,
    this.loadingWidget,
    this.errorWidget,
    this.context,
    this.showErrorDialog = true,
    this.onError,
  });

  @override
  State<AsyncErrorBoundary> createState() => _AsyncErrorBoundaryState();
}

class _AsyncErrorBoundaryState extends State<AsyncErrorBoundary> {
  bool isLoading = false;
  bool hasError = false;
  Object? error;
  StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return widget.errorWidget ?? _buildErrorWidget();
    }

    return widget.child;
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Yükleme Hatası',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Veriler yüklenirken bir hata oluştu. Lütfen tekrar deneyin.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _retry,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  void _retry() {
    setState(() {
      hasError = false;
      error = null;
      stackTrace = null;
    });
  }

  void handleError(Object error, StackTrace stackTrace) {
    setState(() {
      hasError = true;
      this.error = error;
      this.stackTrace = stackTrace;
    });

    // Log the error
    ErrorLogger.logError(
      'Async error boundary caught error',
      error: error,
      stackTrace: stackTrace,
      context: widget.context,
    );

    // Call onError callback
    widget.onError?.call();

    // Show error dialog if enabled
    if (widget.showErrorDialog && mounted) {
      ErrorDialog.showGenericError(
        context,
        message: 'Veri yükleme sırasında bir hata oluştu.',
        onRetry: _retry,
      );
    }
  }

  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }
}

/// Mixin for widgets that need error boundary functionality
mixin ErrorBoundaryMixin<T extends StatefulWidget> on State<T> {
  void handleError(Object error, StackTrace stackTrace, {String? context}) {
    ErrorLogger.logError(
      'Widget error caught',
      error: error,
      stackTrace: stackTrace,
      context: context ?? widget.runtimeType.toString(),
    );

    if (mounted) {
      ErrorDialog.showGenericError(
        this.context,
        message: 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  void handleAsyncError(Object error, StackTrace stackTrace,
      {String? context}) {
    ErrorLogger.logError(
      'Async operation error caught',
      error: error,
      stackTrace: stackTrace,
      context: context ?? widget.runtimeType.toString(),
    );

    if (mounted) {
      ErrorDialog.showGenericError(
        this.context,
        message: 'İşlem sırasında bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }
}
