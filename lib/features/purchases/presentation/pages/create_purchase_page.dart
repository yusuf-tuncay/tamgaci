// ========== CREATE PURCHASE PAGE ==========
// lib/features/purchases/presentation/pages/create_purchase_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';

/// Yeni alış oluşturma sayfası
class CreatePurchasePage extends ConsumerStatefulWidget {
  final String? purchaseId; // Düzenleme için ID, null ise yeni oluşturma

  const CreatePurchasePage({super.key, this.purchaseId});

  @override
  ConsumerState<CreatePurchasePage> createState() => _CreatePurchasePageState();
}

class _CreatePurchasePageState extends ConsumerState<CreatePurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Basic form controllers
  final _purchaseNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentTermsController = TextEditingController();

  // Form state
  String? _selectedSupplier;
  DateTime _purchaseDate = DateTime.now();
  DateTime? _dueDate;
  String _currencyCode = 'TRY';
  // final double _discountAmount = 0.0; // Will be used in future

  @override
  void initState() {
    super.initState();
    if (widget.purchaseId != null) {
      _loadPurchaseData();
    } else {
      _generatePurchaseNumber();
    }
  }

  @override
  void dispose() {
    _purchaseNumberController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _paymentTermsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadPurchaseData() {
    // Mock data loading - gerçek uygulamada provider'dan gelecek
    _purchaseNumberController.text = 'ALI-2024-001';
    _descriptionController.text = 'Örnek alış açıklaması';
    _notesController.text = 'Örnek notlar';
    _paymentTermsController.text = '30 gün';
    _selectedSupplier = '1';
    _purchaseDate = DateTime.now().subtract(const Duration(days: 1));
    _dueDate = DateTime.now().add(const Duration(days: 30));
  }

  void _generatePurchaseNumber() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random =
        (now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    _purchaseNumberController.text = 'ALI-$year-$month$day-$random';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: widget.purchaseId != null ? 'Alış Düzenle' : 'Yeni Alış',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _savePurchase,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: TamgaciConstants.paddingMedium(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Temel Bilgiler
              _buildSectionCard(
                'Temel Bilgiler',
                Icons.info_outline,
                [
                  _buildTextField(
                    controller: _purchaseNumberController,
                    label: 'Alış Numarası',
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    value: _selectedSupplier,
                    label: 'Tedarikçi',
                    items: _getMockSuppliers(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSupplier = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Alış Tarihi',
                          value: _purchaseDate,
                          onChanged: (date) {
                            if (date != null) {
                              setState(() {
                                _purchaseDate = date;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          label: 'Vade Tarihi',
                          value: _dueDate,
                          onChanged: (date) {
                            setState(() {
                              _dueDate = date;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Açıklama ve Notlar
              _buildSectionCard(
                'Açıklama ve Notlar',
                Icons.note_outlined,
                [
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Açıklama',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _notesController,
                    label: 'Notlar',
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Ödeme Bilgileri
              _buildSectionCard(
                'Ödeme Bilgileri',
                Icons.payment,
                [
                  _buildDropdownField(
                    value: _currencyCode,
                    label: 'Para Birimi',
                    items: const [
                      {'value': 'TRY', 'label': 'Türk Lirası (TRY)'},
                      {'value': 'USD', 'label': 'Amerikan Doları (USD)'},
                      {'value': 'EUR', 'label': 'Euro (EUR)'},
                    ],
                    onChanged: (value) {
                      setState(() {
                        _currencyCode = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _paymentTermsController,
                    label: 'Ödeme Koşulları',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Alış Kalemleri
              _buildSectionCard(
                'Alış Kalemleri',
                Icons.list_alt,
                [
                  _buildPurchaseItemsList(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addPurchaseItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Kalem Ekle'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(TamgaciConstants.radiusMD),
                    ),
                  ),
                  child: Text(
                    widget.purchaseId != null
                        ? 'Alışı Güncelle'
                        : 'Alışı Kaydet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label gereklidir';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(item['label']!),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label seçilmelidir';
        }
        return null;
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null
              ? '${value.day}/${value.month}/${value.year}'
              : 'Tarih seçin',
          style: GoogleFonts.poppins(
            color:
                value != null ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseItemsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            'Alış kalemleri burada görünecek',
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kalem ekleme özelliği yakında eklenecek',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getMockSuppliers() {
    return [
      {'value': '1', 'label': 'ABC Tedarik A.Ş.'},
      {'value': '2', 'label': 'XYZ Malzeme Ltd.'},
      {'value': '3', 'label': 'DEF Hammadde A.Ş.'},
    ];
  }

  void _addPurchaseItem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kalem Ekle'),
        content: const Text('Kalem ekleme formu yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _savePurchase() {
    if (_formKey.currentState!.validate()) {
      // Form validation passed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Başarılı'),
          content: Text(
            widget.purchaseId != null
                ? 'Alış başarıyla güncellendi!'
                : 'Alış başarıyla oluşturuldu!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }
}
