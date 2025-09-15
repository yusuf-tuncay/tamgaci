import 'package:flutter/material.dart';
import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';

/// Satın alma kartı widget'ı
class PurchaseCard extends StatelessWidget {
  final Purchase purchase;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const PurchaseCard({
    super.key,
    required this.purchase,
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
                          purchase.purchaseNumber,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          purchase.supplierName ?? purchase.supplierId,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₺${purchase.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        _formatDate(purchase.purchaseDate),
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
                  _buildStatusChip(purchase.status),
                  const SizedBox(width: 8.0),
                  _buildPaymentStatusChip(purchase.paymentStatus),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${purchase.items.length} ürün',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
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

  Widget _buildStatusChip(PurchaseStatus status) {
    return Chip(
      label: Text(
        status.displayName,
        style: const TextStyle(fontSize: 12.0),
      ),
      backgroundColor: _getStatusColor(status),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPaymentStatusChip(PurchasePaymentStatus status) {
    return Chip(
      label: Text(
        status.displayName,
        style: const TextStyle(fontSize: 12.0),
      ),
      backgroundColor: _getPaymentStatusColor(status),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getStatusColor(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.draft:
        return Colors.grey.shade300;
      case PurchaseStatus.pending:
        return Colors.orange.shade300;
      case PurchaseStatus.confirmed:
        return Colors.blue.shade300;
      case PurchaseStatus.received:
        return Colors.green.shade300;
      case PurchaseStatus.paid:
        return Colors.green.shade300;
      case PurchaseStatus.cancelled:
        return Colors.red.shade300;
      case PurchaseStatus.returned:
        return Colors.purple.shade300;
    }
  }

  Color _getPaymentStatusColor(PurchasePaymentStatus status) {
    switch (status) {
      case PurchasePaymentStatus.pending:
        return Colors.orange.shade300;
      case PurchasePaymentStatus.partial:
        return Colors.yellow.shade300;
      case PurchasePaymentStatus.paid:
        return Colors.green.shade300;
      case PurchasePaymentStatus.overdue:
        return Colors.red.shade300;
      case PurchasePaymentStatus.refunded:
        return Colors.purple.shade300;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
