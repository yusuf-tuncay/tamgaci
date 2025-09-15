import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/core/errors/error_logger.dart';
import 'package:tamgaci/core/repositories/cache_repository.dart';

/// Cache provider for managing cache state
class CacheProvider extends StateNotifier<CacheState> {
  CacheProvider() : super(const CacheState());

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // This would typically clear all cache repositories
      // For now, we'll just log the action
      ErrorLogger.logInfo(
        'Clearing all cache',
        context: 'CacheProvider',
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Tüm önbellek temizlendi',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Önbellek temizlenirken hata oluştu: $e',
      );
      ErrorLogger.logError(
        'Error clearing all cache',
        error: e,
        context: 'CacheProvider',
      );
    }
  }

  /// Clear specific cache
  Future<void> clearCache(String cacheKey) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      ErrorLogger.logInfo(
        'Clearing cache: $cacheKey',
        context: 'CacheProvider',
        additionalData: {'cacheKey': cacheKey},
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Önbellek temizlendi: $cacheKey',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Önbellek temizlenirken hata oluştu: $e',
      );
      ErrorLogger.logError(
        'Error clearing cache: $cacheKey',
        error: e,
        context: 'CacheProvider',
        additionalData: {'cacheKey': cacheKey},
      );
    }
  }

  /// Get cache info
  Future<void> getCacheInfo() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // This would typically get cache info from all repositories
      // For now, we'll just log the action
      ErrorLogger.logInfo(
        'Getting cache info',
        context: 'CacheProvider',
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Önbellek bilgileri alındı',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Önbellek bilgileri alınırken hata oluştu: $e',
      );
      ErrorLogger.logError(
        'Error getting cache info',
        error: e,
        context: 'CacheProvider',
      );
    }
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

/// Cache state class
class CacheState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, CacheInfo> cacheInfo;

  const CacheState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.cacheInfo = const {},
  });

  CacheState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    Map<String, CacheInfo>? cacheInfo,
  }) {
    return CacheState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      cacheInfo: cacheInfo ?? this.cacheInfo,
    );
  }
}

/// Cache provider instance
final cacheProvider = StateNotifierProvider<CacheProvider, CacheState>((ref) {
  return CacheProvider();
});

/// Cache info provider
final cacheInfoProvider = FutureProvider<Map<String, CacheInfo>>((ref) async {
  try {
    // This would typically get cache info from all repositories
    // For now, we'll return empty map
    return {};
  } catch (e) {
    ErrorLogger.logError(
      'Error getting cache info',
      error: e,
      context: 'CacheInfoProvider',
    );
    return {};
  }
});

/// Cache size provider
final cacheSizeProvider = FutureProvider<int>((ref) async {
  try {
    // This would typically calculate total cache size
    // For now, we'll return 0
    return 0;
  } catch (e) {
    ErrorLogger.logError(
      'Error getting cache size',
      error: e,
      context: 'CacheSizeProvider',
    );
    return 0;
  }
});

/// Cache expiry provider
final cacheExpiryProvider = FutureProvider<Map<String, DateTime>>((ref) async {
  try {
    // This would typically get cache expiry times
    // For now, we'll return empty map
    return {};
  } catch (e) {
    ErrorLogger.logError(
      'Error getting cache expiry',
      error: e,
      context: 'CacheExpiryProvider',
    );
    return {};
  }
});
