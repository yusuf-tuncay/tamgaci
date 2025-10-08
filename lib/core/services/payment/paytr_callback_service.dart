// ========== PAYTR CALLBACK SERVICE ==========
// lib/core/services/payment/paytr_callback_service.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'paytr_service.dart';
import '../../../features/subscription/domain/entities/subscription_entity.dart' as sub;
import '../../../features/subscription/domain/entities/subscription_plan.dart' as plan;
import '../../../features/auth/domain/entities/user.dart';

/// PayTR callback handling servisi
class PaytrCallbackService {
  static final PaytrCallbackService _instance = PaytrCallbackService._internal();
  factory PaytrCallbackService() => _instance;
  PaytrCallbackService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PaytrService _paytrService = PaytrService();

  /// PayTR callback'i işle
  Future<PaytrCallbackResult> handleCallback({
    required String merchantOid,
    required String status,
    required String totalAmount,
    required String hash,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      debugPrint('🔄 Processing PayTR callback: $merchantOid');

      // Hash doğrulaması
      if (!_paytrService.verifyCallback(
        merchantOid: merchantOid,
        status: status,
        totalAmount: totalAmount,
        hash: hash,
      )) {
        return PaytrCallbackResult(
          success: false,
          error: 'Hash doğrulaması başarısız',
        );
      }

      // Sipariş ID'sinden kullanıcı bilgilerini çıkar
      final orderInfo = _parseOrderId(merchantOid);
      if (orderInfo == null) {
        return PaytrCallbackResult(
          success: false,
          error: 'Geçersiz sipariş ID',
        );
      }

      // Kullanıcıyı bul
      final user = await _getUser(orderInfo['userId']);
      if (user == null) {
        return PaytrCallbackResult(
          success: false,
          error: 'Kullanıcı bulunamadı',
        );
      }

      // Ödeme durumunu kontrol et
      if (status == 'success') {
        // Başarılı ödeme - aboneliği aktif et
        final subscription = await _createActiveSubscription(
          user: user,
          planType: orderInfo['planType'],
          amount: double.parse(totalAmount) / 100, // Kuruştan TL'ye çevir
          transactionId: merchantOid,
        );

        return PaytrCallbackResult(
          success: true,
          subscription: subscription,
          message: 'Abonelik başarıyla aktif edildi',
        );
      } else {
        // Başarısız ödeme
        return PaytrCallbackResult(
          success: false,
          error: 'Ödeme başarısız: $status',
        );
      }
    } catch (e) {
      debugPrint('❌ PayTR callback error: $e');
      return PaytrCallbackResult(
        success: false,
        error: 'Callback işleme hatası: $e',
      );
    }
  }

  /// Sipariş ID'sini parse et
  Map<String, dynamic>? _parseOrderId(String orderId) {
    try {
      // Format: TAMGACI_{userId}_{planType}_{timestamp}
      final parts = orderId.split('_');
      if (parts.length < 4 || parts[0] != 'TAMGACI') {
        return null;
      }

      final userId = parts[1];
      final planTypeName = parts[2];
      
      // Plan tipini enum'a çevir
      plan.SubscriptionPlanType? planType;
      for (final type in plan.SubscriptionPlanType.values) {
        if (type.name == planTypeName) {
          planType = type;
          break;
        }
      }

      if (planType == null) {
        return null;
      }

      return {
        'userId': userId,
        'planType': planType,
        'timestamp': parts[3],
      };
    } catch (e) {
      debugPrint('Parse order ID error: $e');
      return null;
    }
  }

