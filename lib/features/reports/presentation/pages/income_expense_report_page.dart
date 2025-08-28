// ========== INCOME EXPENSE REPORT PAGE ==========
// lib/features/reports/presentation/pages/income_expense_report_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';

/// Gelir-Gider analiz raporu sayfası
class IncomeExpenseReportPage extends ConsumerStatefulWidget {
  const IncomeExpenseReportPage({super.key});

  @override
  ConsumerState<IncomeExpenseReportPage> createState() =>
      _IncomeExpenseReportPageState();
}

class _IncomeExpenseReportPageState
    extends ConsumerState<IncomeExpenseReportPage> {
  String _selectedPeriod = 'Bu Ay';
  final String _selectedView = 'Özet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Gelir-Gider Raporu',
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
                  const Icon(Icons.bar_chart, size: 20),
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
      case 'Özet':
        return _buildSummaryView();
      case 'Grafik':
        return _buildChartView();
      case 'Detay':
        return _buildDetailView();
      default:
        return _buildSummaryView();
    }
  }

  Widget _buildSummaryView() {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    // Mock veri
    const totalIncome = 125000.0;
    const totalExpense = 85000.0;
    final netIncome = totalIncome - totalExpense;
    final profitMargin = (netIncome / totalIncome) * 100;

    return SingleChildScrollView(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        children: [
          // Özet kartları
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Toplam Gelir',
                  amount: totalIncome,
                  color: Colors.green,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Toplam Gider',
                  amount: totalExpense,
                  color: Colors.red,
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Net gelir kartı
          _buildNetIncomeCard(netIncome, profitMargin),

          const SizedBox(height: 24),

          // Kategori bazlı analiz
          _buildCategoryAnalysis(),

          const SizedBox(height: 24),

          // Aylık karşılaştırma
          _buildMonthlyComparison(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

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
                    color: color.withOpacity(0.1),
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
              currencyFormat.format(amount),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetIncomeCard(double netIncome, double profitMargin) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final isPositive = netIncome >= 0;

    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          children: [
            Text(
              'Net Gelir',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: TamgaciConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(netIncome.abs()),
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isPositive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${isPositive ? '+' : '-'}%${profitMargin.abs().toStringAsFixed(1)} Kar Marjı',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAnalysis() {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori Bazlı Analiz',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Gelir kategorileri
            _buildCategoryItem('Satış Gelirleri', 75000.0, Colors.green, 0.6),
            _buildCategoryItem('Hizmet Gelirleri', 35000.0, Colors.green, 0.28),
            _buildCategoryItem('Diğer Gelirler', 15000.0, Colors.green, 0.12),

            const Divider(height: 32),

            // Gider kategorileri
            _buildCategoryItem('Personel Giderleri', 40000.0, Colors.red, 0.47),
            _buildCategoryItem('Ofis Giderleri', 25000.0, Colors.red, 0.29),
            _buildCategoryItem('Pazarlama', 15000.0, Colors.red, 0.18),
            _buildCategoryItem('Diğer Giderler', 5000.0, Colors.red, 0.06),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    String name,
    double amount,
    Color color,
    double percentage,
  ) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              currencyFormat.format(amount),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
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

  Widget _buildMonthlyComparison() {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aylık Karşılaştırma',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Basit bar chart (gerçek chart kütüphanesi eklenecek)
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBarChartItem('Oca', 80000, 60000),
                  _buildBarChartItem('Şub', 90000, 65000),
                  _buildBarChartItem('Mar', 110000, 70000),
                  _buildBarChartItem('Nis', 95000, 75000),
                  _buildBarChartItem('May', 125000, 85000),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartItem(String month, double income, double expense) {
    const maxValue = 125000.0;
    final incomeHeight = (income / maxValue) * 150;
    final expenseHeight = (expense / maxValue) * 150;

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 20,
                height: incomeHeight,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 20,
                height: expenseHeight,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          month,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: TamgaciConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChartView() {
    return const Center(child: Text('Grafik görünümü yakında eklenecek'));
  }

  Widget _buildDetailView() {
    return const Center(child: Text('Detay görünümü yakında eklenecek'));
  }

  void _showPeriodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dönem Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              [
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
      const SnackBar(content: Text('Rapor export özelliği yakında eklenecek')),
    );
  }
}
