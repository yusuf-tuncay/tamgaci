// ========== PAYMENT STATUS ENUM ==========
// lib/features/payments/domain/entities/payment_status.dart

import 'package:flutter/material.dart';

enum PaymentStatus {
  pending('Beklemede'),
  completed('Tamamlandı'),
  cancelled('İptal Edildi'),
  failed('Başarısız');

  const PaymentStatus(this.displayName);
  final String displayName;

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.cancelled:
        return Colors.red;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }
}
