import 'package:tamgaci/core/errors/error_logger.dart';
import 'package:tamgaci/core/errors/exceptions.dart';
import 'package:tamgaci/core/validation/business_rules.dart';

/// Base repository interface for all repositories
abstract class BaseRepository<T> {
  /// Get all entities
  Future<List<T>> getAll();

  /// Get entity by ID
  Future<T?> getById(String id);

  /// Create new entity
  Future<String> create(T entity);

  /// Update existing entity
  Future<void> update(T entity);

  /// Delete entity by ID
  Future<void> delete(String id);

  /// Check if entity exists
  Future<bool> exists(String id);

  /// Get count of entities
  Future<int> getCount();

  /// Search entities
  Future<List<T>> search(String query);

  /// Get entities with pagination
  Future<List<T>> getPaginated({
    int page = 1,
    int limit = 20,
    String? sortBy,
    bool ascending = true,
  });

  /// Validate entity before operations
  Future<ValidationResult> validateEntity(T entity);

  /// Validate business rules
  Future<BusinessRuleResult> validateBusinessRules(T entity);
}

/// Base repository implementation with common functionality
abstract class BaseRepositoryImpl<T> implements BaseRepository<T> {
  /// Get entity type name for logging
  String get entityTypeName;

  /// Get collection name for Firebase
  String get collectionName;

  /// Convert entity to map for storage
  Map<String, dynamic> entityToMap(T entity);

  /// Convert map to entity
  T mapToEntity(Map<String, dynamic> map);

  /// Get entity ID
  String getEntityId(T entity);

  /// Set entity ID
  T setEntityId(T entity, String id);

  /// Get entity creation timestamp
  DateTime getEntityCreatedAt(T entity);

  /// Get entity update timestamp
  DateTime getEntityUpdatedAt(T entity);

  /// Set entity update timestamp
  T setEntityUpdatedAt(T entity, DateTime timestamp);

  /// Get entity created by
  String getEntityCreatedBy(T entity);

  /// Get entity updated by
  String? getEntityUpdatedBy(T entity);

  /// Set entity updated by
  T setEntityUpdatedBy(T entity, String userId);

  @override
  Future<List<T>> getAll() async {
    try {
      ErrorLogger.logInfo(
        'Getting all $entityTypeName entities',
        context: 'BaseRepository',
        additionalData: {'collection': collectionName},
      );

      // This will be implemented by concrete repositories
      throw UnimplementedError(
          'getAll must be implemented by concrete repository');
    } catch (e) {
      ErrorLogger.logError(
        'Error getting all $entityTypeName entities',
        error: e,
        context: 'BaseRepository',
        additionalData: {'collection': collectionName},
      );
      rethrow;
    }
  }

  @override
  Future<T?> getById(String id) async {
    try {
      ErrorLogger.logInfo(
        'Getting $entityTypeName by ID',
        context: 'BaseRepository',
        additionalData: {'id': id, 'collection': collectionName},
      );

      // This will be implemented by concrete repositories
      throw UnimplementedError(
          'getById must be implemented by concrete repository');
    } catch (e) {
      ErrorLogger.logError(
        'Error getting $entityTypeName by ID',
        error: e,
        context: 'BaseRepository',
        additionalData: {'id': id, 'collection': collectionName},
      );
      rethrow;
    }
  }

  @override
  Future<String> create(T entity) async {
    try {
      // Validate entity
      final validationResult = await validateEntity(entity);
      if (!validationResult.isValid) {
        throw ValidationException(validationResult.errors.join(', '));
      }

      // Validate business rules
      final businessRuleResult = await validateBusinessRules(entity);
      if (!businessRuleResult.isValid) {
        throw BusinessRuleException(businessRuleResult.errors.join(', '));
      }

      ErrorLogger.logInfo(
        'Creating $entityTypeName',
        context: 'BaseRepository',
        additionalData: {'collection': collectionName},
      );

      // This will be implemented by concrete repositories
      throw UnimplementedError(
          'create must be implemented by concrete repository');
    } catch (e) {
      ErrorLogger.logError(
        'Error creating $entityTypeName',
        error: e,
        context: 'BaseRepository',
        additionalData: {'collection': collectionName},
      );
      rethrow;
    }
  }

