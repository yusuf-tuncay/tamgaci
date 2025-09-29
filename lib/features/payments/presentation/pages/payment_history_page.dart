// ========== PAYMENT HISTORY PAGE ==========
// lib/features/payments/presentation/pages/payment_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_type.dart';
import '../../domain/entities/payment_status.dart';
import '../providers/payment_providers.dart';

class PaymentHistoryPage extends ConsumerStatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  ConsumerState<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends ConsumerState<PaymentHistoryPage> {
  final String _selectedFilter = 'all';
  PaymentType? _selectedType;
  PaymentStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahsilat Geçmişi'),
        backgroundColor: Colors.blue[50],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(paymentsProvider);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header ve İstatistikler
            _buildHeaderSection(),

            // Arama ve Filtreler
            _buildSearchAndFilters(),

            // Tahsilat Listesi
            Expanded(
              child: _buildPaymentsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/payments');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Consumer(
        builder: (context, ref, child) {
          final statsAsync = ref.watch(paymentStatsProvider);
          return statsAsync.when(
            data: (stats) => _buildStatsCards(stats),
            loading: () => const LinearProgressIndicator(),
            error: (error, stack) => Text('Hata: $error'),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Toplam Tahsilat',
            stats['totalPayments'].toString(),
            Colors.blue,
            Icons.payments,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Toplam Tutar',
            NumberFormat.currency(locale: 'tr_TR', symbol: '₺')
                .format(stats['totalAmount']),
            Colors.green,
            Icons.attach_money,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Tamamlanan',
            stats['completedCount'].toString(),
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Bekleyen',
            stats['pendingCount'].toString(),
            Colors.orange,
            Icons.schedule,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Müşteri adı, referans ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList() {
    return Consumer(
      builder: (context, ref, child) {
        final paymentsAsync = ref.watch(paymentsProvider);
        return paymentsAsync.when(
          data: (payments) {
            final filteredPayments = _filterPayments(payments);
            if (filteredPayments.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredPayments.length,
              itemBuilder: (context, index) {
                final payment = filteredPayments[index];
                return _buildPaymentCard(payment);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Hata: $error', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(paymentsProvider);
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _getPaymentTypeColor(payment.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPaymentTypeIcon(payment.type),
                  color: _getPaymentTypeColor(payment.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.customerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      payment.type.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(payment.status),
            ],
          ),

          const SizedBox(height: 12),

          // Tutar ve Tarih
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tutar',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    Text(
                      '${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(payment.amount)} ${payment.currency}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tarih',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    Text(
                      DateFormat('dd.MM.yyyy').format(payment.paymentDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Açıklama (varsa)
          if (payment.description != null &&
              payment.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              payment.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],

          // Referans (varsa)
          if (payment.reference != null && payment.reference!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Ref: ${payment.reference}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(PaymentStatus status) {
    Color color;
    String text;

    switch (status) {
      case PaymentStatus.completed:
        color = Colors.green;
        text = 'Tamamlandı';
        break;
      case PaymentStatus.pending:
        color = Colors.orange;
        text = 'Bekliyor';
        break;
      case PaymentStatus.cancelled:
        color = Colors.red;
        text = 'İptal';
        break;
      case PaymentStatus.failed:
        color = Colors.red[700]!;
        text = 'Başarısız';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payments_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz tahsilat kaydı yok',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk tahsilatınızı oluşturmak için + butonuna tıklayın',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreler'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tahsilat Türü
              DropdownButtonFormField<PaymentType?>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Tahsilat Türü'),
                items: [
                  const DropdownMenuItem<PaymentType?>(
                    value: null,
                    child: Text('Tümü'),
                  ),
                  ...PaymentType.values.map(
                    (type) => DropdownMenuItem<PaymentType?>(
                      value: type,
                      child: Text(type.displayName),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Durum
              DropdownButtonFormField<PaymentStatus?>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Durum'),
                items: [
                  const DropdownMenuItem<PaymentStatus?>(
                    value: null,
                    child: Text('Tümü'),
                  ),
                  ...PaymentStatus.values.map(
                    (status) => DropdownMenuItem<PaymentStatus?>(
                      value: status,
                      child: Text(_getStatusText(status)),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Tarih Aralığı
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _startDate != null
                              ? DateFormat('dd.MM.yyyy').format(_startDate!)
                              : 'Başlangıç Tarihi',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _endDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _endDate != null
                              ? DateFormat('dd.MM.yyyy').format(_endDate!)
                              : 'Bitiş Tarihi',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedStatus = null;
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  List<Payment> _filterPayments(List<Payment> payments) {
    return payments.where((payment) {
      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!payment.customerName.toLowerCase().contains(searchLower) &&
            (payment.reference?.toLowerCase().contains(searchLower) ?? false)) {
          return false;
        }
      }

      // Tahsilat türü filtresi
      if (_selectedType != null && payment.type != _selectedType) {
        return false;
      }

      // Durum filtresi
      if (_selectedStatus != null && payment.status != _selectedStatus) {
        return false;
      }

      // Tarih filtresi
      if (_startDate != null && payment.paymentDate.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && payment.paymentDate.isAfter(_endDate!)) {
        return false;
      }

      return true;
    }).toList();
  }

  Color _getPaymentTypeColor(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Colors.green;
      case PaymentType.creditCard:
        return Colors.blue;
      case PaymentType.bank:
        return Colors.purple;
      case PaymentType.check:
        return Colors.orange;
      case PaymentType.promissoryNote:
        return Colors.red;
      case PaymentType.transfer:
        return Colors.teal;
      case PaymentType.voucher:
        return Colors.indigo;
      case PaymentType.balanceAdjustment:
        return Colors.grey;
    }
  }

  IconData _getPaymentTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Icons.monetization_on;
      case PaymentType.creditCard:
        return Icons.credit_card;
      case PaymentType.bank:
        return Icons.account_balance;
      case PaymentType.check:
        return Icons.receipt;
      case PaymentType.promissoryNote:
        return Icons.description;
      case PaymentType.transfer:
        return Icons.swap_horiz;
      case PaymentType.voucher:
        return Icons.receipt_long;
      case PaymentType.balanceAdjustment:
        return Icons.balance;
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'Tamamlandı';
      case PaymentStatus.pending:
        return 'Bekliyor';
      case PaymentStatus.cancelled:
        return 'İptal';
      case PaymentStatus.failed:
        return 'Başarısız';
    }
  }
}
