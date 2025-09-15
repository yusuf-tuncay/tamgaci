import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/features/sales/data/datasources/sale_firebase_datasource.dart';
import 'package:tamgaci/features/sales/data/repositories/sale_repository_impl.dart';
import 'package:tamgaci/features/sales/presentation/states/sale_state.dart';
import 'package:tamgaci/features/sales/domain/usecases/create_sale_usecase.dart';
import 'package:tamgaci/features/sales/domain/usecases/get_sales_usecase.dart';
import 'package:tamgaci/features/sales/domain/usecases/get_sale_usecase.dart';
import 'package:tamgaci/features/sales/domain/usecases/update_sale_usecase.dart';
import 'package:tamgaci/features/sales/domain/usecases/delete_sale_usecase.dart';
import 'package:tamgaci/features/sales/domain/usecases/get_sales_statistics_usecase.dart';
import 'package:tamgaci/features/sales/domain/usecases/duplicate_sale_usecase.dart';
import 'package:tamgaci/features/sales/presentation/notifiers/sale_notifier.dart';

/// Firebase Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Sale Firebase DataSource provider
final saleFirebaseDataSourceProvider = Provider<SaleFirebaseDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return SaleFirebaseDataSourceImpl(firestore: firestore);
});

/// Sale Repository provider
final saleRepositoryProvider = Provider<SaleRepositoryImpl>((ref) {
  final dataSource = ref.watch(saleFirebaseDataSourceProvider);
  return SaleRepositoryImpl(dataSource: dataSource);
});

/// Create Sale UseCase provider
final createSaleUseCaseProvider = Provider<CreateSaleUseCase>((ref) {
  final repository = ref.watch(saleRepositoryProvider);
  return CreateSaleUseCase(repository);
});

/// Get Sales UseCase provider
final getSalesUseCaseProvider = Provider<GetSalesUseCase>((ref) {
  final repository = ref.watch(saleRepositoryProvider);
  return GetSalesUseCase(repository);
});

/// Get Sale UseCase provider
final getSaleUseCaseProvider = Provider<GetSaleUseCase>((ref) {
  final repository = ref.watch(saleRepositoryProvider);
  return GetSaleUseCase(repository);
});

/// Update Sale UseCase provider
final updateSaleUseCaseProvider = Provider<UpdateSaleUseCase>((ref) {
  final repository = ref.watch(saleRepositoryProvider);
  return UpdateSaleUseCase(repository);
});

/// Delete Sale UseCase provider
final deleteSaleUseCaseProvider = Provider<DeleteSaleUseCase>((ref) {
  final repository = ref.watch(saleRepositoryProvider);
  return DeleteSaleUseCase(repository);
});

/// Get Sales Statistics UseCase provider
final getSalesStatisticsUseCaseProvider =
    Provider<GetSalesStatisticsUseCase>((ref) {
  final repository = ref.watch(saleRepositoryProvider);
  return GetSalesStatisticsUseCase(repository);
});

/// Duplicate Sale UseCase provider
final duplicateSaleUseCaseProvider = Provider<DuplicateSaleUseCase>((ref) {
  final repository = ref.watch(saleRepositoryProvider);
  return DuplicateSaleUseCase(repository);
});

/// Sale Notifier provider
final saleNotifierProvider =
    StateNotifierProvider<SaleNotifier, SaleState>((ref) {
  final createSaleUseCase = ref.watch(createSaleUseCaseProvider);
  final getSalesUseCase = ref.watch(getSalesUseCaseProvider);
  final getSaleUseCase = ref.watch(getSaleUseCaseProvider);
  final updateSaleUseCase = ref.watch(updateSaleUseCaseProvider);
  final deleteSaleUseCase = ref.watch(deleteSaleUseCaseProvider);
  final getSalesStatisticsUseCase =
      ref.watch(getSalesStatisticsUseCaseProvider);
  final duplicateSaleUseCase = ref.watch(duplicateSaleUseCaseProvider);

  return SaleNotifier(
    createSaleUseCase: createSaleUseCase,
    getSalesUseCase: getSalesUseCase,
    getSaleUseCase: getSaleUseCase,
    updateSaleUseCase: updateSaleUseCase,
    deleteSaleUseCase: deleteSaleUseCase,
    getSalesStatisticsUseCase: getSalesStatisticsUseCase,
    duplicateSaleUseCase: duplicateSaleUseCase,
  );
});
