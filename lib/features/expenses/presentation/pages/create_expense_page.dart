// ========== CREATE/EDIT EXPENSE PAGE ==========
// lib/features/expenses/presentation/pages/create_expense_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/expense_providers.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';

/// Gider oluşturma/düzenleme sayfası
class CreateExpensePage extends ConsumerStatefulWidget {
  final String? expenseId; // Düzenleme için ID, null ise yeni oluşturma

  const CreateExpensePage({super.key, this.expenseId});

  @override
  ConsumerState<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends ConsumerState<CreateExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _supplierNameController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'Nakit';
  String? _selectedCategoryId;
  ExpenseStatus _selectedStatus = ExpenseStatus.paid;

  final List<String> _paymentMethods = [
    'Nakit',
    'Banka Transferi',
    'Kredi Kartı',
    'Çek',
    'Senet',
    'Otomatik Ödeme',
    'Diğer',
  ];

  final List<ExpenseCategory> _mockCategories = [
    ExpenseCategory(
      id: '1',
      name: 'Ofis Giderleri',
      icon: 'business',
      color: '#2196F3',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ExpenseCategory(
      id: '2',
      name: 'Personel Giderleri',
      icon: 'people',
      color: '#4CAF50',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ExpenseCategory(
      id: '3',
      name: 'Yazılım',
      icon: 'computer',
      color: '#FF9800',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ExpenseCategory(
      id: '4',
      name: 'Elektrik/Su',
      icon: 'flash_on',
      color: '#9C27B0',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ExpenseCategory(
      id: '5',
      name: 'Kira',
      icon: 'home',
      color: '#607D8B',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ExpenseCategory(
      id: '6',
      name: 'Pazarlama',
      icon: 'trending_up',
      color: '#E91E63',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ExpenseCategory(
      id: '7',
      name: 'Diğer',
      icon: 'more_horiz',
      color: '#9E9E9E',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenseData();
  }

  void _loadExpenseData() async {
    if (widget.expenseId != null) {
      // Düzenleme modu - gider verilerini yükle
      try {
        final expense = await ref.read(
          expenseProvider(widget.expenseId!).future,
        );
        if (expense != null && mounted) {
          setState(() {
            _titleController.text = expense.title;
            _descriptionController.text = expense.description ?? '';
            _amountController.text = expense.amount.toString();
            _supplierNameController.text = expense.supplierName ?? '';
            _invoiceNumberController.text = expense.invoiceNumber ?? '';
            _notesController.text = '';
            _selectedDate = expense.expenseDate;
            _selectedPaymentMethod = expense.paymentMethod;
            _selectedCategoryId = expense.categoryId;
            _selectedStatus = expense.status;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gider verileri yüklenirken hata: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _supplierNameController.dispose();
    _invoiceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Tarih seçici
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Yeni kategori ekleme dialog'u
  void _showAddCategoryDialog() {
    final categoryNameController = TextEditingController();
    String selectedIcon = 'business';
    String selectedColor = '#2196F3';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kategori Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryNameController,
              decoration: const InputDecoration(
                labelText: 'Kategori Adı',
                hintText: 'Örn: Araç Giderleri',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedIcon,
              decoration: const InputDecoration(labelText: 'İkon'),
              items: const [
                DropdownMenuItem(value: 'business', child: Text('İş')),
                DropdownMenuItem(value: 'people', child: Text('İnsanlar')),
                DropdownMenuItem(value: 'home', child: Text('Ev')),
                DropdownMenuItem(value: 'flash_on', child: Text('Elektrik')),
                DropdownMenuItem(value: 'trending_up', child: Text('Grafik')),
                DropdownMenuItem(value: 'computer', child: Text('Bilgisayar')),
                DropdownMenuItem(value: 'more_horiz', child: Text('Diğer')),
              ],
              onChanged: (value) {
                selectedIcon = value!;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedColor,
              decoration: const InputDecoration(labelText: 'Renk'),
              items: const [
                DropdownMenuItem(value: '#2196F3', child: Text('Mavi')),
                DropdownMenuItem(value: '#4CAF50', child: Text('Yeşil')),
                DropdownMenuItem(value: '#FF9800', child: Text('Turuncu')),
                DropdownMenuItem(value: '#9C27B0', child: Text('Mor')),
                DropdownMenuItem(value: '#607D8B', child: Text('Gri-Mavi')),
                DropdownMenuItem(value: '#E91E63', child: Text('Pembe')),
                DropdownMenuItem(value: '#9E9E9E', child: Text('Gri')),
              ],
              onChanged: (value) {
                selectedColor = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryNameController.text.trim().isNotEmpty) {
                final newCategory = ExpenseCategory(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: categoryNameController.text.trim(),
                  icon: selectedIcon,
                  color: selectedColor,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                setState(() {
                  _mockCategories.add(newCategory);
                  _selectedCategoryId = newCategory.id;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kategori başarıyla eklendi')),
                );
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  /// Formu kaydet
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kategori seçin')),
      );
      return;
    }

    final selectedCategory = _mockCategories.firstWhere(
      (cat) => cat.id == _selectedCategoryId,
    );

    final expense = Expense(
      id: widget.expenseId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      currency: 'TRY', // Varsayılan para birimi
      categoryId: _selectedCategoryId!,
      categoryName: selectedCategory.name,
      expenseDate: _selectedDate,
      supplierName: _supplierNameController.text.trim().isEmpty
          ? null
          : _supplierNameController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
      invoiceNumber: _invoiceNumberController.text.trim().isEmpty
          ? null
          : _invoiceNumberController.text.trim(),
      status: _selectedStatus,

      attachments: const [],
      createdAt: widget.expenseId != null
          ? DateTime.now() // Düzenleme modunda mevcut tarihi koru
          : DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'system',
    );

    try {
      if (widget.expenseId != null) {
        await ref
            .read(expenseOperationsProvider.notifier)
            .updateExpense(expense);
        // Provider'ları yenile
        ref.invalidate(expensesProvider);
        ref.invalidate(expenseProvider(widget.expenseId!));
        ref.invalidate(expensesStreamProvider);
      } else {
        await ref
            .read(expenseOperationsProvider.notifier)
            .createExpense(expense);
        // Provider'ları yenile
        ref.invalidate(expensesProvider);
        ref.invalidate(expensesStreamProvider);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.expenseId != null
                  ? 'Gider başarıyla güncellendi'
                  : 'Gider başarıyla oluşturuldu',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(expenseFormProvider);
    final isEditing = widget.expenseId != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: isEditing ? 'Gider Düzenle' : 'Yeni Gider',
        showDrawer: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: TamgaciConstants.paddingMedium(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Gider Başlığı *',
                  hintText: 'Örn: Ofis Malzemeleri',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Gider başlığı gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Açıklama
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Gider açıklaması (opsiyonel)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Tutar
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Tutar (₺) *',
                  hintText: '0.00',
                  prefixText: '₺ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tutar gereklidir';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Geçerli bir tutar girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Kategori *'),
                items: [
                  ..._mockCategories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(
                            _getIconData(category.icon),
                            color: _parseColor(category.color),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }),
                  const DropdownMenuItem(
                    value: 'add_new',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('+ Yeni Kategori Ekle'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == 'add_new') {
                    _showAddCategoryDialog();
                  } else {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value == 'add_new') {
                    return 'Kategori seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gider Tarihi
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Gider Tarihi *',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy').format(_selectedDate),
                        style: GoogleFonts.poppins(),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tedarikçi Adı
              TextFormField(
                controller: _supplierNameController,
                decoration: const InputDecoration(
                  labelText: 'Tedarikçi Adı',
                  hintText: 'Tedarikçi adı (opsiyonel)',
                ),
              ),
              const SizedBox(height: 16),

              // Ödeme Yöntemi
              DropdownButtonFormField<String>(
                initialValue: _selectedPaymentMethod,
                decoration: const InputDecoration(labelText: 'Ödeme Yöntemi *'),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Fatura Numarası
              TextFormField(
                controller: _invoiceNumberController,
                decoration: const InputDecoration(
                  labelText: 'Fatura Numarası',
                  hintText: 'Fatura no (opsiyonel)',
                ),
              ),
              const SizedBox(height: 16),

              // Durum
              DropdownButtonFormField<ExpenseStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Durum *'),
                items: ExpenseStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Notlar
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  hintText: 'Ek notlar (opsiyonel)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: formState.isLoading ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TamgaciConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: formState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'Güncelle' : 'Kaydet',
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

  /// Icon data'ya dönüştürme
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'business':
        return Icons.business;
      case 'people':
        return Icons.people;
      case 'home':
        return Icons.home;
      case 'flash_on':
        return Icons.flash_on;
      case 'trending_up':
        return Icons.trending_up;
      case 'computer':
        return Icons.computer;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  /// Renk parsing
  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}
