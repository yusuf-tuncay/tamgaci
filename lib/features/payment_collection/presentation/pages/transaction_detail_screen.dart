// ========== TRANSACTION DETAIL SCREEN ==========
// lib/features/payment_collection/presentation/pages/transaction_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment_transaction.dart';
import '../../domain/entities/payment_enums.dart';
import '../providers/payment_collection_providers.dart';
import '../widgets/transaction_detail_card.dart';
import 'transaction_form_screen.dart';

/// Tahsilat ve ödeme işlemi detay ekranı
class TransactionDetailScreen extends ConsumerStatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactionDetail();
    });
  }

  Future<void> _loadTransactionDetail() async {
    await ref
        .read(paymentCollectionStateProvider.notifier)
        .loadTransactionDetail(widget.transactionId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentCollectionStateProvider);
    final theme = Theme.of(context);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('İşlem Detayı')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTransactionDetail,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    final transaction = state.selectedTransaction;
    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('İşlem Detayı')),
        body: const Center(
          child: Text('İşlem bulunamadı'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('İşlem #${transaction.transactionNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTransaction(transaction),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printTransaction(transaction),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editTransaction(transaction);
                  break;
                case 'print':
                  _printTransaction(transaction);
                  break;
                case 'duplicate':
                  _duplicateTransaction(transaction);
                  break;
                case 'delete':
                  _deleteTransaction(transaction);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Düzenle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 8),
                    Text('Yazdır'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Kopyala'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('Sil'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İşlem özeti
            TransactionDetailCard(
              title: 'İşlem Özeti',
              children: [
                _buildDetailRow('İşlem No', transaction.transactionNumber),
                _buildDetailRow(
                    'Tür', _getTransactionTypeText(transaction.type)),
                _buildDetailRow(
                    'Kategori', _getCategoryText(transaction.category)),
                _buildDetailRow(
                    'Yön', _getDirectionText(transaction.direction)),
                _buildDetailRow('Durum', _getStatusText(transaction.status)),
                _buildDetailRow(
                    'Tarih', _formatDate(transaction.transactionDate)),
                if (transaction.dueDate != null)
                  _buildDetailRow(
                      'Vade Tarihi', _formatDate(transaction.dueDate!)),
                _buildDetailRow(
                    'Tutar', '${transaction.amount} ${transaction.currency}'),
                if (transaction.description != null)
                  _buildDetailRow('Açıklama', transaction.description!),
                if (transaction.referenceNumber != null)
                  _buildDetailRow('Referans No', transaction.referenceNumber!),
                if (transaction.notes != null)
                  _buildDetailRow('Notlar', transaction.notes!),
              ],
            ),

            const SizedBox(height: 16),

            // İlişkili taraflar
            TransactionDetailCard(
              title: 'İlişkili Taraflar',
              children: [
                if (transaction.customerId != null)
                  _buildDetailRow(
                      'Müşteri', 'Müşteri ID: ${transaction.customerId}'),
                if (transaction.supplierId != null)
                  _buildDetailRow(
                      'Tedarikçi', 'Tedarikçi ID: ${transaction.supplierId}'),
                if (transaction.revenueId != null)
                  _buildDetailRow(
                      'Gelir Fişi', 'Gelir ID: ${transaction.revenueId}'),
                if (transaction.expenseId != null)
                  _buildDetailRow(
                      'Gider Fişi', 'Gider ID: ${transaction.expenseId}'),
              ],
            ),

            const SizedBox(height: 16),

            // Hesap bilgileri
            TransactionDetailCard(
              title: 'Hesap Bilgileri',
              children: [
                _buildDetailRow('Hesap', 'Hesap ID: ${transaction.accountId}'),
                if (transaction.targetAccountId != null)
                  _buildDetailRow('Hedef Hesap',
                      'Hedef ID: ${transaction.targetAccountId}'),
                _buildDetailRow('Ödeme Yöntemi',
                    'Yöntem ID: ${transaction.paymentMethodId}'),
                if (transaction.paymentSourceId != null)
                  _buildDetailRow('Ödeme Kaynağı',
                      'Kaynak ID: ${transaction.paymentSourceId}'),
              ],
            ),

            const SizedBox(height: 16),

            // Belge bilgileri
            if (transaction.relatedDocumentId != null)
              TransactionDetailCard(
                title: 'Belge Bilgileri',
                children: [
                  _buildDetailRow('Belge ID', transaction.relatedDocumentId!),
                  if (transaction.relatedDocumentType != null)
                    _buildDetailRow(
                        'Belge Türü', transaction.relatedDocumentType!),
                ],
              ),

            const SizedBox(height: 16),

            // Ek bilgiler
            TransactionDetailCard(
              title: 'Ek Bilgiler',
              children: [
                _buildDetailRow(
                    'Oluşturulma', _formatDateTime(transaction.createdAt)),
                _buildDetailRow(
                    'Güncellenme', _formatDateTime(transaction.updatedAt)),
                _buildDetailRow('Oluşturan', transaction.createdBy),
                if (transaction.updatedBy != null)
                  _buildDetailRow('Güncelleyen', transaction.updatedBy!),
                if (transaction.attachments.isNotEmpty)
                  _buildDetailRow(
                      'Ekler', '${transaction.attachments.length} dosya'),
                if (transaction.metadata.isNotEmpty)
                  _buildDetailRow(
                      'Meta Veri', '${transaction.metadata.length} alan'),
              ],
            ),

            const SizedBox(height: 32),

            // İşlem butonları
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editTransaction(transaction),
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _printTransaction(transaction),
                    icon: const Icon(Icons.print),
                    label: const Text('Yazdır'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getTransactionTypeText(PaymentTransactionType type) {
    switch (type) {
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

  String _getCategoryText(PaymentTransactionCategory category) {
    switch (category) {
      case PaymentTransactionCategory.customerPayment:
        return 'Müşteri Tahsilatı';
      case PaymentTransactionCategory.supplierPayment:
        return 'Tedarikçi Ödemesi';
      case PaymentTransactionCategory.internalTransfer:
        return 'İç Transfer';
      case PaymentTransactionCategory.adjustment:
        return 'Düzeltme';
      case PaymentTransactionCategory.refund:
        return 'İade';
      case PaymentTransactionCategory.commission:
        return 'Komisyon';
      case PaymentTransactionCategory.interest:
        return 'Faiz';
      case PaymentTransactionCategory.penalty:
        return 'Ceza';
      case PaymentTransactionCategory.other:
        return 'Diğer';
    }
  }

  String _getDirectionText(PaymentDirection direction) {
    switch (direction) {
      case PaymentDirection.incoming:
        return 'Gelen';
      case PaymentDirection.outgoing:
        return 'Giden';
    }
  }

  String _getStatusText(PaymentTransactionStatus status) {
    switch (status) {
      case PaymentTransactionStatus.pending:
        return 'Beklemede';
      case PaymentTransactionStatus.processing:
        return 'İşleniyor';
      case PaymentTransactionStatus.completed:
        return 'Tamamlandı';
      case PaymentTransactionStatus.approved:
        return 'Onaylandı';
      case PaymentTransactionStatus.rejected:
        return 'Reddedildi';
      case PaymentTransactionStatus.failed:
        return 'Başarısız';
      case PaymentTransactionStatus.cancelled:
        return 'İptal Edildi';
      case PaymentTransactionStatus.reversed:
        return 'Geri Alındı';
      case PaymentTransactionStatus.refunded:
        return 'İade Edildi';
      case PaymentTransactionStatus.disputed:
        return 'İtiraz Edildi';
      case PaymentTransactionStatus.onHold:
        return 'Bekletildi';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _editTransaction(PaymentTransaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormScreen(
          direction: transaction.direction,
          transactionId: transaction.id,
        ),
      ),
    ).then((_) => _loadTransactionDetail());
  }

  void _printTransaction(PaymentTransaction transaction) {
    // PDF oluşturma işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yazdırma işlemi başlatılıyor...')),
    );
  }

  void _duplicateTransaction(PaymentTransaction transaction) {
    // Kopyalama işlemi
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormScreen(
          direction: transaction.direction,
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(PaymentTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşlemi Sil'),
        content: const Text('Bu işlemi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(paymentCollectionStateProvider.notifier)
          .deleteTransaction(transaction.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
