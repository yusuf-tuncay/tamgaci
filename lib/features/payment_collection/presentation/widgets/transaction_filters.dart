// ========== TRANSACTION FILTERS ==========
// lib/features/payment_collection/presentation/widgets/transaction_filters.dart

import 'package:flutter/material.dart';
import '../../domain/entities/payment_enums.dart';

/// İşlem filtreleri widget'ı
class TransactionFilters extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedCustomerId;
  final String? selectedSupplierId;
  final String? selectedAccountId;
  final String? selectedPaymentMethodId;
  final String? selectedPaymentSourceId;
  final PaymentTransactionType? selectedType;
  final PaymentTransactionCategory? selectedCategory;
  final PaymentTransactionStatus? selectedStatus;
  final PaymentDirection? selectedDirection;
  final String? selectedCurrency;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const TransactionFilters({
    super.key,
    this.startDate,
    this.endDate,
    this.selectedCustomerId,
    this.selectedSupplierId,
    this.selectedAccountId,
    this.selectedPaymentMethodId,
    this.selectedPaymentSourceId,
    this.selectedType,
    this.selectedCategory,
    this.selectedStatus,
    this.selectedDirection,
    this.selectedCurrency,
    required this.onFiltersChanged,
  });

  @override
  State<TransactionFilters> createState() => _TransactionFiltersState();
}

class _TransactionFiltersState extends State<TransactionFilters> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late String? _selectedCustomerId;
  late String? _selectedSupplierId;
  late String? _selectedAccountId;
  late String? _selectedPaymentMethodId;
  late String? _selectedPaymentSourceId;
  late PaymentTransactionType? _selectedType;
  late PaymentTransactionCategory? _selectedCategory;
  late PaymentTransactionStatus? _selectedStatus;
  late PaymentDirection? _selectedDirection;
  late String? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _selectedCustomerId = widget.selectedCustomerId;
    _selectedSupplierId = widget.selectedSupplierId;
    _selectedAccountId = widget.selectedAccountId;
    _selectedPaymentMethodId = widget.selectedPaymentMethodId;
    _selectedPaymentSourceId = widget.selectedPaymentSourceId;
    _selectedType = widget.selectedType;
    _selectedCategory = widget.selectedCategory;
    _selectedStatus = widget.selectedStatus;
    _selectedDirection = widget.selectedDirection;
    _selectedCurrency = widget.selectedCurrency;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtreler',
                style: theme.textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filtre içeriği
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarih aralığı
                  _buildDateRangeFilter(theme),

                  const SizedBox(height: 16),

                  // İşlem türü
                  _buildTypeFilter(theme),

                  const SizedBox(height: 16),

                  // Kategori
                  _buildCategoryFilter(theme),

                  const SizedBox(height: 16),

                  // Durum
                  _buildStatusFilter(theme),

                  const SizedBox(height: 16),

                  // Yön
                  _buildDirectionFilter(theme),

                  const SizedBox(height: 16),

                  // Para birimi
                  _buildCurrencyFilter(theme),

                  const SizedBox(height: 16),

                  // Müşteri
                  _buildCustomerFilter(theme),

                  const SizedBox(height: 16),

                  // Tedarikçi
                  _buildSupplierFilter(theme),

                  const SizedBox(height: 16),

                  // Hesap
                  _buildAccountFilter(theme),

                  const SizedBox(height: 16),

                  // Ödeme yöntemi
                  _buildPaymentMethodFilter(theme),

                  const SizedBox(height: 16),

                  // Ödeme kaynağı
                  _buildPaymentSourceFilter(theme),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Butonlar
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearAllFilters,
                  child: const Text('Temizle'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Uygula'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarih Aralığı',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectStartDate(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _startDate != null
                            ? _formatDate(_startDate!)
                            : 'Başlangıç tarihi',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectEndDate(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _endDate != null
                            ? _formatDate(_endDate!)
                            : 'Bitiş tarihi',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İşlem Türü',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<PaymentTransactionType?>(
          initialValue: _selectedType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Tümü'),
            ),
            ...PaymentTransactionType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getTypeText(type)),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedType = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<PaymentTransactionCategory?>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Tümü'),
            ),
            ...PaymentTransactionCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(_getCategoryText(category)),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStatusFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durum',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<PaymentTransactionStatus?>(
          initialValue: _selectedStatus,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Tümü'),
            ),
            ...PaymentTransactionStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getStatusText(status)),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedStatus = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDirectionFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yön',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<PaymentDirection?>(
          initialValue: _selectedDirection,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Tümü'),
            ),
            ...PaymentDirection.values.map((direction) {
              return DropdownMenuItem(
                value: direction,
                child: Text(_getDirectionText(direction)),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedDirection = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCurrencyFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Para Birimi',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          initialValue: _selectedCurrency,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(
              value: null,
              child: Text('Tümü'),
            ),
            DropdownMenuItem(
              value: 'TRY',
              child: Text('TRY'),
            ),
            DropdownMenuItem(
              value: 'USD',
              child: Text('USD'),
            ),
            DropdownMenuItem(
              value: 'EUR',
              child: Text('EUR'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCurrency = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCustomerFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Müşteri',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _selectedCustomerId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Müşteri ID girin',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {
            setState(() {
              _selectedCustomerId = value.isEmpty ? null : value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSupplierFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tedarikçi',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _selectedSupplierId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Tedarikçi ID girin',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {
            setState(() {
              _selectedSupplierId = value.isEmpty ? null : value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAccountFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hesap',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _selectedAccountId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Hesap ID girin',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {
            setState(() {
              _selectedAccountId = value.isEmpty ? null : value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ödeme Yöntemi',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _selectedPaymentMethodId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Ödeme yöntemi ID girin',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethodId = value.isEmpty ? null : value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPaymentSourceFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ödeme Kaynağı',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _selectedPaymentSourceId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Ödeme kaynağı ID girin',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {
            setState(() {
              _selectedPaymentSourceId = value.isEmpty ? null : value;
            });
          },
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
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
  }

  Future<void> _selectEndDate() async {
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
  }

  void _clearAllFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedCustomerId = null;
      _selectedSupplierId = null;
      _selectedAccountId = null;
      _selectedPaymentMethodId = null;
      _selectedPaymentSourceId = null;
      _selectedType = null;
      _selectedCategory = null;
      _selectedStatus = null;
      _selectedDirection = null;
      _selectedCurrency = null;
    });
  }

  void _applyFilters() {
    final filters = {
      'startDate': _startDate,
      'endDate': _endDate,
      'customerId': _selectedCustomerId,
      'supplierId': _selectedSupplierId,
      'accountId': _selectedAccountId,
      'paymentMethodId': _selectedPaymentMethodId,
      'paymentSourceId': _selectedPaymentSourceId,
      'type': _selectedType,
      'category': _selectedCategory,
      'status': _selectedStatus,
      'direction': _selectedDirection,
      'currency': _selectedCurrency,
    };

    widget.onFiltersChanged(filters);
    Navigator.pop(context);
  }

  String _getTypeText(PaymentTransactionType type) {
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

  String _getDirectionText(PaymentDirection direction) {
    switch (direction) {
      case PaymentDirection.incoming:
        return 'Gelen';
      case PaymentDirection.outgoing:
        return 'Giden';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
