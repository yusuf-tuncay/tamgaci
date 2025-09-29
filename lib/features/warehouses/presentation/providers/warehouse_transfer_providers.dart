import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/warehouse_transfer.dart';
import '../../domain/repositories/warehouse_transfer_repository.dart';
import '../../data/repositories/firebase_warehouse_transfer_repository.dart';

/// Warehouse Transfer Repository Provider
final warehouseTransferRepositoryProvider = Provider<WarehouseTransferRepository>((ref) {
  return FirebaseWarehouseTransferRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

/// Warehouse Transfers Provider
final warehouseTransfersProvider = FutureProvider<List<WarehouseTransfer>>((ref) async {
  final repository = ref.read(warehouseTransferRepositoryProvider);
  return repository.getTransfers();
});

/// Warehouse Transfers by Warehouse Provider
final warehouseTransfersByWarehouseProvider = FutureProvider.family<List<WarehouseTransfer>, String>((ref, warehouseId) async {
  final repository = ref.read(warehouseTransferRepositoryProvider);
  return repository.getTransfersByWarehouse(warehouseId);
});

/// Warehouse Transfers by Product Provider
final warehouseTransfersByProductProvider = FutureProvider.family<List<WarehouseTransfer>, String>((ref, productId) async {
  final repository = ref.read(warehouseTransferRepositoryProvider);
  return repository.getTransfersByProduct(productId);
});

/// Pending Transfers Provider
final pendingTransfersProvider = FutureProvider<List<WarehouseTransfer>>((ref) async {
  final repository = ref.read(warehouseTransferRepositoryProvider);
  return repository.getPendingTransfers();
});

/// Warehouse Transfer Notifier
class WarehouseTransferNotifier extends StateNotifier<AsyncValue<List<WarehouseTransfer>>> {
  final WarehouseTransferRepository _repository;

  WarehouseTransferNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadTransfers();
  }

  Future<void> _loadTransfers() async {
    try {
      state = const AsyncValue.loading();
      final transfers = await _repository.getTransfers();
      state = AsyncValue.data(transfers);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createTransfer(WarehouseTransfer transfer) async {
    try {
      await _repository.createTransfer(transfer);
      await _loadTransfers();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateTransfer(WarehouseTransfer transfer) async {
    try {
      await _repository.updateTransfer(transfer);
      await _loadTransfers();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteTransfer(String id) async {
    try {
      await _repository.deleteTransfer(id);
      await _loadTransfers();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> completeTransfer(String id) async {
    try {
      await _repository.completeTransfer(id);
      await _loadTransfers();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> cancelTransfer(String id) async {
    try {
      await _repository.cancelTransfer(id);
      await _loadTransfers();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadTransfers();
  }
}

/// Warehouse Transfer Notifier Provider
final warehouseTransferNotifierProvider = StateNotifierProvider<WarehouseTransferNotifier, AsyncValue<List<WarehouseTransfer>>>((ref) {
  final repository = ref.read(warehouseTransferRepositoryProvider);
  return WarehouseTransferNotifier(repository);
});
