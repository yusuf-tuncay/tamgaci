import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/features/sales/presentation/providers/sale_providers.dart';
import 'package:tamgaci/features/sales/presentation/widgets/sale_card.dart';
import 'package:tamgaci/features/sales/presentation/widgets/sale_filter_bottom_sheet.dart';
import 'package:tamgaci/core/routes/routes.dart';
import 'package:tamgaci/core/widgets/loading_widget.dart';
import 'package:tamgaci/core/widgets/error_widget.dart' as core_widgets;
import 'package:tamgaci/core/widgets/empty_state_widget.dart';
import 'package:tamgaci/core/widgets/search_bar_widget.dart';
import 'package:tamgaci/core/widgets/fab_widget.dart';
import 'package:tamgaci/features/sales/presentation/states/sale_state.dart';

/// Satış listesi sayfası
class SalesListPage extends ConsumerStatefulWidget {
  const SalesListPage({super.key});

  @override
  ConsumerState<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends ConsumerState<SalesListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SaleStatus? _selectedStatus;
  PaymentStatus? _selectedPaymentStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSales();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSales() {
    ref.read(saleNotifierProvider.notifier).getSales();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      _loadSales();
    } else {
      ref.read(saleNotifierProvider.notifier).searchSales(query);
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaleFilterBottomSheet(
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
            ref.read(saleNotifierProvider.notifier).getSalesByStatus(status);
          } else if (paymentStatus != null) {
            ref
                .read(saleNotifierProvider.notifier)
                .getSalesByPaymentStatus(paymentStatus);
          } else if (startDate != null && endDate != null) {
            ref
                .read(saleNotifierProvider.notifier)
                .getSalesByDateRange(startDate, endDate);
          } else {
            _loadSales();
          }
        },
        onClearFilters: () {
          setState(() {
            _selectedStatus = null;
            _selectedPaymentStatus = null;
            _startDate = null;
            _endDate = null;
          });
          _loadSales();
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
    _loadSales();
  }

  @override
  Widget build(BuildContext context) {
    final saleState = ref.watch(saleNotifierProvider);
    final hasFilters = _selectedStatus != null ||
        _selectedPaymentStatus != null ||
        _startDate != null ||
        _endDate != null ||
        _searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Satışlar'),
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
              hintText: 'Satış ara...',
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
                                _loadSales();
                              },
                            ),
                          if (_selectedPaymentStatus != null)
                            Chip(
                              label: Text(_selectedPaymentStatus!.displayName),
                              onDeleted: () {
                                setState(() {
                                  _selectedPaymentStatus = null;
                                });
                                _loadSales();
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
                                _loadSales();
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
            child: _buildBody(saleState),
          ),
        ],
      ),
      floatingActionButton: FabWidget(
        onPressed: () {
          Navigator.pushNamed(context, TamgaciRoutes.createSale);
        },
        tooltip: 'Yeni Satış',
      ),
    );
  }

  Widget _buildBody(SaleState state) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.error != null) {
      return core_widgets.ErrorWidget(
        message: state.error!,
        onRetry: _loadSales,
      );
    }

    if (state.sales.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        title: 'Satış Bulunamadı',
        message: _searchQuery.isNotEmpty ||
                _selectedStatus != null ||
                _selectedPaymentStatus != null ||
                _startDate != null ||
                _endDate != null
            ? 'Arama kriterlerinize uygun satış bulunamadı.'
            : 'Henüz satış kaydı bulunmuyor.\nYeni satış oluşturmak için + butonuna tıklayın.',
        actionText: _searchQuery.isNotEmpty ||
                _selectedStatus != null ||
                _selectedPaymentStatus != null ||
                _startDate != null ||
                _endDate != null
            ? 'Filtreleri Temizle'
            : 'Yeni Satış',
        onAction: _searchQuery.isNotEmpty ||
                _selectedStatus != null ||
                _selectedPaymentStatus != null ||
                _startDate != null ||
                _endDate != null
            ? _clearFilters
            : () {
                Navigator.pushNamed(context, TamgaciRoutes.createSale);
              },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadSales();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.sales.length,
        itemBuilder: (context, index) {
          final sale = state.sales[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: SaleCard(
              sale: sale,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.saleDetail,
                  arguments: sale.id,
                );
              },
              onEdit: () {
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.editSale,
                  arguments: sale.id,
                );
              },
              onDelete: () {
                _showDeleteDialog(sale);
              },
              onDuplicate: () {
                _duplicateSale(sale.id);
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Satışı Sil'),
        content: Text(
            '${sale.saleNumber} numaralı satışı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSale(sale.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _deleteSale(String id) {
    ref.read(saleNotifierProvider.notifier).deleteSale(id);
  }

  void _duplicateSale(String id) {
    ref.read(saleNotifierProvider.notifier).duplicateSale(id);
  }
}
