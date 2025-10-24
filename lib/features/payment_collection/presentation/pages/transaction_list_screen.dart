// ========== TRANSACTION LIST SCREEN ==========
// lib/features/payment_collection/presentation/pages/transaction_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment_enums.dart';
import '../providers/payment_collection_providers.dart';
import '../models/payment_collection_state.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_filters.dart';
import 'transaction_form_screen.dart';
import 'transaction_detail_screen.dart';

/// Tahsilat ve ödeme işlemlerini listeleyen ekran
class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});


  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCustomerId;
  String? _selectedSupplierId;
  String? _selectedAccountId;
  String? _selectedPaymentMethodId;
  String? _selectedPaymentSourceId;
  PaymentTransactionType? _selectedType;
  PaymentTransactionCategory? _selectedCategory;
  PaymentTransactionStatus? _selectedStatus;
  PaymentDirection? _selectedDirection;
  String? _selectedCurrency;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await ref
        .read(paymentCollectionStateProvider.notifier)
        .loadPaymentMethods();
    await ref
        .read(paymentCollectionStateProvider.notifier)
        .loadPaymentSources();
    await _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    await ref
        .read(paymentCollectionStateProvider.notifier)
        .loadFilteredTransactions(
          customerId: _selectedCustomerId,
          supplierId: _selectedSupplierId,
          accountId: _selectedAccountId,
          paymentMethodId: _selectedPaymentMethodId,
          paymentSourceId: _selectedPaymentSourceId,
          startDate: _startDate,
          endDate: _endDate,
          currency: _selectedCurrency,
        );
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentCollectionStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahsilat ve Ödemeler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          if (state.searchQuery != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'İşlem ara...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref
                          .read(paymentCollectionStateProvider.notifier)
                          .setSearch(null);
                    },
                  ),
                ),
                onChanged: (value) {
                  ref
                      .read(paymentCollectionStateProvider.notifier)
                      .setSearch(value);
                  _loadTransactions();
                },
              ),
            ),

          // Filtreler
          if (state.filters.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: state.filters.entries.map((entry) {
                  return Chip(
                    label: Text('${entry.key}: ${entry.value}'),
                    onDeleted: () {
                      ref
                          .read(paymentCollectionStateProvider.notifier)
                          .clearFilter(entry.key);
                      _loadTransactions();
                    },
                  );
                }).toList(),
              ),
            ),

          // İçerik
          Expanded(
            child: _buildContent(state, theme),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _navigateToForm(PaymentDirection.incoming),
            icon: const Icon(Icons.add),
            label: const Text('Yeni Tahsilat'),
            backgroundColor: Colors.green,
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: () => _navigateToForm(PaymentDirection.outgoing),
            icon: const Icon(Icons.remove),
            label: const Text('Yeni Ödeme'),
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PaymentCollectionState state, ThemeData theme) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
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
              onPressed: _loadTransactions,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (state.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long,
                size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'Henüz işlem bulunmuyor',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni tahsilat veya ödeme eklemek için + butonunu kullanın',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.transactions.length,
        itemBuilder: (context, index) {
          final transaction = state.transactions[index];
          return TransactionListItem(
            transaction: transaction,
            onTap: () => _navigateToDetail(transaction.id),
            onEdit: () =>
                _navigateToForm(PaymentDirection.incoming, transaction.id),
            onPrint: () => _printTransaction(transaction.id),
          );
        },
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TransactionFilters(
        startDate: _startDate,
        endDate: _endDate,
        selectedCustomerId: _selectedCustomerId,
        selectedSupplierId: _selectedSupplierId,
        selectedAccountId: _selectedAccountId,
        selectedPaymentMethodId: _selectedPaymentMethodId,
        selectedPaymentSourceId: _selectedPaymentSourceId,
        selectedType: _selectedType,
        selectedCategory: _selectedCategory,
        selectedStatus: _selectedStatus,
        selectedDirection: _selectedDirection,
        selectedCurrency: _selectedCurrency,
        onFiltersChanged: (filters) {
          setState(() {
            _startDate = filters['startDate'];
            _endDate = filters['endDate'];
            _selectedCustomerId = filters['customerId'];
            _selectedSupplierId = filters['supplierId'];
            _selectedAccountId = filters['accountId'];
            _selectedPaymentMethodId = filters['paymentMethodId'];
            _selectedPaymentSourceId = filters['paymentSourceId'];
            _selectedType = filters['type'];
            _selectedCategory = filters['category'];
            _selectedStatus = filters['status'];
            _selectedDirection = filters['direction'];
            _selectedCurrency = filters['currency'];
          });
          _loadTransactions();
        },
      ),
    );
  }

  void _showSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşlem Ara'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'İşlem numarası, açıklama veya müşteri adı...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            ref.read(paymentCollectionStateProvider.notifier).setSearch(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadTransactions();
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }

  void _navigateToForm(PaymentDirection direction, [String? transactionId]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormScreen(
          direction: direction,
          transactionId: transactionId,
        ),
      ),
    ).then((_) => _loadTransactions());
  }

  void _navigateToDetail(String transactionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TransactionDetailScreen(transactionId: transactionId),
      ),
    );
  }

  void _printTransaction(String transactionId) {
    // PDF oluşturma işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yazdırma işlemi başlatılıyor...')),
    );
  }
}
