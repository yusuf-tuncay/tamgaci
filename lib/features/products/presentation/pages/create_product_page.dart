// ========== CREATE PRODUCT PAGE ==========
// lib/features/products/presentation/pages/create_product_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/theme/constants.dart';
import '../../domain/entities/product.dart';
import '../../domain/utils/barcode_generator.dart';
import '../providers/product_providers.dart';
import '../../../../core/routes/routes.dart';
import '../../../warehouses/domain/entities/warehouse.dart';
import '../../../warehouses/presentation/providers/warehouse_providers.dart';
import '../../data/services/firebase_storage_service.dart';

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

  ProductType _selectedType = ProductType.stocked;
  StockTrackingType _selectedStockTracking = StockTrackingType.normal;
  TaxInclusiveOption _salesTaxInclusive = TaxInclusiveOption.exclusive;
  TaxInclusiveOption? _purchaseTaxInclusive;
  String _salesCurrency = 'TRY';
  String? _purchaseCurrency;
  Warehouse? _selectedWarehouse;
  String? _currentWarehouseId; // Düzenleme modunda mevcut depo ID'si
  final List<String> _tags = [];
  List<String> _images = [];
  final List<String> _linkedProducts = [];
  final List<File> _selectedImages = [];
  final List<Uint8List> _selectedImageBytes = [];

  bool _isLoading = false;
  bool _autoGenerateBarcode = false;
  bool _autoGenerateProductCode = false;

  @override
  void initState() {
    super.initState();
    _autoGenerateProductCode = true;
    _autoGenerateBarcode = true;
    _stockQuantityController.text = ''; // Varsayılan stok miktarı

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
    _salesPriceController.text = product.salesPrice.toString();
    _purchasePriceController.text = product.purchasePrice?.toString() ?? '';
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
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
            child: const Icon(
              Icons.add_box,
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
                  widget.productId != null
                      ? 'Ürün Düzenle'
                      : 'Yeni Ürün Oluştur',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.productId != null
                      ? 'Ürün bilgilerini güncelleyin'
                      : 'Ürün bilgilerini doldurun ve depo seçin',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
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
                  child: TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                      hintText: 'Örn: Elektronik',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'Marka',
                      border: OutlineInputBorder(),
                      hintText: 'Örn: Apple',
                    ),
                  ),
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
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _generateProductCode,
                        tooltip: 'Otomatik üret',
                      ),
                    ),
                    readOnly: _autoGenerateProductCode,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: 'Barkod',
                      border: const OutlineInputBorder(),
                      hintText: 'GS1 barkod',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code),
                        onPressed: _generateBarcode,
                        tooltip: 'GS1 barkod üret',
                      ),
                    ),
                    readOnly: _autoGenerateBarcode,
                  ),
                ),
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
                    decoration: const InputDecoration(
                      labelText: 'Satış Fiyatı *',
                      border: OutlineInputBorder(),
                      hintText: '0.00',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Satış fiyatı zorunludur';
                      }
                      if (double.tryParse(value) == null) {
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
                    decoration: const InputDecoration(
                      labelText: 'Alış Fiyatı',
                      border: OutlineInputBorder(),
                      hintText: '0.00',
                    ),
                    keyboardType: TextInputType.number,
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
                      _selectedWarehouse = defaultWarehouse;
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
                      _selectedWarehouse = currentWarehouse;
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
                    decoration: const InputDecoration(
                      labelText: 'Başlangıç Stok Miktarı',
                      border: OutlineInputBorder(),
                      hintText: 'Stok miktarını girin',
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
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

            // Raf yeri
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
          ],
        ),
      ),
    );
  }

  // Helper methods
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
        salesPrice: double.parse(_salesPriceController.text),
        purchasePrice: _purchasePriceController.text.trim().isEmpty
            ? null
            : double.parse(_purchasePriceController.text),
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
        stockQuantity: _stockQuantityController.text.trim().isEmpty
            ? 0
            : int.parse(_stockQuantityController.text),
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
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'current_user_id', // TODO: Get from auth provider
      );

      // Save or update product using repository
      if (widget.productId != null) {
        await ref
            .read(productOperationsProvider.notifier)
            .updateProduct(product);

        // Liste sayfası canlı dinliyor; manuel refresh gereksiz

        if (mounted) {
          Future.microtask(() {
            if (!mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil(
              TamgaciRoutes.productsList,
              (route) => false,
            );
          });
        }
      } else {
        await ref
            .read(productOperationsProvider.notifier)
            .createProduct(product);

        debugPrint('✅ Product created successfully');

        if (mounted) {
          Future.microtask(() {
            if (!mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil(
              TamgaciRoutes.productsList,
              (route) => false,
            );
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
}
