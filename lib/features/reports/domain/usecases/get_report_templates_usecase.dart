import 'package:tamgaci/features/reports/domain/entities/report_template.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_template_repository.dart';

/// Rapor şablonlarını getirme use case'i
class GetReportTemplatesUseCase {
  final ReportTemplateRepository _repository;

  GetReportTemplatesUseCase(this._repository);

  /// Tüm rapor şablonlarını getirir
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> call({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getAllReportTemplates(
      limit: limit,
      offset: offset,
    );
  }

  /// Türüne göre rapor şablonlarını getirir
  /// [type]: Rapor şablonu türü
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> getByType(
    ReportTemplateType type, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getReportTemplatesByType(
      type,
      limit: limit,
      offset: offset,
    );
  }

  /// Rapor türüne göre şablonları getirir
  /// [reportType]: Rapor türü
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> getByReportType(
    String reportType, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getReportTemplatesByReportType(
      reportType,
      limit: limit,
      offset: offset,
    );
  }

  /// Aktif rapor şablonlarını getirir
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> getActive({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getActiveReportTemplates(
      limit: limit,
      offset: offset,
    );
  }

  /// Varsayılan rapor şablonlarını getirir
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> getDefault({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getDefaultReportTemplates(
      limit: limit,
      offset: offset,
    );
  }

  /// Kullanıcıya göre rapor şablonlarını getirir
  /// [userId]: Kullanıcı ID'si
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> getByUser(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getReportTemplatesByUser(
      userId,
      limit: limit,
      offset: offset,
    );
  }

  /// Rapor şablonu arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum şablon sayısı
  /// [offset]: Atlanacak şablon sayısı
  /// Returns: Rapor şablonu listesi
  Future<List<ReportTemplate>> search(
    String query, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.searchReportTemplates(
      query,
      limit: limit,
      offset: offset,
    );
  }

  /// Rapor şablonu önerilerini getirir
  /// [reportType]: Rapor türü
  /// [limit]: Maksimum öneri sayısı
  /// Returns: Öneri listesi
  Future<List<ReportTemplate>> getSuggestions(
    String reportType, {
    int limit = 5,
  }) async {
    return await _repository.getReportTemplateSuggestions(
      reportType,
      limit: limit,
    );
  }
}
