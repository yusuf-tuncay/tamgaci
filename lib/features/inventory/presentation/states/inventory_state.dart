import 'package:equatable/equatable.dart';
import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';
import 'package:tamgaci/features/inventory/domain/entities/inventory_movement.dart';

/// Inventory state
class InventoryState extends Equatable {
  final List<InventoryItem> inventoryItems;
  final List<InventoryMovement> inventoryMovements;
  final InventoryItem? selectedInventoryItem;
  final InventoryMovement? selectedInventoryMovement;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? inventoryItemsStatistics;
  final Map<String, dynamic>? inventoryMovementsStatistics;
  final Map<String, dynamic>? inventoryItemsReport;
  final Map<String, dynamic>? inventoryMovementsReport;
  final List<Map<String, dynamic>> topMovedItems;
  final List<Map<String, dynamic>> topLocations;

  const InventoryState({
    this.inventoryItems = const [],
    this.inventoryMovements = const [],
    this.selectedInventoryItem,
    this.selectedInventoryMovement,
    this.isLoading = false,
    this.error,
    this.inventoryItemsStatistics,
    this.inventoryMovementsStatistics,
    this.inventoryItemsReport,
    this.inventoryMovementsReport,
    this.topMovedItems = const [],
    this.topLocations = const [],
  });

  InventoryState copyWith({
    List<InventoryItem>? inventoryItems,
    List<InventoryMovement>? inventoryMovements,
    InventoryItem? selectedInventoryItem,
    InventoryMovement? selectedInventoryMovement,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? inventoryItemsStatistics,
    Map<String, dynamic>? inventoryMovementsStatistics,
    Map<String, dynamic>? inventoryItemsReport,
    Map<String, dynamic>? inventoryMovementsReport,
    List<Map<String, dynamic>>? topMovedItems,
    List<Map<String, dynamic>>? topLocations,
  }) {
    return InventoryState(
      inventoryItems: inventoryItems ?? this.inventoryItems,
      inventoryMovements: inventoryMovements ?? this.inventoryMovements,
      selectedInventoryItem:
          selectedInventoryItem ?? this.selectedInventoryItem,
      selectedInventoryMovement:
          selectedInventoryMovement ?? this.selectedInventoryMovement,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      inventoryItemsStatistics:
          inventoryItemsStatistics ?? this.inventoryItemsStatistics,
      inventoryMovementsStatistics:
          inventoryMovementsStatistics ?? this.inventoryMovementsStatistics,
      inventoryItemsReport: inventoryItemsReport ?? this.inventoryItemsReport,
      inventoryMovementsReport:
          inventoryMovementsReport ?? this.inventoryMovementsReport,
      topMovedItems: topMovedItems ?? this.topMovedItems,
      topLocations: topLocations ?? this.topLocations,
    );
  }

  @override
  List<Object?> get props => [
        inventoryItems,
        inventoryMovements,
        selectedInventoryItem,
        selectedInventoryMovement,
        isLoading,
        error,
        inventoryItemsStatistics,
        inventoryMovementsStatistics,
        inventoryItemsReport,
        inventoryMovementsReport,
        topMovedItems,
        topLocations,
      ];
}
