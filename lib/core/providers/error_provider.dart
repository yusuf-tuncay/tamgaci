import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/core/errors/error_logger.dart';

/// Error provider for managing global error state
class ErrorProvider extends StateNotifier<ErrorState> {
  ErrorProvider() : super(const ErrorState());

  /// Set error
  void setError(String error,
      {String? context, Map<String, dynamic>? additionalData}) {
    ErrorLogger.logError(
      error,
      context: context ?? 'ErrorProvider',
      additionalData: additionalData,
    );

    state = state.copyWith(
      hasError: true,
      errorMessage: error,
      errorContext: context,
      errorData: additionalData,
      timestamp: DateTime.now(),
    );
  }

  /// Set warning
  void setWarning(String warning,
      {String? context, Map<String, dynamic>? additionalData}) {
    ErrorLogger.logWarning(
      warning,
      context: context ?? 'ErrorProvider',
      additionalData: additionalData,
    );

    state = state.copyWith(
      hasWarning: true,
      warningMessage: warning,
      warningContext: context,
      warningData: additionalData,
      timestamp: DateTime.now(),
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(
      hasError: false,
      errorMessage: null,
      errorContext: null,
      errorData: null,
    );
  }

  /// Clear warning
  void clearWarning() {
    state = state.copyWith(
      hasWarning: false,
      warningMessage: null,
      warningContext: null,
      warningData: null,
    );
  }

  /// Clear all messages
  void clearAll() {
    state = state.copyWith(
      hasError: false,
      errorMessage: null,
      errorContext: null,
      errorData: null,
      hasWarning: false,
      warningMessage: null,
      warningContext: null,
      warningData: null,
    );
  }

  /// Add error to history
  void addToHistory(ErrorItem errorItem) {
    final history = List<ErrorItem>.from(state.errorHistory);
    history.insert(0, errorItem);

    // Keep only last 50 errors
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    state = state.copyWith(errorHistory: history);
  }

  /// Clear error history
  void clearHistory() {
    state = state.copyWith(errorHistory: []);
  }

  /// Get error count
  int getErrorCount() {
    return state.errorHistory.length;
  }

  /// Get error count by type
  int getErrorCountByType(ErrorType type) {
    return state.errorHistory.where((error) => error.type == type).length;
  }

  /// Get recent errors
  List<ErrorItem> getRecentErrors({int limit = 10}) {
    return state.errorHistory.take(limit).toList();
  }

  /// Get errors by context
  List<ErrorItem> getErrorsByContext(String context) {
    return state.errorHistory
        .where((error) => error.context == context)
        .toList();
  }
}

/// Error state class
class ErrorState {
  final bool hasError;
  final String? errorMessage;
  final String? errorContext;
  final Map<String, dynamic>? errorData;
  final bool hasWarning;
  final String? warningMessage;
  final String? warningContext;
  final Map<String, dynamic>? warningData;
  final DateTime? timestamp;
  final List<ErrorItem> errorHistory;

  const ErrorState({
    this.hasError = false,
    this.errorMessage,
    this.errorContext,
    this.errorData,
    this.hasWarning = false,
    this.warningMessage,
    this.warningContext,
    this.warningData,
    this.timestamp,
    this.errorHistory = const [],
  });

  ErrorState copyWith({
    bool? hasError,
    String? errorMessage,
    String? errorContext,
    Map<String, dynamic>? errorData,
    bool? hasWarning,
    String? warningMessage,
    String? warningContext,
    Map<String, dynamic>? warningData,
    DateTime? timestamp,
    List<ErrorItem>? errorHistory,
  }) {
    return ErrorState(
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
      errorContext: errorContext,
      errorData: errorData,
      hasWarning: hasWarning ?? this.hasWarning,
      warningMessage: warningMessage,
      warningContext: warningContext,
      warningData: warningData,
      timestamp: timestamp ?? this.timestamp,
      errorHistory: errorHistory ?? this.errorHistory,
    );
  }
}

/// Error item class
class ErrorItem {
  final String message;
  final ErrorType type;
  final String? context;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final String? stackTrace;

  const ErrorItem({
    required this.message,
    required this.type,
    this.context,
    this.data,
    required this.timestamp,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'ErrorItem(message: $message, type: $type, context: $context, timestamp: $timestamp)';
  }
}

/// Error type enum
enum ErrorType {
  error,
  warning,
  info,
  debug,
}

/// Error provider instance
final errorProvider = StateNotifierProvider<ErrorProvider, ErrorState>((ref) {
  return ErrorProvider();
});

/// Error history provider
final errorHistoryProvider = Provider<List<ErrorItem>>((ref) {
  final errorState = ref.watch(errorProvider);
  return errorState.errorHistory;
});

/// Recent errors provider
final recentErrorsProvider = Provider<List<ErrorItem>>((ref) {
  final errorState = ref.watch(errorProvider);
  return errorState.errorHistory.take(10).toList();
});

/// Error count provider
final errorCountProvider = Provider<int>((ref) {
  final errorState = ref.watch(errorProvider);
  return errorState.errorHistory.length;
});

/// Error count by type provider
final errorCountByTypeProvider = Provider.family<int, ErrorType>((ref, type) {
  final errorState = ref.watch(errorProvider);
  return errorState.errorHistory.where((error) => error.type == type).length;
});

/// Current error provider
final currentErrorProvider = Provider<String?>((ref) {
  final errorState = ref.watch(errorProvider);
  return errorState.errorMessage;
});

/// Current warning provider
final currentWarningProvider = Provider<String?>((ref) {
  final errorState = ref.watch(errorProvider);
  return errorState.warningMessage;
});

/// Has error provider
final hasErrorProvider = Provider<bool>((ref) {
  final errorState = ref.watch(errorProvider);
  return errorState.hasError;
});

/// Has warning provider
final hasWarningProvider = Provider<bool>((ref) {
  final errorState = ref.watch(errorProvider);
  return errorState.hasWarning;
});

/// Error context provider
final errorContextProvider = Provider<String?>((ref) {
  final errorState = ref.watch(errorProvider);
  return errorState.errorContext;
});

/// Warning context provider
final warningContextProvider = Provider<String?>((ref) {
  final errorState = ref.watch(errorProvider);
  return errorState.warningContext;
});
