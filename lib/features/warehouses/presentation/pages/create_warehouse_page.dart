import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/warehouse.dart';
import '../providers/warehouse_providers.dart';

/// Depo Oluşturma/Düzenleme Sayfası
class CreateWarehousePage extends ConsumerStatefulWidget {
  final Warehouse? existingWarehouse;

  const CreateWarehousePage({
    super.key,
    this.existingWarehouse,
  });

  @override
  ConsumerState<CreateWarehousePage> createState() =>
      _CreateWarehousePageState();
}

class _CreateWarehousePageState extends ConsumerState<CreateWarehousePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _managerPhoneController = TextEditingController();
  final _managerEmailController = TextEditingController();
  final _capacityController = TextEditingController();
  final _capacityUnitController = TextEditingController();
  final _notesController = TextEditingController();

  // Form values
  WarehouseType _selectedType = WarehouseType.main;
  WarehouseStatus _selectedStatus = WarehouseStatus.active;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // Mevcut depo bilgilerini doldur
    if (widget.existingWarehouse != null) {
      _fillFormWithExistingData();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _managerNameController.dispose();
    _managerPhoneController.dispose();
    _managerEmailController.dispose();
    _capacityController.dispose();
    _capacityUnitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _fillFormWithExistingData() {
    final warehouse = widget.existingWarehouse!;
    _nameController.text = warehouse.name;
    _descriptionController.text = warehouse.description ?? '';
    _addressController.text = warehouse.address;
    _cityController.text = warehouse.city ?? '';
    _stateController.text = warehouse.state ?? '';
    _countryController.text = warehouse.country ?? '';
    _postalCodeController.text = warehouse.postalCode ?? '';
    _phoneController.text = warehouse.phone ?? '';
    _emailController.text = warehouse.email ?? '';
    _managerNameController.text = warehouse.managerName ?? '';
    _managerPhoneController.text = warehouse.managerPhone ?? '';
    _managerEmailController.text = warehouse.managerEmail ?? '';
    _capacityController.text = warehouse.capacity?.toString() ?? '';
    _capacityUnitController.text = warehouse.capacityUnit ?? '';
    _notesController.text = warehouse.notes ?? '';
    _selectedType = warehouse.type;
    _selectedStatus = warehouse.status;
    _isActive = warehouse.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.existingWarehouse != null ? 'Depo Düzenle' : 'Yeni Depo',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black87, size: 24),
          onPressed: _showMoreOptions,
          tooltip: 'Daha fazla seçenek',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoCard(),
            const SizedBox(height: 16),
            _buildLocationInfoCard(),
            const SizedBox(height: 16),
            _buildContactInfoCard(),
            const SizedBox(height: 16),
            _buildCapacityInfoCard(),
            const SizedBox(height: 16),
            _buildAdditionalInfoCard(),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temel Bilgiler',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Depo Adı *',
              hintText: 'Depo adını girin',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Depo adı zorunludur';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Açıklama',
              hintText: 'Depo açıklaması',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              DropdownButtonFormField<WarehouseType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Depo Türü *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: WarehouseType.values.map((type) {
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
              DropdownButtonFormField<WarehouseStatus>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Durum *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: WarehouseStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(
              'Aktif',
              style: GoogleFonts.poppins(),
            ),
            subtitle: Text(
              'Depo aktif durumda',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
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
    );
  }

  Widget _buildLocationInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konum Bilgileri',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Adres *',
              hintText: 'Depo adresi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Adres zorunludur';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Şehir',
                    hintText: 'Şehir',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: InputDecoration(
                    labelText: 'İl',
                    hintText: 'İl',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: 'Ülke',
                    hintText: 'Ülke',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(
                    labelText: 'Posta Kodu',
                    hintText: 'Posta kodu',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İletişim Bilgileri',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefon',
                    hintText: 'Telefon numarası',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    hintText: 'E-posta adresi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Sorumlu Kişi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _managerNameController,
            decoration: InputDecoration(
              labelText: 'Sorumlu Adı',
              hintText: 'Sorumlu kişi adı',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _managerPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Sorumlu Telefon',
                    hintText: 'Sorumlu telefon',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _managerEmailController,
                  decoration: InputDecoration(
                    labelText: 'Sorumlu E-posta',
                    hintText: 'Sorumlu e-posta',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kapasite Bilgileri',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _capacityController,
                  decoration: InputDecoration(
                    labelText: 'Kapasite',
                    hintText: 'Depo kapasitesi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _capacityUnitController,
                  decoration: InputDecoration(
                    labelText: 'Kapasite Birimi',
                    hintText: 'm², adet, kg vb.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ek Bilgiler',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Notlar',
              hintText: 'Ek notlar ve açıklamalar',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveWarehouse,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.existingWarehouse != null ? 'Güncelle' : 'Kaydet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: Text(
                'Taslak Olarak Kaydet',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pop(context);
                // Taslak kaydetme işlemi
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: Text(
                'Formu Temizle',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pop(context);
                _clearForm();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(
                'Yardım',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pop(context);
                // Yardım sayfasına git
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _addressController.clear();
    _cityController.clear();
    _stateController.clear();
    _countryController.clear();
    _postalCodeController.clear();
    _phoneController.clear();
    _emailController.clear();
    _managerNameController.clear();
    _managerPhoneController.clear();
    _managerEmailController.clear();
    _capacityController.clear();
    _capacityUnitController.clear();
    _notesController.clear();
    setState(() {
      _selectedType = WarehouseType.main;
      _selectedStatus = WarehouseStatus.active;
      _isActive = true;
    });
  }

  Future<void> _saveWarehouse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final warehouse = Warehouse(
        id: widget.existingWarehouse?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        address: _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty
            ? null
            : _stateController.text.trim(),
        country: _countryController.text.trim().isEmpty
            ? null
            : _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty
            ? null
            : _postalCodeController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        managerName: _managerNameController.text.trim().isEmpty
            ? null
            : _managerNameController.text.trim(),
        managerPhone: _managerPhoneController.text.trim().isEmpty
            ? null
            : _managerPhoneController.text.trim(),
        managerEmail: _managerEmailController.text.trim().isEmpty
            ? null
            : _managerEmailController.text.trim(),
        capacity: _capacityController.text.trim().isEmpty
            ? null
            : int.tryParse(_capacityController.text.trim()),
        capacityUnit: _capacityUnitController.text.trim().isEmpty
            ? null
            : _capacityUnitController.text.trim(),
        isActive: _isActive,
        isDefault: widget.existingWarehouse?.isDefault ?? false,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdBy: widget.existingWarehouse?.createdBy ?? 'current_user',
        createdAt: widget.existingWarehouse?.createdAt ?? DateTime.now(),
        updatedBy: 'current_user',
        updatedAt: DateTime.now(),
        tenantId: widget.existingWarehouse?.tenantId ?? 'current_tenant',
      );

      if (widget.existingWarehouse != null) {
        await ref
            .read(warehouseNotifierProvider.notifier)
            .updateWarehouse(warehouse);
      } else {
        await ref
            .read(warehouseNotifierProvider.notifier)
            .createWarehouse(warehouse);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingWarehouse != null
                  ? 'Depo başarıyla güncellendi'
                  : 'Depo başarıyla oluşturuldu',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green[600],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hata: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
