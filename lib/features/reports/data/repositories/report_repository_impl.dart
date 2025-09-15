import 'package:tamgaci/features/reports/domain/entities/report.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_repository.dart';
import 'package:tamgaci/features/reports/data/datasources/report_firebase_datasource.dart';
import 'package:tamgaci/features/reports/data/models/report_model.dart';

/// Report repository implementasyonu
/// Firebase Firestore işlemleri için repository
class ReportRepositoryImpl implements ReportRepository {
  final ReportFirebaseDataSource _dataSource;

  ReportRepositoryImpl({
    required ReportFirebaseDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<Report>> getAllReports({
    int? limit,
    int? offset,
  }) async {
    final reportModels = await _dataSource.getAllReports(
      limit: limit,
      offset: offset,
    );
    return reportModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Report?> getReportById(String id) async {
    final reportModel = await _dataSource.getReportById(id);
    return reportModel?.toEntity();
  }

  @override
  Future<List<Report>> getReportsByType(
    ReportType type, {
    int? limit,
    int? offset,
  }) async {
    final reportModels = await _dataSource.getReportsByType(
      type,
      limit: limit,
      offset: offset,
    );
    return reportModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Report>> getReportsByStatus(
    ReportStatus status, {
    int? limit,
    int? offset,
  }) async {
    final reportModels = await _dataSource.getReportsByStatus(
      status,
      limit: limit,
      offset: offset,
    );
    return reportModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Report>> getReportsByFormat(
    ReportFormat format, {
    int? limit,
    int? offset,
  }) async {
    final reportModels = await _dataSource.getReportsByFormat(
      format,
      limit: limit,
      offset: offset,
    );
    return reportModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Report>> getReportsByUser(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    final reportModels = await _dataSource.getReportsByUser(
      userId,
      limit: limit,
      offset: offset,
    );
    return reportModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Report>> getReportsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    final reportModels = await _dataSource.getReportsByDateRange(
      startDate,
      endDate,
      limit: limit,
      offset: offset,
    );
    return reportModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Report> createReport(Report report) async {
    final reportModel = ReportModel.fromEntity(report);
    final createdReportModel = await _dataSource.createReport(reportModel);
    return createdReportModel.toEntity();
  }

  @override
  Future<Report> updateReport(Report report) async {
    final reportModel = ReportModel.fromEntity(report);
    final updatedReportModel = await _dataSource.updateReport(reportModel);
    return updatedReportModel.toEntity();
  }

  @override
  Future<void> deleteReport(String id) async {
    await _dataSource.deleteReport(id);
  }

  @override
  Future<Report> updateReportStatus(String id, ReportStatus status) async {
    final report = await getReportById(id);
    if (report == null) {
      throw Exception('Rapor bulunamadı');
    }

    final updatedReport = report.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    return await updateReport(updatedReport);
  }

  @override
  Future<List<Report>> searchReports(
    String query, {
    int? limit,
    int? offset,
  }) async {
    final reportModels = await _dataSource.searchReports(
      query,
      limit: limit,
      offset: offset,
    );
    return reportModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> getReportsCount() async {
    return await _dataSource.getReportsCount();
  }

  @override
  Future<int> getReportsCountByType(ReportType type) async {
    final reports = await getReportsByType(type);
    return reports.length;
  }

  @override
  Future<int> getReportsCountByStatus(ReportStatus status) async {
    final reports = await getReportsByStatus(status);
    return reports.length;
  }

  @override
  Future<Report> generateReport(
    ReportType type,
    ReportFormat format, {
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? filters,
  }) async {
    final reportModel = await _dataSource.generateReport(
      type,
      format,
      parameters: parameters,
      filters: filters,
    );
    return reportModel.toEntity();
  }

  @override
  Future<Map<String, dynamic>> getReportData(String id) async {
    return await _dataSource.getReportData(id);
  }

  @override
  Future<String> downloadReport(String id) async {
    return await _dataSource.downloadReport(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getReportTemplates({String? type}) async {
    return await _dataSource.getReportTemplates(type: type);
  }

  @override
  Future<Map<String, dynamic>> getReportStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getReportStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<String> generateReportNumber(ReportType type) async {
    return await _dataSource.generateReportNumber(type);
  }

  @override
  Future<Report> duplicateReport(String id) async {
    final originalReport = await getReportById(id);
    if (originalReport == null) {
      throw Exception('Rapor bulunamadı');
    }

    final newReportNumber = await generateReportNumber(originalReport.type);

    final duplicatedReport = originalReport.copyWith(
      id: '', // Yeni ID oluşturulacak
      name: newReportNumber,
      status: ReportStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createReport(duplicatedReport);
  }

  @override
  Future<Report> archiveReport(String id) async {
    return await updateReportStatus(id, ReportStatus.expired);
  }

  @override
  Future<Report> activateReport(String id) async {
    return await updateReportStatus(id, ReportStatus.completed);
  }

  @override
  Future<int> cleanupExpiredReports(int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final expiredReports = await getReportsByDateRange(
      DateTime(2020, 1, 1), // Başlangıç tarihi
      cutoffDate,
    );

    int cleanedCount = 0;
    for (final report in expiredReports) {
      if (report.status == ReportStatus.expired) {
        await deleteReport(report.id);
        cleanedCount++;
      }
    }

    return cleanedCount;
  }

  @override
  Future<void> clearReportCache() async {
    // Firebase Firestore'da cache temizleme işlemi
    // Bu implementasyon Firebase'in kendi cache yönetimini kullanır
  }

  @override
  Future<List<Map<String, dynamic>>> getReportHistory(String id) async {
    // Rapor geçmişi implementasyonu
    // Bu özellik için ayrı bir collection kullanılabilir
    return [];
  }

  @override
  Future<String> createReportShareLink(String id, int expiresIn) async {
    final report = await getReportById(id);
    if (report == null) {
      throw Exception('Rapor bulunamadı');
    }

    final expiresAt = DateTime.now().add(Duration(days: expiresIn));
    final updatedReport = report.copyWith(
      expiresAt: expiresAt,
      updatedAt: DateTime.now(),
    );

    await updateReport(updatedReport);

    // Gerçek uygulamada burada paylaşım linki oluşturulur
    return 'https://app.tamgaci.com/reports/share/$id';
  }

  @override
  Future<void> revokeReportShareLink(String id) async {
    final report = await getReportById(id);
    if (report == null) {
      throw Exception('Rapor bulunamadı');
    }

    final updatedReport = report.copyWith(
      expiresAt: null,
      updatedAt: DateTime.now(),
    );

    await updateReport(updatedReport);
  }
}
