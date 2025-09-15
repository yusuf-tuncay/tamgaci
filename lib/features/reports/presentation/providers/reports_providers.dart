import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/features/reports/data/datasources/report_firebase_datasource.dart';
import 'package:tamgaci/features/reports/data/datasources/report_template_firebase_datasource.dart';
import 'package:tamgaci/features/reports/data/repositories/report_repository_impl.dart';
import 'package:tamgaci/features/reports/data/repositories/report_template_repository_impl.dart';
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
import 'package:tamgaci/features/reports/presentation/notifiers/reports_notifier.dart';
import 'package:tamgaci/features/reports/presentation/states/reports_state.dart';

/// Firebase Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Report Firebase DataSource provider
final reportFirebaseDataSourceProvider =
    Provider<ReportFirebaseDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return ReportFirebaseDataSource(firestore, firebaseAuth);
});

/// ReportTemplate Firebase DataSource provider
final reportTemplateFirebaseDataSourceProvider =
    Provider<ReportTemplateFirebaseDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return ReportTemplateFirebaseDataSource(firestore, firebaseAuth);
});

/// Report Repository provider
final reportRepositoryProvider = Provider<ReportRepositoryImpl>((ref) {
  final dataSource = ref.watch(reportFirebaseDataSourceProvider);
  return ReportRepositoryImpl(dataSource: dataSource);
});

/// ReportTemplate Repository provider
final reportTemplateRepositoryProvider =
    Provider<ReportTemplateRepositoryImpl>((ref) {
  final dataSource = ref.watch(reportTemplateFirebaseDataSourceProvider);
  return ReportTemplateRepositoryImpl(dataSource: dataSource);
});

/// Create Report UseCase provider
final createReportUseCaseProvider = Provider<CreateReportUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return CreateReportUseCase(repository);
});

/// Get Reports UseCase provider
final getReportsUseCaseProvider = Provider<GetReportsUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return GetReportsUseCase(repository);
});

/// Get Report UseCase provider
final getReportUseCaseProvider = Provider<GetReportUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return GetReportUseCase(repository);
});

/// Update Report UseCase provider
final updateReportUseCaseProvider = Provider<UpdateReportUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return UpdateReportUseCase(repository);
});

/// Delete Report UseCase provider
final deleteReportUseCaseProvider = Provider<DeleteReportUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return DeleteReportUseCase(repository);
});

/// Get Reports Statistics UseCase provider
final getReportsStatisticsUseCaseProvider =
    Provider<GetReportsStatisticsUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return GetReportsStatisticsUseCase(repository);
});

/// Duplicate Report UseCase provider
final duplicateReportUseCaseProvider = Provider<DuplicateReportUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return DuplicateReportUseCase(repository);
});

/// Create ReportTemplate UseCase provider
final createReportTemplateUseCaseProvider =
    Provider<CreateReportTemplateUseCase>((ref) {
  final repository = ref.watch(reportTemplateRepositoryProvider);
  return CreateReportTemplateUseCase(repository);
});

/// Get ReportTemplates UseCase provider
final getReportTemplatesUseCaseProvider =
    Provider<GetReportTemplatesUseCase>((ref) {
  final repository = ref.watch(reportTemplateRepositoryProvider);
  return GetReportTemplatesUseCase(repository);
});

/// Get ReportTemplate UseCase provider
final getReportTemplateUseCaseProvider =
    Provider<GetReportTemplateUseCase>((ref) {
  final repository = ref.watch(reportTemplateRepositoryProvider);
  return GetReportTemplateUseCase(repository);
});

/// Update ReportTemplate UseCase provider
final updateReportTemplateUseCaseProvider =
    Provider<UpdateReportTemplateUseCase>((ref) {
  final repository = ref.watch(reportTemplateRepositoryProvider);
  return UpdateReportTemplateUseCase(repository);
});

/// Delete ReportTemplate UseCase provider
final deleteReportTemplateUseCaseProvider =
    Provider<DeleteReportTemplateUseCase>((ref) {
  final repository = ref.watch(reportTemplateRepositoryProvider);
  return DeleteReportTemplateUseCase(repository);
});

/// Get ReportTemplates Statistics UseCase provider
final getReportTemplatesStatisticsUseCaseProvider =
    Provider<GetReportTemplatesStatisticsUseCase>((ref) {
  final repository = ref.watch(reportTemplateRepositoryProvider);
  return GetReportTemplatesStatisticsUseCase(repository);
});

/// Duplicate ReportTemplate UseCase provider
final duplicateReportTemplateUseCaseProvider =
    Provider<DuplicateReportTemplateUseCase>((ref) {
  final repository = ref.watch(reportTemplateRepositoryProvider);
  return DuplicateReportTemplateUseCase(repository);
});

/// Reports Notifier provider
final reportsNotifierProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  final createReportUseCase = ref.watch(createReportUseCaseProvider);
  final getReportsUseCase = ref.watch(getReportsUseCaseProvider);
  final getReportUseCase = ref.watch(getReportUseCaseProvider);
  final updateReportUseCase = ref.watch(updateReportUseCaseProvider);
  final deleteReportUseCase = ref.watch(deleteReportUseCaseProvider);
  final getReportsStatisticsUseCase =
      ref.watch(getReportsStatisticsUseCaseProvider);
  final duplicateReportUseCase = ref.watch(duplicateReportUseCaseProvider);
  final createReportTemplateUseCase =
      ref.watch(createReportTemplateUseCaseProvider);
  final getReportTemplatesUseCase =
      ref.watch(getReportTemplatesUseCaseProvider);
  final getReportTemplateUseCase = ref.watch(getReportTemplateUseCaseProvider);
  final updateReportTemplateUseCase =
      ref.watch(updateReportTemplateUseCaseProvider);
  final deleteReportTemplateUseCase =
      ref.watch(deleteReportTemplateUseCaseProvider);
  final getReportTemplatesStatisticsUseCase =
      ref.watch(getReportTemplatesStatisticsUseCaseProvider);
  final duplicateReportTemplateUseCase =
      ref.watch(duplicateReportTemplateUseCaseProvider);

  return ReportsNotifier(
    createReportUseCase: createReportUseCase,
    getReportsUseCase: getReportsUseCase,
    getReportUseCase: getReportUseCase,
    updateReportUseCase: updateReportUseCase,
    deleteReportUseCase: deleteReportUseCase,
    getReportsStatisticsUseCase: getReportsStatisticsUseCase,
    duplicateReportUseCase: duplicateReportUseCase,
    createReportTemplateUseCase: createReportTemplateUseCase,
    getReportTemplatesUseCase: getReportTemplatesUseCase,
    getReportTemplateUseCase: getReportTemplateUseCase,
    updateReportTemplateUseCase: updateReportTemplateUseCase,
    deleteReportTemplateUseCase: deleteReportTemplateUseCase,
    getReportTemplatesStatisticsUseCase: getReportTemplatesStatisticsUseCase,
    duplicateReportTemplateUseCase: duplicateReportTemplateUseCase,
  );
});
