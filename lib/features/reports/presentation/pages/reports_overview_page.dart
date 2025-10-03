// ========== REPORTS (RAPORLAR) FEATURE ==========
// lib/features/reports/presentation/pages/reports_overview_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';

/// Raporlar ana sayfası
class ReportsOverviewPage extends ConsumerStatefulWidget {
  const ReportsOverviewPage({super.key});

  @override
  ConsumerState<ReportsOverviewPage> createState() =>
      _ReportsOverviewPageState();
}

class _ReportsOverviewPageState extends ConsumerState<ReportsOverviewPage> {
  String _selectedPeriod = 'Bu Ay';
  String _selectedReportType = 'Tümü';
  bool _showFavorites = false;

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TamgaciConstants.primaryColor,
            Color(0xFF4C6EF5),
            TamgaciConstants.primaryColorDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: TamgaciConstants.primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Raporlar',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'İşletme raporlarını görüntüleyin ve analiz edin',
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 8),
          Text(
            'Bugün: ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now())}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// Filtreleme ve arama bölümü oluşturur
  Widget _buildFiltersSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                Icons.filter_list,
                color: TamgaciConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtreler',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              const Spacer(),
              if (_showFavorites)
                IconButton(
                  onPressed: () => setState(() => _showFavorites = false),
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  tooltip: 'Favorileri gizle',
                )
              else
                IconButton(
                  onPressed: () => setState(() => _showFavorites = true),
                  icon: const Icon(Icons.favorite_border, color: Colors.grey),
                  tooltip: 'Favorileri göster',
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  'Rapor Türü',
                  _selectedReportType,
                  () => _showReportTypeDialog(),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterChip(
                  'Dönem',
                  _selectedPeriod,
                  () => _showPeriodDialog(),
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Filtre chip'i oluşturur
  Widget _buildFilterChip(
      String label, String value, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  /// Rapor türü dialog'u gösterir
  void _showReportTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rapor Türü Seçin', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Tümü', _selectedReportType == 'Tümü'),
            _buildDialogOption(
                'Satış Raporları', _selectedReportType == 'Satış Raporları'),
            _buildDialogOption(
                'Mali Raporlar', _selectedReportType == 'Mali Raporlar'),
            _buildDialogOption(
                'Stok Raporları', _selectedReportType == 'Stok Raporları'),
            _buildDialogOption('Müşteri Raporları',
                _selectedReportType == 'Müşteri Raporları'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  /// Dönem dialog'u gösterir
  void _showPeriodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dönem Seçin', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Bu Hafta', _selectedPeriod == 'Bu Hafta'),
            _buildDialogOption('Bu Ay', _selectedPeriod == 'Bu Ay'),
            _buildDialogOption('Son 3 Ay', _selectedPeriod == 'Son 3 Ay'),
            _buildDialogOption('Bu Yıl', _selectedPeriod == 'Bu Yıl'),
            _buildDialogOption('Özel Tarih', _selectedPeriod == 'Özel Tarih'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  /// Dialog seçenek oluşturur
  Widget _buildDialogOption(String title, bool isSelected) {
    return ListTile(
      title: Text(title, style: GoogleFonts.poppins()),
      leading: Checkbox(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (title == 'Rapor Türü') {
              _selectedReportType = title;
            } else {
              _selectedPeriod = title;
            }
          });
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() {
          if (title == 'Rapor Türü') {
            _selectedReportType = title;
          } else {
            _selectedPeriod = title;
          }
        });
        Navigator.pop(context);
      },
    );
  }

  /// Dönem seçici oluşturur
  Widget _buildPeriodSelector() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: TamgaciConstants.paddingMedium(context),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: TamgaciConstants.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Dönem: ',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textSecondary,
              ),
            ),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                isExpanded: true,
                underline: const SizedBox(),
                items: ['Bu Hafta', 'Bu Ay', 'Son 3 Ay', 'Bu Yıl', 'Özel Tarih']
                    .map((period) => DropdownMenuItem(
                          value: period,
                          child: Text(
                            period,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsSummaryAsync = AsyncValue.data(_DummyReportsSummary());

    return ResponsiveScaffold(
      appBar: CustomAppBar(
        title: 'Raporlar',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _showExportDialog,
            icon: const Icon(Icons.download),
            tooltip: 'Dışa Aktar',
          ),
          IconButton(
            onPressed: _showCreateReportDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Yeni Rapor',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  // Refresh logic
                  break;
                case 'settings':
                  // Settings logic
                  break;
                case 'help':
                  // Help logic
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 8),
                    Text('Yenile', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, size: 20),
                    const SizedBox(width: 8),
                    Text('Ayarlar', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    const Icon(Icons.help, size: 20),
                    const SizedBox(width: 8),
                    Text('Yardım', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: Consumer(
        builder: (context, ref, child) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildWelcomeCard(isDark),
              ),

              // Filtreleme ve arama bölümü
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildFiltersSection(isDark),
                ),
              ),

              // Dönem seçici
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildPeriodSelector(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Özet kartları
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: reportsSummaryAsync.when(
                    data: (summary) => _buildSummaryCards(summary, isDark),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Hata: $error'),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Grafik bölümü
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildChartSection(isDark),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Detaylı raporlar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildDetailedReports(),
                ),
              ),

              // Son boşluk
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  /// Özet kartları oluşturur
  Widget _buildSummaryCards(_DummyReportsSummary summary, bool isDark) {
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
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              'Toplam Gelir',
              CurrencyHelper.formatCurrency(summary.totalIncome, 'TRY'),
              Icons.trending_up,
              TamgaciConstants.successColor,
              isDark,
            ),
            _buildSummaryCard(
              'Toplam Gider',
              CurrencyHelper.formatCurrency(summary.totalExpense, 'TRY'),
              Icons.trending_down,
              TamgaciConstants.errorColor,
              isDark,
            ),
            _buildSummaryCard(
              'Net Kar',
              CurrencyHelper.formatCurrency(summary.netProfit, 'TRY'),
              Icons.account_balance_wallet,
              TamgaciConstants.primaryColor,
              isDark,
            ),
            _buildSummaryCard(
              'Aktif Müşteri',
              '${summary.activeCustomers}',
              Icons.people,
              TamgaciConstants.infoColor,
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  /// Özet kartı oluşturur
  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.05),
              color.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.trending_up,
                    color: color,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Son 30 gün',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: TamgaciConstants.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Grafik bölümü oluşturur
  Widget _buildChartSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gelir-Gider Trendi',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
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
        Row(
          children: [
            Text(
              'Detaylı Raporlar',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => _showCreateReportDialog(),
              icon: const Icon(Icons.add_circle_outline,
                  color: TamgaciConstants.primaryColor),
              tooltip: 'Yeni Rapor Oluştur',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            // Satış Raporları
            if (_selectedReportType == 'Tümü' ||
                _selectedReportType == 'Satış Raporları') ...[
              _buildReportCard(
                title: 'Gelir-Gider Raporu',
                subtitle: 'Aylık gelir ve gider analizi',
                icon: Icons.trending_up_outlined,
                color: TamgaciConstants.primaryColor,
                onTap: () =>
                    Navigator.of(context).pushNamed('/reports/income-expense'),
                isFavorite: true,
                lastGenerated:
                    DateTime.now().subtract(const Duration(hours: 2)),
              ),
              _buildReportCard(
                title: 'Satış Performans Raporu',
                subtitle: 'Satış ekibi ve ürün performansı',
                icon: Icons.bar_chart_outlined,
                color: TamgaciConstants.successColor,
                onTap: () => Navigator.of(context)
                    .pushNamed('/reports/sales-performance'),
                isFavorite: false,
                lastGenerated: DateTime.now().subtract(const Duration(days: 1)),
              ),
              _buildReportCard(
                title: 'Müşteri Analiz Raporu',
                subtitle: 'Müşteri segmentasyonu ve davranış analizi',
                icon: Icons.people_outline,
                color: TamgaciConstants.warningColor,
                onTap: () => Navigator.of(context)
                    .pushNamed('/reports/customer-analysis'),
                isFavorite: true,
                lastGenerated: DateTime.now().subtract(const Duration(days: 3)),
              ),
            ],

            // Mali Raporlar
            if (_selectedReportType == 'Tümü' ||
                _selectedReportType == 'Mali Raporlar') ...[
              _buildReportCard(
                title: 'Nakit Akış Raporu',
                subtitle: 'Giriş ve çıkış nakit akışı',
                icon: Icons.account_balance_wallet_outlined,
                color: TamgaciConstants.infoColor,
                onTap: () =>
                    Navigator.of(context).pushNamed('/reports/cash-flow'),
                isFavorite: false,
                lastGenerated:
                    DateTime.now().subtract(const Duration(hours: 6)),
              ),
              _buildReportCard(
                title: 'Kar-Zarar Raporu',
                subtitle: 'Detaylı kar-zarar analizi',
                icon: Icons.account_balance_outlined,
                color: TamgaciConstants.errorColor,
                onTap: () =>
                    Navigator.of(context).pushNamed('/reports/profit-loss'),
                isFavorite: true,
                lastGenerated: DateTime.now().subtract(const Duration(days: 2)),
              ),
            ],

            // Stok Raporları
            if (_selectedReportType == 'Tümü' ||
                _selectedReportType == 'Stok Raporları') ...[
              _buildReportCard(
                title: 'Stok Durum Raporu',
                subtitle: 'Mevcut stok seviyeleri ve uyarılar',
                icon: Icons.inventory_2_outlined,
                color: TamgaciConstants.secondaryColor,
                onTap: () => Navigator.of(context)
                    .pushNamed('/reports/inventory-status'),
                isFavorite: false,
                lastGenerated:
                    DateTime.now().subtract(const Duration(hours: 4)),
              ),
              _buildReportCard(
                title: 'Stok Hareket Raporu',
                subtitle: 'Giriş-çıkış hareketleri',
                icon: Icons.swap_horiz_outlined,
                color: TamgaciConstants.primaryColor,
                onTap: () => Navigator.of(context)
                    .pushNamed('/reports/inventory-movement'),
                isFavorite: true,
                lastGenerated: DateTime.now().subtract(const Duration(days: 1)),
              ),
            ],

            // Müşteri Raporları
            if (_selectedReportType == 'Tümü' ||
                _selectedReportType == 'Müşteri Raporları') ...[
              _buildReportCard(
                title: 'Müşteri Ödeme Raporu',
                subtitle: 'Ödeme geçmişi ve risk analizi',
                icon: Icons.payment_outlined,
                color: TamgaciConstants.warningColor,
                onTap: () => Navigator.of(context)
                    .pushNamed('/reports/customer-payments'),
                isFavorite: false,
                lastGenerated: DateTime.now().subtract(const Duration(days: 5)),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Yeni rapor oluşturma dialog'u gösterir
  void _showCreateReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yeni Rapor Oluştur', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.trending_up,
                  color: TamgaciConstants.primaryColor),
              title: Text('Gelir-Gider Raporu', style: GoogleFonts.poppins()),
              subtitle: Text('Aylık gelir ve gider analizi',
                  style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/reports/income-expense');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart,
                  color: TamgaciConstants.successColor),
              title:
                  Text('Satış Performans Raporu', style: GoogleFonts.poppins()),
              subtitle: Text('Satış ekibi ve ürün performansı',
                  style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/reports/sales-performance');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance,
                  color: TamgaciConstants.infoColor),
              title: Text('Nakit Akış Raporu', style: GoogleFonts.poppins()),
              subtitle: Text('Giriş ve çıkış nakit akışı',
                  style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/reports/cash-flow');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  /// Rapor kartı oluşturur
  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFavorite = false,
    DateTime? lastGenerated,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  Row(
                    children: [
                      if (isFavorite)
                        const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
              if (lastGenerated != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TamgaciConstants.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 12,
                        color: TamgaciConstants.successColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Son oluşturulma: ${DateFormat('dd/MM HH:mm').format(lastGenerated)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: TamgaciConstants.successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        title: Text('Dışa Aktar', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text('PDF', style: GoogleFonts.poppins()),
              subtitle: Text('PDF formatında dışa aktar',
                  style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                // PDF export logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: Text('Excel', style: GoogleFonts.poppins()),
              subtitle: Text('Excel formatında dışa aktar',
                  style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                // Excel export logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: Text('Resim', style: GoogleFonts.poppins()),
              subtitle: Text('PNG formatında dışa aktar',
                  style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                // Image export logic
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}

/// Dummy rapor özeti sınıfı
class _DummyReportsSummary {
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final int activeCustomers;

  _DummyReportsSummary()
      : totalIncome = 125000.0,
        totalExpense = 85000.0,
        netProfit = 40000.0,
        activeCustomers = 156;
}
