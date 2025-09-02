// ========== PRODUCT REPORT PAGE ==========
// lib/features/reports/presentation/pages/product_report_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';

/// Ürün analiz raporu sayfası
class ProductReportPage extends ConsumerStatefulWidget {
  const ProductReportPage({super.key});

  @override
  ConsumerState<ProductReportPage> createState() => _ProductReportPageState();
}

class _ProductReportPageState extends ConsumerState<ProductReportPage> {
  String _selectedPeriod = 'Bu Ay';
  final String _selectedView = 'Genel Bakış';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Ürün Raporu',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _showPeriodDialog,
            icon: const Icon(Icons.date_range),
            tooltip: 'Dönem Seç',
          ),
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download),
            tooltip: 'Rapor İndir',
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          // Filtre çubuğu
          _buildFilterBar(),

          // Rapor içeriği
          Expanded(child: _buildReportContent()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: TamgaciConstants.paddingMedium(context),
      child: Row(
        children: [
          // Dönem seçici
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: TamgaciConstants.borderColor),
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _selectedPeriod,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Görünüm seçici
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: TamgaciConstants.borderColor),
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _selectedView,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    switch (_selectedView) {
      case 'Genel Bakış':
        return _buildOverviewView();
      case 'En Çok Satanlar':
        return _buildTopSellersView();
      case 'Stok Durumu':
        return _buildStockStatusView();
      case 'Karlılık':
        return _buildProfitabilityView();
      default:
        return _buildOverviewView();
    }
  }

  Widget _buildOverviewView() {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    // Mock veri
    const totalProducts = 156;
    const activeProducts = 142;
    const lowStockProducts = 8;
    const outOfStockProducts = 6;
    const totalRevenue = 450000.0;
    const totalCost = 320000.0;
    const totalProfit = totalRevenue - totalCost;
    const profitMargin = (totalProfit / totalRevenue) * 100;

    return SingleChildScrollView(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        children: [
          // Özet kartları
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Toplam Ürün',
                  value: totalProducts.toString(),
                  subtitle: 'Aktif: $activeProducts',
                  color: Colors.blue,
                  icon: Icons.inventory,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Toplam Gelir',
                  value: currencyFormat.format(totalRevenue),
                  subtitle: 'Bu dönem',
                  color: Colors.green,
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Toplam Kar',
                  value: currencyFormat.format(totalProfit),
                  subtitle: '%${profitMargin.toStringAsFixed(1)} kar marjı',
                  color: Colors.orange,
                  icon: Icons.monetization_on,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Stok Uyarısı',
                  value: (lowStockProducts + outOfStockProducts).toString(),
                  subtitle:
                      'Düşük: $lowStockProducts, Tükendi: $outOfStockProducts',
                  color: Colors.red,
                  icon: Icons.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Kategori performansı
          _buildCategoryPerformance(),

          const SizedBox(height: 24),

          // En çok satan ürünler
          _buildTopSellingProducts(),

          const SizedBox(height: 24),

          // Stok durumu özeti
          _buildStockSummary(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPerformance() {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori Performansı',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryItem('Elektronik', 45, 180000.0, 0.4),
            _buildCategoryItem('Ofis Ekipmanları', 32, 120000.0, 0.27),
            _buildCategoryItem('Kırtasiye', 28, 80000.0, 0.18),
            _buildCategoryItem('Diğer', 51, 70000.0, 0.15),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    String name,
    int productCount,
    double revenue,
    double percentage,
  ) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$productCount ürün',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              currencyFormat.format(revenue),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '%${(percentage * 100).toStringAsFixed(1)}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingProducts() {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'En Çok Satan Ürünler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildProductItem('Laptop Bilgisayar', 25, 375000.0, 1),
            _buildProductItem('Mouse Kablosuz', 100, 15000.0, 2),
            _buildProductItem('Klavye Mekanik', 3, 2400.0, 3),
            _buildProductItem('Monitör 24"', 0, 0.0, 4),
            _buildProductItem('Yazıcı Lazer', 8, 20000.0, 5),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(String name, int sold, double revenue, int rank) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank <= 3 ? Colors.orange : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$sold adet',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              currencyFormat.format(revenue),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSummary() {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stok Durumu Özeti',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStockItem('Yeterli Stok', 134, Colors.green),
            _buildStockItem('Düşük Stok', 8, Colors.orange),
            _buildStockItem('Stok Tükendi', 6, Colors.red),
            _buildStockItem('Pasif Ürünler', 8, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStockItem(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ),
          Text(
            '$count ürün',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellersView() {
    return const Center(
      child: Text('En çok satanlar detay görünümü yakında eklenecek'),
    );
  }

  Widget _buildStockStatusView() {
    return const Center(
      child: Text('Stok durumu detay görünümü yakında eklenecek'),
    );
  }

  Widget _buildProfitabilityView() {
    return const Center(child: Text('Karlılık analizi yakında eklenecek'));
  }

  void _showPeriodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dönem Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Bu Ay',
            'Geçen Ay',
            'Bu Yıl',
            'Geçen Yıl',
            'Son 3 Ay',
            'Son 6 Ay',
          ].map((period) {
            return ListTile(
              title: Text(period),
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ürün raporu export özelliği yakında eklenecek'),
      ),
    );
  }
}
