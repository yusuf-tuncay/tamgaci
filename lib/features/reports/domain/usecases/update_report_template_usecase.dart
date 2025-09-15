import 'package:tamgaci/features/reports/domain/entities/report_template.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_template_repository.dart';

/// Rapor şablonu güncelleme use case'i
class UpdateReportTemplateUseCase {
  final ReportTemplateRepository _repository;

  UpdateReportTemplateUseCase(this._repository);

  /// Rapor şablonu günceller
  /// [reportTemplate]: Güncellenecek rapor şablonu
  /// Returns: Güncellenmiş rapor şablonu
  Future<ReportTemplate> call(ReportTemplate reportTemplate) async {
    final updatedReportTemplate = reportTemplate.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _repository.updateReportTemplate(updatedReportTemplate);
  }

  /// Rapor şablonu durumunu günceller
  /// [id]: Rapor şablonu ID'si
  /// [isActive]: Aktif durumu
  /// Returns: Güncellenmiş rapor şablonu
  Future<ReportTemplate> updateStatus(String id, bool isActive) async {
    return await _repository.updateReportTemplateStatus(id, isActive);
  }

  /// Rapor şablonu sıralamasını günceller
  /// [id]: Rapor şablonu ID'si
  /// [sortOrder]: Yeni sıralama
  /// Returns: Güncellenmiş rapor şablonu
  Future<ReportTemplate> updateSortOrder(String id, int sortOrder) async {
    return await _repository.updateReportTemplateSortOrder(id, sortOrder);
  }

  /// Rapor şablonu varsayılan yapar
  /// [id]: Rapor şablonu ID'si
  /// Returns: Güncellenmiş rapor şablonu
  Future<ReportTemplate> setDefault(String id) async {
    return await _repository.setDefaultReportTemplate(id);
  }

  /// Rapor şablonu arşivler
  /// [id]: Rapor şablonu ID'si
  /// Returns: Güncellenmiş rapor şablonu
  Future<ReportTemplate> archive(String id) async {
    return await _repository.archiveReportTemplate(id);
  }

  /// Rapor şablonu aktifleştirir
  /// [id]: Rapor şablonu ID'si
  /// Returns: Güncellenmiş rapor şablonu
  Future<ReportTemplate> activate(String id) async {
    return await _repository.activateReportTemplate(id);
  }
}