  /// Kullanıcıyı Firestore'dan al
  Future<User?> _getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return User(
        id: data['id'] as String,
        email: data['email'] as String,
        name: data['name'] as String,
        surname: data['surname'] as String,
        phone: data['phone'] as String?,
        phoneE164: data['phoneE164'] as String?,
        phoneCountry: data['phoneCountry'] as String?,
        phoneDialCode: data['phoneDialCode'] as String?,
        profileImageUrl: data['profileImageUrl'] as String?,
        profileImagePath: data['profileImagePath'] as String?,
        profileImageMetadata: data['profileImageMetadata'] as Map<String, dynamic>?,
        role: UserRole.values.firstWhere(
          (e) => e.name == data['role'],
          orElse: () => UserRole.user,
        ),
        status: UserStatus.values.firstWhere(
          (e) => e.name == data['status'],
          orElse: () => UserStatus.active,
        ),
        tenantId: data['tenantId'] as String?,
        createdAt: DateTime.parse(data['createdAt'] as String),
        updatedAt: DateTime.parse(data['updatedAt'] as String),
        trialStartAt: data['trialStartAt'] != null ? DateTime.parse(data['trialStartAt'] as String) : null,
        trialEndAt: data['trialEndAt'] != null ? DateTime.parse(data['trialEndAt'] as String) : null,
        subscriptionStatus: SubscriptionStatus.fromString(data['subscriptionStatus'] ?? 'none'),
        subscriptionPlan: SubscriptionPlan.none, // User entity'de SubscriptionPlan enum'u farklı
        isEmailVerified: data['isEmailVerified'] as bool? ?? false,
        isTwoFactorEnabled: data['isTwoFactorEnabled'] as bool? ?? false,
        subscriptionEndAt: data['subscriptionEndAt'] != null ? DateTime.parse(data['subscriptionEndAt'] as String) : null,
        settings: data['settings'] as Map<String, dynamic>? ?? {},
      );
    } catch (e) {
      debugPrint('Get user error: $e');
      return null;
    }
  }

  /// Aktif abonelik oluştur
  Future<sub.SubscriptionEntity> _createActiveSubscription({
    required User user,
    required plan.SubscriptionPlanType planType,
    required double amount,
    required String transactionId,
  }) async {
    final now = DateTime.now();
    final endDate = _calculateEndDate(now, planType);

    final subscription = sub.SubscriptionEntity(
      id: _generateSubscriptionId(user.id, planType),
      userId: user.id,
      planType: planType,
      status: sub.SubscriptionStatus.active,
      provider: sub.PaymentProvider.paytr,
      startDate: now,
      endDate: endDate,
      amount: amount,
      paytrToken: transactionId,
      createdAt: now,
      updatedAt: now,
    );

    // Firestore'a kaydet
    await _firestore
        .collection('subscriptions')
        .doc(subscription.id)
        .set(subscription.toJson());

    // Kullanıcının abonelik durumunu güncelle
    await _updateUserSubscriptionStatus(user.id, subscription);

    debugPrint('✅ Subscription created: ${subscription.id}');
    return subscription;
  }

  /// Plan tipine göre bitiş tarihini hesapla
  DateTime _calculateEndDate(DateTime startDate, plan.SubscriptionPlanType planType) {
    switch (planType) {
      case plan.SubscriptionPlanType.monthly:
        return startDate.add(const Duration(days: 30));
      case plan.SubscriptionPlanType.semiAnnual:
        return startDate.add(const Duration(days: 180));
      case plan.SubscriptionPlanType.annual:
        return startDate.add(const Duration(days: 365));
      case plan.SubscriptionPlanType.none:
        return startDate;
    }
  }

  /// Abonelik ID'si oluştur
  String _generateSubscriptionId(String userId, plan.SubscriptionPlanType planType) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'SUB_${userId}_${planType.name}_$timestamp';
  }

  /// Kullanıcının abonelik durumunu güncelle
  Future<void> _updateUserSubscriptionStatus(
    String userId, 
    sub.SubscriptionEntity subscription,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'subscriptionStatus': subscription.status.name,
        'subscriptionPlan': subscription.planType.name,
        'subscriptionEndAt': subscription.endDate.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      debugPrint('✅ User subscription status updated: $userId');
    } catch (e) {
      debugPrint('❌ Update user subscription status error: $e');
      rethrow;
    }
  }

  /// PayTR ödeme durumunu sorgula
  Future<PaytrCallbackResult> checkPaymentStatus(String orderId) async {
    try {
      final statusResponse = await _paytrService.checkPaymentStatus(orderId);
      
      if (!statusResponse.success) {
        return PaytrCallbackResult(
          success: false,
          error: statusResponse.error ?? 'Durum sorgulanamadı',
        );
      }

      // Durum başarılı ise callback'i işle
      if (statusResponse.status == 'success') {
        return await handleCallback(
          merchantOid: orderId,
          status: 'success',
          totalAmount: statusResponse.totalAmount ?? '0',
          hash: '', // Status sorgusunda hash gerekli değil
        );
      } else {
        return PaytrCallbackResult(
          success: false,
          error: 'Ödeme durumu: ${statusResponse.status}',
        );
      }
    } catch (e) {
      debugPrint('❌ Check payment status error: $e');
      return PaytrCallbackResult(
        success: false,
        error: 'Durum kontrol hatası: $e',
      );
    }
  }
}

/// PayTR callback sonucu
class PaytrCallbackResult {
  final bool success;
  final sub.SubscriptionEntity? subscription;
  final String? message;
  final String? error;

  const PaytrCallbackResult({
    required this.success,
    this.subscription,
    this.message,
    this.error,
  });
}
