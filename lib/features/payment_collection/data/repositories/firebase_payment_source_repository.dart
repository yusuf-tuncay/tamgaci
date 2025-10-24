// ========== FIREBASE PAYMENT SOURCE REPOSITORY ==========
// lib/features/payment_collection/data/repositories/firebase_payment_source_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/entities/payment_enums.dart';
import '../../domain/repositories/payment_source_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:tamgaci/core/utils/logger.dart';

/// Firebase Firestore tabanlı ödeme kaynağı repository implementasyonu
abstract class FirebasePaymentSourceRepository
    implements PaymentSourceRepository {
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
    return 'tenants/$tenantId/payment_sources';
  }

  @override
  Future<List<PaymentSource>> getAllSources({
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
      AppLogger.error('Error getting all payment sources', e);
      rethrow;
    }
  }

  @override
  Future<PaymentSource?> getSourceById(String id) async {
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
      AppLogger.error('Error getting payment source by ID', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentSource>> getActiveSources({
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
      AppLogger.error('Error getting active payment sources', e);
      rethrow;
    }
  }

  @override
  Future<PaymentSource?> getDefaultSource({
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
      AppLogger.error('Error getting default payment source', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentSource>> getSourcesByType(
    PaymentSourceType type, {
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
      AppLogger.error('Error getting payment sources by type', e);
      rethrow;
    }
  }

  @override
  Future<PaymentSource> createSource(PaymentSource source) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      final sourceWithDefaults = source.copyWith(
        companyId: source.companyId.isEmpty ? _uid() ?? '' : source.companyId,
        tenantId: source.tenantId.isEmpty ? tenantId : source.tenantId,
        createdBy: source.createdBy.isEmpty ? _uid() ?? '' : source.createdBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(sourceWithDefaults.id)
          .set(_toFirestore(sourceWithDefaults));

      AppLogger.info('Payment source created: ${sourceWithDefaults.id}');
      return sourceWithDefaults;
    } catch (e) {
      AppLogger.error('Error creating payment source', e);
      rethrow;
    }
  }

  @override
  Future<PaymentSource> updateSource(PaymentSource source) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      final updatedSource = source.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: _uid(),
      );

      await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(updatedSource.id)
          .update(_toFirestore(updatedSource));

      AppLogger.info('Payment source updated: ${updatedSource.id}');
      return updatedSource;
    } catch (e) {
      AppLogger.error('Error updating payment source', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteSource(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .delete();

      AppLogger.info('Payment source deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting payment source', e);
      rethrow;
    }
  }

  @override
  Future<PaymentSource> toggleSourceStatus(String id, bool isActive) async {
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
        throw Exception('Payment source not found after update');
      }
    } catch (e) {
      AppLogger.error('Error toggling payment source status', e);
      rethrow;
    }
  }

  @override
  Future<PaymentSource> setDefaultSource(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      // First, remove default status from all sources
      final allSources = await _firestore
          .collection(_getCollectionPath(tenantId))
          .where('isDefault', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in allSources.docs) {
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
        throw Exception('Payment source not found after update');
      }
    } catch (e) {
      AppLogger.error('Error setting default payment source', e);
      rethrow;
    }
  }

  @override
  Future<PaymentSource> updateBalance(
    String id,
    double newBalance,
  ) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'balance': newBalance,
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
        throw Exception('Payment source not found after update');
      }
    } catch (e) {
      AppLogger.error('Error updating payment source balance', e);
      rethrow;
    }
  }

  @override
  Future<PaymentSource> updateAvailableBalance(
    String id,
    double newAvailableBalance,
  ) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'availableBalance': newAvailableBalance,
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
        throw Exception('Payment source not found after update');
      }
    } catch (e) {
      AppLogger.error('Error updating payment source available balance', e);
      rethrow;
    }
  }

  @override
  Future<PaymentSource> updateBlockedAmount(
    String id,
    double newBlockedAmount,
  ) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required');
      }

      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'blockedAmount': newBlockedAmount,
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
        throw Exception('Payment source not found after update');
      }
    } catch (e) {
      AppLogger.error('Error updating payment source blocked amount', e);
      rethrow;
    }
  }

  @override
  Future<PaymentSource> updateLimits(
    String id, {
    double? dailyLimit,
    double? monthlyLimit,
    double? transactionLimit,
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

      if (transactionLimit != null) {
        updateData['transactionLimit'] = transactionLimit;
      }
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
        throw Exception('Payment source not found after update');
      }
    } catch (e) {
      AppLogger.error('Error updating payment source limits', e);
      rethrow;
    }
  }

  PaymentSource _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PaymentSource(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      type: PaymentSourceType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PaymentSourceType.cash,
      ),
      isActive: data['isActive'] as bool? ?? true,
      isDefault: data['isDefault'] as bool? ?? false,
      currentBalance: (data['currentBalance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (data['availableBalance'] as num?)?.toDouble() ?? 0.0,
      blockedAmount: (data['blockedAmount'] as num?)?.toDouble() ?? 0.0,
      // minimumAmount: (data['minimumAmount'] as num?)?.toDouble(),
      // maximumAmount: (data['maximumAmount'] as num?)?.toDouble(),
      dailyLimit: (data['dailyLimit'] as num?)?.toDouble(),
      monthlyLimit: (data['monthlyLimit'] as num?)?.toDouble(),
      currency: data['currency'] as String? ?? 'TRY',
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
      companyId: data['companyId'] as String? ?? '',
      tenantId: data['tenantId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String? ?? '',
      updatedBy: data['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> _toFirestore(PaymentSource source) {
    return {
      'name': source.name,
      'description': source.description,
      'type': source.type.name,
      'isActive': source.isActive,
      'isDefault': source.isDefault,
      'currentBalance': source.currentBalance,
      'availableBalance': source.availableBalance,
      'blockedAmount': source.blockedAmount,
      'dailyLimit': source.dailyLimit,
      'monthlyLimit': source.monthlyLimit,
      'currency': source.currency,
      'settings': source.settings,
      'companyId': source.companyId,
      'tenantId': source.tenantId,
      'createdAt': Timestamp.fromDate(source.createdAt),
      'updatedAt': Timestamp.fromDate(source.updatedAt),
      'createdBy': source.createdBy,
      'updatedBy': source.updatedBy,
    };
  }

  // Eksik methodlar - gelecekte implement edilecek

  @override
  Future<Map<String, dynamic>> analyzeSourceImpact(String id) async {
    throw UnimplementedError('analyzeSourceImpact not implemented');
  }

  @override
  Future<Map<String, dynamic>> analyzeSourcePerformance(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('analyzeSourcePerformance not implemented');
  }

  @override
  Future<Map<String, dynamic>> analyzeSourceSecurity(String id) async {
    throw UnimplementedError('analyzeSourceSecurity not implemented');
  }

  @override
  Future<PaymentSource> archiveSource(String id) async {
    throw UnimplementedError('archiveSource not implemented');
  }

  @override
  Future<PaymentSource> restoreSource(String id) async {
    throw UnimplementedError('restoreSource not implemented');
  }

  @override
  Future<List<PaymentSource>> getArchivedSources(
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getArchivedSources not implemented');
  }

  @override
  Future<Map<String, dynamic>> getSourceStatistics(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('getSourceStatistics not implemented');
  }

  Future<Map<String, dynamic>> getSourceUsageReport(
      {String? companyId,
      String? tenantId,
      DateTime? startDate,
      DateTime? endDate}) async {
    throw UnimplementedError('getSourceUsageReport not implemented');
  }

  @override
  Future<List<PaymentSource>> searchSources(String query,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('searchSources not implemented');
  }

  Future<PaymentSource> updateSourceSettings(
      String id, Map<String, dynamic> settings) async {
    throw UnimplementedError('updateSourceSettings not implemented');
  }

  Future<PaymentSource> setSourceLimits(String id,
      {double? dailyLimit, double? monthlyLimit}) async {
    throw UnimplementedError('setSourceLimits not implemented');
  }

  Future<bool> validateSourceUsage(String id, double amount) async {
    throw UnimplementedError('validateSourceUsage not implemented');
  }

  Future<PaymentSource> cloneSource(String id, String newName) async {
    throw UnimplementedError('cloneSource not implemented');
  }

  @override
  Future<String> exportSources({String? companyId, String? tenantId}) async {
    throw UnimplementedError('exportSources not implemented');
  }

  @override
  Future<List<PaymentSource>> importSources(List<PaymentSource> data) async {
    throw UnimplementedError('importSources not implemented');
  }

  Future<Map<String, dynamic>> getSourcePerformanceMetrics(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('getSourcePerformanceMetrics not implemented');
  }

  Future<Map<String, dynamic>> getSourceAuditLog(String id) async {
    throw UnimplementedError('getSourceAuditLog not implemented');
  }

  Future<PaymentSource> setSourcePriority(String id, int priority) async {
    throw UnimplementedError('setSourcePriority not implemented');
  }

  Future<List<PaymentSource>> getSourcesByPriority(
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByPriority not implemented');
  }

  Future<Map<String, dynamic>> getSourceComplianceReport(String id) async {
    throw UnimplementedError('getSourceComplianceReport not implemented');
  }

  Future<PaymentSource> setSourceComplianceSettings(
      String id, Map<String, dynamic> settings) async {
    throw UnimplementedError('setSourceComplianceSettings not implemented');
  }

  Future<List<PaymentSource>> getSourcesByComplianceStatus(String status,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByComplianceStatus not implemented');
  }

  Future<Map<String, dynamic>> getSourceRiskAssessment(String id) async {
    throw UnimplementedError('getSourceRiskAssessment not implemented');
  }

  Future<PaymentSource> setSourceRiskLevel(String id, String level) async {
    throw UnimplementedError('setSourceRiskLevel not implemented');
  }

  Future<List<PaymentSource>> getSourcesByRiskLevel(String level,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByRiskLevel not implemented');
  }

  Future<Map<String, dynamic>> getSourceCostAnalysis(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('getSourceCostAnalysis not implemented');
  }

  Future<PaymentSource> setSourceCostSettings(
      String id, Map<String, dynamic> settings) async {
    throw UnimplementedError('setSourceCostSettings not implemented');
  }

  Future<List<PaymentSource>> getSourcesByCostRange(
      double minCost, double maxCost,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByCostRange not implemented');
  }

  Future<Map<String, dynamic>> getSourceIntegrationStatus(String id) async {
    throw UnimplementedError('getSourceIntegrationStatus not implemented');
  }

  Future<PaymentSource> setSourceIntegrationSettings(
      String id, Map<String, dynamic> settings) async {
    throw UnimplementedError('setSourceIntegrationSettings not implemented');
  }

  Future<List<PaymentSource>> getSourcesByIntegrationStatus(String status,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByIntegrationStatus not implemented');
  }

  Future<Map<String, dynamic>> getSourceMaintenanceSchedule(String id) async {
    throw UnimplementedError('getSourceMaintenanceSchedule not implemented');
  }

  Future<PaymentSource> scheduleSourceMaintenance(
      String id, DateTime scheduledDate) async {
    throw UnimplementedError('scheduleSourceMaintenance not implemented');
  }

  Future<List<PaymentSource>> getSourcesRequiringMaintenance(
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesRequiringMaintenance not implemented');
  }

  Future<Map<String, dynamic>> getSourceBackupStatus(String id) async {
    throw UnimplementedError('getSourceBackupStatus not implemented');
  }

  @override
  Future<String> backupSource(String id) async {
    throw UnimplementedError('backupSource not implemented');
  }

  Future<PaymentSource> restoreSourceFromBackup(
      String id, String backupId) async {
    throw UnimplementedError('restoreSourceFromBackup not implemented');
  }

  Future<List<PaymentSource>> getSourceBackups(String id) async {
    throw UnimplementedError('getSourceBackups not implemented');
  }

  Future<Map<String, dynamic>> getSourceVersionHistory(String id) async {
    throw UnimplementedError('getSourceVersionHistory not implemented');
  }

  Future<PaymentSource> rollbackSourceToVersion(
      String id, String versionId) async {
    throw UnimplementedError('rollbackSourceToVersion not implemented');
  }

  @override
  Future<List<String>> getSourceDependencies(String id) async {
    throw UnimplementedError('getSourceDependencies not implemented');
  }

  Future<PaymentSource> setSourceDependencies(
      String id, List<String> dependencies) async {
    throw UnimplementedError('setSourceDependencies not implemented');
  }

  Future<List<PaymentSource>> getSourcesByDependency(String dependencyId,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByDependency not implemented');
  }

  Future<Map<String, dynamic>> getSourceHealthStatus(String id) async {
    throw UnimplementedError('getSourceHealthStatus not implemented');
  }

  Future<PaymentSource> setSourceHealthStatus(String id, String status) async {
    throw UnimplementedError('setSourceHealthStatus not implemented');
  }

  Future<List<PaymentSource>> getSourcesByHealthStatus(String status,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByHealthStatus not implemented');
  }

  Future<Map<String, dynamic>> getSourceMonitoringData(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('getSourceMonitoringData not implemented');
  }

  Future<PaymentSource> setSourceMonitoringSettings(
      String id, Map<String, dynamic> settings) async {
    throw UnimplementedError('setSourceMonitoringSettings not implemented');
  }

  Future<List<PaymentSource>> getSourcesRequiringMonitoring(
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesRequiringMonitoring not implemented');
  }

  Future<PaymentSource> setSourceBalance(String id, double balance) async {
    throw UnimplementedError('setSourceBalance not implemented');
  }

  Future<PaymentSource> blockSourceAmount(String id, double amount) async {
    throw UnimplementedError('blockSourceAmount not implemented');
  }

  Future<PaymentSource> unblockSourceAmount(String id, double amount) async {
    throw UnimplementedError('unblockSourceAmount not implemented');
  }

  Future<Map<String, dynamic>> getSourceBalanceHistory(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('getSourceBalanceHistory not implemented');
  }

  Future<PaymentSource> transferBalance(
      String fromSourceId, String toSourceId, double amount) async {
    throw UnimplementedError('transferBalance not implemented');
  }

  Future<List<PaymentSource>> getSourcesByBalanceRange(
      double minBalance, double maxBalance,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByBalanceRange not implemented');
  }

  Future<Map<String, dynamic>> getSourceTransactionHistory(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('getSourceTransactionHistory not implemented');
  }

  Future<PaymentSource> setSourceCurrency(String id, String currency) async {
    throw UnimplementedError('setSourceCurrency not implemented');
  }

  Future<List<PaymentSource>> getSourcesByCurrency(String currency,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByCurrency not implemented');
  }

  Future<Map<String, dynamic>> getSourceExchangeRates(String id) async {
    throw UnimplementedError('getSourceExchangeRates not implemented');
  }

  Future<PaymentSource> updateSourceExchangeRates(
      String id, Map<String, double> rates) async {
    throw UnimplementedError('updateSourceExchangeRates not implemented');
  }

  Future<Map<String, dynamic>> getSourceFinancialReport(String id,
      {DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError('getSourceFinancialReport not implemented');
  }

  Future<PaymentSource> setSourceFinancialSettings(
      String id, Map<String, dynamic> settings) async {
    throw UnimplementedError('setSourceFinancialSettings not implemented');
  }

  Future<List<PaymentSource>> getSourcesByFinancialStatus(String status,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByFinancialStatus not implemented');
  }

  Future<Map<String, dynamic>> getSourceLiquidityAnalysis(String id) async {
    throw UnimplementedError('getSourceLiquidityAnalysis not implemented');
  }

  Future<PaymentSource> setSourceLiquiditySettings(
      String id, Map<String, dynamic> settings) async {
    throw UnimplementedError('setSourceLiquiditySettings not implemented');
  }

  Future<List<PaymentSource>> getSourcesByLiquidityLevel(String level,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByLiquidityLevel not implemented');
  }

  Future<Map<String, dynamic>> getSourceCreditRating(String id) async {
    throw UnimplementedError('getSourceCreditRating not implemented');
  }

  Future<PaymentSource> setSourceCreditRating(String id, String rating) async {
    throw UnimplementedError('setSourceCreditRating not implemented');
  }

  Future<List<PaymentSource>> getSourcesByCreditRating(String rating,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByCreditRating not implemented');
  }

  Future<Map<String, dynamic>> getSourceRegulatoryCompliance(String id) async {
    throw UnimplementedError('getSourceRegulatoryCompliance not implemented');
  }

  Future<PaymentSource> setSourceRegulatorySettings(
      String id, Map<String, dynamic> settings) async {
    throw UnimplementedError('setSourceRegulatorySettings not implemented');
  }

  Future<List<PaymentSource>> getSourcesByRegulatoryStatus(String status,
      {String? companyId, String? tenantId}) async {
    throw UnimplementedError('getSourcesByRegulatoryStatus not implemented');
  }
}
