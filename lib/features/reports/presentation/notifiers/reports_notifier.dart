import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/reports/domain/entities/report.dart';
import 'package:tamgaci/features/reports/domain/entities/report_template.dart';
import 'package:tamgaci/features/reports/domain/usecases/create_report_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/get_report_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/update_report_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/delete_report_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/get_reports_statistics_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/duplicate_report_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/create_report_template_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/get_report_templates_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/get_report_template_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/update_report_template_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/delete_report_template_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/get_report_templates_statistics_usecase.dart';
import 'package:tamgaci/features/reports/domain/usecases/duplicate_report_template_usecase.dart';
import 'package:tamgaci/features/reports/presentation/states/reports_state.dart';

/// Reports state notifier
class ReportsNotifier extends StateNotifier<ReportsState> {
  // Report Use Cases
  final CreateReportUseCase _createReportUseCase;
  final GetReportsUseCase _getReportsUseCase;
  final GetReportUseCase _getReportUseCase;
  final UpdateReportUseCase _updateReportUseCase;
  final DeleteReportUseCase _deleteReportUseCase;
  final GetReportsStatisticsUseCase _getReportsStatisticsUseCase;
  final DuplicateReportUseCase _duplicateReportUseCase;

  // ReportTemplate Use Cases
  final CreateReportTemplateUseCase _createReportTemplateUseCase;
  final GetReportTemplatesUseCase _getReportTemplatesUseCase;
  final GetReportTemplateUseCase _getReportTemplateUseCase;
  final UpdateReportTemplateUseCase _updateReportTemplateUseCase;
  final DeleteReportTemplateUseCase _deleteReportTemplateUseCase;
  final GetReportTemplatesStatisticsUseCase
      _getReportTemplatesStatisticsUseCase;
  final DuplicateReportTemplateUseCase _duplicateReportTemplateUseCase;

  ReportsNotifier({
    required CreateReportUseCase createReportUseCase,
    required GetReportsUseCase getReportsUseCase,
    required GetReportUseCase getReportUseCase,
    required UpdateReportUseCase updateReportUseCase,
    required DeleteReportUseCase deleteReportUseCase,
    required GetReportsStatisticsUseCase getReportsStatisticsUseCase,
    required DuplicateReportUseCase duplicateReportUseCase,
    required CreateReportTemplateUseCase createReportTemplateUseCase,
    required GetReportTemplatesUseCase getReportTemplatesUseCase,
    required GetReportTemplateUseCase getReportTemplateUseCase,
    required UpdateReportTemplateUseCase updateReportTemplateUseCase,
    required DeleteReportTemplateUseCase deleteReportTemplateUseCase,
    required GetReportTemplatesStatisticsUseCase
        getReportTemplatesStatisticsUseCase,
    required DuplicateReportTemplateUseCase duplicateReportTemplateUseCase,
  })  : _createReportUseCase = createReportUseCase,
        _getReportsUseCase = getReportsUseCase,
        _getReportUseCase = getReportUseCase,
        _updateReportUseCase = updateReportUseCase,
        _deleteReportUseCase = deleteReportUseCase,
        _getReportsStatisticsUseCase = getReportsStatisticsUseCase,
        _duplicateReportUseCase = duplicateReportUseCase,
        _createReportTemplateUseCase = createReportTemplateUseCase,
        _getReportTemplatesUseCase = getReportTemplatesUseCase,
        _getReportTemplateUseCase = getReportTemplateUseCase,
        _updateReportTemplateUseCase = updateReportTemplateUseCase,
        _deleteReportTemplateUseCase = deleteReportTemplateUseCase,
        _getReportTemplatesStatisticsUseCase =
            getReportTemplatesStatisticsUseCase,
        _duplicateReportTemplateUseCase = duplicateReportTemplateUseCase,
        super(const ReportsState());

  // Report Methods

