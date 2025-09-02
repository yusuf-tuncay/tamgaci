// ========== STOCK DETAIL PAGE ==========
// lib/features/inventory/presentation/pages/stock_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../core/providers/currency_providers.dart';
import '../providers/stock_providers.dart';
import '../providers/warehouse_providers.dart';
import '../../domain/entities/stock.dart';

class StockDetailPage extends ConsumerWidget {
  final String stockId;

  const StockDetailPage({super.key, required this.stockId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stockAsync = ref.watch(stockByIdProvider(int.parse(stockId)));

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Stok Detayı',
        showDrawer: false,
      ),
      drawer: const TamgaciDrawerMenu(),
      body: stockAsync.when(
        data: (stock) => stock != null 
            ? _buildStockDetail(stock, isDark, ref, context)
            : _buildNotFound(isDark),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Hata: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildStockDetail(Stock stock, bool isDark, WidgetRef ref, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStockHeader(stock, isDark),
          const SizedBox(height: 16),
          _buildStockInfo(stock, isDark, ref),
          const SizedBox(height: 16),
          _buildStockStats(stock, isDark),
          const SizedBox(height: 16),
          _buildActionButtons(stock, isDark, context),
        ],
      ),
    );
  }

  Widget _buildStockHeader(Stock stock, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(stock.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory,
                    color: _getStatusColor(stock.status),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ürün #${stock.productId}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(stock.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stock.status.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(stock.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfo(Stock stock, bool isDark, WidgetRef ref) {
    final warehousesAsync = ref.watch(warehousesProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stok Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Miktar', '${stock.quantity.toStringAsFixed(0)} ${stock.unit}', Icons.inventory, isDark),
            const SizedBox(height: 8),
            _buildInfoRow('Birim Fiyat', '${CurrencyHelper.getCurrencySymbol(stock.currency)}${stock.unitPrice.toStringAsFixed(2)}', Icons.attach_money, isDark),
            const SizedBox(height: 8),
            _buildInfoRow('Toplam Değer', '${CurrencyHelper.getCurrencySymbol(stock.currency)}${stock.totalValue.toStringAsFixed(2)}', Icons.calculate, isDark),
            const SizedBox(height: 8),
            warehousesAsync.when(
              data: (warehouses) {
                final warehouse = warehouses.firstWhere(
                  (w) => w.id == stock.warehouseId,
                  orElse: () => warehouses.first,
                );
                return _buildInfoRow('Depo', warehouse.name, Icons.warehouse, isDark);
              },
              loading: () => _buildInfoRow('Depo', '...', Icons.warehouse, isDark),
              error: (error, stack) => _buildInfoRow('Depo', 'Hata', Icons.warehouse, isDark),
            ),
            if (stock.location != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Konum', stock.location!, Icons.location_on, isDark),
            ],
            if (stock.notes != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Notlar', stock.notes!, Icons.note, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStockStats(Stock stock, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stok İstatistikleri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Minimum',
                    stock.minimumQuantity.toStringAsFixed(0),
                    Icons.trending_down,
                    Colors.red,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Maksimum',
                    stock.maximumQuantity.toStringAsFixed(0),
                    Icons.trending_up,
                    Colors.green,
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Stok Yüzdesi',
              '${stock.stockPercentage.toStringAsFixed(1)}%',
              Icons.pie_chart,
              Colors.blue,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? TamgaciConstants.textSecondaryDark : TamgaciConstants.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? TamgaciConstants.textSecondaryDark : TamgaciConstants.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : TamgaciConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Stock stock, bool isDark, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İşlemler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/stock/edit',
                        arguments: stock.id.toString(),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(
                      'Düzenle',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TamgaciConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showDeleteConfirmation(context, stock);
                    },
                    icon: const Icon(Icons.delete),
                    label: Text(
                      'Sil',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2,
            size: 64,
            color: isDark ? Colors.grey : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Stok bulunamadı',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : TamgaciConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aradığınız stok kaydı mevcut değil',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.grey : Colors.grey[600],
            ),
          ),
        ],
      ),
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
              style: GoogleFonts.poppins(color: TamgaciConstants.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
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
