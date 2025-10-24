// ========== CREATE WAREHOUSE PAGE ==========
// lib/features/inventory/presentation/pages/create_warehouse_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';

import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../core/providers/currency_providers.dart';
import '../providers/warehouse_providers.dart';
import '../../domain/entities/warehouse.dart';

class CreateWarehousePage extends ConsumerStatefulWidget {
  final String? warehouseId;

  const CreateWarehousePage({
    super.key,
    this.warehouseId,
  });

  @override
  ConsumerState<CreateWarehousePage> createState() =>
      _CreateWarehousePageState();
}

class _CreateWarehousePageState extends ConsumerState<CreateWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _managerController = TextEditingController();
  final _capacityController = TextEditingController();

  String _selectedCurrencyCode = 'TRY';
  String _selectedCapacityUnit = 'm²';
  bool _isActive = true;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _loadWarehouseData();
  }

  void _loadWarehouseData() {
    if (widget.warehouseId != null) {
      // Load existing warehouse data
      // For now, just set some default values
      _nameController.text = 'Örnek Depo';
      _codeController.text = 'DEPO001';
      _descriptionController.text = 'Örnek depo açıklaması';
      _addressController.text = 'Örnek adres';
      _phoneController.text = '+90 555 123 45 67';
      _emailController.text = 'depo@example.com';
      _managerController.text = 'Örnek Yönetici';
      _capacityController.text = '1000';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _managerController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCurrency = ref.watch(selectedCurrencyProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.warehouseId != null ? 'Depo Düzenle' : 'Yeni Depo',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _saveWarehouse,
            icon: const Icon(Icons.save),
            tooltip: 'Kaydet',
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: _buildBody(isDark, selectedCurrency),
    );
  }

  Widget _buildBody(bool isDark, dynamic selectedCurrency) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoCard(isDark),
            const SizedBox(height: 16),
            _buildContactInfoCard(isDark),
            const SizedBox(height: 16),
            _buildCapacityInfoCard(isDark),
            const SizedBox(height: 16),
            _buildSettingsCard(isDark),
            const SizedBox(height: 32),
            _buildSaveButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warehouse,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Temel Bilgiler',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Depo Adı *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.warehouse),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Depo adı gereklidir';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Depo Kodu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.code),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.contact_phone,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'İletişim Bilgileri',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Adres',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Telefon',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _managerController,
              decoration: InputDecoration(
                labelText: 'Depo Yöneticisi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityInfoCard(bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.straighten,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Kapasite Bilgileri',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _capacityController,
                    decoration: InputDecoration(
                      labelText: 'Kapasite',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.straighten),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCapacityUnit,
                    decoration: InputDecoration(
                      labelText: 'Birim',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.straighten),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'm²', child: Text('m²')),
                      DropdownMenuItem(value: 'm³', child: Text('m³')),
                      DropdownMenuItem(value: 'ton', child: Text('Ton')),
                      DropdownMenuItem(value: 'adet', child: Text('Adet')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCapacityUnit = value!;
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

  Widget _buildSettingsCard(bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.settings,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ayarlar',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCurrencyCode,
              decoration: InputDecoration(
                labelText: 'Para Birimi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.currency_exchange),
              ),
              items: const [
                DropdownMenuItem(value: 'TRY', child: Text('₺ TRY')),
                DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
                DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
                DropdownMenuItem(value: 'GBP', child: Text('£ GBP')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCurrencyCode = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                'Aktif',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                ),
              ),
              subtitle: Text(
                'Depo aktif olarak kullanılabilir',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: TamgaciConstants.textSecondary,
                ),
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeThumbColor: TamgaciConstants.primaryColor,
            ),
            SwitchListTile(
              title: Text(
                'Varsayılan Depo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                ),
              ),
              subtitle: Text(
                'Bu depo varsayılan depo olarak ayarlanacak',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: TamgaciConstants.textSecondary,
                ),
              ),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value;
                });
              },
              activeThumbColor: TamgaciConstants.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveWarehouse,
        style: ElevatedButton.styleFrom(
          backgroundColor: TamgaciConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          widget.warehouseId != null ? 'Güncelle' : 'Kaydet',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _saveWarehouse() async {
    if (_formKey.currentState!.validate()) {
      try {
        final warehouse = Warehouse(
          id: widget.warehouseId ?? '',
          name: _nameController.text.trim(),
          code: _codeController.text.trim().isEmpty
              ? null
              : _codeController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          manager: _managerController.text.trim().isEmpty
              ? null
              : _managerController.text.trim(),
          capacity: _capacityController.text.trim().isEmpty
              ? null
              : double.tryParse(_capacityController.text),
          capacityUnit: _selectedCapacityUnit,
          currency: _selectedCurrencyCode,
          isActive: _isActive,
          isDefault: _isDefault,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final repository = ref.read(warehouseRepositoryProvider);

        if (widget.warehouseId != null) {
          // Update existing warehouse
          await repository.updateWarehouse(warehouse);
        } else {
          // Create new warehouse
          await repository.createWarehouse(warehouse);
        }

        // Invalidate providers to refresh data
        ref.invalidate(warehousesProvider);
        ref.invalidate(activeWarehousesProvider);
        ref.invalidate(warehouseCountProvider);
        ref.invalidate(activeWarehouseCountProvider);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.warehouseId != null
                    ? 'Depo başarıyla güncellendi'
                    : 'Depo başarıyla oluşturuldu',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Show error message
        if (mounted) {
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
}
