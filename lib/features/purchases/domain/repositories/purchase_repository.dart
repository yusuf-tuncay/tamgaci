import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';

/// Purchase Repository Interface
/// Bu interface, satın alma ile ilgili tüm veri işlemlerini tanımlar.
abstract class PurchaseRepository {
  /// Tüm satın almaları getirir
  /// [includeItems]: Ürün detaylarını dahil et
  /// Returns: Satın alma listesi
  Future<List<Purchase>> getAllPurchases({
    bool includeItems = true,
  });

  /// ID'ye göre satın alma getirir
  /// [id]: Satın alma ID'si
  /// Returns: Satın alma veya null
  Future<Purchase?> getPurchaseById(String id);

  /// Satın alma numarasına göre satın alma getirir
  /// [purchaseNumber]: Satın alma numarası
  /// Returns: Satın alma veya null
  Future<Purchase?> getPurchaseByNumber(String purchaseNumber);

  /// Tedarikçiye göre satın almaları getirir
  /// [supplierId]: Tedarikçi ID'si
  /// [limit]: Maksimum satın alma sayısı
  /// [offset]: Atlanacak satın alma sayısı
  /// Returns: Satın alma listesi
  Future<List<Purchase>> getPurchasesBySupplier(
    String supplierId, {
    int? limit,
    int? offset,
  });

  /// Tarih aralığına göre satın almaları getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [limit]: Maksimum satın alma sayısı
  /// [offset]: Atlanacak satın alma sayısı
  /// Returns: Satın alma listesi
  Future<List<Purchase>> getPurchasesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  });

  /// Duruma göre satın almaları getirir
  /// [status]: Satın alma durumu
  /// [limit]: Maksimum satın alma sayısı
  /// [offset]: Atlanacak satın alma sayısı
  /// Returns: Satın alma listesi
  Future<List<Purchase>> getPurchasesByStatus(
    PurchaseStatus status, {
    int? limit,
    int? offset,
  });

  /// Ödeme durumuna göre satın almaları getirir
  /// [paymentStatus]: Ödeme durumu
  /// [limit]: Maksimum satın alma sayısı
  /// [offset]: Atlanacak satın alma sayısı
  /// Returns: Satın alma listesi
  Future<List<Purchase>> getPurchasesByPaymentStatus(
    PurchasePaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  });

  /// Vadesi geçmiş satın almaları getirir
  /// [limit]: Maksimum satın alma sayısı
  /// [offset]: Atlanacak satın alma sayısı
  /// Returns: Satın alma listesi
  Future<List<Purchase>> getOverduePurchases({
    int? limit,
    int? offset,
  });

  /// Yeni satın alma oluşturur
  /// [purchase]: Oluşturulacak satın alma
  /// Returns: Oluşturulan satın alma ID'si
  Future<String> createPurchase(Purchase purchase);

  /// Satın alma günceller
  /// [purchase]: Güncellenecek satın alma
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> updatePurchase(Purchase purchase);

  /// Satın alma siler
  /// [id]: Silinecek satın alma ID'si
  Future<void> deletePurchase(String id);

  /// Satın alma durumunu günceller
  /// [id]: Satın alma ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> updatePurchaseStatus(String id, PurchaseStatus status);

  /// Ödeme durumunu günceller
  /// [id]: Satın alma ID'si
  /// [paymentStatus]: Yeni ödeme durumu
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> updatePaymentStatus(
      String id, PurchasePaymentStatus paymentStatus);

  /// Satın alma arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum satın alma sayısı
  /// [offset]: Atlanacak satın alma sayısı
  /// Returns: Satın alma listesi
  Future<List<Purchase>> searchPurchases(
    String query, {
    int? limit,
    int? offset,
  });

  /// Satın alma sayısını getirir
  /// Returns: Toplam satın alma sayısı
  Future<int> getPurchasesCount();

  /// Tedarikçiye göre satın alma sayısını getirir
  /// [supplierId]: Tedarikçi ID'si
  /// Returns: Satın alma sayısı
  Future<int> getPurchasesCountBySupplier(String supplierId);

  /// Tarih aralığına göre satın alma sayısını getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// Returns: Satın alma sayısı
  Future<int> getPurchasesCountByDateRange(
      DateTime startDate, DateTime endDate);

  /// Satın alma toplamını getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getPurchasesTotal({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Tedarikçiye göre satın alma toplamını getirir
  /// [supplierId]: Tedarikçi ID'si
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getPurchasesTotalBySupplier(
    String supplierId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Satın alma raporu oluşturur
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [groupBy]: Gruplama türü (supplier, product, date)
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getPurchasesReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  });

  /// En çok satın alınan ürünleri getirir
  /// [limit]: Maksimum ürün sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Ürün listesi
  Future<List<Map<String, dynamic>>> getTopPurchasedProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// En çok satın alma yapılan tedarikçileri getirir
  /// [limit]: Maksimum tedarikçi sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Tedarikçi listesi
  Future<List<Map<String, dynamic>>> getTopSuppliers({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Satın alma istatistiklerini getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> getPurchasesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Satın alma numarası oluşturur
  /// Returns: Satın alma numarası
  Future<String> generatePurchaseNumber();

  /// Satın alma kopyalar
  /// [id]: Kopyalanacak satın alma ID'si
  /// Returns: Kopyalanan satın alma
  Future<Purchase> duplicatePurchase(String id);

  /// Satın alma iptal eder
  /// [id]: Satın alma ID'si
  /// [reason]: İptal nedeni
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> cancelPurchase(String id, String reason);

  /// Satın alma iade eder
  /// [id]: Satın alma ID'si
  /// [reason]: İade nedeni
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> returnPurchase(String id, String reason);

  /// Satın alma onaylar
  /// [id]: Satın alma ID'si
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> approvePurchase(String id);

  /// Satın alma teslim alır
  /// [id]: Satın alma ID'si
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> receivePurchase(String id);

  /// Tedarikçiye göre satın almaları getirir (ID ile)
  /// [supplierId]: Tedarikçi ID'si
  /// Returns: Satın alma listesi
  Future<List<Purchase>> getPurchasesBySupplierId(String supplierId);

  /// Tüm satın almaları izler
  /// Returns: Satın alma stream'i
  Stream<List<Purchase>> watchAllPurchases();

  /// ID'ye göre satın alma izler
  /// [id]: Satın alma ID'si
  /// Returns: Satın alma stream'i
  Stream<Purchase?> watchPurchaseById(String id);

  /// Tedarikçiye göre satın almaları izler
  /// [supplierId]: Tedarikçi ID'si
  /// Returns: Satın alma stream'i
  Stream<List<Purchase>> watchPurchasesBySupplierId(String supplierId);
}
