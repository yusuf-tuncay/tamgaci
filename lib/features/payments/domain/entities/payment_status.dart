// ========== PAYMENT STATUS ENUM ==========
// lib/features/payments/domain/entities/payment_status.dart

enum PaymentStatus {
  pending('Beklemede'),
  completed('Tamamlandı'),
  cancelled('İptal Edildi'),
  failed('Başarısız');

  const PaymentStatus(this.displayName);
  final String displayName;
}
