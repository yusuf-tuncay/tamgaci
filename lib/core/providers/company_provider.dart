// ========== COMPANY PROVIDER ==========
// lib/core/providers/company_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/company.dart';
import '../services/user_company_service.dart';
import '../utils/logger.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

/// Company service provider
final companyServiceProvider = Provider<UserCompanyService>((ref) {
  return UserCompanyService();
});

/// Current company provider
final currentCompanyProvider = FutureProvider<Company?>((ref) async {
  try {
    final companyService = ref.watch(companyServiceProvider);
    final companyData = await companyService.getUserCompany();

    if (companyData != null) {
      return Company.fromJson(companyData);
    }
    return null;
  } catch (e) {
    AppLogger.error('Error loading current company', e);
    return null;
  }
});

/// Company name provider (with fallback) - Multi-tenant safe
final companyNameProvider = Provider<String>((ref) {
  // Auth state'i de izle ki kullanıcı giriş yaptığında yenilensin
  ref.watch(authProvider); // Auth state değişikliklerini izle
  final companyAsync = ref.watch(currentCompanyProvider);

  return companyAsync.when(
    data: (company) => company?.name ?? 'Tamgaci',
    loading: () => 'Yükleniyor...',
    error: (error, stack) => 'Tamgaci',
  );
});

/// Company ID provider
final companyIdProvider = FutureProvider<String?>((ref) async {
  try {
    final companyService = ref.watch(companyServiceProvider);
    return await companyService.getUserCompanyId();
  } catch (e) {
    AppLogger.error('Error loading company ID', e);
    return null;
  }
});

/// Company state notifier
class CompanyNotifier extends StateNotifier<AsyncValue<Company?>> {
  final UserCompanyService _companyService;

  CompanyNotifier(this._companyService) : super(const AsyncValue.loading()) {
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    if (!mounted) return;

    try {
      state = const AsyncValue.loading();
      final companyData = await _companyService.getUserCompany();

      if (mounted) {
        if (companyData != null) {
          final company = Company.fromJson(companyData);
          state = AsyncValue.data(company);
        } else {
          state = const AsyncValue.data(null);
        }
      }
    } catch (error, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  /// Refresh company data
  Future<void> refresh() async {
    if (mounted) {
      await _loadCompany();
    }
  }

  /// Update company
  Future<void> updateCompany(Company company) async {
    if (mounted) {
      try {
        // Update logic would go here
        state = AsyncValue.data(company);
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }
}

/// Company notifier provider
final companyNotifierProvider =
    StateNotifierProvider<CompanyNotifier, AsyncValue<Company?>>((ref) {
  final companyService = ref.watch(companyServiceProvider);
  return CompanyNotifier(companyService);
});
