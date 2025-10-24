// ========== TRANSACTION LIST ITEM ==========
// lib/features/payment_collection/presentation/widgets/transaction_list_item.dart

import 'package:flutter/material.dart';
import '../../domain/entities/payment_transaction.dart';
import '../../domain/entities/payment_enums.dart';

/// İşlem listesi öğesi widget'ı
class TransactionListItem extends StatelessWidget {
  final PaymentTransaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onPrint;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onPrint,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDeleted = transaction.isDeleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDeleted ? theme.colorScheme.surfaceContainerHighest : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır - Tarih ve durum
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(transaction.transactionDate),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          isDeleted ? theme.colorScheme.onSurfaceVariant : null,
                    ),
                  ),
                  _buildStatusChip(theme, isDeleted),
                ],
              ),

              const SizedBox(height: 8),

              // Orta satır - Açıklama ve tutar
              Row(
                children: [
                  Expanded(
                    child: Text(
                      transaction.description ?? 'Açıklama yok',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDeleted
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${transaction.amount} ${transaction.currency}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getAmountColor(theme, transaction.direction),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Alt satır - Müşteri/Tedarikçi ve ödeme yöntemi
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _getRelatedPartyText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDeleted
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _getPaymentMethodText(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          isDeleted ? theme.colorScheme.onSurfaceVariant : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Butonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: isDeleted ? null : onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Düzenle'),
                    ),
                  const SizedBox(width: 8),
                  if (onPrint != null)
                    TextButton.icon(
                      onPressed: onPrint,
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Yazdır'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, bool isDeleted) {
    Color chipColor;
    String statusText;

    if (isDeleted) {
      chipColor = theme.colorScheme.outline;
      statusText = 'Silinmiş';
    } else {
      switch (transaction.status) {
        case PaymentTransactionStatus.pending:
          chipColor = Colors.orange;
          statusText = 'Beklemede';
          break;
        case PaymentTransactionStatus.processing:
          chipColor = Colors.blue;
          statusText = 'İşleniyor';
          break;
        case PaymentTransactionStatus.completed:
          chipColor = Colors.green;
          statusText = 'Tamamlandı';
          break;
        case PaymentTransactionStatus.approved:
          chipColor = Colors.green;
          statusText = 'Onaylandı';
          break;
        case PaymentTransactionStatus.rejected:
          chipColor = Colors.red;
          statusText = 'Reddedildi';
          break;
        case PaymentTransactionStatus.failed:
          chipColor = Colors.red;
          statusText = 'Başarısız';
          break;
        case PaymentTransactionStatus.cancelled:
          chipColor = Colors.red;
          statusText = 'İptal';
          break;
        case PaymentTransactionStatus.reversed:
          chipColor = Colors.orange;
          statusText = 'Geri Alındı';
          break;
        case PaymentTransactionStatus.refunded:
          chipColor = Colors.purple;
          statusText = 'İade Edildi';
          break;
        case PaymentTransactionStatus.disputed:
          chipColor = Colors.yellow;
          statusText = 'İtiraz Edildi';
          break;
        case PaymentTransactionStatus.onHold:
          chipColor = Colors.amber;
          statusText = 'Bekletildi';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getAmountColor(ThemeData theme, PaymentDirection direction) {
    switch (direction) {
      case PaymentDirection.incoming:
        return Colors.green;
      case PaymentDirection.outgoing:
        return Colors.red;
    }
  }

  String _getRelatedPartyText() {
    if (transaction.customerId != null) {
      return 'Müşteri: ${transaction.customerId}';
    } else if (transaction.supplierId != null) {
      return 'Tedarikçi: ${transaction.supplierId}';
    } else if (transaction.revenueId != null) {
      return 'Gelir Fişi: ${transaction.revenueId}';
    } else if (transaction.expenseId != null) {
      return 'Gider Fişi: ${transaction.expenseId}';
    } else {
      return 'İç Transfer';
    }
  }

  String _getPaymentMethodText() {
    switch (transaction.type) {
      case PaymentTransactionType.cash:
        return 'Nakit';
      case PaymentTransactionType.creditCard:
        return 'Kredi Kartı';
      case PaymentTransactionType.eftTransfer:
        return 'EFT/Havale';
      case PaymentTransactionType.check:
        return 'Çek';
      case PaymentTransactionType.promissoryNote:
        return 'Senet';
      case PaymentTransactionType.debtReceipt:
        return 'Borç Fişi';
      case PaymentTransactionType.creditReceipt:
        return 'Alacak Fişi';
      case PaymentTransactionType.accountTransfer:
        return 'Hesap Transferi';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
