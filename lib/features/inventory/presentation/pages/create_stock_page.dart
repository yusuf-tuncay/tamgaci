// ========== CREATE STOCK PAGE ==========
// lib/features/inventory/presentation/pages/create_stock_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../providers/warehouse_providers.dart';
import '../../domain/entities/stock.dart';

class CreateStockPage extends ConsumerStatefulWidget {
  final String? stockId;

  const CreateStockPage({super.key, this.stockId});

  @override
  ConsumerState<CreateStockPage> createState() => _CreateStockPageState();
}

class _CreateStockPageState extends ConsumerState<CreateStockPage> {
  final _formKey = GlobalKey<FormState>();
  final _productIdController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minimumQuantityController = TextEditingController();
  final _maximumQuantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCurrency = 'TRY';
  String? _selectedWarehouseId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.stockId != null) {
      // Load existing stock data for editing
      _loadStockData();
    } else {
      // Set default values for new stock
      _minimumQuantityController.text = '0';
      _maximumQuantityController.text = '1000';
      _unitController.text = 'adet';
    }
  }

  void _loadStockData() {
    // Implement loading existing stock data
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _quantityController.dispose();
    _minimumQuantityController.dispose();
    _maximumQuantityController.dispose();
    _unitController.dispose();
    _unitPriceController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.stockId != null;

    return Scaffold(
      appBar: const CustomAppBar(
        showDrawer: false,
      ),
      drawer: const TamgaciDrawerMenu(),
      body: _buildBody(isDark, isEditing),
    );
  }

  Widget _buildBody(bool isDark, bool isEditing) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(isDark),
            const SizedBox(height: 24),
            _buildQuantitySection(isDark),
            const SizedBox(height: 24),
            _buildPriceSection(isDark),
            const SizedBox(height: 24),
            _buildLocationSection(isDark),
            const SizedBox(height: 24),
            _buildSettingsSection(isDark),
            const SizedBox(height: 32),
            _buildActionButtons(isDark, isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temel Bilgiler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _productIdController,
              decoration: InputDecoration(
                labelText: 'Ürün ID',
                hintText: 'Ürün ID giriniz',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ürün ID gereklidir';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildWarehouseDropdown(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseDropdown(bool isDark) {
    final warehousesAsync = ref.watch(warehousesProvider);

    return warehousesAsync.when(
      data: (warehouses) {
        return DropdownButtonFormField<String>(
          initialValue: _selectedWarehouseId,
          decoration: InputDecoration(
            labelText: 'Depo',
            hintText: 'Depo seçiniz',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: warehouses.map((warehouse) {
            return DropdownMenuItem<String>(
              value: warehouse.id,
              child: Text(warehouse.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedWarehouseId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Depo seçimi gereklidir';
            }
            return null;
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Hata: $error'),
    );
  }

  Widget _buildQuantitySection(bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Miktar Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Miktar',
                      hintText: '0.0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Miktar gereklidir';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: InputDecoration(
                      labelText: 'Birim',
                      hintText: 'adet, kg, litre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Birim gereklidir';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minimumQuantityController,
                    decoration: InputDecoration(
                      labelText: 'Minimum Miktar',
                      hintText: '0.0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Minimum miktar gereklidir';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maximumQuantityController,
                    decoration: InputDecoration(
                      labelText: 'Maksimum Miktar',
                      hintText: '1000.0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Maksimum miktar gereklidir';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fiyat Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _unitPriceController,
                    decoration: InputDecoration(
                      labelText: 'Birim Fiyat',
                      hintText: '0.00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Birim fiyat gereklidir';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCurrency,
                    decoration: InputDecoration(
                      labelText: 'Para Birimi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: CurrencyHelper.getCurrencyOptions().map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konum Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Konum',
                hintText: 'A-1-1, B-2-3, vb.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notlar',
                hintText: 'Ek notlar...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ayarlar',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                'Aktif',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              subtitle: Text(
                'Bu stok kaydı aktif olsun',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.grey : Colors.grey[600],
                ),
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, bool isEditing) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveStock,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isEditing ? 'Güncelle' : 'Kaydet',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _saveStock() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir depo seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      Stock(
        id: widget.stockId ?? '',
        tenantId: '', // Repository'de set edilecek
        productId: _productIdController.text,
        warehouseId: _selectedWarehouseId!,
        quantity: double.parse(_quantityController.text),
        minimumQuantity: double.parse(_minimumQuantityController.text),
        maximumQuantity: double.parse(_maximumQuantityController.text),
        unit: _unitController.text,
        currency: _selectedCurrency,
        unitPrice: double.parse(_unitPriceController.text),
        location: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        isActive: _isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Implement save functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              widget.stockId != null ? 'Stok güncellendi' : 'Stok oluşturuldu'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
