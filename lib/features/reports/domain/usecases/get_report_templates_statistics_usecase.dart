import 'package:tamgaci/features/reports/domain/entities/report_template.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_template_repository.dart';

/// Rapor şablonları istatistikleri use case'i
class GetReportTemplatesStatisticsUseCase {
  final ReportTemplateRepository _repository;

  GetReportTemplatesStatisticsUseCase(this._repository);

  /// Rapor şablonları istatistiklerini getirir
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> call() async {
    return await _repository.getReportTemplateStatistics();
  }

  /// Rapor şablonu sayısını getirir
  /// Returns: Toplam rapor şablonu sayısı
  Future<int> getCount() async {
    return await _repository.getReportTemplatesCount();
  }

  /// Türüne göre rapor şablonu sayısını getirir
  /// [type]: Rapor şablonu türü
  /// Returns: Rapor şablonu sayısı
  Future<int> getCountByType(ReportTemplateType type) async {
    return await _repository.getReportTemplatesCountByType(type);
  }

  /// Rapor türüne göre rapor şablonu sayısını getirir
  /// [reportType]: Rapor türü
  /// Returns: Rapor şablonu sayısı
  Future<int> getCountByReportType(String reportType) async {
    return await _repository.getReportTemplatesCountByReportType(reportType);
  }
}
