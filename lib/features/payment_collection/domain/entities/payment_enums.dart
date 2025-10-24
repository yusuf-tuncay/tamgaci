// ========== PAYMENT ENUMS ==========
// lib/features/payment_collection/domain/entities/payment_enums.dart

/// Ödeme işlemi türleri
enum PaymentTransactionType {
  cash('Nakit'),
  creditCard('Kredi Kartı'),
  eftTransfer('EFT / Havale'),
  check('Çek'),
  promissoryNote('Senet'),
  debtReceipt('Borç Fişi'),
  creditReceipt('Alacak Fişi'),
  accountTransfer('Cari Virman');

  const PaymentTransactionType(this.displayName);
  final String displayName;

  /// İşlem türü ikonu
  String get icon {
    switch (this) {
      case PaymentTransactionType.cash:
        return '💵';
      case PaymentTransactionType.creditCard:
        return '💳';
      case PaymentTransactionType.eftTransfer:
        return '🏦';
      case PaymentTransactionType.check:
        return '📄';
      case PaymentTransactionType.promissoryNote:
        return '📋';
      case PaymentTransactionType.debtReceipt:
        return '📝';
      case PaymentTransactionType.creditReceipt:
        return '📜';
      case PaymentTransactionType.accountTransfer:
        return '🔄';
    }
  }

  /// İşlem türü rengi
  String get color {
    switch (this) {
      case PaymentTransactionType.cash:
        return 'green';
      case PaymentTransactionType.creditCard:
        return 'blue';
      case PaymentTransactionType.eftTransfer:
        return 'purple';
      case PaymentTransactionType.check:
        return 'orange';
      case PaymentTransactionType.promissoryNote:
        return 'yellow';
      case PaymentTransactionType.debtReceipt:
        return 'red';
      case PaymentTransactionType.creditReceipt:
        return 'green';
      case PaymentTransactionType.accountTransfer:
        return 'grey';
    }
  }
}

/// Ödeme işlemi kategorileri
enum PaymentTransactionCategory {
  customerPayment('Müşteri Tahsilatı'),
  supplierPayment('Tedarikçi Ödemesi'),
  internalTransfer('İç Transfer'),
  adjustment('Düzeltme'),
  refund('İade'),
  commission('Komisyon'),
  interest('Faiz'),
  penalty('Ceza'),
  other('Diğer');

  const PaymentTransactionCategory(this.displayName);
  final String displayName;

  /// Kategori ikonu
  String get icon {
    switch (this) {
      case PaymentTransactionCategory.customerPayment:
        return '💰';
      case PaymentTransactionCategory.supplierPayment:
        return '💸';
      case PaymentTransactionCategory.internalTransfer:
        return '🔄';
      case PaymentTransactionCategory.adjustment:
        return '⚖️';
      case PaymentTransactionCategory.refund:
        return '↩️';
      case PaymentTransactionCategory.commission:
        return '💼';
      case PaymentTransactionCategory.interest:
        return '📈';
      case PaymentTransactionCategory.penalty:
        return '⚠️';
      case PaymentTransactionCategory.other:
        return '📋';
    }
  }
}

/// Ödeme işlemi durumları
enum PaymentTransactionStatus {
  pending('Beklemede'),
  processing('İşleniyor'),
  completed('Tamamlandı'),
  approved('Onaylandı'),
  rejected('Reddedildi'),
  failed('Başarısız'),
  cancelled('İptal'),
  reversed('Geri Alındı'),
  refunded('İade Edildi'),
  disputed('İtiraz Edildi'),
  onHold('Bekletildi');

  const PaymentTransactionStatus(this.displayName);
  final String displayName;

  /// Durum rengi
  String get color {
    switch (this) {
      case PaymentTransactionStatus.pending:
        return 'orange';
      case PaymentTransactionStatus.processing:
        return 'blue';
      case PaymentTransactionStatus.completed:
        return 'green';
      case PaymentTransactionStatus.approved:
        return 'green';
      case PaymentTransactionStatus.rejected:
        return 'red';
      case PaymentTransactionStatus.failed:
        return 'red';
      case PaymentTransactionStatus.cancelled:
        return 'grey';
      case PaymentTransactionStatus.reversed:
        return 'orange';
      case PaymentTransactionStatus.refunded:
        return 'purple';
      case PaymentTransactionStatus.disputed:
        return 'yellow';
      case PaymentTransactionStatus.onHold:
        return 'amber';
    }
  }

  /// Durum ikonu
  String get icon {
    switch (this) {
      case PaymentTransactionStatus.pending:
        return '⏳';
      case PaymentTransactionStatus.processing:
        return '🔄';
      case PaymentTransactionStatus.completed:
        return '✅';
      case PaymentTransactionStatus.approved:
        return '✅';
      case PaymentTransactionStatus.rejected:
        return '❌';
      case PaymentTransactionStatus.failed:
        return '❌';
      case PaymentTransactionStatus.cancelled:
        return '🚫';
      case PaymentTransactionStatus.reversed:
        return '↩️';
      case PaymentTransactionStatus.refunded:
        return '↩️';
      case PaymentTransactionStatus.disputed:
        return '⚠️';
      case PaymentTransactionStatus.onHold:
        return '⏸️';
    }
  }
}

