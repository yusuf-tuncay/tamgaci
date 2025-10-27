import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_transaction.dart';
import '../providers/account_providers.dart';
import '../providers/account_transaction_providers.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Hesap İşlemleri Sayfası - Filtreleme ve Arama ile
class AccountTransactionsPage extends ConsumerStatefulWidget {
  final Account account;

  const AccountTransactionsPage({
    super.key,
    required this.account,
  });

  @override
  ConsumerState<AccountTransactionsPage> createState() =>
      _AccountTransactionsPageState();
}

class _AccountTransactionsPageState
    extends ConsumerState<AccountTransactionsPage> {
  String _searchQuery = '';
  TransactionType? _selectedType;
  TransactionCategory? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _sortAscending = false; // En yeni önce

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(
      transactionsByAccountIdProvider(widget.account.id),
    );

    return ResponsiveScaffold(
      appBar: CustomAppBar(
        title: '${widget.account.name} - İşlemler',
        showDrawer: false,
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Kapat',
          ),
        ],
      ),
      drawerContent: const SizedBox.shrink(),
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filteredTransactions = _filterTransactions(transactions);

                if (filteredTransactions.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return _buildTransactionItem(transaction);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'İşlemler yüklenirken hata oluştu',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.red[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return _buildDesktopFilters();
          } else {
            return _buildMobileFilters();
          }
        },
      ),
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        // Arama çubuğu
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'İşlem ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // İşlem türü filtresi
        Expanded(
          child: DropdownButtonFormField<TransactionType?>(
            initialValue: _selectedType,
            decoration: InputDecoration(
              labelText: 'Tür',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Tümü')),
              DropdownMenuItem(
                value: TransactionType.deposit,
                child: Text('Para Girişi'),
              ),
              DropdownMenuItem(
                value: TransactionType.withdrawal,
                child: Text('Para Çıkışı'),
              ),
              DropdownMenuItem(
                value: TransactionType.transfer,
                child: Text('Transfer'),
              ),
              DropdownMenuItem(
                value: TransactionType.adjustment,
                child: Text('Düzeltme'),
              ),
              DropdownMenuItem(
                value: TransactionType.opening,
                child: Text('Açılış'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        // Kategori filtresi
        Expanded(
          child: DropdownButtonFormField<TransactionCategory?>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Tümü')),
              DropdownMenuItem(
                value: TransactionCategory.cash,
                child: Text('Nakit'),
              ),
              DropdownMenuItem(
                value: TransactionCategory.bank,
                child: Text('Banka'),
              ),
              DropdownMenuItem(
                value: TransactionCategory.credit,
                child: Text('Kredi'),
              ),
              DropdownMenuItem(
                value: TransactionCategory.investment,
                child: Text('Yatırım'),
              ),
              DropdownMenuItem(
                value: TransactionCategory.expense,
                child: Text('Masraf'),
              ),
              DropdownMenuItem(
                value: TransactionCategory.other,
                child: Text('Diğer'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        // Tarih filtresi
        Expanded(
          child: GestureDetector(
            onTap: () {
              debugPrint('Tarih aralığı InkWell tıklandı');
              _selectDateRange();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _startDate != null && _endDate != null
                          ? '${DateFormat('dd.MM.yyyy').format(_startDate!)} - ${DateFormat('dd.MM.yyyy').format(_endDate!)}'
                          : 'Tarih Aralığı Seç',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _startDate != null && _endDate != null 
                            ? Colors.blue[700] 
                            : Colors.grey[600],
                        fontWeight: _startDate != null && _endDate != null 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Sıralama yönü
        IconButton(
          onPressed: () {
            setState(() {
              _sortAscending = !_sortAscending;
            });
          },
          icon: Icon(
            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          ),
          tooltip: _sortAscending ? 'Artan' : 'Azalan',
        ),
        const SizedBox(width: 8),
        // Temizle butonu
        IconButton(
          onPressed: _clearFilters,
          icon: const Icon(Icons.clear_all),
          tooltip: 'Filtreleri Temizle',
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.withOpacity(0.1),
            foregroundColor: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        // Arama çubuğu - tam genişlik
        TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'İşlem ara...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // İlk satır: Tür ve Kategori
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<TransactionType?>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Tür',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tümü')),
                  DropdownMenuItem(
                    value: TransactionType.deposit,
                    child: Text('Para Girişi'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.withdrawal,
                    child: Text('Para Çıkışı'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.transfer,
                    child: Text('Transfer'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.adjustment,
                    child: Text('Düzeltme'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.opening,
                    child: Text('Açılış'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<TransactionCategory?>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tümü')),
                  DropdownMenuItem(
                    value: TransactionCategory.cash,
                    child: Text('Nakit'),
                  ),
                  DropdownMenuItem(
                    value: TransactionCategory.bank,
                    child: Text('Banka'),
                  ),
                  DropdownMenuItem(
                    value: TransactionCategory.credit,
                    child: Text('Kredi'),
                  ),
                  DropdownMenuItem(
                    value: TransactionCategory.investment,
                    child: Text('Yatırım'),
                  ),
                  DropdownMenuItem(
                    value: TransactionCategory.expense,
                    child: Text('Masraf'),
                  ),
                  DropdownMenuItem(
                    value: TransactionCategory.other,
                    child: Text('Diğer'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // İkinci satır: Tarih ve Kontroller
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  debugPrint('Tarih aralığı InkWell tıklandı (mobil)');
                  _selectDateRange();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _startDate != null && _endDate != null
                              ? '${DateFormat('dd.MM.yyyy').format(_startDate!)} - ${DateFormat('dd.MM.yyyy').format(_endDate!)}'
                              : 'Tarih Aralığı Seç',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _startDate != null && _endDate != null
                                ? Colors.blue[700]
                                : Colors.grey[600],
                            fontWeight: _startDate != null && _endDate != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                });
              },
              icon: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              ),
              tooltip: _sortAscending ? 'Artan' : 'Azalan',
            ),
            IconButton(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Filtreleri Temizle',
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.1),
                foregroundColor: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'İşlem bulunamadı',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Filtreleri değiştirerek tekrar deneyin',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(AccountTransaction transaction) {
    final isNegative = transaction.amount < 0;
    final amountColor = isNegative ? Colors.red[600] : Colors.green[600];
    final amountIcon = isNegative ? Icons.arrow_downward : Icons.arrow_upward;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => _TransactionEditDialog(
            transaction: transaction,
            account: widget.account,
            onTransactionUpdated: () {
              ref.invalidate(
                  transactionsByAccountIdProvider(widget.account.id));
              ref.invalidate(accountsProvider);
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: amountColor?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                amountIcon,
                color: amountColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy HH:mm')
                            .format(transaction.transactionDate),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              _getTypeColor(transaction.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getTypeText(transaction.type),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getTypeColor(transaction.type),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isNegative ? '-' : '+'}${NumberFormat('#,##0.00', 'tr_TR').format(transaction.amount.abs())} ${widget.account.currency}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bakiye: ${NumberFormat('#,##0.00', 'tr_TR').format(transaction.balanceAfter)} ${widget.account.currency}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<AccountTransaction> _filterTransactions(
      List<AccountTransaction> transactions) {
    debugPrint('=== FİLTRELEME BAŞLADI ===');
    debugPrint('Toplam işlem sayısı: ${transactions.length}');
    debugPrint('Arama sorgusu: "$_searchQuery"');
    debugPrint('Seçili tür: $_selectedType');
    debugPrint('Seçili kategori: $_selectedCategory');
    debugPrint('Başlangıç tarihi: $_startDate');
    debugPrint('Bitiş tarihi: $_endDate');
    debugPrint('Sıralama: ${_sortAscending ? "Artan" : "Azalan"}');

    var filtered = transactions.where((transaction) {
      debugPrint('İşlem kontrol ediliyor: ${transaction.description} - ${transaction.transactionDate}');
      
      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!transaction.description.toLowerCase().contains(query)) {
          debugPrint('  ❌ Arama filtresi: "${transaction.description}" sorgu "$query" içermiyor');
          return false;
        }
        debugPrint('  ✅ Arama filtresi geçti');
      }

      // İşlem türü filtresi
      if (_selectedType != null && transaction.type != _selectedType) {
        debugPrint('  ❌ Tür filtresi: ${transaction.type} != $_selectedType');
        return false;
      }
      debugPrint('  ✅ Tür filtresi geçti');

      // Kategori filtresi
      if (_selectedCategory != null &&
          transaction.category != _selectedCategory) {
        debugPrint('  ❌ Kategori filtresi: ${transaction.category} != $_selectedCategory');
        return false;
      }
      debugPrint('  ✅ Kategori filtresi geçti');

      // Tarih filtresi
      if (_startDate != null) {
        // Başlangıç tarihinden önceki günleri filtrele (başlangıç dahil)
        if (transaction.transactionDate.isBefore(_startDate!)) {
          debugPrint('  ❌ Başlangıç tarihi filtresi: ${transaction.transactionDate} < $_startDate');
          return false;
        }
        debugPrint('  ✅ Başlangıç tarihi filtresi geçti');
      }
      if (_endDate != null) {
        // Bitiş tarihinden sonraki günleri filtrele (bitiş dahil)
        if (transaction.transactionDate.isAfter(_endDate!)) {
          debugPrint('  ❌ Bitiş tarihi filtresi: ${transaction.transactionDate} > $_endDate');
          return false;
        }
        debugPrint('  ✅ Bitiş tarihi filtresi geçti');
      }

      debugPrint('  ✅ Tüm filtreler geçti - işlem dahil ediliyor');
      return true;
    }).toList();

    debugPrint('Filtreleme sonucu: ${filtered.length} işlem');

    // Sıralama
    filtered.sort((a, b) {
      if (_sortAscending) {
        return a.transactionDate.compareTo(b.transactionDate);
      } else {
        return b.transactionDate.compareTo(a.transactionDate);
      }
    });

    debugPrint('=== FİLTRELEME BİTTİ ===');
    return filtered;
  }

  Future<void> _selectDateRange() async {
    debugPrint('Tarih aralığı seçimi başlatılıyor...');
    debugPrint('Mevcut başlangıç tarihi: $_startDate');
    debugPrint('Mevcut bitiş tarihi: $_endDate');

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      helpText: 'Tarih aralığı seçin',
      cancelText: 'İptal',
      confirmText: 'Tamam',
      saveText: 'Kaydet',
      fieldStartLabelText: 'Başlangıç tarihi',
      fieldEndLabelText: 'Bitiş tarihi',
    );

    debugPrint('Seçilen tarih aralığı: $picked');

    if (picked != null) {
      debugPrint('Yeni başlangıç tarihi: ${picked.start}');
      debugPrint('Yeni bitiş tarihi: ${picked.end}');

      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      debugPrint('Tarih aralığı güncellendi');

      // Kullanıcıya bilgi ver
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tarih aralığı: ${DateFormat('dd.MM.yyyy').format(picked.start)} - ${DateFormat('dd.MM.yyyy').format(picked.end)}',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.blue[600],
          ),
        );
      }
    } else {
      debugPrint('Tarih aralığı seçimi iptal edildi');
    }
  }

  void _clearFilters() {
    debugPrint('Filtreler temizleniyor...');
    debugPrint('Önceki arama: $_searchQuery');
    debugPrint('Önceki tür: $_selectedType');
    debugPrint('Önceki kategori: $_selectedCategory');
    debugPrint('Önceki başlangıç tarihi: $_startDate');
    debugPrint('Önceki bitiş tarihi: $_endDate');

    setState(() {
      _searchQuery = '';
      _selectedType = null;
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
      _sortAscending = false;
    });

    debugPrint('Filtreler temizlendi');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Filtreler temizlendi'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Colors.green;
      case TransactionType.withdrawal:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
      case TransactionType.adjustment:
        return Colors.orange;
      case TransactionType.opening:
        return Colors.purple;
    }
  }

  String _getTypeText(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Giriş';
      case TransactionType.withdrawal:
        return 'Çıkış';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.adjustment:
        return 'Düzeltme';
      case TransactionType.opening:
        return 'Açılış';
    }
  }
}

/// Transaction Edit Dialog - AccountDetailPage'den kopyalandı
class _TransactionEditDialog extends ConsumerStatefulWidget {
  final AccountTransaction transaction;
  final Account account;
  final VoidCallback onTransactionUpdated;

  const _TransactionEditDialog({
    required this.transaction,
    required this.account,
    required this.onTransactionUpdated,
  });

  @override
  ConsumerState<_TransactionEditDialog> createState() =>
      _TransactionEditDialogState();
}

class _TransactionEditDialogState
    extends ConsumerState<_TransactionEditDialog> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.transaction.description);
    _amountController =
        TextEditingController(text: widget.transaction.amount.abs().toString());
    _selectedDate = widget.transaction.transactionDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.transaction.transactionDate);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Text(
            'İşlem Düzenle',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Açıklama',
                prefixIcon: const Icon(Icons.description),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Miktar',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: widget.account.currency,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 8),
                          Text(_selectedTime.format(context)),
                        ],
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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _deleteTransaction,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Sil'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateTransaction,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Güncelle'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateTransaction() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Açıklama gerekli')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir miktar girin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final oldAmount = widget.transaction.amount;
      final newAmount = widget.transaction.amount < 0 ? -amount : amount;
      final balanceChange = newAmount - oldAmount;
      final newBalance = widget.account.balance + balanceChange;

      final updatedTransaction = widget.transaction.copyWith(
        description: _descriptionController.text.trim(),
        amount: newAmount,
        balanceAfter: newBalance,
        transactionDate: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        updatedAt: DateTime.now(),
      );

      await ref
          .read(accountTransactionNotifierProvider.notifier)
          .updateTransaction(updatedTransaction);

      await ref
          .read(accountNotifierProvider.notifier)
          .updateAccountBalance(widget.account.id, newBalance);

      widget.onTransactionUpdated();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'İşlem güncellendi. Yeni bakiye: ${NumberFormat('#,##0.00', 'tr_TR').format(newBalance)} ${widget.account.currency}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTransaction() async {
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
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final deletedAmount = widget.transaction.amount;
      final newBalance = widget.account.balance - deletedAmount;

      await ref
          .read(accountTransactionNotifierProvider.notifier)
          .deleteTransaction(widget.transaction.id);

      await ref
          .read(accountNotifierProvider.notifier)
          .updateAccountBalance(widget.account.id, newBalance);

      widget.onTransactionUpdated();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'İşlem silindi. Yeni bakiye: ${NumberFormat('#,##0.00', 'tr_TR').format(newBalance)} ${widget.account.currency}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
