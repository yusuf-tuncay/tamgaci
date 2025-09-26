// ========== CREATE PURCHASE PAGE ==========
// lib/features/purchases/presentation/pages/create_purchase_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../inventory/presentation/providers/warehouse_providers.dart';
import '../../../inventory/domain/entities/warehouse.dart';
import '../../../purchases/presentation/providers/purchase_providers.dart';
import '../../../purchases/domain/entities/purchase.dart';
import '../../../products/domain/entities/product.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import '../../../../core/services/utils/exchange_rate_service.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../notifications/presentation/providers/notification_providers.dart'
    as notif_providers;
import '../../../notifications/domain/entities/notification.dart'
    as app_notification;
// import '../../../../core/routes/routes.dart';
import 'package:tamgaci/features/invoices/domain/entities/invoice.dart' as inv;
import 'package:tamgaci/features/invoices/domain/entities/invoice_item.dart'
    as inv_item;
import 'package:tamgaci/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:tamgaci/features/invoices/data/models/invoice_status.dart'
    as inv_status;

/// Yeni alış oluşturma sayfası
class CreatePurchasePage extends ConsumerStatefulWidget {
  final String? purchaseId; // Düzenleme için ID, null ise yeni oluşturma
  final String? supplierId; // Müşteri detayından gelen tedarikçi ID
  final String? supplierName; // Müşteri detayından gelen tedarikçi adı

  const CreatePurchasePage({
    super.key,
    this.purchaseId,
    this.supplierId,
    this.supplierName,
  });

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
  final _shippingCostController = TextEditingController(text: '0');

  // Form state
  Supplier? _selectedSupplier;
  DateTime _purchaseDate = DateTime.now();
  DateTime? _dueDate;
  String _currencyCode = 'TRY';
  Warehouse? _selectedWarehouse;
  PurchaseType _purchaseType =
      PurchaseType.returnPurchase; // Default: İade alışı
  final List<_PurchaseItemForm> _items = <_PurchaseItemForm>[];
  bool _isSaving = false;
  bool _receiveToInventory = true;
  bool _isDraft = false;
  bool _isInstallmentPurchase = false;
  final List<_InstallmentForm> _installments = <_InstallmentForm>[];
  // final double _discountAmount = 0.0; // Will be used in future

  @override
  void initState() {
    super.initState();
    _initDefaults();
  }

