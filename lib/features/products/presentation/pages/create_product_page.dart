// ========== CREATE PRODUCT PAGE ==========
// lib/features/products/presentation/pages/create_product_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/constants.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/utils/barcode_generator.dart';
import '../providers/product_providers.dart';
import '../../../warehouses/domain/entities/warehouse.dart';
import '../../../warehouses/presentation/providers/warehouse_providers.dart';
import '../../data/services/firebase_storage_service.dart';
import '../../../../core/utils/currency_helper.dart';

/// Ürün oluşturma sayfası
class CreateProductPage extends ConsumerStatefulWidget {
  final String? productId; // Düzenleme için ürün ID'si

  const CreateProductPage({
    super.key,
    this.productId,
  });

  @override
  ConsumerState<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends ConsumerState<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productCodeController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _salesPriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salesTaxRateController = TextEditingController();
  final _purchaseTaxRateController = TextEditingController();
  final _purchaseDiscountController = TextEditingController();
  final _sctController = TextEditingController();
  final _shelfLocationController = TextEditingController();
  final _criticalStockController = TextEditingController();
  final _gtipCodeController = TextEditingController();
  final _countryCodeController = TextEditingController();
  final _notesController = TextEditingController();
  final _stockQuantityController = TextEditingController();

  // Focus node'lar fiyat formatlaması için
  final _salesPriceFocusNode = FocusNode();
  final _purchasePriceFocusNode = FocusNode();

  ProductType _selectedType = ProductType.stocked;
  StockTrackingType _selectedStockTracking = StockTrackingType.normal;
  TaxInclusiveOption _salesTaxInclusive = TaxInclusiveOption.exclusive;
  TaxInclusiveOption? _purchaseTaxInclusive = TaxInclusiveOption.exclusive;
  String _salesCurrency = 'TRY';
  String? _purchaseCurrency;
  Warehouse? _selectedWarehouse;
  String? _currentWarehouseId; // Düzenleme modunda mevcut depo ID'si
  final List<String> _tags = [];
  List<String> _images = [];
  final List<String> _linkedProducts = [];
  final List<File> _selectedImages = [];
  final List<Uint8List> _selectedImageBytes = [];

  // Dinamik kategori ve marka listeleri
  final List<String> _customCategories = [];
  final List<String> _customBrands = [];

  // Özel özellikler (Custom Attributes)
  final Map<String, String> _customAttributes = {};

  // Varyant özellikleri
  final List<ProductVariant> _variants = [];
  final List<String> _variantTypes = []; // Renk, Beden, Boyut vb.
  final Map<String, List<String>> _variantOptions =
      {}; // {Renk: [Kırmızı, Mavi], Beden: [36, 38, 40]}
  bool _hasVariants = false;

  bool _isLoading = false;
  bool _autoGenerateBarcode = true;
  bool _autoGenerateProductCode = true;

  @override
  void initState() {
    super.initState();
    _autoGenerateProductCode = true;
    _autoGenerateBarcode = true;
    _stockQuantityController.text = '0'; // Varsayılan stok miktarı

    // Otomatik kod üretimi
    _generateProductCode();
    _generateBarcode();

    // Varsayılan para birimi seçimi
    _purchaseCurrency = 'TRY';

    // Focus listener'ları ekle
    _salesPriceFocusNode.addListener(_onSalesPriceFocusChange);
    _purchasePriceFocusNode.addListener(_onPurchasePriceFocusChange);

    // Düzenleme modu için ürün bilgilerini yükle
    if (widget.productId != null) {
      _loadProductForEdit();
    }
  }

  Future<void> _loadProductForEdit() async {
    try {
      final productAsync = ref.read(productDetailProvider(widget.productId!));
      await productAsync.when(
        data: (product) {
          if (product != null && mounted) {
            _populateFormWithProduct(product);
          }
        },
        loading: () {},
        error: (error, stack) {
          debugPrint('Ürün bilgileri yüklenemedi: $error');
        },
      );
    } catch (e) {
      debugPrint('Hata: $e');
    }
  }

