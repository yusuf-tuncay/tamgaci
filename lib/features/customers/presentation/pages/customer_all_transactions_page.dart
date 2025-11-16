// ========== CUSTOMER ALL TRANSACTIONS PAGE ==========
// lib/features/customers/presentation/pages/customer_all_transactions_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../cash_management/presentation/providers/cash_management_providers.dart';
import '../../../cash_management/domain/entities/cash_transaction.dart';
import '../../../../core/services/business/transaction_service.dart'
    show Transaction, TransactionService, TransactionType;
import '../../../../core/services/utils/export_service.dart';
import '../../../sales/presentation/providers/sale_providers.dart' as sales;
import '../../../payment_collection/domain/entities/payment_enums.dart';
import '../../../payment_collection/domain/entities/payment_transaction.dart';
import '../../../payment_collection/presentation/providers/payment_collection_providers.dart';
import '../providers/customer_providers.dart';

/// Müşteri tüm işlemler sayfası - Detaylı arama, filtreleme, sıralama
class CustomerAllTransactionsPage extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerAllTransactionsPage({
    super.key,
    required this.customerId,
  });

  @override
  ConsumerState<CustomerAllTransactionsPage> createState() =>
      _CustomerAllTransactionsPageState();
}

class _CustomerAllTransactionsPageState
    extends ConsumerState<CustomerAllTransactionsPage> {
  String _searchQuery = '';
  String _filterType =
      'all'; // all, invoice, payment, payment_transaction, transaction
  String _sortBy = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc

  Future<List<dynamic>> _loadCustomerTransactions(String customerId) async {
    try {
      final transactionService = TransactionService();
      final transactions =
          await transactionService.getCustomerTransactions(customerId);
      return transactions;
    } catch (e) {
      debugPrint('Error loading customer transactions: $e');
      rethrow;
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      final formats = [
        DateFormat('yyyy-MM-ddTHH:mm:ss'),
        DateFormat('yyyy-MM-dd HH:mm:ss'),
        DateFormat('dd.MM.yyyy HH:mm'),
        DateFormat('dd.MM.yyyy'),
        DateFormat('yyyy-MM-dd'),
      ];
      for (final format in formats) {
        try {
          return format.parse(value);
        } catch (_) {}
      }
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  List<Map<String, dynamic>> _getFilteredAndSortedItems(
    List<Map<String, dynamic>> allItems,
  ) {
    var filtered = allItems;

    // Tip filtresi
    if (_filterType != 'all') {
      filtered = filtered.where((item) => item['type'] == _filterType).toList();
    }

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final data = item['data'];
        final searchLower = _searchQuery.toLowerCase();

        // Her tip için arama
        if (item['type'] == 'invoice') {
          final saleNumber =
              (data['saleNumber'] as String? ?? '').toLowerCase();
          final invoiceNumber =
              (data['invoiceNumber'] as String? ?? '').toLowerCase();
          return saleNumber.contains(searchLower) ||
              invoiceNumber.contains(searchLower);
        } else if (item['type'] == 'payment') {
          final cashTx = data as CashTransaction;
          return cashTx.transactionNumber.toLowerCase().contains(searchLower) ||
              (cashTx.description ?? '').toLowerCase().contains(searchLower);
        } else if (item['type'] == 'payment_transaction') {
          final pt = data as PaymentTransaction;
          return pt.transactionNumber.toLowerCase().contains(searchLower) ||
              (pt.description ?? '').toLowerCase().contains(searchLower);
        } else {
          final desc = (data.description as String? ?? '').toLowerCase();
          final docNum = (data.documentNumber as String? ?? '').toLowerCase();
          return desc.contains(searchLower) || docNum.contains(searchLower);
        }
      }).toList();
    }

    // Sıralama
    filtered.sort((a, b) {
      final dateA = a['date'] as DateTime?;
      final dateB = b['date'] as DateTime?;

      if (_sortBy == 'date_desc') {
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      } else if (_sortBy == 'date_asc') {
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      } else if (_sortBy == 'amount_desc' || _sortBy == 'amount_asc') {
        double amountA = 0.0;
        double amountB = 0.0;

        if (a['type'] == 'invoice') {
          amountA = (a['data']['totalAmount'] as num?)?.toDouble() ?? 0.0;
        } else if (a['type'] == 'payment') {
          amountA = (a['data'] as CashTransaction).amount;
        } else if (a['type'] == 'payment_transaction') {
          amountA = (a['data'] as PaymentTransaction).amount;
        } else {
          amountA = (a['data'].amount as num?)?.toDouble() ?? 0.0;
        }

        if (b['type'] == 'invoice') {
          amountB = (b['data']['totalAmount'] as num?)?.toDouble() ?? 0.0;
        } else if (b['type'] == 'payment') {
          amountB = (b['data'] as CashTransaction).amount;
        } else if (b['type'] == 'payment_transaction') {
          amountB = (b['data'] as PaymentTransaction).amount;
        } else {
          amountB = (b['data'].amount as num?)?.toDouble() ?? 0.0;
        }

        return _sortBy == 'amount_desc'
            ? amountB.compareTo(amountA)
            : amountA.compareTo(amountB);
      }

      return 0;
    });

    return filtered;
  }

  void _onTransactionTap(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final data = item['data'];

    if (type == 'invoice') {
      final invoiceId = data['id'] as String?;
      if (invoiceId != null && invoiceId.isNotEmpty) {
        context.push('/sales/detail/$invoiceId');
      }
    } else if (type == 'payment') {
      // Ödeme detayını göster
      _showPaymentDetail(data as CashTransaction);
    } else if (type == 'payment_transaction') {
      // Payment transaction detayını göster
      _showPaymentTransactionDetail(data as PaymentTransaction);
    } else {
      // Transaction detayını göster
      _showTransactionDetail(data);
    }
  }

  void _showPaymentDetail(CashTransaction payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Ödeme Detayı',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('İşlem No', payment.transactionNumber),
              _buildDetailRow(
                  'Tutar',
                  CurrencyHelper.formatCurrency(
                      payment.amount, payment.currency)),
              _buildDetailRow(
                  'Tarih',
                  DateFormat('dd.MM.yyyy HH:mm')
                      .format(payment.transactionDate)),
              if (payment.description != null)
                _buildDetailRow('Açıklama', payment.description!),
              _buildDetailRow('Tip', payment.type.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _exportPaymentToPDF(payment);
            },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF İndir'),
          ),
        ],
      ),
    );
  }

  void _showPaymentTransactionDetail(PaymentTransaction pt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tahsilat/Ödeme Detayı',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('İşlem No', pt.transactionNumber),
              _buildDetailRow('Tip', _getPaymentTypeName(pt.type)),
              _buildDetailRow(
                  'Yön',
                  pt.direction == PaymentDirection.incoming
                      ? 'Tahsilat'
                      : 'Ödeme'),
              _buildDetailRow('Tutar',
                  CurrencyHelper.formatCurrency(pt.amount, pt.currency)),
              _buildDetailRow('Tarih',
                  DateFormat('dd.MM.yyyy HH:mm').format(pt.transactionDate)),
              if (pt.dueDate != null)
                _buildDetailRow('Vade Tarihi',
                    DateFormat('dd.MM.yyyy').format(pt.dueDate!)),
              _buildDetailRow('Durum', pt.status.name.toUpperCase()),
              _buildDetailRow('Kategori', pt.category.name),
              if (pt.description != null)
                _buildDetailRow('Açıklama', pt.description!),
              if (pt.referenceNumber != null)
                _buildDetailRow('Referans No', pt.referenceNumber!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _exportPaymentTransactionToPDF(pt);
            },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF İndir'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(dynamic transaction) {
    final txn = transaction as Transaction;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'İşlem Detayı',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (txn.documentNumber != null && txn.documentNumber!.isNotEmpty)
                _buildDetailRow('Belge No', txn.documentNumber!),
              _buildDetailRow('Tutar',
                  CurrencyHelper.formatCurrency(txn.amount, txn.currency)),
              _buildDetailRow('Tarih',
                  DateFormat('dd.MM.yyyy HH:mm').format(txn.transactionDate)),
              _buildDetailRow('İşlem Türü', txn.type.name),
              _buildDetailRow('Durum', txn.status.name),
              if (txn.reference != null && txn.reference!.isNotEmpty)
                _buildDetailRow('Referans', txn.reference!),
              if (txn.paymentMethod != null && txn.paymentMethod!.isNotEmpty)
                _buildDetailRow('Ödeme Yöntemi', txn.paymentMethod!),
              if (txn.description != null && txn.description!.isNotEmpty)
                _buildDetailRow('Açıklama', txn.description!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _exportCustomerTransactionToPDF(txn);
            },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF İndir'),
          ),
        ],
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
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPdfCurrency(double amount, String currency) {
    return CurrencyHelper.formatCurrency(amount, currency)
        .replaceAll('₺', 'TL');
  }

  String _getPaymentTypeName(PaymentTransactionType type) {
    switch (type) {
      case PaymentTransactionType.cash:
        return 'Nakit';
      case PaymentTransactionType.check:
        return 'Çek';
      case PaymentTransactionType.promissoryNote:
        return 'Senet';
      case PaymentTransactionType.eftTransfer:
        return 'Havale/EFT';
      case PaymentTransactionType.creditCard:
        return 'Kredi Kartı';
      case PaymentTransactionType.debtReceipt:
        return 'Borç Fişi';
      case PaymentTransactionType.creditReceipt:
        return 'Alacak Fişi';
      case PaymentTransactionType.accountTransfer:
        return 'Cari Virman';
    }
  }

  Future<void> _exportPaymentToPDF(CashTransaction payment) async {
    final exportService = ExportService();
    final details = <String, String>{
      'İşlem No': payment.transactionNumber,
      'Tarih': DateFormat('dd.MM.yyyy HH:mm').format(payment.transactionDate),
      'Tutar': _formatPdfCurrency(payment.amount, payment.currency),
      'Tip': payment.type.toString(),
      if (payment.description != null && payment.description!.isNotEmpty)
        'Açıklama': payment.description!,
    };

    try {
      final bytes = await exportService.exportTransactionDetailPDF(
        title: 'Ödeme Detayı',
        subtitle:
            'Rapor Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
        details: details,
      );

      final fileName =
          'odeme_${payment.transactionNumber}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        final blob = web.Blob([bytes.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = url;
        anchor.download = fileName;
        anchor.click();
        web.URL.revokeObjectURL(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('PDF indirme şu an sadece web üzerinde destekleniyor'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportPaymentTransactionToPDF(PaymentTransaction pt) async {
    final exportService = ExportService();

    final details = <String, String>{
      'İşlem No': pt.transactionNumber,
      'Tip': _getPaymentTypeName(pt.type),
      'Yön': pt.direction == PaymentDirection.incoming ? 'Tahsilat' : 'Ödeme',
      'Tutar': _formatPdfCurrency(pt.amount, pt.currency),
      'Tarih': DateFormat('dd.MM.yyyy HH:mm').format(pt.transactionDate),
      'Durum': pt.status.name.toUpperCase(),
      'Kategori': pt.category.name,
      if (pt.referenceNumber != null && pt.referenceNumber!.isNotEmpty)
        'Referans': pt.referenceNumber!,
      if (pt.description != null && pt.description!.isNotEmpty)
        'Açıklama': pt.description!,
    };

    try {
      final bytes = await exportService.exportTransactionDetailPDF(
        title: 'Tahsilat/Ödeme Detayı',
        subtitle:
            'Rapor Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
        details: details,
      );

      final fileName =
          'payment_transaction_${pt.transactionNumber}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        final blob = web.Blob([bytes.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = url;
        anchor.download = fileName;
        anchor.click();
        web.URL.revokeObjectURL(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('PDF indirme şu an sadece web üzerinde destekleniyor'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportCustomerTransactionToPDF(Transaction transaction) async {
    final exportService = ExportService();

    final details = <String, String>{
      'İşlem ID': transaction.id,
      'İşlem Türü': transaction.type.name,
      'Durum': transaction.status.name,
      'Tutar': _formatPdfCurrency(transaction.amount, transaction.currency),
      'Tarih':
          DateFormat('dd.MM.yyyy HH:mm').format(transaction.transactionDate),
      if (transaction.dueDate != null)
        'Vade Tarihi': DateFormat('dd.MM.yyyy').format(transaction.dueDate!),
      if (transaction.reference != null && transaction.reference!.isNotEmpty)
        'Referans': transaction.reference!,
      if (transaction.description != null &&
          transaction.description!.isNotEmpty)
        'Açıklama': transaction.description!,
      if (transaction.paymentMethod != null &&
          transaction.paymentMethod!.isNotEmpty)
        'Ödeme Yöntemi': transaction.paymentMethod!,
    };

    if (transaction.metadata != null && transaction.metadata!.isNotEmpty) {
      details['Ek Bilgiler'] = transaction.metadata!.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\\n');
    }

    try {
      final bytes = await exportService.exportTransactionDetailPDF(
        title: 'İşlem Detayı',
        subtitle:
            'Rapor Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
        details: details,
      );

      final fileName =
          'transaction_${transaction.id}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        final blob = web.Blob([bytes.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = url;
        anchor.download = fileName;
        anchor.click();
        web.URL.revokeObjectURL(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('PDF indirme şu an sadece web üzerinde destekleniyor'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customerAsync = ref.watch(customerProvider(widget.customerId));

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tüm İşlemler',
        showBackButton: true,
        showDrawer: false,
      ),
      body: SafeArea(
        child: customerAsync.when(
          data: (customer) {
            if (customer == null) {
              return const Center(child: Text('Müşteri bulunamadı'));
            }

            final invoicesAsync =
                ref.watch(sales.customerInvoicesStreamProvider(customer.id));
            final cashState = ref.watch(cashManagementNotifierProvider);
            final paymentTransactionsAsync =
                ref.watch(customerPaymentTransactionsProvider(customer.id));

            return FutureBuilder<List<dynamic>>(
              future: _loadCustomerTransactions(customer.id),
              builder: (context, transactionSnapshot) {
                if (transactionSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (transactionSnapshot.hasError) {
                  return Center(
                    child: Text('Hata: ${transactionSnapshot.error}'),
                  );
                }

                return invoicesAsync.when(
                  data: (invoices) {
                    final transactionsRaw = transactionSnapshot.data ?? [];
                    final paymentTransactions =
                        paymentTransactionsAsync.maybeWhen(
                      data: (value) => value,
                      orElse: () => <PaymentTransaction>[],
                    );

                    final paymentTransactionIds =
                        paymentTransactions.map((e) => e.id).toSet();
                    final invoiceIds =
                        invoices.map((e) => e['id'] as String).toSet();
                    final payments = cashState.cashTransactions
                        .where((t) => invoiceIds.contains(t.relatedDocumentId))
                        .where((t) {
                      final metaId =
                          t.metadata['paymentTransactionId']?.toString();
                      if (metaId != null &&
                          paymentTransactionIds.contains(metaId)) {
                        return false;
                      }
                      return true;
                    }).toList();

                    final invoiceKeys = <String>{};
                    final paymentKeys = <String>{};
                    final paymentTxnKeys = <String>{};
                    final transactionKeys = <String>{};
                    final uniqueKeys = <String>{};
                    final allItems = <Map<String, dynamic>>[];

                    void addItem(String key, Map<String, dynamic> item) {
                      if (uniqueKeys.add(key)) {
                        allItems.add(item);
                      }
                    }

                    for (final invoice in invoices) {
                      final invoiceId = invoice['id'] as String?;
                      final invoiceNumber =
                          invoice['invoiceNumber']?.toString();
                      final key = 'invoice-${invoiceId ?? invoiceNumber ?? ''}';
                      if (invoiceKeys.add(key)) {
                        addItem(
                          key,
                          {
                            'type': 'invoice',
                            'date': _parseDateTime(invoice['saleDate']) ??
                                _parseDateTime(invoice['invoiceDate']) ??
                                DateTime.now(),
                            'data': invoice,
                          },
                        );
                      }
                    }

                    for (final payment in payments) {
                      final key = 'payment-${payment.id}';
                      if (paymentKeys.add(key)) {
                        addItem(
                          key,
                          {
                            'type': 'payment',
                            'date': payment.transactionDate,
                            'data': payment,
                          },
                        );
                      }
                    }

                    for (final pt in paymentTransactions) {
                      final key = 'paymentTransaction-${pt.id}';
                      if (paymentTxnKeys.add(key)) {
                        addItem(
                          key,
                          {
                            'type': 'payment_transaction',
                            'date': pt.transactionDate,
                            'data': pt,
                          },
                        );
                      }
                    }

                    for (final t in transactionsRaw.whereType<Transaction>()) {
                      final invoiceRef = t.invoiceId;
                      final docNumber = t.documentNumber;
                      if ((invoiceRef != null &&
                              invoiceIds.contains(invoiceRef)) ||
                          (docNumber != null &&
                              docNumber.isNotEmpty &&
                              invoiceKeys.contains('invoice-$docNumber')) ||
                          t.type == TransactionType.invoice ||
                          t.type == TransactionType.sale) {
                        continue;
                      }
                      final key = 'transaction-${docNumber ?? t.id}';
                      if (transactionKeys.add(key)) {
                        addItem(
                          key,
                          {
                            'type': 'transaction',
                            'date': _parseDateTime(t.transactionDate) ??
                                DateTime.now(),
                            'data': t,
                          },
                        );
                      }
                    }

                    allItems.sort((a, b) {
                      final dateA = a['date'] as DateTime?;
                      final dateB = b['date'] as DateTime?;
                      if (dateA == null && dateB == null) return 0;
                      if (dateA == null) return 1;
                      if (dateB == null) return -1;
                      return dateB.compareTo(dateA);
                    });

                    final filteredItems = _getFilteredAndSortedItems(allItems);

                    return Column(
                      children: [
                        // Arama ve filtre bölümü
                        _buildSearchAndFilter(isDark),
                        // İşlemler listesi
                        Expanded(
                          child: filteredItems.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Filtreye uygun işlem bulunamadı',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index];
                                    return _buildTransactionCard(
                                        item, isDark, customer);
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Hata: $e')),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Müşteri yüklenemedi: $e')),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Arama çubuğu
          TextField(
            decoration: InputDecoration(
              hintText: 'İşlem ara (numara, açıklama)',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Filtre ve sıralama
          Row(
            children: [
              // Tip filtresi
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _filterType,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Tip',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tümü')),
                    DropdownMenuItem(
                        value: 'invoice', child: Text('Faturalar')),
                    DropdownMenuItem(
                        value: 'payment_transaction',
                        child: Text('Tahsilat/Ödeme')),
                    DropdownMenuItem(
                        value: 'payment', child: Text('Kasa Ödemeleri')),
                    DropdownMenuItem(
                        value: 'transaction', child: Text('Diğer İşlemler')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterType = value ?? 'all';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Sıralama
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Sırala',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'date_desc', child: Text('Tarih (Yeni → Eski)')),
                    DropdownMenuItem(
                        value: 'date_asc', child: Text('Tarih (Eski → Yeni)')),
                    DropdownMenuItem(
                        value: 'amount_desc',
                        child: Text('Tutar (Büyük → Küçük)')),
                    DropdownMenuItem(
                        value: 'amount_asc',
                        child: Text('Tutar (Küçük → Büyük)')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value ?? 'date_desc';
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
      Map<String, dynamic> item, bool isDark, dynamic customer) {
    final type = item['type'] as String;
    void onTap() => _onTransactionTap(item);

    Widget content;
    if (type == 'invoice') {
      content = _buildInvoiceCard(item['data'], isDark, onTap);
    } else if (type == 'payment') {
      content =
          _buildPaymentCard(item['data'] as CashTransaction, isDark, onTap);
    } else if (type == 'payment_transaction') {
      content = _buildPaymentTransactionCard(
          item['data'] as PaymentTransaction, isDark, onTap);
    } else {
      content = _buildTransactionCardWidget(item['data'], isDark, onTap);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: content,
    );
  }

  Widget _buildInvoiceCard(dynamic invoice, bool isDark, VoidCallback onTap) {
    final isPaid = invoice['isPaid'] as bool? ?? false;
    final actuallyPaid = isPaid;
    final color = actuallyPaid ? Colors.green : Colors.blue;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(Icons.receipt, color: color),
      ),
      title: Text(
        'Fatura - ${invoice['saleNumber'] ?? invoice['invoiceNumber'] ?? 'N/A'}',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        DateFormat('dd.MM.yyyy').format(_parseDateTime(invoice['saleDate']) ??
            _parseDateTime(invoice['invoiceDate']) ??
            DateTime.now()),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            CurrencyHelper.formatCurrency(invoice['totalAmount'] ?? 0.0,
                invoice['currencyCode'] ?? 'TRY'),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            actuallyPaid ? 'Ödendi' : 'Beklemede',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: actuallyPaid ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
      CashTransaction payment, bool isDark, VoidCallback onTap) {
    final color =
        payment.type == CashTransactionType.income ? Colors.green : Colors.red;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(Icons.payment, color: color),
      ),
      title: Text(
        payment.transactionNumber,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        DateFormat('dd.MM.yyyy').format(payment.transactionDate),
      ),
      trailing: Text(
        CurrencyHelper.formatCurrency(payment.amount, payment.currency),
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPaymentTransactionCard(
      PaymentTransaction pt, bool isDark, VoidCallback onTap) {
    final color =
        pt.direction == PaymentDirection.incoming ? Colors.green : Colors.red;

    String typeText = _getPaymentTypeName(pt.type);
    IconData icon = Icons.payment;

    switch (pt.type) {
      case PaymentTransactionType.cash:
        icon = Icons.money;
        break;
      case PaymentTransactionType.check:
        icon = Icons.check_circle_outline;
        break;
      case PaymentTransactionType.promissoryNote:
        icon = Icons.description;
        break;
      case PaymentTransactionType.eftTransfer:
        icon = Icons.account_balance;
        break;
      case PaymentTransactionType.creditCard:
        icon = Icons.credit_card;
        break;
      default:
        icon = Icons.payment;
    }

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              '$typeText - ${pt.direction == PaymentDirection.incoming ? "Tahsilat" : "Ödeme"}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              pt.status.name.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        DateFormat('dd.MM.yyyy HH:mm').format(pt.transactionDate),
        style: GoogleFonts.poppins(fontSize: 12),
      ),
      trailing: Text(
        CurrencyHelper.formatCurrency(pt.amount, pt.currency),
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTransactionCardWidget(
      Transaction t, bool isDark, VoidCallback onTap) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: primaryColor.withValues(alpha: 0.1),
        child: Icon(Icons.receipt, color: primaryColor),
      ),
      title: Text(
        t.documentNumber ?? t.id,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        DateFormat('dd.MM.yyyy HH:mm').format(t.transactionDate),
      ),
      trailing: Text(
        CurrencyHelper.formatCurrency(t.amount, t.currency),
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }
}
