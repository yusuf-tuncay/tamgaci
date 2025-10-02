// ========== SUPPLIER ENUMS ==========
// lib/features/suppliers/domain/entities/supplier_enums.dart

/// Tedarikçi türleri enum'u
enum SupplierType {
  /// Bireysel tedarikçi
  individual,

  /// Kurumsal tedarikçi
  company;

  /// Kullanıcıya gösterilecek isim
  String get displayName {
    switch (this) {
      case SupplierType.individual:
        return 'Bireysel';
      case SupplierType.company:
        return 'Kurumsal';
    }
  }

  /// Database'de saklanacak değer
  String get value {
    switch (this) {
      case SupplierType.individual:
        return 'individual';
      case SupplierType.company:
        return 'company';
    }
  }

  /// String değerden SupplierType oluşturma
  static SupplierType fromValue(String value) {
    switch (value) {
      case 'individual':
        return SupplierType.individual;
      case 'company':
        return SupplierType.company;
      default:
        return SupplierType.individual;
    }
  }
}

/// Tedarikçi durumu enum'u
enum SupplierStatus {
  active,
  inactive,
  suspended,
  blocked;

  String get displayName {
    switch (this) {
      case SupplierStatus.active:
        return 'Aktif';
      case SupplierStatus.inactive:
        return 'Pasif';
      case SupplierStatus.suspended:
        return 'Askıya Alınmış';
      case SupplierStatus.blocked:
        return 'Engellenmiş';
    }
  }

  static SupplierStatus fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return SupplierStatus.active;
      case 'inactive':
        return SupplierStatus.inactive;
      case 'suspended':
        return SupplierStatus.suspended;
      case 'blocked':
        return SupplierStatus.blocked;
      default:
        return SupplierStatus.active;
    }
  }
}

/// Tedarikçi ödeme durumu enum'u
enum SupplierPaymentStatus {
  /// Ödeme bekleniyor
  pending,

  /// Ödeme yapıldı
  paid,

  /// Ödeme gecikti
  overdue,

  /// Ödeme iptal edildi
  cancelled;

  String get displayName {
    switch (this) {
      case SupplierPaymentStatus.pending:
        return 'Ödeme Bekleniyor';
      case SupplierPaymentStatus.paid:
        return 'Ödendi';
      case SupplierPaymentStatus.overdue:
        return 'Gecikmiş';
      case SupplierPaymentStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  static SupplierPaymentStatus fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return SupplierPaymentStatus.pending;
      case 'paid':
        return SupplierPaymentStatus.paid;
      case 'overdue':
        return SupplierPaymentStatus.overdue;
      case 'cancelled':
        return SupplierPaymentStatus.cancelled;
      default:
        return SupplierPaymentStatus.pending;
    }
  }
}

/// Tedarikçi risk seviyesi enum'u
enum SupplierRiskLevel {
  /// Düşük risk
  low,

  /// Orta risk
  medium,

  /// Yüksek risk
  high,

  /// Kritik risk
  critical;

  String get displayName {
    switch (this) {
      case SupplierRiskLevel.low:
        return 'Düşük Risk';
      case SupplierRiskLevel.medium:
        return 'Orta Risk';
      case SupplierRiskLevel.high:
        return 'Yüksek Risk';
      case SupplierRiskLevel.critical:
        return 'Kritik Risk';
    }
  }

  static SupplierRiskLevel fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return SupplierRiskLevel.low;
      case 'medium':
        return SupplierRiskLevel.medium;
      case 'high':
        return SupplierRiskLevel.high;
      case 'critical':
        return SupplierRiskLevel.critical;
      default:
        return SupplierRiskLevel.low;
    }
  }
}
