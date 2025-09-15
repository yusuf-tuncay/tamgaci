import 'package:tamgaci/features/reports/domain/entities/report_template.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_template_repository.dart';

/// Rapor şablonu oluşturma use case'i
class CreateReportTemplateUseCase {
  final ReportTemplateRepository _repository;

  CreateReportTemplateUseCase(this._repository);

  /// Yeni rapor şablonu oluşturur
  /// [reportTemplate]: Oluşturulacak rapor şablonu
  /// Returns: Oluşturulan rapor şablonu
  Future<ReportTemplate> call(ReportTemplate reportTemplate) async {
    // Rapor şablonu numarası otomatik oluşturulacak
    final templateNumber =
        await _repository.generateReportTemplateNumber(reportTemplate.type);

    final newReportTemplate = reportTemplate.copyWith(
      name: reportTemplate.name.isEmpty ? templateNumber : reportTemplate.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createReportTemplate(newReportTemplate);
  }
}
