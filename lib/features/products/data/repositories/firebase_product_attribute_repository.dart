// ========== FIREBASE PRODUCT ATTRIBUTE REPOSITORY ==========
// lib/features/products/data/repositories/firebase_product_attribute_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/product_attribute.dart';
import '../../domain/repositories/product_attribute_repository.dart';

/// Firebase ürün özelliği repository implementasyonu
class FirebaseProductAttributeRepository implements ProductAttributeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Stream<List<ProductAttribute>> getAllProductAttributes() {
    return _firestore
        .collection('product_attributes')
        .where('createdBy', isEqualTo: _userId)
        .orderBy('sortOrder')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ProductAttribute.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<ProductAttribute>> getActiveProductAttributes() {
    return _firestore
        .collection('product_attributes')
        .where('createdBy', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ProductAttribute.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<ProductAttribute?> getProductAttributeById(String id) async {
    final doc = await _firestore.collection('product_attributes').doc(id).get();
    if (!doc.exists) return null;
    return ProductAttribute.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Stream<List<ProductAttribute>> getProductAttributesByType(
      AttributeType type) {
    return _firestore
        .collection('product_attributes')
        .where('createdBy', isEqualTo: _userId)
        .where('type', isEqualTo: type.name)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ProductAttribute.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<ProductAttribute>> getSearchableAttributes() {
    return _firestore
        .collection('product_attributes')
        .where('createdBy', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .where('isSearchable', isEqualTo: true)
        .orderBy('sortOrder')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ProductAttribute.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<ProductAttribute>> getFilterableAttributes() {
    return _firestore
        .collection('product_attributes')
        .where('createdBy', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .where('isFilterable', isEqualTo: true)
        .orderBy('sortOrder')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ProductAttribute.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<ProductAttribute>> getVisibleAttributes() {
    return _firestore
        .collection('product_attributes')
        .where('createdBy', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .where('isVisible', isEqualTo: true)
        .orderBy('sortOrder')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ProductAttribute.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<ProductAttribute>> getRequiredAttributes() {
    return _firestore
        .collection('product_attributes')
        .where('createdBy', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .where('isRequired', isEqualTo: true)
        .orderBy('sortOrder')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ProductAttribute.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<void> createProductAttribute(ProductAttribute attribute) async {
    await _firestore
        .collection('product_attributes')
        .doc(attribute.id)
        .set(attribute.toJson());
  }

  @override
  Future<void> updateProductAttribute(ProductAttribute attribute) async {
    await _firestore
        .collection('product_attributes')
        .doc(attribute.id)
        .update(attribute.toJson());
  }

  @override
  Future<void> deleteProductAttribute(String id) async {
    await _firestore.collection('product_attributes').doc(id).delete();
  }

  @override
  Future<void> updateProductAttributeStatus(String id, bool isActive) async {
    await _firestore.collection('product_attributes').doc(id).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateAttributeSortOrder(String id, int sortOrder) async {
    await _firestore.collection('product_attributes').doc(id).update({
      'sortOrder': sortOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<int> getActiveProductAttributeCount() async {
    final snapshot = await _firestore
        .collection('product_attributes')
        .where('createdBy', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }

  @override
  Stream<List<AttributeType>> getAttributeTypes() {
    return Stream.value(AttributeType.values);
  }

  @override
  Stream<List<AttributeValueType>> getAttributeValueTypes() {
    return Stream.value(AttributeValueType.values);
  }
}
