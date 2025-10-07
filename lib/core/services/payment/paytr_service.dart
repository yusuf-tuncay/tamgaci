// ========== PAYTR SERVICE ==========
// lib/core/services/payment/paytr_service.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'paytr_config.dart';
import '../../../features/subscription/domain/entities/subscription_plan.dart';
import '../../../features/auth/domain/entities/user.dart';

/// PayTR ödeme servisi
class PaytrService {
  static final PaytrService _instance = PaytrService._internal();
  factory PaytrService() => _instance;
  PaytrService._internal();

  /// PayTR token oluştur
  Future<PaytrTokenResponse> createPaymentToken({
    required User user,
    required SubscriptionPlanType planType,
    required double amount,
    String? userAddress,
  }) async {
    try {
      final orderId = _generateOrderId(user.id, planType);
      // final userBasket = _generateUserBasket(amount); // PayTR'de kullanılacak
      
      // PayTR parametreleri
      final params = PaytrConfig.getBaseParameters(
        userEmail: user.email,
        userPhone: user.phone ?? '',
        userName: '${user.name} ${user.surname}',
        amount: amount,
        orderId: orderId,
        userAddress: userAddress,
      );

      // Hash oluştur
      final hashString = _createHashString(params);
      final hash = _generateHash(hashString);

      // PayTR API'ye istek gönder
      final response = await _sendTokenRequest(params, hash);

      if (response['status'] == 'success') {
        return PaytrTokenResponse(
          success: true,
          token: response['token'],
          orderId: orderId,
        );
      } else {
        return PaytrTokenResponse(
          success: false,
          error: response['reason'] ?? 'Bilinmeyen hata',
        );
      }
    } catch (e) {
      debugPrint('PayTR Token Error: $e');
      return PaytrTokenResponse(
        success: false,
        error: 'Ödeme token oluşturulamadı: $e',
      );
    }
  }

  /// PayTR ödeme durumu sorgula
  Future<PaytrStatusResponse> checkPaymentStatus(String orderId) async {
    try {
      final params = {
        'merchant_id': PaytrConfig.merchantId,
        'merchant_key': PaytrConfig.merchantKey,
        'merchant_salt': PaytrConfig.merchantSalt,
        'merchant_oid': orderId,
      };

      final hashString = _createHashString(params);
      final hash = _generateHash(hashString);
      params['hash'] = hash;

      final response = await http.post(
        Uri.parse(PaytrConfig.statusQueryUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaytrStatusResponse.fromJson(data);
      } else {
        return PaytrStatusResponse(
          success: false,
          error: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('PayTR Status Check Error: $e');
      return PaytrStatusResponse(
        success: false,
        error: 'Durum sorgulanamadı: $e',
      );
    }
  }

  /// Sipariş ID oluştur
  String _generateOrderId(String userId, SubscriptionPlanType planType) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final planId = planType.name;
    return 'TAMGACI_${userId}_${planId}_$timestamp';
  }


  /// Hash string oluştur
  String _createHashString(Map<String, dynamic> params) {
    final sortedKeys = params.keys.toList()..sort();
    return sortedKeys.map((key) => '$key=${params[key]}').join('&');
  }

  /// Hash oluştur
  String _generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Token isteği gönder
  Future<Map<String, dynamic>> _sendTokenRequest(
    Map<String, dynamic> params,
    String hash,
  ) async {
    final requestParams = Map<String, dynamic>.from(params);
    requestParams['hash'] = hash;

    final response = await http.post(
      Uri.parse(PaytrConfig.iframeUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: requestParams,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// Callback doğrulama
  bool verifyCallback({
    required String merchantOid,
    required String status,
    required String totalAmount,
    required String hash,
  }) {
    try {
      final hashString = '$merchantOid$status$totalAmount${PaytrConfig.merchantSalt}';
      final expectedHash = _generateHash(hashString);
      return hash == expectedHash;
    } catch (e) {
      debugPrint('PayTR Callback Verification Error: $e');
      return false;
    }
  }
}

/// PayTR token response
class PaytrTokenResponse {
  final bool success;
  final String? token;
  final String? orderId;
  final String? error;

  const PaytrTokenResponse({
    required this.success,
    this.token,
    this.orderId,
    this.error,
  });
}

/// PayTR status response
class PaytrStatusResponse {
  final bool success;
  final String? status;
  final String? totalAmount;
  final String? merchantOid;
  final String? error;

  const PaytrStatusResponse({
    required this.success,
    this.status,
    this.totalAmount,
    this.merchantOid,
    this.error,
  });

  factory PaytrStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaytrStatusResponse(
      success: json['status'] == 'success',
      status: json['payment_status'],
      totalAmount: json['total_amount'],
      merchantOid: json['merchant_oid'],
      error: json['reason'],
    );
  }
}
