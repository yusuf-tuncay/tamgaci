// ========== PRODUCT FIREBASE SERVICE ==========
// lib/features/products/data/services/product_firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../../../../core/firebase/collections.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/warehouse.dart';
// import '../../domain/entities/warehouse_enums.dart' as warehouse_enums;
import '../../../inventory/domain/entities/stock_movement.dart';

/// Ürün Firebase servis sınıfı
class ProductFirebaseService {
  final FirebaseService _firebaseService = FirebaseService();

  /// Ürün oluştur
  Future<String> createProduct(Product product) async {
    try {
      final data = _productToMap(product);
      final docRef = await _firebaseService.createDocument(
        FirebaseCollections.products,
        data,
      );
      return docRef.id;
    } catch (e) {
      _firebaseService.logger.e('Ürün oluşturulurken hata: $e');
      rethrow;
    }
  }

  /// Ürün güncelle
  Future<void> updateProduct(String productId, Product product) async {
    try {
      final data = _productToMap(product);
      await _firebaseService.updateDocument(
        FirebaseCollections.products,
        productId,
        data,
      );
    } catch (e) {
      _firebaseService.logger.e('Ürün güncellenirken hata: $e');
      rethrow;
    }
  }

  /// Ürün sil
  Future<void> deleteProduct(String productId) async {
    try {
      await _firebaseService.deleteDocument(
        FirebaseCollections.products,
        productId,
      );
    } catch (e) {
      _firebaseService.logger.e('Ürün silinirken hata: $e');
      rethrow;
    }
  }

  /// Ürün getir
  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firebaseService.getDocumentById(
        FirebaseCollections.products,
        productId,
      );

      if (doc.exists && doc.data() != null) {
        return _mapToProduct(doc.id, doc.data()! as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      _firebaseService.logger.e('Ürün getirilirken hata: $e');
      rethrow;
    }
  }

