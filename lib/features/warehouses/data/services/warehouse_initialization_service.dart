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

      // Bu tenant için zaten varsayılan depo var mı kontrol et
      final existingWarehouses = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .where('isDefault', isEqualTo: true)
          .get();

      if (existingWarehouses.docs.isNotEmpty) {
        await _ensureSingleDefaultWarehouse(
          tenantId,
          existingWarehouses.docs,
        );
        AppLogger.info(
            'Default warehouse already exists for tenant: $tenantId');
        return;
      }

      // Varsayılan depo oluştur
      final defaultWarehouse = Warehouse(
        id: 'default_warehouse',
        name: 'Ana Depo',
        description: 'Sistem tarafından oluşturulan varsayılan depo',
        type: WarehouseType.main,
        status: WarehouseStatus.active,
        address: 'Adres bilgisi ekleyin',
        city: 'Şehir',
        isActive: true,
        isDefault: true,
        createdBy: user.uid,
        createdAt: DateTime.now(),
        updatedBy: user.uid,
        updatedAt: DateTime.now(),
        tenantId: tenantId,
      );

      final docRef = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouses')
          .doc(defaultWarehouse.id);

      if ((await docRef.get()).exists) {
        AppLogger.info(
            'Default warehouse document already exists for tenant: $tenantId');
        return;
      }

      final warehouseEntity =
          FirebaseWarehouseEntity.fromDomain(defaultWarehouse);

      await docRef.set(warehouseEntity.toFirestore());
      AppLogger.info(
          'Default warehouse created successfully for user: ${user.uid}');
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
          // Bu tenant için varsayılan depo var mı kontrol et
          final existingWarehouses = await _firestore
              .collection('tenants')
              .doc(tenantId)
              .collection('warehouses')
              .where('isDefault', isEqualTo: true)
              .get();

          if (existingWarehouses.docs.isEmpty) {
            // Varsayılan depo oluştur
            final defaultWarehouse = Warehouse(
              id: 'default_warehouse',
              name: 'Ana Depo',
              description: 'Sistem tarafından oluşturulan varsayılan depo',
              type: WarehouseType.main,
              status: WarehouseStatus.active,
              address: 'Adres bilgisi ekleyin',
              city: 'Şehir',
              isActive: true,
              isDefault: true,
              createdBy: userDoc.id,
              createdAt: DateTime.now(),
              updatedBy: userDoc.id,
              updatedAt: DateTime.now(),
              tenantId: tenantId,
            );

            final docRef = _firestore
                .collection('tenants')
                .doc(tenantId)
                .collection('warehouses')
                .doc(defaultWarehouse.id);

            if ((await docRef.get()).exists) {
              AppLogger.info(
                  'Default warehouse document already exists for tenant: $tenantId');
              continue;
            }

            final warehouseEntity =
                FirebaseWarehouseEntity.fromDomain(defaultWarehouse);

            await docRef.set(warehouseEntity.toFirestore());
            AppLogger.info('Default warehouse created for tenant: $tenantId');
          } else {
            await _ensureSingleDefaultWarehouse(
              tenantId,
              existingWarehouses.docs,
            );
          }
        }
      }

      AppLogger.info('Default warehouses creation process completed');
    } catch (e) {
      AppLogger.error('Error creating default warehouses for all users', e);
    }
  }

  Future<void> _ensureSingleDefaultWarehouse(
    String tenantId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    if (docs.length <= 1) return;

    final docToKeep = docs.firstWhere(
      (doc) => doc.id == 'default_warehouse',
      orElse: () => docs.first,
    );

    for (final doc in docs) {
      if (doc.id == docToKeep.id) continue;
      try {
        await doc.reference.delete();
        AppLogger.info(
            'Removed duplicate default warehouse ${doc.id} for tenant $tenantId');
      } catch (e) {
        AppLogger.error(
          'Error removing duplicate default warehouse for tenant $tenantId',
          e,
        );
      }
    }
  }
}