  Future<Product?> _showQuickCreateProductDialog() async {
    final nameController = TextEditingController();
    Product? created;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Yeni Ürün'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Ad'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                created = await ref
                    .read(productOperationsProvider.notifier)
                    .createMinimalProduct(name);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Oluştur'),
            ),
          ],
        );
      },
    );
    return created;
  }

  Widget _buildInstallmentRow(int index) {
    final inst = _installments[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
          child: TextFormField(
            controller: inst.amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Taksit Tutarı',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: inst.dueDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) setState(() => inst.dueDate = date);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Vade Tarihi',
                border: OutlineInputBorder(),
              ),
              child: Text(inst.dueDate != null
                  ? '${inst.dueDate!.day}/${inst.dueDate!.month}/${inst.dueDate!.year}'
                  : 'Seçiniz'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => setState(() => _installments.removeAt(index)),
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _purchaseNumberController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _paymentTermsController.dispose();
    _shippingCostController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initDefaults() async {
    // Default company currency
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings != null) {
      setState(() {
        _currencyCode = settings.currency.name.toUpperCase();
      });
    }

    // Default warehouse
    final defWh = await ref.read(defaultWarehouseProvider.future);
    setState(() {
      _selectedWarehouse = defWh;
    });

    // Numbering
    await _generatePurchaseNumberFromRepo();

    // Müşteri detayından gelen tedarikçi bilgilerini ayarla
    if (widget.supplierId != null && widget.supplierName != null) {
      setState(() {
        _selectedSupplier = Supplier(
          id: widget.supplierId!,
          name: widget.supplierName!,
          email: '',
          phone: '',
          address: '',
          taxNumber: '',
          supplierType: SupplierType.company,
          status: SupplierStatus.active,
          companyId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
    }

    // If editing, load data later (not implemented here)
  }

  Future<void> _generatePurchaseNumberFromRepo() async {
    try {
      final repo = ref.read(purchaseRepositoryProvider);
      final number = await repo.generatePurchaseNumber(_purchaseType);
      setState(() {
        _purchaseNumberController.text = number;
      });
    } catch (_) {
      // Fallback: Generate a simple unique number
      final now = DateTime.now();
      final prefix =
          _purchaseType == PurchaseType.returnPurchase ? 'IAL' : 'NAL';
      final fallbackNumber =
          '$prefix-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
      setState(() {
        _purchaseNumberController.text = fallbackNumber;
      });
    }
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
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: _savePurchase,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      // No drawer on create page, use back button for navigation
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${_purchaseType == PurchaseType.returnPurchase ? 'İade Alış' : 'Normal Alış'} Numarası: ',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _purchaseNumberController.text,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPurchaseTypeSelector(),
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

              // Ödeme Bilgileri - Sadece normal alış için göster
              if (_purchaseType == PurchaseType.purchase) ...[
                _buildSectionCard(
                  'Ödeme Bilgileri',
                  Icons.payment,
                  [
                    _buildCurrencyAndFxRow(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _paymentTermsController,
                      label: 'Ödeme Koşulları',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _shippingCostController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kargo (Nakliye) Tutarı',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Consumer(builder: (context, ref, _) {
                            final asyncWarehouses =
                                ref.watch(warehousesProvider);
                            return asyncWarehouses.when(
                              data: (list) {
                                // unique values and safe initial
                                final items = <DropdownMenuItem<String>>[
                                  const DropdownMenuItem(
                                    value: 'no_stock',
                                    child: Text('Stoksuz Ürün'),
                                  ),
                                  for (final w in list)
                                    DropdownMenuItem(
                                        value: w.id, 
                                        child: Text(w.code != null && w.code!.isNotEmpty 
                                            ? '${w.name} (${w.code})' 
                                            : w.name)),
                                ];
                                String? value = _selectedWarehouse?.id;
                                final values =
                                    items.map((e) => e.value).toSet();
                                if (value != null && !values.contains(value)) {
                                  value = 'no_stock';
                                }
                                return DropdownButtonFormField<String>(
                                  initialValue: value,
                                  decoration:
                                      const InputDecoration(labelText: 'Depo'),
                                  isExpanded: true,
                                  items: items,
                                  onChanged: (id) async {
                                    if (id == 'no_stock') {
                                      setState(() {
                                        _selectedWarehouse = null;
                                        _receiveToInventory = false;
                                      });
                                    } else {
                                      final list = await ref
                                          .read(warehousesProvider.future);
                                      setState(() {
                                        _selectedWarehouse = list.firstWhere(
                                            (w) => w.id == id,
                                            orElse: () => list.first);
                                        _receiveToInventory = true;
                                      });
                                    }
                                  },
                                );
                              },
                              loading: () => const LinearProgressIndicator(),
                              error: (e, _) => DropdownButtonFormField<String>(
                                initialValue: 'no_stock',
                                decoration:
                                    const InputDecoration(labelText: 'Depo'),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'no_stock',
                                    child: Text('Stoksuz Ürün'),
                                  ),
                                ],
                                onChanged: (_) {},
                              ),
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CheckboxListTile(
                            value: _receiveToInventory,
                            onChanged: (v) =>
                                setState(() => _receiveToInventory = v ?? true),
                            dense: true,
                            title: const Text('Teslim al (stok girişi)'),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // İade alışı için sadece depo seçimi
              if (_purchaseType == PurchaseType.returnPurchase) ...[
                _buildSectionCard(
                  'Depo Bilgileri',
                  Icons.warehouse,
                  [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedWarehouse?.id,
                            decoration:
                                const InputDecoration(labelText: 'Depo'),
                            isExpanded: true,
                            items: ref.watch(warehousesProvider).maybeWhen(
                                  data: (list) => [
                                    const DropdownMenuItem(
                                      value: 'no_stock',
                                      child: Text('Stoksuz Ürün'),
                                    ),
                                    for (final w in list)
                                      DropdownMenuItem(
                                          value: w.id, 
                                          child: Text(w.code != null && w.code!.isNotEmpty 
                                              ? '${w.name} (${w.code})' 
                                              : w.name)),
                                  ],
                                  orElse: () => [
                                    const DropdownMenuItem(
                                      value: 'no_stock',
                                      child: Text('Stoksuz Ürün'),
                                    ),
                                  ],
                                ),
                            onChanged: (id) async {
                              if (id == 'no_stock') {
                                setState(() {
                                  _selectedWarehouse = null;
                                  _receiveToInventory =
                                      false; // Stoksuz ürün için stok girişi false
                                });
                              } else {
                                final list =
                                    await ref.read(warehousesProvider.future);
                                setState(() {
                                  _selectedWarehouse =
                                      list.firstWhere((w) => w.id == id);
                                  _receiveToInventory =
                                      true; // Normal depo için stok girişi true
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CheckboxListTile(
                            value: _receiveToInventory,
                            onChanged: (v) =>
                                setState(() => _receiveToInventory = v ?? true),
                            dense: true,
                            title: const Text('Stok girişi yap'),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Vade ve Taksitler - Sadece normal alış için göster
              if (_purchaseType == PurchaseType.purchase) ...[
                const SizedBox(height: 24),
                _buildSectionCard(
                  'Vade ve Taksitler',
                  Icons.schedule,
                  [
                    SwitchListTile(
                      value: _isInstallmentPurchase,
                      onChanged: (v) =>
                          setState(() => _isInstallmentPurchase = v),
                      title: const Text('Vadeli (taksitli) alış'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_isInstallmentPurchase) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => setState(
                              () => _installments.add(_InstallmentForm())),
                          icon: const Icon(Icons.add),
                          label: const Text('Taksit Ekle'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          for (int i = 0; i < _installments.length; i++)
                            _buildInstallmentRow(i),
                          if (_installments.isEmpty)
                            Text('Henüz taksit eklenmedi',
                                style: GoogleFonts.poppins(
                                    color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ],
                ),
              ],

              // Alış Kalemleri
              _buildSectionCard(
                'Alış Kalemleri',
                Icons.list_alt,
                [
                  _buildItemsEditor(),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: _addPurchaseItem,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Kalem Ekle',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Toplam ve Kaydet
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildItemsTotalsHeader(),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _savePurchase,
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
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () {
                          setState(() => _isDraft = true);
                          _savePurchase();
                        },
                  icon: const Icon(Icons.save_as),
                  label: const Text('Taslak Olarak Kaydet'),
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

  // removed unused _buildDropdownField helper

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

  Widget _buildItemsEditor() {
    return Column(
      children: [
        for (int i = 0; i < _items.length; i++) _buildItemCard(i),
        if (_items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Text(
              'Kalem ekleyin',
              style: GoogleFonts.poppins(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7)),
            ),
          ),
      ],
    );
  }

  Widget _buildItemsTotalsHeader() {
    double subtotal = 0, discount = 0, tax = 0;
    for (final it in _items) {
      final q = double.tryParse(it.quantityController.text) ?? 0;
      final up = double.tryParse(it.unitPriceController.text) ?? 0;
      final lineNet = q * up - it.discountAmount;
      subtotal += lineNet;
      discount += it.discountAmount;
      tax +=
          lineNet * ((double.tryParse(it.taxRateController.text) ?? 0) / 100);
    }
    final shipping = double.tryParse(_shippingCostController.text) ?? 0;
    final total = subtotal + tax + shipping;

    final baseCurrency =
        ref.read(settingsProvider).valueOrNull?.currency.name ?? 'TRY';
    // Note: To convert to base currency, integrate rates; for now assume same
    final subtotalBase = subtotal;
    final discountBase = discount;
    final taxBase = tax;
    final shippingBase = shipping;
    final totalBase = total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
                child: Text(
                    'Ara Toplam: ${CurrencyHelper.formatCurrency(subtotal, _currencyCode)}')),
            Expanded(
                child: Text(
                    'İndirim: ${CurrencyHelper.formatCurrency(discount, _currencyCode)}')),
            Expanded(
                child: Text(
                    'KDV: ${CurrencyHelper.formatCurrency(tax, _currencyCode)}')),
            Expanded(
                child: Text(
                    'Kargo: ${CurrencyHelper.formatCurrency(shipping, _currencyCode)}')),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
                child: Text(
                    'Ara Toplam ($baseCurrency): ${CurrencyHelper.formatCurrency(subtotalBase, baseCurrency)}')),
            Expanded(
                child: Text(
                    'İndirim ($baseCurrency): ${CurrencyHelper.formatCurrency(discountBase, baseCurrency)}')),
            Expanded(
                child: Text(
                    'KDV ($baseCurrency): ${CurrencyHelper.formatCurrency(taxBase, baseCurrency)}')),
            Expanded(
                child: Text(
                    'Kargo ($baseCurrency): ${CurrencyHelper.formatCurrency(shippingBase, baseCurrency)}')),
          ]),
          const Divider(height: 12),
          Row(children: [
            Expanded(
                child: Text(
                    'Genel Toplam: ${CurrencyHelper.formatCurrency(total, _currencyCode)}',
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(
                child: Text(
                    'Genel Toplam ($baseCurrency): ${CurrencyHelper.formatCurrency(totalBase, baseCurrency)}',
                    style: const TextStyle(fontWeight: FontWeight.w600))),
          ]),
        ],
      ),
    );
  }

  void _addPurchaseItem() {
    setState(() {
      _items.add(_PurchaseItemForm());
    });
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null) {
      final scheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tedarikçi seçilmelidir',
              style: TextStyle(color: scheme.onError)),
          backgroundColor: scheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_items.isEmpty) {
      final scheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('En az bir kalem ekleyin',
              style: TextStyle(color: scheme.onError)),
          backgroundColor: scheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Vadeli alış uyumu: vade tarihi seçilmişse pending olarak bırak; aksi nakit varsayımı
    if (_dueDate != null && _dueDate!.isBefore(_purchaseDate)) {
      final scheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Vade tarihi alış tarihinden önce olamaz',
                style: TextStyle(color: scheme.onError)),
            backgroundColor: scheme.error,
            behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Calculate totals
      final decimals = (ref
              .read(settingsProvider)
              .valueOrNull
              ?.customSettings['roundingDecimals'] as int?) ??
          2;
      double subtotal = 0, taxAmount = 0;
      for (final it in _items) {
        subtotal += it.quantity * it.unitPrice - it.discountAmount;
        taxAmount += (it.quantity * it.unitPrice - it.discountAmount) *
            (it.taxRate / 100);
      }
      final total = subtotal + taxAmount;

      final purchase = Purchase(
        id: '',
        purchaseNumber: _purchaseNumberController.text,
        type: _purchaseType,
        status: _isDraft ? PurchaseStatus.draft : PurchaseStatus.pending,
        paymentStatus: _purchaseType == PurchaseType.returnPurchase
            ? PurchasePaymentStatus
                .paid // İade alışı için ödeme tamamlanmış sayılır
            : PurchasePaymentStatus.pending,
        supplierId: _selectedSupplier!.id,
        supplierName: _selectedSupplier!.name,
        purchaseDate: _purchaseDate,
        dueDate: _dueDate,
        receivedDate: null,
        subtotal: double.parse(subtotal.toStringAsFixed(decimals)),
        taxRate: _items.isNotEmpty ? _items.first.taxRate : 0,
        taxAmount: double.parse(taxAmount.toStringAsFixed(decimals)),
        discountAmount: double.parse(_items
            .fold<double>(0, (s, e) => s + e.discountAmount)
            .toStringAsFixed(decimals)),
        totalAmount: double.parse(total.toStringAsFixed(decimals)),
        currency: _currencyCode,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        shippingAddress: null,
        billingAddress: null,
        shippingCost: double.tryParse(_shippingCostController.text),
        paymentMethod: null,
        paymentTerms: _paymentTermsController.text.trim().isEmpty
            ? null
            : _paymentTermsController.text.trim(),
        items: _items.map((e) => e.toEntity()).toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref
          .read(purchaseNotifierProvider.notifier)
          .createPurchase(purchase);

      // Faturalar modülüne senkronizasyon (direction: purchase)
      try {
        await _syncInvoiceWithPurchase(purchase);
      } catch (_) {}
      // Installment reminders
      if (_isInstallmentPurchase && _installments.isNotEmpty) {
        for (final inst in _installments) {
          await ref
              .read(notif_providers.notificationRepositoryProvider)
              .createNotification(
                app_notification.AppNotification(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: 'Taksit Hatırlatma',
                  message:
                      '${inst.amountController.text} tutarlı taksit vadesi: ${inst.dueDate != null ? '${inst.dueDate!.day}/${inst.dueDate!.month}/${inst.dueDate!.year}' : ''}',
                  type: app_notification.NotificationType.supplier,
                  priority: app_notification.NotificationPriority.medium,
                  createdAt: DateTime.now(),
                  isRead: false,
                  relatedEntityId: _purchaseNumberController.text,
                  relatedEntityType: 'purchase',
                  metadata: {
                    'supplierId': _selectedSupplier!.id,
                  },
                ),
              );
        }
      }
      // TODO: if _receiveToInventory and _selectedWarehouse != null, create stock movements (future step)
      if (mounted) {
        final scheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alış kaydedildi',
                style: TextStyle(color: scheme.onPrimary)),
            backgroundColor: scheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final scheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kaydedilemedi: $e',
                style: TextStyle(color: scheme.onError)),
            backgroundColor: scheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _syncInvoiceWithPurchase(Purchase purchase) async {
    // documentType eşlemesi: normal alış -> invoice, satıştan iade alışı -> returnPurchase (invoice altında not)
    final documentType = purchase.type == PurchaseType.returnPurchase
        ? 'invoice' // İade alışını da purchase faturası olarak kaydediyoruz
        : 'invoice';

    final repo = ref.read(invoiceRepositoryProvider);
    final existing = await repo.getInvoiceByNumber(purchase.purchaseNumber,
        includeItems: true);

    // InvoiceStatus eşlemesi
    inv_status.InvoiceStatus status;
    switch (purchase.status) {
      case PurchaseStatus.draft:
        status = inv_status.InvoiceStatus.draft;
        break;
      case PurchaseStatus.cancelled:
        status = inv_status.InvoiceStatus.cancelled;
        break;
      case PurchaseStatus.paid:
        status = inv_status.InvoiceStatus.paid;
        break;
      default:
        status = inv_status.InvoiceStatus.sent;
    }

    final now = DateTime.now();
    final invoice = inv.Invoice(
      id: existing?.id ?? '',
      invoiceNumber: purchase.purchaseNumber,
      customerId: purchase.supplierId, // supplierId müşteri alanına yazılıyor
      customer: null,
      invoiceDate: purchase.purchaseDate,
      dueDate: purchase.dueDate,
      status: status,
      subtotal: purchase.subtotal,
      taxAmount: purchase.taxAmount,
      discountAmount: purchase.discountAmount,
      totalAmount: purchase.totalAmount,
      currencyCode: purchase.currency,
      paymentTerms: purchase.paymentTerms,
      notes: purchase.notes,
      description: purchase.description,
      isPaid: purchase.paymentStatus == PurchasePaymentStatus.paid,
      paidDate:
          purchase.paymentStatus == PurchasePaymentStatus.paid ? now : null,
      items: const [],
      direction: 'purchase',
      documentType: documentType,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final items = <inv_item.InvoiceItem>[];
    for (int i = 0; i < purchase.items.length; i++) {
      final pi = purchase.items[i];
      items.add(inv_item.InvoiceItem.create(
        id: '',
        invoiceId: '',
        itemOrder: i + 1,
        productId: pi.productId,
        productName: pi.productName ?? pi.productId,
        description: pi.description,
        quantity: pi.quantity,
        unit: null,
        unitPrice: pi.unitPrice,
        taxRate: pi.taxRate,
        currencyCode: purchase.currency,
      ));
    }

    if (existing == null) {
      await repo.createInvoice(invoice, items);
    } else {
      await repo.updateInvoice(invoice);
      await repo.deleteAllInvoiceItems(existing.id);
      await repo.addInvoiceItems(
          items.map((it) => it.copyWith(invoiceId: existing.id)).toList());
    }
  }

  Widget _buildPurchaseTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alış Türü',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _purchaseType = PurchaseType.returnPurchase;
                  });
                  _generatePurchaseNumberFromRepo(); // Yeni numara üret
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      // ignore: deprecated_member_use
                      Radio<PurchaseType>(
                        value: PurchaseType.returnPurchase,
                        // ignore: deprecated_member_use
                        groupValue: _purchaseType,
                        // ignore: deprecated_member_use
                        onChanged: (value) {
                          setState(() {
                            _purchaseType = value!;
                          });
                          _generatePurchaseNumberFromRepo(); // Yeni numara üret
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Satıştan İade Alışı',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            Text(
                              'Müşteriden iade alınan ürünler',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _purchaseType = PurchaseType.purchase;
                  });
                  _generatePurchaseNumberFromRepo(); // Yeni numara üret
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      // ignore: deprecated_member_use
                      Radio<PurchaseType>(
                        value: PurchaseType.purchase,
                        // ignore: deprecated_member_use
                        groupValue: _purchaseType,
                        // ignore: deprecated_member_use
                        onChanged: (value) {
                          setState(() {
                            _purchaseType = value!;
                          });
                          _generatePurchaseNumberFromRepo(); // Yeni numara üret
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Normal Alış',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            Text(
                              'Tedarikçiden ürün alımı',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildCurrencyAndFxRow() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _currencyCode,
            decoration: InputDecoration(
              labelText: 'Para Birimi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'TRY', child: Text('TRY')),
              DropdownMenuItem(value: 'USD', child: Text('USD')),
              DropdownMenuItem(value: 'EUR', child: Text('EUR')),
              DropdownMenuItem(value: 'GBP', child: Text('GBP')),
            ],
            onChanged: (v) => setState(() => _currencyCode = v ?? 'TRY'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FutureBuilder<List<ExchangeRate>>(
            future: ExchangeRateService().getExchangeRates(),
            builder: (context, snap) {
              if (!snap.hasData) return const LinearProgressIndicator();
              final baseCurrency =
                  ref.read(settingsProvider).valueOrNull?.currency.name ??
                      'TRY';
              final selectedCode = _currencyCode;
              final selectedRate = snap.data!
                  .firstWhere((r) => r.code == selectedCode,
                      orElse: () => snap.data!.first)
                  .rate;
              return TextFormField(
                enabled: selectedCode != baseCurrency,
                initialValue: selectedRate.toStringAsFixed(4),
                decoration: InputDecoration(
                  labelText: 'Kur (1 $selectedCode = X $baseCurrency)',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(TamgaciConstants.radiusMD),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) {},
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(int index) {
    final item = _items[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildProductPicker(index)),
                IconButton(
                  onPressed: () => setState(() => _items.removeAt(index)),
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: item.quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Miktar'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: item.unitPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Birim Fiyat'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 112,
                child: TextFormField(
                  controller: item.taxRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'KDV %'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: item.currency,
                  decoration: const InputDecoration(labelText: 'Kalem PB'),
                  items: const [
                    DropdownMenuItem(value: 'TRY', child: Text('TRY')),
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                  ],
                  onChanged: (v) => setState(() => item.currency = v ?? 'TRY'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FutureBuilder<List<ExchangeRate>>(
                  future: ExchangeRateService().getExchangeRates(),
                  builder: (context, snap) {
                    if (!snap.hasData) return const LinearProgressIndicator();
                    final base = _currencyCode;
                    final code = item.currency;
                    final rate = snap.data!
                        .firstWhere((r) => r.code == code,
                            orElse: () => snap.data!.first)
                        .rate;
                    return TextFormField(
                      enabled: code != base,
                      initialValue: rate.toStringAsFixed(4),
                      decoration: InputDecoration(
                        labelText: 'Kur (1 $code = X $base)',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(TamgaciConstants.radiusMD),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                CurrencyHelper.formatCurrency(item.lineTotal, _currencyCode),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPicker(int index) {
    final query = _items[index].productQuery;
    final productsAsync = ref.watch(productSearchProvider(query));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration:
              const InputDecoration(labelText: 'Ürün ara (ad/kod/barkod)'),
          onChanged: (v) => setState(() => _items[index].productQuery = v),
        ),
        const SizedBox(height: 6),
        productsAsync.when(
          data: (products) {
            return Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _items[index].productId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Ürün'),
                    items: [
                      for (final p in products)
                        DropdownMenuItem(value: p.id, child: Text(p.name)),
                    ],
                    onChanged: (pid) {
                      final p = products.firstWhere((e) => e.id == pid);
                      setState(() {
                        _items[index].applyProduct(p);
                      });
                    },
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ürün seçin' : null,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final created = await _showQuickCreateProductDialog();
                      if (created != null) {
                        setState(() {
                          _items[index].applyProduct(created);
                          _items[index].productQuery = '';
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ekle'),
                  ),
                ),
              ],
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Ürün yüklenemedi: $e',
              style: GoogleFonts.poppins(color: Colors.red)),
        ),
      ],
    );
  }

  // Item form model helper ends
}

class _PurchaseItemForm {
  String? productId;
  String productName = '';
  double quantity = 1;
  double unitPrice = 0;
  double taxRate = 0;
  double discountRate = 0;
  double discountAmount = 0;
  String currency = 'TRY';

  final TextEditingController quantityController =
      TextEditingController(text: '1');
  final TextEditingController unitPriceController =
      TextEditingController(text: '0');
  final TextEditingController taxRateController =
      TextEditingController(text: '0');
  String productQuery = '';

  double get lineTotal {
    final q = double.tryParse(quantityController.text) ?? 0;
    final up = double.tryParse(unitPriceController.text) ?? 0;
    final dr = discountAmount;
    final tr = double.tryParse(taxRateController.text) ?? 0;
    final net = (q * up) - dr;
    final tax = net * (tr / 100);
    return net + tax;
  }

  void applyProduct(Product p) {
    productId = p.id;
    productName = p.name;
    unitPrice = p.purchasePrice ?? 0;
    unitPriceController.text = (p.purchasePrice ?? 0).toStringAsFixed(2);
    taxRate = p.salesTaxRate;
    taxRateController.text = p.salesTaxRate.toStringAsFixed(2);
    currency = p.purchaseCurrency ?? p.salesCurrency;
  }

  PurchaseItem toEntity() {
    final q = double.tryParse(quantityController.text) ?? 0;
    final up = double.tryParse(unitPriceController.text) ?? 0;
    final tr = double.tryParse(taxRateController.text) ?? 0;
    final net = (q * up) - discountAmount;
    final tax = net * (tr / 100);
    return PurchaseItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      purchaseId: '',
      productId: productId ?? '',
      productName: productName,
      quantity: q,
      unitPrice: up,
      discountRate: discountRate,
      discountAmount: discountAmount,
      taxRate: tr,
      taxAmount: tax,
      totalAmount: net + tax,
      description: null,
      notes: null,
    );
  }
}

class _InstallmentForm {
  final TextEditingController amountController =
      TextEditingController(text: '0');
  DateTime? dueDate;
}
