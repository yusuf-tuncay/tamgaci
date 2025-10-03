import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/stock_count.dart';
import '../providers/stock_count_providers.dart';
import '../../../warehouses/domain/entities/warehouse.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';

/// Stok Sayımı Sayfası
class StockCountPage extends ConsumerStatefulWidget {
  final Warehouse warehouse;
  final StockCount? existingStockCount;

  const StockCountPage({
    super.key,
    required this.warehouse,
    this.existingStockCount,
  });

  @override
  ConsumerState<StockCountPage> createState() => _StockCountPageState();
}

class _StockCountPageState extends ConsumerState<StockCountPage> {
  StockCount? _stockCount;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyUncounted = false;
  bool _showOnlyWithVariance = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingStockCount != null) {
      _stockCount = widget.existingStockCount!;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeNewStockCount();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeNewStockCount() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      final productsSnapshot = await ref
          .read(productsByWarehouseStreamProvider(widget.warehouse.id).future);

      final repository = ref.read(stockCountRepositoryProvider);
      final newStockCount = await repository.createStockCountFromProducts(
        warehouseId: widget.warehouse.id,
        warehouseName: widget.warehouse.name,
        products: productsSnapshot,
        type: StockCountType.full,
        description: 'Depo sayımı - ${widget.warehouse.name}',
      );

      if (mounted) {
        setState(() {
          _stockCount = newStockCount;
          _isInitializing = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stok sayımı oluşturulamadı: $error'),
            backgroundColor: Colors.red[600],
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    // Yeni stok sayımı oluşturulurken veya henüz yüklenmediyse loading göster
    if (_stockCount == null || _isInitializing) {
      return const ResponsiveScaffold(
        appBar: CustomAppBar(
          title: 'Stok Sayımı',
          showBackButton: true,
          showDrawer: false,
        ),
        drawerContent: TamgaciDrawerMenu(),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ResponsiveScaffold(
      appBar: CustomAppBar(
        title: 'Stok Sayımı - ${widget.warehouse.name}',
        showBackButton: true,
        showDrawer: false,
        actions: [
          if (_stockCount!.status == StockCountStatus.draft ||
              _stockCount!.status == StockCountStatus.inProgress)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _completeStockCount,
              tooltip: 'Tamamla',
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
            tooltip: 'Daha fazla',
          ),
        ],
      ),
      drawerContent: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          _buildStockCountHeader(),
          _buildSearchAndFilters(),
          _buildStatistics(),
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

  Widget _buildStockCountHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stockCount!.countNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _stockCount!.status.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _stockCount!.type.displayName,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Ürün ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: const Text('Sayılmayanlar'),
                  selected: _showOnlyUncounted,
                  onSelected: (value) {
                    setState(() {
                      _showOnlyUncounted = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilterChip(
                  label: const Text('Farklı Olanlar'),
                  selected: _showOnlyWithVariance,
                  onSelected: (value) {
                    setState(() {
                      _showOnlyWithVariance = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final totalItems = _stockCount!.totalItemsCount;
    final countedItems =
        _stockCount!.items.where((item) => item.isCounted).length;
    final progress = totalItems > 0 ? countedItems / totalItems : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Toplam',
                totalItems.toString(),
                Icons.inventory_2,
                Colors.blue,
              ),
              _buildStatItem(
                'Sayılan',
                countedItems.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatItem(
                'Kalan',
                (totalItems - countedItems).toString(),
                Icons.pending,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? Colors.green : Colors.blue,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% Tamamlandı',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    var items = _stockCount!.items;

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.productName.toLowerCase().contains(_searchQuery) ||
            (item.productCode?.toLowerCase().contains(_searchQuery) ?? false) ||
            (item.barcode?.contains(_searchQuery) ?? false) ||
            (item.variantName?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    // Sayılmayanları göster filtresi
    if (_showOnlyUncounted) {
      items = items.where((item) => !item.isCounted).toList();
    }

    // Farklı olanları göster filtresi
    if (_showOnlyWithVariance) {
      items = items
          .where((item) =>
              item.isCounted && item.variance != null && item.variance != 0)
          .toList();
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          'Ürün bulunamadı',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildProductCard(item, index);
      },
    );
  }

  Widget _buildProductCard(StockCountItem item, int index) {
    final hasVariance =
        item.isCounted && item.variance != null && item.variance != 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasVariance
              ? (item.variance! > 0 ? Colors.green : Colors.red)
              : Colors.grey[200]!,
          width: hasVariance ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showCountDialog(item, index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.variantName != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.variantName!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.purple[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (item.isCounted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                ],
              ),
              if (item.productCode != null || item.barcode != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (item.productCode != null)
                      Text(
                        'Kod: ${item.productCode}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    if (item.productCode != null && item.barcode != null)
                      Text(
                        ' • ',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    if (item.barcode != null)
                      Text(
                        'Barkod: ${item.barcode}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
              if (item.shelfLocation != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Raf: ${item.shelfLocation}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuantityBox(
                      'Sistem',
                      item.systemQuantity.toString(),
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuantityBox(
                      'Sayım',
                      item.countedQuantity?.toString() ?? '-',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuantityBox(
                      'Fark',
                      item.variance != null
                          ? (item.variance! > 0
                              ? '+${item.variance}'
                              : item.variance.toString())
                          : '-',
                      hasVariance
                          ? (item.variance! > 0 ? Colors.green : Colors.red)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityBox(String label, String value, Color color) {
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
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _showCountDialog(StockCountItem item, int index) {
    if (_stockCount!.status != StockCountStatus.draft &&
        _stockCount!.status != StockCountStatus.inProgress) {
      return;
    }

    final controller = TextEditingController(
      text: item.countedQuantity?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: item.notes ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Stok Sayımı',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.productName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (item.variantName != null) ...[
              const SizedBox(height: 4),
              Text(
                item.variantName!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.purple[700],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Sistem Miktarı: ${item.systemQuantity}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Sayım Miktarı',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        final current = int.tryParse(controller.text) ?? 0;
                        if (current > 0) {
                          controller.text = (current - 1).toString();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final current = int.tryParse(controller.text) ?? 0;
                        controller.text = (current + 1).toString();
                      },
                    ),
                  ],
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notlar (Opsiyonel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final countedQuantity = int.tryParse(controller.text);
              if (countedQuantity == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Geçerli bir miktar girin'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final variance = countedQuantity - item.systemQuantity;
              final updatedItem = item.copyWith(
                countedQuantity: countedQuantity,
                variance: variance,
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
                isCounted: true,
                countedAt: DateTime.now(),
              );

              final updatedItems =
                  List<StockCountItem>.from(_stockCount!.items);
              final originalIndex = _stockCount!.items.indexOf(item);
              updatedItems[originalIndex] = updatedItem;

              final countedCount =
                  updatedItems.where((i) => i.isCounted).length;

              setState(() {
                _stockCount = _stockCount!.copyWith(
                  items: updatedItems,
                  countedItemsCount: countedCount,
                  status: countedCount > 0 &&
                          countedCount < _stockCount!.totalItemsCount
                      ? StockCountStatus.inProgress
                      : _stockCount!.status,
                );
              });

              // Kaydet
              ref
                  .read(stockCountOperationsProvider.notifier)
                  .updateStockCount(_stockCount!);

              Navigator.of(context).pop();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _completeStockCount() async {
    // Tüm kalemlerin sayılıp sayılmadığını kontrol et
    final uncountedItems =
        _stockCount!.items.where((item) => !item.isCounted).toList();

    if (uncountedItems.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Uyarı',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Henüz ${uncountedItems.length} ürün sayılmadı. Tamamlamak istediğinize emin misiniz?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _doCompleteStockCount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Tamamla'),
            ),
          ],
        ),
      );
    } else {
      _doCompleteStockCount();
    }
  }

  Future<void> _doCompleteStockCount() async {
    final success = await ref
        .read(stockCountOperationsProvider.notifier)
        .completeStockCount(_stockCount!.id);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_stockCount!.status != StockCountStatus.completed)
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.orange),
                title: Text('İptal Et', style: GoogleFonts.poppins()),
                onTap: () async {
                  Navigator.of(context).pop();
                  final success = await ref
                      .read(stockCountOperationsProvider.notifier)
                      .cancelStockCount(_stockCount!.id);

                  if (mounted && success) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('Sil', style: GoogleFonts.poppins(color: Colors.red)),
              onTap: () async {
                Navigator.of(context).pop();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Stok Sayımını Sil'),
                    content:
                        const Text('Bu işlem geri alınamaz. Emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('İptal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Sil'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && mounted) {
                  final success = await ref
                      .read(stockCountOperationsProvider.notifier)
                      .deleteStockCount(_stockCount!.id);

                  if (mounted && success) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_stockCount!.status) {
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

  IconData _getStatusIcon() {
    switch (_stockCount!.status) {
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
