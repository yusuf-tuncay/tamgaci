import 'package:tamgaci/features/reports/domain/entities/report.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_repository.dart';

/// Rapor kopyalama use case'i
class DuplicateReportUseCase {
  final ReportRepository _repository;

  DuplicateReportUseCase(this._repository);

  /// Rapor kopyalar
  /// [id]: Kopyalanacak rapor ID'si
  /// Returns: Kopyalanan rapor
  Future<Report> call(String id) async {
    return await _repository.duplicateReport(id);
  }
}
