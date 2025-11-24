import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_account_repository.dart';
import '../../data/services/account_initialization_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Account Repository Provider
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  ref.watch(authProvider);
  return FirebaseAccountRepository();
});

/// Accounts List Provider
final accountsProvider = FutureProvider<List<Account>>((ref) async {
  final repository = ref.read(accountRepositoryProvider);
  return await repository.getAccounts();
});

/// Active Accounts Provider
final activeAccountsProvider = FutureProvider<List<Account>>((ref) async {
  final repository = ref.read(accountRepositoryProvider);
  return await repository.getActiveAccounts();
});

/// Account by ID Provider
final accountByIdProvider =
    FutureProvider.family<Account?, String>((ref, id) async {
  final repository = ref.read(accountRepositoryProvider);
  return await repository.getAccountById(id);
});

/// Account Stream Provider (Realtime)
final accountStreamProvider =
    StreamProvider.family<Account?, String>((ref, id) {
  final repository = ref.read(accountRepositoryProvider);
  return repository.getAccountStream(id);
});

/// Accounts by Currency Provider
final accountsByCurrencyProvider =
    FutureProvider.family<List<Account>, String>((ref, currency) async {
  final repository = ref.read(accountRepositoryProvider);
  return await repository.getAccountsByCurrency(currency);
});

/// Search Accounts Provider
final searchAccountsProvider =
    FutureProvider.family<List<Account>, String>((ref, query) async {
  final repository = ref.read(accountRepositoryProvider);
  return await repository.searchAccounts(query);
});

/// Account Statistics Provider
final accountStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final accounts = await ref.read(accountsProvider.future);

  double totalBalance = 0;
  double totalAvailableBalance = 0;
  double totalBlockedAmount = 0;
  int activeAccountsCount = 0;
  int inactiveAccountsCount = 0;

  Map<String, double> balancesByCurrency = {};
  Map<AccountType, int> accountsByType = {};
  Map<AccountStatus, int> accountsByStatus = {};

  for (final account in accounts) {
    totalBalance += account.balance;
    totalAvailableBalance += account.availableBalance;
    totalBlockedAmount += account.blockedAmount;

    if (account.isActive) {
      activeAccountsCount++;
    } else {
      inactiveAccountsCount++;
    }

    // Para birimine göre bakiye
    balancesByCurrency[account.currency] =
        (balancesByCurrency[account.currency] ?? 0) + account.balance;

    // Hesap türüne göre sayım
    accountsByType[account.type] = (accountsByType[account.type] ?? 0) + 1;

    // Hesap durumuna göre sayım
    accountsByStatus[account.status] =
        (accountsByStatus[account.status] ?? 0) + 1;
  }

  return {
    'totalBalance': totalBalance,
    'totalAvailableBalance': totalAvailableBalance,
    'totalBlockedAmount': totalBlockedAmount,
    'activeAccountsCount': activeAccountsCount,
    'inactiveAccountsCount': inactiveAccountsCount,
    'totalAccountsCount': accounts.length,
    'balancesByCurrency': balancesByCurrency,
    'accountsByType': accountsByType,
    'accountsByStatus': accountsByStatus,
  };
});

/// Account Notifier
class AccountNotifier extends StateNotifier<AsyncValue<List<Account>>> {
  final AccountRepository _repository;

  AccountNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      state = const AsyncValue.loading();
      var accounts = await _repository.getAccounts();

      if (accounts.isEmpty) {
        AppLogger.info(
            'AccountNotifier: No accounts found, attempting to seed defaults.');
        try {
          final initializer = AccountInitializationService();
          await initializer.initializeDefaultAccounts();
          accounts = await _repository.getAccounts();
          AppLogger.info(
              'AccountNotifier: Default accounts initialization completed. Account count: ${accounts.length}');
        } catch (e) {
          AppLogger.error(
              'AccountNotifier: Failed to initialize default accounts', e);
        }
      }

      state = AsyncValue.data(accounts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadAccounts();
  }

  Future<void> createAccount(Account account) async {
    try {
      await _repository.createAccount(account);
      await _loadAccounts();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      await _repository.updateAccount(account);
      await _loadAccounts();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      await _repository.deleteAccount(id);
      await _loadAccounts();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      await _repository.updateAccountBalance(accountId, newBalance);
      await _loadAccounts();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateAccountStatus(
      String accountId, AccountStatus status) async {
    try {
      await _repository.updateAccountStatus(accountId, status);
      await _loadAccounts();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Account Notifier Provider
final accountNotifierProvider =
    StateNotifierProvider<AccountNotifier, AsyncValue<List<Account>>>((ref) {
  final repository = ref.read(accountRepositoryProvider);
  return AccountNotifier(repository);
});
