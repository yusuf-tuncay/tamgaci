import 'package:flutter/material.dart';
import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';

/// Envanter öğesi kartı widget'ı
class InventoryItemCard extends StatelessWidget {
  final InventoryItem inventoryItem;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const InventoryItemCard({
    super.key,
    required this.inventoryItem,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inventoryItem.name,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        if (inventoryItem.sku != null)
                          Text(
                            'SKU: ${inventoryItem.sku}',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        if (inventoryItem.description != null)
                          Text(
                            inventoryItem.description!,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${inventoryItem.currentStock.toStringAsFixed(0)} ${inventoryItem.unit}',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: _getStockColor(inventoryItem.currentStock,
                              inventoryItem.reorderPoint),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${inventoryItem.unitPrice.toStringAsFixed(2)} ${inventoryItem.currency}',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  _buildTypeChip(inventoryItem.type),
                  const SizedBox(width: 8.0),
                  _buildStatusChip(inventoryItem.status),
                  if (inventoryItem.category != null) ...[
                    const SizedBox(width: 8.0),
                    _buildCategoryChip(inventoryItem.category!),
                  ],
                ],
              ),
              if (inventoryItem.brand != null ||
                  inventoryItem.location != null) ...[
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    if (inventoryItem.brand != null) ...[
                      Icon(Icons.branding_watermark,
                          size: 16.0, color: Colors.grey.shade600),
                      const SizedBox(width: 4.0),
                      Text(
                        inventoryItem.brand!,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (inventoryItem.location != null) ...[
                      const SizedBox(width: 16.0),
                      Icon(Icons.location_on,
                          size: 16.0, color: Colors.grey.shade600),
                      const SizedBox(width: 4.0),
                      Text(
                        inventoryItem.location!,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Min: ${inventoryItem.minimumStock.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Text(
                        'Max: ${inventoryItem.maximumStock.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20.0),
                          onPressed: onEdit,
                          tooltip: 'Düzenle',
                        ),
                      if (onDuplicate != null)
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20.0),
                          onPressed: onDuplicate,
                          tooltip: 'Kopyala',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete,
                              size: 20.0, color: Colors.red),
                          onPressed: onDelete,
                          tooltip: 'Sil',
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(InventoryItemType type) {
    return Chip(
      label: Text(
        type.displayName,
        style: const TextStyle(fontSize: 12.0),
      ),
      backgroundColor: _getTypeColor(type),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStatusChip(InventoryItemStatus status) {
    return Chip(
      label: Text(
        status.displayName,
        style: const TextStyle(fontSize: 12.0),
      ),
      backgroundColor: _getStatusColor(status),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildCategoryChip(String category) {
    return Chip(
      label: Text(
        category,
        style: const TextStyle(fontSize: 12.0),
      ),
      backgroundColor: Colors.blue.shade300,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getTypeColor(InventoryItemType type) {
    switch (type) {
      case InventoryItemType.product:
        return Colors.green.shade300;
      case InventoryItemType.material:
        return Colors.blue.shade300;
      case InventoryItemType.equipment:
        return Colors.orange.shade300;
      case InventoryItemType.consumable:
        return Colors.purple.shade300;
      case InventoryItemType.other:
        return Colors.grey.shade300;
    }
  }

  Color _getStatusColor(InventoryItemStatus status) {
    switch (status) {
      case InventoryItemStatus.active:
        return Colors.green.shade300;
      case InventoryItemStatus.inactive:
        return Colors.orange.shade300;
      case InventoryItemStatus.discontinued:
        return Colors.red.shade300;
      case InventoryItemStatus.outOfStock:
        return Colors.red.shade300;
    }
  }

  Color _getStockColor(double currentStock, double reorderPoint) {
    if (currentStock == 0) {
      return Colors.red;
    } else if (currentStock <= reorderPoint) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