  /// Tüm raporları getirir
  Future<void> getReports({
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reports = await _getReportsUseCase.call(
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reports: reports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Türüne göre raporları getirir
  Future<void> getReportsByType(
    ReportType type, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reports = await _getReportsUseCase.getByType(
        type,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reports: reports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Duruma göre raporları getirir
  Future<void> getReportsByStatus(
    ReportStatus status, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reports = await _getReportsUseCase.getByStatus(
        status,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reports: reports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Formatına göre raporları getirir
  Future<void> getReportsByFormat(
    ReportFormat format, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reports = await _getReportsUseCase.getByFormat(
        format,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reports: reports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Kullanıcıya göre raporları getirir
  Future<void> getReportsByUser(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reports = await _getReportsUseCase.getByUser(
        userId,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reports: reports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tarih aralığına göre raporları getirir
  Future<void> getReportsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reports = await _getReportsUseCase.getByDateRange(
        startDate,
        endDate,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reports: reports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rapor arama
  Future<void> searchReports(
    String query, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reports = await _getReportsUseCase.search(
        query,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reports: reports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tek rapor getirir
  Future<void> getReport(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report = await _getReportUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        selectedReport: report,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Yeni rapor oluşturur
  Future<void> createReport(Report report) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createdReport = await _createReportUseCase.call(report);

      state = state.copyWith(
        isLoading: false,
        reports: [...state.reports, createdReport],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rapor günceller
  Future<void> updateReport(Report report) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedReport = await _updateReportUseCase.call(report);

      final updatedReports = state.reports.map((r) {
        return r.id == updatedReport.id ? updatedReport : r;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        reports: updatedReports,
        selectedReport: state.selectedReport?.id == updatedReport.id
            ? updatedReport
            : state.selectedReport,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rapor siler
  Future<void> deleteReport(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _deleteReportUseCase.call(id);

      final updatedReports = state.reports.where((r) => r.id != id).toList();

      state = state.copyWith(
        isLoading: false,
        reports: updatedReports,
        selectedReport:
            state.selectedReport?.id == id ? null : state.selectedReport,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rapor kopyalar
  Future<void> duplicateReport(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final duplicatedReport = await _duplicateReportUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        reports: [...state.reports, duplicatedReport],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Raporlar istatistiklerini getirir
  Future<void> getReportsStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final statistics = await _getReportsStatisticsUseCase.call(
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        reportsStatistics: statistics,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ReportTemplate Methods

  /// Tüm rapor şablonlarını getirir
  Future<void> getReportTemplates({
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reportTemplates = await _getReportTemplatesUseCase.call(
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reportTemplates: reportTemplates,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Türüne göre rapor şablonlarını getirir
  Future<void> getReportTemplatesByType(
    ReportTemplateType type, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reportTemplates = await _getReportTemplatesUseCase.getByType(
        type,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reportTemplates: reportTemplates,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rapor türüne göre şablonları getirir
  Future<void> getReportTemplatesByReportType(
    String reportType, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reportTemplates = await _getReportTemplatesUseCase.getByReportType(
        reportType,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reportTemplates: reportTemplates,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Aktif rapor şablonlarını getirir
  Future<void> getActiveReportTemplates({
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reportTemplates = await _getReportTemplatesUseCase.getActive(
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reportTemplates: reportTemplates,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Varsayılan rapor şablonlarını getirir
  Future<void> getDefaultReportTemplates({
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reportTemplates = await _getReportTemplatesUseCase.getDefault(
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reportTemplates: reportTemplates,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Kullanıcıya göre rapor şablonlarını getirir
  Future<void> getReportTemplatesByUser(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reportTemplates = await _getReportTemplatesUseCase.getByUser(
        userId,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reportTemplates: reportTemplates,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rapor şablonu arama
  Future<void> searchReportTemplates(
    String query, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reportTemplates = await _getReportTemplatesUseCase.search(
        query,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        reportTemplates: reportTemplates,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tek rapor şablonu getirir
  Future<void> getReportTemplate(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reportTemplate = await _getReportTemplateUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        selectedReportTemplate: reportTemplate,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Yeni rapor şablonu oluşturur
  Future<void> createReportTemplate(ReportTemplate reportTemplate) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createdReportTemplate =
          await _createReportTemplateUseCase.call(reportTemplate);

      state = state.copyWith(
        isLoading: false,
        reportTemplates: [...state.reportTemplates, createdReportTemplate],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rapor şablonu günceller
  Future<void> updateReportTemplate(ReportTemplate reportTemplate) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedReportTemplate =
          await _updateReportTemplateUseCase.call(reportTemplate);

      final updatedReportTemplates = state.reportTemplates.map((rt) {
        return rt.id == updatedReportTemplate.id ? updatedReportTemplate : rt;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        reportTemplates: updatedReportTemplates,
        selectedReportTemplate:
            state.selectedReportTemplate?.id == updatedReportTemplate.id
                ? updatedReportTemplate
                : state.selectedReportTemplate,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rapor şablonu siler
  Future<void> deleteReportTemplate(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _deleteReportTemplateUseCase.call(id);

      final updatedReportTemplates =
          state.reportTemplates.where((rt) => rt.id != id).toList();

      state = state.copyWith(
        isLoading: false,
        reportTemplates: updatedReportTemplates,
        selectedReportTemplate: state.selectedReportTemplate?.id == id
            ? null
            : state.selectedReportTemplate,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rapor şablonu kopyalar
  Future<void> duplicateReportTemplate(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final duplicatedReportTemplate =
          await _duplicateReportTemplateUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        reportTemplates: [...state.reportTemplates, duplicatedReportTemplate],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rapor şablonları istatistiklerini getirir
  Future<void> getReportTemplatesStatistics() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final statistics = await _getReportTemplatesStatisticsUseCase.call();

      state = state.copyWith(
        isLoading: false,
        reportTemplatesStatistics: statistics,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Seçili rapor temizler
  void clearSelectedReport() {
    state = state.copyWith(selectedReport: null);
  }

  /// Seçili rapor şablonu temizler
  void clearSelectedReportTemplate() {
    state = state.copyWith(selectedReportTemplate: null);
  }

  /// Hata mesajını temizler
  void clearError() {
    state = state.copyWith(error: null);
  }
}
