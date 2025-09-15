import 'package:tamgaci/features/reports/domain/entities/report_template.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_template_repository.dart';

/// Tek rapor şablonu getirme use case'i
class GetReportTemplateUseCase {
  final ReportTemplateRepository _repository;

  GetReportTemplateUseCase(this._repository);

  /// ID'ye göre rapor şablonu getirir
  /// [id]: Rapor şablonu ID'si
  /// Returns: Rapor şablonu veya null
  Future<ReportTemplate?> call(String id) async {
    return await _repository.getReportTemplateById(id);
  }

  /// Rapor şablonu kategorilerini getirir
  /// Returns: Kategori listesi
  Future<List<String>> getCategories() async {
    return await _repository.getReportTemplateCategories();
  }

  /// Rapor şablonu etiketlerini getirir
  /// Returns: Etiket listesi
  Future<List<String>> getTags() async {
    return await _repository.getReportTemplateTags();
  }
}
