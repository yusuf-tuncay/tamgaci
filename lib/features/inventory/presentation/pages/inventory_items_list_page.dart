import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';
import 'package:tamgaci/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:tamgaci/features/inventory/presentation/widgets/inventory_item_card.dart';
import 'package:tamgaci/features/inventory/presentation/widgets/inventory_item_filter_bottom_sheet.dart';
import 'package:tamgaci/core/routes/routes.dart';
import 'package:tamgaci/core/widgets/loading_widget.dart';
import 'package:tamgaci/core/widgets/error_widget.dart' as core_widgets;
import 'package:tamgaci/features/inventory/presentation/states/inventory_state.dart';
import 'package:tamgaci/core/widgets/empty_state_widget.dart';
import 'package:tamgaci/core/widgets/search_bar_widget.dart';
import 'package:tamgaci/core/widgets/fab_widget.dart';

/// Envanter öğeleri listesi sayfası
class InventoryItemsListPage extends ConsumerStatefulWidget {
  const InventoryItemsListPage({super.key});

  @override
  ConsumerState<InventoryItemsListPage> createState() =>
      _InventoryItemsListPageState();
}

class _InventoryItemsListPageState
    extends ConsumerState<InventoryItemsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  InventoryItemType? _selectedType;
  InventoryItemStatus? _selectedStatus;
  String? _selectedCategory;
  String? _selectedStockLevel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInventoryItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadInventoryItems() {
    ref.read(inventoryNotifierProvider.notifier).getInventoryItems();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      _loadInventoryItems();
    } else {
      ref.read(inventoryNotifierProvider.notifier).searchInventoryItems(query);
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InventoryItemFilterBottomSheet(
        selectedType: _selectedType,
        selectedStatus: _selectedStatus,
        selectedCategory: _selectedCategory,
        selectedStockLevel: _selectedStockLevel,
        onFilterChanged: (type, status, category, stockLevel) {
          setState(() {
            _selectedType = type;
            _selectedStatus = status;
            _selectedCategory = category;
            _selectedStockLevel = stockLevel;
          });

          if (type != null) {
            ref
                .read(inventoryNotifierProvider.notifier)
                .getInventoryItemsByType(type);
          } else if (status != null) {
            ref
                .read(inventoryNotifierProvider.notifier)
                .getInventoryItemsByStatus(status);
          } else if (category != null) {
            ref
                .read(inventoryNotifierProvider.notifier)
                .getInventoryItemsByCategory(category);
          } else if (stockLevel != null) {
            ref
                .read(inventoryNotifierProvider.notifier)
                .getInventoryItemsByStockLevel(stockLevel);
          } else {
            _loadInventoryItems();
          }
        },
        onClearFilters: () {
          setState(() {
            _selectedType = null;
            _selectedStatus = null;
            _selectedCategory = null;
            _selectedStockLevel = null;
            _searchQuery = '';
            _searchController.clear();
          });
          _loadInventoryItems();
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _selectedCategory = null;
      _selectedStockLevel = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _loadInventoryItems();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryNotifierProvider);
    final hasFilters = _selectedType != null ||
        _selectedStatus != null ||
        _selectedCategory != null ||
        _selectedStockLevel != null ||
        _searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Envanter Öğeleri'),
        actions: [
          if (hasFilters)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Filtreleri Temizle',
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filtrele',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Envanter öğesi ara...',
              onChanged: _onSearchChanged,
            ),
          ),
          if (hasFilters)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedType != null)
                            Chip(
                              label: Text(_selectedType!.displayName),
                              onDeleted: () {
                                setState(() {
                                  _selectedType = null;
                                });
                                _loadInventoryItems();
                              },
                            ),
                          if (_selectedStatus != null)
                            Chip(
                              label: Text(_selectedStatus!.displayName),
                              onDeleted: () {
                                setState(() {
                                  _selectedStatus = null;
                                });
                                _loadInventoryItems();
                              },
                            ),
                          if (_selectedCategory != null)
                            Chip(
                              label: Text(_selectedCategory!),
                              onDeleted: () {
                                setState(() {
                                  _selectedCategory = null;
                                });
                                _loadInventoryItems();
                              },
                            ),
                          if (_selectedStockLevel != null)
                            Chip(
                              label: Text(_selectedStockLevel!),
                              onDeleted: () {
                                setState(() {
                                  _selectedStockLevel = null;
                                });
                                _loadInventoryItems();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _buildBody(inventoryState),
          ),
        ],
      ),
      floatingActionButton: FabWidget(
        onPressed: () {
          Navigator.pushNamed(context, TamgaciRoutes.createStock);
        },
        tooltip: 'Yeni Envanter Öğesi',
      ),
    );
  }

  Widget _buildBody(InventoryState state) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.error != null) {
      return core_widgets.ErrorWidget(
        error: state.error!,
        onRetry: _loadInventoryItems,
      );
    }

    if (state.inventoryItems.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: 'Envanter Öğesi Bulunamadı',
        message: _searchQuery.isNotEmpty ||
                _selectedType != null ||
                _selectedStatus != null ||
                _selectedCategory != null ||
                _selectedStockLevel != null
            ? 'Arama kriterlerinize uygun envanter öğesi bulunamadı.'
            : 'Henüz envanter öğesi kaydı bulunmuyor.\nYeni envanter öğesi oluşturmak için + butonuna tıklayın.',
        actionText: _searchQuery.isNotEmpty ||
                _selectedType != null ||
                _selectedStatus != null ||
                _selectedCategory != null ||
                _selectedStockLevel != null
            ? 'Filtreleri Temizle'
            : 'Yeni Envanter Öğesi',
        onAction: _searchQuery.isNotEmpty ||
                _selectedType != null ||
                _selectedStatus != null ||
                _selectedCategory != null ||
                _selectedStockLevel != null
            ? _clearFilters
            : () {
                Navigator.pushNamed(context, TamgaciRoutes.createStock);
              },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadInventoryItems();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.inventoryItems.length,
        itemBuilder: (context, index) {
          final inventoryItem = state.inventoryItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InventoryItemCard(
              inventoryItem: inventoryItem,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.stockDetail,
                  arguments: inventoryItem.id,
                );
              },
              onEdit: () {
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.editStock,
                  arguments: inventoryItem.id,
                );
              },
              onDelete: () {
                _showDeleteDialog(inventoryItem);
              },
              onDuplicate: () {
                _duplicateInventoryItem(inventoryItem.id);
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(InventoryItem inventoryItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envanter Öğesini Sil'),
        content: Text(
            '${inventoryItem.name} adlı envanter öğesini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteInventoryItem(inventoryItem.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _deleteInventoryItem(String id) {
    ref.read(inventoryNotifierProvider.notifier).deleteInventoryItem(id);
  }

  void _duplicateInventoryItem(String id) {
    ref.read(inventoryNotifierProvider.notifier).duplicateInventoryItem(id);
  }
}
