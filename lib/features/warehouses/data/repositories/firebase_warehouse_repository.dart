import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../models/firebase_warehouse_entity.dart';

/// Firebase Warehouse Repository Implementation
class FirebaseWarehouseRepository implements WarehouseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tenant ID'yi al
  Future<String> _tenantId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      throw Exception('User document not found');
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final tenantId = userData['tenantId'] as String?;

    if (tenantId == null || tenantId.isEmpty) {
      throw Exception('User is not assigned to any tenant');
    }

    return tenantId;
  }

  /// User ID'yi al
  String? _uid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Future<List<Warehouse>> getWarehouses() async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirebaseWarehouseEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting warehouses', e);
      rethrow;
    }
  }

  @override
  Future<List<Warehouse>> getActiveWarehouses() async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirebaseWarehouseEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting active warehouses', e);
      rethrow;
    }
  }

  @override
  Future<Warehouse?> getWarehouseById(String id) async {
    try {
      final tenantId = await _tenantId();
      final doc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .doc(id)
          .get();

      if (!doc.exists) return null;

      return FirebaseWarehouseEntity.fromFirestore(doc).toDomain();
    } catch (e) {
      AppLogger.error('Error getting warehouse by id', e);
      rethrow;
    }
  }

  @override
  Future<List<Warehouse>> getWarehousesByType(WarehouseType type) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirebaseWarehouseEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting warehouses by type', e);
      rethrow;
    }
  }

  @override
  Future<List<Warehouse>> getWarehousesByStatus(WarehouseStatus status) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirebaseWarehouseEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting warehouses by status', e);
      rethrow;
    }
  }

  @override
  Future<List<Warehouse>> getWarehousesByCity(String city) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .where('city', isEqualTo: city)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirebaseWarehouseEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting warehouses by city', e);
      rethrow;
    }
  }

  @override
  Future<List<Warehouse>> searchWarehouses(String query) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .orderBy('name')
          .startAt([query]).endAt(['$query\uf8ff']).get();

      return snapshot.docs
          .map((doc) => FirebaseWarehouseEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error searching warehouses', e);
      rethrow;
    }
  }

  @override
  Future<String> createWarehouse(Warehouse warehouse) async {
    try {
      final tenantId = await _tenantId();
      final userId = _uid();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final warehouseWithTenant = warehouse.copyWith(
        tenantId: tenantId,
        createdBy: userId,
        updatedBy: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final warehouseEntity =
          FirebaseWarehouseEntity.fromDomain(warehouseWithTenant);
      final docRef = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .add(warehouseEntity.toFirestore());

      AppLogger.info('Warehouse created successfully: ${warehouse.name}');
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating warehouse', e);
      rethrow;
    }
  }

  @override
  Future<void> updateWarehouse(Warehouse warehouse) async {
    try {
      final tenantId = await _tenantId();
      final userId = _uid();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final warehouseWithTenant = warehouse.copyWith(
        tenantId: tenantId,
        updatedBy: userId,
        updatedAt: DateTime.now(),
      );

      final warehouseEntity =
          FirebaseWarehouseEntity.fromDomain(warehouseWithTenant);
      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .doc(warehouse.id)
          .update(warehouseEntity.toFirestore());

      AppLogger.info('Warehouse updated successfully: ${warehouse.name}');
    } catch (e) {
      AppLogger.error('Error updating warehouse', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteWarehouse(String id) async {
    try {
      final tenantId = await _tenantId();

      // Önce depoyu kontrol et
      final warehouseDoc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .doc(id)
          .get();

      if (!warehouseDoc.exists) {
        throw Exception('Depo bulunamadı');
      }

      final warehouseData = warehouseDoc.data() as Map<String, dynamic>;
      final isDefault = warehouseData['isDefault'] as bool? ?? false;

      if (isDefault) {
        throw Exception('Varsayılan depolar silinemez');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .doc(id)
          .delete();

      AppLogger.info('Warehouse deleted successfully: $id');
    } catch (e) {
      AppLogger.error('Error deleting warehouse', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getWarehouseStatistics() async {
    try {
      final warehouses = await getWarehouses();

      int totalWarehouses = warehouses.length;
      int activeWarehouses = warehouses.where((w) => w.isActive).length;
      int inactiveWarehouses = warehouses.where((w) => !w.isActive).length;

      Map<WarehouseType, int> warehousesByType = {};
      Map<WarehouseStatus, int> warehousesByStatus = {};
      Map<String, int> warehousesByCity = {};

      for (final warehouse in warehouses) {
        // Türüne göre sayım
        warehousesByType[warehouse.type] =
            (warehousesByType[warehouse.type] ?? 0) + 1;

        // Durumuna göre sayım
        warehousesByStatus[warehouse.status] =
            (warehousesByStatus[warehouse.status] ?? 0) + 1;

        // Şehre göre sayım
        if (warehouse.city != null) {
          warehousesByCity[warehouse.city!] =
              (warehousesByCity[warehouse.city!] ?? 0) + 1;
        }
      }

      return {
        'totalWarehouses': totalWarehouses,
        'activeWarehouses': activeWarehouses,
        'inactiveWarehouses': inactiveWarehouses,
        'warehousesByType': warehousesByType,
        'warehousesByStatus': warehousesByStatus,
        'warehousesByCity': warehousesByCity,
      };
    } catch (e) {
      AppLogger.error('Error getting warehouse statistics', e);
      rethrow;
    }
  }
}
