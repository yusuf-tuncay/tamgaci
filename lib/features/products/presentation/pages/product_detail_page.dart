// ========== PRODUCTS (ÜRÜNLER) FEATURE ==========
// lib/features/products/presentation/pages/product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/product_providers.dart';
import '../../domain/entities/product.dart';

/// Ürün detay sayfası
class ProductDetailPage extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() {
    // Ürün detayı zaten provider'da yüklü olmalı
    // Eğer yüklü değilse yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final operationsState = ref.read(productOperationsProvider);
      if (operationsState.products.isEmpty && !operationsState.isLoading) {
        ref.read(productOperationsProvider.notifier).loadProducts();
      }
    });
  }

  void _navigateToEdit() {
    Navigator.of(
      context,
    ).pushNamed('/product/edit', arguments: widget.productId);
  }

  void _deleteProduct() async {
    final operationsState = ref.read(productOperationsProvider);
    final product = operationsState.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => throw Exception('Ürün bulunamadı'),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content: const Text(
          'Bu ürünü silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: TamgaciConstants.errorColor,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(productOperationsProvider.notifier)
          .deleteProduct(product.id!);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ürün başarıyla silindi')));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(productOperationsProvider);

    // Ürün bulunamadığında hata sayfası göster
    try {
      final product = operationsState.products.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () => throw Exception('Ürün bulunamadı'),
      );

      return Scaffold(
        backgroundColor: TamgaciConstants.backgroundColor,
        appBar: CustomAppBar(
          title: 'Ürün Detayı',
          showBackButton: true,
          actions: [
            IconButton(
              onPressed: _navigateToEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Düzenle',
            ),
            IconButton(
              onPressed: _deleteProduct,
              icon: const Icon(Icons.delete),
              tooltip: 'Sil',
            ),
          ],
        ),
        body: operationsState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : operationsState.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Hata: ${operationsState.errorMessage}'),
                        ElevatedButton(
                          onPressed: _loadProduct,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  )
                : _buildProductDetail(product),
      );
    } catch (e) {
      return Scaffold(
        backgroundColor: TamgaciConstants.backgroundColor,
        appBar: const CustomAppBar(title: 'Ürün Detayı', showBackButton: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: TamgaciConstants.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Ürün bulunamadı',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: TamgaciConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aradığınız ürün mevcut değil veya silinmiş olabilir.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TamgaciConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Geri Dön'),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Ürün detayını oluşturur
  Widget _buildProductDetail(Product product) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.stockQuantity <= 0;

    return SingleChildScrollView(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ürün kartı
          _buildProductCard(product, currencyFormat),

          const SizedBox(height: TamgaciConstants.spaceLG),

          // Detay bilgileri
          _buildDetailSection(product, currencyFormat),

          const SizedBox(height: TamgaciConstants.spaceLG),

          // Stok bilgileri
          _buildStockSection(product),

          const SizedBox(height: TamgaciConstants.spaceLG),

          // Fiyat bilgileri
          _buildPriceSection(product, currencyFormat),

          if (product.description != null &&
              product.description!.isNotEmpty) ...[
            const SizedBox(height: TamgaciConstants.spaceLG),
            _buildDescriptionSection(product),
          ],

          const SizedBox(height: TamgaciConstants.spaceLG),

          // İşlem butonları
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Ürün kartı oluşturur
  Widget _buildProductCard(Product product, NumberFormat currencyFormat) {
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.stockQuantity <= 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusLG),
      ),
      child: Padding(
        padding: TamgaciConstants.paddingLarge(context),
        child: Column(
          children: [
            // Ürün ikonu
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? TamgaciConstants.errorColor.withValues(alpha: 0.1)
                    : isLowStock
                        ? TamgaciConstants.warningColor.withValues(alpha: 0.1)
                        : TamgaciConstants.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusLG),
              ),
              child: Icon(
                Icons.inventory_2,
                size: 40,
                color: isOutOfStock
                    ? TamgaciConstants.errorColor
                    : isLowStock
                        ? TamgaciConstants.warningColor
                        : TamgaciConstants.successColor,
              ),
            ),

            const SizedBox(height: TamgaciConstants.spaceMD),

            // Ürün adı
            Text(
              product.name,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            if (product.category != null) ...[
              const SizedBox(height: TamgaciConstants.spaceSM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: TamgaciConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.category!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: TamgaciConstants.primaryColor,
                  ),
                ),
              ),
            ],

            const SizedBox(height: TamgaciConstants.spaceMD),

            // Fiyat
            Text(
              currencyFormat.format(product.unitPrice),
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: TamgaciConstants.successColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Detay bölümü oluşturur
  Widget _buildDetailSection(Product product, NumberFormat currencyFormat) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: TamgaciConstants.paddingMedium(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ürün Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            _buildDetailRow('Ürün Adı', product.name),
            if (product.sku != null) _buildDetailRow('SKU', product.sku!),
            if (product.barcode != null)
              _buildDetailRow('Barkod', product.barcode!),
            if (product.category != null)
              _buildDetailRow('Kategori', product.category!),
            _buildDetailRow('Birim', product.unit),
            _buildDetailRow('Durum', product.isActive ? 'Aktif' : 'Pasif'),
          ],
        ),
      ),
    );
  }

  /// Stok bölümü oluşturur
  Widget _buildStockSection(Product product) {
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.stockQuantity <= 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: TamgaciConstants.paddingMedium(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory,
                  color: isOutOfStock
                      ? TamgaciConstants.errorColor
                      : isLowStock
                          ? TamgaciConstants.warningColor
                          : TamgaciConstants.successColor,
                ),
                const SizedBox(width: TamgaciConstants.spaceSM),
                Text(
                  'Stok Bilgileri',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            _buildDetailRow(
              'Mevcut Stok',
              '${product.stockQuantity} ${product.unit}',
            ),
            _buildDetailRow(
              'Minimum Stok',
              '${product.minStockLevel} ${product.unit}',
            ),
            const SizedBox(height: TamgaciConstants.spaceSM),
            _buildStockStatusChip(product),
          ],
        ),
      ),
    );
  }

  /// Fiyat bölümü oluşturur
  Widget _buildPriceSection(Product product, NumberFormat currencyFormat) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: TamgaciConstants.paddingMedium(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: TamgaciConstants.successColor),
                const SizedBox(width: TamgaciConstants.spaceSM),
                Text(
                  'Fiyat Bilgileri',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            _buildDetailRow(
              'Birim Fiyat',
              currencyFormat.format(product.unitPrice),
            ),
            _buildDetailRow(
              'KDV Oranı',
              '%${product.taxRate.toStringAsFixed(1)}',
            ),
          ],
        ),
      ),
    );
  }

  /// Açıklama bölümü oluşturur
  Widget _buildDescriptionSection(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: TamgaciConstants.paddingMedium(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: TamgaciConstants.textSecondary),
                const SizedBox(width: TamgaciConstants.spaceSM),
                Text(
                  'Açıklama',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            Text(
              product.description!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// İşlem butonları oluşturur
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _navigateToEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Düzenle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TamgaciConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: TamgaciConstants.spaceMD),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _deleteProduct,
            icon: const Icon(Icons.delete),
            label: const Text('Sil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TamgaciConstants.errorColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Detay satırı oluşturur
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Stok durumu chip'i oluşturur
  Widget _buildStockStatusChip(Product product) {
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.stockQuantity <= 0;

    Color backgroundColor;
    Color textColor;
    String text;

    if (isOutOfStock) {
      backgroundColor = TamgaciConstants.errorColor.withValues(alpha: 0.1);
      textColor = TamgaciConstants.errorColor;
      text = 'Stokta Yok';
    } else if (isLowStock) {
      backgroundColor = TamgaciConstants.warningColor.withValues(alpha: 0.1);
      textColor = TamgaciConstants.warningColor;
      text = 'Kritik Stok';
    } else {
      backgroundColor = TamgaciConstants.successColor.withValues(alpha: 0.1);
      textColor = TamgaciConstants.successColor;
      text = 'Stokta Var';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
