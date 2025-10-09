// ========== TRIAL PROVIDERS ==========
// lib/features/subscription/presentation/providers/trial_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/subscription/trial_service.dart';
import '../../domain/entities/trial_entity.dart';

/// Trial servisi provider'ı
final trialServiceProvider = Provider<TrialService>((ref) {
  return TrialService();
});

/// Kullanıcının trial durumu provider'ı
final userTrialProvider =
    FutureProvider.family<TrialEntity?, String>((ref, userId) async {
  try {
    final trialService = ref.read(trialServiceProvider);
    return await trialService.getUserTrial(userId);
  } catch (e) {
    return null;
  }
});

/// Trial durum kontrolü provider'ı
final trialStatusProvider =
    FutureProvider.family<TrialStatusResult, String>((ref, userId) async {
  try {
    final trialService = ref.read(trialServiceProvider);
    return await trialService.checkTrialStatus(userId);
  } catch (e) {
    return TrialStatusResult(
      success: false,
      hasTrial: false,
      status: 'none',
      error: 'Trial status check failed: $e',
    );
  }
});

/// Trial oluşturma provider'ı
final trialCreationProvider =
    StateNotifierProvider<TrialCreationNotifier, TrialCreationState>((ref) {
  return TrialCreationNotifier(ref.read(trialServiceProvider));
});

/// Trial oluşturma notifier'ı
class TrialCreationNotifier extends StateNotifier<TrialCreationState> {
  final TrialService _trialService;

  TrialCreationNotifier(this._trialService) : super(const TrialCreationState());

  /// Trial oluştur
  Future<void> createTrial(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _trialService.createUserTrial(userId);

      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          success: true,
          trialId: result.trialId,
          message: result.message,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Trial creation failed: $e',
      );
    }
  }

  /// Durumu temizle
  void clearState() {
    state = const TrialCreationState();
  }
}

/// Trial oluşturma durumu
class TrialCreationState {
  final bool isLoading;
  final bool success;
  final String? trialId;
  final String? error;
  final String? message;

  const TrialCreationState({
    this.isLoading = false,
    this.success = false,
    this.trialId,
    this.error,
    this.message,
  });

  TrialCreationState copyWith({
    bool? isLoading,
    bool? success,
    String? trialId,
    String? error,
    String? message,
  }) {
    return TrialCreationState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      trialId: trialId ?? this.trialId,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }
}

/// Trial countdown provider'ı
final trialCountdownProvider =
    StreamProvider.family<String, String>((ref, userId) async* {
  final trialService = ref.read(trialServiceProvider);

  while (true) {
    try {
      final trial = await trialService.getUserTrial(userId);

      if (trial == null) {
        yield 'Trial bulunamadı';
        break;
      }

      if (trial.isExpired) {
        yield 'Süresi dolmuş';
        break;
      }

      yield trial.countdownText;

      // 1 dakika bekle
      await Future.delayed(const Duration(minutes: 1));
    } catch (e) {
      yield 'Hata: $e';
      break;
    }
  }
});

/// Trial otomatik oluşturma provider'ı
final ensureTrialProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  try {
    final trialService = ref.read(trialServiceProvider);

    // Önce mevcut trial'ı kontrol et
    final existingTrial = await trialService.getUserTrial(userId);
    if (existingTrial != null) {
      return true; // Trial zaten var
    }

    // Trial oluştur
    final result = await trialService.createUserTrial(userId);
    return result.success;
  } catch (e) {
    return false;
  }
});
