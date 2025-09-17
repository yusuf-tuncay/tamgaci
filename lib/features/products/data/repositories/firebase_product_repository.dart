// ========== FIREBASE PRODUCT REPOSITORY ==========
// lib/features/products/data/repositories/firebase_product_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'package:tamgaci/core/utils/logger.dart';
import '../models/firebase_product_entity.dart';

/// Firebase Firestore tabanlı ürün repository implementasyonu
class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'products';

  @override
  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection(_collectionName)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
            .toList());
  }

  @override
  Stream<List<Product>> getActiveProducts() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
            .toList());
  }

  @override
  Future<Product?> getProductById(int id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collectionName).doc(id.toString()).get();

      if (docSnapshot.exists) {
        return ProductEntity.fromFirestore(docSnapshot).toDomain();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting product by ID', e);
      rethrow;
    }
  }

  @override
  Future<Product?> getProductBySku(String sku) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('sku', isEqualTo: sku)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ProductEntity.fromFirestore(querySnapshot.docs.first).toDomain();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting product by SKU', e);
      rethrow;
    }
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ProductEntity.fromFirestore(querySnapshot.docs.first).toDomain();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting product by barcode', e);
      rethrow;
    }
  }

  @override
  Stream<List<Product>> getProductsByCategory(String category) {
    return _firestore
        .collection(_collectionName)
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
            .toList());
  }

  @override
  Stream<List<Product>> getLowStockProducts() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
            .where((product) => product.totalStockQuantity <= (product.criticalStockQuantity ?? 0))
            .toList());
  }

  @override
  Stream<List<Product>> getOutOfStockProducts() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
            .where((product) => product.totalStockQuantity == 0)
            .toList());
  }

  @override
  Stream<List<Product>> searchProducts(String query) {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                (product.sku?.toLowerCase().contains(query.toLowerCase()) ??
                    false) ||
                (product.barcode?.toLowerCase().contains(query.toLowerCase()) ??
                    false))
            .toList());
  }

  @override
  Future<void> createProduct(Product product) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      final productEntity =
          ProductEntity.fromDomain(product).copyWith(id: docRef.id);
      await docRef.set(productEntity.toFirestore());
    } catch (e) {
      AppLogger.error('Error creating product', e);
      rethrow;
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(product.id.toString())
          .update(ProductEntity.fromDomain(product).toFirestore());
    } catch (e) {
      AppLogger.error('Error updating product', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _firestore.collection(_collectionName).doc(id.toString()).delete();
    } catch (e) {
      AppLogger.error('Error deleting product', e);
      rethrow;
    }
  }

  @override
  Future<void> updateStockQuantity(int id, int quantity) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id.toString())
          .update({'stockQuantity': quantity});
    } catch (e) {
      AppLogger.error('Error updating stock quantity', e);
      rethrow;
    }
  }

  @override
  Future<void> updateProductStatus(int id, bool isActive) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id.toString())
          .update({'isActive': isActive});
    } catch (e) {
      AppLogger.error('Error updating product status', e);
      rethrow;
    }
  }

  @override
  Future<int> getActiveProductCount() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting active product count', e);
      rethrow;
    }
  }

  @override
  Future<double> getTotalStockValue() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      double totalValue = 0.0;
      for (var doc in querySnapshot.docs) {
        final product = ProductEntity.fromFirestore(doc).toDomain();
        totalValue += product.salesPrice * product.totalStockQuantity;
      }
      return totalValue;
    } catch (e) {
      AppLogger.error('Error calculating total stock value', e);
      rethrow;
    }
  }

  @override
  Stream<List<String>> getCategories() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
            .map((product) => product.category)
            .where((category) => category != null && category.isNotEmpty)
            .map((category) => category!)
            .toSet()
            .toList());
  }
}
