// ========== PAYMENT TYPE ENUM ==========
// lib/features/payments/domain/entities/payment_type.dart

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
}
