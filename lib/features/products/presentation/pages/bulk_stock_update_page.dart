import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Toplu Stok Güncelleme Sayfası
class BulkStockUpdatePage extends ConsumerStatefulWidget {
  final String? warehouseId;

  const BulkStockUpdatePage({
    super.key,
    this.warehouseId,
  });

  @override
  ConsumerState<BulkStockUpdatePage> createState() =>
      _BulkStockUpdatePageState();
}

class _BulkStockUpdatePageState extends ConsumerState<BulkStockUpdatePage> {
  final Map<String, TextEditingController> _stockControllers = {};
  final Map<String, bool> _selectedProducts = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _selectAll = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _stockControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = widget.warehouseId != null
        ? ref.watch(productsByWarehouseStreamProvider(widget.warehouseId!))
        : ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Toplu Stok Güncelleme',
        showBackButton: false,
        showDrawer: true,
        actions: [
          if (_selectedProducts.values.any((selected) => selected))
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveChanges,
              tooltip: 'Kaydet',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndSelectAll(),
          _buildSelectedCount(),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                var filteredProducts = products;

                // Arama filtresi
                if (_searchQuery.isNotEmpty) {
                  filteredProducts = products.where((product) {
                    return product.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        (product.productCode
                                ?.toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ??
                            false) ||
                        (product.barcode?.contains(_searchQuery) ?? false);
                  }).toList();
                }

                if (filteredProducts.isEmpty) {
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
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(filteredProducts[index]);
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Hata: ${error.toString()}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.red[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSelectAll() {
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
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: Text(
              'Tümünü Seç',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            value: _selectAll,
            onChanged: (value) {
              setState(() {
                _selectAll = value ?? false;
                final productsAsync = widget.warehouseId != null
                    ? ref.read(
                        productsByWarehouseStreamProvider(widget.warehouseId!))
                    : ref.read(productsStreamProvider);

                productsAsync.whenData((products) {
                  for (var product in products) {
                    _selectedProducts[product.id] = _selectAll;
                  }
                });
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCount() {
    final selectedCount =
        _selectedProducts.values.where((selected) => selected).length;

    if (selectedCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue[50],
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Text(
            '$selectedCount ürün seçildi',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    // Controller'ı oluştur veya al
    if (!_stockControllers.containsKey(product.id)) {
      _stockControllers[product.id] = TextEditingController(
        text: product.totalStockQuantity.toString(),
      );
    }

    // Seçim durumunu oluştur
    _selectedProducts.putIfAbsent(product.id, () => false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selectedProducts[product.id]!
              ? Colors.blue
              : Colors.grey[200]!,
          width: _selectedProducts[product.id]! ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _selectedProducts[product.id],
                  onChanged: (value) {
                    setState(() {
                      _selectedProducts[product.id] = value ?? false;
                      if (!value!) {
                        _selectAll = false;
                      }
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (product.productCode != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Kod: ${product.productCode}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (product.variants != null && product.variants!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Varyantlar:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                ),
              ),
              const SizedBox(height: 8),
              ...product.variants!.asMap().entries.map((entry) {
                final variantIndex = entry.key;
                final variant = entry.value;
                final variantKey = '${product.id}_variant_$variantIndex';

                if (!_stockControllers.containsKey(variantKey)) {
                  _stockControllers[variantKey] = TextEditingController(
                    text: variant.stockQuantity.toString(),
                  );
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.purple.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          variant.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _stockControllers[variantKey],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: 'Stok',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16),
                                  onPressed: () {
                                    final current = int.tryParse(
                                            _stockControllers[variantKey]!
                                                .text) ??
                                        0;
                                    if (current > 0) {
                                      _stockControllers[variantKey]!.text =
                                          (current - 1).toString();
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16),
                                  onPressed: () {
                                    final current = int.tryParse(
                                            _stockControllers[variantKey]!
                                                .text) ??
                                        0;
                                    _stockControllers[variantKey]!.text =
                                        (current + 1).toString();
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Mevcut Stok: ${product.totalStockQuantity}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _stockControllers[product.id],
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Yeni Stok',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () {
                                final current = int.tryParse(
                                        _stockControllers[product.id]!.text) ??
                                    0;
                                if (current > 0) {
                                  _stockControllers[product.id]!.text =
                                      (current - 1).toString();
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                final current = int.tryParse(
                                        _stockControllers[product.id]!.text) ??
                                    0;
                                _stockControllers[product.id]!.text =
                                    (current + 1).toString();
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    // Seçili ürünleri al
    final selectedProductIds = _selectedProducts.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir ürün seçin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Onay dialogu göster
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Stok Güncelleme',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${selectedProductIds.length} ürünün stoğu güncellenecek. Onaylıyor musunuz?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final productsAsync = widget.warehouseId != null
          ? await ref
              .read(productsByWarehouseStreamProvider(widget.warehouseId!)
                  .future)
          : await ref.read(productsStreamProvider.future);

      int updatedCount = 0;

      for (var productId in selectedProductIds) {
        final product =
            productsAsync.firstWhere((p) => p.id == productId, orElse: () {
          throw Exception('Ürün bulunamadı: $productId');
        });

        if (product.variants != null && product.variants!.isNotEmpty) {
          // Varyantlı ürün - her varyantı güncelle
          final updatedVariants = product.variants!.asMap().entries.map((entry) {
            final variantIndex = entry.key;
            final variant = entry.value;
            final variantKey = '${product.id}_variant_$variantIndex';
            final newStock =
                int.tryParse(_stockControllers[variantKey]?.text ?? '0') ?? 0;

            return variant.copyWith(stockQuantity: newStock);
          }).toList();

          final updatedProduct = product.copyWith(variants: updatedVariants);
          await ref
              .read(productOperationsProvider.notifier)
              .updateProduct(updatedProduct);
        } else {
          // Varyantsız ürün
          final newStock =
              int.tryParse(_stockControllers[productId]?.text ?? '0') ?? 0;
          await ref
              .read(productRepositoryProvider)
              .updateStockQuantity(productId, newStock);
        }

        updatedCount++;
      }

      // İstatistikleri güncelle
      ref.invalidate(productStatisticsProvider);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _selectedProducts.clear();
          _selectAll = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$updatedCount ürün başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
