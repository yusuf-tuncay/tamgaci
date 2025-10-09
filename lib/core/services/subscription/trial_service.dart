// ========== TRIAL SERVICE ==========
// lib/core/services/subscription/trial_service.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../features/subscription/domain/entities/trial_entity.dart';

/// Trial yönetim servisi
class TrialService {
  static final TrialService _instance = TrialService._internal();
  factory TrialService() => _instance;
  TrialService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Kullanıcı için trial oluştur
  Future<TrialCreationResult> createUserTrial(String userId) async {
    try {
      debugPrint('Trial: Creating trial for user: $userId');

      final callable = _functions.httpsCallable('createUserTrial');
      final result = await callable.call({'userId': userId});

      if (result.data['success'] == true) {
        return TrialCreationResult(
          success: true,
          trialId: result.data['trialId'],
          message: result.data['message'],
        );
      } else {
        return TrialCreationResult(
          success: false,
          error: result.data['message'] ?? 'Trial creation failed',
        );
      }
    } catch (e) {
      debugPrint('Trial: Creation error: $e');
      return TrialCreationResult(
        success: false,
        error: 'Trial creation failed: $e',
      );
    }
  }

  /// Trial durumunu kontrol et
  Future<TrialStatusResult> checkTrialStatus(String userId) async {
    try {
      debugPrint('Trial: Checking trial status for user: $userId');

      final callable = _functions.httpsCallable('checkTrialStatus');
      final result = await callable.call({'userId': userId});

      if (result.data['success'] == true) {
        return TrialStatusResult(
          success: true,
          hasTrial: result.data['hasTrial'] ?? false,
          status: result.data['status'] ?? 'none',
          remainingDays: result.data['remainingDays'],
          message: result.data['message'],
        );
      } else {
      return TrialStatusResult(
        success: false,
        hasTrial: false,
        status: 'none',
        error: result.data['message'] ?? 'Trial status check failed',
      );
      }
    } catch (e) {
      debugPrint('Trial: Status check error: $e');
        return TrialStatusResult(
          success: false,
          hasTrial: false,
          status: 'none',
          error: 'Trial status check failed: $e',
        );
    }
  }

  /// Kullanıcının trial'ını Firestore'dan al
  Future<TrialEntity?> getUserTrial(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('trials')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return TrialEntity.fromJson(snapshot.docs.first.data());
    } catch (e) {
      debugPrint('Trial: Get user trial error: $e');
      return null;
    }
  }

  /// Trial'ı iptal et
  Future<bool> cancelTrial(String trialId) async {
    try {
      await _firestore.collection('trials').doc(trialId).update({
        'status': 'canceled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Trial: Cancel trial error: $e');
      return false;
    }
  }

  /// Trial'ı ücretli plana dönüştür
  Future<bool> convertTrialToSubscription(String trialId, String subscriptionId) async {
    try {
      await _firestore.collection('trials').doc(trialId).update({
        'status': 'converted',
        'subscriptionId': subscriptionId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Trial: Convert trial error: $e');
      return false;
    }
  }
}

/// Trial oluşturma sonucu
class TrialCreationResult {
  final bool success;
  final String? trialId;
  final String? error;
  final String? message;

  const TrialCreationResult({
    required this.success,
    this.trialId,
    this.error,
    this.message,
  });
}

/// Trial durum sonucu
class TrialStatusResult {
  final bool success;
  final bool hasTrial;
  final String status;
  final int? remainingDays;
  final String? error;
  final String? message;

  const TrialStatusResult({
    required this.success,
    required this.hasTrial,
    required this.status,
    this.remainingDays,
    this.error,
    this.message,
  });
}
