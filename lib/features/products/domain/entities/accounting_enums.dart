// ========== ACCOUNTING ENUMS ==========
// lib/features/products/domain/entities/accounting_enums.dart

/// Maliyet hesaplama yöntemleri
enum CostingMethod {
  fifo('FIFO - İlk Giren İlk Çıkar'),
  lifo('LIFO - Son Giren İlk Çıkar'),
  weightedAverage('Ağırlıklı Ortalama'),
  specificIdentification('Özel Tanımlama');

  const CostingMethod(this.displayName);
  final String displayName;
}

/// Muhasebe durumu
enum AccountingStatus {
  draft('Taslak'),
  pending('Beklemede'),
  approved('Onaylandı'),
  rejected('Reddedildi'),
  archived('Arşivlendi');

  const AccountingStatus(this.displayName);
  final String displayName;
}

/// Stok hareket türü
enum StockMovementType {
  purchase('Alış'),
  sale('Satış'),
  adjustment('Düzeltme'),
  transfer('Transfer'),
  productReturn('İade'),
  loss('Fire'),
  found('Bulgular');

  const StockMovementType(this.displayName);
  final String displayName;
}

/// Stok hareket yönü
enum StockMovementDirection {
  stockIn('Giriş'),
  out('Çıkış');

  const StockMovementDirection(this.displayName);
  final String displayName;
}

/// Stok hareket durumu
enum StockMovementStatus {
  pending('Beklemede'),
  approved('Onaylandı'),
  rejected('Reddedildi'),
  cancelled('İptal Edildi');

  const StockMovementStatus(this.displayName);
  final String displayName;
}

/// Muhasebe dönemi
enum AccountingPeriod {
  daily('Günlük'),
  weekly('Haftalık'),
  monthly('Aylık'),
  quarterly('Çeyreklik'),
  yearly('Yıllık');

  const AccountingPeriod(this.displayName);
  final String displayName;
}

/// Vergi türü
enum TaxType {
  vat('KDV'),
  sct('ÖTV'),
  specialConsumption('Özel Tüketim'),
  stamp('Damga'),
  municipality('Belediye'),
  other('Diğer');

  const TaxType(this.displayName);
  final String displayName;
}

/// Para birimi türü
enum CurrencyType {
  local('Yerel'),
  foreign('Döviz'),
  crypto('Kripto');

  const CurrencyType(this.displayName);
  final String displayName;
}

/// Muhasebe hesap türü
enum AccountType {
  asset('Varlık'),
  liability('Yükümlülük'),
  equity('Özkaynak'),
  revenue('Gelir'),
  expense('Gider'),
  cost('Maliyet');

  const AccountType(this.displayName);
  final String displayName;
}

/// Stok takip seviyesi
enum StockTrackingLevel {
  none('Takip Yok'),
  basic('Temel'),
  detailed('Detaylı'),
  advanced('Gelişmiş');

  const StockTrackingLevel(this.displayName);
  final String displayName;
}

/// Ürün yaşam döngüsü
enum ProductLifecycle {
  development('Geliştirme'),
  introduction('Tanıtım'),
  growth('Büyüme'),
  maturity('Olgunluk'),
  decline('Düşüş'),
  discontinued('Üretimden Kaldırıldı');

  const ProductLifecycle(this.displayName);
  final String displayName;
}

/// Kalite seviyesi
enum QualityLevel {
  low('Düşük'),
  medium('Orta'),
  high('Yüksek'),
  premium('Premium');

  const QualityLevel(this.displayName);
  final String displayName;
}

/// Tedarikçi türü
enum SupplierType {
  manufacturer('Üretici'),
  distributor('Distribütör'),
  wholesaler('Toptancı'),
  retailer('Perakendeci'),
  service('Hizmet Sağlayıcı');

  const SupplierType(this.displayName);
  final String displayName;
}

/// Müşteri segmenti
enum CustomerSegment {
  individual('Bireysel'),
  corporate('Kurumsal'),
  government('Kamu'),
  nonprofit('Kar Amacı Gütmeyen');

  const CustomerSegment(this.displayName);
  final String displayName;
}

/// Satış kanalı
enum SalesChannel {
  direct('Doğrudan'),
  online('Online'),
  retail('Perakende'),
  wholesale('Toptan'),
  export('İhracat'),
  import('İthalat');

  const SalesChannel(this.displayName);
  final String displayName;
}

/// Ödeme yöntemi
enum PaymentMethod {
  cash('Nakit'),
  credit('Kredi'),
  check('Çek'),
  transfer('Havale'),
  card('Kart'),
  installment('Taksit'),
  other('Diğer');

  const PaymentMethod(this.displayName);
  final String displayName;
}

/// Fatura türü
enum InvoiceType {
  sales('Satış Faturası'),
  purchase('Alış Faturası'),
  credit('Kredi Notu'),
  debit('Borç Notu'),
  proforma('Proforma'),
  waybill('İrsaliye');

  const InvoiceType(this.displayName);
  final String displayName;
}

/// Muhasebe belge türü
enum AccountingDocumentType {
  invoice('Fatura'),
  receipt('Fiş'),
  voucher('Makbuz'),
  journal('Yevmiye'),
  ledger('Defter'),
  report('Rapor');

  const AccountingDocumentType(this.displayName);
  final String displayName;
}
