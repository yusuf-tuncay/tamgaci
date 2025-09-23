// ========== FIREBASE PRICE LIST REPOSITORY ==========
// lib/features/products/data/repositories/firebase_price_list_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/price_list.dart';
import '../../domain/repositories/price_list_repository.dart';

/// Firebase fiyat listesi repository implementasyonu
class FirebasePriceListRepository implements PriceListRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Stream<List<PriceList>> getAllPriceLists() {
    return _firestore
        .collection('price_lists')
        .where('createdBy', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PriceList.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<PriceList>> getActivePriceLists() {
    return _firestore
        .collection('price_lists')
        .where('createdBy', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PriceList.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<PriceList?> getPriceListById(String id) async {
    final doc = await _firestore.collection('price_lists').doc(id).get();
    if (!doc.exists) return null;
    return PriceList.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Stream<List<PriceList>> getCustomerPriceLists(String customerId) {
    return _firestore
        .collection('price_lists')
        .where('createdBy', isEqualTo: _userId)
        .where('customerId', isEqualTo: customerId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PriceList.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<PriceList>> getCategoryPriceLists(String categoryId) {
    return _firestore
        .collection('price_lists')
        .where('createdBy', isEqualTo: _userId)
        .where('categoryId', isEqualTo: categoryId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PriceList.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<PriceList>> getValidPriceLists() {
    final now = Timestamp.now();
    return _firestore
        .collection('price_lists')
        .where('createdBy', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .where('validFrom', isLessThanOrEqualTo: now)
        .orderBy('validFrom', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PriceList.fromJson({...doc.data(), 'id': doc.id}))
            .where((priceList) => priceList.isValid)
            .toList());
  }

  @override
  Stream<List<PriceList>> getValidPriceListsForProduct(String productId) {
    return getValidPriceLists().map((priceLists) => priceLists
        .where((priceList) => priceList.productPrices.containsKey(productId))
        .toList());
  }

  @override
  Stream<List<PriceList>> getValidPriceListsForCustomer(String customerId) {
    return getValidPriceLists().map((priceLists) => priceLists
        .where((priceList) =>
            priceList.customerId == null || priceList.customerId == customerId)
        .toList());
  }

  @override
  Future<void> createPriceList(PriceList priceList) async {
    await _firestore
        .collection('price_lists')
        .doc(priceList.id)
        .set(priceList.toJson());
  }

  @override
  Future<void> updatePriceList(PriceList priceList) async {
    await _firestore
        .collection('price_lists')
        .doc(priceList.id)
        .update(priceList.toJson());
  }

  @override
  Future<void> deletePriceList(String id) async {
    await _firestore.collection('price_lists').doc(id).delete();
  }

  @override
  Future<void> updatePriceListStatus(String id, bool isActive) async {
    await _firestore.collection('price_lists').doc(id).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateProductPrice(
      String priceListId, String productId, double price) async {
    await _firestore.collection('price_lists').doc(priceListId).update({
      'productPrices.$productId': price,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateProductDiscount(
      String priceListId, String productId, double discount) async {
    await _firestore.collection('price_lists').doc(priceListId).update({
      'productDiscounts.$productId': discount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<int> getActivePriceListCount() async {
    final snapshot = await _firestore
        .collection('price_lists')
        .where('createdBy', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }

  @override
  Stream<List<PriceListType>> getPriceListTypes() {
    return Stream.value(PriceListType.values);
  }
}
