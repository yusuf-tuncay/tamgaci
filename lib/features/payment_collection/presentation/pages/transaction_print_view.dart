// ========== TRANSACTION PRINT VIEW ==========
// lib/features/payment_collection/presentation/pages/transaction_print_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment_transaction.dart';
import '../../domain/entities/payment_enums.dart';
import '../providers/payment_collection_providers.dart';

/// Tahsilat ve ödeme işlemi yazdırma görünümü
class TransactionPrintView extends ConsumerStatefulWidget {
  final String transactionId;
  final bool isPreview;

  const TransactionPrintView({
    super.key,
    required this.transactionId,
    this.isPreview = true,
  });

  @override
  ConsumerState<TransactionPrintView> createState() =>
      _TransactionPrintViewState();
}

class _TransactionPrintViewState extends ConsumerState<TransactionPrintView> {
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
        appBar: AppBar(title: const Text('Yazdırma Önizleme')),
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
            ],
          ),
        ),
      );
    }

    final transaction = state.selectedTransaction;
    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yazdırma Önizleme')),
        body: const Center(
          child: Text('İşlem bulunamadı'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yazdırma Önizleme'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printDocument(transaction),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadPDF(transaction),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: 600,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _buildPrintDocument(transaction, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildPrintDocument(PaymentTransaction transaction, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Column(
            children: [
              Text(
                'TAMGACI',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tahsilat ve Ödeme Belgesi',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),

        // İçerik
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // İşlem bilgileri
              _buildSection(
                'İşlem Bilgileri',
                [
                  _buildInfoRow('İşlem No', transaction.transactionNumber),
                  _buildInfoRow(
                      'Tarih', _formatDate(transaction.transactionDate)),
                  _buildInfoRow(
                      'Tür', _getTransactionTypeText(transaction.type)),
                  _buildInfoRow(
                      'Kategori', _getCategoryText(transaction.category)),
                  _buildInfoRow(
                      'Yön', _getDirectionText(transaction.direction)),
                  _buildInfoRow('Durum', _getStatusText(transaction.status)),
                  if (transaction.dueDate != null)
                    _buildInfoRow(
                        'Vade Tarihi', _formatDate(transaction.dueDate!)),
                ],
              ),

              const SizedBox(height: 24),

              // Tutar bilgileri
              _buildSection(
                'Tutar Bilgileri',
                [
                  _buildInfoRow(
                      'Tutar', '${transaction.amount} ${transaction.currency}'),
                  _buildInfoRow('Para Birimi', transaction.currency),
                ],
              ),

              const SizedBox(height: 24),

              // İlişkili taraflar
              if (transaction.customerId != null ||
                  transaction.supplierId != null)
                _buildSection(
                  'İlişkili Taraflar',
                  [
                    if (transaction.customerId != null)
                      _buildInfoRow(
                          'Müşteri', 'Müşteri ID: ${transaction.customerId}'),
                    if (transaction.supplierId != null)
                      _buildInfoRow('Tedarikçi',
                          'Tedarikçi ID: ${transaction.supplierId}'),
                    if (transaction.revenueId != null)
                      _buildInfoRow(
                          'Gelir Fişi', 'Gelir ID: ${transaction.revenueId}'),
                    if (transaction.expenseId != null)
                      _buildInfoRow(
                          'Gider Fişi', 'Gider ID: ${transaction.expenseId}'),
                  ],
                ),

              const SizedBox(height: 24),

              // Hesap bilgileri
              _buildSection(
                'Hesap Bilgileri',
                [
                  _buildInfoRow('Hesap', 'Hesap ID: ${transaction.accountId}'),
                  if (transaction.targetAccountId != null)
                    _buildInfoRow('Hedef Hesap',
                        'Hedef ID: ${transaction.targetAccountId}'),
                  _buildInfoRow('Ödeme Yöntemi',
                      'Yöntem ID: ${transaction.paymentMethodId}'),
                  if (transaction.paymentSourceId != null)
                    _buildInfoRow('Ödeme Kaynağı',
                        'Kaynak ID: ${transaction.paymentSourceId}'),
                ],
              ),

              const SizedBox(height: 24),

              // Açıklama ve notlar
              if (transaction.description != null || transaction.notes != null)
                _buildSection(
                  'Açıklama ve Notlar',
                  [
                    if (transaction.description != null)
                      _buildInfoRow('Açıklama', transaction.description!),
                    if (transaction.notes != null)
                      _buildInfoRow('Notlar', transaction.notes!),
                    if (transaction.referenceNumber != null)
                      _buildInfoRow(
                          'Referans No', transaction.referenceNumber!),
                  ],
                ),

              const SizedBox(height: 24),

              // Belge bilgileri
              if (transaction.relatedDocumentId != null)
                _buildSection(
                  'Belge Bilgileri',
                  [
                    _buildInfoRow('Belge ID', transaction.relatedDocumentId!),
                    if (transaction.relatedDocumentType != null)
                      _buildInfoRow(
                          'Belge Türü', transaction.relatedDocumentType!),
                  ],
                ),

              const SizedBox(height: 24),

              // Ek bilgiler
              _buildSection(
                'Ek Bilgiler',
                [
                  _buildInfoRow(
                      'Oluşturulma', _formatDateTime(transaction.createdAt)),
                  _buildInfoRow(
                      'Güncellenme', _formatDateTime(transaction.updatedAt)),
                  _buildInfoRow('Oluşturan', transaction.createdBy),
                  if (transaction.updatedBy != null)
                    _buildInfoRow('Güncelleyen', transaction.updatedBy!),
                  if (transaction.attachments.isNotEmpty)
                    _buildInfoRow(
                        'Ekler', '${transaction.attachments.length} dosya'),
                ],
              ),
            ],
          ),
        ),

        // Alt bilgi
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Belge Tarihi: ${_formatDate(DateTime.now())}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Sayfa 1/1',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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

  void _printDocument(PaymentTransaction transaction) {
    // Yazdırma işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yazdırma işlemi başlatılıyor...')),
    );
  }

  void _downloadPDF(PaymentTransaction transaction) {
    // PDF indirme işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF indirme işlemi başlatılıyor...')),
    );
  }
}
