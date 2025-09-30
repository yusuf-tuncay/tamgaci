// ========== FIREBASE PRODUCT REPOSITORY - TENANT BASED ==========
// lib/features/products/data/repositories/firebase_product_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/firebase_product_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/core/services/tenant_service.dart';

/// Firebase Firestore tabanlı ürün repository implementasyonu - Multi-tenant
class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TenantService _tenantService = TenantService();

  String? _uid() {
    try {
      return firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<String> _tenantId() async {
    return await _tenantService.getUserTenantIdString();
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final docSnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .doc(id)
          .get();

      if (docSnapshot.exists) {
        return ProductEntity.fromFirestore(docSnapshot).toDomain();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting product by ID', e);
      return null;
    }
  }

  @override
  Future<Product?> getProductBySku(String sku) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('sku', isEqualTo: sku)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ProductEntity.fromFirestore(querySnapshot.docs.first).toDomain();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting product by SKU', e);
      return null;
    }
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ProductEntity.fromFirestore(querySnapshot.docs.first).toDomain();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting product by barcode', e);
      return null;
    }
  }

  @override
  Stream<List<Product>> getProductsByCategory(String category) {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Product>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
              .toList());
    });
  }

  @override
  Stream<List<Product>> getLowStockProducts() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Product>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
              .where((product) =>
                  product.criticalStockQuantity != null &&
                  product.criticalStockQuantity! > 0)
              .toList());
    });
  }

  @override
  Stream<List<Product>> getOutOfStockProducts() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Product>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
              .where((product) => product.criticalStockQuantity == 0)
              .toList());
    });
  }

  Stream<List<Product>> getProductsByBrand(String brand) {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Product>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('brand', isEqualTo: brand)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
              .toList());
    });
  }

  @override
  Future<void> createProduct(Product product) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final docRef = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .doc();
      final productWithTenant = product.copyWith(tenantId: tenantId);
      final productEntity =
          ProductEntity.fromDomain(productWithTenant).copyWith(
        id: docRef.id,
      );
      final data = productEntity.toFirestore();
      data['tenantId'] = tenantId;
      data['createdBy'] = _uid() ?? 'anonymous';
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.runTransaction((transaction) async {
        transaction.set(docRef, data);
      });

      debugPrint('🔥 Firebase: Product created with ID: ${docRef.id}');
      AppLogger.info('Product created successfully', {'productId': docRef.id});
    } catch (e) {
      AppLogger.error('Error creating product', e);
      rethrow;
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final productEntity = ProductEntity.fromDomain(product).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: _uid(),
      );

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .doc(product.id)
          .update(productEntity.toFirestore());
    } catch (e) {
      AppLogger.error('Error updating product', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .doc(id)
          .delete();

      debugPrint('🔥 Firebase: Product deleted with ID: $id');
      AppLogger.info('Product deleted successfully', {'productId': id});
    } catch (e) {
      AppLogger.error('Error deleting product', e);
      rethrow;
    }
  }

  @override
  Future<void> updateStockQuantity(String id, int quantity) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .doc(id)
          .update({
        'criticalStockQuantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid(),
      });
    } catch (e) {
      AppLogger.error('Error updating stock quantity', e);
      rethrow;
    }
  }

  @override
  Future<void> updateProductStatus(String id, bool isActive) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .doc(id)
          .update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid(),
      });
    } catch (e) {
      AppLogger.error('Error updating product status', e);
      rethrow;
    }
  }

  @override
  Stream<List<Product>> getAllProducts() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return Stream.value(<Product>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
              .toList());
    });
  }

  @override
  Stream<List<Product>> getActiveProducts() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return Stream.value(<Product>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
        final products = snapshot.docs
            .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
            .toList();
        debugPrint(
            '🔥 Firebase Stream: ${products.length} active products found');
        return products;
      });
    });
  }

  Stream<Product?> getProductStream(String id) {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(null);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .doc(id)
          .snapshots()
          .map((doc) {
        if (doc.exists) {
          return ProductEntity.fromFirestore(doc).toDomain();
        }
        return null;
      });
    });
  }

  // ========== EKSİK METODLAR ==========

  @override
  Stream<List<Product>> searchProducts(String query) {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Product>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
              .toList());
    });
  }

  @override
  Future<int> getActiveProductCount() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return 0;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting active product count', e);
      return 0;
    }
  }

  @override
  Future<double> getTotalStockValue() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return 0.0;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      double totalValue = 0.0;
      for (final doc in querySnapshot.docs) {
        final product = ProductEntity.fromFirestore(doc).toDomain();
        final stockQuantity = product.totalStockQuantity;
        // KDV hariç fiyat kullan (gerçek maliyet/değer)
        // Her bir ürünün fiyatını 2 basamağa yuvarla
        final priceWithoutTax = product.salesPriceWithoutTax;
        final roundedPrice = double.parse(priceWithoutTax.toStringAsFixed(2));
        final itemValue = stockQuantity * roundedPrice;
        totalValue += itemValue;

        // Debug
        debugPrint('📦 Stok Değeri Hesaplama: ${product.name}');
        debugPrint(
            '   Stok: $stockQuantity × KDV Hariç Fiyat: $roundedPrice = $itemValue');
        debugPrint(
            '   (KDV Dahil: ${product.salesPrice}, KDV: %${product.salesTaxRate})');
      }
      debugPrint('💰 Toplam Stok Değeri: $totalValue');
      return totalValue;
    } catch (e) {
      AppLogger.error('Error getting total stock value', e);
      return 0.0;
    }
  }

  @override
  Stream<List<Product>> getProductsByWarehouse(String warehouseId) {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Product>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('warehouseId', isEqualTo: warehouseId)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
            .toList();
      });
    });
  }

  @override
  Stream<List<Product>> getLowStockProductsByWarehouse(String warehouseId) {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Product>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('warehouseId', isEqualTo: warehouseId)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        final products = snapshot.docs
            .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
            .toList();

        return products.where((product) => product.isLowStock).toList();
      });
    });
  }

  @override
  Stream<List<Product>> getOutOfStockProductsByWarehouse(String warehouseId) {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Product>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('warehouseId', isEqualTo: warehouseId)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        final products = snapshot.docs
            .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
            .toList();

        return products
            .where((product) => product.totalStockQuantity <= 0)
            .toList();
      });
    });
  }

  @override
  Stream<List<String>> getCategories() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<String>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        final categories = <String>{};
        for (final doc in snapshot.docs) {
          final product = ProductEntity.fromFirestore(doc).toDomain();
          if (product.category != null && product.category!.isNotEmpty) {
            categories.add(product.category!);
          }
        }
        return categories.toList()..sort();
      });
    });
  }
}
