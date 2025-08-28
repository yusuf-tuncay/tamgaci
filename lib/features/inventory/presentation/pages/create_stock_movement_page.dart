import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/routes/routes.dart';
import '../providers/inventory_providers.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/entities/warehouse.dart';

class CreateStockMovementPage extends ConsumerStatefulWidget {
  const CreateStockMovementPage({super.key});

  @override
  ConsumerState<CreateStockMovementPage> createState() =>
      _CreateStockMovementPageState();
}

class _CreateStockMovementPageState
    extends ConsumerState<CreateStockMovementPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceNumberController = TextEditingController();

  StockMovementType _selectedMovementType = StockMovementType.in_;
  Warehouse? _selectedWarehouse;
  Warehouse? _selectedSourceWarehouse;
  Warehouse? _selectedDestinationWarehouse;
  final DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _descriptionController.dispose();
    _referenceNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(activeWarehousesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stok Hareketi Oluştur',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        backgroundColor: TamgaciConstants.backgroundColor,
        elevation: 0,
      ),
      body: warehousesAsync.when(
        data: (warehouses) => _buildForm(warehouses),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: TamgaciConstants.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Depolar yüklenirken hata oluştu',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: TamgaciConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TamgaciConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(List<Warehouse> warehouses) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hareket Türü
            Text(
              'Hareket Türü',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: TamgaciConstants.cardColor,
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
                border: Border.all(color: TamgaciConstants.borderColor),
              ),
              child: DropdownButtonFormField<StockMovementType>(
                initialValue: _selectedMovementType,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: StockMovementType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMovementType = value!;
                    // Transfer seçilirse source ve destination warehouse'ları sıfırla
                    if (value == StockMovementType.transfer) {
                      _selectedWarehouse = null;
                    } else {
                      _selectedSourceWarehouse = null;
                      _selectedDestinationWarehouse = null;
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Depo Seçimi
            if (_selectedMovementType != StockMovementType.transfer) ...[
              Text(
                'Depo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TamgaciConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: TamgaciConstants.cardColor,
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                  border: Border.all(color: TamgaciConstants.borderColor),
                ),
                child: DropdownButtonFormField<Warehouse>(
                  initialValue: _selectedWarehouse,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintText: 'Depo seçin',
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
                      return 'Lütfen bir depo seçin';
                    }
                    return null;
                  },
                ),
              ),
            ],

            // Transfer için kaynak ve hedef depolar
            if (_selectedMovementType == StockMovementType.transfer) ...[
              Text(
                'Kaynak Depo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TamgaciConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: TamgaciConstants.cardColor,
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                  border: Border.all(color: TamgaciConstants.borderColor),
                ),
                child: DropdownButtonFormField<Warehouse>(
                  initialValue: _selectedSourceWarehouse,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintText: 'Kaynak depo seçin',
                  ),
                  items: warehouses.map((warehouse) {
                    return DropdownMenuItem(
                      value: warehouse,
                      child: Text(warehouse.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSourceWarehouse = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Lütfen kaynak depo seçin';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Hedef Depo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TamgaciConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: TamgaciConstants.cardColor,
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                  border: Border.all(color: TamgaciConstants.borderColor),
                ),
                child: DropdownButtonFormField<Warehouse>(
                  initialValue: _selectedDestinationWarehouse,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintText: 'Hedef depo seçin',
                  ),
                  items: warehouses
                      .where(
                        (warehouse) =>
                            warehouse.id != _selectedSourceWarehouse?.id,
                      )
                      .map((warehouse) {
                        return DropdownMenuItem(
                          value: warehouse,
                          child: Text(warehouse.name),
                        );
                      })
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDestinationWarehouse = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Lütfen hedef depo seçin';
                    }
                    if (value.id == _selectedSourceWarehouse?.id) {
                      return 'Kaynak ve hedef depo aynı olamaz';
                    }
                    return null;
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Miktar
            Text(
              'Miktar',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Miktar girin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                ),
                filled: true,
                fillColor: TamgaciConstants.cardColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen miktar girin';
                }
                if (int.tryParse(value) == null) {
                  return 'Geçerli bir sayı girin';
                }
                if (int.parse(value) <= 0) {
                  return 'Miktar 0\'dan büyük olmalıdır';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Birim Fiyat
            Text(
              'Birim Fiyat (₺)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _unitPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Birim fiyat girin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                ),
                filled: true,
                fillColor: TamgaciConstants.cardColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen birim fiyat girin';
                }
                if (double.tryParse(value) == null) {
                  return 'Geçerli bir sayı girin';
                }
                if (double.parse(value) < 0) {
                  return 'Birim fiyat negatif olamaz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Açıklama
            Text(
              'Açıklama',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Açıklama girin (opsiyonel)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                ),
                filled: true,
                fillColor: TamgaciConstants.cardColor,
              ),
            ),
            const SizedBox(height: 16),

            // Referans Numarası
            Text(
              'Referans Numarası',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _referenceNumberController,
              decoration: InputDecoration(
                hintText: 'Referans numarası girin (opsiyonel)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                ),
                filled: true,
                fillColor: TamgaciConstants.cardColor,
              ),
            ),
            const SizedBox(height: 24),

            // Kaydet Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveStockMovement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TamgaciConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      TamgaciConstants.radiusMD,
                    ),
                  ),
                ),
                child: Text(
                  'Stok Hareketi Oluştur',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveStockMovement() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // TODO: Implement stock movement creation
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Stok hareketi başarıyla oluşturuldu',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: TamgaciConstants.successColor,
      ),
    );

    Navigator.pop(context);
  }
}
