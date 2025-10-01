import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/features/cash_management/data/datasources/cash_account_firebase_datasource.dart';
import 'package:tamgaci/features/cash_management/data/datasources/cash_transaction_firebase_datasource.dart';
import 'package:tamgaci/features/cash_management/data/repositories/cash_account_repository_impl.dart';
import 'package:tamgaci/features/cash_management/data/repositories/cash_transaction_repository_impl.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/create_cash_account_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/get_cash_accounts_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/get_cash_account_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/update_cash_account_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/delete_cash_account_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/get_cash_accounts_statistics_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/duplicate_cash_account_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/create_cash_transaction_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/get_cash_transactions_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/get_cash_transaction_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/update_cash_transaction_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/delete_cash_transaction_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/get_cash_transactions_statistics_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/duplicate_cash_transaction_usecase.dart';
import 'package:tamgaci/features/cash_management/presentation/notifiers/cash_management_notifier.dart';
import 'package:tamgaci/features/cash_management/presentation/states/cash_management_state.dart';
import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';

/// Firebase Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Cash Account Firebase DataSource provider
final cashAccountFirebaseDataSourceProvider =
    Provider<CashAccountFirebaseDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return CashAccountFirebaseDataSource(firestore, firebaseAuth);
});

/// Cash Transaction Firebase DataSource provider
final cashTransactionFirebaseDataSourceProvider =
    Provider<CashTransactionFirebaseDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return CashTransactionFirebaseDataSource(firestore, firebaseAuth);
});

/// Cash Account Repository provider
final cashAccountRepositoryProvider =
    Provider<CashAccountRepositoryImpl>((ref) {
  final dataSource = ref.watch(cashAccountFirebaseDataSourceProvider);
  return CashAccountRepositoryImpl(dataSource: dataSource);
});

/// Cash Transaction Repository provider
final cashTransactionRepositoryProvider =
    Provider<CashTransactionRepositoryImpl>((ref) {
  final dataSource = ref.watch(cashTransactionFirebaseDataSourceProvider);
  return CashTransactionRepositoryImpl(dataSource: dataSource);
});

/// Create Cash Account UseCase provider
final createCashAccountUseCaseProvider =
    Provider<CreateCashAccountUseCase>((ref) {
  final repository = ref.watch(cashAccountRepositoryProvider);
  return CreateCashAccountUseCase(repository);
});

/// Get Cash Accounts UseCase provider
final getCashAccountsUseCaseProvider = Provider<GetCashAccountsUseCase>((ref) {
  final repository = ref.watch(cashAccountRepositoryProvider);
  return GetCashAccountsUseCase(repository);
});

/// Get Cash Account UseCase provider
final getCashAccountUseCaseProvider = Provider<GetCashAccountUseCase>((ref) {
  final repository = ref.watch(cashAccountRepositoryProvider);
  return GetCashAccountUseCase(repository);
});

/// Update Cash Account UseCase provider
final updateCashAccountUseCaseProvider =
    Provider<UpdateCashAccountUseCase>((ref) {
  final repository = ref.watch(cashAccountRepositoryProvider);
  return UpdateCashAccountUseCase(repository);
});

/// Delete Cash Account UseCase provider
final deleteCashAccountUseCaseProvider =
    Provider<DeleteCashAccountUseCase>((ref) {
  final repository = ref.watch(cashAccountRepositoryProvider);
  return DeleteCashAccountUseCase(repository);
});

/// Get Cash Accounts Statistics UseCase provider
final getCashAccountsStatisticsUseCaseProvider =
    Provider<GetCashAccountsStatisticsUseCase>((ref) {
  final repository = ref.watch(cashAccountRepositoryProvider);
  return GetCashAccountsStatisticsUseCase(repository);
});

/// Duplicate Cash Account UseCase provider
final duplicateCashAccountUseCaseProvider =
    Provider<DuplicateCashAccountUseCase>((ref) {
  final repository = ref.watch(cashAccountRepositoryProvider);
  return DuplicateCashAccountUseCase(repository);
});

/// Create Cash Transaction UseCase provider
final createCashTransactionUseCaseProvider =
    Provider<CreateCashTransactionUseCase>((ref) {
  final repository = ref.watch(cashTransactionRepositoryProvider);
  return CreateCashTransactionUseCase(repository);
});

/// Get Cash Transactions UseCase provider
final getCashTransactionsUseCaseProvider =
    Provider<GetCashTransactionsUseCase>((ref) {
  final repository = ref.watch(cashTransactionRepositoryProvider);
  return GetCashTransactionsUseCase(repository);
});

