import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/features/inventory/data/datasources/inventory_item_firebase_datasource.dart';
import 'package:tamgaci/features/inventory/data/datasources/inventory_movement_firebase_datasource.dart';
import 'package:tamgaci/features/inventory/data/repositories/inventory_item_repository_impl.dart';
import 'package:tamgaci/features/inventory/data/repositories/inventory_movement_repository_impl.dart';
import 'package:tamgaci/features/inventory/domain/usecases/create_inventory_item_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/get_inventory_items_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/get_inventory_item_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/update_inventory_item_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/delete_inventory_item_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/get_inventory_items_statistics_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/duplicate_inventory_item_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/create_inventory_movement_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/get_inventory_movements_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/get_inventory_movement_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/update_inventory_movement_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/delete_inventory_movement_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/get_inventory_movements_statistics_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/duplicate_inventory_movement_usecase.dart';
import 'package:tamgaci/features/inventory/presentation/notifiers/inventory_notifier.dart';
import 'package:tamgaci/features/inventory/presentation/states/inventory_state.dart';

/// Firebase Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Inventory Item Firebase DataSource provider
final inventoryItemFirebaseDataSourceProvider =
    Provider<InventoryItemFirebaseDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return InventoryItemFirebaseDataSource(firestore, firebaseAuth);
});

/// Inventory Movement Firebase DataSource provider
final inventoryMovementFirebaseDataSourceProvider =
    Provider<InventoryMovementFirebaseDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return InventoryMovementFirebaseDataSource(firestore, firebaseAuth);
});

/// Inventory Item Repository provider
final inventoryItemRepositoryProvider =
    Provider<InventoryItemRepositoryImpl>((ref) {
  final dataSource = ref.watch(inventoryItemFirebaseDataSourceProvider);
  return InventoryItemRepositoryImpl(dataSource: dataSource);
});

/// Inventory Movement Repository provider
final inventoryMovementRepositoryProvider =
    Provider<InventoryMovementRepositoryImpl>((ref) {
  final dataSource = ref.watch(inventoryMovementFirebaseDataSourceProvider);
  return InventoryMovementRepositoryImpl(dataSource: dataSource);
});

/// Create Inventory Item UseCase provider
final createInventoryItemUseCaseProvider =
    Provider<CreateInventoryItemUseCase>((ref) {
  final repository = ref.watch(inventoryItemRepositoryProvider);
  return CreateInventoryItemUseCase(repository);
});

/// Get Inventory Items UseCase provider
final getInventoryItemsUseCaseProvider =
    Provider<GetInventoryItemsUseCase>((ref) {
  final repository = ref.watch(inventoryItemRepositoryProvider);
  return GetInventoryItemsUseCase(repository);
});

/// Get Inventory Item UseCase provider
final getInventoryItemUseCaseProvider =
    Provider<GetInventoryItemUseCase>((ref) {
  final repository = ref.watch(inventoryItemRepositoryProvider);
  return GetInventoryItemUseCase(repository);
});

/// Update Inventory Item UseCase provider
final updateInventoryItemUseCaseProvider =
    Provider<UpdateInventoryItemUseCase>((ref) {
  final repository = ref.watch(inventoryItemRepositoryProvider);
  return UpdateInventoryItemUseCase(repository);
});

/// Delete Inventory Item UseCase provider
final deleteInventoryItemUseCaseProvider =
    Provider<DeleteInventoryItemUseCase>((ref) {
  final repository = ref.watch(inventoryItemRepositoryProvider);
  return DeleteInventoryItemUseCase(repository);
});

/// Get Inventory Items Statistics UseCase provider
final getInventoryItemsStatisticsUseCaseProvider =
    Provider<GetInventoryItemsStatisticsUseCase>((ref) {
  final repository = ref.watch(inventoryItemRepositoryProvider);
  return GetInventoryItemsStatisticsUseCase(repository);
});

/// Duplicate Inventory Item UseCase provider
final duplicateInventoryItemUseCaseProvider =
    Provider<DuplicateInventoryItemUseCase>((ref) {
  final repository = ref.watch(inventoryItemRepositoryProvider);
  return DuplicateInventoryItemUseCase(repository);
});

/// Create Inventory Movement UseCase provider
final createInventoryMovementUseCaseProvider =
    Provider<CreateInventoryMovementUseCase>((ref) {
  final repository = ref.watch(inventoryMovementRepositoryProvider);
  return CreateInventoryMovementUseCase(repository);
});

