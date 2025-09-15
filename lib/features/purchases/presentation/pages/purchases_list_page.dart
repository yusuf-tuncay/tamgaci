import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';
import 'package:tamgaci/features/purchases/presentation/providers/purchase_providers.dart';
import 'package:tamgaci/features/purchases/presentation/widgets/purchase_card.dart';
import 'package:tamgaci/features/purchases/presentation/widgets/purchase_filter_bottom_sheet.dart';
import 'package:tamgaci/core/routes/routes.dart';
// import 'package:tamgaci/core/theme/app_theme.dart';
import 'package:tamgaci/core/widgets/loading_widget.dart';
import 'package:tamgaci/core/widgets/error_widget.dart' as core_widgets;
import 'package:tamgaci/core/widgets/empty_state_widget.dart';
import 'package:tamgaci/core/widgets/search_bar_widget.dart';
import 'package:tamgaci/core/widgets/fab_widget.dart';
import 'package:tamgaci/features/purchases/presentation/states/purchase_state.dart';

/// Satın alma listesi sayfası
class PurchasesListPage extends ConsumerStatefulWidget {
  const PurchasesListPage({super.key});

  @override
  ConsumerState<PurchasesListPage> createState() => _PurchasesListPageState();
}

class _PurchasesListPageState extends ConsumerState<PurchasesListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  PurchaseStatus? _selectedStatus;
  PurchasePaymentStatus? _selectedPaymentStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPurchases();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPurchases() {
    ref.read(purchaseNotifierProvider.notifier).getPurchases();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      _loadPurchases();
    } else {
      ref.read(purchaseNotifierProvider.notifier).searchPurchases(query);
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PurchaseFilterBottomSheet(
        selectedStatus: _selectedStatus,
        selectedPaymentStatus: _selectedPaymentStatus,
        startDate: _startDate,
        endDate: _endDate,
        onFilterChanged: (status, paymentStatus, startDate, endDate) {
          setState(() {
            _selectedStatus = status;
            _selectedPaymentStatus = paymentStatus;
            _startDate = startDate;
            _endDate = endDate;
          });

          if (status != null) {
            ref
                .read(purchaseNotifierProvider.notifier)
                .getPurchasesByStatus(status);
          } else if (paymentStatus != null) {
            ref
                .read(purchaseNotifierProvider.notifier)
                .getPurchasesByPaymentStatus(paymentStatus);
          } else if (startDate != null && endDate != null) {
            ref
                .read(purchaseNotifierProvider.notifier)
                .getPurchasesByDateRange(startDate, endDate);
          } else {
            _loadPurchases();
          }
        },
        onClearFilters: () {
          setState(() {
            _selectedStatus = null;
            _selectedPaymentStatus = null;
            _startDate = null;
            _endDate = null;
          });
          _loadPurchases();
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPaymentStatus = null;
      _startDate = null;
      _endDate = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _loadPurchases();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final hasFilters = _selectedStatus != null ||
        _selectedPaymentStatus != null ||
        _startDate != null ||
        _endDate != null ||
        _searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Satın Almalar'),
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
              hintText: 'Satın alma ara...',
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
                          if (_selectedStatus != null)
                            Chip(
                              label: Text(_selectedStatus!.displayName),
                              onDeleted: () {
                                setState(() {
                                  _selectedStatus = null;
                                });
                                _loadPurchases();
                              },
                            ),
                          if (_selectedPaymentStatus != null)
                            Chip(
                              label: Text(_selectedPaymentStatus!.displayName),
                              onDeleted: () {
                                setState(() {
                                  _selectedPaymentStatus = null;
                                });
                                _loadPurchases();
                              },
                            ),
                          if (_startDate != null && _endDate != null)
                            Chip(
                              label: Text(
                                  '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}'),
                              onDeleted: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                });
                                _loadPurchases();
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
            child: _buildBody(purchaseState),
          ),
        ],
      ),
      floatingActionButton: FabWidget(
        onPressed: () {
          Navigator.pushNamed(context, TamgaciRoutes.createPurchase);
        },
        tooltip: 'Yeni Satın Alma',
      ),
    );
  }

  Widget _buildBody(PurchaseState state) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.error != null) {
      return core_widgets.ErrorWidget(
        message: state.error!,
        onRetry: _loadPurchases,
      );
    }

    if (state.purchases.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.shopping_bag_outlined,
        title: 'Satın Alma Bulunamadı',
        message: _searchQuery.isNotEmpty ||
                _selectedStatus != null ||
                _selectedPaymentStatus != null ||
                _startDate != null ||
                _endDate != null
            ? 'Arama kriterlerinize uygun satın alma bulunamadı.'
            : 'Henüz satın alma kaydı bulunmuyor.\nYeni satın alma oluşturmak için + butonuna tıklayın.',
        actionText: _searchQuery.isNotEmpty ||
                _selectedStatus != null ||
                _selectedPaymentStatus != null ||
                _startDate != null ||
                _endDate != null
            ? 'Filtreleri Temizle'
            : 'Yeni Satın Alma',
        onAction: _searchQuery.isNotEmpty ||
                _selectedStatus != null ||
                _selectedPaymentStatus != null ||
                _startDate != null ||
                _endDate != null
            ? _clearFilters
            : () {
                Navigator.pushNamed(context, TamgaciRoutes.createPurchase);
              },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadPurchases();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.purchases.length,
        itemBuilder: (context, index) {
          final purchase = state.purchases[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: PurchaseCard(
              purchase: purchase,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.purchaseDetail,
                  arguments: purchase.id,
                );
              },
              onEdit: () {
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.editPurchase,
                  arguments: purchase.id,
                );
              },
              onDelete: () {
                _showDeleteDialog(purchase);
              },
              onDuplicate: () {
                _duplicatePurchase(purchase.id);
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(Purchase purchase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Satın Almayı Sil'),
        content: Text(
            '${purchase.purchaseNumber} numaralı satın almayı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePurchase(purchase.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _deletePurchase(String id) {
    ref.read(purchaseNotifierProvider.notifier).deletePurchase(id);
  }

  void _duplicatePurchase(String id) {
    ref.read(purchaseNotifierProvider.notifier).duplicatePurchase(id);
  }
}
