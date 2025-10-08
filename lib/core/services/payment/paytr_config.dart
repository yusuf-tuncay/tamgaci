// ========== PAYTR CONFIG ==========
// lib/core/services/payment/paytr_config.dart

import '../../../features/subscription/domain/entities/subscription_plan.dart';

/// PayTR konfigürasyon sınıfı
class PaytrConfig {
  /// Merchant ID (Mağaza No)
  static const String merchantId = '622887';

  /// Merchant Key (Mağaza Parola)
  static const String merchantKey = 'uePB67AfxtAAyqZ';

  /// Merchant Salt (Mağaza Gizli Anahtar)
  static const String merchantSalt = 'ejdEC3ReZay7QxE8';

  /// PayTR API URL'leri
  static const String apiBaseUrl = 'https://www.paytr.com';
  static const String iframeUrl = '$apiBaseUrl/odeme/api/get-token';
  static const String statusQueryUrl = '$apiBaseUrl/odeme/durum-sorgu';

  /// Test modu (development için)
  static const bool testMode = true; // Production'da false yapılacak

  /// Callback URL'leri (Firebase Hosting)
  static const String successUrl =
      'https://tamgaci.web.app/#/subscription/success';
  static const String failUrl = 'https://tamgaci.web.app/#/subscription/fail';
  static const String callbackUrl =
      'https://tamgaci.web.app/api/paytr/callback';

  /// Para birimi
  static const String currency = 'TL';

  /// Dil kodu
  static const String lang = 'tr';

  /// Timeout (saniye)
  static const int timeout = 30;

  /// Debug modu
  static const bool debugMode = true;

  /// Konfigürasyon geçerli mi?
  static bool get isConfigured =>
      merchantId.isNotEmpty &&
      merchantKey.isNotEmpty &&
      merchantSalt.isNotEmpty;

  /// Test merchant bilgileri
  static Map<String, String> get testCredentials => {
        'merchant_id': testMode ? 'test_merchant' : merchantId,
        'merchant_key': testMode ? 'test_key' : merchantKey,
        'merchant_salt': testMode ? 'test_salt' : merchantSalt,
      };

  /// Production merchant bilgileri
  static Map<String, String> get productionCredentials => {
        'merchant_id': merchantId,
        'merchant_key': merchantKey,
        'merchant_salt': merchantSalt,
      };

  /// Aktif merchant bilgileri
  static Map<String, String> get activeCredentials =>
      testMode ? testCredentials : productionCredentials;

  /// PayTR için gerekli parametreler
  static Map<String, dynamic> getBaseParameters({
    required String userEmail,
    required String userPhone,
    required String userName,
    required double amount,
    required String orderId,
    String? userAddress,
  }) {
    final credentials = activeCredentials;

    return {
      'merchant_id': credentials['merchant_id'],
      'merchant_key': credentials['merchant_key'],
      'merchant_salt': credentials['merchant_salt'],
      'email': userEmail,
      'payment_amount': (amount * 100).toInt(), // PayTR kuruş cinsinden bekler
      'merchant_oid': orderId,
      'user_name': userName,
      'user_address': userAddress ?? 'Belirtilmemiş',
      'user_phone': userPhone,
      'merchant_ok_url': successUrl,
      'merchant_fail_url': failUrl,
      'user_basket': '', // Service'de oluşturulacak
      'debug_on': debugMode ? 1 : 0,
      'test_mode': testMode ? 1 : 0,
      'currency': currency,
      'lang': lang,
      'timeout_limit': timeout,
    };
  }


  /// Hash oluştur (PayTR token için gerekli)
  static String generatePaytrToken({
    required String merchantId,
    required String userEmail,
    required int paymentAmount,
    required String merchantOid,
    required String userBasket,
    required String merchantSalt,
  }) {
    // PayTR hash format: merchant_id + user_email + payment_amount + merchant_oid + user_basket + merchant_salt
    final hashString = '$merchantId$userEmail$paymentAmount$merchantOid$userBasket$merchantSalt';
    return hashString;
  }

  /// Plan tipine göre ürün adı
  static String getProductName(SubscriptionPlanType planType) {
    switch (planType) {
      case SubscriptionPlanType.monthly:
        return 'Tamgacı Aylık Abonelik';
      case SubscriptionPlanType.semiAnnual:
        return 'Tamgacı 6 Aylık Abonelik';
      case SubscriptionPlanType.annual:
        return 'Tamgacı Yıllık Abonelik';
      case SubscriptionPlanType.none:
        return 'Tamgacı Abonelik';
    }
  }
}
