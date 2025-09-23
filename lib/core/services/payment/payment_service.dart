// ========== PAYMENT SERVICE ==========
// lib/core/services/payment/payment_service.dart

import 'package:url_launcher/url_launcher.dart';
import '../../../features/auth/domain/entities/user.dart' as auth_domain;
import 'paytr_config.dart';

class PaymentService {
  const PaymentService();

  Future<bool> startCheckout(auth_domain.SubscriptionPlan plan) async {
    final planParam = _planToParam(plan);
    final paytr = PaytrConfig.fromEnv();
    // If PayTR not configured yet, open info page (placeholder) and return false
    if (!paytr.isConfigured) {
      final info = Uri.parse('https://tamgaci.com/odeme-bilgi?plan=$planParam');
      try {
        if (await canLaunchUrl(info)) {
          await launchUrl(info, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
      return false;
    }
    // Otherwise, proceed to merchant checkout URL (placeholder until token backend hazır)
    final uri =
        Uri.parse('https://www.paytr.com/odeme/guvenli?plan=$planParam');
    try {
      if (await canLaunchUrl(uri)) {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        return ok;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  String _planToParam(auth_domain.SubscriptionPlan plan) {
    switch (plan) {
      case auth_domain.SubscriptionPlan.monthly:
        return 'monthly';
      case auth_domain.SubscriptionPlan.semiAnnual:
        return 'semi_annual';
      case auth_domain.SubscriptionPlan.annual:
        return 'annual';
      case auth_domain.SubscriptionPlan.none:
        return 'none';
    }
  }
}
