import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/warehouse_transfer.dart';
import '../../domain/repositories/warehouse_transfer_repository.dart';
import '../models/firebase_warehouse_transfer_entity.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/data/repositories/firebase_product_repository.dart';

/// Firebase Warehouse Transfer Repository Implementation
class FirebaseWarehouseTransferRepository
    implements WarehouseTransferRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseWarehouseTransferRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  String _tenantId() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı giriş yapmamış');

    // Bu kısımda kullanıcının tenantId'sini almak için
    // user document'ından tenantId'yi okumamız gerekiyor
    // Şimdilik basit bir implementasyon yapıyoruz
    return 'default_tenant_${user.uid.substring(0, 8)}';
  }

  String _uid() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı giriş yapmamış');
    return user.uid;
  }

  @override
  Future<WarehouseTransfer> createTransfer(WarehouseTransfer transfer) async {
    try {
      final tenantId = _tenantId();
      final userId = _uid();

      final transferWithTenant = transfer.copyWith(
        tenantId: tenantId,
        createdBy: userId,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      final firebaseEntity =
          FirebaseWarehouseTransferEntity.fromDomain(transferWithTenant);

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouseTransfers')
          .doc(transfer.id)
          .set(firebaseEntity.toFirestore());

      // Transfer oluşturulduktan sonra stokları güncelle
      await _updateProductStocks(transferWithTenant);

      return transferWithTenant;
    } catch (e) {
      throw Exception('Transfer oluşturulamadı: $e');
    }
  }

  /// Transfer sonrası ürün stoklarını güncelle
  Future<void> _updateProductStocks(WarehouseTransfer transfer) async {
    try {
      final tenantId = _tenantId();
      
      // Ürünü getir
      final productDoc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .doc(transfer.productId)
          .get();

      if (!productDoc.exists) {
        throw Exception('Ürün bulunamadı');
      }

      final productData = productDoc.data()!;
      final currentStock = productData['stockQuantity'] ?? 0;
      
      // Kaynak depodan çıkar, hedef depoya ekle
      final newStock = currentStock - transfer.quantity;
      
      if (newStock < 0) {
        throw Exception('Yetersiz stok. Mevcut stok: $currentStock, İstenen: ${transfer.quantity}');
      }

      // Stok güncelle
      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .doc(transfer.productId)
          .update({
        'stockQuantity': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid(),
      });

      // Transfer durumunu completed olarak güncelle
      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouseTransfers')
          .doc(transfer.id)
          .update({
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      throw Exception('Stok güncellenemedi: $e');
    }
  }

  @override
  Future<WarehouseTransfer> updateTransfer(WarehouseTransfer transfer) async {
    try {
      final tenantId = _tenantId();

      final transferWithTenant = transfer.copyWith(
        tenantId: tenantId,
        updatedAt: DateTime.now(),
      );

      final firebaseEntity =
          FirebaseWarehouseTransferEntity.fromDomain(transferWithTenant);

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouseTransfers')
          .doc(transfer.id)
          .update(firebaseEntity.toFirestore());

      return transferWithTenant;
    } catch (e) {
      throw Exception('Transfer güncellenemedi: $e');
    }
  }

  @override
  Future<void> deleteTransfer(String id) async {
    try {
      final tenantId = _tenantId();

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouseTransfers')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Transfer silinemedi: $e');
    }
  }

  @override
  Future<WarehouseTransfer?> getTransfer(String id) async {
    try {
      final tenantId = _tenantId();

      final doc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouseTransfers')
          .doc(id)
          .get();

      if (!doc.exists) return null;

      final entity = FirebaseWarehouseTransferEntity.fromFirestore(doc);
      return entity.toDomain();
    } catch (e) {
      throw Exception('Transfer getirilemedi: $e');
    }
  }

  @override
  Future<List<WarehouseTransfer>> getTransfers() async {
    try {
      final tenantId = _tenantId();

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouseTransfers')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              FirebaseWarehouseTransferEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      throw Exception('Transferler getirilemedi: $e');
    }
  }

  @override
  Future<List<WarehouseTransfer>> getTransfersByWarehouse(
      String warehouseId) async {
    try {
      final tenantId = _tenantId();

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouseTransfers')
          .where('fromWarehouseId', isEqualTo: warehouseId)
          .get();

      final querySnapshot2 = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouseTransfers')
          .where('toWarehouseId', isEqualTo: warehouseId)
          .get();

      final allTransfers = <WarehouseTransfer>[];

      allTransfers.addAll(
        querySnapshot.docs
            .map((doc) =>
                FirebaseWarehouseTransferEntity.fromFirestore(doc).toDomain())
            .toList(),
      );

      allTransfers.addAll(
        querySnapshot2.docs
            .map((doc) =>
                FirebaseWarehouseTransferEntity.fromFirestore(doc).toDomain())
            .toList(),
      );

      // Tarihe göre sırala
      allTransfers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allTransfers;
    } catch (e) {
      throw Exception('Depo transferleri getirilemedi: $e');
    }
  }

  @override
  Future<List<WarehouseTransfer>> getTransfersByProduct(
      String productId) async {
    try {
      final tenantId = _tenantId();

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouseTransfers')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              FirebaseWarehouseTransferEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      throw Exception('Ürün transferleri getirilemedi: $e');
    }
  }

  @override
  Future<List<WarehouseTransfer>> getTransfersByStatus(String status) async {
    try {
      final tenantId = _tenantId();

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('warehouseTransfers')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              FirebaseWarehouseTransferEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      throw Exception('Durum transferleri getirilemedi: $e');
    }
  }

  @override
  Future<List<WarehouseTransfer>> getPendingTransfers() async {
    return getTransfersByStatus('pending');
  }

  @override
  Future<WarehouseTransfer> completeTransfer(String id) async {
    try {
      final transfer = await getTransfer(id);
      if (transfer == null) throw Exception('Transfer bulunamadı');

      final completedTransfer = transfer.copyWith(
        status: 'completed',
        updatedAt: DateTime.now(),
      );

      return await updateTransfer(completedTransfer);
    } catch (e) {
      throw Exception('Transfer tamamlanamadı: $e');
    }
  }

  @override
  Future<WarehouseTransfer> cancelTransfer(String id) async {
    try {
      final transfer = await getTransfer(id);
      if (transfer == null) throw Exception('Transfer bulunamadı');

      final cancelledTransfer = transfer.copyWith(
        status: 'cancelled',
        updatedAt: DateTime.now(),
      );

      return await updateTransfer(cancelledTransfer);
    } catch (e) {
      throw Exception('Transfer iptal edilemedi: $e');
    }
  }
}
