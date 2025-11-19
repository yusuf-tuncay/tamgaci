// ========== REPORTS (RAPORLAR) FEATURE ==========
// lib/features/reports/presentation/pages/reports_overview_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../providers/reports_providers.dart';
import '../../domain/entities/report.dart';

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
  final bool _showFavorites = false;
  bool _sortAscending = true;
  bool _filtersExpanded =
      false; // Mobil layout için filtreler açık/kapalı durumu

  Widget _buildWelcomeCard(bool isDark, List<Report> reports) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final secondaryTextColor = onPrimary.withValues(alpha: isDark ? 0.9 : 0.95);
    final borderColor = onPrimary.withValues(alpha: 0.12);
    final dividerColor = onPrimary.withValues(alpha: 0.14);
    final totalReports = reports.length;
    final activeReports =
        reports.where((r) => r.status == ReportStatus.generating).length;
    final completedReports =
        reports.where((r) => r.status == ReportStatus.completed).length;
    final pendingReports =
        reports.where((r) => r.status == ReportStatus.pending).length;

    // Geçici sabit değerler - gelecekte dinamik hale getirilecek
    const totalIncome = 125000.0;
    const totalExpense = 85000.0;

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
        border: Border.all(color: borderColor),
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
          // Başlık ve açıklama
          Row(
            children: [
              Expanded(
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
                        color: onPrimary,
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
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Özet istatistikler - sadece masaüstünde göster
              if (MediaQuery.of(context).size.width > 768)
                Row(
                  children: [
                    _buildHeaderStatCard('Toplam', totalReports.toString()),
                    const SizedBox(width: 8),
                    _buildHeaderStatCard('Aktif', activeReports.toString()),
                    const SizedBox(width: 8),
                    _buildHeaderStatCard(
                        'Tamamlanan', completedReports.toString()),
                    const SizedBox(width: 8),
                    _buildHeaderStatCard('Bekleyen', pendingReports.toString()),
                    const SizedBox(width: 8),
                    _buildHeaderStatCard('Gelir', _formatCurrency(totalIncome)),
                    const SizedBox(width: 8),
                    _buildHeaderStatCard(
                        'Gider', _formatCurrency(totalExpense)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: double.infinity,
            color: dividerColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Bugün: ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now())}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Header içindeki istatistik kartı - banner timer gibi
  Widget _buildHeaderStatCard(String title, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onPrimary = theme.colorScheme.onPrimary;
    final backgroundColor = onPrimary.withValues(alpha: isDark ? 0.16 : 0.22);
    final labelColor = onPrimary.withValues(alpha: 0.85);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: onPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Filtreleme ve arama bölümü oluşturur
  Widget _buildFiltersSection(bool isDark) {
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey[200]!,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Masaüstünde tek satır, mobilde açılır kapanır
          if (constraints.maxWidth > 768) {
            return Row(
              children: [
                // Arama çubuğu
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rapor ara...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tür filtresi
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedReportType,
                    decoration: InputDecoration(
                      labelText: 'Tür',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Tümü', child: Text('Tümü')),
                      DropdownMenuItem(value: 'Satış', child: Text('Satış')),
                      DropdownMenuItem(value: 'Alış', child: Text('Alış')),
                      DropdownMenuItem(
                          value: 'Nakit Akış', child: Text('Nakit Akış')),
                      DropdownMenuItem(
                          value: 'Envanter', child: Text('Envanter')),
                      DropdownMenuItem(
                          value: 'Kar/Zarar', child: Text('Kar/Zarar')),
                      DropdownMenuItem(
                          value: 'Bilanço', child: Text('Bilanço')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedReportType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Dönem filtresi
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedPeriod,
                    decoration: InputDecoration(
                      labelText: 'Dönem',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Bu Ay', child: Text('Bu Ay')),
                      DropdownMenuItem(
                          value: 'Geçen Ay', child: Text('Geçen Ay')),
                      DropdownMenuItem(
                          value: 'Son 3 Ay', child: Text('Son 3 Ay')),
                      DropdownMenuItem(value: 'Bu Yıl', child: Text('Bu Yıl')),
                      DropdownMenuItem(
                          value: 'Geçen Yıl', child: Text('Geçen Yıl')),
                      DropdownMenuItem(value: 'Özel', child: Text('Özel')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Sıralama
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: 'name',
                    decoration: InputDecoration(
                      labelText: 'Sırala',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('İsim')),
                      DropdownMenuItem(value: 'type', child: Text('Tür')),
                      DropdownMenuItem(value: 'status', child: Text('Durum')),
                      DropdownMenuItem(
                          value: 'createdAt', child: Text('Tarih')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        // Sıralama logic
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Sıralama yönü
                IconButton(
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                  },
                  icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  tooltip: _sortAscending ? 'Artan' : 'Azalan',
                ),
                const SizedBox(width: 8),
                // Excel, CSV, PDF, Import butonları
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Excel Export
                    IconButton(
                      onPressed: _exportToExcel,
                      icon: const Icon(Icons.table_chart),
                      tooltip: 'Excel\'e Aktar',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.withValues(alpha: 0.1),
                        foregroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // CSV Export
                    IconButton(
                      onPressed: _exportToCSV,
                      icon: const Icon(Icons.description),
                      tooltip: 'CSV\'ye Aktar',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // PDF Export
                    IconButton(
                      onPressed: _exportToPDF,
                      icon: const Icon(Icons.picture_as_pdf),
                      tooltip: 'PDF\'ye Aktar',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Import
                    IconButton(
                      onPressed: _showImportDialog,
                      icon: const Icon(Icons.upload_file),
                      tooltip: 'Dosya İçe Aktar',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            // Mobile - açılır kapanır (arama da içinde)
            return ExpansionTile(
              initiallyExpanded: _filtersExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _filtersExpanded = expanded;
                });
              },
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              childrenPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              collapsedIconColor: isDark ? Colors.grey[400] : Colors.grey[600],
              iconColor: isDark ? Colors.grey[400] : Colors.grey[600],
              title: Text(
                'Arama ve Filtreler',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Arama çubuğu - tam genişlik
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Rapor ara...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          filled: true,
                          fillColor:
                              isDark ? Colors.grey[800] : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color:
                                  isDark ? Colors.white12 : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color:
                                  isDark ? Colors.white12 : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.blue[400]!
                                  : Colors.blue[600]!,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Filtreler - iki satır
                      Row(
                        children: [
                          // İlk satır: Tür ve Dönem
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedReportType,
                              decoration: InputDecoration(
                                labelText: 'Tür',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'Tümü', child: Text('Tümü')),
                                DropdownMenuItem(
                                    value: 'Satış', child: Text('Satış')),
                                DropdownMenuItem(
                                    value: 'Alış', child: Text('Alış')),
                                DropdownMenuItem(
                                    value: 'Nakit Akış',
                                    child: Text('Nakit Akış')),
                                DropdownMenuItem(
                                    value: 'Envanter', child: Text('Envanter')),
                                DropdownMenuItem(
                                    value: 'Kar/Zarar',
                                    child: Text('Kar/Zarar')),
                                DropdownMenuItem(
                                    value: 'Bilanço', child: Text('Bilanço')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedReportType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedPeriod,
                              decoration: InputDecoration(
                                labelText: 'Dönem',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'Bu Ay', child: Text('Bu Ay')),
                                DropdownMenuItem(
                                    value: 'Geçen Ay', child: Text('Geçen Ay')),
                                DropdownMenuItem(
                                    value: 'Son 3 Ay', child: Text('Son 3 Ay')),
                                DropdownMenuItem(
                                    value: 'Bu Yıl', child: Text('Bu Yıl')),
                                DropdownMenuItem(
                                    value: 'Geçen Yıl',
                                    child: Text('Geçen Yıl')),
                                DropdownMenuItem(
                                    value: 'Özel', child: Text('Özel')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedPeriod = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // İkinci satır: Sıralama ve Export/Import
                      Row(
                        children: [
                          // Sıralama
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: 'name',
                              decoration: InputDecoration(
                                labelText: 'Sırala',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'name', child: Text('İsim')),
                                DropdownMenuItem(
                                    value: 'type', child: Text('Tür')),
                                DropdownMenuItem(
                                    value: 'status', child: Text('Durum')),
                                DropdownMenuItem(
                                    value: 'createdAt', child: Text('Tarih')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  // Sıralama logic
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Sıralama yönü
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _sortAscending = !_sortAscending;
                              });
                            },
                            icon: Icon(
                              _sortAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                            ),
                            tooltip: _sortAscending ? 'Artan' : 'Azalan',
                          ),
                          const SizedBox(width: 8),
                          // Excel, CSV, PDF, Import butonları
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Excel Export
                              IconButton(
                                onPressed: _exportToExcel,
                                icon: const Icon(Icons.table_chart),
                                tooltip: 'Excel\'e Aktar',
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.green.withValues(alpha: 0.1),
                                  foregroundColor: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 4),
                              // CSV Export
                              IconButton(
                                onPressed: _exportToCSV,
                                icon: const Icon(Icons.description),
                                tooltip: 'CSV\'ye Aktar',
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.blue.withValues(alpha: 0.1),
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 4),
                              // PDF Export
                              IconButton(
                                onPressed: _exportToPDF,
                                icon: const Icon(Icons.picture_as_pdf),
                                tooltip: 'PDF\'ye Aktar',
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.red.withValues(alpha: 0.1),
                                  foregroundColor: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Import
                              IconButton(
                                onPressed: _showImportDialog,
                                icon: const Icon(Icons.upload_file),
                                tooltip: 'Dosya İçe Aktar',
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.orange.withValues(alpha: 0.1),
                                  foregroundColor: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  /// Filtre chip'i oluşturur

  /// Dönem seçici oluşturur

  @override
  Widget build(BuildContext context) {
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
          final reportsAsync = ref.watch(reportsNotifierProvider);

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildWelcomeCard(isDark, reportsAsync.reports),
              ),

              // Filtreleme ve arama bölümü
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _buildFiltersSection(isDark),
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
                onTap: () => context.goNamed('income-expense-report'),
                isFavorite: true,
                lastGenerated:
                    DateTime.now().subtract(const Duration(hours: 2)),
              ),
              _buildReportCard(
                title: 'Satış Performans Raporu',
                subtitle: 'Satış ekibi ve ürün performansı',
                icon: Icons.bar_chart_outlined,
                color: TamgaciConstants.successColor,
                onTap: () => context.goNamed('sales-performance-report'),
                isFavorite: false,
                lastGenerated: DateTime.now().subtract(const Duration(days: 1)),
              ),
              _buildReportCard(
                title: 'Müşteri Analiz Raporu',
                subtitle: 'Müşteri segmentasyonu ve davranış analizi',
                icon: Icons.people_outline,
                color: TamgaciConstants.warningColor,
                onTap: () => context.goNamed('customer-analysis-report'),
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
                onTap: () => context.goNamed('cash-flow-report'),
                isFavorite: false,
                lastGenerated:
                    DateTime.now().subtract(const Duration(hours: 6)),
              ),
              _buildReportCard(
                title: 'Kar-Zarar Raporu',
                subtitle: 'Detaylı kar-zarar analizi',
                icon: Icons.account_balance_outlined,
                color: TamgaciConstants.errorColor,
                onTap: () => context.goNamed('profit-loss-report'),
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
                onTap: () => context.goNamed('inventory-status-report'),
                isFavorite: false,
                lastGenerated:
                    DateTime.now().subtract(const Duration(hours: 4)),
              ),
              _buildReportCard(
                title: 'Stok Hareket Raporu',
                subtitle: 'Giriş-çıkış hareketleri',
                icon: Icons.swap_horiz_outlined,
                color: TamgaciConstants.primaryColor,
                onTap: () => context.goNamed('inventory-movement-report'),
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
                onTap: () => context.goNamed('customer-payments-report'),
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
                context.goNamed('income-expense-report');
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
                context.goNamed('sales-performance-report');
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
                context.goNamed('cash-flow-report');
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

  void _exportToExcel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excel\'e Aktar'),
        content: const Text('Excel dosyası oluşturuluyor...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _exportToCSV() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CSV\'ye Aktar'),
        content: const Text('CSV dosyası oluşturuluyor...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _exportToPDF() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF\'ye Aktar'),
        content: const Text('PDF dosyası oluşturuluyor...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dosya İçe Aktar'),
        content: const Text('Dosya seçin ve içe aktarın...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Para birimi formatlaması için helper metod
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}

/// Dummy rapor özeti sınıfı
