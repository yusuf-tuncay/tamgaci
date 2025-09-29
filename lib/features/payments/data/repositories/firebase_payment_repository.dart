// ========== FIREBASE PAYMENT REPOSITORY ==========
// lib/features/payments/data/repositories/firebase_payment_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase/firebase_auth_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/payment.dart';
import '../models/firebase_payment_entity.dart';

/// Firebase Payment Repository
/// Tahsilat işlemleri için Firebase Firestore entegrasyonu
class FirebasePaymentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuthService _authService;

  FirebasePaymentRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuthService authService,
  })  : _firestore = firestore,
        _authService = authService;

  /// Tenant ID al
  Future<String> _tenantId() async {
    final user = FirebaseAuthService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // User document'ından tenantId'yi al
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      throw Exception('User document not found');
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final tenantId = userData['tenantId'] as String?;

    if (tenantId == null || tenantId.isEmpty) {
      throw Exception('User is not assigned to any tenant');
    }

    return tenantId;
  }

  /// Current user ID al
  String _uid() {
    final user = FirebaseAuthService.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  /// Tüm tahsilatları getir
  Future<List<Payment>> getAllPayments() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('payments')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirebasePaymentEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all payments', e);
      rethrow;
    }
  }

  /// Müşteriye göre tahsilatları getir
  Future<List<Payment>> getPaymentsByCustomer(String customerId) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('payments')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirebasePaymentEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting payments by customer', e);
      rethrow;
    }
  }

  /// Tahsilat türüne göre getir
  Future<List<Payment>> getPaymentsByType(String type) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('payments')
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirebasePaymentEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting payments by type', e);
      rethrow;
    }
  }

  /// ID'ye göre tahsilat getir
  Future<Payment?> getPaymentById(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final doc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('payments')
          .doc(id)
          .get();

      if (!doc.exists) return null;

      return FirebasePaymentEntity.fromFirestore(doc).toDomain();
    } catch (e) {
      AppLogger.error('Error getting payment by ID', e);
      rethrow;
    }
  }

  /// Yeni tahsilat oluştur
  Future<String> createPayment(Payment payment) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      // Payment'a tenantId set et
      final paymentWithTenant = payment.copyWith(tenantId: tenantId);
      final paymentEntity = FirebasePaymentEntity.fromDomain(paymentWithTenant);

      final docRef = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('payments')
          .add(paymentEntity.toFirestore());

      AppLogger.info('Payment created successfully: ${payment.customerName}');
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating payment', e);
      rethrow;
    }
  }

  /// Tahsilat güncelle
  Future<void> updatePayment(Payment payment) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final paymentEntity = FirebasePaymentEntity.fromDomain(payment).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: _uid(),
      );

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('payments')
          .doc(payment.id)
          .update(paymentEntity.toFirestore());

      AppLogger.info('Payment updated successfully: ${payment.customerName}');
    } catch (e) {
      AppLogger.error('Error updating payment', e);
      rethrow;
    }
  }

  /// Tahsilat sil
  Future<void> deletePayment(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('payments')
          .doc(id)
          .delete();

      AppLogger.info('Payment deleted successfully: $id');
    } catch (e) {
      AppLogger.error('Error deleting payment', e);
      rethrow;
    }
  }

  /// Tarih aralığına göre tahsilatları getir
  Future<List<Payment>> getPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('payments')
          .where('paymentDate', isGreaterThanOrEqualTo: startDate)
          .where('paymentDate', isLessThanOrEqualTo: endDate)
          .orderBy('paymentDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirebasePaymentEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting payments by date range', e);
      rethrow;
    }
  }

  /// Tahsilat durumuna göre getir
  Future<List<Payment>> getPaymentsByStatus(String status) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('payments')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirebasePaymentEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting payments by status', e);
      rethrow;
    }
  }
}

/// Payment Repository Provider
final paymentRepositoryProvider = Provider<FirebasePaymentRepository>((ref) {
  return FirebasePaymentRepository(
    firestore: FirebaseFirestore.instance,
    authService: FirebaseAuthService(),
  );
});
