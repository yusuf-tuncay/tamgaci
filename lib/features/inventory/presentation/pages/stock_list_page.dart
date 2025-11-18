// ========== STOCK LIST PAGE ==========
// lib/features/inventory/presentation/pages/stock_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import 'package:go_router/go_router.dart';
import '../providers/stock_providers.dart';
import '../providers/warehouse_providers.dart';
import '../../domain/entities/stock.dart';

class StockListPage extends ConsumerWidget {
  const StockListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stocksAsync = ref.watch(stocksProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        showBackButton: true,
        showDrawer: false,
      ),
      body: stocksAsync.when(
        data: (stocks) => _buildStockList(stocks, isDark, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Hata: $error',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/inventory/stock/create');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStockList(List<Stock> stocks, bool isDark, WidgetRef ref) {
    if (stocks.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.inventory,
        title: 'Henüz stok yok',
        message: 'Yeni stok eklemek için + butonuna tıklayın',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterSection(isDark, ref),
          const SizedBox(height: 16),
          _buildStockGrid(stocks, isDark, ref),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDark, WidgetRef ref) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtreler',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFilterChip(
                    'Tümü',
                    Icons.all_inclusive,
                    Colors.blue,
                    () {},
                    isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    'Düşük Stok',
                    Icons.warning,
                    Colors.red,
                    () {},
                    isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    'Fazla Stok',
                    Icons.inventory_2,
                    Colors.orange,
                    () {},
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockGrid(List<Stock> stocks, bool isDark, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        return _buildStockCard(stocks[index], isDark, ref, context);
      },
    );
  }

  Widget _buildStockCard(
      Stock stock, bool isDark, WidgetRef ref, BuildContext context) {
    final warehousesAsync = ref.watch(warehousesProvider);

    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/inventory/stock/detail',
            arguments: stock.id.toString(),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ürün #${stock.productId}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(stock.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stock.status.shortName,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(stock.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quantity info
              _buildInfoRow(
                'Miktar',
                '${stock.quantity.toStringAsFixed(0)} ${stock.unit}',
                Icons.inventory,
                isDark,
              ),
              const SizedBox(height: 4),

              // Price info
              _buildInfoRow(
                'Birim Fiyat',
                '${CurrencyHelper.getCurrencySymbol(stock.currency)}${stock.unitPrice.toStringAsFixed(2)}',
                Icons.attach_money,
                isDark,
              ),
              const SizedBox(height: 4),

              // Total value
              _buildInfoRow(
                'Toplam Değer',
                '${CurrencyHelper.getCurrencySymbol(stock.currency)}${stock.totalValue.toStringAsFixed(2)}',
                Icons.calculate,
                isDark,
              ),
              const SizedBox(height: 4),

              // Warehouse info
              warehousesAsync.when(
                data: (warehouses) {
                  final warehouse = warehouses.firstWhere(
                    (w) => w.id == stock.warehouseId,
                    orElse: () => warehouses.first,
                  );
                  return _buildInfoRow(
                    'Depo',
                    warehouse.name,
                    Icons.warehouse,
                    isDark,
                  );
                },
                loading: () =>
                    _buildInfoRow('Depo', '...', Icons.warehouse, isDark),
                error: (error, stack) =>
                    _buildInfoRow('Depo', 'Hata', Icons.warehouse, isDark),
              ),
              const SizedBox(height: 4),

              // Location info
              if (stock.location != null)
                _buildInfoRow(
                  'Konum',
                  stock.location!,
                  Icons.location_on,
                  isDark,
                ),

              const Spacer(),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/inventory/stock/edit',
                        arguments: stock.id.toString(),
                      );
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: TamgaciConstants.primaryColor,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showDeleteConfirmation(context, stock);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isDark
                      ? TamgaciConstants.textSecondaryDark
                      : TamgaciConstants.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.low:
        return Colors.red;
      case StockStatus.normal:
        return Colors.green;
      case StockStatus.high:
        return Colors.orange;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Stock stock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Stok Silme',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bu stok kaydını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stok silme işlemi henüz implement edilmedi'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Sil',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
