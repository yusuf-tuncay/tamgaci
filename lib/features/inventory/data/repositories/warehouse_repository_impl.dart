// ========== WAREHOUSE REPOSITORY IMPLEMENTATION ==========
// lib/features/inventory/data/repositories/warehouse_repository_impl.dart

import 'package:tamgaci/core/repositories/firebase_repository.dart';
import 'package:tamgaci/features/inventory/domain/entities/warehouse.dart';
import 'package:tamgaci/features/inventory/domain/repositories/warehouse_repository.dart';

/// Firebase Warehouse Repository Implementation
class WarehouseRepositoryImpl extends FirebaseRepository<Warehouse>
    implements WarehouseRepository {
  static const String _warehousesCollection = 'warehouses';

  @override
  String get collectionName => _warehousesCollection;

  @override
  String get entityTypeName => 'Warehouse';

  @override
  Map<String, dynamic> entityToMap(Warehouse entity) => entity.toMap();

  @override
  Warehouse mapToEntity(Map<String, dynamic> map) => Warehouse.fromMap(map);

  @override
  String getEntityId(Warehouse entity) => entity.id;

  @override
  Warehouse setEntityId(Warehouse entity, String id) => entity.copyWith(id: id);

  @override
  DateTime getEntityCreatedAt(Warehouse entity) => entity.createdAt;

  @override
  DateTime getEntityUpdatedAt(Warehouse entity) => entity.updatedAt;

  @override
  Warehouse setEntityUpdatedAt(Warehouse entity, DateTime timestamp) =>
      entity.copyWith(updatedAt: timestamp);

  @override
  String getEntityCreatedBy(Warehouse entity) => '';

  @override
  String? getEntityUpdatedBy(Warehouse entity) => null;

  @override
  Warehouse setEntityUpdatedBy(Warehouse entity, String userId) => entity;

  @override
  Future<List<Warehouse>> getAllWarehouses() async {
    try {
      final snapshot = await firestore
          .collection(_warehousesCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Warehouse.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get all warehouses: $e');
    }
  }

  @override
  Future<List<Warehouse>> getActiveWarehouses() async {
    try {
      final snapshot = await firestore
          .collection(_warehousesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Warehouse.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get active warehouses: $e');
    }
  }

  @override
  Future<Warehouse?> getDefaultWarehouse() async {
    try {
      final snapshot = await firestore
          .collection(_warehousesCollection)
          .where('isDefault', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Warehouse.fromMap(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get default warehouse: $e');
    }
  }

  @override
  Future<Warehouse?> getWarehouseById(String id) async {
    try {
      final doc = await firestore
          .collection(_warehousesCollection)
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        return Warehouse.fromMap(doc.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get warehouse by id: $e');
    }
  }

  @override
  Future<Warehouse?> getWarehouseByCode(String code) async {
    try {
      final doc = await firestore
          .collection(_warehousesCollection)
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        return Warehouse.fromMap(doc.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get warehouse by code: $e');
    }
  }

  @override
  Future<Warehouse> createWarehouse(Warehouse warehouse) async {
    try {
      // Generate new ID
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      final newWarehouse = warehouse.copyWith(
        id: newId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestore
          .collection(_warehousesCollection)
          .doc(newId.toString())
          .set(newWarehouse.toMap());

      return newWarehouse;
    } catch (e) {
      throw Exception('Failed to create warehouse: $e');
    }
  }

  @override
  Future<Warehouse> updateWarehouse(Warehouse warehouse) async {
    try {
      final updatedWarehouse = warehouse.copyWith(updatedAt: DateTime.now());

      await firestore
          .collection(_warehousesCollection)
          .doc(warehouse.id.toString())
          .update(updatedWarehouse.toMap());

      return updatedWarehouse;
    } catch (e) {
      throw Exception('Failed to update warehouse: $e');
    }
  }

  @override
  Future<void> deleteWarehouse(String id) async {
    try {
      await firestore.collection(_warehousesCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete warehouse: $e');
    }
  }

  @override
  Future<int> getWarehouseCount() async {
    try {
      final snapshot = await firestore.collection(_warehousesCollection).get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get warehouse count: $e');
    }
  }

  @override
  Future<int> getActiveWarehouseCount() async {
    try {
      final snapshot = await firestore
          .collection(_warehousesCollection)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get active warehouse count: $e');
    }
  }

  // ========== FIREBASE REPOSITORY IMPLEMENTATION ==========

  // These methods are not part of the base interface; keep non-override helpers.
  Warehouse fromFirestore(Map<String, dynamic> data) {
    return Warehouse.fromMap(data);
  }

  Map<String, dynamic> toFirestore(Warehouse entity) {
    return entity.toMap();
  }
}
