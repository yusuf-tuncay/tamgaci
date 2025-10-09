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
      final userBasket = _generateUserBasket(amount, planType);
      final userIp = await _getUserIp();

      // PayTR parametreleri
      final params = PaytrConfig.getBaseParameters(
        userEmail: user.email,
        userPhone: user.phone ?? '',
        userName: '${user.name} ${user.surname}',
        amount: amount,
        orderId: orderId,
        userIp: userIp,
        userAddress: userAddress,
      );

      // User basket'i ekle
      params['user_basket'] = userBasket;

      // PayTR hash oluştur (dokümantasyona göre)
      final hash = _generatePaytrHash(params);

      // Debug: Parametreleri yazdır
      debugPrint('PayTR Request Params: $params');
      debugPrint('PayTR Hash: $hash');

      // PayTR API'ye istek gönder
      final response = await _sendTokenRequest(params, hash);

      // Debug: Response'u yazdır
      debugPrint('PayTR Response: $response');

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

      // Status query için hash gerekli değil

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
    // PayTR merchant_oid alfanumerik olmalı, özel karakter içeremez
    // userId'deki özel karakterleri temizle
    final cleanUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return 'TAMGACI$cleanUserId$planId$timestamp';
  }

  /// Kullanıcı sepeti oluştur (PayTR formatında)
  String _generateUserBasket(double amount, SubscriptionPlanType planType) {
    final productName = PaytrConfig.getProductName(planType);
    final priceInKurus = (amount * 100).toInt();
    // PayTR format: [["Ürün adı", "Fiyat", "Adet"]]
    final basketJson = '[["$productName", "$priceInKurus", "1"]]';
    // Base64 encode
    return base64.encode(utf8.encode(basketJson));
  }

  /// Kullanıcı IP adresini al
  Future<String> _getUserIp() async {
    try {
      // Node.js örneğinde user_ip boş string olarak gönderiliyor
      // PayTR test ortamında boş string kabul ediyor
      return ''; // Node.js örneğine uygun boş string
    } catch (e) {
      debugPrint('IP alınamadı: $e');
      return ''; // Fallback boş string
    }
  }

  /// PayTR hash oluştur (dokümantasyona göre)
  String _generatePaytrHash(Map<String, dynamic> params) {
    // PayTR hash format: merchant_id + user_ip + merchant_oid + email + payment_amount + user_basket + no_installment + max_installment + currency + test_mode
    final hashStr =
        '${params['merchant_id']}${params['user_ip']}${params['merchant_oid']}${params['email']}${params['payment_amount']}${params['user_basket']}${params['no_installment']}${params['max_installment']}${params['currency']}${params['test_mode']}';

    // PayTR PHP: base64_encode(hash_hmac('sha256', $hash_str.$merchant_salt, $merchant_key, true))
    final key = utf8.encode(params['merchant_key'] as String);
    final data = utf8.encode(hashStr + (params['merchant_salt'] as String));
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(data);

    return base64.encode(digest.bytes);
  }

  /// Token isteği gönder
  Future<Map<String, dynamic>> _sendTokenRequest(
    Map<String, dynamic> params,
    String hash,
  ) async {
    final requestParams = Map<String, dynamic>.from(params);

    // Node.js örneğine göre merchant_key ve merchant_salt da gönderiliyor
    // requestParams.remove('merchant_key');
    // requestParams.remove('merchant_salt');

    // Hash'i ekle
    requestParams['paytr_token'] = hash;

    // Form data'ya çevir
    final formData = requestParams.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}',
        )
        .join('&');

    // Debug: Form data'yı yazdır
    debugPrint('PayTR Form Data: $formData');
    debugPrint('PayTR URL: ${PaytrConfig.iframeUrl}');

    final response = await http.post(
      Uri.parse(PaytrConfig.iframeUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: formData,
    );

    // Debug: HTTP response'u yazdır
    debugPrint('PayTR HTTP Status: ${response.statusCode}');
    debugPrint('PayTR HTTP Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// Callback doğrulama (PayTR dokümantasyonuna göre)
  bool verifyCallback({
    required String merchantOid,
    required String status,
    required String totalAmount,
    required String hash,
  }) {
    try {
      // PayTR callback hash format: merchant_oid + merchant_salt + status + total_amount
      final hashString =
          '$merchantOid${PaytrConfig.merchantSalt}$status$totalAmount';

      // HMAC-SHA256 ile hash oluştur
      final key = utf8.encode(PaytrConfig.merchantKey);
      final data = utf8.encode(hashString);
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(data);
      final expectedHash = base64.encode(digest.bytes);

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