/// Ödeme yönü
enum PaymentDirection {
  incoming('Giriş'),
  outgoing('Çıkış');

  const PaymentDirection(this.displayName);
  final String displayName;

  /// Yön ikonu
  String get icon {
    switch (this) {
      case PaymentDirection.incoming:
        return '⬇️';
      case PaymentDirection.outgoing:
        return '⬆️';
    }
  }

  /// Yön rengi
  String get color {
    switch (this) {
      case PaymentDirection.incoming:
        return 'green';
      case PaymentDirection.outgoing:
        return 'red';
    }
  }
}

/// Ödeme kaynağı türleri
enum PaymentSourceType {
  cash('Nakit Kasa'),
  bankAccount('Banka Hesabı'),
  pos('POS Terminali'),
  online('Online Ödeme'),
  mobile('Mobil Ödeme'),
  other('Diğer');

  const PaymentSourceType(this.displayName);
  final String displayName;

  /// Kaynak türü ikonu
  String get icon {
    switch (this) {
      case PaymentSourceType.cash:
        return '💵';
      case PaymentSourceType.bankAccount:
        return '🏦';
      case PaymentSourceType.pos:
        return '💳';
      case PaymentSourceType.online:
        return '🌐';
      case PaymentSourceType.mobile:
        return '📱';
      case PaymentSourceType.other:
        return '📋';
    }
  }
}

/// Ödeme yöntemi türleri
enum PaymentMethodType {
  cash('Nakit'),
  creditCard('Kredi Kartı'),
  debitCard('Banka Kartı'),
  bankTransfer('Banka Transferi'),
  check('Çek'),
  promissoryNote('Senet'),
  digitalWallet('Dijital Cüzdan'),
  cryptocurrency('Kripto Para'),
  other('Diğer');

  const PaymentMethodType(this.displayName);
  final String displayName;

  /// Yöntem türü ikonu
  String get icon {
    switch (this) {
      case PaymentMethodType.cash:
        return '💵';
      case PaymentMethodType.creditCard:
        return '💳';
      case PaymentMethodType.debitCard:
        return '🏦';
      case PaymentMethodType.bankTransfer:
        return '🔄';
      case PaymentMethodType.check:
        return '📄';
      case PaymentMethodType.promissoryNote:
        return '📋';
      case PaymentMethodType.digitalWallet:
        return '📱';
      case PaymentMethodType.cryptocurrency:
        return '₿';
      case PaymentMethodType.other:
        return '📋';
    }
  }
}

/// Çek durumları
enum CheckStatus {
  pending('Beklemede'),
  deposited('Yatırıldı'),
  cleared('Tahsil Edildi'),
  bounced('Karşılıksız'),
  cancelled('İptal'),
  expired('Süresi Doldu');

  const CheckStatus(this.displayName);
  final String displayName;

  /// Çek durumu rengi
  String get color {
    switch (this) {
      case CheckStatus.pending:
        return 'orange';
      case CheckStatus.deposited:
        return 'blue';
      case CheckStatus.cleared:
        return 'green';
      case CheckStatus.bounced:
        return 'red';
      case CheckStatus.cancelled:
        return 'grey';
      case CheckStatus.expired:
        return 'red';
    }
  }
}

/// Senet durumları
enum PromissoryNoteStatus {
  pending('Beklemede'),
  accepted('Kabul Edildi'),
  rejected('Reddedildi'),
  paid('Ödendi'),
  overdue('Vadesi Geçti'),
  cancelled('İptal');

  const PromissoryNoteStatus(this.displayName);
  final String displayName;

  /// Senet durumu rengi
  String get color {
    switch (this) {
      case PromissoryNoteStatus.pending:
        return 'orange';
      case PromissoryNoteStatus.accepted:
        return 'blue';
      case PromissoryNoteStatus.rejected:
        return 'red';
      case PromissoryNoteStatus.paid:
        return 'green';
      case PromissoryNoteStatus.overdue:
        return 'red';
      case PromissoryNoteStatus.cancelled:
        return 'grey';
    }
  }
}

/// Ödeme onay seviyeleri
enum PaymentApprovalLevel {
  none('Onay Gerekmez'),
  single('Tek Onay'),
  double('Çift Onay'),
  multiple('Çoklu Onay');

  const PaymentApprovalLevel(this.displayName);
  final String displayName;
}

/// Ödeme öncelik seviyeleri
enum PaymentPriority {
  low('Düşük'),
  normal('Normal'),
  high('Yüksek'),
  urgent('Acil');

  const PaymentPriority(this.displayName);
  final String displayName;

  /// Öncelik rengi
  String get color {
    switch (this) {
      case PaymentPriority.low:
        return 'green';
      case PaymentPriority.normal:
        return 'blue';
      case PaymentPriority.high:
        return 'orange';
      case PaymentPriority.urgent:
        return 'red';
    }
  }

  /// Öncelik ikonu
  String get icon {
    switch (this) {
      case PaymentPriority.low:
        return '🟢';
      case PaymentPriority.normal:
        return '🔵';
      case PaymentPriority.high:
        return '🟠';
      case PaymentPriority.urgent:
        return '🔴';
    }
  }
}