  /// Ürünleri listele
  Future<List<Product>> getProducts({
    int? limit,
    DocumentSnapshot? startAfter,
    String? orderBy,
    bool descending = false,
    String? searchQuery,
    ProductType? type,
    String? category,
    String? warehouseId,
  }) async {
    try {
      final whereConditions = <String, dynamic>{
        FirebaseFields.isDeleted: false,
        FirebaseFields.isActive: true,
      };

      // Tip filtresi
      if (type != null) {
        whereConditions[FirebaseFields.productType] = type.name;
      }

      // Kategori filtresi
      if (category != null && category.isNotEmpty) {
        whereConditions[FirebaseFields.productCategory] = category;
      }

      // Depo filtresi
      if (warehouseId != null && warehouseId.isNotEmpty) {
        whereConditions[FirebaseFields.productWarehouseId] = warehouseId;
      }

      final snapshot = await _firebaseService.getCollectionData(
        FirebaseCollections.products,
        limit: limit,
        startAfter: startAfter,
        orderBy: orderBy ?? FirebaseFields.createdAt,
        descending: descending,
        whereConditions: whereConditions,
      );

      final products = snapshot.docs
          .map((doc) =>
              _mapToProduct(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // Arama sorgusu varsa filtrele
      if (searchQuery != null && searchQuery.isNotEmpty) {
        return products
            .where((product) =>
                product.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                (product.sku
                        ?.toLowerCase()
                        .contains(searchQuery.toLowerCase()) ??
                    false) ||
                (product.barcode?.contains(searchQuery) ?? false))
            .toList();
      }

      return products;
    } catch (e) {
      _firebaseService.logger.e('Ürünler listelenirken hata: $e');
      rethrow;
    }
  }

  /// Ürünleri gerçek zamanlı dinle
  Stream<List<Product>> listenToProducts({
    int? limit,
    String? orderBy,
    bool descending = false,
    String? searchQuery,
    ProductType? type,
    String? category,
    String? warehouseId,
  }) {
    try {
      final whereConditions = <String, dynamic>{
        FirebaseFields.isDeleted: false,
        FirebaseFields.isActive: true,
      };

      // Tip filtresi
      if (type != null) {
        whereConditions[FirebaseFields.productType] = type.name;
      }

      // Kategori filtresi
      if (category != null && category.isNotEmpty) {
        whereConditions[FirebaseFields.productCategory] = category;
      }

      // Depo filtresi
      if (warehouseId != null && warehouseId.isNotEmpty) {
        whereConditions[FirebaseFields.productWarehouseId] = warehouseId;
      }

      return _firebaseService
          .listenToCollection(
        FirebaseCollections.products,
        limit: limit,
        orderBy: orderBy ?? FirebaseFields.createdAt,
        descending: descending,
        whereConditions: whereConditions,
      )
          .map((snapshot) {
        final products = snapshot.docs
            .map((doc) =>
                _mapToProduct(doc.id, doc.data() as Map<String, dynamic>))
            .toList();

        // Arama sorgusu varsa filtrele
        if (searchQuery != null && searchQuery.isNotEmpty) {
          return products
              .where((product) =>
                  product.name
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()) ||
                  (product.sku
                          ?.toLowerCase()
                          .contains(searchQuery.toLowerCase()) ??
                      false) ||
                  (product.barcode?.contains(searchQuery) ?? false))
              .toList();
        }

        return products;
      });
    } catch (e) {
      _firebaseService.logger.e('Ürünler dinlenirken hata: $e');
      rethrow;
    }
  }

  /// Depo oluştur
  Future<String> createWarehouse(Warehouse warehouse) async {
    try {
      final data = _warehouseToMap(warehouse);
      final docRef = await _firebaseService.createDocument(
        FirebaseCollections.warehouses,
        data,
      );
      return docRef.id;
    } catch (e) {
      _firebaseService.logger.e('Depo oluşturulurken hata: $e');
      rethrow;
    }
  }

  /// Depo güncelle
  Future<void> updateWarehouse(String warehouseId, Warehouse warehouse) async {
    try {
      final data = _warehouseToMap(warehouse);
      await _firebaseService.updateDocument(
        FirebaseCollections.warehouses,
        warehouseId,
        data,
      );
    } catch (e) {
      _firebaseService.logger.e('Depo güncellenirken hata: $e');
      rethrow;
    }
  }

  /// Depo sil
  Future<void> deleteWarehouse(String warehouseId) async {
    try {
      await _firebaseService.deleteDocument(
        FirebaseCollections.warehouses,
        warehouseId,
      );
    } catch (e) {
      _firebaseService.logger.e('Depo silinirken hata: $e');
      rethrow;
    }
  }

  /// Depo getir
  Future<Warehouse?> getWarehouse(String warehouseId) async {
    try {
      final doc = await _firebaseService.getDocumentById(
        FirebaseCollections.warehouses,
        warehouseId,
      );

      if (doc.exists && doc.data() != null) {
        return _mapToWarehouse(doc.id, doc.data()! as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      _firebaseService.logger.e('Depo getirilirken hata: $e');
      rethrow;
    }
  }

  /// Depoları listele
  Future<List<Warehouse>> getWarehouses({
    int? limit,
    DocumentSnapshot? startAfter,
    String? orderBy,
    bool descending = false,
    WarehouseType? type,
    WarehouseStatus? status,
  }) async {
    try {
      final whereConditions = <String, dynamic>{
        FirebaseFields.isDeleted: false,
        FirebaseFields.isActive: true,
      };

      // Tip filtresi
      if (type != null) {
        whereConditions[FirebaseFields.warehouseType] = type.name;
      }

      // Durum filtresi
      if (status != null) {
        whereConditions[FirebaseFields.warehouseStatus] = status.name;
      }

      final snapshot = await _firebaseService.getCollectionData(
        FirebaseCollections.warehouses,
        limit: limit,
        startAfter: startAfter,
        orderBy: orderBy ?? FirebaseFields.createdAt,
        descending: descending,
        whereConditions: whereConditions,
      );

      return snapshot.docs
          .map((doc) =>
              _mapToWarehouse(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _firebaseService.logger.e('Depolar listelenirken hata: $e');
      rethrow;
    }
  }

  /// Stok hareketi oluştur
  Future<String> createStockMovement(StockMovement movement) async {
    try {
      final data = _stockMovementToMap(movement);
      final docRef = await _firebaseService.createDocument(
        FirebaseCollections.stockMovements,
        data,
      );
      return docRef.id;
    } catch (e) {
      _firebaseService.logger.e('Stok hareketi oluşturulurken hata: $e');
      rethrow;
    }
  }

  /// Stok hareketlerini getir
  Future<List<StockMovement>> getStockMovements({
    int? limit,
    DocumentSnapshot? startAfter,
    String? productId,
    String? warehouseId,
    StockMovementType? type,
  }) async {
    try {
      final whereConditions = <String, dynamic>{
        FirebaseFields.isDeleted: false,
      };

      if (productId != null) {
        whereConditions[FirebaseFields.movementProductId] = productId;
      }

      if (warehouseId != null) {
        whereConditions[FirebaseFields.movementWarehouseId] = warehouseId;
      }

      if (type != null) {
        whereConditions[FirebaseFields.movementType] = type.name;
      }

      final snapshot = await _firebaseService.getCollectionData(
        FirebaseCollections.stockMovements,
        limit: limit,
        startAfter: startAfter,
        orderBy: FirebaseFields.movementDate,
        descending: true,
        whereConditions: whereConditions,
      );

      return snapshot.docs
          .map((doc) =>
              _mapToStockMovement(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _firebaseService.logger.e('Stok hareketleri getirilirken hata: $e');
      rethrow;
    }
  }

  /// Ürün istatistiklerini getir
  Future<Map<String, dynamic>> getProductStats() async {
    try {
      final snapshot = await _firebaseService.getCollectionData(
        FirebaseCollections.products,
        whereConditions: {
          FirebaseFields.isDeleted: false,
          FirebaseFields.isActive: true,
        },
      );

      final products = snapshot.docs
          .map((doc) =>
              _mapToProduct(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final totalProducts = products.length;
      final lowStockProducts =
          products.where((p) => p.stockQuantity <= p.minStockLevel).length;
      final outOfStockProducts =
          products.where((p) => p.stockQuantity <= 0).length;
      final totalStockValue = products.fold<double>(
          0, (total, p) => total + (p.stockQuantity * (p.costPrice ?? 0)));

      return {
        'totalProducts': totalProducts,
        'lowStockProducts': lowStockProducts,
        'outOfStockProducts': outOfStockProducts,
        'totalStockValue': totalStockValue,
      };
    } catch (e) {
      _firebaseService.logger.e('Ürün istatistikleri getirilirken hata: $e');
      rethrow;
    }
  }

  /// Product entity'sini Map'e çevir
  Map<String, dynamic> _productToMap(Product product) {
    return {
      FirebaseFields.productName: product.name,
      FirebaseFields.productCode: product.sku,
      FirebaseFields.productBarcode: product.barcode,
      FirebaseFields.productDescription: product.description,
      FirebaseFields.productType: product.type.name,
      FirebaseFields.productCategory: product.category,
      FirebaseFields.productUnit: product.unit,
      FirebaseFields.productPrice: product.unitPrice,
      FirebaseFields.productCost: product.costPrice,
      FirebaseFields.productStock: product.stockQuantity,
      FirebaseFields.productMinStock: product.minStockLevel,
      FirebaseFields.productMaxStock: product.maxStockLevel,
      FirebaseFields.productWarehouseId: product.warehouseId,
      FirebaseFields.productImageUrl: product.imageUrl,
      // companyId is not a field of Product; omit or source from context if needed
      'taxRate': product.taxRate,
      'currency': product.currency,
      'isActive': product.isActive,
    };
  }

  /// Map'i Product entity'sine çevir
  Product _mapToProduct(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data[FirebaseFields.productName] ?? '',
      sku: data[FirebaseFields.productCode],
      barcode: data[FirebaseFields.productBarcode],
      description: data[FirebaseFields.productDescription],
      type: ProductType.values.firstWhere(
        (e) => e.name == data[FirebaseFields.productType],
        orElse: () => ProductType.product,
      ),
      category: data[FirebaseFields.productCategory] ?? '',
      unitPrice: (data[FirebaseFields.productPrice] ?? 0).toDouble(),
      costPrice: (data[FirebaseFields.productCost] ?? 0).toDouble(),
      stockQuantity: (data[FirebaseFields.productStock] ?? 0).toInt(),
      minStockLevel: (data[FirebaseFields.productMinStock] ?? 0).toInt(),
      maxStockLevel: (data[FirebaseFields.productMaxStock] ?? 1000).toInt(),
      unit: data[FirebaseFields.productUnit] ?? 'adet',
      taxRate: (data['taxRate'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      isActive: data['isActive'] ?? true,
      imageUrl: data[FirebaseFields.productImageUrl],
      warehouseId: data[FirebaseFields.productWarehouseId],
      createdAt: (data[FirebaseFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (data[FirebaseFields.updatedAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      createdBy: (data[FirebaseFields.createdBy] as String?) ?? 'system',
      updatedBy: data[FirebaseFields.updatedBy],
    );
  }

  /// Warehouse entity'sini Map'e çevir
  Map<String, dynamic> _warehouseToMap(Warehouse warehouse) {
    return {
      FirebaseFields.warehouseName: warehouse.name,
      FirebaseFields.warehouseCode: warehouse.code,
      FirebaseFields.warehouseAddress: warehouse.address,
      FirebaseFields.warehouseType: warehouse.type.name,
      FirebaseFields.warehouseStatus: warehouse.status.name,
      FirebaseFields.warehouseCapacity: warehouse.capacity,
      FirebaseFields.warehouseManager: warehouse.manager,
      FirebaseFields.companyId: warehouse.companyId,
    };
  }

  /// Map'i Warehouse entity'sine çevir
  Warehouse _mapToWarehouse(String id, Map<String, dynamic> data) {
    return Warehouse(
      id: id,
      name: data[FirebaseFields.warehouseName] ?? '',
      code: data[FirebaseFields.warehouseCode] ?? '',
      address: data[FirebaseFields.warehouseAddress],
      type: WarehouseType.values.firstWhere(
        (e) => e.name == data[FirebaseFields.warehouseType],
        orElse: () => WarehouseType.warehouse,
      ),
      status: WarehouseStatus.values.firstWhere(
        (e) => e.name == data[FirebaseFields.warehouseStatus],
        orElse: () => WarehouseStatus.active,
      ),
      capacity: (data[FirebaseFields.warehouseCapacity] ?? 0).toDouble(),
      manager: data[FirebaseFields.warehouseManager],
      companyId: data[FirebaseFields.companyId] ?? '',
      createdAt: (data[FirebaseFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (data[FirebaseFields.updatedAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      createdBy: data[FirebaseFields.createdBy] ?? '',
      updatedBy: data[FirebaseFields.updatedBy],
    );
  }

  /// StockMovement entity'sini Map'e çevir
  Map<String, dynamic> _stockMovementToMap(StockMovement movement) {
    return {
      FirebaseFields.movementProductId: movement.productId,
      FirebaseFields.movementWarehouseId: movement.warehouseId,
      FirebaseFields.movementType: movement.type.name,
      FirebaseFields.movementQuantity: movement.quantity,
      FirebaseFields.movementUnitPrice: movement.unitPrice,
      FirebaseFields.movementTotalPrice: movement.totalPrice,
      FirebaseFields.movementDate: movement.movementDate,
      FirebaseFields.movementReference: movement.reference,
      FirebaseFields.movementNotes: movement.notes,
      FirebaseFields.companyId: movement.companyId,
    };
  }

  /// Map'i StockMovement entity'sine çevir
  StockMovement _mapToStockMovement(String id, Map<String, dynamic> data) {
    return StockMovement(
      id: id,
      productId: data[FirebaseFields.movementProductId] ?? '',
      warehouseId: data[FirebaseFields.movementWarehouseId] ?? '',
      type: StockMovementType.values.firstWhere(
        (e) => e.name == data[FirebaseFields.movementType],
        orElse: () => StockMovementType.in_,
      ),
      quantity: (data[FirebaseFields.movementQuantity] ?? 0).toDouble(),
      unitPrice: (data[FirebaseFields.movementUnitPrice] ?? 0).toDouble(),
      totalPrice: (data[FirebaseFields.movementTotalPrice] ?? 0).toDouble(),
      movementDate:
          (data[FirebaseFields.movementDate] as Timestamp?)?.toDate() ??
              DateTime.now(),
      reference: data[FirebaseFields.movementReference],
      notes: data[FirebaseFields.movementNotes],
      companyId: data[FirebaseFields.companyId] ?? '',
      createdAt: (data[FirebaseFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (data[FirebaseFields.updatedAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      createdBy: data[FirebaseFields.createdBy] ?? '',
      updatedBy: data[FirebaseFields.updatedBy],
    );
  }
}
