import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamgaci/core/errors/error_logger.dart';
import 'package:tamgaci/core/errors/exceptions.dart';
import 'package:tamgaci/core/repositories/base_repository.dart';

/// Cache repository for local data storage
abstract class CacheRepository<T> extends BaseRepositoryImpl<T> {
  static const String _cachePrefix = 'tamgaci_cache_';
  static const String _cacheTimestampPrefix = 'tamgaci_timestamp_';
  static const Duration _defaultCacheExpiry = Duration(hours: 1);

  /// Get cache key for entity type
  String get cacheKey => '$_cachePrefix${entityTypeName.toLowerCase()}';

  /// Get cache timestamp key
  String get cacheTimestampKey =>
      '$_cacheTimestampPrefix${entityTypeName.toLowerCase()}';

  /// Get cache expiry duration
  Duration get cacheExpiry => _defaultCacheExpiry;

  /// Convert entity to JSON string
  String entityToJson(T entity);

  /// Convert JSON string to entity
  T jsonToEntity(String json);

  /// Convert entity list to JSON string
  String entityListToJson(List<T> entities);

  /// Convert JSON string to entity list
  List<T> jsonToEntityList(String json);

  @override
  Future<List<T>> getAll() async {
    try {
      ErrorLogger.logInfo(
        'Getting all $entityTypeName entities from cache',
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(cacheKey);

      if (jsonString == null) {
        ErrorLogger.logInfo(
          'No cached data found for $entityTypeName',
          context: 'CacheRepository',
          additionalData: {'cacheKey': cacheKey},
        );
        return [];
      }

      // Check if cache is expired
      if (await _isCacheExpired()) {
        ErrorLogger.logInfo(
          'Cache expired for $entityTypeName, clearing cache',
          context: 'CacheRepository',
          additionalData: {'cacheKey': cacheKey},
        );
        await clearCache();
        return [];
      }

      final entities = jsonToEntityList(jsonString);

      ErrorLogger.logInfo(
        'Successfully retrieved ${entities.length} $entityTypeName entities from cache',
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );

      return entities;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting all $entityTypeName entities from cache',
        error: e,
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
      return [];
    }
  }

  @override
  Future<T?> getById(String id) async {
    try {
      ErrorLogger.logInfo(
        'Getting $entityTypeName by ID from cache',
        context: 'CacheRepository',
        additionalData: {'id': id, 'cacheKey': cacheKey},
      );

      final entities = await getAll();
      final entity = entities.where((e) => getEntityId(e) == id).firstOrNull;

      if (entity == null) {
        ErrorLogger.logInfo(
          '$entityTypeName not found in cache',
          context: 'CacheRepository',
          additionalData: {'id': id, 'cacheKey': cacheKey},
        );
      } else {
        ErrorLogger.logInfo(
          'Successfully retrieved $entityTypeName from cache',
          context: 'CacheRepository',
          additionalData: {'id': id, 'cacheKey': cacheKey},
        );
      }

      return entity;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting $entityTypeName by ID from cache',
        error: e,
        context: 'CacheRepository',
        additionalData: {'id': id, 'cacheKey': cacheKey},
      );
      return null;
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

      final entityId = getEntityId(entity);
      if (entityId.isEmpty) {
        throw ValidationException('Entity ID is required');
      }

      ErrorLogger.logInfo(
        'Creating $entityTypeName in cache',
        context: 'CacheRepository',
        additionalData: {'id': entityId, 'cacheKey': cacheKey},
      );

      final entities = await getAll();
      entities.add(entity);
      await _saveEntities(entities);

      ErrorLogger.logInfo(
        'Successfully created $entityTypeName in cache',
        context: 'CacheRepository',
        additionalData: {'id': entityId, 'cacheKey': cacheKey},
      );

      return entityId;
    } catch (e) {
      ErrorLogger.logError(
        'Error creating $entityTypeName in cache',
        error: e,
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
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
      final entityWithUpdatedTimestamp =
          setEntityUpdatedAt(entity, DateTime.now());

      ErrorLogger.logInfo(
        'Updating $entityTypeName in cache',
        context: 'CacheRepository',
        additionalData: {'id': entityId, 'cacheKey': cacheKey},
      );

      final entities = await getAll();
      final index = entities.indexWhere((e) => getEntityId(e) == entityId);

      if (index == -1) {
        throw Exception('Entity not found in cache');
      }

      entities[index] = entityWithUpdatedTimestamp;
      await _saveEntities(entities);

      ErrorLogger.logInfo(
        'Successfully updated $entityTypeName in cache',
        context: 'CacheRepository',
        additionalData: {'id': entityId, 'cacheKey': cacheKey},
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error updating $entityTypeName in cache',
        error: e,
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      ErrorLogger.logInfo(
        'Deleting $entityTypeName from cache',
        context: 'CacheRepository',
        additionalData: {'id': id, 'cacheKey': cacheKey},
      );

      final entities = await getAll();
      entities.removeWhere((e) => getEntityId(e) == id);
      await _saveEntities(entities);

      ErrorLogger.logInfo(
        'Successfully deleted $entityTypeName from cache',
        context: 'CacheRepository',
        additionalData: {'id': id, 'cacheKey': cacheKey},
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error deleting $entityTypeName from cache',
        error: e,
        context: 'CacheRepository',
        additionalData: {'id': id, 'cacheKey': cacheKey},
      );
      rethrow;
    }
  }

  @override
  Future<List<T>> search(String query) async {
    try {
      ErrorLogger.logInfo(
        'Searching $entityTypeName in cache',
        context: 'CacheRepository',
        additionalData: {'query': query, 'cacheKey': cacheKey},
      );

      final entities = await getAll();
      final filteredEntities = entities.where((entity) {
        final entityString = entityToJson(entity).toLowerCase();
        return entityString.contains(query.toLowerCase());
      }).toList();

      ErrorLogger.logInfo(
        'Found ${filteredEntities.length} $entityTypeName entities matching query in cache',
        context: 'CacheRepository',
        additionalData: {'query': query, 'cacheKey': cacheKey},
      );

      return filteredEntities;
    } catch (e) {
      ErrorLogger.logError(
        'Error searching $entityTypeName in cache',
        error: e,
        context: 'CacheRepository',
        additionalData: {'query': query, 'cacheKey': cacheKey},
      );
      return [];
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
        'Getting paginated $entityTypeName from cache',
        context: 'CacheRepository',
        additionalData: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
          'ascending': ascending,
          'cacheKey': cacheKey,
        },
      );

      final entities = await getAll();

      // Sort entities if sortBy is specified
      if (sortBy != null) {
        entities.sort((a, b) {
          final aValue = _getFieldValue(a, sortBy);
          final bValue = _getFieldValue(b, sortBy);

          if (aValue == null && bValue == null) return 0;
          if (aValue == null) return ascending ? -1 : 1;
          if (bValue == null) return ascending ? 1 : -1;

          final comparison = _compareValues(aValue, bValue);
          return ascending ? comparison : -comparison;
        });
      }

      // Apply pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedEntities = entities.length > startIndex
          ? entities.sublist(startIndex,
              endIndex > entities.length ? entities.length : endIndex)
          : <T>[];

      ErrorLogger.logInfo(
        'Successfully retrieved ${paginatedEntities.length} $entityTypeName entities (page $page) from cache',
        context: 'CacheRepository',
        additionalData: {
          'page': page,
          'limit': limit,
          'cacheKey': cacheKey,
        },
      );

      return paginatedEntities;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting paginated $entityTypeName from cache',
        error: e,
        context: 'CacheRepository',
        additionalData: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
          'ascending': ascending,
          'cacheKey': cacheKey,
        },
      );
      return [];
    }
  }

  /// Save entities to cache
  Future<void> _saveEntities(List<T> entities) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = entityListToJson(entities);

      await prefs.setString(cacheKey, jsonString);
      await prefs.setString(
          cacheTimestampKey, DateTime.now().toIso8601String());

      ErrorLogger.logInfo(
        'Saved ${entities.length} $entityTypeName entities to cache',
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error saving $entityTypeName entities to cache',
        error: e,
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
      rethrow;
    }
  }

  /// Check if cache is expired
  Future<bool> _isCacheExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(cacheTimestampKey);

      if (timestampString == null) {
        return true;
      }

      final timestamp = DateTime.parse(timestampString);
      final now = DateTime.now();

      return now.difference(timestamp) > cacheExpiry;
    } catch (e) {
      ErrorLogger.logError(
        'Error checking cache expiry for $entityTypeName',
        error: e,
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
      return true;
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(cacheKey);
      await prefs.remove(cacheTimestampKey);

      ErrorLogger.logInfo(
        'Cleared cache for $entityTypeName',
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error clearing cache for $entityTypeName',
        error: e,
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
      rethrow;
    }
  }

  /// Get cache info
  Future<CacheInfo> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(cacheTimestampKey);
      final entities = await getAll();

      DateTime? timestamp;
      if (timestampString != null) {
        timestamp = DateTime.parse(timestampString);
      }

      return CacheInfo(
        entityCount: entities.length,
        lastUpdated: timestamp,
        isExpired: await _isCacheExpired(),
        expiryDuration: cacheExpiry,
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cache info for $entityTypeName',
        error: e,
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
      return CacheInfo(
        entityCount: 0,
        lastUpdated: null,
        isExpired: true,
        expiryDuration: cacheExpiry,
      );
    }
  }

  /// Get field value from entity for sorting
  dynamic _getFieldValue(T entity, String fieldName) {
    try {
      final entityMap = entityToMap(entity);
      return entityMap[fieldName];
    } catch (e) {
      return null;
    }
  }

  /// Compare values for sorting
  int _compareValues(dynamic a, dynamic b) {
    if (a is String && b is String) {
      return a.compareTo(b);
    } else if (a is num && b is num) {
      return a.compareTo(b);
    } else if (a is DateTime && b is DateTime) {
      return a.compareTo(b);
    } else {
      return a.toString().compareTo(b.toString());
    }
  }

  /// Batch create entities
  Future<List<String>> batchCreate(List<T> entities) async {
    try {
      ErrorLogger.logInfo(
        'Batch creating ${entities.length} $entityTypeName entities in cache',
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );

      final existingEntities = await getAll();
      final ids = <String>[];

      for (final entity in entities) {
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
        if (entityId.isEmpty) {
          throw ValidationException('Entity ID is required');
        }

        existingEntities.add(entity);
        ids.add(entityId);
      }

      await _saveEntities(existingEntities);

      ErrorLogger.logInfo(
        'Successfully batch created ${entities.length} $entityTypeName entities in cache',
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );

      return ids;
    } catch (e) {
      ErrorLogger.logError(
        'Error batch creating $entityTypeName entities in cache',
        error: e,
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
      rethrow;
    }
  }

  /// Batch update entities
  Future<void> batchUpdate(List<T> entities) async {
    try {
      ErrorLogger.logInfo(
        'Batch updating ${entities.length} $entityTypeName entities in cache',
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );

      final existingEntities = await getAll();

      for (final entity in entities) {
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
        final entityWithUpdatedTimestamp =
            setEntityUpdatedAt(entity, DateTime.now());

        final index =
            existingEntities.indexWhere((e) => getEntityId(e) == entityId);
        if (index != -1) {
          existingEntities[index] = entityWithUpdatedTimestamp;
        }
      }

      await _saveEntities(existingEntities);

      ErrorLogger.logInfo(
        'Successfully batch updated ${entities.length} $entityTypeName entities in cache',
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error batch updating $entityTypeName entities in cache',
        error: e,
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
      rethrow;
    }
  }

  /// Batch delete entities
  Future<void> batchDelete(List<String> ids) async {
    try {
      ErrorLogger.logInfo(
        'Batch deleting ${ids.length} $entityTypeName entities from cache',
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );

      final entities = await getAll();
      entities.removeWhere((entity) => ids.contains(getEntityId(entity)));
      await _saveEntities(entities);

      ErrorLogger.logInfo(
        'Successfully batch deleted ${ids.length} $entityTypeName entities from cache',
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error batch deleting $entityTypeName entities from cache',
        error: e,
        context: 'CacheRepository',
        additionalData: {'cacheKey': cacheKey},
      );
      rethrow;
    }
  }
}

/// Cache info class
class CacheInfo {
  final int entityCount;
  final DateTime? lastUpdated;
  final bool isExpired;
  final Duration expiryDuration;

  const CacheInfo({
    required this.entityCount,
    required this.lastUpdated,
    required this.isExpired,
    required this.expiryDuration,
  });

  @override
  String toString() {
    return 'CacheInfo(entityCount: $entityCount, lastUpdated: $lastUpdated, isExpired: $isExpired, expiryDuration: $expiryDuration)';
  }
}
