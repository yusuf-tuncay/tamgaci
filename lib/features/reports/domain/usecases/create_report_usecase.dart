import 'package:tamgaci/features/reports/domain/entities/report.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_repository.dart';

/// Rapor oluşturma use case'i
class CreateReportUseCase {
  final ReportRepository _repository;

  CreateReportUseCase(this._repository);

  /// Yeni rapor oluşturur
  /// [report]: Oluşturulacak rapor
  /// Returns: Oluşturulan rapor
  Future<Report> call(Report report) async {
    // Rapor numarası otomatik oluşturulacak
    final reportNumber = await _repository.generateReportNumber(report.type);

    final newReport = report.copyWith(
      name: report.name.isEmpty ? reportNumber : report.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createReport(newReport);
  }

  /// Rapor oluşturur
  /// [type]: Rapor türü
  /// [format]: Rapor formatı
  /// [name]: Rapor adı
  /// [description]: Rapor açıklaması
  /// [parameters]: Rapor parametreleri
  /// [filters]: Rapor filtreleri
  /// Returns: Oluşturulan rapor
  Future<Report> generateReport(
    ReportType type,
    ReportFormat format, {
    String? name,
    String? description,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? filters,
  }) async {
    return await _repository.generateReport(
      type,
      format,
      parameters: parameters,
      filters: filters,
    );
  }
}
