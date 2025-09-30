import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../../domain/entities/stock_count.dart';
import '../../../products/domain/entities/product.dart';

/// Firebase Stok Sayımı Repository
class FirebaseStockCountRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'stockCounts';

  /// Tenant ID'yi al
  Future<String> _tenantId() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }
    // Şimdilik default tenant kullanıyoruz
    return 'default-tenant';
  }

  /// Yeni stok sayımı oluştur
  Future<String> createStockCount(StockCount stockCount) async {
    try {
      final tenantId = await _tenantId();
      final docRef = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection(_collection)
          .doc();

      final data = stockCount.copyWith(
        id: docRef.id,
        tenantId: tenantId,
      ).toJson();

      await docRef.set(data);
      debugPrint('🔥 Firebase: Stock count created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating stock count: $e');
      rethrow;
    }
  }

  /// Stok sayımı güncelle
  Future<void> updateStockCount(StockCount stockCount) async {
    try {
      final tenantId = await _tenantId();
      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection(_collection)
          .doc(stockCount.id)
          .update(stockCount.toJson());

      debugPrint('🔥 Firebase: Stock count updated with ID: ${stockCount.id}');
    } catch (e) {
      debugPrint('❌ Error updating stock count: $e');
      rethrow;
    }
  }

  /// Stok sayımını sil
  Future<void> deleteStockCount(String id) async {
    try {
      final tenantId = await _tenantId();
      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection(_collection)
          .doc(id)
          .delete();

      debugPrint('🔥 Firebase: Stock count deleted with ID: $id');
    } catch (e) {
      debugPrint('❌ Error deleting stock count: $e');
      rethrow;
    }
  }

  /// Stok sayımını getir
  Future<StockCount?> getStockCount(String id) async {
    try {
      final tenantId = await _tenantId();
      final doc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection(_collection)
          .doc(id)
          .get();

      if (doc.exists && doc.data() != null) {
        return StockCount.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting stock count: $e');
      rethrow;
    }
  }

  /// Depoya göre stok sayımları stream
  Stream<List<StockCount>> getStockCountsByWarehouse(String warehouseId) {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection(_collection)
          .where('warehouseId', isEqualTo: warehouseId)
          .orderBy('countDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => StockCount.fromJson(doc.data()))
              .toList());
    });
  }

  /// Tüm stok sayımları stream
  Stream<List<StockCount>> getAllStockCounts() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection(_collection)
          .orderBy('countDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => StockCount.fromJson(doc.data()))
              .toList());
    });
  }

  /// Depodaki ürünlerden stok sayımı oluştur
  Future<StockCount> createStockCountFromProducts({
    required String warehouseId,
    required String warehouseName,
    required List<Product> products,
    required StockCountType type,
    String? description,
  }) async {
    try {
      final tenantId = await _tenantId();
      final user = firebase_auth.FirebaseAuth.instance.currentUser!;
      
      // Sayım numarası üret (örn: SC-2025-001)
      final countNumber = await _generateCountNumber(tenantId);

      // Ürünlerden stok sayım kalemlerini oluştur
      final List<StockCountItem> items = [];
      
      for (final product in products) {
        if (product.variants != null && product.variants!.isNotEmpty) {
          // Varyantlı ürünler için her varyantı ayrı kalem olarak ekle
          for (final variant in product.variants!) {
            items.add(StockCountItem(
              productId: product.id,
              productName: product.name,
              productCode: product.productCode,
              barcode: variant.barcode,
              variantId: variant.id,
              variantName: variant.name,
              systemQuantity: variant.stockQuantity,
              shelfLocation: variant.shelfLocation,
            ));
          }
        } else {
          // Varyantsız ürünler
          items.add(StockCountItem(
            productId: product.id,
            productName: product.name,
            productCode: product.productCode,
            barcode: product.barcode,
            systemQuantity: product.stockQuantity,
            shelfLocation: product.shelfLocation,
          ));
        }
      }

      final stockCount = StockCount(
        id: '',
        tenantId: tenantId,
        warehouseId: warehouseId,
        warehouseName: warehouseName,
        countNumber: countNumber,
        type: type,
        status: StockCountStatus.draft,
        countDate: DateTime.now(),
        description: description,
        items: items,
        totalItemsCount: items.length,
        countedItemsCount: 0,
        createdBy: user.email ?? user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await createStockCount(stockCount);
      return stockCount.copyWith(id: id);
    } catch (e) {
      debugPrint('❌ Error creating stock count from products: $e');
      rethrow;
    }
  }

  /// Sayım numarası üret
  Future<String> _generateCountNumber(String tenantId) async {
    try {
      final now = DateTime.now();
      final year = now.year;
      
      // Bu yıl için kaç sayım yapılmış kontrol et
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection(_collection)
          .where('countNumber', isGreaterThanOrEqualTo: 'SC-$year-')
          .where('countNumber', isLessThan: 'SC-${year + 1}-')
          .get();

      final count = snapshot.docs.length + 1;
      return 'SC-$year-${count.toString().padLeft(3, '0')}';
    } catch (e) {
      // Hata durumunda timestamp kullanalım
      return 'SC-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Stok sayımını tamamla ve ürün stoklarını güncelle
  Future<void> completeStockCount(String id) async {
    try {
      final tenantId = await _tenantId();
      final user = firebase_auth.FirebaseAuth.instance.currentUser!;
      
      final stockCount = await getStockCount(id);
      if (stockCount == null) {
        throw Exception('Stok sayımı bulunamadı');
      }

      // Tüm kalemlerin sayılıp sayılmadığını kontrol et
      final uncountedItems = stockCount.items.where((item) => !item.isCounted).toList();
      if (uncountedItems.isNotEmpty) {
        throw Exception('Tüm kalemler sayılmadan tamamlanamaz');
      }

      // Ürün stoklarını güncelle (batch işlemi)
      final batch = _firestore.batch();

      for (final item in stockCount.items) {
        if (item.countedQuantity != null && item.countedQuantity != item.systemQuantity) {
          final productRef = _firestore
              .collection('tenants')
              .doc(tenantId)
              .collection('products')
              .doc(item.productId);

          final productDoc = await productRef.get();
          if (productDoc.exists) {
            final productData = productDoc.data()!;
            
            if (item.variantId != null) {
              // Varyantlı ürün - varyant stokunu güncelle
              final variants = (productData['variants'] as List<dynamic>?)
                  ?.map((v) => Map<String, dynamic>.from(v as Map))
                  .toList() ?? <Map<String, dynamic>>[];
              
              final variantIndex = variants.indexWhere((v) => v['id'] == item.variantId);
              if (variantIndex != -1) {
                variants[variantIndex]['stockQuantity'] = item.countedQuantity;
                batch.update(productRef, {
                  'variants': variants,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }
            } else {
              // Varyantsız ürün - ana stoku güncelle
              batch.update(productRef, {
                'stockQuantity': item.countedQuantity,
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
          }
        }
      }

      // Stok sayımını tamamlandı olarak işaretle
      final stockCountRef = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection(_collection)
          .doc(id);

      batch.update(stockCountRef, {
        'status': StockCountStatus.completed.name,
        'completedBy': user.email ?? user.uid,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      debugPrint('🔥 Firebase: Stock count completed with ID: $id');
    } catch (e) {
      debugPrint('❌ Error completing stock count: $e');
      rethrow;
    }
  }

  /// Stok sayımını iptal et
  Future<void> cancelStockCount(String id) async {
    try {
      final tenantId = await _tenantId();
      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection(_collection)
          .doc(id)
          .update({
        'status': StockCountStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('🔥 Firebase: Stock count cancelled with ID: $id');
    } catch (e) {
      debugPrint('❌ Error cancelling stock count: $e');
      rethrow;
    }
  }
}
