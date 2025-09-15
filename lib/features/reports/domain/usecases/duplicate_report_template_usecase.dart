import 'package:tamgaci/features/reports/domain/entities/report_template.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_template_repository.dart';

/// Rapor şablonu kopyalama use case'i
class DuplicateReportTemplateUseCase {
  final ReportTemplateRepository _repository;

  DuplicateReportTemplateUseCase(this._repository);

  /// Rapor şablonu kopyalar
  /// [id]: Kopyalanacak rapor şablonu ID'si
  /// Returns: Kopyalanan rapor şablonu
  Future<ReportTemplate> call(String id) async {
    return await _repository.duplicateReportTemplate(id);
  }
}