  @override
  Future<void> update(T entity) async {
    try {
      // Validate entity
      final validationResult = await validateEntity(entity);
      if (!validationResult.isValid) {
        throw ValidationException(validationResult.errors.join(', '));
      }

      // Validate business rules
      final businessRuleResult = await validateBusinessRules(entity);
      if (!businessRuleResult.isValid) {
        throw BusinessRuleException(businessRuleResult.errors.join(', '));
      }

      final entityId = getEntityId(entity);
      ErrorLogger.logInfo(
        'Updating $entityTypeName',
        context: 'BaseRepository',
        additionalData: {'id': entityId, 'collection': collectionName},
      );

      // This will be implemented by concrete repositories
      throw UnimplementedError(
          'update must be implemented by concrete repository');
    } catch (e) {
      ErrorLogger.logError(
        'Error updating $entityTypeName',
        error: e,
        context: 'BaseRepository',
        additionalData: {'collection': collectionName},
      );
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      ErrorLogger.logInfo(
        'Deleting $entityTypeName',
        context: 'BaseRepository',
        additionalData: {'id': id, 'collection': collectionName},
      );

      // This will be implemented by concrete repositories
      throw UnimplementedError(
          'delete must be implemented by concrete repository');
    } catch (e) {
      ErrorLogger.logError(
        'Error deleting $entityTypeName',
        error: e,
        context: 'BaseRepository',
        additionalData: {'id': id, 'collection': collectionName},
      );
      rethrow;
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final entity = await getById(id);
      return entity != null;
    } catch (e) {
      ErrorLogger.logError(
        'Error checking if $entityTypeName exists',
        error: e,
        context: 'BaseRepository',
        additionalData: {'id': id, 'collection': collectionName},
      );
      return false;
    }
  }

  @override
  Future<int> getCount() async {
    try {
      final entities = await getAll();
      return entities.length;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting $entityTypeName count',
        error: e,
        context: 'BaseRepository',
        additionalData: {'collection': collectionName},
      );
      return 0;
    }
  }

  @override
  Future<List<T>> search(String query) async {
    try {
      ErrorLogger.logInfo(
        'Searching $entityTypeName',
        context: 'BaseRepository',
        additionalData: {'query': query, 'collection': collectionName},
      );

      // This will be implemented by concrete repositories
      throw UnimplementedError(
          'search must be implemented by concrete repository');
    } catch (e) {
      ErrorLogger.logError(
        'Error searching $entityTypeName',
        error: e,
        context: 'BaseRepository',
        additionalData: {'query': query, 'collection': collectionName},
      );
      rethrow;
    }
  }

  @override
  Future<List<T>> getPaginated({
    int page = 1,
    int limit = 20,
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      ErrorLogger.logInfo(
        'Getting paginated $entityTypeName',
        context: 'BaseRepository',
        additionalData: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
          'ascending': ascending,
          'collection': collectionName,
        },
      );

      // This will be implemented by concrete repositories
      throw UnimplementedError(
          'getPaginated must be implemented by concrete repository');
    } catch (e) {
      ErrorLogger.logError(
        'Error getting paginated $entityTypeName',
        error: e,
        context: 'BaseRepository',
        additionalData: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
          'ascending': ascending,
          'collection': collectionName,
        },
      );
      rethrow;
    }
  }

  @override
  Future<ValidationResult> validateEntity(T entity) async {
    try {
      // Basic validation - can be overridden by concrete repositories
      final errors = <String>[];

      // Check required fields
      if (getEntityId(entity).isEmpty) {
        errors.add('Entity ID is required');
      }

      if (getEntityCreatedBy(entity).isEmpty) {
        errors.add('Created by is required');
      }

      return ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error validating $entityTypeName',
        error: e,
        context: 'BaseRepository',
      );
      return ValidationResult(
        isValid: false,
        errors: ['Validation error: $e'],
      );
    }
  }

  @override
  Future<BusinessRuleResult> validateBusinessRules(T entity) async {
    try {
      // Basic business rules - can be overridden by concrete repositories
      final entityMap = entityToMap(entity);
      return BusinessRules.validateGeneralRules(entityMap, entityTypeName);
    } catch (e) {
      ErrorLogger.logError(
        'Error validating business rules for $entityTypeName',
        error: e,
        context: 'BaseRepository',
      );
      return BusinessRuleResult(
        isValid: false,
        errors: ['Business rule validation error: $e'],
      );
    }
  }
}

/// Validation result class
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  @override
  String toString() {
    return isValid ? 'Valid' : 'Invalid: ${errors.join(', ')}';
  }
}

