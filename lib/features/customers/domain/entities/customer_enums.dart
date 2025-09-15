// ========== CUSTOMER ENUMS ==========
// lib/features/customers/domain/entities/customer_enums.dart

/// Müşteri türleri enum'u
enum CustomerType {
  /// Bireysel müşteri
  individual,

  /// Kurumsal müşteri
  company;

  /// Kullanıcıya gösterilecek isim
  String get displayName {
    switch (this) {
      case CustomerType.individual:
        return 'Bireysel';
      case CustomerType.company:
        return 'Kurumsal';
    }
  }

  /// Database'de saklanacak değer
  String get value {
    switch (this) {
      case CustomerType.individual:
        return 'individual';
      case CustomerType.company:
        return 'company';
    }
  }

  /// String değerden CustomerType oluşturma
  static CustomerType fromValue(String value) {
    switch (value) {
      case 'individual':
        return CustomerType.individual;
      case 'company':
        return CustomerType.company;
      default:
        return CustomerType.individual;
    }
  }
}

/// Müşteri durumu enum'u
enum CustomerStatus {
  active,
  inactive,
  suspended,
  blocked;

  String get displayName {
    switch (this) {
      case CustomerStatus.active:
        return 'Aktif';
      case CustomerStatus.inactive:
        return 'Pasif';
      case CustomerStatus.suspended:
        return 'Askıya Alınmış';
      case CustomerStatus.blocked:
        return 'Engellenmiş';
    }
  }

  static CustomerStatus fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return CustomerStatus.active;
      case 'inactive':
        return CustomerStatus.inactive;
      case 'suspended':
        return CustomerStatus.suspended;
      case 'blocked':
        return CustomerStatus.blocked;
      default:
        return CustomerStatus.active;
    }
  }
}
