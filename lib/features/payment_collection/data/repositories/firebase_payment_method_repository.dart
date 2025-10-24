// ========== FIREBASE PAYMENT METHOD REPOSITORY ==========
// lib/features/payment_collection/data/repositories/firebase_payment_method_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_enums.dart';
import '../../domain/repositories/payment_method_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:tamgaci/core/utils/logger.dart';

/// Firebase Firestore tabanlı ödeme yöntemi repository implementasyonu
abstract class FirebasePaymentMethodRepository
    implements PaymentMethodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _uid() {
    try {
      return firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<String> _tenantId() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return '';

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['tenantId'] as String? ?? '';
      }
      return '';
    } catch (e) {
      AppLogger.error('Error getting tenant ID', e);
      return '';
    }
  }

  String _getCollectionPath(String tenantId) {
    return 'tenants/$tenantId/payment_methods';
  }

  @override
  Future<List<PaymentMethod>> getAllMethods({
    String? companyId,
    String? tenantId,
    bool? isActive,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      if (actualTenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      Query query = _firestore.collection(_getCollectionPath(actualTenantId));

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      query = query.orderBy('name');

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting all payment methods', e);
      rethrow;
    }
  }

  @override
  Future<PaymentMethod?> getMethodById(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      final doc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (doc.exists) {
        return _fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting payment method by ID', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethod>> getActiveMethods({
    String? companyId,
    String? tenantId,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      if (actualTenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('isActive', isEqualTo: true);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      query = query.orderBy('name');

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting active payment methods', e);
      rethrow;
    }
  }

  @override
  Future<PaymentMethod?> getDefaultMethod({
    String? companyId,
    String? tenantId,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      if (actualTenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('isDefault', isEqualTo: true)
          .where('isActive', isEqualTo: true);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      final snapshot = await query.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return _fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting default payment method', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethod>> getMethodsByType(
    PaymentMethodType type, {
    String? companyId,
    String? tenantId,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      if (actualTenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('type', isEqualTo: type.name)
          .where('isActive', isEqualTo: true);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      query = query.orderBy('name');

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting payment methods by type', e);
      rethrow;
    }
  }

  @override
  Future<PaymentMethod> createMethod(PaymentMethod method) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      final methodWithDefaults = method.copyWith(
        companyId: method.companyId.isEmpty ? _uid() ?? '' : method.companyId,
        tenantId: method.tenantId.isEmpty ? tenantId : method.tenantId,
        createdBy: method.createdBy.isEmpty ? _uid() ?? '' : method.createdBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(methodWithDefaults.id)
          .set(_toFirestore(methodWithDefaults));

      AppLogger.info('Payment method created: ${methodWithDefaults.id}');
      return methodWithDefaults;
    } catch (e) {
      AppLogger.error('Error creating payment method', e);
      rethrow;
    }
  }

  @override
  Future<PaymentMethod> updateMethod(PaymentMethod method) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      final updatedMethod = method.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: _uid(),
      );

      await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(updatedMethod.id)
          .update(_toFirestore(updatedMethod));

      AppLogger.info('Payment method updated: ${updatedMethod.id}');
      return updatedMethod;
    } catch (e) {
      AppLogger.error('Error updating payment method', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteMethod(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .delete();

      AppLogger.info('Payment method deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting payment method', e);
      rethrow;
    }
  }

  @override
  Future<PaymentMethod> toggleMethodStatus(String id, bool isActive) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid(),
      });

      final updatedDoc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (updatedDoc.exists) {
        return _fromFirestore(updatedDoc);
      } else {
        throw Exception('Payment method not found after update');
      }
    } catch (e) {
      AppLogger.error('Error toggling payment method status', e);
      rethrow;
    }
  }

  @override
  Future<PaymentMethod> setDefaultMethod(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      // First, remove default status from all methods
      final allMethods = await _firestore
          .collection(_getCollectionPath(tenantId))
          .where('isDefault', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in allMethods.docs) {
        batch.update(doc.reference, {
          'isDefault': false,
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': _uid(),
        });
      }
      await batch.commit();

      // Then set the new default
      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'isDefault': true,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid(),
      });

      final updatedDoc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (updatedDoc.exists) {
        return _fromFirestore(updatedDoc);
      } else {
        throw Exception('Payment method not found after update');
      }
    } catch (e) {
      AppLogger.error('Error setting default payment method', e);
      rethrow;
    }
  }

  @override
  Future<PaymentMethod> updateMethodSettings(
    String id,
    Map<String, dynamic> settings,
  ) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'settings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid(),
      });

      final updatedDoc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (updatedDoc.exists) {
        return _fromFirestore(updatedDoc);
      } else {
        throw Exception('Payment method not found after update');
      }
    } catch (e) {
      AppLogger.error('Error updating payment method settings', e);
      rethrow;
    }
  }

  @override
  Future<PaymentMethod> updateLimits(
    String id, {
    double? minimumAmount,
    double? maximumAmount,
    double? dailyLimit,
    double? monthlyLimit,
  }) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid(),
      };

      if (minimumAmount != null) updateData['minimumAmount'] = minimumAmount;
      if (maximumAmount != null) updateData['maximumAmount'] = maximumAmount;
      if (dailyLimit != null) updateData['dailyLimit'] = dailyLimit;
      if (monthlyLimit != null) updateData['monthlyLimit'] = monthlyLimit;

      await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .update(updateData);

      final updatedDoc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (updatedDoc.exists) {
        return _fromFirestore(updatedDoc);
      } else {
        throw Exception('Payment method not found after update');
      }
    } catch (e) {
      AppLogger.error('Error updating payment method limits', e);
      rethrow;
    }
  }

  @override
  Future<PaymentMethod> updateCommissionRate(
    String id,
    double commissionRate,
  ) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'commissionRate': commissionRate,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid(),
      });

      final updatedDoc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (updatedDoc.exists) {
        return _fromFirestore(updatedDoc);
      } else {
        throw Exception('Payment method not found after update');
      }
    } catch (e) {
      AppLogger.error('Error updating payment method commission rate', e);
      rethrow;
    }
  }

  @override
  Future<PaymentMethod> updateApprovalLevel(
    String id,
    PaymentApprovalLevel approvalLevel,
  ) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'approvalLevel': approvalLevel.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid(),
      });

      final updatedDoc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (updatedDoc.exists) {
        return _fromFirestore(updatedDoc);
      } else {
        throw Exception('Payment method not found after update');
      }
    } catch (e) {
      AppLogger.error('Error updating payment method approval level', e);
      rethrow;
    }
  }

  PaymentMethod _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PaymentMethod(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      type: PaymentMethodType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PaymentMethodType.cash,
      ),
      isActive: data['isActive'] as bool? ?? true,
      isDefault: data['isDefault'] as bool? ?? false,
      minimumAmount: (data['minimumAmount'] as num?)?.toDouble(),
      maximumAmount: (data['maximumAmount'] as num?)?.toDouble(),
      dailyLimit: (data['dailyLimit'] as num?)?.toDouble(),
      monthlyLimit: (data['monthlyLimit'] as num?)?.toDouble(),
      commissionRate: (data['commissionRate'] as num?)?.toDouble() ?? 0.0,
      approvalLevel: PaymentApprovalLevel.values.firstWhere(
        (e) => e.name == data['approvalLevel'],
        orElse: () => PaymentApprovalLevel.none,
      ),
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
      companyId: data['companyId'] as String? ?? '',
      tenantId: data['tenantId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String? ?? '',
      updatedBy: data['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> _toFirestore(PaymentMethod method) {
    return {
      'name': method.name,
      'description': method.description,
      'type': method.type.name,
      'isActive': method.isActive,
      'isDefault': method.isDefault,
      'minimumAmount': method.minimumAmount,
      'maximumAmount': method.maximumAmount,
      'dailyLimit': method.dailyLimit,
      'monthlyLimit': method.monthlyLimit,
      'commissionRate': method.commissionRate,
      'approvalLevel': method.approvalLevel,
      'settings': method.settings,
      'companyId': method.companyId,
      'tenantId': method.tenantId,
      'createdAt': Timestamp.fromDate(method.createdAt),
      'updatedAt': Timestamp.fromDate(method.updatedAt),
      'createdBy': method.createdBy,
      'updatedBy': method.updatedBy,
    };
  }

  // Eksik methodlar - gelecekte implement edilecek

  @override
  Future<Map<String, dynamic>> analyzeMethodImpact(String id) async {
    throw UnimplementedError('analyzeMethodImpact not implemented');
  }

  @override
  Future<Map<String, dynamic>> analyzeMethodPerformance(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('analyzeMethodPerformance not implemented');
  }

  @override
  Future<Map<String, dynamic>> analyzeMethodSecurity(String id) async {
    throw UnimplementedError('analyzeMethodSecurity not implemented');
  }

  @override
  Future<PaymentMethod> archiveMethod(String id) async {
    throw UnimplementedError('archiveMethod not implemented');
  }

  @override
  Future<PaymentMethod> restoreMethod(String id) async {
    throw UnimplementedError('restoreMethod not implemented');
  }

  @override
  Future<List<PaymentMethod>> getArchivedMethods(
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getArchivedMethods not implemented');
  }

  @override
  Future<Map<String, dynamic>> getMethodStatistics(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('getMethodStatistics not implemented');
  }

  @override
  Future<Map<String, dynamic>> getMethodUsageReport(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('getMethodUsageReport not implemented');
  }

  @override
  Future<List<PaymentMethod>> searchMethods(String query,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('searchMethods not implemented');
  }

  Future<List<PaymentMethod>> getMethodsByApprovalLevel(
      PaymentApprovalLevel level,
      {String? companyId,
      String? tenantId}) async {
    throw UnimplementedError('getMethodsByApprovalLevel not implemented');
  }

  Future<PaymentMethod> setMethodLimits(String id,
      {double? dailyLimit,
      double? monthlyLimit,
      double? minimumAmount,
      double? maximumAmount}) async {
    throw UnimplementedError('setMethodLimits not implemented');
  }

  Future<bool> validateMethodUsage(String id, double amount) async {
    throw UnimplementedError('validateMethodUsage not implemented');
  }

  Future<PaymentMethod> cloneMethod(String id, String newName) async {
    throw UnimplementedError('cloneMethod not implemented');
  }

  @override
  Future<String> exportMethods({String? companyId, String? tenantId}) async {
    throw UnimplementedError('exportMethods not implemented');
  }

  @override
  Future<List<PaymentMethod>> importMethods(List<PaymentMethod> data) async {
    throw UnimplementedError('importMethods not implemented');
  }

  Future<PaymentMethod> setMethodCommission(String id, double rate) async {
    throw UnimplementedError('setMethodCommission not implemented');
  }

  Future<List<PaymentMethod>> getMethodsByCommissionRange(
      double minRate, double maxRate,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getMethodsByCommissionRange not implemented');
  }

  Future<Map<String, dynamic>> getMethodPerformanceMetrics(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('getMethodPerformanceMetrics not implemented');
  }

  Future<PaymentMethod> setMethodApprovalLevel(
      String id, PaymentApprovalLevel level) async {
    throw UnimplementedError('setMethodApprovalLevel not implemented');
  }

  Future<List<PaymentMethod>> getMethodsRequiringApproval(
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getMethodsRequiringApproval not implemented');
  }

  Future<PaymentMethod> approveMethod(String id, String approvedBy) async {
    throw UnimplementedError('approveMethod not implemented');
  }

  Future<PaymentMethod> rejectMethod(
      String id, String rejectedBy, String reason) async {
    throw UnimplementedError('rejectMethod not implemented');
  }

  Future<Map<String, dynamic>> getMethodAuditLog(String id) async {
    throw UnimplementedError('getMethodAuditLog not implemented');
  }

  Future<PaymentMethod> setMethodPriority(String id, int priority) async {
    throw UnimplementedError('setMethodPriority not implemented');
  }

  @override
  Future<List<PaymentMethod>> getMethodsByPriority(
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getMethodsByPriority not implemented');
  }

  Future<Map<String, dynamic>> getMethodComplianceReport(String id) async {
    throw UnimplementedError('getMethodComplianceReport not implemented');
  }

  Future<PaymentMethod> setMethodComplianceSettings(
      String id, Map<String, dynamic> settings) async {
    throw UnimplementedError('setMethodComplianceSettings not implemented');
  }

  Future<List<PaymentMethod>> getMethodsByComplianceStatus(String status,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getMethodsByComplianceStatus not implemented');
  }

  Future<Map<String, dynamic>> getMethodRiskAssessment(String id) async {
    throw UnimplementedError('getMethodRiskAssessment not implemented');
  }

  Future<PaymentMethod> setMethodRiskLevel(String id, String level) async {
    throw UnimplementedError('setMethodRiskLevel not implemented');
  }

  Future<List<PaymentMethod>> getMethodsByRiskLevel(String level,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getMethodsByRiskLevel not implemented');
  }

  Future<Map<String, dynamic>> getMethodCostAnalysis(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('getMethodCostAnalysis not implemented');
  }

  Future<PaymentMethod> setMethodCostSettings(
      String id, Map<String, dynamic> settings) async {
    throw UnimplementedError('setMethodCostSettings not implemented');
  }

  Future<List<PaymentMethod>> getMethodsByCostRange(
      double minCost, double maxCost,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getMethodsByCostRange not implemented');
  }

  Future<Map<String, dynamic>> getMethodIntegrationStatus(String id) async {
    throw UnimplementedError('getMethodIntegrationStatus not implemented');
  }

  Future<PaymentMethod> setMethodIntegrationSettings(
      String id, Map<String, dynamic> settings) async {
    throw UnimplementedError('setMethodIntegrationSettings not implemented');
  }

  Future<List<PaymentMethod>> getMethodsByIntegrationStatus(String status,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getMethodsByIntegrationStatus not implemented');
  }

  Future<Map<String, dynamic>> getMethodMaintenanceSchedule(String id) async {
    throw UnimplementedError('getMethodMaintenanceSchedule not implemented');
  }

  Future<PaymentMethod> scheduleMethodMaintenance(
      String id, DateTime scheduledDate) async {
    throw UnimplementedError('scheduleMethodMaintenance not implemented');
  }

  Future<List<PaymentMethod>> getMethodsRequiringMaintenance(
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getMethodsRequiringMaintenance not implemented');
  }

  Future<Map<String, dynamic>> getMethodBackupStatus(String id) async {
    throw UnimplementedError('getMethodBackupStatus not implemented');
  }

  @override
  Future<String> backupMethod(String id) async {
    throw UnimplementedError('backupMethod not implemented');
  }

  Future<PaymentMethod> restoreMethodFromBackup(
      String id, String backupId) async {
    throw UnimplementedError('restoreMethodFromBackup not implemented');
  }

  Future<List<PaymentMethod>> getMethodBackups(String id) async {
    throw UnimplementedError('getMethodBackups not implemented');
  }

  Future<Map<String, dynamic>> getMethodVersionHistory(String id) async {
    throw UnimplementedError('getMethodVersionHistory not implemented');
  }

  Future<PaymentMethod> rollbackMethodToVersion(
      String id, String versionId) async {
    throw UnimplementedError('rollbackMethodToVersion not implemented');
  }

  @override
  Future<List<String>> getMethodDependencies(String id) async {
    throw UnimplementedError('getMethodDependencies not implemented');
  }

  Future<PaymentMethod> setMethodDependencies(
      String id, List<String> dependencies) async {
    throw UnimplementedError('setMethodDependencies not implemented');
  }

  Future<List<PaymentMethod>> getMethodsByDependency(String dependencyId,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getMethodsByDependency not implemented');
  }

  Future<Map<String, dynamic>> getMethodHealthStatus(String id) async {
    throw UnimplementedError('getMethodHealthStatus not implemented');
  }

  Future<PaymentMethod> setMethodHealthStatus(String id, String status) async {
    throw UnimplementedError('setMethodHealthStatus not implemented');
  }

  Future<List<PaymentMethod>> getMethodsByHealthStatus(String status,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getMethodsByHealthStatus not implemented');
  }

  Future<Map<String, dynamic>> getMethodMonitoringData(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('getMethodMonitoringData not implemented');
  }

  Future<PaymentMethod> setMethodMonitoringSettings(
      String id, Map<String, dynamic> settings) async {
    throw UnimplementedError('setMethodMonitoringSettings not implemented');
  }

  Future<List<PaymentMethod>> getMethodsRequiringMonitoring(
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getMethodsRequiringMonitoring not implemented');
  }
}
