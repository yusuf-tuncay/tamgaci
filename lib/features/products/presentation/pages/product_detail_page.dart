// ========== PRODUCT DETAIL PAGE ==========
// lib/features/products/presentation/pages/product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;
import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';

/// Ürün detay sayfası
class ProductDetailPage extends ConsumerWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer(
      builder: (context, ref, child) {
        final productAsync = ref.watch(productDetailProvider(productId));

        return productAsync.when(
          data: (product) {
            if (product == null) {
              return const Scaffold(
                appBar: CustomAppBar(
                  title: 'Ürün Bulunamadı',
                  showBackButton: true,
                  showDrawer: false,
                ),
                body: Center(
                  child: Text('Ürün bulunamadı'),
                ),
              );
            }

            return Scaffold(
              backgroundColor: isDark
                  ? TamgaciConstants.backgroundColorDark
                  : TamgaciConstants.backgroundColor,
              appBar: CustomAppBar(
                title: product.name,
                showBackButton: true,
                showDrawer: false,
                actions: [
                  IconButton(
                    onPressed: () => _showProductActions(context, product),
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ürün resmi ve temel bilgiler
                    _buildProductHeader(context, product),

                    const SizedBox(height: 24),

                    // Fiyat bilgileri
                    _buildPricingSection(context, product),

                    const SizedBox(height: 24),

                    // Stok bilgileri
                    _buildStockSection(context, product),

                    const SizedBox(height: 24),

                    // Ek bilgiler
                    _buildAdditionalInfoSection(context, product),

                    const SizedBox(height: 24),

                    // Bağlı ürünler
                    if (product.linkedProducts != null &&
                        product.linkedProducts!.isNotEmpty)
                      _buildLinkedProductsSection(context, product),
                  ],
                ),
              ),
            );
          },
          loading: () => const Scaffold(
            appBar: CustomAppBar(
              title: 'Ürün Yükleniyor',
              showBackButton: true,
              showDrawer: false,
            ),
            body: LoadingWidget(),
          ),
          error: (error, stack) => Scaffold(
            appBar: const CustomAppBar(
              title: 'Hata',
              showBackButton: true,
              showDrawer: false,
            ),
            body: custom_error.ErrorWidget(
              error: error.toString(),
              onRetry: () => ref.refresh(productDetailProvider(productId)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductHeader(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ürün resmi
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: TamgaciConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: TamgaciConstants.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: product.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultProductIcon();
                        },
                      ),
                    )
                  : _buildDefaultProductIcon(),
            ),

            const SizedBox(height: 16),

            // Ürün adı
            Text(
              product.name,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? TamgaciConstants.textPrimaryDark
                    : TamgaciConstants.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Ürün türü
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTypeColor(product.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getTypeColor(product.type).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                product.type.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getTypeColor(product.type),
                ),
              ),
            ),

            if (product.description != null) ...[
              const SizedBox(height: 16),
              Text(
                product.description!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark
                      ? TamgaciConstants.textSecondaryDark
                      : TamgaciConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fiyat Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? TamgaciConstants.textPrimaryDark
                    : TamgaciConstants.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Satış fiyatı
            _buildInfoRow(
              'Satış Fiyatı',
              '${product.salesPrice.toStringAsFixed(2)} ${product.salesCurrency}',
              isDark,
            ),

            if (product.salesTaxInclusive == TaxInclusiveOption.inclusive)
              _buildInfoRow(
                'KDV Dahil Satış Fiyatı',
                '${product.salesPriceWithTax.toStringAsFixed(2)} ${product.salesCurrency}',
                isDark,
              ),

            if (product.purchasePrice != null) ...[
              _buildInfoRow(
                'Alış Fiyatı',
                '${product.purchasePrice!.toStringAsFixed(2)} ${product.purchaseCurrency ?? product.salesCurrency}',
                isDark,
              ),
              if (product.purchaseTaxInclusive == TaxInclusiveOption.inclusive)
                _buildInfoRow(
                  'KDV Dahil Alış Fiyatı',
                  '${product.purchasePriceWithTax?.toStringAsFixed(2)} ${product.purchaseCurrency ?? product.salesCurrency}',
                  isDark,
                ),
            ],

            _buildInfoRow(
              'KDV Oranı',
              '%${product.salesTaxRate.toStringAsFixed(1)}',
              isDark,
            ),

            if (product.purchaseDiscount != null)
              _buildInfoRow(
                'Alış İskontosu',
                '%${product.purchaseDiscount!.toStringAsFixed(1)}',
                isDark,
              ),

            if (product.sct != null)
              _buildInfoRow(
                'ÖTV Oranı',
                '%${product.sct!.toStringAsFixed(1)}',
                isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSection(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stok Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? TamgaciConstants.textPrimaryDark
                    : TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Stok Durumu',
              product.stockStatus,
              isDark,
              valueColor: _getStockStatusColor(product.stockStatus),
            ),
            _buildInfoRow(
              'Toplam Stok',
              product.totalStockQuantity.toString(),
              isDark,
            ),
            _buildInfoRow(
              'Stok Takibi',
              product.stockTracking.displayName,
              isDark,
            ),
            if (product.criticalStockQuantity != null)
              _buildInfoRow(
                'Kritik Stok',
                product.criticalStockQuantity.toString(),
                isDark,
              ),
            if (product.shelfLocation != null)
              _buildInfoRow(
                'Raf Yeri',
                product.shelfLocation!,
                isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ek Bilgiler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? TamgaciConstants.textPrimaryDark
                    : TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (product.productCode != null)
              _buildInfoRow('Ürün Kodu', product.productCode!, isDark),
            if (product.barcode != null)
              _buildInfoRow('Barkod', product.barcode!, isDark),
            if (product.category != null)
              _buildInfoRow('Kategori', product.category!, isDark),
            if (product.brand != null)
              _buildInfoRow('Marka', product.brand!, isDark),
            if (product.gtipCode != null)
              _buildInfoRow('GTIP Kodu', product.gtipCode!, isDark),
            if (product.countryCode != null)
              _buildInfoRow('Ülke Kodu', product.countryCode!, isDark),
            if (product.tags.isNotEmpty)
              _buildInfoRow('Etiketler', product.tags.join(', '), isDark),
            if (product.notes != null)
              _buildInfoRow('Notlar', product.notes!, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkedProductsSection(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bağlı Ürünler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? TamgaciConstants.textPrimaryDark
                    : TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...product.linkedProducts!.map(
              (linkedProduct) => ListTile(
                leading: const Icon(Icons.link),
                title: Text(linkedProduct),
                subtitle: const Text('Bu ürün satıldığında stoktan düşer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? TamgaciConstants.textSecondaryDark
                    : TamgaciConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ??
                    (isDark
                        ? TamgaciConstants.textPrimaryDark
                        : TamgaciConstants.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultProductIcon() {
    return const Icon(
      Icons.inventory_2_outlined,
      color: TamgaciConstants.primaryColor,
      size: 64,
    );
  }

  Color _getTypeColor(ProductType type) {
    switch (type) {
      case ProductType.stocked:
        return Colors.green;
      case ProductType.nonStocked:
        return Colors.orange;
      case ProductType.service:
        return Colors.blue;
      case ProductType.digital:
        return Colors.purple;
    }
  }

  Color _getStockStatusColor(String status) {
    switch (status) {
      case 'Stokta Var':
        return Colors.green;
      case 'Kritik Stok':
        return Colors.orange;
      case 'Stokta Yok':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showProductActions(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit page
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Kopyala'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Copy product
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Sil', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, product);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content:
            Text('${product.name} ürününü silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct(context, product);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, Product product) async {
    try {
      final container = ProviderScope.containerOf(context);
      await container
          .read(productOperationsProvider.notifier)
          .deleteProduct(product.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ürün başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
