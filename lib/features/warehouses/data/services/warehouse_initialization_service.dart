import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import '../../domain/entities/warehouse.dart';
import '../models/firebase_warehouse_entity.dart';

/// Depo Başlatma Servisi
class WarehouseInitializationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Kullanıcı için varsayılan depo oluştur
  Future<void> createDefaultWarehouseForUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppLogger.warning(
            'User not authenticated, skipping default warehouse creation');
        return;
      }

      // Kullanıcının tenantId'sini al
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        AppLogger.warning(
            'User document not found, skipping default warehouse creation');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String?;

      if (tenantId == null || tenantId.isEmpty) {
        AppLogger.warning(
            'User has no tenantId, skipping default warehouse creation');
        return;
      }

      await _createDefaultWarehouseIfNeeded(
        tenantId: tenantId,
        createdBy: user.uid,
      );
    } catch (e) {
      AppLogger.error('Error creating default warehouse', e);
      // Hata durumunda sessizce devam et, kullanıcı deneyimini bozmasın
    }
  }

  /// Tüm kullanıcılar için varsayılan depo oluştur (admin işlemi)
  Future<void> createDefaultWarehousesForAllUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final tenantId = userData['tenantId'] as String?;

        if (tenantId != null && tenantId.isNotEmpty) {
          await _createDefaultWarehouseIfNeeded(
            tenantId: tenantId,
            createdBy: userDoc.id,
          );
        }
      }

      AppLogger.info('Default warehouses creation process completed');
    } catch (e) {
      AppLogger.error('Error creating default warehouses for all users', e);
    }
  }

  Future<void> _createDefaultWarehouseIfNeeded({
    required String tenantId,
    required String createdBy,
  }) async {
    final tenantDocRef = _firestore.collection('tenants').doc(tenantId);
    final tenantSnapshot = await tenantDocRef.get();
    final alreadyInitialized =
        tenantSnapshot.data()?['defaultWarehouseInitialized'] as bool? ?? false;

    if (alreadyInitialized) {
      AppLogger.info(
          'Default warehouse already marked for tenant: $tenantId, skipping');
      return;
    }

    final warehouseDocRef =
        tenantDocRef.collection('warehouses').doc('default_warehouse');
    final warehouseSnapshot = await warehouseDocRef.get();

    if (warehouseSnapshot.exists) {
      await _markWarehouseInitialized(tenantDocRef);
      AppLogger.info(
          'Default warehouse already exists for tenant: $tenantId (flag updated)');
      return;
    }

    await _firestore.runTransaction((transaction) async {
      final latestTenantSnapshot = await transaction.get(tenantDocRef);
      final flagSet = latestTenantSnapshot
              .data()?['defaultWarehouseInitialized'] as bool? ??
          false;

      if (flagSet) {
        AppLogger.info(
            'Transaction detected initialized flag for tenant: $tenantId');
        return;
      }

      final latestWarehouseSnapshot = await transaction.get(warehouseDocRef);
      if (latestWarehouseSnapshot.exists) {
        transaction.set(
          tenantDocRef,
          {
            'defaultWarehouseInitialized': true,
            'defaultWarehouseInitializedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        return;
      }

      final defaultWarehouse = _buildDefaultWarehouse(tenantId, createdBy);
      final warehouseEntity =
          FirebaseWarehouseEntity.fromDomain(defaultWarehouse);

      transaction.set(warehouseDocRef, warehouseEntity.toFirestore());
      transaction.set(
        tenantDocRef,
        {
          'defaultWarehouseInitialized': true,
          'defaultWarehouseInitializedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    AppLogger.info('Default warehouse created for tenant: $tenantId');
  }

  Future<void> _markWarehouseInitialized(
      DocumentReference<Map<String, dynamic>> tenantDocRef) async {
    await tenantDocRef.set(
      {
        'defaultWarehouseInitialized': true,
        'defaultWarehouseInitializedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Warehouse _buildDefaultWarehouse(String tenantId, String createdBy) {
    final now = DateTime.now();
    return Warehouse(
      id: 'default_warehouse',
      name: 'Ana Depo',
      description: 'Sistem tarafından oluşturulan varsayılan depo',
      type: WarehouseType.main,
      status: WarehouseStatus.active,
      address: 'Adres bilgisi ekleyin',
      city: 'Şehir',
      isActive: true,
      isDefault: true,
      createdBy: createdBy,
      createdAt: now,
      updatedBy: createdBy,
      updatedAt: now,
      tenantId: tenantId,
    );
  }
}
