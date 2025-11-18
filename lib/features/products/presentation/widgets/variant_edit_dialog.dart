// ========== VARIANT EDIT DIALOG ==========
// lib/features/products/presentation/widgets/variant_edit_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../providers/product_providers.dart';

/// Varyant düzenleme dialog'u
class VariantEditDialog extends ConsumerStatefulWidget {
  final Product product;
  final ProductVariant variant;
  final int variantIndex;

  const VariantEditDialog({
    super.key,
    required this.product,
    required this.variant,
    required this.variantIndex,
  });

  @override
  ConsumerState<VariantEditDialog> createState() => _VariantEditDialogState();
}

class _VariantEditDialogState extends ConsumerState<VariantEditDialog> {
  late TextEditingController _stockController;
  late TextEditingController _shelfLocationController;
  late TextEditingController _barcodeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _stockController =
        TextEditingController(text: widget.variant.stockQuantity.toString());
    _shelfLocationController =
        TextEditingController(text: widget.variant.shelfLocation ?? '');
    _barcodeController =
        TextEditingController(text: widget.variant.barcode ?? '');
  }

  @override
  void dispose() {
    _stockController.dispose();
    _shelfLocationController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? Colors.grey[850] : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 24),
            _buildVariantInfo(isDark),
            const SizedBox(height: 24),
            _buildFormFields(isDark),
            const SizedBox(height: 24),
            _buildActions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.edit,
            color: Colors.purple[600],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Varyant Düzenle',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? TamgaciConstants.textPrimaryDark
                      : TamgaciConstants.textPrimary,
                ),
              ),
              Text(
                widget.product.name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildVariantInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Varyant Bilgileri',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.variant.name,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.purple[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mevcut Stok: ${CurrencyHelper.formatNumber(widget.variant.stockQuantity.toDouble()).replaceAll(',00', '')} adet',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(bool isDark) {
    return Column(
      children: [
        // Stok Miktarı
        TextFormField(
          controller: _stockController,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.grey[800],
          ),
          decoration: InputDecoration(
            labelText: 'Stok Miktarı',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            hintText: 'Örn: 100',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.inventory_2,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Stok miktarı gerekli';
            }
            final stock = int.tryParse(value);
            if (stock == null || stock < 0) {
              return 'Geçerli bir stok miktarı girin';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Raf Yeri
        TextFormField(
          controller: _shelfLocationController,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.grey[800],
          ),
          decoration: InputDecoration(
            labelText: 'Raf Yeri',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            hintText: 'Örn: A-1-3',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.location_on,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),
        // Barkod
        TextFormField(
          controller: _barcodeController,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.grey[800],
          ),
          decoration: InputDecoration(
            labelText: 'Barkod',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            hintText: 'Örn: 1234567890123',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.qr_code_2,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[300]!,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveVariant,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'Kaydet',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveVariant() async {
    if (_stockController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok miktarı gerekli'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final stockQuantity = int.parse(_stockController.text.trim());
      final shelfLocation = _shelfLocationController.text.trim().isEmpty
          ? null
          : _shelfLocationController.text.trim();
      final barcode = _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim();

      // Varyantı güncelle
      final updatedVariant = widget.variant.copyWith(
        stockQuantity: stockQuantity,
        shelfLocation: shelfLocation,
        barcode: barcode,
      );

      // Ürünün varyantlarını güncelle
      final updatedVariants =
          List<ProductVariant>.from(widget.product.variants!);
      updatedVariants[widget.variantIndex] = updatedVariant;

      final updatedProduct = widget.product.copyWith(
        variants: updatedVariants,
      );

      // Ürünü güncelle
      await ref.read(productRepositoryProvider).updateProduct(updatedProduct);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Varyant başarıyla güncellendi'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
