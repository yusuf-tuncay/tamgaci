// ========== lib/features/invoices/data/models/invoice_status.dart ==========

/// Fatura durumları enum'u
enum InvoiceStatus {
  /// Taslak - Henüz gönderilmemiş
  draft('draft', 'Taslak'),

  /// Gönderildi - Müşteriye gönderildi
  sent('sent', 'Gönderildi'),

  /// Ödendi - Tam ödeme alındı
  paid('paid', 'Ödendi'),

  /// Vadesi Geçmiş - Ödenmemiş ve vadesi geçmiş
  overdue('overdue', 'Vadesi Geçmiş'),

  /// İptal Edildi
  cancelled('cancelled', 'İptal Edildi'),

  /// Kısmen Ödendi - Parçalı ödeme alındı
  partiallyPaid('partially_paid', 'Kısmen Ödendi'),

  /// Ödenmedi - Henüz ödenmemiş
  unpaid('unpaid', 'Ödenmedi');

  const InvoiceStatus(this.value, this.displayName);

  /// Database'de saklanacak değer
  final String value;

  /// Kullanıcıya gösterilecek isim
  final String displayName;

  /// String değerden InvoiceStatus oluşturma
  static InvoiceStatus fromValue(String value) {
    switch (value) {
      case 'draft':
        return InvoiceStatus.draft;
      case 'sent':
        return InvoiceStatus.sent;
      case 'paid':
        return InvoiceStatus.paid;
      case 'overdue':
        return InvoiceStatus.overdue;
      case 'cancelled':
        return InvoiceStatus.cancelled;
      case 'partially_paid':
        return InvoiceStatus.partiallyPaid;
      case 'unpaid':
        return InvoiceStatus.unpaid;
      default:
        throw ArgumentError('Invalid invoice status: $value');
    }
  }

  /// Duruma göre renk kodu
  String get colorCode {
    switch (this) {
      case InvoiceStatus.draft:
        return '#9E9E9E'; // Gray
      case InvoiceStatus.sent:
        return '#2196F3'; // Blue
      case InvoiceStatus.paid:
        return '#4CAF50'; // Green
      case InvoiceStatus.overdue:
        return '#F44336'; // Red
      case InvoiceStatus.cancelled:
        return '#607D8B'; // Blue Gray
      case InvoiceStatus.partiallyPaid:
        return '#FF9800'; // Orange
      case InvoiceStatus.unpaid:
        return '#FF5722'; // Deep Orange
    }
  }
}

// ========== DOSYA YERLEŞTİRME TALİMATLARI ==========

/*
📁 Bu dosyaların yerleştirilmesi gereken konumlar:

1. 📄 invoice_entity.dart
   → lib/features/invoices/data/models/invoice_entity.dart

2. 📄 invoice_item_entity.dart  
   → lib/features/invoices/data/models/invoice_item_entity.dart

3. 📄 invoice_dao.dart
   → lib/features/invoices/data/datasources/invoice_dao.dart

4. 📄 invoice_item_dao.dart
   → lib/features/invoices/data/datasources/invoice_item_dao.dart

5. 📄 invoice_status.dart
   → lib/features/invoices/data/models/invoice_status.dart

========== DATABASE GÜNCELLEME ==========

tamgaci_database.dart dosyanıza şunları ekleyin:

```dart
@Database(
  version: 2, // Version'u artırın
  entities: [
    CustomerEntity,
    InvoiceEntity,        // ✅ EKLE
    InvoiceItemEntity,    // ✅ EKLE
  ],
)
abstract class TamgaciDatabase extends FloorDatabase {
  CustomerDao get customerDao;
  InvoiceDao get invoiceDao;           // ✅ EKLE
  InvoiceItemDao get invoiceItemDao;   // ✅ EKLE
}
```

========== ÖNEMLİ NOTLAR ==========

✅ Floor uyumlu SQL sorguları
✅ Proper nullability handling  
✅ DateTime milisaniye formatında
✅ Foreign key relationships
✅ Cascade delete (items)
✅ Proper indexing
✅ Money kuruş cinsinden (precision)
✅ Enum proper handling
✅ Stream support for reactive UI

Bu entity'ler production-ready ve Floor ile uyumlu! 🚀
*/
