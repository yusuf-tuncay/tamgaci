import 'package:tamgaci/features/reports/domain/repositories/report_template_repository.dart';

/// Rapor şablonu silme use case'i
class DeleteReportTemplateUseCase {
  final ReportTemplateRepository _repository;

  DeleteReportTemplateUseCase(this._repository);

  /// Rapor şablonu siler
  /// [id]: Silinecek rapor şablonu ID'si
  Future<void> call(String id) async {
    await _repository.deleteReportTemplate(id);
  }
}
