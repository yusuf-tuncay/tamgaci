import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../domain/entities/stock_count.dart';
import '../providers/stock_count_providers.dart';
import '../../../warehouses/domain/entities/warehouse.dart';
import 'stock_count_page.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';

/// Stok Sayımları Listesi Sayfası
class StockCountsListPage extends ConsumerStatefulWidget {
  final Warehouse? warehouse;

  const StockCountsListPage({
    super.key,
    this.warehouse,
  });

  @override
  ConsumerState<StockCountsListPage> createState() =>
      _StockCountsListPageState();
}

class _StockCountsListPageState extends ConsumerState<StockCountsListPage> {
  StockCountStatus? _filterStatus;

  Widget _buildWelcomeCard(bool isDark) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final secondaryTextColor = onPrimary.withValues(alpha: isDark ? 0.9 : 0.95);
    final borderColor = onPrimary.withValues(alpha: 0.12);
    final dividerColor = onPrimary.withValues(alpha: 0.14);
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
          Text(
            'Tüm Stok Sayımları',
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
            'Stok sayımlarını yönetin ve takip edin',
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
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

  @override
  Widget build(BuildContext context) {
    final stockCountsAsync = widget.warehouse != null
        ? ref.watch(stockCountsByWarehouseStreamProvider(widget.warehouse!.id))
        : ref.watch(allStockCountsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveScaffold(
        appBar: CustomAppBar(
          showBackButton: false,
          showDrawer: true,
          actions: [
            PopupMenuButton<StockCountStatus?>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filtrele',
              onSelected: (status) {
                setState(() {
                  _filterStatus = status;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: null,
                  child: Text('Tümü', style: GoogleFonts.poppins()),
                ),
                ...StockCountStatus.values.map((status) {
                  return PopupMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 18,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status.displayName,
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
        drawerContent: const TamgaciDrawerMenu(),
        body: SingleChildScrollView(
            child: Column(children: [
          _buildWelcomeCard(isDark),
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.of(context).size.height - 300,
            child: stockCountsAsync.when(
              data: (stockCounts) {
                var filteredCounts = stockCounts;
                if (_filterStatus != null) {
                  filteredCounts = stockCounts
                      .where((count) => count.status == _filterStatus)
                      .toList();
                }

                if (filteredCounts.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCounts.length,
                  itemBuilder: (context, index) {
                    return _buildStockCountCard(filteredCounts[index]);
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: isDark ? Colors.red[400] : Colors.red[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hata: ${error.toString()}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.red[400] : Colors.red[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.warehouse != null) {
                            ref.invalidate(stockCountsByWarehouseStreamProvider(
                                widget.warehouse!.id));
                          } else {
                            ref.invalidate(allStockCountsStreamProvider);
                          }
                        },
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ])));
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_outlined,
            size: 80,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz stok sayımı yok',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Depo detayından yeni sayım başlatın',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCountCard(StockCount stockCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(stockCount.status).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Depo bilgisini bul ve sayfa aç
          _openStockCount(stockCount);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(stockCount.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(stockCount.status),
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          stockCount.status.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    stockCount.type.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                stockCount.countNumber,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stockCount.warehouseName,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(stockCount.countDate),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      'Toplam',
                      stockCount.totalItemsCount.toString(),
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatBox(
                      'Sayılan',
                      stockCount.countedItemsCount.toString(),
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatBox(
                      'Kalan',
                      (stockCount.totalItemsCount -
                              stockCount.countedItemsCount)
                          .toString(),
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              if (stockCount.status == StockCountStatus.inProgress ||
                  stockCount.status == StockCountStatus.draft) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: stockCount.totalItemsCount > 0
                      ? stockCount.countedItemsCount /
                          stockCount.totalItemsCount
                      : 0,
                  backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(stockCount.status),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _openStockCount(StockCount stockCount) {
    // Warehouse objesi oluştur
    final warehouse = Warehouse(
      id: stockCount.warehouseId,
      name: stockCount.warehouseName,
      address: '',
      type: WarehouseType.main,
      status: WarehouseStatus.active,
      isActive: true,
      isDefault: false,
      createdBy: '',
      createdAt: DateTime.now(),
      updatedBy: '',
      updatedAt: DateTime.now(),
      tenantId: stockCount.tenantId,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StockCountPage(
          warehouse: warehouse,
          existingStockCount: stockCount,
        ),
      ),
    );
  }

  Color _getStatusColor(StockCountStatus status) {
    switch (status) {
      case StockCountStatus.draft:
        return Colors.grey;
      case StockCountStatus.inProgress:
        return Colors.blue;
      case StockCountStatus.completed:
        return Colors.green;
      case StockCountStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(StockCountStatus status) {
    switch (status) {
      case StockCountStatus.draft:
        return Icons.edit_note;
      case StockCountStatus.inProgress:
        return Icons.pending;
      case StockCountStatus.completed:
        return Icons.check_circle;
      case StockCountStatus.cancelled:
        return Icons.cancel;
    }
  }
}
