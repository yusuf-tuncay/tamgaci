// ========== PAYMENT TYPE ENUM ==========
// lib/features/payments/domain/entities/payment_type.dart

import 'package:flutter/material.dart';

enum PaymentType {
  cash('Nakit'),
  creditCard('Kredi Kartı'),
  bank('Banka'),
  check('Çek'),
  promissoryNote('Senet'),
  transfer('Cari Virman'),
  voucher('Borç-Alacak Fişi'),
  balanceAdjustment('Bakiye Düzelt');

  const PaymentType(this.displayName);
  final String displayName;

  IconData get icon {
    switch (this) {
      case PaymentType.cash:
        return Icons.monetization_on;
      case PaymentType.creditCard:
        return Icons.credit_card;
      case PaymentType.bank:
        return Icons.account_balance;
      case PaymentType.check:
        return Icons.receipt_long;
      case PaymentType.promissoryNote:
        return Icons.description;
      case PaymentType.transfer:
        return Icons.swap_horiz;
      case PaymentType.voucher:
        return Icons.receipt;
      case PaymentType.balanceAdjustment:
        return Icons.balance;
    }
  }

  Color get color {
    switch (this) {
      case PaymentType.cash:
        return Colors.green;
      case PaymentType.creditCard:
        return Colors.blue;
      case PaymentType.bank:
        return Colors.indigo;
      case PaymentType.check:
        return Colors.orange;
      case PaymentType.promissoryNote:
        return Colors.purple;
      case PaymentType.transfer:
        return Colors.teal;
      case PaymentType.voucher:
        return Colors.red;
      case PaymentType.balanceAdjustment:
        return Colors.grey;
    }
  }
}
