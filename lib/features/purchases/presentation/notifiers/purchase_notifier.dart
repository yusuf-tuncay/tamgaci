import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/create_purchase_usecase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/get_purchases_usecase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/get_purchase_usecase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/update_purchase_usecase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/delete_purchase_usecase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/get_purchases_statistics_usecase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/duplicate_purchase_usecase.dart';
import 'package:tamgaci/features/purchases/presentation/states/purchase_state.dart';

/// Purchases state notifier
class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final CreatePurchaseUseCase _createPurchaseUseCase;
  final GetPurchasesUseCase _getPurchasesUseCase;
  final GetPurchaseUseCase _getPurchaseUseCase;
  final UpdatePurchaseUseCase _updatePurchaseUseCase;
  final DeletePurchaseUseCase _deletePurchaseUseCase;
  final GetPurchasesStatisticsUseCase _getPurchasesStatisticsUseCase;
  final DuplicatePurchaseUseCase _duplicatePurchaseUseCase;

  PurchaseNotifier({
    required CreatePurchaseUseCase createPurchaseUseCase,
    required GetPurchasesUseCase getPurchasesUseCase,
    required GetPurchaseUseCase getPurchaseUseCase,
    required UpdatePurchaseUseCase updatePurchaseUseCase,
    required DeletePurchaseUseCase deletePurchaseUseCase,
    required GetPurchasesStatisticsUseCase getPurchasesStatisticsUseCase,
    required DuplicatePurchaseUseCase duplicatePurchaseUseCase,
  })  : _createPurchaseUseCase = createPurchaseUseCase,
        _getPurchasesUseCase = getPurchasesUseCase,
        _getPurchaseUseCase = getPurchaseUseCase,
        _updatePurchaseUseCase = updatePurchaseUseCase,
        _deletePurchaseUseCase = deletePurchaseUseCase,
        _getPurchasesStatisticsUseCase = getPurchasesStatisticsUseCase,
        _duplicatePurchaseUseCase = duplicatePurchaseUseCase,
        super(const PurchaseState());

  /// Tüm satın almaları getirir
  Future<void> getPurchases({
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final purchases = await _getPurchasesUseCase.call(
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        purchases: purchases,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tedarikçiye göre satın almaları getirir
  Future<void> getPurchasesBySupplier(
    String supplierId, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final purchases = await _getPurchasesUseCase.getBySupplier(
        supplierId,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        purchases: purchases,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tarih aralığına göre satın almaları getirir
  Future<void> getPurchasesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final purchases = await _getPurchasesUseCase.getByDateRange(
        startDate,
        endDate,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        purchases: purchases,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Duruma göre satın almaları getirir
  Future<void> getPurchasesByStatus(
    PurchaseStatus status, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final purchases = await _getPurchasesUseCase.getByStatus(
        status,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        purchases: purchases,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Ödeme durumuna göre satın almaları getirir
  Future<void> getPurchasesByPaymentStatus(
    PurchasePaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final purchases = await _getPurchasesUseCase.getByPaymentStatus(
        paymentStatus,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        purchases: purchases,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Vadesi geçmiş satın almaları getirir
  Future<void> getOverduePurchases({
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final purchases = await _getPurchasesUseCase.getOverdue(
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        purchases: purchases,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satın alma arama
  Future<void> searchPurchases(
    String query, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final purchases = await _getPurchasesUseCase.search(
        query,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        purchases: purchases,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tek satın alma getirir
  Future<void> getPurchase(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final purchase = await _getPurchaseUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        selectedPurchase: purchase,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satın alma numarasına göre satın alma getirir
  Future<void> getPurchaseByNumber(String purchaseNumber) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final purchase = await _getPurchaseUseCase.getByNumber(purchaseNumber);

      state = state.copyWith(
        isLoading: false,
        selectedPurchase: purchase,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Yeni satın alma oluşturur
  Future<void> createPurchase(Purchase purchase) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createdPurchase = await _createPurchaseUseCase.call(purchase);

      state = state.copyWith(
        isLoading: false,
        purchases: [...state.purchases, createdPurchase],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satın alma günceller
  Future<void> updatePurchase(Purchase purchase) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedPurchase = await _updatePurchaseUseCase.call(purchase);

      final updatedPurchases = state.purchases.map((p) {
        return p.id == updatedPurchase.id ? updatedPurchase : p;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        purchases: updatedPurchases,
        selectedPurchase: state.selectedPurchase?.id == updatedPurchase.id
            ? updatedPurchase
            : state.selectedPurchase,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satın alma durumunu günceller
  Future<void> updatePurchaseStatus(String id, PurchaseStatus status) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedPurchase =
          await _updatePurchaseUseCase.updateStatus(id, status);

      final updatedPurchases = state.purchases.map((p) {
        return p.id == updatedPurchase.id ? updatedPurchase : p;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        purchases: updatedPurchases,
        selectedPurchase: state.selectedPurchase?.id == updatedPurchase.id
            ? updatedPurchase
            : state.selectedPurchase,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Ödeme durumunu günceller
  Future<void> updatePaymentStatus(
      String id, PurchasePaymentStatus paymentStatus) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedPurchase =
          await _updatePurchaseUseCase.updatePaymentStatus(id, paymentStatus);

      final updatedPurchases = state.purchases.map((p) {
        return p.id == updatedPurchase.id ? updatedPurchase : p;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        purchases: updatedPurchases,
        selectedPurchase: state.selectedPurchase?.id == updatedPurchase.id
            ? updatedPurchase
            : state.selectedPurchase,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satın alma onaylar
  Future<void> approvePurchase(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedPurchase = await _updatePurchaseUseCase.approve(id);

      final updatedPurchases = state.purchases.map((p) {
        return p.id == updatedPurchase.id ? updatedPurchase : p;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        purchases: updatedPurchases,
        selectedPurchase: state.selectedPurchase?.id == updatedPurchase.id
            ? updatedPurchase
            : state.selectedPurchase,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satın alma teslim alır
  Future<void> receivePurchase(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedPurchase = await _updatePurchaseUseCase.receive(id);

      final updatedPurchases = state.purchases.map((p) {
        return p.id == updatedPurchase.id ? updatedPurchase : p;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        purchases: updatedPurchases,
        selectedPurchase: state.selectedPurchase?.id == updatedPurchase.id
            ? updatedPurchase
            : state.selectedPurchase,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satın alma iptal eder
  Future<void> cancelPurchase(String id, String reason) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedPurchase = await _updatePurchaseUseCase.cancel(id, reason);

      final updatedPurchases = state.purchases.map((p) {
        return p.id == updatedPurchase.id ? updatedPurchase : p;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        purchases: updatedPurchases,
        selectedPurchase: state.selectedPurchase?.id == updatedPurchase.id
            ? updatedPurchase
            : state.selectedPurchase,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satın alma iade eder
  Future<void> returnPurchase(String id, String reason) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedPurchase =
          await _updatePurchaseUseCase.returnPurchase(id, reason);

      final updatedPurchases = state.purchases.map((p) {
        return p.id == updatedPurchase.id ? updatedPurchase : p;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        purchases: updatedPurchases,
        selectedPurchase: state.selectedPurchase?.id == updatedPurchase.id
            ? updatedPurchase
            : state.selectedPurchase,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satın alma siler
  Future<void> deletePurchase(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _deletePurchaseUseCase.call(id);

      final updatedPurchases =
          state.purchases.where((p) => p.id != id).toList();

      state = state.copyWith(
        isLoading: false,
        purchases: updatedPurchases,
        selectedPurchase:
            state.selectedPurchase?.id == id ? null : state.selectedPurchase,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satın alma kopyalar
  Future<void> duplicatePurchase(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final duplicatedPurchase = await _duplicatePurchaseUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        purchases: [...state.purchases, duplicatedPurchase],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satın alma istatistiklerini getirir
  Future<void> getPurchasesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final statistics = await _getPurchasesStatisticsUseCase.call(
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        statistics: statistics,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satın alma raporu oluşturur
  Future<void> getPurchasesReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report = await _getPurchasesStatisticsUseCase.getReport(
        startDate,
        endDate,
        groupBy: groupBy,
      );

      state = state.copyWith(
        isLoading: false,
        report: report,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// En çok satın alınan ürünleri getirir
  Future<void> getTopPurchasedProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final topProducts =
          await _getPurchasesStatisticsUseCase.getTopPurchasedProducts(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        topPurchasedProducts: topProducts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// En çok satın alma yapılan tedarikçileri getirir
  Future<void> getTopSuppliers({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final topSuppliers = await _getPurchasesStatisticsUseCase.getTopSuppliers(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        topSuppliers: topSuppliers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Seçili satın alma temizler
  void clearSelectedPurchase() {
    state = state.copyWith(selectedPurchase: null);
  }

  /// Hata mesajını temizler
  void clearError() {
    state = state.copyWith(error: null);
  }
}
