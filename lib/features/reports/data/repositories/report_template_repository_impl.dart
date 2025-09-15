import 'package:tamgaci/features/reports/domain/entities/report_template.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_template_repository.dart';
import 'package:tamgaci/features/reports/data/datasources/report_template_firebase_datasource.dart';
import 'package:tamgaci/features/reports/data/models/report_template_model.dart';

/// ReportTemplate repository implementasyonu
/// Firebase Firestore işlemleri için repository
class ReportTemplateRepositoryImpl implements ReportTemplateRepository {
  final ReportTemplateFirebaseDataSource _dataSource;

  ReportTemplateRepositoryImpl({
    required ReportTemplateFirebaseDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<ReportTemplate>> getAllReportTemplates({
    int? limit,
    int? offset,
  }) async {
    final reportTemplateModels = await _dataSource.getAllReportTemplates(
      limit: limit,
      offset: offset,
    );
    return reportTemplateModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ReportTemplate?> getReportTemplateById(String id) async {
    final reportTemplateModel = await _dataSource.getReportTemplateById(id);
    return reportTemplateModel?.toEntity();
  }

  @override
  Future<List<ReportTemplate>> getReportTemplatesByType(
    ReportTemplateType type, {
    int? limit,
    int? offset,
  }) async {
    final reportTemplateModels = await _dataSource.getReportTemplatesByType(
      type,
      limit: limit,
      offset: offset,
    );
    return reportTemplateModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ReportTemplate>> getReportTemplatesByReportType(
    String reportType, {
    int? limit,
    int? offset,
  }) async {
    final reportTemplateModels =
        await _dataSource.getReportTemplatesByReportType(
      reportType,
      limit: limit,
      offset: offset,
    );
    return reportTemplateModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ReportTemplate>> getActiveReportTemplates({
    int? limit,
    int? offset,
  }) async {
    final reportTemplateModels = await _dataSource.getActiveReportTemplates(
      limit: limit,
      offset: offset,
    );
    return reportTemplateModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ReportTemplate>> getDefaultReportTemplates({
    int? limit,
    int? offset,
  }) async {
    final reportTemplateModels = await _dataSource.getDefaultReportTemplates(
      limit: limit,
      offset: offset,
    );
    return reportTemplateModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ReportTemplate>> getReportTemplatesByUser(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    final reportTemplateModels = await _dataSource.getReportTemplatesByUser(
      userId,
      limit: limit,
      offset: offset,
    );
    return reportTemplateModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ReportTemplate> createReportTemplate(
      ReportTemplate reportTemplate) async {
    final reportTemplateModel = ReportTemplateModel.fromEntity(reportTemplate);
    final createdReportTemplateModel =
        await _dataSource.createReportTemplate(reportTemplateModel);
    return createdReportTemplateModel.toEntity();
  }

  @override
  Future<ReportTemplate> updateReportTemplate(
      ReportTemplate reportTemplate) async {
    final reportTemplateModel = ReportTemplateModel.fromEntity(reportTemplate);
    final updatedReportTemplateModel =
        await _dataSource.updateReportTemplate(reportTemplateModel);
    return updatedReportTemplateModel.toEntity();
  }

  @override
  Future<void> deleteReportTemplate(String id) async {
    await _dataSource.deleteReportTemplate(id);
  }

  @override
  Future<ReportTemplate> updateReportTemplateStatus(
      String id, bool isActive) async {
    final reportTemplate = await getReportTemplateById(id);
    if (reportTemplate == null) {
      throw Exception('Rapor şablonu bulunamadı');
    }

    final updatedReportTemplate = reportTemplate.copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );

    return await updateReportTemplate(updatedReportTemplate);
  }

  @override
  Future<List<ReportTemplate>> searchReportTemplates(
    String query, {
    int? limit,
    int? offset,
  }) async {
    final reportTemplateModels = await _dataSource.searchReportTemplates(
      query,
      limit: limit,
      offset: offset,
    );
    return reportTemplateModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> getReportTemplatesCount() async {
    return await _dataSource.getReportTemplatesCount();
  }

  @override
  Future<int> getReportTemplatesCountByType(ReportTemplateType type) async {
    final reportTemplates = await getReportTemplatesByType(type);
    return reportTemplates.length;
  }

  @override
  Future<int> getReportTemplatesCountByReportType(String reportType) async {
    final reportTemplates = await getReportTemplatesByReportType(reportType);
    return reportTemplates.length;
  }

  @override
  Future<ReportTemplate> duplicateReportTemplate(String id) async {
    final originalReportTemplate = await getReportTemplateById(id);
    if (originalReportTemplate == null) {
      throw Exception('Rapor şablonu bulunamadı');
    }

    final newTemplateNumber =
        await generateReportTemplateNumber(originalReportTemplate.type);

    final duplicatedReportTemplate = originalReportTemplate.copyWith(
      id: '', // Yeni ID oluşturulacak
      name: newTemplateNumber,
      isDefault: false, // Kopyalanan şablon varsayılan olmaz
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createReportTemplate(duplicatedReportTemplate);
  }

  @override
  Future<ReportTemplate> archiveReportTemplate(String id) async {
    return await updateReportTemplateStatus(id, false);
  }

  @override
  Future<ReportTemplate> activateReportTemplate(String id) async {
    return await updateReportTemplateStatus(id, true);
  }

  @override
  Future<ReportTemplate> updateReportTemplateSortOrder(
      String id, int sortOrder) async {
    final reportTemplate = await getReportTemplateById(id);
    if (reportTemplate == null) {
      throw Exception('Rapor şablonu bulunamadı');
    }

    final updatedReportTemplate = reportTemplate.copyWith(
      sortOrder: sortOrder,
      updatedAt: DateTime.now(),
    );

    return await updateReportTemplate(updatedReportTemplate);
  }

  @override
  Future<ReportTemplate> setDefaultReportTemplate(String id) async {
    final reportTemplate = await getReportTemplateById(id);
    if (reportTemplate == null) {
      throw Exception('Rapor şablonu bulunamadı');
    }

    // Aynı rapor türündeki diğer şablonları varsayılan olmaktan çıkar
    final sameTypeTemplates =
        await getReportTemplatesByReportType(reportTemplate.reportType);
    for (final template in sameTypeTemplates) {
      if (template.isDefault && template.id != id) {
        final updatedTemplate = template.copyWith(
          isDefault: false,
          updatedAt: DateTime.now(),
        );
        await updateReportTemplate(updatedTemplate);
      }
    }

    // Seçilen şablonu varsayılan yap
    final updatedReportTemplate = reportTemplate.copyWith(
      isDefault: true,
      updatedAt: DateTime.now(),
    );

    return await updateReportTemplate(updatedReportTemplate);
  }

  @override
  Future<Map<String, dynamic>> getReportTemplateStatistics() async {
    return await _dataSource.getReportTemplateStatistics();
  }

  @override
  Future<String> generateReportTemplateNumber(ReportTemplateType type) async {
    return await _dataSource.generateReportTemplateNumber(type);
  }

  @override
  Future<List<String>> getReportTemplateCategories() async {
    return await _dataSource.getReportTemplateCategories();
  }

  @override
  Future<List<String>> getReportTemplateTags() async {
    return await _dataSource.getReportTemplateTags();
  }

  @override
  Future<List<ReportTemplate>> getReportTemplateSuggestions(
    String reportType, {
    int limit = 5,
  }) async {
    final reportTemplateModels = await _dataSource.getReportTemplateSuggestions(
      reportType,
      limit: limit,
    );
    return reportTemplateModels.map((model) => model.toEntity()).toList();
  }
}
