import 'package:tamgaci/features/reports/domain/entities/report_template.dart';

/// Report Template Repository Interface
/// Bu interface, rapor şablonu ile ilgili tüm veri işlemlerini tanımlar.
abstract class ReportTemplateRepository {
  /// Tüm rapor şablonlarını getirir
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> getAllReportTemplates({
    int? limit,
    int? offset,
  });

  /// ID'ye göre rapor şablonu getirir
  /// [id]: Rapor şablonu ID'si
  /// Returns: Rapor şablonu veya null
  Future<ReportTemplate?> getReportTemplateById(String id);

  /// Türüne göre rapor şablonlarını getirir
  /// [type]: Rapor şablonu türü
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> getReportTemplatesByType(
    ReportTemplateType type, {
    int? limit,
    int? offset,
  });

  /// Rapor türüne göre şablonları getirir
  /// [reportType]: Rapor türü
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> getReportTemplatesByReportType(
    String reportType, {
    int? limit,
    int? offset,
  });

  /// Aktif rapor şablonlarını getirir
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> getActiveReportTemplates({
    int? limit,
    int? offset,
  });

  /// Varsayılan rapor şablonlarını getirir
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> getDefaultReportTemplates({
    int? limit,
    int? offset,
  });

  /// Kullanıcıya göre rapor şablonlarını getirir
  /// [userId]: Kullanıcı ID'si
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> getReportTemplatesByUser(
    String userId, {
    int? limit,
    int? offset,
  });

  /// Yeni rapor şablonu oluşturur
  /// [reportTemplate]: Oluşturulacak rapor şablonu
  /// Returns: Oluşturulan rapor şablonu
  Future<ReportTemplate> createReportTemplate(ReportTemplate reportTemplate);

  /// Rapor şablonu günceller
  /// [reportTemplate]: Güncellenecek rapor şablonu
  /// Returns: Güncellenmiş rapor şablonu
  Future<ReportTemplate> updateReportTemplate(ReportTemplate reportTemplate);

  /// Rapor şablonu siler
  /// [id]: Silinecek rapor şablonu ID'si
  Future<void> deleteReportTemplate(String id);

  /// Rapor şablonu durumunu günceller
  /// [id]: Rapor şablonu ID'si
  /// [isActive]: Aktif durumu
  /// Returns: Güncellenmiş rapor şablonu
  Future<ReportTemplate> updateReportTemplateStatus(String id, bool isActive);

  /// Rapor şablonu arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> searchReportTemplates(
    String query, {
    int? limit,
    int? offset,
  });

  /// Rapor şablonu sayısını getirir
  /// Returns: Toplam rapor şablonu sayısı
  Future<int> getReportTemplatesCount();

  /// Türüne göre rapor şablonu sayısını getirir
  /// [type]: Rapor şablonu türü
  /// Returns: Rapor şablonu sayısı
  Future<int> getReportTemplatesCountByType(ReportTemplateType type);

  /// Rapor türüne göre rapor şablonu sayısını getirir
  /// [reportType]: Rapor türü
  /// Returns: Rapor şablonu sayısı
  Future<int> getReportTemplatesCountByReportType(String reportType);

  /// Rapor şablonu kopyalar
  /// [id]: Kopyalanacak rapor şablonu ID'si
  /// Returns: Kopyalanan rapor şablonu
  Future<ReportTemplate> duplicateReportTemplate(String id);

  /// Rapor şablonu arşivler
  /// [id]: Rapor şablonu ID'si
  /// Returns: Güncellenmiş rapor şablonu
  Future<ReportTemplate> archiveReportTemplate(String id);

  /// Rapor şablonu aktifleştirir
  /// [id]: Rapor şablonu ID'si
  /// Returns: Güncellenmiş rapor şablonu
  Future<ReportTemplate> activateReportTemplate(String id);

  /// Rapor şablonu sıralamasını günceller
  /// [id]: Rapor şablonu ID'si
  /// [sortOrder]: Yeni sıralama
  /// Returns: Güncellenmiş rapor şablonu
  Future<ReportTemplate> updateReportTemplateSortOrder(
      String id, int sortOrder);

  /// Rapor şablonu varsayılan yapar
  /// [id]: Rapor şablonu ID'si
  /// Returns: Güncellenmiş rapor şablonu
  Future<ReportTemplate> setDefaultReportTemplate(String id);

  /// Rapor şablonu istatistiklerini getirir
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> getReportTemplateStatistics();

  /// Rapor şablonu numarası oluşturur
  /// [type]: Rapor şablonu türü
  /// Returns: Rapor şablonu numarası
  Future<String> generateReportTemplateNumber(ReportTemplateType type);

  /// Rapor şablonu kategorilerini getirir
  /// Returns: Kategori listesi
  Future<List<String>> getReportTemplateCategories();

  /// Rapor şablonu etiketlerini getirir
  /// Returns: Etiket listesi
  Future<List<String>> getReportTemplateTags();

  /// Rapor şablonu önerilerini getirir
  /// [reportType]: Rapor türü
  /// [limit]: Maksimum öneri sayısı
  /// Returns: Öneri listesi
  Future<List<ReportTemplate>> getReportTemplateSuggestions(
    String reportType, {
    int limit = 5,
  });
}
