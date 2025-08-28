// ========== CASH TRANSACTIONS PAGE ==========
// lib/features/cash/presentation/pages/cash_transactions_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

/// Kasa işlemleri sayfası
class CashTransactionsPage extends ConsumerStatefulWidget {
  const CashTransactionsPage({super.key});

  @override
  ConsumerState<CashTransactionsPage> createState() =>
      _CashTransactionsPageState();
}

class _CashTransactionsPageState extends ConsumerState<CashTransactionsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'Tümü';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtre Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Tümü', 'Gelir', 'Gider', 'Transfer', 'Diğer'].map((
            filter,
          ) {
            return ListTile(
              title: Text(filter),
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _navigateToCreate() {
    Navigator.of(context).pushNamed('/cash/create');
  }

  void _navigateToDetail(String transactionId) {
    Navigator.of(context).pushNamed('/cash/detail', arguments: transactionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Kasa İşlemleri',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrele',
          ),
          IconButton(
            onPressed: _navigateToCreate,
            icon: const Icon(Icons.add),
            tooltip: 'Yeni İşlem',
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          // Arama çubuğu
          Container(
            padding: TamgaciConstants.paddingMedium(context),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'İşlem ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                ),
              ),
            ),
          ),

          // Filtre etiketi
          if (_selectedFilter != 'Tümü')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Chip(
                label: Text(_selectedFilter),
                onDeleted: () {
                  setState(() {
                    _selectedFilter = 'Tümü';
                  });
                },
              ),
            ),

          // İşlem listesi
          Expanded(child: _buildTransactionsList()),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    // Mock kasa işlemleri verisi
    final mockTransactions = [
      {
        'id': '1',
        'type': 'Gelir',
        'title': 'Müşteri Ödemesi',
        'description': 'ABC Şirketi ödemesi',
        'amount': 5000.0,
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'category': 'Müşteri Ödemeleri',
        'paymentMethod': 'Banka Transferi',
        'status': 'Tamamlandı',
      },
      {
        'id': '2',
        'type': 'Gider',
        'title': 'Ofis Kirası',
        'description': 'Aralık ayı kirası',
        'amount': -3000.0,
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'category': 'Kira Giderleri',
        'paymentMethod': 'Otomatik Ödeme',
        'status': 'Tamamlandı',
      },
      {
        'id': '3',
        'type': 'Transfer',
        'title': 'Banka Transferi',
        'description': 'Ana hesaptan transfer',
        'amount': 10000.0,
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'category': 'Banka İşlemleri',
        'paymentMethod': 'Banka Transferi',
        'status': 'Tamamlandı',
      },
      {
        'id': '4',
        'type': 'Gelir',
        'title': 'Hizmet Geliri',
        'description': 'Danışmanlık hizmeti',
        'amount': 2500.0,
        'date': DateTime.now().subtract(const Duration(days: 4)),
        'category': 'Hizmet Gelirleri',
        'paymentMethod': 'Nakit',
        'status': 'Tamamlandı',
      },
      {
        'id': '5',
        'type': 'Gider',
        'title': 'Elektrik Faturası',
        'description': 'Kasım ayı elektrik',
        'amount': -450.0,
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'category': 'Fatura Giderleri',
        'paymentMethod': 'Kredi Kartı',
        'status': 'Tamamlandı',
      },
    ];

    // Filtreleme
    List<Map<String, dynamic>> filteredTransactions = mockTransactions;

    if (_selectedFilter != 'Tümü') {
      filteredTransactions = mockTransactions
          .where((transaction) => transaction['type'] == _selectedFilter)
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredTransactions = filteredTransactions
          .where(
            (transaction) =>
                transaction['title'].toLowerCase().contains(query) ||
                transaction['description'].toLowerCase().contains(query) ||
                transaction['category'].toLowerCase().contains(query),
          )
          .toList();
    }

    if (filteredTransactions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.account_balance_wallet_outlined,
        title: 'İşlem Bulunamadı',
        message: _searchController.text.isNotEmpty || _selectedFilter != 'Tümü'
            ? 'Arama kriterlerinize uygun işlem bulunamadı.'
            : 'Henüz kasa işlemi bulunmuyor.\nYeni işlem eklemek için + butonuna tıklayın.',
        actionButton:
            _searchController.text.isEmpty && _selectedFilter == 'Tümü'
            ? ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add),
                label: const Text('İşlem Ekle'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Gerçek veri yenileme işlemi
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veriler yenilendi'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = filteredTransactions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTransactionCard(transaction),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final isIncome = transaction['amount'] > 0;

    return Card(
      child: InkWell(
        onTap: () => _navigateToDetail(transaction['id']),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: TamgaciConstants.cardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // İşlem tipi ikonu
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(transaction['type']),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(transaction['type']),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // İşlem bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: TamgaciConstants.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction['description'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: TamgaciConstants.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: TamgaciConstants.backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                transaction['category'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: TamgaciConstants.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              transaction['paymentMethod'],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: TamgaciConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tutar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(transaction['amount'].abs()),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(transaction['date']),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: TamgaciConstants.textSecondary,
                        ),
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Gelir':
        return Colors.green;
      case 'Gider':
        return Colors.red;
      case 'Transfer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Gelir':
        return Icons.trending_up;
      case 'Gider':
        return Icons.trending_down;
      case 'Transfer':
        return Icons.swap_horiz;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
