import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/reports/domain/entities/report.dart';
import 'package:tamgaci/features/reports/presentation/providers/reports_providers.dart';
import 'package:tamgaci/features/reports/presentation/states/reports_state.dart';
import 'package:tamgaci/core/widgets/error_widget.dart' as core_widgets;
import 'package:tamgaci/features/reports/presentation/widgets/report_card.dart';
import 'package:tamgaci/features/reports/presentation/widgets/report_filter_bottom_sheet.dart';
import 'package:tamgaci/core/routes/routes.dart';
import 'package:tamgaci/core/widgets/loading_widget.dart';
import 'package:tamgaci/core/widgets/empty_state_widget.dart';
import 'package:tamgaci/core/widgets/search_bar_widget.dart';
import 'package:tamgaci/core/widgets/fab_widget.dart';

/// Raporlar listesi sayfası
class ReportsListPage extends ConsumerStatefulWidget {
  const ReportsListPage({super.key});

  @override
  ConsumerState<ReportsListPage> createState() => _ReportsListPageState();
}

class _ReportsListPageState extends ConsumerState<ReportsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ReportType? _selectedType;
  ReportStatus? _selectedStatus;
  ReportFormat? _selectedFormat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadReports() {
    ref.read(reportsNotifierProvider.notifier).getReports();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      _loadReports();
    } else {
      ref.read(reportsNotifierProvider.notifier).searchReports(query);
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportFilterBottomSheet(
        selectedType: _selectedType,
        selectedStatus: _selectedStatus,
        selectedFormat: _selectedFormat,
        onFilterChanged: (type, status, format) {
          setState(() {
            _selectedType = type;
            _selectedStatus = status;
            _selectedFormat = format;
          });

          if (type != null) {
            ref.read(reportsNotifierProvider.notifier).getReportsByType(type);
          } else if (status != null) {
            ref
                .read(reportsNotifierProvider.notifier)
                .getReportsByStatus(status);
          } else if (format != null) {
            ref
                .read(reportsNotifierProvider.notifier)
                .getReportsByFormat(format);
          } else {
            _loadReports();
          }
        },
        onClearFilters: () {
          setState(() {
            _selectedType = null;
            _selectedStatus = null;
            _selectedFormat = null;
            _searchQuery = '';
            _searchController.clear();
          });
          _loadReports();
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _selectedFormat = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsNotifierProvider);
    final hasFilters = _selectedType != null ||
        _selectedStatus != null ||
        _selectedFormat != null ||
        _searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar'),
        actions: [
          if (hasFilters)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Filtreleri Temizle',
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filtrele',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Rapor ara...',
              onChanged: _onSearchChanged,
            ),
          ),
          if (hasFilters)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedType != null)
                            Chip(
                              label: Text(_selectedType!.displayName),
                              onDeleted: () {
                                setState(() {
                                  _selectedType = null;
                                });
                                _loadReports();
                              },
                            ),
                          if (_selectedStatus != null)
                            Chip(
                              label: Text(_selectedStatus!.displayName),
                              onDeleted: () {
                                setState(() {
                                  _selectedStatus = null;
                                });
                                _loadReports();
                              },
                            ),
                          if (_selectedFormat != null)
                            Chip(
                              label: Text(_selectedFormat!.displayName),
                              onDeleted: () {
                                setState(() {
                                  _selectedFormat = null;
                                });
                                _loadReports();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _buildBody(reportsState),
          ),
        ],
      ),
      floatingActionButton: FabWidget(
        onPressed: () {
          Navigator.pushNamed(context, TamgaciRoutes.createReport);
        },
        tooltip: 'Yeni Rapor',
      ),
    );
  }

  Widget _buildBody(ReportsState state) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.error != null) {
      return core_widgets.ErrorWidget(
        error: state.error!,
        onRetry: _loadReports,
      );
    }

    if (state.reports.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.assessment_outlined,
        title: 'Rapor Bulunamadı',
        message: _searchQuery.isNotEmpty ||
                _selectedType != null ||
                _selectedStatus != null ||
                _selectedFormat != null
            ? 'Arama kriterlerinize uygun rapor bulunamadı.'
            : 'Henüz rapor kaydı bulunmuyor.\nYeni rapor oluşturmak için + butonuna tıklayın.',
        actionText: _searchQuery.isNotEmpty ||
                _selectedType != null ||
                _selectedStatus != null ||
                _selectedFormat != null
            ? 'Filtreleri Temizle'
            : 'Yeni Rapor',
        onAction: _searchQuery.isNotEmpty ||
                _selectedType != null ||
                _selectedStatus != null ||
                _selectedFormat != null
            ? _clearFilters
            : () {
                Navigator.pushNamed(context, TamgaciRoutes.createReport);
              },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadReports();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.reports.length,
        itemBuilder: (context, index) {
          final report = state.reports[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ReportCard(
              report: report,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.reportDetail,
                  arguments: report.id,
                );
              },
              onEdit: () {
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.editReport,
                  arguments: report.id,
                );
              },
              onDelete: () {
                _showDeleteDialog(report);
              },
              onDuplicate: () {
                _duplicateReport(report.id);
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raporu Sil'),
        content: Text(
            '${report.name} adlı raporu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReport(report.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _deleteReport(String id) {
    ref.read(reportsNotifierProvider.notifier).deleteReport(id);
  }

  void _duplicateReport(String id) {
    ref.read(reportsNotifierProvider.notifier).duplicateReport(id);
  }
}
