import 'package:tamgaci/features/sales/domain/entities/sale.dart';

/// Sales repository interface
/// Sales işlemleri için repository pattern
abstract class SaleRepository {
  /// Tüm satışları getirir
  /// [limit] - Maksimum kayıt sayısı
  /// [offset] - Atlanacak kayıt sayısı
  /// Returns: List<Sale>
  Future<List<Sale>> getAllSales({
    int? limit,
    int? offset,
  });

  /// ID'ye göre satış getirir
  /// [id] - Satış ID'si
  /// Returns: Sale veya null
  Future<Sale?> getSaleById(String id);

  /// Satış numarasına göre satış getirir
  /// [saleNumber] - Satış numarası
  /// Returns: Sale veya null
  Future<Sale?> getSaleByNumber(String saleNumber);

  /// Müşteriye göre satışları getirir
  /// [customerId] - Müşteri ID'si
  /// [limit] - Maksimum kayıt sayısı
  /// [offset] - Atlanacak kayıt sayısı
  /// Returns: List<Sale>
  Future<List<Sale>> getSalesByCustomer(
    String customerId, {
    int? limit,
    int? offset,
  });

  /// Tarih aralığına göre satışları getirir
  /// [startDate] - Başlangıç tarihi
  /// [endDate] - Bitiş tarihi
  /// [limit] - Maksimum kayıt sayısı
  /// [offset] - Atlanacak kayıt sayısı
  /// Returns: List<Sale>
  Future<List<Sale>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  });

  /// Satış durumuna göre satışları getirir
  /// [status] - Satış durumu
  /// [limit] - Maksimum kayıt sayısı
  /// [offset] - Atlanacak kayıt sayısı
  /// Returns: List<Sale>
  Future<List<Sale>> getSalesByStatus(
    SaleStatus status, {
    int? limit,
    int? offset,
  });

  /// Ödeme durumuna göre satışları getirir
  /// [paymentStatus] - Ödeme durumu
  /// [limit] - Maksimum kayıt sayısı
  /// [offset] - Atlanacak kayıt sayısı
  /// Returns: List<Sale>
  Future<List<Sale>> getSalesByPaymentStatus(
    PaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  });

  /// Vadesi geçmiş satışları getirir
  /// [limit] - Maksimum kayıt sayısı
  /// [offset] - Atlanacak kayıt sayısı
  /// Returns: List<Sale>
  Future<List<Sale>> getOverdueSales({
    int? limit,
    int? offset,
  });

  /// Yeni satış oluşturur
  /// [sale] - Oluşturulacak satış
  /// Returns: Oluşturulan satış
  Future<Sale> createSale(Sale sale);

  /// Satış günceller
  /// [sale] - Güncellenecek satış
  /// Returns: Güncellenen satış
  Future<Sale> updateSale(Sale sale);

  /// Satış siler
  /// [id] - Silinecek satış ID'si
  Future<void> deleteSale(String id);

  /// Satış durumunu günceller
  /// [id] - Satış ID'si
  /// [status] - Yeni durum
  /// Returns: Güncellenen satış
  Future<Sale> updateSaleStatus(String id, SaleStatus status);

  /// Ödeme durumunu günceller
  /// [id] - Satış ID'si
  /// [paymentStatus] - Yeni ödeme durumu
  /// Returns: Güncellenen satış
  Future<Sale> updatePaymentStatus(String id, PaymentStatus paymentStatus);

  /// Satış arama yapar
  /// [query] - Arama sorgusu
  /// [limit] - Maksimum kayıt sayısı
  /// [offset] - Atlanacak kayıt sayısı
  /// Returns: List<Sale>
  Future<List<Sale>> searchSales(
    String query, {
    int? limit,
    int? offset,
  });

  /// Satış sayısını getirir
  /// Returns: Toplam satış sayısı
  Future<int> getSalesCount();

  /// Müşteriye göre satış sayısını getirir
  /// [customerId] - Müşteri ID'si
  /// Returns: Müşteri satış sayısı
  Future<int> getSalesCountByCustomer(String customerId);

  /// Tarih aralığına göre satış sayısını getirir
  /// [startDate] - Başlangıç tarihi
  /// [endDate] - Bitiş tarihi
  /// Returns: Satış sayısı
  Future<int> getSalesCountByDateRange(DateTime startDate, DateTime endDate);

  /// Satış toplamını getirir
  /// [startDate] - Başlangıç tarihi (opsiyonel)
  /// [endDate] - Bitiş tarihi (opsiyonel)
  /// Returns: Toplam satış tutarı
  Future<double> getSalesTotal({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Müşteriye göre satış toplamını getirir
  /// [customerId] - Müşteri ID'si
  /// [startDate] - Başlangıç tarihi (opsiyonel)
  /// [endDate] - Bitiş tarihi (opsiyonel)
  /// Returns: Müşteri satış toplamı
  Future<double> getSalesTotalByCustomer(
    String customerId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Satış raporu oluşturur
  /// [startDate] - Başlangıç tarihi
  /// [endDate] - Bitiş tarihi
  /// [groupBy] - Gruplama türü (customer, product, date)
  /// Returns: Satış raporu verileri
  Future<Map<String, dynamic>> getSalesReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  });

  /// En çok satan ürünleri getirir
  /// [limit] - Maksimum kayıt sayısı
  /// [startDate] - Başlangıç tarihi (opsiyonel)
  /// [endDate] - Bitiş tarihi (opsiyonel)
  /// Returns: En çok satan ürünler listesi
  Future<List<Map<String, dynamic>>> getTopSellingProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// En çok satış yapılan müşterileri getirir
  /// [limit] - Maksimum kayıt sayısı
  /// [startDate] - Başlangıç tarihi (opsiyonel)
  /// [endDate] - Bitiş tarihi (opsiyonel)
  /// Returns: En çok satış yapılan müşteriler listesi
  Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Satış istatistiklerini getirir
  /// [startDate] - Başlangıç tarihi (opsiyonel)
  /// [endDate] - Bitiş tarihi (opsiyonel)
  /// Returns: Satış istatistikleri
  Future<Map<String, dynamic>> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Satış numarası oluşturur
  /// [type] - Satış türü
  /// Returns: Yeni satış numarası
  Future<String> generateSaleNumber(SaleType type);

  /// Satış kopyalar
  /// [id] - Kopyalanacak satış ID'si
  /// Returns: Kopyalanan satış
  Future<Sale> duplicateSale(String id);

  /// Satışı iptal eder
  /// [id] - İptal edilecek satış ID'si
  /// [reason] - İptal nedeni
  /// Returns: İptal edilen satış
  Future<Sale> cancelSale(String id, String reason);

  /// Satışı iade eder
  /// [id] - İade edilecek satış ID'si
  /// [reason] - İade nedeni
  /// Returns: İade edilen satış
  Future<Sale> returnSale(String id, String reason);

  /// Satışı onaylar
  /// [id] - Onaylanacak satış ID'si
  /// Returns: Onaylanan satış
  Future<Sale> approveSale(String id);

  /// Satışı kargoya verir
  /// [id] - Kargoya verilecek satış ID'si
  /// [trackingNumber] - Takip numarası
  /// Returns: Kargoya verilen satış
  Future<Sale> shipSale(String id, String trackingNumber);

  /// Satışı teslim eder
  /// [id] - Teslim edilecek satış ID'si
  /// Returns: Teslim edilen satış
  Future<Sale> deliverSale(String id);
}
