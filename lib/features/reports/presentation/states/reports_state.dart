import 'package:equatable/equatable.dart';
import 'package:tamgaci/features/reports/domain/entities/report.dart';
import 'package:tamgaci/features/reports/domain/entities/report_template.dart';

/// Reports state
class ReportsState extends Equatable {
  final List<Report> reports;
  final List<ReportTemplate> reportTemplates;
  final Report? selectedReport;
  final ReportTemplate? selectedReportTemplate;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? reportsStatistics;
  final Map<String, dynamic>? reportTemplatesStatistics;
  final List<Map<String, dynamic>> reportTemplatesList;
  final List<String> categories;
  final List<String> tags;

  const ReportsState({
    this.reports = const [],
    this.reportTemplates = const [],
    this.selectedReport,
    this.selectedReportTemplate,
    this.isLoading = false,
    this.error,
    this.reportsStatistics,
    this.reportTemplatesStatistics,
    this.reportTemplatesList = const [],
    this.categories = const [],
    this.tags = const [],
  });

  ReportsState copyWith({
    List<Report>? reports,
    List<ReportTemplate>? reportTemplates,
    Report? selectedReport,
    ReportTemplate? selectedReportTemplate,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? reportsStatistics,
    Map<String, dynamic>? reportTemplatesStatistics,
    List<Map<String, dynamic>>? reportTemplatesList,
    List<String>? categories,
    List<String>? tags,
  }) {
    return ReportsState(
      reports: reports ?? this.reports,
      reportTemplates: reportTemplates ?? this.reportTemplates,
      selectedReport: selectedReport ?? this.selectedReport,
      selectedReportTemplate:
          selectedReportTemplate ?? this.selectedReportTemplate,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      reportsStatistics: reportsStatistics ?? this.reportsStatistics,
      reportTemplatesStatistics:
          reportTemplatesStatistics ?? this.reportTemplatesStatistics,
      reportTemplatesList: reportTemplatesList ?? this.reportTemplatesList,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        reports,
        reportTemplates,
        selectedReport,
        selectedReportTemplate,
        isLoading,
        error,
        reportsStatistics,
        reportTemplatesStatistics,
        reportTemplatesList,
        categories,
        tags,
      ];
}
