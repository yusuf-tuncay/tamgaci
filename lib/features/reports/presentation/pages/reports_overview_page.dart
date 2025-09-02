// ========== REPORTS (RAPORLAR) FEATURE ==========
// lib/features/reports/presentation/pages/reports_overview_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../providers/reports_providers.dart';
import '../../../../core/providers/currency_providers.dart';

/// Raporlar ana sayfası
class ReportsOverviewPage extends ConsumerStatefulWidget {
  const ReportsOverviewPage({super.key});

  @override
  ConsumerState<ReportsOverviewPage> createState() =>
      _ReportsOverviewPageState();
}

class _ReportsOverviewPageState extends ConsumerState<ReportsOverviewPage> {
  String _selectedPeriod = 'Bu Ay';

  @override
  Widget build(BuildContext context) {
    final reportsSummaryAsync = ref.watch(reportsSummaryProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TamgaciConstants.backgroundColorDark : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Raporlar',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _showExportDialog,
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Rapor verilerini yenile
          ref.invalidate(reportsSummaryProvider);
          ref.invalidate(incomeExpenseReportProvider);
          ref.invalidate(customerReportProvider);
          ref.invalidate(supplierReportProvider);
          ref.invalidate(productReportProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: TamgaciConstants.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dönem seçici
              _buildPeriodSelector(),

              const SizedBox(height: 24),

              // Özet kartları
              reportsSummaryAsync.when(
                data: (summary) => _buildSummaryCards(summary),
                loading: () => _buildSummaryCardsLoading(),
                error: (error, stack) => _buildSummaryCardsError(error),
              ),

              const SizedBox(height: 24),

              // Grafik bölümü
              _buildChartSection(),

              const SizedBox(height: 24),

              // Detaylı raporlar
              _buildDetailedReports(),
            ],
          ),
        ),
      ),
    );
  }

  /// Dönem seçici oluşturur
  Widget _buildPeriodSelector() {
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rapor Dönemi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TamgaciConstants.textPrimary,
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
                      'Para Birimi: ${CurrencyHelper.getCurrencySymbol(selectedCurrency.code)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['Bugün', 'Bu Hafta', 'Bu Ay', 'Bu Yıl', 'Özel']
                  .map(
                    (period) => ChoiceChip(
                      label: Text(period),
                      selected: _selectedPeriod == period,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedPeriod = period;
                          });
                        }
                      },
                      selectedColor: TamgaciConstants.primaryColor.withValues(
                        alpha: 0.2,
                      ),
                      labelStyle: GoogleFonts.poppins(
                        color: _selectedPeriod == period
                            ? TamgaciConstants.primaryColor
                            : TamgaciConstants.textSecondary,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Özet kartları oluşturur
  Widget _buildSummaryCards(ReportsSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özet',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Toplam Gelir',
                value: summary.formattedTotalIncome,
                change: summary.formattedIncomeChange,
                isPositive: summary.incomeChangePercent >= 0,
                icon: Icons.trending_up,
                color: TamgaciConstants.successColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                title: 'Toplam Gider',
                value: summary.formattedTotalExpense,
                change: summary.formattedExpenseChange,
                isPositive: summary.expenseChangePercent < 0,
                icon: Icons.trending_down,
                color: TamgaciConstants.errorColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Net Kar',
                value: summary.formattedNetProfit,
                change: summary.formattedNetProfitChange,
                isPositive: summary.netProfitChangePercent >= 0,
                icon: Icons.account_balance_wallet,
                color: TamgaciConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                title: 'İşlem Sayısı',
                value: '${summary.totalTransactions}',
                change: summary.formattedTransactionChange,
                isPositive: summary.transactionChangePercent >= 0,
                icon: Icons.receipt_long,
                color: TamgaciConstants.infoColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Özet kartları loading
  Widget _buildSummaryCardsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özet',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: TamgaciConstants.cardColor,
                  borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
                  boxShadow: TamgaciConstants.shadowLight,
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: TamgaciConstants.cardColor,
                  borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
                  boxShadow: TamgaciConstants.shadowLight,
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Özet kartları error
  Widget _buildSummaryCardsError(Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TamgaciConstants.cardColor,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        boxShadow: TamgaciConstants.shadowLight,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: TamgaciConstants.errorColor,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Rapor verileri yüklenirken hata oluştu',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: TamgaciConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Özet kartı oluşturur
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      TamgaciConstants.radiusSM,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isPositive
                                ? TamgaciConstants.successColor
                                : TamgaciConstants.errorColor)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      TamgaciConstants.radiusXS,
                    ),
                  ),
                  child: Text(
                    change,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPositive
                          ? TamgaciConstants.successColor
                          : TamgaciConstants.errorColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grafik bölümünü oluşturur
  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gelir-Gider Grafiği',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
          ),
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Basit grafik simülasyonu
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBarChart('Oca', 80, TamgaciConstants.successColor),
                      _buildBarChart('Şub', 65, TamgaciConstants.successColor),
                      _buildBarChart('Mar', 90, TamgaciConstants.successColor),
                      _buildBarChart('Nis', 75, TamgaciConstants.successColor),
                      _buildBarChart('May', 85, TamgaciConstants.successColor),
                      _buildBarChart('Haz', 95, TamgaciConstants.successColor),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem('Gelir', TamgaciConstants.successColor),
                    _buildLegendItem('Gider', TamgaciConstants.errorColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Bar grafik oluşturur
  Widget _buildBarChart(String label, double percentage, Color color) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusXS),
              ),
              height: percentage * 2, // Yükseklik yüzdeye göre
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: TamgaciConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Grafik açıklaması oluşturur
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: TamgaciConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Detaylı raporlar bölümünü oluşturur
  Widget _buildDetailedReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detaylı Raporlar',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildReportCard(
              title: 'Gelir-Gider Raporu',
              subtitle: 'Aylık gelir ve gider analizi',
              icon: Icons.trending_up_outlined,
              color: TamgaciConstants.primaryColor,
              onTap: () =>
                  Navigator.of(context).pushNamed('/reports/income-expense'),
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              title: 'Müşteri Raporu',
              subtitle: 'Müşteri performans analizi',
              icon: Icons.people_outlined,
              color: TamgaciConstants.successColor,
              onTap: () => Navigator.of(context).pushNamed('/reports/customer'),
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              title: 'Tedarikçi Raporu',
              subtitle: 'Tedarikçi performans analizi',
              icon: Icons.business_outlined,
              color: TamgaciConstants.infoColor,
              onTap: () => Navigator.of(context).pushNamed('/reports/supplier'),
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              title: 'Ürün Raporu',
              subtitle: 'Ürün satış analizi',
              icon: Icons.inventory_2_outlined,
              color: TamgaciConstants.warningColor,
              onTap: () => Navigator.of(context).pushNamed('/reports/product'),
            ),
          ],
        ),
      ],
    );
  }

  /// Rapor kartı oluşturur
  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusSM,
                  ),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TamgaciConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: TamgaciConstants.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dışa aktarma dialog'unu gösterir
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rapor Dışa Aktar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: () {
                Navigator.of(context).pop();
                _exportToPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel'),
              onTap: () {
                Navigator.of(context).pop();
                _exportToExcel();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  /// PDF'e dışa aktar
  void _exportToPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF dışa aktarma özelliği yakında eklenecek.'),
      ),
    );
  }

  /// Excel'e dışa aktar
  void _exportToExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel dışa aktarma özelliği yakında eklenecek.'),
      ),
    );
  }
}
