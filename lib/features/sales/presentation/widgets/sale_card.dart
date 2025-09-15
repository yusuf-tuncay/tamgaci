import 'package:flutter/material.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';

/// Satış kartı widget'ı
class SaleCard extends StatelessWidget {
  final Sale sale;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const SaleCard({
    super.key,
    required this.sale,
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
                          sale.saleNumber,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          sale.customerName ?? sale.customerId,
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
                        '₺${sale.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        _formatDate(sale.saleDate),
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
                  _buildStatusChip(sale.status),
                  const SizedBox(width: 8.0),
                  _buildPaymentStatusChip(sale.paymentStatus),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${sale.items.length} ürün',
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

  Widget _buildStatusChip(SaleStatus status) {
    return Chip(
      label: Text(
        status.displayName,
        style: const TextStyle(fontSize: 12.0),
      ),
      backgroundColor: _getStatusColor(status),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPaymentStatusChip(PaymentStatus status) {
    return Chip(
      label: Text(
        status.displayName,
        style: const TextStyle(fontSize: 12.0),
      ),
      backgroundColor: _getPaymentStatusColor(status),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getStatusColor(SaleStatus status) {
    switch (status) {
      case SaleStatus.draft:
        return Colors.grey.shade300;
      case SaleStatus.pending:
        return Colors.orange.shade300;
      case SaleStatus.confirmed:
        return Colors.blue.shade300;
      case SaleStatus.shipped:
        return Colors.orange.shade300;
      case SaleStatus.delivered:
        return Colors.green.shade300;
      case SaleStatus.paid:
        return Colors.green.shade400;
      case SaleStatus.cancelled:
        return Colors.red.shade300;
      case SaleStatus.returned:
        return Colors.purple.shade300;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange.shade300;
      case PaymentStatus.partial:
        return Colors.yellow.shade300;
      case PaymentStatus.paid:
        return Colors.green.shade300;
      case PaymentStatus.overdue:
        return Colors.red.shade300;
      case PaymentStatus.refunded:
        return Colors.purple.shade300;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
