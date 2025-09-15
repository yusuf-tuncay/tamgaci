import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';
import 'package:tamgaci/features/cash_management/presentation/providers/cash_management_providers.dart';
import 'package:tamgaci/features/cash_management/presentation/widgets/cash_account_card.dart';
import 'package:tamgaci/features/cash_management/presentation/widgets/cash_account_filter_bottom_sheet.dart';
import 'package:tamgaci/core/routes/routes.dart';
// import 'package:tamgaci/core/theme/app_theme.dart';
import 'package:tamgaci/core/widgets/loading_widget.dart';
import 'package:tamgaci/core/widgets/error_widget.dart' as core_widgets;
import 'package:tamgaci/core/widgets/empty_state_widget.dart';
import 'package:tamgaci/core/widgets/search_bar_widget.dart';
import 'package:tamgaci/core/widgets/fab_widget.dart';
import 'package:tamgaci/features/cash_management/presentation/states/cash_management_state.dart';

/// Nakit hesaplar listesi sayfası
class CashAccountsListPage extends ConsumerStatefulWidget {
  const CashAccountsListPage({super.key});

  @override
  ConsumerState<CashAccountsListPage> createState() =>
      _CashAccountsListPageState();
}

class _CashAccountsListPageState extends ConsumerState<CashAccountsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  CashAccountType? _selectedType;
  CashAccountStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCashAccounts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCashAccounts() {
    ref.read(cashManagementNotifierProvider.notifier).getCashAccounts();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      _loadCashAccounts();
    } else {
      ref
          .read(cashManagementNotifierProvider.notifier)
          .searchCashAccounts(query);
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CashAccountFilterBottomSheet(
        selectedType: _selectedType,
        selectedStatus: _selectedStatus,
        onFilterChanged: (type, status) {
          setState(() {
            _selectedType = type;
            _selectedStatus = status;
          });

          if (type != null) {
            ref
                .read(cashManagementNotifierProvider.notifier)
                .getCashAccountsByType(type);
          } else if (status != null) {
            ref
                .read(cashManagementNotifierProvider.notifier)
                .getCashAccountsByStatus(status);
          } else {
            _loadCashAccounts();
          }
        },
        onClearFilters: () {
          setState(() {
            _selectedType = null;
            _selectedStatus = null;
          });
          _loadCashAccounts();
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _loadCashAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final cashManagementState = ref.watch(cashManagementNotifierProvider);
    final hasFilters = _selectedType != null ||
        _selectedStatus != null ||
        _searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nakit Hesaplar'),
        actions: [
          if (hasFilters)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Filtreleri Temizle',
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filtrele',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Nakit hesap ara...',
              onChanged: _onSearchChanged,
            ),
          ),
          if (hasFilters)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedType != null)
                            Chip(
                              label: Text(_selectedType!.displayName),
                              onDeleted: () {
                                setState(() {
                                  _selectedType = null;
                                });
                                _loadCashAccounts();
                              },
                            ),
                          if (_selectedStatus != null)
                            Chip(
                              label: Text(_selectedStatus!.displayName),
                              onDeleted: () {
                                setState(() {
                                  _selectedStatus = null;
                                });
                                _loadCashAccounts();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _buildBody(cashManagementState),
          ),
        ],
      ),
      floatingActionButton: FabWidget(
        onPressed: () {
          Navigator.pushNamed(context, TamgaciRoutes.createAccount);
        },
        tooltip: 'Yeni Nakit Hesap',
      ),
    );
  }

  Widget _buildBody(CashManagementState state) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.error != null) {
      return core_widgets.ErrorWidget(
        message: state.error!,
        onRetry: _loadCashAccounts,
      );
    }

    if (state.cashAccounts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Nakit Hesap Bulunamadı',
        message: _searchQuery.isNotEmpty ||
                _selectedType != null ||
                _selectedStatus != null
            ? 'Arama kriterlerinize uygun nakit hesap bulunamadı.'
            : 'Henüz nakit hesap kaydı bulunmuyor.\nYeni nakit hesap oluşturmak için + butonuna tıklayın.',
        actionText: _searchQuery.isNotEmpty ||
                _selectedType != null ||
                _selectedStatus != null
            ? 'Filtreleri Temizle'
            : 'Yeni Nakit Hesap',
        onAction: _searchQuery.isNotEmpty ||
                _selectedType != null ||
                _selectedStatus != null
            ? _clearFilters
            : () {
                Navigator.pushNamed(context, TamgaciRoutes.createAccount);
              },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadCashAccounts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.cashAccounts.length,
        itemBuilder: (context, index) {
          final cashAccount = state.cashAccounts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: CashAccountCard(
              cashAccount: cashAccount,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.accountDetail,
                  arguments: cashAccount.id,
                );
              },
              onEdit: () {
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.editAccount,
                  arguments: cashAccount.id,
                );
              },
              onDelete: () {
                _showDeleteDialog(cashAccount);
              },
              onDuplicate: () {
                _duplicateCashAccount(cashAccount.id);
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(CashAccount cashAccount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nakit Hesabı Sil'),
        content: Text(
            '${cashAccount.name} adlı nakit hesabı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCashAccount(cashAccount.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _deleteCashAccount(String id) {
    ref.read(cashManagementNotifierProvider.notifier).deleteCashAccount(id);
  }

  void _duplicateCashAccount(String id) {
    ref.read(cashManagementNotifierProvider.notifier).duplicateCashAccount(id);
  }
}
