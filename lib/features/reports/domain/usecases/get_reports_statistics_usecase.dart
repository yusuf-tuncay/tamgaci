import 'package:tamgaci/features/reports/domain/entities/report.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_repository.dart';

/// Raporlar istatistikleri use case'i
class GetReportsStatisticsUseCase {
  final ReportRepository _repository;

  GetReportsStatisticsUseCase(this._repository);

  /// Raporlar istatistiklerini getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getReportStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Rapor sayısını getirir
  /// Returns: Toplam rapor sayısı
  Future<int> getCount() async {
    return await _repository.getReportsCount();
  }

  /// Türüne göre rapor sayısını getirir
  /// [type]: Rapor türü
  /// Returns: Rapor sayısı
  Future<int> getCountByType(ReportType type) async {
    return await _repository.getReportsCountByType(type);
  }

  /// Duruma göre rapor sayısını getirir
  /// [status]: Rapor durumu
  /// Returns: Rapor sayısı
  Future<int> getCountByStatus(ReportStatus status) async {
    return await _repository.getReportsCountByStatus(status);
  }

  /// Rapor şablonlarını getirir
  /// [type]: Rapor türü (opsiyonel)
  /// Returns: Rapor şablonları
  Future<List<Map<String, dynamic>>> getReportTemplates({String? type}) async {
    return await _repository.getReportTemplates(type: type);
  }
}
