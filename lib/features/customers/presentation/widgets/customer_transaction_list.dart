// ========== CUSTOMER TRANSACTION LIST ==========
// lib/features/customers/presentation/widgets/customer_transaction_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tamgaci/core/services/business/transaction_service.dart';
import 'package:tamgaci/core/theme/constants.dart';
import 'package:tamgaci/core/utils/currency_helper.dart';
import 'package:tamgaci/features/customers/data/services/customer_transaction_service.dart';

/// Müşteri işlem listesi widget'ı
class CustomerTransactionList extends ConsumerWidget {
  final String customerId;
  final String customerName;

  const CustomerTransactionList({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionService = CustomerTransactionService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(
                Icons.history,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'İşlem Geçmişi',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: TamgaciConstants.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showTransactionSummary(context, customerId),
                icon: const Icon(Icons.analytics_outlined, size: 16),
                label: const Text('Özet'),
              ),
            ],
          ),
        ),

        // İşlem listesi
        Expanded(
          child: StreamBuilder<List<Transaction>>(
            stream: transactionService.watchCustomerTransactions(customerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'İşlem geçmişi yüklenirken hata oluştu',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final transactions = snapshot.data ?? [];

              if (transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz işlem kaydı bulunmuyor',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionCard(context, transaction);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// İşlem kartı oluşturma
  Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
    final isPositive = _isPositiveTransaction(transaction.type);
    final amountColor = isPositive ? Colors.green[600] : Colors.red[600];
    final amountPrefix = isPositive ? '+' : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTransactionTypeColor(transaction.type),
          child: Icon(
            _getTransactionTypeIcon(transaction.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          _getTransactionTypeDisplayName(transaction.type),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description != null) ...[
              const SizedBox(height: 2),
              Text(
                transaction.description!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: TamgaciConstants.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: TamgaciConstants.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm')
                      .format(transaction.transactionDate),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: TamgaciConstants.textSecondary,
                  ),
                ),
                if (transaction.reference != null) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.tag,
                    size: 12,
                    color: TamgaciConstants.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    transaction.reference!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$amountPrefix${CurrencyHelper.formatCurrency(transaction.amount, transaction.currency)}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: amountColor,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusDisplayName(transaction.status),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(context, transaction),
      ),
    );
  }

  /// Pozitif işlem kontrolü
  bool _isPositiveTransaction(TransactionType type) {
    switch (type) {
      case TransactionType.payment:
      case TransactionType.refund:
      case TransactionType.credit:
        return true;
      case TransactionType.sale:
      case TransactionType.invoice:
      case TransactionType.debit:
        return false;
      default:
        return false;
    }
  }

  /// İşlem türü rengi
  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
      case TransactionType.invoice:
        return Colors.blue[600]!;
      case TransactionType.payment:
        return Colors.green[600]!;
      case TransactionType.refund:
      case TransactionType.credit:
        return Colors.orange[600]!;
      case TransactionType.purchase:
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  /// İşlem türü ikonu
  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
      case TransactionType.invoice:
        return Icons.shopping_cart;
      case TransactionType.payment:
        return Icons.payment;
      case TransactionType.refund:
        return Icons.undo;
      case TransactionType.credit:
        return Icons.add_circle;
      case TransactionType.purchase:
        return Icons.shopping_bag;
      default:
        return Icons.receipt;
    }
  }

  /// İşlem türü görünen adı
  String _getTransactionTypeDisplayName(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return 'Satış';
      case TransactionType.invoice:
        return 'Fatura';
      case TransactionType.payment:
        return 'Ödeme';
      case TransactionType.refund:
        return 'İade';
      case TransactionType.credit:
        return 'Kredi';
      case TransactionType.purchase:
        return 'Alış';
      case TransactionType.debit:
        return 'Borç';
      case TransactionType.proforma:
        return 'Proforma';
      case TransactionType.waybill:
        return 'İrsaliye';
      case TransactionType.expense:
        return 'Gider';
      case TransactionType.income:
        return 'Gelir';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.stockIn:
        return 'Stok Girişi';
      case TransactionType.stockOut:
        return 'Stok Çıkışı';
      case TransactionType.adjustment:
        return 'Düzeltme';
    }
  }

  /// Durum rengi
  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
      case TransactionStatus.paid:
        return Colors.green[600]!;
      case TransactionStatus.pending:
        return Colors.orange[600]!;
      case TransactionStatus.overdue:
        return Colors.red[600]!;
      case TransactionStatus.cancelled:
        return Colors.grey[600]!;
      case TransactionStatus.partial:
        return Colors.blue[600]!;
    }
  }

  /// Durum görünen adı
  String _getStatusDisplayName(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return 'Tamamlandı';
      case TransactionStatus.paid:
        return 'Ödendi';
      case TransactionStatus.pending:
        return 'Beklemede';
      case TransactionStatus.overdue:
        return 'Vadesi Geçti';
      case TransactionStatus.cancelled:
        return 'İptal';
      case TransactionStatus.partial:
        return 'Kısmi';
    }
  }

  /// İşlem özeti gösterme
  void _showTransactionSummary(BuildContext context, String customerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'İşlem Özeti',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: FutureBuilder<Map<String, dynamic>>(
          future: CustomerTransactionService()
              .getCustomerTransactionSummary(customerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Hata: ${snapshot.error}');
            }

            final summary = snapshot.data ?? {};

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSummaryRow(
                    'Toplam Satış', summary['totalSales'] ?? 0.0, 'TRY'),
                _buildSummaryRow(
                    'Toplam Ödeme', summary['totalPayments'] ?? 0.0, 'TRY'),
                _buildSummaryRow(
                    'Toplam İade', summary['totalRefunds'] ?? 0.0, 'TRY'),
                const Divider(),
                _buildSummaryRow(
                  'Mevcut Bakiye',
                  summary['currentBalance'] ?? 0.0,
                  'TRY',
                  isBalance: true,
                ),
                _buildSummaryRow(
                    'İşlem Sayısı', summary['transactionCount'] ?? 0, 'adet'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  /// Özet satırı oluşturma
  Widget _buildSummaryRow(String label, dynamic value, String unit,
      {bool isBalance = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isBalance ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            unit == 'TRY'
                ? CurrencyHelper.formatCurrency(value, unit)
                : '$value $unit',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isBalance ? FontWeight.w600 : FontWeight.normal,
              color: isBalance && value < 0 ? Colors.red[600] : null,
            ),
          ),
        ],
      ),
    );
  }

  /// İşlem detayları gösterme
  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getTransactionTypeDisplayName(transaction.type),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                'Tutar',
                CurrencyHelper.formatCurrency(
                    transaction.amount, transaction.currency)),
            _buildDetailRow(
                'Tarih',
                DateFormat('dd.MM.yyyy HH:mm')
                    .format(transaction.transactionDate)),
            if (transaction.dueDate != null)
              _buildDetailRow('Vade Tarihi',
                  DateFormat('dd.MM.yyyy').format(transaction.dueDate!)),
            if (transaction.description != null)
              _buildDetailRow('Açıklama', transaction.description!),
            if (transaction.reference != null)
              _buildDetailRow('Referans', transaction.reference!),
            if (transaction.documentNumber != null)
              _buildDetailRow('Belge No', transaction.documentNumber!),
            if (transaction.paymentMethod != null)
              _buildDetailRow('Ödeme Yöntemi', transaction.paymentMethod!),
            _buildDetailRow('Durum', _getStatusDisplayName(transaction.status)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  /// Detay satırı oluşturma
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
