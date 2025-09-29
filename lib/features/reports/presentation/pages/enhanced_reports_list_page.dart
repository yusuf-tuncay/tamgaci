// ========== ENHANCED REPORTS LIST PAGE ==========
// lib/features/reports/presentation/pages/enhanced_reports_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
// import '../../../../core/utils/currency_helper.dart'; // Unused
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../domain/entities/report.dart';

/// Gelişmiş raporlar listesi sayfası
class EnhancedReportsListPage extends ConsumerStatefulWidget {
  const EnhancedReportsListPage({super.key});

  @override
  ConsumerState<EnhancedReportsListPage> createState() =>
      _EnhancedReportsListPageState();
}

class _EnhancedReportsListPageState
    extends ConsumerState<EnhancedReportsListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Filter states
  ReportType? _selectedType;
  ReportStatus? _selectedStatus;
  ReportFormat? _selectedFormat;
  DateTime? _startDate;
  DateTime? _endDate;
  final String _sortBy = 'createdAt';
  final bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveScaffold(
      appBar: CustomAppBar(
        title: 'Raporlar',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _showCreateReportDialog,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Tümü', icon: Icon(Icons.list)),
                Tab(text: 'Satış', icon: Icon(Icons.sell)),
                Tab(text: 'Mali', icon: Icon(Icons.account_balance)),
                Tab(text: 'Stok', icon: Icon(Icons.inventory)),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: TamgaciConstants.paddingMedium(context),
            color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rapor ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(TamgaciConstants.radiusMD),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportsList(ReportType.values),
                _buildReportsList([ReportType.sales]),
                _buildReportsList([
                  ReportType.cashFlow,
                  ReportType.profitLoss,
                  ReportType.balanceSheet
                ]),
                _buildReportsList([ReportType.inventory]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(List<ReportType> types) {
    final reports = _getMockReports()
        .where((report) => types.contains(report.type))
        .toList();
    final filteredReports = _applyFilters(reports);

    if (filteredReports.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshReports,
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredReports.length,
        itemBuilder: (context, index) {
          final report = filteredReports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    final statusColor = _getStatusColor(report.status);
    final typeIcon = _getTypeIcon(report.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _viewReport(report),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: TamgaciConstants.cardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(TamgaciConstants.radiusMD),
                    ),
                    child: Icon(
                      typeIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          report.description ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.status.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Tür',
                      report.type.displayName,
                      Icons.category,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Format',
                      report.format.displayName,
                      Icons.description,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Tarih',
                      _formatDate(report.createdAt),
                      Icons.calendar_today,
                    ),
                  ),
                ],
              ),

              if (report.fileSize != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Dosya Boyutu',
                        _formatFileSize((report.fileSize ?? 0).toDouble()),
                        Icons.storage,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  if (report.status == ReportStatus.completed &&
                      report.fileUrl != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadReport(report),
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('İndir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (report.status == ReportStatus.completed &&
                      report.fileUrl != null)
                    const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewReport(report),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Görüntüle'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (action) => _handleReportAction(action, report),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 16),
                            SizedBox(width: 8),
                            Text('Kopyala'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assessment_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz rapor bulunmuyor',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni rapor oluşturmak için + butonuna tıklayın',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateReportDialog,
            icon: const Icon(Icons.add),
            label: const Text('Rapor Oluştur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<Report> _applyFilters(List<Report> reports) {
    var filtered = reports;

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered
          .where((report) =>
              report.name.toLowerCase().contains(searchTerm) ||
              (report.description ?? '').toLowerCase().contains(searchTerm))
          .toList();
    }

    // Type filter
    if (_selectedType != null) {
      filtered =
          filtered.where((report) => report.type == _selectedType).toList();
    }

    // Status filter
    if (_selectedStatus != null) {
      filtered =
          filtered.where((report) => report.status == _selectedStatus).toList();
    }

    // Format filter
    if (_selectedFormat != null) {
      filtered =
          filtered.where((report) => report.format == _selectedFormat).toList();
    }

    // Date filter
    if (_startDate != null) {
      filtered = filtered
          .where((report) => report.createdAt.isAfter(_startDate!))
          .toList();
    }
    if (_endDate != null) {
      filtered = filtered
          .where((report) => report.createdAt.isBefore(_endDate!))
          .toList();
    }

    // Sort
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'status':
          comparison = a.status.displayName.compareTo(b.status.displayName);
          break;
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  IconData _getTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.sales:
        return Icons.sell;
      case ReportType.purchases:
        return Icons.shopping_cart;
      case ReportType.balanceSheet:
        return Icons.account_balance;
      case ReportType.inventory:
        return Icons.inventory;
      case ReportType.customer:
        return Icons.people;
      case ReportType.supplier:
        return Icons.business;
      case ReportType.cashFlow:
        return Icons.account_balance_wallet;
      case ReportType.profitLoss:
        return Icons.trending_up;
      case ReportType.product:
        return Icons.inventory_2;
      case ReportType.custom:
        return Icons.assessment;
      case ReportType.payments:
        return Icons.payment;
      case ReportType.paymentSummary:
        return Icons.summarize;
      case ReportType.paymentByType:
        return Icons.category;
      case ReportType.paymentByCustomer:
        return Icons.person;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return AppColors.warning;
      case ReportStatus.generating:
        return AppColors.info;
      case ReportStatus.completed:
        return AppColors.success;
      case ReportStatus.failed:
        return AppColors.error;
      case ReportStatus.expired:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatFileSize(double sizeInBytes) {
    if (sizeInBytes < 1024) return '${sizeInBytes.toStringAsFixed(0)} B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  List<Report> _getMockReports() {
    return [
      Report(
        id: '1',
        name: 'Aylık Satış Raporu',
        description: 'Ocak 2024 satış raporu',
        type: ReportType.sales,
        format: ReportFormat.pdf,
        status: ReportStatus.completed,
        parameters: const {},
        fileUrl: 'https://example.com/report1.pdf',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdBy: 'Admin',
        generatedAt: DateTime.now().subtract(const Duration(days: 1)),
        fileSize: (2.5 * 1024 * 1024).toInt(), // 2.5 MB
      ),
      Report(
        id: '2',
        name: 'Stok Durumu Raporu',
        description: 'Güncel stok seviyeleri',
        type: ReportType.inventory,
        format: ReportFormat.excel,
        status: ReportStatus.completed,
        parameters: const {},
        fileUrl: 'https://example.com/report2.xlsx',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'Admin',
        generatedAt: DateTime.now().subtract(const Duration(days: 2)),
        fileSize: (1.8 * 1024 * 1024).toInt(), // 1.8 MB
      ),
      Report(
        id: '3',
        name: 'Mali Durum Raporu',
        description: 'Q1 2024 mali durum analizi',
        type: ReportType.balanceSheet,
        format: ReportFormat.pdf,
        status: ReportStatus.generating,
        parameters: const {},
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        createdBy: 'Admin',
      ),
    ];
  }

  Future<void> _refreshReports() async {
    // Refresh logic here
    await Future.delayed(const Duration(seconds: 1));
  }

  void _showCreateReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Rapor Oluştur'),
        content: const Text('Rapor oluşturma formu yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreler'),
        content: const Text('Filtre seçenekleri yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _viewReport(Report report) {
    // View report logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.name),
        content: const Text('Rapor görüntüleme özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _downloadReport(Report report) {
    // Download logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${report.name} indiriliyor...')),
    );
  }

  void _handleReportAction(String action, Report report) {
    switch (action) {
      case 'edit':
        _editReport(report);
        break;
      case 'duplicate':
        _duplicateReport(report);
        break;
      case 'delete':
        _deleteReport(report);
        break;
    }
  }

  void _editReport(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rapor Düzenle'),
        content: Text('${report.name} düzenleme formu yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _duplicateReport(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rapor Kopyala'),
        content: Text('${report.name} kopyalanıyor...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _deleteReport(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raporu Sil'),
        content: Text('${report.name} silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Delete logic here
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