  void _populateFormWithProduct(Product product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _productCodeController.text = product.productCode ?? '';
    _barcodeController.text = product.barcode ?? '';
    _categoryController.text = product.category ?? '';
    _brandController.text = product.brand ?? '';

    // Fiyatları formatlanmış şekilde yükle (virgülle)
    _salesPriceController.text =
        product.salesPrice.toStringAsFixed(2).replaceAll('.', ',');
    _purchasePriceController.text = product.purchasePrice != null
        ? product.purchasePrice!.toStringAsFixed(2).replaceAll('.', ',')
        : '';

    _salesTaxRateController.text = product.salesTaxRate.toString();
    _purchaseTaxRateController.text = product.purchaseTaxRate?.toString() ?? '';
    _purchaseDiscountController.text =
        product.purchaseDiscount?.toString() ?? '';
    _sctController.text = product.sct?.toString() ?? '';
    _shelfLocationController.text = product.shelfLocation ?? '';
    _criticalStockController.text =
        product.criticalStockQuantity?.toString() ?? '';
    _gtipCodeController.text = product.gtipCode ?? '';
    _countryCodeController.text = product.countryCode ?? '';
    _notesController.text = product.notes ?? '';
    _stockQuantityController.text = product.stockQuantity.toString();

    // Özel özellikleri yükle
    if (product.attributeValues != null) {
      _customAttributes.addAll(
        product.attributeValues!
            .map((key, value) => MapEntry(key, value.toString())),
      );
    }

    // Varyantları yükle
    if (product.variants != null && product.variants!.isNotEmpty) {
      _hasVariants = true;
      _variants.addAll(product.variants!);

      // Varyant tiplerini ve seçeneklerini çıkar
      for (final variant in product.variants!) {
        for (final entry in variant.attributes.entries) {
          if (!_variantOptions.containsKey(entry.key)) {
            _variantOptions[entry.key] = [];
            _variantTypes.add(entry.key);
          }
          if (!_variantOptions[entry.key]!.contains(entry.value)) {
            _variantOptions[entry.key]!.add(entry.value);
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _selectedType = product.type;
        _selectedStockTracking = product.stockTracking;
        _salesTaxInclusive = product.salesTaxInclusive;
        _purchaseTaxInclusive = product.purchaseTaxInclusive;
        _salesCurrency = product.salesCurrency;
        _purchaseCurrency = product.purchaseCurrency;
        _images = List<String>.from(product.images);

        // Düzenleme modunda depo seçimini yap
        if (product.warehouseId != null) {
          // Mevcut depo bilgilerini sakla, dropdown'da eşleşecek
          _currentWarehouseId = product.warehouseId;
        }
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty && mounted) {
        // Tüm işlemleri tek seferde yap
        if (kIsWeb) {
          final List<Uint8List> newBytes = [];
          for (final image in images) {
            final bytes = await image.readAsBytes();
            newBytes.add(bytes);
          }

          if (mounted) {
            setState(() {
              _selectedImageBytes.addAll(newBytes);
            });
          }
        } else {
          final List<File> newFiles = [];
          for (final image in images) {
            newFiles.add(File(image.path));
          }

          if (mounted) {
            setState(() {
              _selectedImages.addAll(newFiles);
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Fotoğraf seçilirken hata: $e');
    }
  }

  void _removeImage(int index) {
    if (mounted) {
      setState(() {
        if (kIsWeb) {
          _selectedImageBytes.removeAt(index);
        } else {
          _selectedImages.removeAt(index);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _productCodeController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _salesPriceController.dispose();
    _purchasePriceController.dispose();
    _salesTaxRateController.dispose();
    _purchaseTaxRateController.dispose();
    _purchaseDiscountController.dispose();
    _sctController.dispose();
    _shelfLocationController.dispose();
    _criticalStockController.dispose();
    _gtipCodeController.dispose();
    _countryCodeController.dispose();
    _notesController.dispose();
    _stockQuantityController.dispose();

    // Focus node'ları dispose et
    _salesPriceFocusNode.dispose();
    _purchasePriceFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.productId != null ? 'Ürün Düzenle' : 'Yeni Ürün',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Premium Header
            _buildPremiumHeader(),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Temel Bilgiler
                    _buildSectionTitle('Temel Bilgiler'),
                    _buildBasicInfoSection(),

                    const SizedBox(height: 24),

                    // Fiyat ve Vergi Bilgileri
                    _buildSectionTitle('Fiyat ve Vergi Bilgileri'),
                    _buildPricingSection(),

                    const SizedBox(height: 24),

                    // Varyant Bilgileri
                    _buildSectionTitle('Varyant Bilgileri'),
                    _buildVariantSection(),

                    const SizedBox(height: 24),

                    // Stok ve Depo Bilgileri
                    _buildSectionTitle('Stok ve Depo Bilgileri'),
                    _buildStockSection(),

                    const SizedBox(height: 24),

                    // Ek Bilgiler
                    _buildSectionTitle('Ek Bilgiler'),
                    _buildAdditionalInfoSection(),

                    const SizedBox(height: 24),

                    // Fotoğraflar
                    _buildSectionTitle('Ürün Fotoğrafları'),
                    _buildImageSection(),

                    const SizedBox(height: 100), // Save button için boşluk
                  ],
                ),
              ),
            ),

            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
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
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: TamgaciConstants.primaryColor.withValues(alpha: 0.25),
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
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_box,
              color: Theme.of(context).colorScheme.onPrimary,
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
                  widget.productId != null
                      ? 'Ürün Düzenle'
                      : 'Yeni Ürün Oluştur',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.productId != null
                      ? 'Ürün bilgilerini güncelleyin'
                      : 'Ürün bilgilerini doldurun ve depo seçin',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.productId != null ? 'Ürünü Güncelle' : 'Ürünü Kaydet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark
              ? TamgaciConstants.textPrimaryDark
              : TamgaciConstants.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ürün adı
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ürün Adı *',
                hintText: 'Örn: iPhone 15 Pro',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ürün adı zorunludur';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // Ürün türü
            DropdownButtonFormField<ProductType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Ürün Türü *',
                border: OutlineInputBorder(),
              ),
              items: ProductType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _selectedType = value!;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Açıklama
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
                hintText: 'Ürün açıklaması...',
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Kategori ve Marka
            Row(
              children: [
                Expanded(
                  child: _buildCategoryDropdown(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBrandDropdown(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Ürün kodu ve barkod
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _productCodeController,
                    decoration: InputDecoration(
                      labelText: 'Ürün Kodu',
                      border: const OutlineInputBorder(),
                      hintText: 'Otomatik üretilir',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(_autoGenerateProductCode
                                ? Icons.lock
                                : Icons.lock_open),
                            onPressed: () {
                              setState(() {
                                _autoGenerateProductCode =
                                    !_autoGenerateProductCode;
                                if (_autoGenerateProductCode) {
                                  _generateProductCode();
                                }
                              });
                            },
                            tooltip: _autoGenerateProductCode
                                ? 'Manuel girişe geç'
                                : 'Otomatik üretime geç',
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _generateProductCode,
                            tooltip: 'Yeni kod üret',
                          ),
                        ],
                      ),
                    ),
                    readOnly: _autoGenerateProductCode,
                  ),
                ),
                const SizedBox(width: 16),
                // Barkod (varyantlı ürünlerde gizli)
                if (!_hasVariants)
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Barkod',
                        border: const OutlineInputBorder(),
                        hintText: 'GS1 barkod',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(_autoGenerateBarcode
                                  ? Icons.lock
                                  : Icons.lock_open),
                              onPressed: () {
                                setState(() {
                                  _autoGenerateBarcode = !_autoGenerateBarcode;
                                  if (_autoGenerateBarcode) {
                                    _generateBarcode();
                                  }
                                });
                              },
                              tooltip: _autoGenerateBarcode
                                  ? 'Manuel girişe geç'
                                  : 'Otomatik üretime geç',
                            ),
                            IconButton(
                              icon: const Icon(Icons.qr_code),
                              onPressed: _generateBarcode,
                              tooltip: 'Yeni barkod üret',
                            ),
                          ],
                        ),
                      ),
                      readOnly: _autoGenerateBarcode,
                    ),
                  )
                else
                  Expanded(child: Container()), // Boş alan bırak
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Satış fiyatı
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _salesPriceController,
                    focusNode: _salesPriceFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Satış Fiyatı *',
                      border: OutlineInputBorder(),
                      hintText: '0,00',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                      _PriceInputFormatter(),
                    ],
                    onChanged: (value) {
                      // Sadece input formatter ile kontrol et, formatlamayı onFocusChange'de yap
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Satış fiyatı zorunludur';
                      }
                      // Binlik ayracı noktaları kaldır, virgülü nokta ile değiştir
                      final cleanValue =
                          value.replaceAll('.', '').replaceAll(',', '.');
                      if (double.tryParse(cleanValue) == null) {
                        return 'Geçerli bir fiyat girin';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _salesCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Para Birimi',
                      border: OutlineInputBorder(),
                    ),
                    items: ['TRY', 'USD', 'EUR'].map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _salesCurrency = value!;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Alış fiyatı
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _purchasePriceController,
                    focusNode: _purchasePriceFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Alış Fiyatı',
                      border: OutlineInputBorder(),
                      hintText: '0,00',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                      _PriceInputFormatter(),
                    ],
                    onChanged: (value) {
                      // Sadece input formatter ile kontrol et, formatlamayı onFocusChange'de yap
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _purchaseCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Para Birimi',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Seçiniz')),
                      ...['TRY', 'USD', 'EUR'].map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _purchaseCurrency = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // KDV oranları
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _salesTaxRateController,
                    decoration: const InputDecoration(
                      labelText: 'Satış KDV Oranı (%) *',
                      border: OutlineInputBorder(),
                      hintText: '20',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'KDV oranı zorunludur';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _purchaseTaxRateController,
                    decoration: const InputDecoration(
                      labelText: 'Alış KDV Oranı (%)',
                      border: OutlineInputBorder(),
                      hintText: '20',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // KDV dahil seçenekleri
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TaxInclusiveOption>(
                    initialValue: _salesTaxInclusive,
                    decoration: const InputDecoration(
                      labelText: 'Satış Fiyatına KDV',
                      border: OutlineInputBorder(),
                    ),
                    items: TaxInclusiveOption.values.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _salesTaxInclusive = value!;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<TaxInclusiveOption?>(
                    initialValue: _purchaseTaxInclusive,
                    decoration: const InputDecoration(
                      labelText: 'Alış Fiyatına KDV',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Seçiniz')),
                      ...TaxInclusiveOption.values.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option.displayName),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _purchaseTaxInclusive = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // İskonto ve ÖTV
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _purchaseDiscountController,
                    decoration: const InputDecoration(
                      labelText: 'Alış İskontosu (%)',
                      border: OutlineInputBorder(),
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sctController,
                    decoration: const InputDecoration(
                      labelText: 'ÖTV Oranı (%)',
                      border: OutlineInputBorder(),
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Warehouse seçimi
            Consumer(
              builder: (context, ref, child) {
                final warehousesAsync = ref.watch(warehousesProvider);
                return warehousesAsync.when(
                  data: (warehouses) {
                    // Varsayılan depo seçimi (isDefault: true olan depo)
                    if (_selectedWarehouse == null && warehouses.isNotEmpty) {
                      // Önce varsayılan depoyu bul
                      final defaultWarehouse = warehouses.firstWhere(
                        (warehouse) => warehouse.isDefault,
                        orElse: () =>
                            warehouses.first, // Varsayılan yoksa ilk depo
                      );
                      // setState'i build dışında çağır
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _selectedWarehouse = defaultWarehouse;
                          });
                        }
                      });
                    }

                    // Düzenleme modunda mevcut depo seçimini yap
                    if (widget.productId != null &&
                        _selectedWarehouse == null &&
                        _currentWarehouseId != null) {
                      // Düzenleme modunda mevcut depo seçimi yapılacak
                      // Mevcut depo seçimini yap
                      final currentWarehouse = warehouses.firstWhere(
                        (warehouse) => warehouse.id == _currentWarehouseId,
                        orElse: () => warehouses.first,
                      );
                      // setState'i build dışında çağır
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _selectedWarehouse = currentWarehouse;
                          });
                        }
                      });
                    }

                    return DropdownButtonFormField<Warehouse>(
                      initialValue: _selectedWarehouse,
                      decoration: const InputDecoration(
                        labelText: 'Depo Seçimi *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warehouse),
                      ),
                      items: warehouses.map((warehouse) {
                        return DropdownMenuItem(
                          value: warehouse,
                          child: Text(warehouse.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedWarehouse = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Depo seçimi zorunludur';
                        }
                        return null;
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Hata: $error'),
                );
              },
            ),

            const SizedBox(height: 16),

            // Stok takibi türü
            DropdownButtonFormField<StockTrackingType>(
              initialValue: _selectedStockTracking,
              decoration: const InputDecoration(
                labelText: 'Stok Takibi',
                border: OutlineInputBorder(),
              ),
              items: StockTrackingType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _selectedStockTracking = value!;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Başlangıç stok miktarı ve kritik stok
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockQuantityController,
                    decoration: InputDecoration(
                      labelText: _hasVariants
                          ? 'Toplam Stok (Otomatik)'
                          : 'Başlangıç Stok Miktarı',
                      border: const OutlineInputBorder(),
                      hintText: _hasVariants
                          ? 'Varyantlardan hesaplanıyor'
                          : 'Stok miktarını girin',
                      prefixIcon: const Icon(Icons.inventory),
                      filled: _hasVariants,
                      fillColor: _hasVariants ? Colors.grey[200] : null,
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: _hasVariants, // Varyantlı ürünlerde sadece okunur
                    validator: (value) {
                      if (!_hasVariants && value != null && value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          return 'Geçerli bir sayı giriniz';
                        }
                        if (int.parse(value) < 0) {
                          return 'Stok miktarı negatif olamaz';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _criticalStockController,
                    decoration: const InputDecoration(
                      labelText: 'Kritik Stok Miktarı',
                      border: OutlineInputBorder(),
                      hintText: '0',
                      prefixIcon: Icon(Icons.warning),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Raf yeri (sadece varyantlı ürünlerde gizli)
            if (!_hasVariants)
              TextFormField(
                controller: _shelfLocationController,
                decoration: const InputDecoration(
                  labelText: 'Raf Yeri',
                  border: OutlineInputBorder(),
                  hintText: 'A-1-2',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fotoğraf ekleme butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Fotoğraf Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[700],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blue[200]!),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Seçilen fotoğraflar
            if ((kIsWeb
                ? _selectedImageBytes.isNotEmpty
                : _selectedImages.isNotEmpty)) ...[
              Text(
                'Seçilen Fotoğraflar (${kIsWeb ? _selectedImageBytes.length : _selectedImages.length})',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: kIsWeb
                      ? _selectedImageBytes.length
                      : _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.memory(
                                    _selectedImageBytes[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.broken_image,
                                            color: Colors.grey[600]),
                                      );
                                    },
                                  )
                                : Image.file(
                                    _selectedImages[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.broken_image,
                                            color: Colors.grey[600]),
                                      );
                                    },
                                  ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Henüz fotoğraf eklenmedi',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // GTIP kodu ve ülke kodu
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gtipCodeController,
                    decoration: const InputDecoration(
                      labelText: 'GTIP Kodu',
                      border: OutlineInputBorder(),
                      hintText: '8517120000',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _countryCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Ülke Kodu',
                      border: OutlineInputBorder(),
                      hintText: 'TR',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notlar
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notlar',
                border: OutlineInputBorder(),
                hintText: 'Ek notlar...',
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Özel Özellikler Bölümü
            _buildCustomAttributesSection(),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Widget _buildCustomAttributesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Özel Özellikler',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showAddAttributeDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Özellik Ekle'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                ),
              ),
            ],
          ),
          if (_customAttributes.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Henüz özel özellik eklenmedi. "Özellik Ekle" butonuna tıklayarak özellikler ekleyebilirsiniz.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            ..._customAttributes.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.value,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red[400],
                      onPressed: () => _removeAttribute(entry.key),
                      tooltip: 'Sil',
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _showAddAttributeDialog() {
    final keyController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Yeni Özellik Ekle',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Özellik Adı',
                hintText: 'Örn: Renk, Boyut, Malzeme',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Özellik Değeri',
                hintText: 'Örn: Kırmızı, XL, Pamuk',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (keyController.text.trim().isNotEmpty &&
                  valueController.text.trim().isNotEmpty) {
                setState(() {
                  _customAttributes[keyController.text.trim()] =
                      valueController.text.trim();
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _removeAttribute(String key) {
    setState(() {
      _customAttributes.remove(key);
    });
  }

  Widget _buildVariantSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Varyant aktif/pasif switch
            SwitchListTile(
              title: Text(
                'Bu Ürün Varyantlara Sahip',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Renk, beden, boyut gibi farklı varyantlar ekleyebilirsiniz',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              value: _hasVariants,
              onChanged: (value) {
                setState(() {
                  _hasVariants = value;
                  if (!value) {
                    _variants.clear();
                    _variantTypes.clear();
                    _variantOptions.clear();
                  }
                });
              },
            ),

            if (_hasVariants) ...[
              const Divider(height: 32),

              // Varyant tipleri ekleme
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Varyant Tipleri',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddVariantTypeDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tip Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Eklenen varyant tipleri ve seçenekleri
              if (_variantOptions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.05),
                        Colors.purple.withValues(alpha: 0.05)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.2), width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[600], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Henüz varyant tipi eklenmedi. "Tip Ekle" butonuna tıklayarak varyant tiplerini ekleyin (örn: Renk, Beden)',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._variantOptions.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.withValues(alpha: 0.05),
                          Colors.purple.withValues(alpha: 0.05)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.indigo.withValues(alpha: 0.3),
                          width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // İkon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.category,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            // Seçenek sayısı badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.tag,
                                      color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${entry.value.length}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: Colors.red[400],
                              onPressed: () => _removeVariantType(entry.key),
                              tooltip: 'Tipi Sil',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...entry.value.map((option) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color:
                                          Colors.blue.withValues(alpha: 0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      option,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => _removeVariantOption(
                                          entry.key, option),
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.red[400],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            // Ekle butonu
                            InkWell(
                              onTap: () =>
                                  _showAddVariantOptionDialog(entry.key),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add,
                                        size: 16, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Ekle',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

              if (_variantOptions.isNotEmpty) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _generateVariantCombinations,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Varyant Kombinasyonlarını Oluştur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],

              // Oluşturulan varyantlar
              if (_variants.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Varyantlar (${_variants.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ..._variants.asMap().entries.map((entry) {
                  final index = entry.key;
                  final variant = entry.value;
                  return _buildVariantCard(index, variant);
                }),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _generateProductCode() {
    // Basit ürün kodu üretimi
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    _productCodeController.text = 'PRD-$timestamp';
    if (mounted) {
      setState(() {
        _autoGenerateProductCode = true;
      });
    }
  }

  void _generateBarcode() {
    final barcode = BarcodeGenerator.generateRandomGS1Barcode();
    _barcodeController.text = barcode;
    if (mounted) {
      setState(() {
        _autoGenerateBarcode = true;
      });
    }
  }

  Widget _buildCategoryDropdown() {
    // Varsayılan kategoriler
    final defaultCategories = [
      'Elektronik',
      'Giyim',
      'Ev & Yaşam',
      'Spor & Outdoor',
      'Kitap & Dergi',
      'Oyuncak',
      'Kozmetik',
      'Gıda & İçecek',
      'Otomotiv',
      'Diğer'
    ];

    // Tüm kategorileri birleştir (varsayılan + özel)
    final allCategories = [...defaultCategories, ..._customCategories];

    return DropdownButtonFormField<String>(
      initialValue:
          _categoryController.text.isNotEmpty ? _categoryController.text : null,
      decoration: const InputDecoration(
        labelText: 'Kategori *',
        border: OutlineInputBorder(),
        hintText: 'Kategori seçin veya yeni oluşturun',
        prefixIcon: Icon(Icons.category),
      ),
      isExpanded: true,
      items: [
        ...allCategories.map((category) => DropdownMenuItem(
              value: category,
              child: Text(
                category,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        const DropdownMenuItem(
          value: 'NEW_CATEGORY',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Yeni Kategori Oluştur',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value == 'NEW_CATEGORY') {
          _showCreateCategoryDialog();
        } else if (value != null) {
          _categoryController.text = value;
        }
      },
      validator: (value) {
        if (_categoryController.text.trim().isEmpty) {
          return 'Kategori seçimi zorunludur';
        }
        return null;
      },
    );
  }

  Widget _buildBrandDropdown() {
    // Varsayılan markalar
    final defaultBrands = [
      'Apple',
      'Samsung',
      'Nike',
      'Adidas',
      'Sony',
      'LG',
      'Xiaomi',
      'Huawei',
      'Diğer'
    ];

    // Tüm markaları birleştir (varsayılan + özel)
    final allBrands = [...defaultBrands, ..._customBrands];

    return DropdownButtonFormField<String>(
      initialValue:
          _brandController.text.isNotEmpty ? _brandController.text : null,
      decoration: const InputDecoration(
        labelText: 'Marka *',
        border: OutlineInputBorder(),
        hintText: 'Marka seçin veya yeni oluşturun',
        prefixIcon: Icon(Icons.branding_watermark),
      ),
      isExpanded: true,
      items: [
        ...allBrands.map((brand) => DropdownMenuItem(
              value: brand,
              child: Text(
                brand,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        const DropdownMenuItem(
          value: 'NEW_BRAND',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Yeni Marka Oluştur',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value == 'NEW_BRAND') {
          _showCreateBrandDialog();
        } else if (value != null) {
          _brandController.text = value;
        }
      },
      validator: (value) {
        if (_brandController.text.trim().isEmpty) {
          return 'Marka seçimi zorunludur';
        }
        return null;
      },
    );
  }

  void _showCreateCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kategori Oluştur'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Kategori Adı',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final newCategory = controller.text.trim();
                _categoryController.text = newCategory;

                // Yeni kategoriyi listeye ekle
                if (!_customCategories.contains(newCategory)) {
                  setState(() {
                    _customCategories.add(newCategory);
                  });
                }

                Navigator.pop(context);
              }
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  void _showCreateBrandDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Marka Oluştur'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Marka Adı',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final newBrand = controller.text.trim();
                _brandController.text = newBrand;

                // Yeni markayı listeye ekle
                if (!_customBrands.contains(newBrand)) {
                  setState(() {
                    _customBrands.add(newBrand);
                  });
                }

                Navigator.pop(context);
              }
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String value) {
    if (value.isEmpty) return '';

    // Binlik ayracı noktaları kaldır, virgülü nokta ile değiştir
    final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
    final doubleValue = double.tryParse(cleanValue);

    if (doubleValue == null) return value;

    // Türkçe format: 1.234,56
    return CurrencyHelper.formatNumber(doubleValue);
  }

  void _onSalesPriceFocusChange() {
    if (!_salesPriceFocusNode.hasFocus &&
        _salesPriceController.text.isNotEmpty) {
      final currentText = _salesPriceController.text;
      final formatted = _formatPrice(currentText);

      debugPrint('💰 Fiyat Formatlama (Satış):');
      debugPrint('   Input: "$currentText"');
      debugPrint('   Output: "$formatted"');

      if (formatted != currentText) {
        _salesPriceController.text = formatted;
      }
    }
  }

  void _onPurchasePriceFocusChange() {
    if (!_purchasePriceFocusNode.hasFocus &&
        _purchasePriceController.text.isNotEmpty) {
      final currentText = _purchasePriceController.text;
      final formatted = _formatPrice(currentText);

      debugPrint('💰 Fiyat Formatlama (Alış):');
      debugPrint('   Input: "$currentText"');
      debugPrint('   Output: "$formatted"');

      if (formatted != currentText) {
        _purchasePriceController.text = formatted;
      }
    }
  }

  double _parsePrice(String priceText) {
    if (priceText.isEmpty) return 0.0;

    // Binlik ayracı noktaları kaldır, virgülü nokta ile değiştir
    final cleanValue = priceText.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleanValue) ?? 0.0;
  }

  int _parseStockQuantity(String stockText) {
    if (stockText.trim().isEmpty) return 0;

    // Sadece rakamları al ve parse et
    final cleanValue = stockText.trim();
    final parsed = int.tryParse(cleanValue);

    debugPrint('📦 Stok Parse: "$stockText" -> $parsed');

    return parsed ?? 0;
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final productId =
          widget.productId ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Debug bilgileri
      debugPrint(
          '🏪 Seçilen Depo: ${_selectedWarehouse?.name} (ID: ${_selectedWarehouse?.id})');
      debugPrint('📦 Stok Miktarı: ${_stockQuantityController.text}');
      debugPrint(
          '🔍 Stok Parse Sonucu: ${int.tryParse(_stockQuantityController.text)}');

      // Fotoğrafları Firebase Storage'a yükle
      List<String> imageUrls = [];
      if (kIsWeb
          ? _selectedImageBytes.isNotEmpty
          : _selectedImages.isNotEmpty) {
        try {
          final storageService = FirebaseStorageService();
          if (kIsWeb) {
            imageUrls = await storageService.uploadProductImageBytesList(
                productId, _selectedImageBytes);
          } else {
            imageUrls = await storageService.uploadProductImages(
                productId, _selectedImages);
          }
        } catch (storageError) {
          debugPrint('Fotoğraf yükleme hatası: $storageError');
          // Fotoğraf yükleme hatası olsa bile ürünü kaydet
        }
      }

      final product = Product(
        id: productId,
        tenantId: '', // Repository'de set edilecek
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        productCode: _productCodeController.text.trim().isEmpty
            ? null
            : _productCodeController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        type: _selectedType,
        salesPrice: _parsePrice(_salesPriceController.text),
        purchasePrice: _purchasePriceController.text.trim().isEmpty
            ? null
            : _parsePrice(_purchasePriceController.text),
        salesCurrency: _salesCurrency,
        purchaseCurrency: _purchaseCurrency,
        salesTaxRate: double.parse(_salesTaxRateController.text),
        purchaseTaxRate: _purchaseTaxRateController.text.trim().isEmpty
            ? null
            : double.parse(_purchaseTaxRateController.text),
        salesTaxInclusive: _salesTaxInclusive,
        purchaseTaxInclusive: _purchaseTaxInclusive,
        purchaseDiscount: _purchaseDiscountController.text.trim().isEmpty
            ? null
            : double.parse(_purchaseDiscountController.text),
        sct: _sctController.text.trim().isEmpty
            ? null
            : double.parse(_sctController.text),
        shelfLocation: _shelfLocationController.text.trim().isEmpty
            ? null
            : _shelfLocationController.text.trim(),
        stockTracking: _selectedStockTracking,
        warehouseId: _selectedWarehouse?.id,
        warehouseName: _selectedWarehouse?.name,
        stockQuantity: _parseStockQuantity(_stockQuantityController.text),
        criticalStockQuantity: _criticalStockController.text.trim().isEmpty
            ? null
            : int.parse(_criticalStockController.text),
        gtipCode: _gtipCodeController.text.trim().isEmpty
            ? null
            : _gtipCodeController.text.trim(),
        countryCode: _countryCodeController.text.trim().isEmpty
            ? null
            : _countryCodeController.text.trim(),
        tags: _tags,
        images: imageUrls,
        linkedProducts: _linkedProducts.isEmpty ? null : _linkedProducts,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        attributeValues: _customAttributes.isEmpty ? null : _customAttributes,
        variants: _variants.isEmpty ? null : _variants,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'current_user_id', // Get from auth provider
      );

      // Debug: Oluşturulan product entity'sini kontrol et
      debugPrint('📦 Oluşturulan Product Entity:');
      debugPrint('   - Depo ID: ${product.warehouseId}');
      debugPrint('   - Depo Adı: ${product.warehouseName}');
      debugPrint('   - Stok Miktarı: ${product.stockQuantity}');

      // Save or update product using repository
      if (widget.productId != null) {
        await ref
            .read(productOperationsProvider.notifier)
            .updateProduct(product);

        // İstatistikleri güncelle
        ref.invalidate(productStatisticsProvider);

        if (mounted) {
          Future.microtask(() {
            if (!mounted) return;
            context.goNamed('products-list');
          });
        }
      } else {
        await ref
            .read(productOperationsProvider.notifier)
            .createProduct(product);

        debugPrint('✅ Product created successfully');

        // İstatistikleri güncelle
        ref.invalidate(productStatisticsProvider);

        if (mounted) {
          Future.microtask(() {
            if (!mounted) return;
            context.goNamed('products-list');
          });
        }
      }
    } catch (e) {
      debugPrint('Hata: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Varyant metodları
  void _showAddVariantTypeDialog() {
    final typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Varyant Tipi Ekle',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: typeController,
          decoration: const InputDecoration(
            labelText: 'Varyant Tipi',
            hintText: 'Örn: Renk, Beden, Boyut',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (typeController.text.trim().isNotEmpty) {
                setState(() {
                  final type = _toTitleCase(typeController.text.trim());
                  if (!_variantOptions.containsKey(type)) {
                    _variantOptions[type] = [];
                    _variantTypes.add(type);
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showAddVariantOptionDialog(String type) {
    final optionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '$type Seçeneği Ekle',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: optionController,
          decoration: InputDecoration(
            labelText: '$type Değeri',
            hintText: type == 'Renk'
                ? 'Örn: Kırmızı, Mavi'
                : type == 'Beden'
                    ? 'Örn: 36, 38, 40'
                    : 'Değer girin',
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (optionController.text.trim().isNotEmpty) {
                setState(() {
                  final option = _toTitleCase(optionController.text.trim());
                  if (!_variantOptions[type]!.contains(option)) {
                    _variantOptions[type]!.add(option);
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _removeVariantType(String type) {
    setState(() {
      _variantOptions.remove(type);
      _variantTypes.remove(type);
      _variants.clear(); // Kombinasyonları temizle
    });
  }

  void _removeVariantOption(String type, String option) {
    setState(() {
      _variantOptions[type]!.remove(option);
      _variants.clear(); // Kombinasyonları yeniden oluştur
    });
  }

  void _generateVariantCombinations() {
    if (_variantOptions.isEmpty) return;

    final combinations = <Map<String, String>>[];
    _generateCombinationsRecursive(
      _variantOptions.entries.toList(),
      0,
      {},
      combinations,
    );

    setState(() {
      _variants.clear();
      for (final combo in combinations) {
        final variantName = combo.values.join(' - ');
        _variants.add(
          ProductVariant(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                _variants.length.toString(),
            name: variantName,
            attributes: combo,
            stockQuantity: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    });
  }

  void _generateCombinationsRecursive(
    List<MapEntry<String, List<String>>> entries,
    int index,
    Map<String, String> current,
    List<Map<String, String>> result,
  ) {
    if (index == entries.length) {
      result.add(Map.from(current));
      return;
    }

    final entry = entries[index];
    for (final option in entry.value) {
      current[entry.key] = option;
      _generateCombinationsRecursive(entries, index + 1, current, result);
    }
    current.remove(entry.key);
  }

  Widget _buildVariantCard(int index, ProductVariant variant) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[850]! : Colors.white;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: variant.stockQuantity > 0
              ? Colors.green.withValues(alpha: isDark ? 0.4 : 0.3)
              : (isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.3)),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // İkon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: variant.stockQuantity > 0
                      ? Colors.green
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.dashboard_customize,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Varyant adı
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variant.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Özellikler chip'leri
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: variant.attributes.entries.map((attr) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${attr.key}: ${attr.value}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.purple[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Stok badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: variant.stockQuantity > 0 ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (variant.stockQuantity > 0
                              ? Colors.green
                              : Colors.red)
                          .withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      variant.stockQuantity > 0
                          ? Icons.check_circle
                          : Icons.warning,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${variant.stockQuantity}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barkod
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey(
                      'variant_barcode_${variant.id}_${variant.barcode ?? "empty"}'),
                  initialValue: variant.barcode ?? '',
                  decoration: InputDecoration(
                    labelText: 'Barkod',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    prefixIcon:
                        Icon(Icons.qr_code_2, color: Colors.purple[600]),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Manuel girin veya üretin',
                  ),
                  onChanged: (value) {
                    _variants[index] = variant.copyWith(
                        barcode: value.trim().isEmpty ? null : value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  final barcode = BarcodeGenerator.generateRandomGS1Barcode();
                  setState(() {
                    _variants[index] = variant.copyWith(barcode: barcode);
                  });
                },
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Üret'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: variant.stockQuantity.toString(),
                  decoration: InputDecoration(
                    labelText: 'Stok Miktarı',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    prefixIcon:
                        Icon(Icons.inventory_2, color: Colors.blue[600]),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final stock = int.tryParse(value) ?? 0;
                    setState(() {
                      _variants[index] = variant.copyWith(stockQuantity: stock);
                      _updateTotalStock();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: variant.shelfLocation ?? '',
                  decoration: InputDecoration(
                    labelText: 'Raf Yeri',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    prefixIcon:
                        Icon(Icons.location_on, color: Colors.orange[600]),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'A-1-2',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _variants[index] = variant.copyWith(
                          shelfLocation: value.trim().isEmpty ? null : value);
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

  void _updateTotalStock() {
    if (_hasVariants && _variants.isNotEmpty) {
      final total = _variants.fold<int>(
        0,
        (sum, variant) => sum + variant.stockQuantity,
      );
      _stockQuantityController.text = total.toString();
    }
  }
}

/// Fiyat input formatter'ı
class _PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Sadece rakam ve virgül izin ver
    final filtered = newValue.text.replaceAll(RegExp(r'[^0-9,]'), '');

    // Birden fazla virgül varsa sadece ilkini al
    final commaCount = filtered.split(',').length - 1;
    if (commaCount > 1) {
      final firstCommaIndex = filtered.indexOf(',');
      final result = filtered.substring(0, firstCommaIndex + 1) +
          filtered.substring(firstCommaIndex + 1).replaceAll(',', '');
      return TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    }

    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
