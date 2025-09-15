import 'package:flutter/material.dart';
import 'package:tamgaci/core/theme/constants.dart';

/// Error dialog widget for displaying errors to users
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final bool isDismissible;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.isDismissible = true,
  });

  /// Show error dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
    bool isDismissible = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: title,
          message: message,
          actionText: actionText,
          onAction: onAction,
          isDismissible: isDismissible,
        );
      },
    );
  }

  /// Show network error dialog
  static Future<void> showNetworkError(BuildContext context) {
    return show(
      context,
      title: 'Bağlantı Hatası',
      message: 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
      actionText: 'Tamam',
    );
  }

  /// Show validation error dialog
  static Future<void> showValidationError(
    BuildContext context, {
    required String message,
  }) {
    return show(
      context,
      title: 'Geçersiz Veri',
      message: message,
      actionText: 'Tamam',
    );
  }

  /// Show permission error dialog
  static Future<void> showPermissionError(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    return show(
      context,
      title: 'İzin Gerekli',
      message: message,
      actionText: onRetry != null ? 'Tekrar Dene' : 'Tamam',
      onAction: onRetry,
    );
  }

  /// Show Firebase error dialog
  static Future<void> showFirebaseError(BuildContext context) {
    return show(
      context,
      title: 'Veri Hatası',
      message: 'Veri işleme sırasında bir hata oluştu. Lütfen tekrar deneyin.',
      actionText: 'Tamam',
    );
  }

  /// Show generic error dialog
  static Future<void> showGenericError(
    BuildContext context, {
    String? message,
    VoidCallback? onRetry,
  }) {
    return show(
      context,
      title: 'Hata',
      message: message ?? 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
      actionText: onRetry != null ? 'Tekrar Dene' : 'Tamam',
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        if (isDismissible)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        if (actionText != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAction?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(actionText!),
          ),
      ],
    );
  }
}

/// Error snackbar widget
class ErrorSnackBar {
  /// Show error snackbar
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionText,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onError,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration,
        action: actionText != null && onAction != null
            ? SnackBarAction(
                label: actionText,
                textColor: Theme.of(context).colorScheme.onError,
                onPressed: onAction,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        ),
      ),
    );
  }

  /// Show network error snackbar
  static void showNetworkError(BuildContext context) {
    show(
      context,
      message: 'İnternet bağlantınızı kontrol edin',
      actionText: 'Tekrar Dene',
      onAction: () {
        // Retry logic here
      },
    );
  }

  /// Show validation error snackbar
  static void showValidationError(BuildContext context, String message) {
    show(
      context,
      message: message,
    );
  }
}
