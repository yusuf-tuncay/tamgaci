import 'package:flutter/material.dart';
import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';

/// Envanter öğesi filtreleme bottom sheet widget'ı
class InventoryItemFilterBottomSheet extends StatefulWidget {
  final InventoryItemType? selectedType;
  final InventoryItemStatus? selectedStatus;
  final String? selectedCategory;
  final String? selectedStockLevel;
  final Function(InventoryItemType?, InventoryItemStatus?, String?, String?)
      onFilterChanged;
  final VoidCallback onClearFilters;

  const InventoryItemFilterBottomSheet({
    super.key,
    this.selectedType,
    this.selectedStatus,
    this.selectedCategory,
    this.selectedStockLevel,
    required this.onFilterChanged,
    required this.onClearFilters,
  });

  @override
  State<InventoryItemFilterBottomSheet> createState() =>
      _InventoryItemFilterBottomSheetState();
}

class _InventoryItemFilterBottomSheetState
    extends State<InventoryItemFilterBottomSheet> {
  InventoryItemType? _selectedType;
  InventoryItemStatus? _selectedStatus;
  String? _selectedCategory;
  String? _selectedStockLevel;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedStatus = widget.selectedStatus;
    _selectedCategory = widget.selectedCategory;
    _selectedStockLevel = widget.selectedStockLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.0,
            height: 4.0,
            margin: const EdgeInsets.only(top: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtrele',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedType = null;
                          _selectedStatus = null;
                          _selectedCategory = null;
                          _selectedStockLevel = null;
                        });
                        widget.onClearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Temizle'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildTypeFilter(),
                const SizedBox(height: 16.0),
                _buildStatusFilter(),
                const SizedBox(height: 16.0),
                _buildStockLevelFilter(),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFilterChanged(_selectedType, _selectedStatus,
                          _selectedCategory, _selectedStockLevel);
                      Navigator.pop(context);
                    },
                    child: const Text('Filtrele'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Öğe Türü',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: InventoryItemType.values.map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = selected ? type : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Öğe Durumu',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: InventoryItemStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            return FilterChip(
              label: Text(status.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? status : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStockLevelFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stok Seviyesi',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: [
            FilterChip(
              label: const Text('Düşük Stok'),
              selected: _selectedStockLevel == 'low',
              onSelected: (selected) {
                setState(() {
                  _selectedStockLevel = selected ? 'low' : null;
                });
              },
            ),
            FilterChip(
              label: const Text('Normal Stok'),
              selected: _selectedStockLevel == 'normal',
              onSelected: (selected) {
                setState(() {
                  _selectedStockLevel = selected ? 'normal' : null;
                });
              },
            ),
            FilterChip(
              label: const Text('Yüksek Stok'),
              selected: _selectedStockLevel == 'high',
              onSelected: (selected) {
                setState(() {
                  _selectedStockLevel = selected ? 'high' : null;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
