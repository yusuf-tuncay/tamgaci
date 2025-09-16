import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/core/errors/error_logger.dart';
import 'package:tamgaci/core/errors/exceptions.dart';
import 'package:tamgaci/core/repositories/base_repository.dart';

/// Base Firebase repository implementation
abstract class FirebaseRepository<T> extends BaseRepositoryImpl<T> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// Get collection reference
  CollectionReference get collection => _firestore.collection(collectionName);

  @override
  Future<List<T>> getAll() async {
    try {
      ErrorLogger.logInfo(
        'Getting all $entityTypeName entities from Firebase',
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );

      final querySnapshot = await collection.get();
      final entities = <T>[];

      for (final doc in querySnapshot.docs) {
        try {
          final entity = mapToEntity(doc.data() as Map<String, dynamic>);
          entities.add(entity);
        } catch (e) {
          ErrorLogger.logError(
            'Error parsing $entityTypeName from Firebase',
            error: e,
            context: 'FirebaseRepository',
            additionalData: {
              'docId': doc.id,
              'collection': collectionName,
            },
          );
        }
      }

      ErrorLogger.logInfo(
        'Successfully retrieved ${entities.length} $entityTypeName entities',
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );

      return entities;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting all $entityTypeName entities from Firebase',
        error: e,
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );
      rethrow;
    }
  }

  @override
  Future<T?> getById(String id) async {
    try {
      ErrorLogger.logInfo(
        'Getting $entityTypeName by ID from Firebase',
        context: 'FirebaseRepository',
        additionalData: {'id': id, 'collection': collectionName},
      );

      final doc = await collection.doc(id).get();

      if (!doc.exists) {
        ErrorLogger.logInfo(
          '$entityTypeName not found',
          context: 'FirebaseRepository',
          additionalData: {'id': id, 'collection': collectionName},
        );
        return null;
      }

      final entity = mapToEntity(doc.data() as Map<String, dynamic>);

      ErrorLogger.logInfo(
        'Successfully retrieved $entityTypeName',
        context: 'FirebaseRepository',
        additionalData: {'id': id, 'collection': collectionName},
      );

      return entity;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting $entityTypeName by ID from Firebase',
        error: e,
        context: 'FirebaseRepository',
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

      // Map is recomputed after setting ID; suppress unused local variable
      final docRef = collection.doc();
      final entityWithId = setEntityId(entity, docRef.id);
      final finalEntityMap = entityToMap(entityWithId);

      ErrorLogger.logInfo(
        'Creating $entityTypeName in Firebase',
        context: 'FirebaseRepository',
        additionalData: {'id': docRef.id, 'collection': collectionName},
      );

      await docRef.set(finalEntityMap);

      ErrorLogger.logInfo(
        'Successfully created $entityTypeName in Firebase',
        context: 'FirebaseRepository',
        additionalData: {'id': docRef.id, 'collection': collectionName},
      );

      return docRef.id;
    } catch (e) {
      ErrorLogger.logError(
        'Error creating $entityTypeName in Firebase',
        error: e,
        context: 'FirebaseRepository',
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
      final entityWithUpdatedTimestamp =
          setEntityUpdatedAt(entity, DateTime.now());
      final entityMap = entityToMap(entityWithUpdatedTimestamp);

      ErrorLogger.logInfo(
        'Updating $entityTypeName in Firebase',
        context: 'FirebaseRepository',
        additionalData: {'id': entityId, 'collection': collectionName},
      );

      await collection.doc(entityId).update(entityMap);

      ErrorLogger.logInfo(
        'Successfully updated $entityTypeName in Firebase',
        context: 'FirebaseRepository',
        additionalData: {'id': entityId, 'collection': collectionName},
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error updating $entityTypeName in Firebase',
        error: e,
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      ErrorLogger.logInfo(
        'Deleting $entityTypeName from Firebase',
        context: 'FirebaseRepository',
        additionalData: {'id': id, 'collection': collectionName},
      );

      await collection.doc(id).delete();

      ErrorLogger.logInfo(
        'Successfully deleted $entityTypeName from Firebase',
        context: 'FirebaseRepository',
        additionalData: {'id': id, 'collection': collectionName},
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error deleting $entityTypeName from Firebase',
        error: e,
        context: 'FirebaseRepository',
        additionalData: {'id': id, 'collection': collectionName},
      );
      rethrow;
    }
  }

  @override
  Future<List<T>> search(String query) async {
    try {
      ErrorLogger.logInfo(
        'Searching $entityTypeName in Firebase',
        context: 'FirebaseRepository',
        additionalData: {'query': query, 'collection': collectionName},
      );

      // Basic search implementation - can be overridden by concrete repositories
      final querySnapshot = await collection.get();
      final entities = <T>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final entity = mapToEntity(data);

        // Simple text search in entity data
        final entityString = data.toString().toLowerCase();
        if (entityString.contains(query.toLowerCase())) {
          entities.add(entity);
        }
      }

      ErrorLogger.logInfo(
        'Found ${entities.length} $entityTypeName entities matching query',
        context: 'FirebaseRepository',
        additionalData: {'query': query, 'collection': collectionName},
      );

      return entities;
    } catch (e) {
      ErrorLogger.logError(
        'Error searching $entityTypeName in Firebase',
        error: e,
        context: 'FirebaseRepository',
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
        'Getting paginated $entityTypeName from Firebase',
        context: 'FirebaseRepository',
        additionalData: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
          'ascending': ascending,
          'collection': collectionName,
        },
      );

      Query query = collection.limit(limit * page);

      if (sortBy != null) {
        query = query.orderBy(sortBy, descending: !ascending);
      }

      final querySnapshot = await query.get();
      final entities = <T>[];

      for (final doc in querySnapshot.docs) {
        try {
          final entity = mapToEntity(doc.data() as Map<String, dynamic>);
          entities.add(entity);
        } catch (e) {
          ErrorLogger.logError(
            'Error parsing $entityTypeName from Firebase',
            error: e,
            context: 'FirebaseRepository',
            additionalData: {
              'docId': doc.id,
              'collection': collectionName,
            },
          );
        }
      }

      // Apply pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedEntities = entities.length > startIndex
          ? entities.sublist(startIndex,
              endIndex > entities.length ? entities.length : endIndex)
          : <T>[];

      ErrorLogger.logInfo(
        'Successfully retrieved ${paginatedEntities.length} $entityTypeName entities (page $page)',
        context: 'FirebaseRepository',
        additionalData: {
          'page': page,
          'limit': limit,
          'collection': collectionName,
        },
      );

      return paginatedEntities;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting paginated $entityTypeName from Firebase',
        error: e,
        context: 'FirebaseRepository',
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

  /// Get entities by field value
  Future<List<T>> getByField(String field, dynamic value) async {
    try {
      ErrorLogger.logInfo(
        'Getting $entityTypeName by field from Firebase',
        context: 'FirebaseRepository',
        additionalData: {
          'field': field,
          'value': value.toString(),
          'collection': collectionName,
        },
      );

      final querySnapshot =
          await collection.where(field, isEqualTo: value).get();
      final entities = <T>[];

      for (final doc in querySnapshot.docs) {
        try {
          final entity = mapToEntity(doc.data() as Map<String, dynamic>);
          entities.add(entity);
        } catch (e) {
          ErrorLogger.logError(
            'Error parsing $entityTypeName from Firebase',
            error: e,
            context: 'FirebaseRepository',
            additionalData: {
              'docId': doc.id,
              'collection': collectionName,
            },
          );
        }
      }

      ErrorLogger.logInfo(
        'Found ${entities.length} $entityTypeName entities with $field = $value',
        context: 'FirebaseRepository',
        additionalData: {
          'field': field,
          'value': value.toString(),
          'collection': collectionName,
        },
      );

      return entities;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting $entityTypeName by field from Firebase',
        error: e,
        context: 'FirebaseRepository',
        additionalData: {
          'field': field,
          'value': value.toString(),
          'collection': collectionName,
        },
      );
      rethrow;
    }
  }

  /// Get entities by multiple field values
  Future<List<T>> getByFields(Map<String, dynamic> fields) async {
    try {
      ErrorLogger.logInfo(
        'Getting $entityTypeName by fields from Firebase',
        context: 'FirebaseRepository',
        additionalData: {
          'fields': fields,
          'collection': collectionName,
        },
      );

      Query query = collection;

      for (final entry in fields.entries) {
        query = query.where(entry.key, isEqualTo: entry.value);
      }

      final querySnapshot = await query.get();
      final entities = <T>[];

      for (final doc in querySnapshot.docs) {
        try {
          final entity = mapToEntity(doc.data() as Map<String, dynamic>);
          entities.add(entity);
        } catch (e) {
          ErrorLogger.logError(
            'Error parsing $entityTypeName from Firebase',
            error: e,
            context: 'FirebaseRepository',
            additionalData: {
              'docId': doc.id,
              'collection': collectionName,
            },
          );
        }
      }

      ErrorLogger.logInfo(
        'Found ${entities.length} $entityTypeName entities with specified fields',
        context: 'FirebaseRepository',
        additionalData: {
          'fields': fields,
          'collection': collectionName,
        },
      );

      return entities;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting $entityTypeName by fields from Firebase',
        error: e,
        context: 'FirebaseRepository',
        additionalData: {
          'fields': fields,
          'collection': collectionName,
        },
      );
      rethrow;
    }
  }

  /// Watch entities in real-time
  Stream<List<T>> watchAll() {
    return collection.snapshots().map((snapshot) {
      final entities = <T>[];

      for (final doc in snapshot.docs) {
        try {
          final entity = mapToEntity(doc.data() as Map<String, dynamic>);
          entities.add(entity);
        } catch (e) {
          ErrorLogger.logError(
            'Error parsing $entityTypeName from Firebase stream',
            error: e,
            context: 'FirebaseRepository',
            additionalData: {
              'docId': doc.id,
              'collection': collectionName,
            },
          );
        }
      }

      return entities;
    });
  }

  /// Watch entity by ID in real-time
  Stream<T?> watchById(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }

      try {
        return mapToEntity(doc.data() as Map<String, dynamic>);
      } catch (e) {
        ErrorLogger.logError(
          'Error parsing $entityTypeName from Firebase stream',
          error: e,
          context: 'FirebaseRepository',
          additionalData: {
            'docId': doc.id,
            'collection': collectionName,
          },
        );
        return null;
      }
    });
  }

  /// Batch create entities
  Future<List<String>> batchCreate(List<T> entities) async {
    try {
      ErrorLogger.logInfo(
        'Batch creating ${entities.length} $entityTypeName entities in Firebase',
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );

      final batch = _firestore.batch();
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

        final docRef = collection.doc();
        final entityWithId = setEntityId(entity, docRef.id);
        final entityMap = entityToMap(entityWithId);

        batch.set(docRef, entityMap);
        ids.add(docRef.id);
      }

      await batch.commit();

      ErrorLogger.logInfo(
        'Successfully batch created ${entities.length} $entityTypeName entities in Firebase',
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );

      return ids;
    } catch (e) {
      ErrorLogger.logError(
        'Error batch creating $entityTypeName entities in Firebase',
        error: e,
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );
      rethrow;
    }
  }

  /// Batch update entities
  Future<void> batchUpdate(List<T> entities) async {
    try {
      ErrorLogger.logInfo(
        'Batch updating ${entities.length} $entityTypeName entities in Firebase',
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );

      final batch = _firestore.batch();

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
        final entityMap = entityToMap(entityWithUpdatedTimestamp);

        batch.update(collection.doc(entityId), entityMap);
      }

      await batch.commit();

      ErrorLogger.logInfo(
        'Successfully batch updated ${entities.length} $entityTypeName entities in Firebase',
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error batch updating $entityTypeName entities in Firebase',
        error: e,
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );
      rethrow;
    }
  }

  /// Batch delete entities
  Future<void> batchDelete(List<String> ids) async {
    try {
      ErrorLogger.logInfo(
        'Batch deleting ${ids.length} $entityTypeName entities from Firebase',
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );

      final batch = _firestore.batch();

      for (final id in ids) {
        batch.delete(collection.doc(id));
      }

      await batch.commit();

      ErrorLogger.logInfo(
        'Successfully batch deleted ${ids.length} $entityTypeName entities from Firebase',
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error batch deleting $entityTypeName entities from Firebase',
        error: e,
        context: 'FirebaseRepository',
        additionalData: {'collection': collectionName},
      );
      rethrow;
    }
  }
}
