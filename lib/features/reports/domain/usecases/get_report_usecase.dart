import 'package:tamgaci/features/reports/domain/entities/report.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_repository.dart';

/// Tek rapor getirme use case'i
class GetReportUseCase {
  final ReportRepository _repository;

  GetReportUseCase(this._repository);

  /// ID'ye göre rapor getirir
  /// [id]: Rapor ID'si
  /// Returns: Rapor veya null
  Future<Report?> call(String id) async {
    return await _repository.getReportById(id);
  }

  /// Rapor verilerini getirir
  /// [id]: Rapor ID'si
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getReportData(String id) async {
    return await _repository.getReportData(id);
  }

  /// Rapor dosyasını indirir
  /// [id]: Rapor ID'si
  /// Returns: Dosya URL'si
  Future<String> downloadReport(String id) async {
    return await _repository.downloadReport(id);
  }

  /// Rapor geçmişini getirir
  /// [id]: Rapor ID'si
  /// Returns: Rapor geçmişi
  Future<List<Map<String, dynamic>>> getReportHistory(String id) async {
    return await _repository.getReportHistory(id);
  }
}
