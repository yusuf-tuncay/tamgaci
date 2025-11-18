import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../core/widgets/lifecycle_mixin.dart';

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

class _BulkStockUpdatePageState extends ConsumerState<BulkStockUpdatePage>
    with ConsumerLifecycleMixin {
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
    if (!mounted) {
      return const SizedBox.shrink();
    }

    final productsAsync = widget.warehouseId != null
        ? ref.watch(productsByWarehouseStreamProvider(widget.warehouseId!))
        : ref.watch(productsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!mounted) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Toplu Stok Güncelleme',
        showBackButton: true,
        showDrawer: false,
        onBackPressed: () {
          GoRouter.of(context).go('/products');
        },
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
            child: Builder(
              builder: (context) {
                if (!mounted) {
                  return const SizedBox.shrink();
                }

                try {
                  return productsAsync.when(
                    data: (products) {
                      if (!mounted) {
                        return const SizedBox.shrink();
                      }

                      try {
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
                          if (!mounted) return const SizedBox.shrink();
                          return Center(
                            child: Text(
                              'Ürün bulunamadı',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        if (!mounted) return const SizedBox.shrink();

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            if (!mounted) return const SizedBox.shrink();
                            try {
                              return _buildProductCard(filteredProducts[index]);
                            } catch (e) {
                              if (e.toString().contains('disposed') ||
                                  e.toString().contains('EngineFlutterView')) {
                                return const SizedBox.shrink();
                              }
                              rethrow;
                            }
                          },
                        );
                      } catch (e) {
                        if (e.toString().contains('disposed') ||
                            e.toString().contains('EngineFlutterView')) {
                          return const SizedBox.shrink();
                        }
                        rethrow;
                      }
                    },
                    loading: () {
                      if (!mounted) return const SizedBox.shrink();
                      try {
                        return const LoadingWidget();
                      } catch (e) {
                        if (e.toString().contains('disposed') ||
                            e.toString().contains('EngineFlutterView')) {
                          return const SizedBox.shrink();
                        }
                        rethrow;
                      }
                    },
                    error: (error, stack) {
                      if (!mounted) return const SizedBox.shrink();
                      try {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Hata: ${error.toString()}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        if (e.toString().contains('disposed') ||
                            e.toString().contains('EngineFlutterView')) {
                          return const SizedBox.shrink();
                        }
                        rethrow;
                      }
                    },
                  );
                } catch (e) {
                  if (e.toString().contains('disposed') ||
                      e.toString().contains('EngineFlutterView')) {
                    return const SizedBox.shrink();
                  }
                  rethrow;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSelectAll() {
    if (!mounted) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? colorScheme.outlineVariant
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
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
                        safeSetState(() {
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
              safeSetState(() {
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
                color: colorScheme.onSurface,
              ),
            ),
            value: _selectAll,
            onChanged: (value) {
              safeSetState(() {
                _selectAll = value ?? false;
                final productsAsync = widget.warehouseId != null
                    ? ref.read(
                        productsByWarehouseStreamProvider(widget.warehouseId!))
                    : ref.read(productsStreamProvider);

                productsAsync.whenData((products) {
                  if (mounted) {
                    safeSetState(() {
                      for (var product in products) {
                        _selectedProducts[product.id] = _selectAll;
                      }
                    });
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
    if (!mounted) {
      return const SizedBox.shrink();
    }

    final selectedCount =
        _selectedProducts.values.where((selected) => selected).length;

    if (selectedCount == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$selectedCount ürün seçildi',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    if (!mounted) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    // Controller'ı oluştur veya al
    if (!_stockControllers.containsKey(product.id)) {
      _stockControllers[product.id] = TextEditingController(
        text: product.totalStockQuantity.toString(),
      );
    }

    // Seçim durumunu oluştur
    _selectedProducts.putIfAbsent(product.id, () => false);

    final isSelected = _selectedProducts[product.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : isDark
                  ? colorScheme.outlineVariant
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
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
                    safeSetState(() {
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
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (product.productCode != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Kod: ${product.productCode}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
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
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 8),
              ...product.variants!.asMap().entries.map((entry) {
                final variantIndex = entry.key;
                final variant = entry.value;
                final variantKey = '${product.id}_variant_$variantIndex';

                if (!_stockControllers.containsKey(variantKey)) {
                  if (mounted) {
                    _stockControllers[variantKey] = TextEditingController(
                      text: variant.stockQuantity.toString(),
                    );
                  }
                }

                if (!mounted) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.tertiary.withValues(alpha: 0.3),
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
                            color: colorScheme.onSurface,
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
                      color: colorScheme.onSurfaceVariant,
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
    if (!mounted) return;

    // Seçili ürünleri al
    final selectedProductIds = _selectedProducts.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedProductIds.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir ürün seçin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Onay dialogu göster
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Stok Güncelleme',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          '${selectedProductIds.length} ürünün stoğu güncellenecek. Onaylıyor musunuz?',
          style: GoogleFonts.poppins(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'İptal',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    safeSetState(() {
      _isSaving = true;
    });

    try {
      if (!mounted) return;

      final productsAsync = widget.warehouseId != null
          ? await ref.read(
              productsByWarehouseStreamProvider(widget.warehouseId!).future)
          : await ref.read(productsStreamProvider.future);

      if (!mounted) return;

      int updatedCount = 0;

      for (var productId in selectedProductIds) {
        if (!mounted) break;

        final product =
            productsAsync.firstWhere((p) => p.id == productId, orElse: () {
          throw Exception('Ürün bulunamadı: $productId');
        });

        if (product.variants != null && product.variants!.isNotEmpty) {
          // Varyantlı ürün - her varyantı güncelle
          final updatedVariants =
              product.variants!.asMap().entries.map((entry) {
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

      if (!mounted) return;

      // İstatistikleri ve ürün listesini güncelle
      ref.invalidate(productStatisticsProvider);
      if (widget.warehouseId != null) {
        ref.invalidate(productsByWarehouseStreamProvider(widget.warehouseId!));
      } else {
        ref.invalidate(productsStreamProvider);
      }

      if (mounted) {
        safeSetState(() {
          _isSaving = false;
          _selectedProducts.clear();
          _selectAll = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$updatedCount ürün başarıyla güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        safeSetState(() {
          _isSaving = false;
        });

        if (mounted) {
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
}
