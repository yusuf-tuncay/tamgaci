import 'package:tamgaci/features/reports/domain/entities/report.dart';

/// Report Repository Interface
/// Bu interface, rapor ile ilgili tüm veri işlemlerini tanımlar.
abstract class ReportRepository {
  /// Tüm raporları getirir
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> getAllReports({
    int? limit,
    int? offset,
  });

  /// ID'ye göre rapor getirir
  /// [id]: Rapor ID'si
  /// Returns: Rapor veya null
  Future<Report?> getReportById(String id);

  /// Türüne göre raporları getirir
  /// [type]: Rapor türü
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> getReportsByType(
    ReportType type, {
    int? limit,
    int? offset,
  });

  /// Duruma göre raporları getirir
  /// [status]: Rapor durumu
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> getReportsByStatus(
    ReportStatus status, {
    int? limit,
    int? offset,
  });

  /// Formatına göre raporları getirir
  /// [format]: Rapor formatı
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> getReportsByFormat(
    ReportFormat format, {
    int? limit,
    int? offset,
  });

  /// Kullanıcıya göre raporları getirir
  /// [userId]: Kullanıcı ID'si
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> getReportsByUser(
    String userId, {
    int? limit,
    int? offset,
  });

  /// Tarih aralığına göre raporları getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> getReportsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  });

  /// Yeni rapor oluşturur
  /// [report]: Oluşturulacak rapor
  /// Returns: Oluşturulan rapor
  Future<Report> createReport(Report report);

  /// Rapor günceller
  /// [report]: Güncellenecek rapor
  /// Returns: Güncellenmiş rapor
  Future<Report> updateReport(Report report);

  /// Rapor siler
  /// [id]: Silinecek rapor ID'si
  Future<void> deleteReport(String id);

  /// Rapor durumunu günceller
  /// [id]: Rapor ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş rapor
  Future<Report> updateReportStatus(String id, ReportStatus status);

  /// Rapor arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> searchReports(
    String query, {
    int? limit,
    int? offset,
  });

  /// Rapor sayısını getirir
  /// Returns: Toplam rapor sayısı
  Future<int> getReportsCount();

  /// Türüne göre rapor sayısını getirir
  /// [type]: Rapor türü
  /// Returns: Rapor sayısı
  Future<int> getReportsCountByType(ReportType type);

  /// Duruma göre rapor sayısını getirir
  /// [status]: Rapor durumu
  /// Returns: Rapor sayısı
  Future<int> getReportsCountByStatus(ReportStatus status);

  /// Rapor oluşturur
  /// [type]: Rapor türü
  /// [format]: Rapor formatı
  /// [parameters]: Rapor parametreleri
  /// [filters]: Rapor filtreleri
  /// Returns: Oluşturulan rapor
  Future<Report> generateReport(
    ReportType type,
    ReportFormat format, {
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? filters,
  });

  /// Rapor verilerini getirir
  /// [id]: Rapor ID'si
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getReportData(String id);

  /// Rapor dosyasını indirir
  /// [id]: Rapor ID'si
  /// Returns: Dosya URL'si
  Future<String> downloadReport(String id);

  /// Rapor şablonlarını getirir
  /// [type]: Rapor türü (opsiyonel)
  /// Returns: Rapor şablonları
  Future<List<Map<String, dynamic>>> getReportTemplates({String? type});

  /// Rapor istatistiklerini getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> getReportStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Rapor numarası oluşturur
  /// [type]: Rapor türü
  /// Returns: Rapor numarası
  Future<String> generateReportNumber(ReportType type);

  /// Rapor kopyalar
  /// [id]: Kopyalanacak rapor ID'si
  /// Returns: Kopyalanan rapor
  Future<Report> duplicateReport(String id);

  /// Rapor arşivler
  /// [id]: Rapor ID'si
  /// Returns: Güncellenmiş rapor
  Future<Report> archiveReport(String id);

  /// Rapor aktifleştirir
  /// [id]: Rapor ID'si
  /// Returns: Güncellenmiş rapor
  Future<Report> activateReport(String id);

  /// Süresi dolmuş raporları temizler
  /// [days]: Kaç gün öncesine kadar
  /// Returns: Temizlenen rapor sayısı
  Future<int> cleanupExpiredReports(int days);

  /// Rapor önbelleğini temizler
  Future<void> clearReportCache();

  /// Rapor geçmişini getirir
  /// [id]: Rapor ID'si
  /// Returns: Rapor geçmişi
  Future<List<Map<String, dynamic>>> getReportHistory(String id);

  /// Rapor paylaşım linki oluşturur
  /// [id]: Rapor ID'si
  /// [expiresIn]: Kaç gün geçerli
  /// Returns: Paylaşım linki
  Future<String> createReportShareLink(String id, int expiresIn);

  /// Rapor paylaşım linkini iptal eder
  /// [id]: Rapor ID'si
  Future<void> revokeReportShareLink(String id);
}
