import 'package:flutter/material.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';

/// Satış detay kartı widget'ı
class SaleDetailCard extends StatelessWidget {
  final Sale sale;

  const SaleDetailCard({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        sale.customerName ?? sale.customerId,
                        style: TextStyle(
                          fontSize: 16.0,
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
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      _formatDate(sale.saleDate),
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Satış Durumu',
                    sale.status.displayName,
                    _getStatusColor(sale.status),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildInfoItem(
                    'Ödeme Durumu',
                    sale.paymentStatus.displayName,
                    _getPaymentStatusColor(sale.paymentStatus),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Satış Türü',
                    sale.type.displayName,
                    Colors.blue.shade300,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildInfoItem(
                    'Ürün Sayısı',
                    '${sale.items.length}',
                    Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            if (sale.dueDate != null) ...[
              const SizedBox(height: 16.0),
              _buildInfoItem(
                'Vade Tarihi',
                _formatDate(sale.dueDate!),
                Colors.orange.shade300,
              ),
            ],
            if (sale.notes != null && sale.notes!.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              _buildInfoItem(
                'Notlar',
                sale.notes!,
                Colors.grey.shade300,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SaleStatus status) {
    switch (status) {
      case SaleStatus.draft:
        return Colors.grey.shade600;
      case SaleStatus.pending:
        return Colors.orange.shade600;
      case SaleStatus.confirmed:
        return Colors.blue.shade600;
      case SaleStatus.shipped:
        return Colors.orange.shade600;
      case SaleStatus.delivered:
        return Colors.green.shade600;
      case SaleStatus.paid:
        return Colors.green.shade700;
      case SaleStatus.cancelled:
        return Colors.red.shade600;
      case SaleStatus.returned:
        return Colors.purple.shade600;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange.shade600;
      case PaymentStatus.partial:
        return Colors.yellow.shade600;
      case PaymentStatus.paid:
        return Colors.green.shade600;
      case PaymentStatus.overdue:
        return Colors.red.shade600;
      case PaymentStatus.refunded:
        return Colors.purple.shade600;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
