// ========== INVENTORY PAGE ==========
// lib/features/inventory/presentation/pages/inventory_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../core/providers/currency_providers.dart';
import '../providers/warehouse_providers.dart';
import '../providers/stock_providers.dart';
import '../../../warehouses/presentation/pages/warehouses_home_page.dart';
import 'stock_list_page.dart';

/// Inventory Sayfası
class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(showDrawer: true),
      drawer: const TamgaciDrawerMenu(),
      body: _buildBody(isDark, ref, context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Stok işlemi ekleme
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(bool isDark, WidgetRef ref, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(isDark),
          const SizedBox(height: 16),
          _buildQuickActions(isDark, context),
          const SizedBox(height: 16),
          _buildStockOverview(isDark, ref),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.orange.withValues(alpha: 0.8), Colors.orange]
              : [Colors.orange, Colors.orange.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warehouse,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Depo Stok Yönetimi',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Stok hareketlerini takip edin ve yönetin',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TamgaciConstants.borderColor : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İşlemler',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : TamgaciConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard('Stok Girişi', Icons.add_box, Colors.green, () {
                // Stok girişi
              }, isDark),
              _buildActionCard('Stok Çıkışı', Icons.remove_circle, Colors.red,
                  () {
                // Stok çıkışı
              }, isDark),
              _buildActionCard('Stok Düzeltme', Icons.edit, Colors.blue, () {
                // Stok düzeltme
              }, isDark),
              _buildActionCard('Depo Listesi', Icons.list, Colors.purple, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WarehousesHomePage(),
                  ),
                );
              }, isDark),
              _buildActionCard('Stok Listesi', Icons.inventory, Colors.teal,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StockListPage(),
                  ),
                );
              }, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color,
      VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockOverview(bool isDark, WidgetRef ref) {
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final warehousesAsync = ref.watch(warehousesProvider);
    final stocksAsync = ref.watch(stocksProvider);
    final lowStocksAsync = ref.watch(lowStocksProvider);
    final totalStockValueAsync = ref.watch(totalStockValueProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TamgaciConstants.borderColor : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Depo Durumu',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.currency_exchange,
                    size: 16,
                    color: TamgaciConstants.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    CurrencyHelper.getCurrencySymbol(selectedCurrency.code),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          warehousesAsync.when(
            data: (warehouses) => stocksAsync.when(
              data: (stocks) => lowStocksAsync.when(
                data: (lowStocks) => totalStockValueAsync.when(
                  data: (totalStockValue) {
                    final totalCapacity = warehouses.fold<double>(
                        0, (sum, warehouse) => sum + (warehouse.capacity ?? 0));
                    final activeWarehouses =
                        warehouses.where((w) => w.isActive).length;
                    final defaultWarehouse =
                        warehouses.where((w) => w.isDefault).firstOrNull;

                    return Column(
                      children: [
                        _buildStockItem(
                            'Toplam Depo',
                            warehouses.length.toString(),
                            Icons.warehouse,
                            Colors.blue,
                            isDark),
                        const SizedBox(height: 8),
                        _buildStockItem(
                            'Aktif Depo',
                            activeWarehouses.toString(),
                            Icons.check_circle,
                            Colors.green,
                            isDark),
                        const SizedBox(height: 8),
                        _buildStockItem(
                            'Toplam Kapasite',
                            '${totalCapacity.toStringAsFixed(0)} m²',
                            Icons.straighten,
                            Colors.orange,
                            isDark),
                        const SizedBox(height: 8),
                        _buildStockItem(
                            'Varsayılan Depo',
                            defaultWarehouse?.name ?? 'Yok',
                            Icons.star,
                            Colors.purple,
                            isDark),
                        const SizedBox(height: 8),
                        _buildStockItem('Toplam Stok', stocks.length.toString(),
                            Icons.inventory, Colors.indigo, isDark),
                        const SizedBox(height: 8),
                        _buildStockItem(
                            'Düşük Stok',
                            lowStocks.length.toString(),
                            Icons.warning,
                            Colors.red,
                            isDark),
                        const SizedBox(height: 8),
                        _buildStockItem(
                            'Toplam Değer',
                            '₺${totalStockValue.toStringAsFixed(0)}',
                            Icons.attach_money,
                            Colors.teal,
                            isDark),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Hata: $error'),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Hata: $error'),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Hata: $error'),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Hata: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildStockItem(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