/// Get Cash Transaction UseCase provider
final getCashTransactionUseCaseProvider =
    Provider<GetCashTransactionUseCase>((ref) {
  final repository = ref.watch(cashTransactionRepositoryProvider);
  return GetCashTransactionUseCase(repository);
});

/// Update Cash Transaction UseCase provider
final updateCashTransactionUseCaseProvider =
    Provider<UpdateCashTransactionUseCase>((ref) {
  final repository = ref.watch(cashTransactionRepositoryProvider);
  return UpdateCashTransactionUseCase(repository);
});

/// Delete Cash Transaction UseCase provider
final deleteCashTransactionUseCaseProvider =
    Provider<DeleteCashTransactionUseCase>((ref) {
  final repository = ref.watch(cashTransactionRepositoryProvider);
  return DeleteCashTransactionUseCase(repository);
});

/// Get Cash Transactions Statistics UseCase provider
final getCashTransactionsStatisticsUseCaseProvider =
    Provider<GetCashTransactionsStatisticsUseCase>((ref) {
  final repository = ref.watch(cashTransactionRepositoryProvider);
  return GetCashTransactionsStatisticsUseCase(repository);
});

/// Duplicate Cash Transaction UseCase provider
final duplicateCashTransactionUseCaseProvider =
    Provider<DuplicateCashTransactionUseCase>((ref) {
  final repository = ref.watch(cashTransactionRepositoryProvider);
  return DuplicateCashTransactionUseCase(repository);
});

/// Cash Accounts Stream Provider
final cashAccountsStreamProvider = StreamProvider<List<CashAccount>>((ref) {
  final notifier = ref.read(cashManagementNotifierProvider.notifier);
  return notifier.watchCashAccounts();
});

/// Cash Management Notifier provider
final cashManagementNotifierProvider =
    StateNotifierProvider<CashManagementNotifier, CashManagementState>((ref) {
  final createCashAccountUseCase = ref.watch(createCashAccountUseCaseProvider);
  final getCashAccountsUseCase = ref.watch(getCashAccountsUseCaseProvider);
  final getCashAccountUseCase = ref.watch(getCashAccountUseCaseProvider);
  final updateCashAccountUseCase = ref.watch(updateCashAccountUseCaseProvider);
  final deleteCashAccountUseCase = ref.watch(deleteCashAccountUseCaseProvider);
  final getCashAccountsStatisticsUseCase =
      ref.watch(getCashAccountsStatisticsUseCaseProvider);
  final duplicateCashAccountUseCase =
      ref.watch(duplicateCashAccountUseCaseProvider);
  final createCashTransactionUseCase =
      ref.watch(createCashTransactionUseCaseProvider);
  final getCashTransactionsUseCase =
      ref.watch(getCashTransactionsUseCaseProvider);
  final getCashTransactionUseCase =
      ref.watch(getCashTransactionUseCaseProvider);
  final updateCashTransactionUseCase =
      ref.watch(updateCashTransactionUseCaseProvider);
  final deleteCashTransactionUseCase =
      ref.watch(deleteCashTransactionUseCaseProvider);
  final getCashTransactionsStatisticsUseCase =
      ref.watch(getCashTransactionsStatisticsUseCaseProvider);
  final duplicateCashTransactionUseCase =
      ref.watch(duplicateCashTransactionUseCaseProvider);

  return CashManagementNotifier(
    createCashAccountUseCase: createCashAccountUseCase,
    getCashAccountsUseCase: getCashAccountsUseCase,
    getCashAccountUseCase: getCashAccountUseCase,
    updateCashAccountUseCase: updateCashAccountUseCase,
    deleteCashAccountUseCase: deleteCashAccountUseCase,
    getCashAccountsStatisticsUseCase: getCashAccountsStatisticsUseCase,
    duplicateCashAccountUseCase: duplicateCashAccountUseCase,
    createCashTransactionUseCase: createCashTransactionUseCase,
    getCashTransactionsUseCase: getCashTransactionsUseCase,
    getCashTransactionUseCase: getCashTransactionUseCase,
    updateCashTransactionUseCase: updateCashTransactionUseCase,
    deleteCashTransactionUseCase: deleteCashTransactionUseCase,
    getCashTransactionsStatisticsUseCase: getCashTransactionsStatisticsUseCase,
    duplicateCashTransactionUseCase: duplicateCashTransactionUseCase,
  );
});
