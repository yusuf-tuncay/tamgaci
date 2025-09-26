// ========== CREATE CASH TRANSACTION PAGE ==========
// lib/features/cash_management/presentation/pages/create_cash_transaction_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../domain/entities/account.dart';

/// Yeni nakit işlemi oluşturma sayfası
class CreateCashTransactionPage extends ConsumerStatefulWidget {
  final String? transactionId; // Düzenleme için ID, null ise yeni oluşturma

  const CreateCashTransactionPage({super.key, this.transactionId});

  @override
  ConsumerState<CreateCashTransactionPage> createState() =>
      _CreateCashTransactionPageState();
}

class _CreateCashTransactionPageState
    extends ConsumerState<CreateCashTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  CashTransactionType _selectedType = CashTransactionType.income;
  CashTransactionStatus _selectedStatus = CashTransactionStatus.pending;
  String _selectedAccount = '1';
  String? _selectedToAccount;
  // String _currencyCode = 'TRY'; // Will be used in future
  DateTime _transactionDate = DateTime.now();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _loadTransactionData();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _categoryController.dispose();
    _subCategoryController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadTransactionData() {
    // Mock data loading - gerçek uygulamada provider'dan gelecek
    _amountController.text = '5000.0';
    _descriptionController.text = 'Satış geliri';
    _categoryController.text = 'Satış';
    _selectedType = CashTransactionType.income;
    _selectedStatus = CashTransactionStatus.completed;
    _selectedAccount = '1';
    _transactionDate = DateTime.now().subtract(const Duration(days: 1));
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
        title: widget.transactionId != null ? 'İşlem Düzenle' : 'Yeni İşlem',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: _saveTransaction,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      // No drawer here; use back for modal-like create page
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
                    controller: _amountController,
                    label: 'Tutar',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tutar gereklidir';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Geçerli bir tutar giriniz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Açıklama',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Açıklama gereklidir';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          value: _selectedType,
                          label: 'İşlem Türü',
                          items: CashTransactionType.values,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                              if (value == CashTransactionType.transfer) {
                                _selectedToAccount = '2'; // Default to account
                              } else {
                                _selectedToAccount = null;
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          value: _selectedStatus,
                          label: 'Durum',
                          items: CashTransactionStatus.values,
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          value: _selectedAccount,
                          label: 'Kaynak Hesap',
                          items: _getMockAccounts(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAccount = value as String;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_selectedType == CashTransactionType.transfer)
                        Expanded(
                          child: _buildDropdownField(
                            value: _selectedToAccount,
                            label: 'Hedef Hesap',
                            items: _getMockAccounts(),
                            onChanged: (value) {
                              setState(() {
                                _selectedToAccount = value as String?;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'İşlem Tarihi',
                          value: _transactionDate,
                          onChanged: (date) {
                            if (date != null) {
                              setState(() {
                                _transactionDate = date;
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

              // Kategori ve Referans
              _buildSectionCard(
                'Kategori ve Referans',
                Icons.category,
                [
                  _buildTextField(
                    controller: _categoryController,
                    label: 'Kategori',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _subCategoryController,
                    label: 'Alt Kategori',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _referenceController,
                    label: 'Referans Numarası',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Notlar
              _buildSectionCard(
                'Notlar',
                Icons.note_outlined,
                [
                  _buildTextField(
                    controller: _notesController,
                    label: 'Notlar',
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
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
                    widget.transactionId != null
                        ? 'İşlemi Güncelle'
                        : 'İşlemi Kaydet',
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required String label,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        ),
      ),
      items: items.map((item) {
        String displayName;
        if (item is CashTransactionType) {
          displayName = item.displayName;
        } else if (item is CashTransactionStatus) {
          displayName = item.displayName;
        } else if (item is Map<String, String>) {
          displayName = (item as Map<String, String>)['label']!;
        } else {
          displayName = item.toString();
        }

        return DropdownMenuItem<T>(
          value: item,
          child: Text(displayName),
        );
      }).toList(),
      onChanged: onChanged,
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

  List<Map<String, String>> _getMockAccounts() {
    return [
      {'value': '1', 'label': 'Ana Nakit Kasa'},
      {'value': '2', 'label': 'İş Bankası TRY Hesabı'},
      {'value': '3', 'label': 'Kredi Kartı'},
      {'value': '4', 'label': 'USD Döviz Hesabı'},
    ];
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      // Form validation passed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Başarılı'),
          content: Text(
            widget.transactionId != null
                ? 'İşlem başarıyla güncellendi!'
                : 'İşlem başarıyla oluşturuldu!',
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