/// Get Inventory Movements UseCase provider
final getInventoryMovementsUseCaseProvider =
    Provider<GetInventoryMovementsUseCase>((ref) {
  final repository = ref.watch(inventoryMovementRepositoryProvider);
  return GetInventoryMovementsUseCase(repository);
});

/// Get Inventory Movement UseCase provider
final getInventoryMovementUseCaseProvider =
    Provider<GetInventoryMovementUseCase>((ref) {
  final repository = ref.watch(inventoryMovementRepositoryProvider);
  return GetInventoryMovementUseCase(repository);
});

/// Update Inventory Movement UseCase provider
final updateInventoryMovementUseCaseProvider =
    Provider<UpdateInventoryMovementUseCase>((ref) {
  final repository = ref.watch(inventoryMovementRepositoryProvider);
  return UpdateInventoryMovementUseCase(repository);
});

/// Delete Inventory Movement UseCase provider
final deleteInventoryMovementUseCaseProvider =
    Provider<DeleteInventoryMovementUseCase>((ref) {
  final repository = ref.watch(inventoryMovementRepositoryProvider);
  return DeleteInventoryMovementUseCase(repository);
});

/// Get Inventory Movements Statistics UseCase provider
final getInventoryMovementsStatisticsUseCaseProvider =
    Provider<GetInventoryMovementsStatisticsUseCase>((ref) {
  final repository = ref.watch(inventoryMovementRepositoryProvider);
  return GetInventoryMovementsStatisticsUseCase(repository);
});

/// Duplicate Inventory Movement UseCase provider
final duplicateInventoryMovementUseCaseProvider =
    Provider<DuplicateInventoryMovementUseCase>((ref) {
  final repository = ref.watch(inventoryMovementRepositoryProvider);
  return DuplicateInventoryMovementUseCase(repository);
});

/// Inventory Notifier provider
final inventoryNotifierProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  final createInventoryItemUseCase =
      ref.watch(createInventoryItemUseCaseProvider);
  final getInventoryItemsUseCase = ref.watch(getInventoryItemsUseCaseProvider);
  final getInventoryItemUseCase = ref.watch(getInventoryItemUseCaseProvider);
  final updateInventoryItemUseCase =
      ref.watch(updateInventoryItemUseCaseProvider);
  final deleteInventoryItemUseCase =
      ref.watch(deleteInventoryItemUseCaseProvider);
  final getInventoryItemsStatisticsUseCase =
      ref.watch(getInventoryItemsStatisticsUseCaseProvider);
  final duplicateInventoryItemUseCase =
      ref.watch(duplicateInventoryItemUseCaseProvider);
  final createInventoryMovementUseCase =
      ref.watch(createInventoryMovementUseCaseProvider);
  final getInventoryMovementsUseCase =
      ref.watch(getInventoryMovementsUseCaseProvider);
  final getInventoryMovementUseCase =
      ref.watch(getInventoryMovementUseCaseProvider);
  final updateInventoryMovementUseCase =
      ref.watch(updateInventoryMovementUseCaseProvider);
  final deleteInventoryMovementUseCase =
      ref.watch(deleteInventoryMovementUseCaseProvider);
  final getInventoryMovementsStatisticsUseCase =
      ref.watch(getInventoryMovementsStatisticsUseCaseProvider);
  final duplicateInventoryMovementUseCase =
      ref.watch(duplicateInventoryMovementUseCaseProvider);

  return InventoryNotifier(
    createInventoryItemUseCase: createInventoryItemUseCase,
    getInventoryItemsUseCase: getInventoryItemsUseCase,
    getInventoryItemUseCase: getInventoryItemUseCase,
    updateInventoryItemUseCase: updateInventoryItemUseCase,
    deleteInventoryItemUseCase: deleteInventoryItemUseCase,
    getInventoryItemsStatisticsUseCase: getInventoryItemsStatisticsUseCase,
    duplicateInventoryItemUseCase: duplicateInventoryItemUseCase,
    createInventoryMovementUseCase: createInventoryMovementUseCase,
    getInventoryMovementsUseCase: getInventoryMovementsUseCase,
    getInventoryMovementUseCase: getInventoryMovementUseCase,
    updateInventoryMovementUseCase: updateInventoryMovementUseCase,
    deleteInventoryMovementUseCase: deleteInventoryMovementUseCase,
    getInventoryMovementsStatisticsUseCase:
        getInventoryMovementsStatisticsUseCase,
    duplicateInventoryMovementUseCase: duplicateInventoryMovementUseCase,
  );
});
