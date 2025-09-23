// ========== FIREBASE TAX RULE REPOSITORY ==========
// lib/features/products/data/repositories/firebase_tax_rule_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/tax_rule.dart';
import '../../domain/repositories/tax_rule_repository.dart';

/// Firebase vergi kuralı repository implementasyonu
class FirebaseTaxRuleRepository implements TaxRuleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Stream<List<TaxRule>> getAllTaxRules() {
    return _firestore
        .collection('tax_rules')
        .where('createdBy', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaxRule.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<TaxRule>> getActiveTaxRules() {
    return _firestore
        .collection('tax_rules')
        .where('createdBy', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaxRule.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<TaxRule?> getTaxRuleById(String id) async {
    final doc = await _firestore.collection('tax_rules').doc(id).get();
    if (!doc.exists) return null;
    return TaxRule.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Stream<List<TaxRule>> getTaxRulesByType(TaxType type) {
    return _firestore
        .collection('tax_rules')
        .where('createdBy', isEqualTo: _userId)
        .where('type', isEqualTo: type.name)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaxRule.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<TaxRule>> getValidTaxRules() {
    return _firestore
        .collection('tax_rules')
        .where('createdBy', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaxRule.fromJson({...doc.data(), 'id': doc.id}))
            .where((taxRule) => taxRule.isValid)
            .toList());
  }

  @override
  Stream<List<TaxRule>> getValidTaxRulesForProduct(
      String productId, String? categoryId) {
    return getValidTaxRules().map((taxRules) => taxRules
        .where(
            (taxRule) => taxRule.isApplicableToProduct(productId, categoryId))
        .toList());
  }

  @override
  Stream<List<TaxRule>> getValidTaxRulesForCustomer(String? customerId) {
    return getValidTaxRules().map((taxRules) => taxRules
        .where((taxRule) => taxRule.isApplicableToCustomer(customerId))
        .toList());
  }

  @override
  Stream<List<TaxRule>> getTaxRulesByCategory(String categoryId) {
    return _firestore
        .collection('tax_rules')
        .where('createdBy', isEqualTo: _userId)
        .where('applicableCategories', arrayContains: categoryId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaxRule.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<TaxRule>> getTaxRulesByCustomer(String customerId) {
    return _firestore
        .collection('tax_rules')
        .where('createdBy', isEqualTo: _userId)
        .where('applicableCustomers', arrayContains: customerId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaxRule.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<void> createTaxRule(TaxRule taxRule) async {
    await _firestore
        .collection('tax_rules')
        .doc(taxRule.id)
        .set(taxRule.toJson());
  }

  @override
  Future<void> updateTaxRule(TaxRule taxRule) async {
    await _firestore
        .collection('tax_rules')
        .doc(taxRule.id)
        .update(taxRule.toJson());
  }

  @override
  Future<void> deleteTaxRule(String id) async {
    await _firestore.collection('tax_rules').doc(id).delete();
  }

  @override
  Future<void> updateTaxRuleStatus(String id, bool isActive) async {
    await _firestore.collection('tax_rules').doc(id).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<int> getActiveTaxRuleCount() async {
    final snapshot = await _firestore
        .collection('tax_rules')
        .where('createdBy', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }

  @override
  Stream<List<TaxType>> getTaxTypes() {
    return Stream.value(TaxType.values);
  }

  @override
  Stream<List<TaxCalculationMethod>> getTaxCalculationMethods() {
    return Stream.value(TaxCalculationMethod.values);
  }
}
