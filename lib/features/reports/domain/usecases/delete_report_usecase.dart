import 'package:tamgaci/features/reports/domain/repositories/report_repository.dart';

/// Rapor silme use case'i
class DeleteReportUseCase {
  final ReportRepository _repository;

  DeleteReportUseCase(this._repository);

  /// Rapor siler
  /// [id]: Silinecek rapor ID'si
  Future<void> call(String id) async {
    await _repository.deleteReport(id);
  }
}
