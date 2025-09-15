import 'package:tamgaci/features/reports/domain/entities/report.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_repository.dart';

/// Rapor güncelleme use case'i
class UpdateReportUseCase {
  final ReportRepository _repository;

  UpdateReportUseCase(this._repository);

  /// Rapor günceller
  /// [report]: Güncellenecek rapor
  /// Returns: Güncellenmiş rapor
  Future<Report> call(Report report) async {
    final updatedReport = report.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _repository.updateReport(updatedReport);
  }

  /// Rapor durumunu günceller
  /// [id]: Rapor ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş rapor
  Future<Report> updateStatus(String id, ReportStatus status) async {
    return await _repository.updateReportStatus(id, status);
  }

  /// Rapor arşivler
  /// [id]: Rapor ID'si
  /// Returns: Güncellenmiş rapor
  Future<Report> archive(String id) async {
    return await _repository.archiveReport(id);
  }

  /// Rapor aktifleştirir
  /// [id]: Rapor ID'si
  /// Returns: Güncellenmiş rapor
  Future<Report> activate(String id) async {
    return await _repository.activateReport(id);
  }
}
