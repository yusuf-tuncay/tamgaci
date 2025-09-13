// ========== DASHBOARD PAGE ==========
// lib/features/dashboard/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/providers/currency_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/exchange_rates_widget.dart';
import '../../../inventory/presentation/providers/warehouse_providers.dart';
import '../../../inventory/presentation/providers/stock_providers.dart';

/// Dashboard Sayfası
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard', showDrawer: true),
      drawer: const TamgaciDrawerMenu(),
      body: _buildMobileLayout(dashboardSummaryAsync, isDark),
    );
  }

  Widget _buildMobileLayout(
      AsyncValue<DashboardSummary> dashboardSummaryAsync, bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh dashboard data and exchange rates
        ref.invalidate(exchangeRatesProvider);
        ref.invalidate(dashboardSummaryProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(isDark),
            const SizedBox(height: 16),
            _buildQuickStats(dashboardSummaryAsync, isDark),
            const SizedBox(height: 16),
            _buildQuickActions(isDark),
            const SizedBox(height: 16),
            const ExchangeRatesWidget(),
            const SizedBox(height: 16),
            _buildRecentActivities(isDark),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildTabletLayout(
      AsyncValue<DashboardSummary> dashboardSummaryAsync, bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh dashboard data and exchange rates
        ref.invalidate(exchangeRatesProvider);
        ref.invalidate(dashboardSummaryProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(flex: 2, child: _buildWelcomeCard(isDark)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildQuickStats(dashboardSummaryAsync, isDark)),
              ],
            ),
            const SizedBox(height: 24),
            _buildQuickActions(isDark),
            const SizedBox(height: 24),
            _buildRecentActivities(isDark),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildDesktopLayout(
      AsyncValue<DashboardSummary> dashboardSummaryAsync, bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh dashboard data and exchange rates
        ref.invalidate(exchangeRatesProvider);
        ref.invalidate(dashboardSummaryProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(flex: 3, child: _buildWelcomeCard(isDark)),
                const SizedBox(width: 24),
                Expanded(
                    flex: 2,
                    child: _buildQuickStats(dashboardSummaryAsync, isDark)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildQuickActions(isDark)),
                const SizedBox(width: 24),
                Expanded(flex: 3, child: _buildRecentActivities(isDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  TamgaciConstants.primaryColor.withValues(alpha: 0.8),
                  TamgaciConstants.primaryColor
                ]
              : [
                  TamgaciConstants.primaryColor,
                  TamgaciConstants.primaryColor.withValues(alpha: 0.8)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TamgaciConstants.primaryColor.withValues(alpha: 0.3),
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
                Icons.dashboard,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hoş Geldiniz!',
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
            'Tamgaci İş Yönetim Sistemi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bugün: ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now())}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
      AsyncValue<DashboardSummary> dashboardSummaryAsync, bool isDark) {
    final warehousesAsync = ref.watch(warehousesProvider);
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
          Text(
            'Hızlı İstatistikler',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : TamgaciConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatItem(
              'Toplam Müşteri', '12', Icons.people, Colors.blue, isDark),
          const SizedBox(height: 8),
          _buildStatItem(
              'Toplam Ürün', '45', Icons.inventory, Colors.orange, isDark),
          const SizedBox(height: 8),
          warehousesAsync.when(
            data: (warehouses) {
              final activeWarehouses =
                  warehouses.where((w) => w.isActive).length;
              return _buildStatItem('Aktif Depo', activeWarehouses.toString(),
                  Icons.warehouse, Colors.green, isDark);
            },
            loading: () => _buildStatItem(
                'Aktif Depo', '...', Icons.warehouse, Colors.green, isDark),
            error: (error, stack) => _buildStatItem(
                'Aktif Depo', '0', Icons.warehouse, Colors.green, isDark),
          ),
          const SizedBox(height: 8),
          lowStocksAsync.when(
            data: (lowStocks) => _buildStatItem('Düşük Stok',
                lowStocks.length.toString(), Icons.warning, Colors.red, isDark),
            loading: () => _buildStatItem(
                'Düşük Stok', '...', Icons.warning, Colors.red, isDark),
            error: (error, stack) => _buildStatItem(
                'Düşük Stok', '0', Icons.warning, Colors.red, isDark),
          ),
          const SizedBox(height: 8),
          totalStockValueAsync.when(
            data: (totalStockValue) => _buildStatItem(
                'Stok Değeri',
                '₺${totalStockValue.toStringAsFixed(0)}',
                Icons.attach_money,
                Colors.purple,
                isDark),
            loading: () => _buildStatItem('Stok Değeri', '...',
                Icons.attach_money, Colors.purple, isDark),
            error: (error, stack) => _buildStatItem(
                'Stok Değeri', '₺0', Icons.attach_money, Colors.purple, isDark),
          ),
          const SizedBox(height: 8),
          _buildStatItem(
              'Bekleyen Fatura', '5', Icons.receipt, Colors.red, isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(
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
                      ? TamgaciConstants.textSecondaryDark
                      : TamgaciConstants.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isDark) {
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
              _buildActionCard('Fatura Oluştur', Icons.receipt_long,
                  TamgaciConstants.primaryColor, () {
                Navigator.of(context).pushNamed(TamgaciRoutes.invoicesList);
              }, isDark),
              _buildActionCard('Gider Ekle', Icons.remove_circle, Colors.red,
                  () {
                Navigator.of(context).pushNamed(TamgaciRoutes.createExpense);
              }, isDark),
              _buildActionCard('Gelir Ekle', Icons.add_circle, Colors.green,
                  () {
                Navigator.of(context).pushNamed(TamgaciRoutes.createIncome);
              }, isDark),
              _buildActionCard('Ürün Ekle', Icons.inventory_2, Colors.orange,
                  () {
                Navigator.of(context).pushNamed(TamgaciRoutes.createProduct);
              }, isDark),
              _buildActionCard('Müşteri Ekle', Icons.person_add, Colors.blue,
                  () {
                Navigator.of(context).pushNamed(TamgaciRoutes.createCustomer);
              }, isDark),
              _buildActionCard('Stok İşlemi', Icons.warehouse, Colors.purple,
                  () {
                Navigator.of(context).pushNamed(TamgaciRoutes.inventory);
              }, isDark),
              _buildActionCard('Depo Listesi', Icons.list, Colors.indigo, () {
                Navigator.of(context).pushNamed(TamgaciRoutes.warehouseList);
              }, isDark),
              _buildActionCard('Stok Listesi', Icons.inventory, Colors.teal,
                  () {
                Navigator.of(context).pushNamed(TamgaciRoutes.stockList);
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
                color: isDark ? Colors.white : TamgaciConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(bool isDark) {
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
                'Son Aktiviteler',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(TamgaciRoutes.expensesList);
                },
                child: Text(
                  'Tümünü Gör',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: TamgaciConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEmptyActivities(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyActivities(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: isDark
                ? TamgaciConstants.textSecondaryDark
                : TamgaciConstants.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz aktivite yok',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
