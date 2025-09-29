// ========== CREATE PRODUCT PAGE ==========
// lib/features/products/presentation/pages/create_product_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/widgets/formatted_text_field.dart';
import '../../domain/entities/product.dart';
import '../../domain/utils/barcode_generator.dart';
import '../providers/product_providers.dart';
import '../../../warehouses/domain/entities/warehouse.dart';
import '../../../warehouses/presentation/providers/warehouse_providers.dart';

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
  final List<String> _tags = [];
  final List<String> _images = [];
  final List<String> _linkedProducts = [];

  bool _isLoading = false;
  bool _autoGenerateBarcode = false;
  bool _autoGenerateProductCode = false;

  @override
  void initState() {
    super.initState();
    _autoGenerateProductCode = true;
    _autoGenerateBarcode = true;
    _stockQuantityController.text = '0'; // Varsayılan stok miktarı
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
              ],
            ),
          ),
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
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yeni Ürün Oluştur',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ürün bilgilerini doldurun ve depo seçin',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
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
                  'Ürünü Kaydet',
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
            FormattedNameField(
              label: 'Ürün Adı *',
              controller: _nameController,
              hint: 'Örn: iPhone 15 Pro',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ürün adı zorunludur';
                }
                return null;
              },
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
                setState(() {
                  _selectedType = value!;
                });
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
                      setState(() {
                        _salesCurrency = value!;
                      });
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
                      setState(() {
                        _purchaseCurrency = value;
                      });
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
                      setState(() {
                        _salesTaxInclusive = value!;
                      });
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
                      setState(() {
                        _purchaseTaxInclusive = value;
                      });
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
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          // Önce varsayılan depoyu bul
                          final defaultWarehouse = warehouses.firstWhere(
                            (warehouse) => warehouse.isDefault,
                            orElse: () => warehouses.first, // Varsayılan yoksa ilk depo
                          );
                          _selectedWarehouse = defaultWarehouse;
                        });
                      });
                    }

                    return DropdownButtonFormField<Warehouse>(
                      value: _selectedWarehouse,
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
                        setState(() {
                          _selectedWarehouse = value;
                        });
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
                setState(() {
                  _selectedStockTracking = value!;
                });
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
                      hintText: '0',
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok miktarı zorunludur';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Geçerli bir sayı giriniz';
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
    setState(() {
      _autoGenerateProductCode = true;
    });
  }

  void _generateBarcode() {
    final barcode = BarcodeGenerator.generateRandomGS1Barcode();
    _barcodeController.text = barcode;
    setState(() {
      _autoGenerateBarcode = true;
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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
        stockQuantity: int.parse(_stockQuantityController.text),
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
        images: _images,
        linkedProducts: _linkedProducts.isEmpty ? null : _linkedProducts,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'current_user_id', // TODO: Get from auth provider
      );

      // Save product using repository
      await ref.read(productOperationsProvider.notifier).createProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ürün başarıyla oluşturuldu'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
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
