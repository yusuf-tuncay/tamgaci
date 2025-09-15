// ========== CREATE/EDIT INCOME PAGE ==========
// lib/features/income/presentation/pages/create_income_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/income_providers.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/income_category.dart';

/// Gelir oluşturma/düzenleme sayfası
class CreateIncomePage extends ConsumerStatefulWidget {
  final String? incomeId; // Düzenleme için ID, null ise yeni oluşturma

  const CreateIncomePage({super.key, this.incomeId});

  @override
  ConsumerState<CreateIncomePage> createState() => _CreateIncomePageState();
}

class _CreateIncomePageState extends ConsumerState<CreateIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'Nakit';
  String? _selectedCategoryId;
  IncomeStatus _selectedStatus = IncomeStatus.received;

  final List<String> _paymentMethods = [
    'Nakit',
    'Banka Transferi',
    'Kredi Kartı',
    'Çek',
    'Senet',
    'Diğer',
  ];

  final List<IncomeCategory> _mockCategories = [
    IncomeCategory(
      id: '1',
      name: 'Hizmet Gelirleri',
      icon: 'business',
      color: '#2196F3',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeCategory(
      id: '2',
      name: 'Ürün Satışları',
      icon: 'shopping_cart',
      color: '#4CAF50',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeCategory(
      id: '3',
      name: 'Danışmanlık',
      icon: 'support_agent',
      color: '#FF9800',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeCategory(
      id: '4',
      name: 'Kira Gelirleri',
      icon: 'home',
      color: '#9C27B0',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeCategory(
      id: '5',
      name: 'Diğer Gelirler',
      icon: 'more_horiz',
      color: '#9E9E9E',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadIncomeData();
  }

  void _loadIncomeData() async {
    if (widget.incomeId != null) {
      // Düzenleme modu - gelir verilerini yükle
      try {
        final income = await ref.read(incomeProvider(widget.incomeId!).future);
        if (income != null && mounted) {
          setState(() {
            _titleController.text = income.title;
            _descriptionController.text = income.description ?? '';
            _amountController.text = income.amount.toString();
            _customerNameController.text = income.customerName ?? '';
            _invoiceNumberController.text = income.invoiceNumber ?? '';
            _notesController.text = income.notes ?? '';
            _selectedDate = income.incomeDate;
            _selectedPaymentMethod = income.paymentMethod;
            _selectedCategoryId = income.categoryId;
            _selectedStatus = income.status;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gelir verileri yüklenirken hata: $e')),
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
    _customerNameController.dispose();
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
                hintText: 'Örn: Danışmanlık Hizmetleri',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedIcon,
              decoration: const InputDecoration(labelText: 'İkon'),
              items: const [
                DropdownMenuItem(value: 'business', child: Text('İş')),
                DropdownMenuItem(
                  value: 'shopping_cart',
                  child: Text('Alışveriş'),
                ),
                DropdownMenuItem(value: 'support_agent', child: Text('Destek')),
                DropdownMenuItem(value: 'home', child: Text('Ev')),
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
                final newCategory = IncomeCategory(
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

    final income = Income(
      id: widget.incomeId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategoryId!,
      categoryName: selectedCategory.name,
      incomeDate: _selectedDate,
      customerName: _customerNameController.text.trim().isEmpty
          ? null
          : _customerNameController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
      invoiceNumber: _invoiceNumberController.text.trim().isEmpty
          ? null
          : _invoiceNumberController.text.trim(),
      status: _selectedStatus,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      attachments: const [],
      createdAt: widget.incomeId != null
          ? DateTime.now() // Düzenleme modunda mevcut tarihi koru
          : DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'current_user', // TODO: Get from auth service
    );

    try {
      if (widget.incomeId != null) {
        await ref.read(incomeFormProvider.notifier).updateIncome(income);
        // Provider'ları yenile
        ref.invalidate(incomesProvider);
        ref.invalidate(incomeProvider(widget.incomeId!));
        ref.invalidate(incomesStreamProvider);
        // Operations provider'ını da yenile
        ref.read(incomeOperationsProvider.notifier).loadIncomes();
      } else {
        await ref.read(incomeFormProvider.notifier).createIncome(income);
        // Provider'ları yenile
        ref.invalidate(incomesProvider);
        ref.invalidate(incomesStreamProvider);
        // Operations provider'ını da yenile
        ref.read(incomeOperationsProvider.notifier).loadIncomes();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.incomeId != null
                  ? 'Gelir başarıyla güncellendi'
                  : 'Gelir başarıyla oluşturuldu',
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
    final formState = ref.watch(incomeFormProvider);
    final isEditing = widget.incomeId != null;

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: isEditing ? 'Gelir Düzenle' : 'Yeni Gelir',
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
                  labelText: 'Gelir Başlığı *',
                  hintText: 'Örn: Müşteri Ödemesi',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Gelir başlığı gereklidir';
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
                  hintText: 'Gelir açıklaması (opsiyonel)',
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

              // Gelir Tarihi
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Gelir Tarihi *',
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

              // Müşteri Adı
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Müşteri Adı',
                  hintText: 'Müşteri adı (opsiyonel)',
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
              DropdownButtonFormField<IncomeStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Durum *'),
                items: IncomeStatus.values.map((status) {
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
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'support_agent':
        return Icons.support_agent;
      case 'home':
        return Icons.home;
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
