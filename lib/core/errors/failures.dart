/// Failure classes for the Tamgaci application
/// 
/// This file contains all failure classes used throughout the application
/// following the documentation requirements for proper error handling.
library;


/// Base failure class for all failures
abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;
  final DateTime timestamp;

  Failure(
    this.message, {
    this.code,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'Failure: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Validation failure
class ValidationFailure extends Failure {
  ValidationFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'ValidationFailure: $message';
}

/// Business rule failure
class BusinessRuleFailure extends Failure {
  BusinessRuleFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'BusinessRuleFailure: $message';
}

/// Network failure
class NetworkFailure extends Failure {
  NetworkFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'NetworkFailure: $message';
}

/// Firebase failure
class FirebaseFailure extends Failure {
  FirebaseFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'FirebaseFailure: $message';
}

/// Cache failure
class CacheFailure extends Failure {
  CacheFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'CacheFailure: $message';
}

/// Permission failure
class PermissionFailure extends Failure {
  PermissionFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'PermissionFailure: $message';
}

/// Authentication failure
class AuthenticationFailure extends Failure {
  AuthenticationFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'AuthenticationFailure: $message';
}

/// Authorization failure
class AuthorizationFailure extends Failure {
  AuthorizationFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'AuthorizationFailure: $message';
}

/// Data not found failure
class DataNotFoundFailure extends Failure {
  DataNotFoundFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'DataNotFoundFailure: $message';
}

/// Duplicate data failure
class DuplicateDataFailure extends Failure {
  DuplicateDataFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'DuplicateDataFailure: $message';
}

/// Configuration failure
class ConfigurationFailure extends Failure {
  ConfigurationFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'ConfigurationFailure: $message';
}

/// Service unavailable failure
class ServiceUnavailableFailure extends Failure {
  ServiceUnavailableFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'ServiceUnavailableFailure: $message';
}

/// Timeout failure
class TimeoutFailure extends Failure {
  TimeoutFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'TimeoutFailure: $message';
}

/// File operation failure
class FileOperationFailure extends Failure {
  FileOperationFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'FileOperationFailure: $message';
}

/// Database failure
class DatabaseFailure extends Failure {
  DatabaseFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'DatabaseFailure: $message';
}

/// Export/Import failure
class ExportImportFailure extends Failure {
  ExportImportFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'ExportImportFailure: $message';
}

/// Payment failure
class PaymentFailure extends Failure {
  PaymentFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'PaymentFailure: $message';
}

/// Inventory failure
class InventoryFailure extends Failure {
  InventoryFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'InventoryFailure: $message';
}

/// Transaction failure
class TransactionFailure extends Failure {
  TransactionFailure(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'TransactionFailure: $message';
}

/// Result class for handling success and failure states
sealed class Result<T> {
  const Result();

  /// Create a success result
  factory Result.success(T data) = Success<T>;

  /// Create a failure result
  factory Result.failure(Failure failure) = FailureResult<T>;

  /// Check if the result is a success
  bool get isSuccess => this is Success<T>;

  /// Check if the result is a failure
  bool get isFailure => this is FailureResult<T>;

  /// Get the data if success, null otherwise
  T? get data => isSuccess ? (this as Success<T>).data : null;

  /// Get the failure if failure, null otherwise
  Failure? get failure => isFailure ? (this as FailureResult<T>).failure : null;

  /// Map the result to another type
  Result<R> map<R>(R Function(T) mapper) {
    return switch (this) {
      Success<T>(data: final data) => Result.success(mapper(data)),
      FailureResult<T>(failure: final failure) => Result.failure(failure),
    };
  }

  /// Map the failure to another failure
  Result<T> mapFailure(Failure Function(Failure) mapper) {
    return switch (this) {
      Success<T>() => this,
      FailureResult<T>(failure: final failure) => Result.failure(mapper(failure)),
    };
  }

  /// Fold the result to a single value
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    return switch (this) {
      Success<T>(data: final data) => onSuccess(data),
      FailureResult<T>(failure: final failure) => onFailure(failure),
    };
  }
}

/// Success result
class Success<T> extends Result<T> {
  @override
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Failure result
class FailureResult<T> extends Result<T> {
  @override
  final Failure failure;

  const FailureResult(this.failure);

  @override
  String toString() => 'FailureResult($failure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
