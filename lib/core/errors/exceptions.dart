/// Custom exceptions for the Tamgaci application
///
/// This file contains all custom exception classes used throughout the application
/// following the documentation requirements for proper error handling.
library;

/// Base exception class for all custom exceptions
abstract class TamgaciException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  final DateTime timestamp;

  TamgaciException(
    this.message, {
    this.code,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'TamgaciException: $message';
}

/// Validation exception for input validation errors
class ValidationException extends TamgaciException {
  ValidationException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Business rule exception for business logic violations
class BusinessRuleException extends TamgaciException {
  BusinessRuleException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'BusinessRuleException: $message';
}

/// Network exception for network-related errors
class NetworkException extends TamgaciException {
  NetworkException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Firebase exception for Firebase-related errors
class FirebaseException extends TamgaciException {
  FirebaseException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'FirebaseException: $message';
}

/// Cache exception for cache-related errors
class CacheException extends TamgaciException {
  CacheException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Permission exception for permission-related errors
class PermissionException extends TamgaciException {
  PermissionException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'PermissionException: $message';
}

/// Authentication exception for authentication-related errors
class AuthenticationException extends TamgaciException {
  AuthenticationException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Authorization exception for authorization-related errors
class AuthorizationException extends TamgaciException {
  AuthorizationException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'AuthorizationException: $message';
}

/// Data not found exception
class DataNotFoundException extends TamgaciException {
  DataNotFoundException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'DataNotFoundException: $message';
}

/// Duplicate data exception
class DuplicateDataException extends TamgaciException {
  DuplicateDataException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'DuplicateDataException: $message';
}

/// Configuration exception for configuration-related errors
class ConfigurationException extends TamgaciException {
  ConfigurationException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'ConfigurationException: $message';
}

/// Service unavailable exception
class ServiceUnavailableException extends TamgaciException {
  ServiceUnavailableException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'ServiceUnavailableException: $message';
}

/// Timeout exception
class TimeoutException extends TamgaciException {
  TimeoutException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'TimeoutException: $message';
}

/// File operation exception
class FileOperationException extends TamgaciException {
  FileOperationException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'FileOperationException: $message';
}

/// Database exception
class DatabaseException extends TamgaciException {
  DatabaseException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'DatabaseException: $message';
}

/// Export/Import exception
class ExportImportException extends TamgaciException {
  ExportImportException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'ExportImportException: $message';
}

/// Payment exception
class PaymentException extends TamgaciException {
  PaymentException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'PaymentException: $message';
}

/// Inventory exception
class InventoryException extends TamgaciException {
  InventoryException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'InventoryException: $message';
}

/// Transaction exception
class TransactionException extends TamgaciException {
  TransactionException(
    super.message, {
    super.code,
    super.details,
    super.timestamp,
  });

  @override
  String toString() => 'TransactionException: $message';
}
