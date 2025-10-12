// ========== PRODUCT DETAIL PAGE ==========
// lib/features/products/presentation/pages/product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../../core/theme/constants.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;
import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';
import '../widgets/product_movements_widget.dart';
import '../../data/services/firebase_storage_service.dart';
import '../../../../core/utils/currency_helper.dart';

/// Ürün detay sayfası
class ProductDetailPage extends ConsumerWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  Widget _buildPremiumHeader(Product product) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Indigo-500
            Color(0xFF8B5CF6), // Violet-500
            Color(0xFF7C3AED), // Violet-600
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getProductTypeIcon(product.type),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.type.displayName} • ${product.warehouseName ?? "Depo yok"}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.inventory,
                        size: 16, color: Colors.white.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Text(
                      'Stok: ${product.totalStockQuantity}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money,
                        size: 16, color: Colors.white.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Text(
                      '₺${product.salesPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProductTypeIcon(ProductType type) {
    switch (type) {
      case ProductType.stocked:
        return Icons.inventory;
      case ProductType.nonStocked:
        return Icons.shopping_cart;
      case ProductType.service:
        return Icons.build;
      case ProductType.digital:
        return Icons.download;
    }
  }

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
              appBar: AppBar(
                title: Text(
                  product.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 1,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    onPressed: () => _showProductActions(context, product, ref),
                    icon: const Icon(Icons.more_vert, color: Colors.black87),
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Premium Header
                  _buildPremiumHeader(product),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ürün resmi ve temel bilgiler
                          _buildProductHeader(context, product),

                          const SizedBox(height: 24),

                          // Ürün fotoğrafları
                          if (product.images.isNotEmpty) ...[
                            _buildProductImagesSection(context, product),
                            const SizedBox(height: 24),
                          ],

                          // Fiyat bilgileri
                          _buildPricingSection(context, product),

                          const SizedBox(height: 24),

                          // Stok bilgileri
                          _buildStockSection(context, product),

                          const SizedBox(height: 24),

                          // Ek bilgiler
                          _buildAdditionalInfoSection(context, product),

                          const SizedBox(height: 24),

                          // Varyantlar
                          if (product.variants != null &&
                              product.variants!.isNotEmpty)
                            _buildVariantsSection(context, product),

                          const SizedBox(height: 24),

                          // Bağlı ürünler
                          if (product.linkedProducts != null &&
                              product.linkedProducts!.isNotEmpty)
                            _buildLinkedProductsSection(context, product),

                          const SizedBox(height: 24),

                          // Ürün hareketleri
                          ProductMovementsWidget(product: product),
                        ],
                      ),
                    ),
                  ),
                ],
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

  Widget _buildProductImagesSection(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Ürün Fotoğrafları',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? TamgaciConstants.textPrimaryDark
                        : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: product.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          _showImageDialog(context, product.images, index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.images[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          isAntiAlias: true,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[600],
                                size: 32,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(
      BuildContext context, List<String> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 64),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
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
              '${CurrencyHelper.formatNumber(product.salesPrice)} ${product.salesCurrency}',
              isDark,
            ),

            // KDV bilgisi
            _buildInfoRow(
              'KDV Oranı',
              '%${product.salesTaxRate.toStringAsFixed(0)}',
              isDark,
            ),

            // KDV dahil/hariç fiyat gösterimi
            if (product.salesTaxInclusive == TaxInclusiveOption.inclusive) ...[
              _buildInfoRow(
                'KDV Dahil Satış Fiyatı',
                '${CurrencyHelper.formatNumber(product.salesPriceWithTax)} ${product.salesCurrency}',
                isDark,
              ),
              _buildInfoRow(
                'KDV Tutarı',
                '${CurrencyHelper.formatNumber(product.salesTaxAmount)} ${product.salesCurrency}',
                isDark,
              ),
            ] else ...[
              _buildInfoRow(
                'KDV Hariç Satış Fiyatı',
                '${CurrencyHelper.formatNumber(product.salesPriceWithoutTax)} ${product.salesCurrency}',
                isDark,
              ),
              _buildInfoRow(
                'KDV Dahil Satış Fiyatı',
                '${CurrencyHelper.formatNumber(product.salesPriceWithTax)} ${product.salesCurrency}',
                isDark,
              ),
              _buildInfoRow(
                'KDV Tutarı',
                '${CurrencyHelper.formatNumber(product.salesTaxAmount)} ${product.salesCurrency}',
                isDark,
              ),
            ],

            if (product.purchasePrice != null) ...[
              _buildInfoRow(
                'Alış Fiyatı',
                '${CurrencyHelper.formatNumber(product.purchasePrice!)} ${product.purchaseCurrency ?? product.salesCurrency}',
                isDark,
              ),
              if (product.purchaseTaxInclusive ==
                      TaxInclusiveOption.inclusive &&
                  product.purchasePriceWithTax != null)
                _buildInfoRow(
                  'KDV Dahil Alış Fiyatı',
                  '${CurrencyHelper.formatNumber(product.purchasePriceWithTax!)} ${product.purchaseCurrency ?? product.salesCurrency}',
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
              'Stok ve Depo Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? TamgaciConstants.textPrimaryDark
                    : TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Warehouse bilgileri
            if (product.warehouseName != null) ...[
              _buildInfoRow(
                'Depo',
                product.warehouseName!,
                isDark,
                icon: Icons.warehouse,
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 8),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Bu ürün henüz bir depoya atanmamış',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.orange[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Stok bilgileri
            _buildInfoRow(
              'Stok Durumu',
              product.stockStatus,
              isDark,
              valueColor: _getStockStatusColor(product.stockStatus),
              icon: Icons.inventory,
            ),
            _buildInfoRow(
              'Toplam Stok',
              product.totalStockQuantity.toString(),
              isDark,
              icon: Icons.numbers,
            ),
            _buildInfoRow(
              'Stok Takibi',
              product.stockTracking.displayName,
              isDark,
              icon: Icons.track_changes,
            ),
            if (product.criticalStockQuantity != null)
              _buildInfoRow(
                'Kritik Stok',
                product.criticalStockQuantity.toString(),
                isDark,
                icon: Icons.warning,
                iconColor: Colors.orange,
              ),
            if (product.shelfLocation != null)
              _buildInfoRow(
                'Raf Yeri',
                product.shelfLocation!,
                isDark,
                icon: Icons.location_on,
                iconColor: Colors.green,
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

            // Özel Özellikler
            if (product.attributeValues != null &&
                product.attributeValues!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, color: Colors.blue[700], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Özel Özellikler',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...product.attributeValues!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.key,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                entry.value.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVariantsSection(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard_customize, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'Varyantlar (${product.variants!.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? TamgaciConstants.textPrimaryDark
                        : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...product.variants!.map((variant) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: variant.stockQuantity > 0
                      ? Colors.green.withValues(alpha: 0.05)
                      : Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: variant.stockQuantity > 0
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            variant.name,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: variant.stockQuantity > 0
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${CurrencyHelper.formatNumber(variant.stockQuantity.toDouble()).replaceAll(',00', '')} adet',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (variant.shelfLocation != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: Colors.blue[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Raf: ${variant.shelfLocation}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
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
    IconData? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: iconColor ?? Colors.grey[600],
            ),
            const SizedBox(width: 8),
          ],
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

  void _showProductActions(
      BuildContext context, Product product, WidgetRef ref) {
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
                Navigator.pushNamed(
                  context,
                  '/products/create',
                  arguments: product.id,
                );
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
                _showDeleteConfirmation(context, product, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Product product, WidgetRef ref) {
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
              await _deleteProduct(context, product, ref);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(
      BuildContext context, Product product, WidgetRef ref) async {
    try {
      debugPrint('🗑️ Ürün silme işlemi başlatılıyor: ${product.id}');

      // Navigation'ı önceden hazırla
      debugPrint('🚀 Navigation hazırlanıyor...');
      final navigator = Navigator.of(context);

      // Firebase Storage'dan fotoğrafları sil
      if (product.images.isNotEmpty) {
        final storageService = FirebaseStorageService();
        await storageService.deleteProductImages(product.images);
        debugPrint('📸 Fotoğraflar silindi');
      }

      // Ürünü sil
      await ref
          .read(productOperationsProvider.notifier)
          .deleteProduct(product.id);

      debugPrint('✅ Ürün başarıyla silindi');

      // İstatistikleri güncelle
      ref.invalidate(productStatisticsProvider);

      // Stream'in güncellenmesi için bekleme
      await Future.delayed(const Duration(milliseconds: 300));

      debugPrint(
          '🚀 Ürün listesi sayfasına yönlendiriliyor: ${TamgaciRoutes.productsList}');
      // Tüm stack'i temizleyip ürün listesi sayfasına git
      navigator.pushNamedAndRemoveUntil(
        TamgaciRoutes.productsList,
        (route) => false,
      );
      debugPrint('✅ Navigation tamamlandı');
    } catch (e) {
      debugPrint('❌ Ürün silinirken hata: $e');
      // Hata durumunda da navigation yap
      try {
        final navigator = Navigator.of(context);
        navigator.pushNamedAndRemoveUntil(
          TamgaciRoutes.productsList,
          (route) => false,
        );
        debugPrint('✅ Hata durumu navigation tamamlandı');
      } catch (navError) {
        debugPrint('❌ Navigation hatası: $navError');
      }
    }
  }
}
