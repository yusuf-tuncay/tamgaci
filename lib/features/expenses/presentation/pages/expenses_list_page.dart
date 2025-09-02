// ========== EXPENSES (GİDERLER) FEATURE ==========
// lib/features/expenses/presentation/pages/expenses_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../providers/expense_providers.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_filter_sheet.dart';

/// Gider listesi sayfası
class ExpensesListPage extends ConsumerStatefulWidget {
  const ExpensesListPage({super.key});

  @override
  ConsumerState<ExpensesListPage> createState() => _ExpensesListPageState();
}

class _ExpensesListPageState extends ConsumerState<ExpensesListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadExpenses();
  }

  void _loadExpenses() {
    // Giderler zaten provider'da yüklü olmalı
    // Eğer yüklü değilse yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final operationsState = ref.read(expenseOperationsProvider);
      if (operationsState.expenses.isEmpty && !operationsState.isLoading) {
        ref.read(expenseOperationsProvider.notifier).loadExpenses();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Arama değişikliği dinleyicisi
  void _onSearchChanged() {
    ref.read(expenseSearchQueryProvider.notifier).state =
        _searchController.text;
  }

  /// Filtre sayfasını aç
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExpenseFilterSheet(),
    );
  }

  /// Yeni gider ekleme sayfasına git
  void _navigateToCreate() {
    Navigator.of(context).pushNamed('/expenses/create');
  }

  /// Gider detay sayfasına git
  void _navigateToDetail(String expenseId) {
    Navigator.of(context).pushNamed('/expenses/detail', arguments: expenseId);
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesStreamProvider);
    final searchQuery = ref.watch(expenseSearchQueryProvider);
    final selectedCategory = ref.watch(selectedExpenseCategoryProvider);
    final selectedDateRange = ref.watch(expenseDateRangeProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Giderler',
        showDrawer: true,
        actions: [
          // Filtre butonu
          IconButton(
            onPressed: _showFilterSheet,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (selectedCategory != null || selectedDateRange != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: TamgaciConstants.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Yeni gider butonu
          IconButton(onPressed: _navigateToCreate, icon: const Icon(Icons.add)),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      endDrawer: null, // End drawer'ı kapat
      body: Column(
        children: [
          // Arama çubuğu
          Container(
            padding: TamgaciConstants.paddingMedium(context),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Gider ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
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

          // Filtre etiketleri
          if (selectedCategory != null || selectedDateRange != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (selectedCategory != null)
                    Chip(
                      label: Text(selectedCategory.name),
                      onDeleted: () {
                        ref
                            .read(selectedExpenseCategoryProvider.notifier)
                            .state = null;
                      },
                    ),
                  if (selectedDateRange != null)
                    Chip(
                      label: Text(
                        '${selectedDateRange.start.day}/${selectedDateRange.start.month} - ${selectedDateRange.end.day}/${selectedDateRange.end.month}',
                      ),
                      onDeleted: () {
                        ref.read(expenseDateRangeProvider.notifier).state =
                            null;
                      },
                    ),
                ],
              ),
            ),

          // Gider listesi
          Expanded(
            child: expensesAsync.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.money_off_outlined,
                    title: 'Gider Bulunamadı',
                    message: searchQuery.isNotEmpty
                        ? 'Arama kriterlerinize uygun gider bulunamadı.'
                        : 'Henüz gider kaydı bulunmuyor.\nYeni gider eklemek için + butonuna tıklayın.',
                    actionButton: searchQuery.isEmpty
                        ? ElevatedButton.icon(
                            onPressed: _navigateToCreate,
                            icon: const Icon(Icons.add),
                            label: const Text('Gider Ekle'),
                          )
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(expensesStreamProvider);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: TamgaciConstants.paddingMedium(context),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ExpenseCard(
                          expense: expense,
                          onTap: () => _navigateToDetail(expense.id),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Hata: $error'),
                    ElevatedButton(
                      onPressed: _loadExpenses,
                      child: const Text('Tekrar Dene'),
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
}
