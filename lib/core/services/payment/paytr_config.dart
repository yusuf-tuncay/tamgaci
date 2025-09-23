// ========== PAYTR CONFIG ==========
// lib/core/services/payment/paytr_config.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaytrConfig {
  final String merchantId;
  final String merchantKey;
  final String merchantSalt;
  final String callbackUrl;

  const PaytrConfig({
    required this.merchantId,
    required this.merchantKey,
    required this.merchantSalt,
    required this.callbackUrl,
  });

  bool get isConfigured =>
      merchantId.isNotEmpty &&
      merchantKey.isNotEmpty &&
      merchantSalt.isNotEmpty;

  static PaytrConfig fromEnv() {
    const id = String.fromEnvironment('PAYTR_MERCHANT_ID', defaultValue: '');
    const key = String.fromEnvironment('PAYTR_MERCHANT_KEY', defaultValue: '');
    const salt =
        String.fromEnvironment('PAYTR_MERCHANT_SALT', defaultValue: '');
    const cb = String.fromEnvironment('PAYTR_CALLBACK_URL', defaultValue: '');
    return const PaytrConfig(
      merchantId: id,
      merchantKey: key,
      merchantSalt: salt,
      callbackUrl: cb,
    );
  }
}

final paytrConfigProvider = Provider<PaytrConfig>((ref) {
  return PaytrConfig.fromEnv();
});
