// ========== PRODUCTS (ÜRÜNLER) FEATURE ==========
// lib/features/products/presentation/pages/create_product_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/product_providers.dart';
import '../../domain/entities/product.dart';

/// Ürün oluşturma/düzenleme sayfası
class CreateProductPage extends ConsumerStatefulWidget {
  final int? productId; // Düzenleme için ürün ID'si

  const CreateProductPage({super.key, this.productId});

  @override
  ConsumerState<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends ConsumerState<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _minStockLevelController = TextEditingController();
  final _unitController = TextEditingController();
  final _taxRateController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.productId != null;
    if (_isEditing) {
      _loadProductData();
    } else {
      _unitController.text = 'Adet';
      _taxRateController.text = '20.0';
    }
  }

  void _loadProductData() async {
    setState(() => _isLoading = true);

    try {
      final operationsState = ref.read(productOperationsProvider);
      final product = operationsState.products.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () => throw Exception('Ürün bulunamadı'),
      );

      _nameController.text = product.name;
      _descriptionController.text = product.description ?? '';
      _skuController.text = product.sku ?? '';
      _barcodeController.text = product.barcode ?? '';
      _categoryController.text = product.category ?? '';
      _unitPriceController.text = product.unitPrice.toString();
      _stockQuantityController.text = product.stockQuantity.toString();
      _minStockLevelController.text = product.minStockLevel.toString();
      _unitController.text = product.unit;
      _taxRateController.text = product.taxRate.toString();
      _isActive = product.isActive;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün yüklenirken hata oluştu: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final product = Product(
        id: widget.productId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        sku: _skuController.text.trim().isEmpty
            ? null
            : _skuController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        unitPrice: double.parse(_unitPriceController.text),
        stockQuantity: int.parse(_stockQuantityController.text),
        minStockLevel: int.parse(_minStockLevelController.text),
        unit: _unitController.text.trim(),
        taxRate: double.parse(_taxRateController.text),
        isActive: _isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await ref
            .read(productOperationsProvider.notifier)
            .updateProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ürün başarıyla güncellendi')),
          );
        }
      } else {
        await ref
            .read(productOperationsProvider.notifier)
            .createProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ürün başarıyla oluşturuldu')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _unitPriceController.dispose();
    _stockQuantityController.dispose();
    _minStockLevelController.dispose();
    _unitController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TamgaciConstants.backgroundColorDark : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: _isEditing ? 'Ürün Düzenle' : 'Yeni Ürün',
        showBackButton: true,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveForm,
              child: Text(
                _isEditing ? 'Güncelle' : 'Kaydet',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: TamgaciConstants.paddingMedium(context),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Temel Bilgiler
                    _buildSectionTitle('Temel Bilgiler', isDark),
                    _buildNameField(),
                    _buildDescriptionField(),
                    _buildCategoryField(),

                    const SizedBox(height: TamgaciConstants.spaceLG),

                    // Kod Bilgileri
                    _buildSectionTitle('Kod Bilgileri', isDark),
                    _buildSkuField(),
                    _buildBarcodeField(),

                    const SizedBox(height: TamgaciConstants.spaceLG),

                    // Fiyat ve Stok Bilgileri
                    _buildSectionTitle('Fiyat ve Stok Bilgileri', isDark),
                    _buildPriceAndStockFields(),

                    const SizedBox(height: TamgaciConstants.spaceLG),

                    // Diğer Bilgiler
                    _buildSectionTitle('Diğer Bilgiler', isDark),
                    _buildOtherFields(),

                    const SizedBox(height: TamgaciConstants.spaceLG),

                    // Durum
                    _buildStatusField(isDark),

                    const SizedBox(height: TamgaciConstants.spaceXXL),
                  ],
                ),
              ),
            ),
    );
  }

  /// Bölüm başlığı oluşturur
  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? TamgaciConstants.textPrimaryDark : TamgaciConstants.textPrimary,
        ),
      ),
    );
  }

  /// Ürün adı alanı
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Ürün Adı *',
        hintText: 'Örn: iPhone 15 Pro',
        border: const OutlineInputBorder(),
        labelStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ürün adı gereklidir';
        }
        return null;
      },
    );
  }

  /// Açıklama alanı
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Açıklama',
        hintText: 'Ürün açıklaması...',
        border: const OutlineInputBorder(),
        labelStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
      ),
      maxLines: 3,
    );
  }

  /// Kategori alanı
  Widget _buildCategoryField() {
    return TextFormField(
      controller: _categoryController,
      decoration: InputDecoration(
        labelText: 'Kategori',
        hintText: 'Örn: Elektronik',
        border: const OutlineInputBorder(),
        labelStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
      ),
    );
  }

  /// SKU alanı
  Widget _buildSkuField() {
    return TextFormField(
      controller: _skuController,
      decoration: InputDecoration(
        labelText: 'SKU',
        hintText: 'Örn: IPH15PRO-128',
        border: const OutlineInputBorder(),
        labelStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
      ),
    );
  }

  /// Barkod alanı
  Widget _buildBarcodeField() {
    return TextFormField(
      controller: _barcodeController,
      decoration: InputDecoration(
        labelText: 'Barkod',
        hintText: '1234567890123',
        border: const OutlineInputBorder(),
        labelStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
      ),
    );
  }

  /// Birim fiyat alanı
  Widget _buildUnitPriceField() {
    return TextFormField(
      controller: _unitPriceController,
      decoration: InputDecoration(
        labelText: 'Birim Fiyat (₺) *',
        hintText: '0.00',
        border: const OutlineInputBorder(),
        labelStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
        prefixText: '₺',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Birim fiyat gereklidir';
        }
        final price = double.tryParse(value);
        if (price == null || price < 0) {
          return 'Geçerli bir fiyat giriniz';
        }
        return null;
      },
    );
  }

  /// KDV oranı alanı
  Widget _buildTaxRateField() {
    return TextFormField(
      controller: _taxRateController,
      decoration: InputDecoration(
        labelText: 'KDV Oranı (%) *',
        hintText: '20.0',
        border: const OutlineInputBorder(),
        labelStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
        suffixText: '%',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'KDV oranı gereklidir';
        }
        final rate = double.tryParse(value);
        if (rate == null || rate < 0 || rate > 100) {
          return 'Geçerli bir KDV oranı giriniz (0-100)';
        }
        return null;
      },
    );
  }

  /// Stok miktarı alanı
  Widget _buildStockQuantityField() {
    return TextFormField(
      controller: _stockQuantityController,
      decoration: InputDecoration(
        labelText: 'Stok Miktarı *',
        hintText: '0',
        border: const OutlineInputBorder(),
        labelStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Stok miktarı gereklidir';
        }
        final quantity = int.tryParse(value);
        if (quantity == null || quantity < 0) {
          return 'Geçerli bir stok miktarı giriniz';
        }
        return null;
      },
    );
  }

  /// Minimum stok seviyesi alanı
  Widget _buildMinStockLevelField() {
    return TextFormField(
      controller: _minStockLevelController,
      decoration: InputDecoration(
        labelText: 'Minimum Stok Seviyesi *',
        hintText: '5',
        border: const OutlineInputBorder(),
        labelStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Minimum stok seviyesi gereklidir';
        }
        final level = int.tryParse(value);
        if (level == null || level < 0) {
          return 'Geçerli bir minimum stok seviyesi giriniz';
        }
        return null;
      },
    );
  }

  /// Birim alanı
  Widget _buildUnitField() {
    return TextFormField(
      controller: _unitController,
      decoration: InputDecoration(
        labelText: 'Birim *',
        hintText: 'Adet, Kg, Lt...',
        border: const OutlineInputBorder(),
        labelStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          color: TamgaciConstants.textSecondary,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Birim gereklidir';
        }
        return null;
      },
    );
  }

  /// Fiyat ve stok alanları
  Widget _buildPriceAndStockFields() {
    return Column(
      children: [
        _buildUnitPriceField(),
        const SizedBox(height: TamgaciConstants.spaceMD),
        _buildTaxRateField(),
        const SizedBox(height: TamgaciConstants.spaceMD),
        _buildStockQuantityField(),
        const SizedBox(height: TamgaciConstants.spaceMD),
        _buildMinStockLevelField(),
      ],
    );
  }

  /// Diğer alanlar
  Widget _buildOtherFields() {
    return _buildUnitField();
  }

  /// Durum alanı
  Widget _buildStatusField(bool isDark) {
    return SwitchListTile(
      title: Text(
        'Aktif',
        style: GoogleFonts.poppins(
          color: isDark ? TamgaciConstants.textPrimaryDark : TamgaciConstants.textPrimary,
        ),
      ),
      subtitle: Text(
        'Ürün aktif olarak satışta',
        style: GoogleFonts.poppins(
          color: isDark ? TamgaciConstants.textSecondaryDark : TamgaciConstants.textSecondary,
        ),
      ),
      value: _isActive,
      onChanged: (value) {
        setState(() {
          _isActive = value;
        });
      },
      activeThumbColor: TamgaciConstants.primaryColor,
    );
  }

  /// Aktif/Pasif switch'i
  Widget _buildActiveSwitch() {
    return SwitchListTile(
      title: const Text('Aktif'),
      subtitle: const Text('Ürün aktif olarak satışta'),
      value: _isActive,
      onChanged: (value) {
        setState(() {
          _isActive = value;
        });
      },
      activeThumbColor: TamgaciConstants.primaryColor,
    );
  }
}
