// ========== INCOME (GELİRLER) FEATURE ==========
// lib/features/income/presentation/pages/income_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../providers/income_providers.dart';
import '../widgets/income_card.dart';
import '../widgets/income_filter_sheet.dart';
import '../../domain/entities/income.dart';

/// Gelir listesi sayfası
class IncomeListPage extends ConsumerStatefulWidget {
  const IncomeListPage({super.key});

  @override
  ConsumerState<IncomeListPage> createState() => _IncomeListPageState();
}

class _IncomeListPageState extends ConsumerState<IncomeListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadIncomes();
  }

  void _loadIncomes() {
    // Gelirler zaten provider'da yüklü olmalı
    // Eğer yüklü değilse yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final operationsState = ref.read(incomeOperationsProvider);
      if (operationsState.incomes.isEmpty && !operationsState.isLoading) {
        ref.read(incomeOperationsProvider.notifier).loadIncomes();
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
    ref.read(incomeSearchQueryProvider.notifier).state = _searchController.text;
  }

  /// Filtre sayfasını aç
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const IncomeFilterSheet(),
    );
  }

  /// Yeni gelir ekleme sayfasına git
  void _navigateToCreate() {
    Navigator.of(context).pushNamed('/income/create');
  }

  /// Gelir detay sayfasına git
  void _navigateToDetail(String incomeId) {
    Navigator.of(context).pushNamed('/income/detail', arguments: incomeId);
  }

  /// Gelir listesini oluşturur
  Widget _buildIncomeList(List<Income> incomes, String searchQuery) {
    // Arama filtresi uygula
    List<Income> filteredIncomes = incomes;
    if (searchQuery.isNotEmpty) {
      filteredIncomes = incomes.where((income) {
        return income.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (income.description?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ??
                false) ||
            (income.customerName?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ??
                false);
      }).toList();
    }

    if (filteredIncomes.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.attach_money_outlined,
        title: 'Gelir Bulunamadı',
        message: searchQuery.isNotEmpty
            ? 'Arama kriterlerinize uygun gelir bulunamadı.'
            : 'Henüz gelir kaydı bulunmuyor.\nYeni gelir eklemek için + butonuna tıklayın.',
        actionButton: searchQuery.isEmpty
            ? ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add),
                label: const Text('Gelir Ekle'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadIncomes();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredIncomes.length,
        itemBuilder: (context, index) {
          final income = filteredIncomes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IncomeCard(
              income: income,
              onTap: () => _navigateToDetail(income.id),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(incomeSearchQueryProvider);
    final selectedCategory = ref.watch(selectedIncomeCategoryProvider);
    final selectedDateRange = ref.watch(incomeDateRangeProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Gelirler',
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
          // Yeni gelir butonu
          IconButton(onPressed: _navigateToCreate, icon: const Icon(Icons.add)),
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
                hintText: 'Gelir ara...',
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
                filled: true,
                fillColor:
                    isDark ? TamgaciConstants.cardColorDark : Colors.white,
                hintStyle: TextStyle(
                  color: isDark
                      ? TamgaciConstants.textSecondaryDark
                      : TamgaciConstants.textSecondary,
                ),
              ),
              style: TextStyle(
                color: isDark
                    ? TamgaciConstants.textPrimaryDark
                    : TamgaciConstants.textPrimary,
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
                            .read(selectedIncomeCategoryProvider.notifier)
                            .state = null;
                      },
                    ),
                  if (selectedDateRange != null)
                    Chip(
                      label: Text(
                        '${selectedDateRange.start.day}/${selectedDateRange.start.month} - ${selectedDateRange.end.day}/${selectedDateRange.end.month}',
                      ),
                      onDeleted: () {
                        ref.read(incomeDateRangeProvider.notifier).state = null;
                      },
                    ),
                ],
              ),
            ),

          // Gelir listesi
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final operationsState = ref.watch(incomeOperationsProvider);

                if (operationsState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (operationsState.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Hata: ${operationsState.error}'),
                        ElevatedButton(
                          onPressed: _loadIncomes,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                }

                final incomes = operationsState.incomes;

                if (incomes.isEmpty && !operationsState.isLoading) {
                  return const Center(
                    child: Text('Henüz gelir kaydı bulunmuyor.'),
                  );
                }

                return _buildIncomeList(incomes, searchQuery);
              },
            ),
          ),
        ],
      ),
    );
  }
}
