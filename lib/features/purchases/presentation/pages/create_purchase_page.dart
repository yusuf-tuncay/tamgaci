// ========== CREATE PURCHASE PAGE ==========
// lib/features/purchases/presentation/pages/create_purchase_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../inventory/presentation/providers/warehouse_providers.dart';
import '../../../inventory/domain/entities/warehouse.dart';
import '../../../../core/services/business/inventory_service.dart';
import '../../../purchases/presentation/providers/purchase_providers.dart';
import '../../../purchases/domain/entities/purchase.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import '../../../../core/services/utils/exchange_rate_service.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../../core/utils/currency_helper.dart';
// Silinen modül: notifications
// import '../../../../core/routes/routes.dart';
import 'package:tamgaci/features/invoices/domain/entities/invoice.dart' as inv;
import 'package:tamgaci/features/invoices/domain/entities/invoice_item.dart'
    as inv_item;
import 'package:tamgaci/features/invoices/presentation/providers/invoice_providers.dart'
    as invoice_providers;
import 'package:tamgaci/features/invoices/data/models/invoice_status.dart'
    as inv_status;
import 'package:tamgaci/features/invoices/presentation/pages/invoice_preview_page.dart';
import 'package:tamgaci/core/services/unified_invoice_converter.dart';
import '../../../../core/utils/logger.dart';
import 'package:tamgaci/core/services/business/transaction_service.dart'
    as transaction_service;
import 'package:tamgaci/features/accounts/presentation/providers/account_providers.dart';
import 'package:tamgaci/features/accounts/domain/entities/account.dart'
    as account_entity;
import 'package:tamgaci/features/accounts/domain/entities/account_transaction.dart'
    as account_txn;
import 'package:tamgaci/features/accounts/presentation/providers/account_transaction_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Yeni alış oluşturma sayfası
class CreatePurchasePage extends ConsumerStatefulWidget {
  final String? purchaseId; // Düzenleme için ID, null ise yeni oluşturma
  final String? supplierId; // Müşteri detayından gelen tedarikçi ID
  final String? supplierName; // Müşteri detayından gelen tedarikçi adı
  final String? customerId; // Müşteri detayından gelen müşteri ID
  final String? customerName; // Müşteri detayından gelen müşteri adı

  const CreatePurchasePage({
    super.key,
    this.purchaseId,
    this.supplierId,
    this.supplierName,
    this.customerId,
    this.customerName,
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

  // Customer management (satış modülünden)
  final _customerIdController = TextEditingController();
  final _customerNameController = TextEditingController();

  // Form state
  DateTime _purchaseDate = DateTime.now();
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

  // Customer management state (satış modülünden)
  final double _customerDefaultDiscountRate = 0.0;

  // Multi-currency summary state (satış modülünden)
  final String _paymentCurrencyCode = '';
  final String _baseCurrencyCode = 'TRY';
  final int _moneyDecimals = 2;
  final String _roundMode = 'halfUp';

  @override
  void initState() {
    super.initState();

    // Müşteri detayından gelen müşteri bilgilerini hemen ayarla
    if (widget.customerId != null && widget.customerName != null) {
      _customerIdController.text = widget.customerId!;
      _customerNameController.text = widget.customerName!;
      debugPrint('Müşteri otomatik seçildi: ${widget.customerName}');
    } else if (widget.supplierId != null && widget.supplierName != null) {
      // Eğer customer parametreleri yoksa supplier parametrelerini kullan
      _customerIdController.text = widget.supplierId!;
      _customerNameController.text = widget.supplierName!;
      debugPrint('Müşteri otomatik seçildi (supplier): ${widget.supplierName}');
    }

    _initDefaults();
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
        // TL -> TRY dönüşümü
        String currencyName = settings.currency.name.toUpperCase();
        if (currencyName == 'TL') {
          currencyName = 'TRY';
        }
        _currencyCode = currencyName;
      });
    }

    // Default warehouse
    final defWh = await ref.read(defaultWarehouseProvider.future);
    setState(() {
      _selectedWarehouse = defWh;
    });

    // Numbering
    await _generatePurchaseNumberFromRepo();

    // Müşteri detayından gelen müşteri bilgilerini ayarla
    if (widget.supplierId != null && widget.supplierName != null) {
      setState(() {
        _customerIdController.text = widget.supplierId!;
        _customerNameController.text = widget.supplierName!;
      });
    }

    // If editing, load data later (not implemented here)
  }

  Future<void> _generatePurchaseNumberFromRepo() async {
    try {
      final repo = ref.read(purchaseRepositoryProvider);
      final number = await repo.generatePurchaseNumber();
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = TamgaciConstants.isDesktop(context) ||
              TamgaciConstants.isWideDesktop(context);
          final maxWidth = isLargeScreen ? 1100.0 : null;
          final padding = TamgaciConstants.paddingMedium(context);
          return Form(
            key: _formKey,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth ?? constraints.maxWidth,
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: padding,
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant),
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
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
                          _buildCustomerSelector(),
                          const SizedBox(height: 16),
                          _buildDateField(
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
                                        final items =
                                            <DropdownMenuItem<String>>[
                                          const DropdownMenuItem(
                                            value: 'no_stock',
                                            child: Text('Stoksuz Ürün'),
                                          ),
                                          for (final w in list)
                                            DropdownMenuItem(
                                                value: w.id,
                                                child: Text(w.code != null &&
                                                        w.code!.isNotEmpty
                                                    ? '${w.name} (${w.code})'
                                                    : w.name)),
                                        ];
                                        String? value = _selectedWarehouse?.id;
                                        final values =
                                            items.map((e) => e.value).toSet();
                                        if (value != null &&
                                            !values.contains(value)) {
                                          value = 'no_stock';
                                        }
                                        return DropdownButtonFormField<String>(
                                          initialValue: value,
                                          decoration: const InputDecoration(
                                              labelText: 'Depo'),
                                          isExpanded: true,
                                          items: items,
                                          onChanged: (id) async {
                                            if (id == 'no_stock') {
                                              setState(() {
                                                _selectedWarehouse = null;
                                                _receiveToInventory = false;
                                              });
                                            } else {
                                              final list = await ref.read(
                                                  warehousesProvider.future);
                                              setState(() {
                                                _selectedWarehouse =
                                                    list.firstWhere(
                                                        (w) => w.id == id,
                                                        orElse: () =>
                                                            list.first);
                                                _receiveToInventory = true;
                                              });
                                            }
                                          },
                                        );
                                      },
                                      loading: () =>
                                          const LinearProgressIndicator(),
                                      error: (e, _) =>
                                          DropdownButtonFormField<String>(
                                        initialValue: 'no_stock',
                                        decoration: const InputDecoration(
                                            labelText: 'Depo'),
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
                                    onChanged: (v) => setState(
                                        () => _receiveToInventory = v ?? true),
                                    dense: true,
                                    title:
                                        const Text('Teslim al (stok girişi)'),
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
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
                                  onPressed: () => setState(() =>
                                      _installments.add(_InstallmentForm())),
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

                      // Alış Ürünleri
                      _buildItemsCard(),

                      const SizedBox(height: 24),

                      // Özet Bölümü
                      _buildSummaryCard(),

                      const SizedBox(height: 24),

                      _buildSectionCard(
                        'Açıklama ve Notlar',
                        Icons.note_outlined,
                        [
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Açıklama',
                            maxLines: 3,
                            required: false,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _notesController,
                            label: 'Notlar',
                            maxLines: 3,
                            required: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: _isSaving ? null : _savePurchase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      TamgaciConstants.radiusMD),
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
            ),
          );
        },
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
    bool required = true,
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
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label gereklidir';
              }
              return null;
            }
          : null,
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

  void _addPurchaseItem() {
    // Müşteri seçili değilse uyarı ver
    if (_customerIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce müşteri seçiniz')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onAdd: (item) {
          setState(() {
            _items.add(item);
          });
        },
        paymentCurrencyCode: _paymentCurrencyCode,
        baseCurrencyCode: _baseCurrencyCode,
        customerId: _customerIdController.text.isNotEmpty
            ? _customerIdController.text
            : null,
        purchaseType: _purchaseType,
        existingItems: _items,
        customerDiscountRate: _customerDefaultDiscountRate,
      ),
    );
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_customerIdController.text.isEmpty) {
      final scheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Müşteri seçilmelidir',
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
        tenantId: '', // Repository'de set edilecek
        purchaseNumber: _purchaseNumberController.text,
        type: _purchaseType,
        status: _isDraft ? PurchaseStatus.draft : PurchaseStatus.pending,
        paymentStatus: _purchaseType == PurchaseType.returnPurchase
            ? PurchasePaymentStatus
                .paid // İade alışı için ödeme tamamlanmış sayılır
            : PurchasePaymentStatus.pending,
        supplierId: _customerIdController.text,
        supplierName: _customerNameController.text,
        purchaseDate: _purchaseDate,
        dueDate: null,
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

      // Alış listesini yeniden yükle (purchase ID'yi almak için)
      await ref.read(purchaseNotifierProvider.notifier).getPurchases();

      // Oluşturulan purchase'ı bul (ID'yi almak için)
      final purchases = ref.read(purchaseNotifierProvider).purchases;
      Purchase purchaseWithId = purchase;
      try {
        final createdPurchase = purchases.firstWhere(
          (p) => p.purchaseNumber == purchase.purchaseNumber,
        );
        // Purchase ID'yi güncelle
        if (createdPurchase.id.isNotEmpty) {
          purchaseWithId = purchase.copyWith(id: createdPurchase.id);
        }
      } catch (e) {
        AppLogger.warning(
            'Could not find created purchase by number, using original purchase');
      }

      // Alış kaydedildikten sonra ilgili provider'ları invalidate et ve yenile
      ref.invalidate(purchaseNotifierProvider);
      ref.invalidate(invoice_providers.invoicesProvider);
      ref.invalidate(invoice_providers.invoicesStreamProvider);
      if (_customerIdController.text.isNotEmpty) {
        ref.invalidate(
            customerPurchasesStreamProvider(_customerIdController.text));
        // Müşteri provider'ını da invalidate et
        ref.invalidate(customerProvider(_customerIdController.text));
      }

      // Faturalar modülüne senkronizasyon (direction: purchase)
      // Hata olsa bile alış kaydı başarılı sayılmalı
      try {
        await _syncInvoiceWithPurchase(purchaseWithId);
      } catch (e) {
        AppLogger.warning('Invoice sync failed (non-critical): $e');
        // Invoice hatası alış kaydını engellememeli
      }

      // İade alışı ise stoklara giriş yap
      if (_purchaseType == PurchaseType.returnPurchase &&
          _selectedWarehouse != null) {
        try {
          final inventory = InventoryService();
          final stockMovements = _items
              .where((item) =>
                  item.productId != null && item.productId!.isNotEmpty)
              .map((item) async {
            try {
              final movement = StockMovement(
                id: '',
                productId: item.productId!,
                warehouseId: _selectedWarehouse!.id,
                type: StockMovementType.returnIn, // İade girişi
                quantity: item.quantity.round(),
                reason: 'Satıştan İade',
                reference: purchaseWithId.purchaseNumber,
                notes: 'İade alışı',
                createdBy: 'system',
                createdAt: DateTime.now(),
              );
              await inventory.recordStockMovement(movement);
              AppLogger.info(
                  'Stock movement recorded for return purchase product: ${item.productId}');
            } catch (e) {
              AppLogger.error(
                  'Error recording stock movement for product: ${item.productId}',
                  e);
            }
          }).toList();

          // Tüm stok hareketlerini paralel olarak çalıştır
          await Future.wait(stockMovements);
        } catch (e) {
          AppLogger.error(
              'Error recording stock movements for return purchase', e);
        }
      }

      // Normal alış için transaction oluştur (iade alışı hariç)
      if (_purchaseType != PurchaseType.returnPurchase) {
        try {
          await _createPurchaseTransactions(purchaseWithId);
        } catch (e) {
          AppLogger.error('Error creating transactions for purchase', e);
          // Transaction hatası alış kaydını engellememeli
        }
      }

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

        // Fatura önizleme sayfasına yönlendir
        final invoice =
            UnifiedInvoiceConverter.convertPurchaseToInvoice(purchase);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InvoicePreviewPage(
                invoice: invoice,
                isEditable: true,
                isFromSale: false, // Alış yap modülünden geldi
              ),
            ),
          );
        }
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

  Future<void> _createPurchaseTransactions(Purchase purchase) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final tenantId = userDoc.data()?['tenantId'] as String? ?? '';

      // Varsayılan hesabı bul (TRY para birimli nakit kasa)
      final accounts = await ref.read(accountsProvider.future);

      if (accounts.isEmpty) {
        AppLogger.warning('No accounts found for purchase transaction');
        return;
      }

      // Önce TRY para birimli nakit kasayı bul
      final targetAccount = accounts.firstWhere(
        (acc) =>
            acc.currency == 'TRY' &&
            acc.type == account_entity.AccountType.cash,
        orElse: () => accounts.firstWhere(
          (acc) => acc.currency == purchase.currency,
          orElse: () => accounts.first,
        ),
      );

      final now = DateTime.now();
      final amount = purchase.totalAmount;

      // TransactionService ile müşteri transaction'ı oluştur
      try {
        final transactionService = transaction_service.TransactionService();
        final transaction = transaction_service.Transaction(
          id: '',
          customerId: '', // Alış için customer yok
          supplierId: purchase.supplierId,
          type: transaction_service.TransactionType.expense,
          amount: amount,
          currency: purchase.currency,
          description: 'Alış ödemesi ${purchase.purchaseNumber}',
          reference: purchase.purchaseNumber,
          transactionDate: purchase.purchaseDate,
          dueDate: purchase.dueDate,
          invoiceId: null,
          paymentMethod: null,
          documentNumber: purchase.purchaseNumber,
          status: transaction_service.TransactionStatus.completed,
          companyId: tenantId, // companyId gerekli
          createdAt: now,
          updatedAt: now,
          createdBy: user.uid,
          updatedBy: user.uid,
          metadata: {'purchaseId': purchase.id},
        );

        await transactionService.createTransaction(transaction);
        AppLogger.info(
            'Transaction created for purchase: ${purchase.purchaseNumber}');
      } catch (e) {
        AppLogger.error('Error creating Transaction for purchase', e);
      }

      // AccountTransaction oluştur
      try {
        final accountDoc = await FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('accounts')
            .doc(targetAccount.id)
            .get();

        if (accountDoc.exists) {
          final accountData = accountDoc.data()!;
          final currentBalance =
              (accountData['balance'] as num?)?.toDouble() ?? 0.0;
          final newBalance = currentBalance - amount; // Alış için çıkış

          // AccountTransaction oluştur
          final accountTransaction = account_txn.AccountTransaction(
            id: '',
            accountId: targetAccount.id,
            fromAccountId: null,
            toAccountId: null,
            type: account_txn.TransactionType.expense,
            category: account_txn.TransactionCategory.other,
            amount: amount,
            debitAmount: amount,
            creditAmount: null,
            balanceAfter: newBalance,
            description:
                'Alış ödemesi ${purchase.purchaseNumber} (${purchase.currency})',
            reference: purchase.purchaseNumber,
            transactionDate: now,
            userId: user.uid,
            notes: null,
            isReconciled: false,
            reconciledAt: null,
            reconciledBy: null,
            tenantId: tenantId,
            createdBy: user.uid,
            updatedBy: user.uid,
            createdAt: now,
            updatedAt: now,
          );

          // AccountTransaction'ı oluştur ve hesap bakiyesini güncelle
          await ref
              .read(accountTransactionNotifierProvider.notifier)
              .createTransaction(accountTransaction);

          // Hesap bakiyesini AccountNotifier üzerinden güncelle
          await ref
              .read(accountNotifierProvider.notifier)
              .updateAccountBalance(targetAccount.id, newBalance);

          // Account provider'larını invalidate et
          ref.invalidate(accountsProvider);
          ref.invalidate(accountByIdProvider(targetAccount.id));
          ref.invalidate(accountStatisticsProvider);
          ref.invalidate(transactionsByAccountIdProvider(targetAccount.id));
          ref.invalidate(transactionsProvider);
          ref.invalidate(transactionStatisticsProvider);

          AppLogger.info(
              'AccountTransaction created and balance updated successfully for purchase: ${purchase.purchaseNumber}');
        }
      } catch (e) {
        AppLogger.error('Error creating AccountTransaction for purchase', e);
      }
    } catch (e) {
      AppLogger.error('Error in _createPurchaseTransactions', e);
      rethrow;
    }
  }

  Future<void> _syncInvoiceWithPurchase(Purchase purchase) async {
    // documentType eşlemesi: normal alış -> invoice, satıştan iade alışı -> returnPurchase (invoice altında not)
    final documentType = purchase.type == PurchaseType.returnPurchase
        ? 'invoice' // İade alışını da purchase faturası olarak kaydediyoruz
        : 'invoice';

    final repo = ref.read(invoice_providers.invoiceRepositoryProvider);
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

  // Item form model helper ends

  // Ürün tablosu metodları (satış modülünden)
  Widget _buildItemsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alış Ürünleri',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addPurchaseItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Ürün Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            if (_items.isEmpty)
              Center(
                child: Text(
                  'Henüz ürün eklenmedi',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey,
                  ),
                ),
              )
            else
              _buildProductsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTable() {
    // Aynı ürün, aynı para birimi ve aynı birim fiyat olan ürünleri birleştir
    final mergedItems = _mergeIdenticalItems(_items);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Column(
        children: [
          // Tablo başlığı
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Küçük ekran için basit başlık
                  return const Row(
                    children: [
                      Expanded(
                          child: Text('Ürün',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 8),
                      Text('Miktar',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Text('Birim',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Text('Toplam',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 40),
                    ],
                  );
                } else {
                  // Büyük ekran için tam tablo başlığı
                  return Row(
                    children: [
                      Expanded(flex: 3, child: _buildTableHeader('Ürün Adı')),
                      Expanded(flex: 2, child: _buildTableHeader('Miktar')),
                      Expanded(
                          flex: 2, child: _buildTableHeader('Birim Fiyat')),
                      Expanded(flex: 2, child: _buildTableHeader('KDV')),
                      Expanded(flex: 2, child: _buildTableHeader('İskonto')),
                      Expanded(flex: 2, child: _buildTableHeader('Toplam')),
                      const SizedBox(width: 40), // Silme butonu için alan
                    ],
                  );
                }
              },
            ),
          ),

          // Ürün listesi
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mergedItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1.0),
            itemBuilder: (context, index) {
              final item = mergedItems[index];
              return _buildProductRow(item, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  /// Aynı ürün, aynı para birimi ve aynı birim fiyat olan ürünleri birleştir
  List<_PurchaseItemForm> _mergeIdenticalItems(List<_PurchaseItemForm> items) {
    if (items.isEmpty) return items;

    // Birleştirme için Map kullan
    final Map<String, _PurchaseItemForm> mergedMap = {};

    for (final item in items) {
      // Benzersiz anahtar oluştur: productId + currency + unitPrice + taxRate + discountRate
      final key =
          '${item.productId}_${item.currency}_${item.unitPrice}_${item.taxRate}_${item.discountRate}';

      if (mergedMap.containsKey(key)) {
        // Mevcut ürünü güncelle
        final existingItem = mergedMap[key]!;
        final mergedItem = _PurchaseItemForm();
        mergedItem.productId = existingItem.productId;
        mergedItem.productName = existingItem.productName;
        mergedItem.currency = existingItem.currency;
        mergedItem.unitPrice = existingItem.unitPrice;
        mergedItem.taxRate = existingItem.taxRate;
        mergedItem.discountRate = existingItem.discountRate;
        mergedItem.quantity = existingItem.quantity + item.quantity;
        mergedItem.quantityController.text = mergedItem.quantity.toString();
        mergedItem.unitPriceController.text = existingItem.unitPrice.toString();
        mergedItem.taxRateController.text = existingItem.taxRate.toString();
        mergedItem.discountAmount =
            existingItem.discountAmount + item.discountAmount;
        mergedMap[key] = mergedItem;
      } else {
        // Yeni ürün ekle
        mergedMap[key] = item;
      }
    }

    return mergedMap.values.toList();
  }

  Widget _buildProductRow(_PurchaseItemForm item, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildSmallScreenRow(item, index);
        } else {
          return _buildLargeScreenRow(item, index);
        }
      },
    );
  }

  Widget _buildSmallScreenRow(_PurchaseItemForm item, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _editItem(item, index),
                icon: const Icon(Icons.edit, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                onPressed: () => _removeItem(index),
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Miktar: ${item.quantity.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Expanded(
                child: Text(
                  'Birim: ${CurrencyHelper.formatCurrency(item.unitPrice, item.currency)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toplam:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                CurrencyHelper.formatCurrency(item.lineTotal, item.currency),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeScreenRow(_PurchaseItemForm item, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.productName,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.quantity.toStringAsFixed(0),
              style: TextStyle(color: textColor),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              CurrencyHelper.formatCurrency(item.unitPrice, item.currency),
              style: TextStyle(color: textColor),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.taxRate.toStringAsFixed(1)}%',
              style: TextStyle(color: textColor),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              CurrencyHelper.formatCurrency(item.discountAmount, item.currency),
              style: TextStyle(color: textColor),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              CurrencyHelper.formatCurrency(item.lineTotal, item.currency),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editItem(item, index),
                icon: const Icon(Icons.edit, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                onPressed: () => _removeItem(index),
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editItem(_PurchaseItemForm item, int index) {
    // Ürün düzenleme dialogunu aç
    _showEditItemDialog(item, index);
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _showEditItemDialog(_PurchaseItemForm item, int index) {
    showDialog(
      context: context,
      builder: (context) => _EditItemDialog(
        item: item,
        onSave: (editedItem) {
          setState(() {
            _items[index] = editedItem;
          });
        },
      ),
    );
  }

  // Multi-currency summary metodları (satış modülünden)
  Widget _buildSummaryCard() {
    if (_items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Özet',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: Text(
                  'Henüz ürün eklenmedi',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Para birimi bazlı gruplandırma
    final Map<String, List<_PurchaseItemForm>> itemsByCurrency = {};
    for (final item in _items) {
      final currency = item.currency;
      if (!itemsByCurrency.containsKey(currency)) {
        itemsByCurrency[currency] = [];
      }
      itemsByCurrency[currency]!.add(item);
    }

    // Her para birimi için hesaplamalar
    final List<Widget> currencyCards = [];
    double totalInTargetCurrency = 0.0;

    // Alış türüne göre hedef para birimi belirle
    String targetCurrency = 'TRY';
    if (_purchaseType == PurchaseType.returnPurchase) {
      // İade Alışı: Müşterinin varsayılan para birimi
      // Customer entity'sine defaultCurrency field'ı eklenmeli
      targetCurrency = 'TRY'; // Şimdilik TRY kullanılıyor
    } else {
      // Normal Alış: Ödeme para birimi
      targetCurrency = _currencyCode;
    }

    for (final currency in itemsByCurrency.keys) {
      final items = itemsByCurrency[currency]!;

      // Bu para birimi için hesaplamalar
      final subtotal = items.fold(
          0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
      final totalDiscount =
          items.fold(0.0, (sum, item) => sum + item.discountAmount);
      final totalTax = items.fold(0.0, (sum, item) => sum + item.taxAmount);
      final total = subtotal - totalDiscount + totalTax;

      // Debug: Özet hesaplama bilgilerini yazdır
      debugPrint(
          'DEBUG: Özet hesaplama - Currency: $currency, Subtotal: $subtotal, TotalDiscount: $totalDiscount, TotalTax: $totalTax, Total: $total');

      // Para birimi dönüşümü hesapla (ürünlerin kendi kurlarını kullan)
      double convertedTotal = 0.0;
      if (currency != targetCurrency) {
        // Bu para birimindeki ürünlerin kurlarını kontrol et
        double? usedFxRate;

        // İlk ürünün kurunu kullan (aynı para birimindeki tüm ürünler aynı kur kullanmalı)
        for (final item in items) {
          if (item.currency == currency &&
              item.fxRateToBase != null &&
              item.fxRateToBase! > 0) {
            usedFxRate = item.fxRateToBase;
            debugPrint(
                'DEBUG: Para birimi kur bilgisi bulundu - $currency: ${item.fxRateToBase}');
            break;
          }
        }

        if (usedFxRate != null && usedFxRate > 0) {
          // Ürün kurlarını kullan
          convertedTotal = total * usedFxRate;
          debugPrint(
              'DEBUG: Ürün kuru kullanıldı - $total $currency x $usedFxRate = $convertedTotal $targetCurrency');
        } else {
          // Kur bilgisi yoksa real-time kur kullan
          try {
            convertedTotal = ExchangeRateService()
                .convertCurrency(total, currency, targetCurrency);
            debugPrint(
                'DEBUG: Real-time kur kullanıldı - $total $currency = $convertedTotal $targetCurrency');
          } catch (e) {
            debugPrint('DEBUG: Para birimi dönüşüm hatası: $e');
            convertedTotal = total; // Fallback
          }
        }
        debugPrint(
            'DEBUG: Para birimi dönüştürüldü - $currency -> $targetCurrency: $convertedTotal');
      } else {
        convertedTotal = total;
        debugPrint('DEBUG: Aynı para birimi - $currency: $total');
      }

      totalInTargetCurrency += convertedTotal;
      debugPrint(
          'DEBUG: totalInTargetCurrency güncellendi: $totalInTargetCurrency');

      currencyCards.add(_buildCurrencySummaryCard(
        currency: currency,
        subtotal: subtotal,
        discount: totalDiscount,
        tax: totalTax,
        total: total,
        targetCurrency: targetCurrency,
        onTotalCalculated: (targetAmount) {
          // Bu callback artık kullanılmıyor ama metodun imzası için gerekli
        },
        items: items,
      ));
    }

    return Column(
      children: [
        // Her para birimi için ayrı kart
        ...currencyCards,
        // GENEL TOPLAM kartı (birden fazla para birimi varsa)
        if (currencyCards.length > 1) ...[
          const SizedBox(height: 16.0),
          _buildGrandTotalCard(totalInTargetCurrency, targetCurrency),
        ],
      ],
    );
  }

  Widget _buildCurrencySummaryCard({
    required String currency,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required String targetCurrency,
    required Function(double) onTotalCalculated,
    required List<_PurchaseItemForm> items,
  }) {
    return FutureBuilder<ExchangeRate?>(
      future: currency == targetCurrency
          ? Future.value(null)
          : ExchangeRateService().getExchangeRate(currency),
      builder: (context, snapshot) {
        double totalInTargetCurrency = total; // Default to original total

        // Only perform conversion and call callback when the future is done
        if (snapshot.connectionState == ConnectionState.done) {
          final rate = snapshot.data;
          if (rate != null && currency != targetCurrency) {
            totalInTargetCurrency = ExchangeRateService()
                .convertCurrency(total, currency, targetCurrency);
            debugPrint(
                'DEBUG: Para birimi dönüştürüldü - $currency -> $targetCurrency: $totalInTargetCurrency');
            onTotalCalculated(totalInTargetCurrency);
          } else if (currency == targetCurrency) {
            debugPrint('DEBUG: Aynı para birimi - $currency: $total');
            onTotalCalculated(total);
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currency Özeti',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                _buildSummaryRow('Ara Toplam:', subtotal, currency,
                    targetCurrency: targetCurrency, items: items),
                _buildSummaryRow('İndirim:', -discount, currency,
                    targetCurrency: targetCurrency, items: items),
                _buildSummaryRow('KDV:', tax, currency,
                    targetCurrency: targetCurrency, items: items),
                const Divider(),
                _buildSummaryRow('Toplam:', total, currency,
                    isTotal: true,
                    targetCurrency: targetCurrency,
                    items: items),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, double amount, String currency,
      {bool isTotal = false,
      String? targetCurrency,
      List<_PurchaseItemForm>? items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16.0 : 14.0,
            ),
          ),
          _buildCurrencyAmount(amount, currency,
              isTotal: isTotal, targetCurrency: targetCurrency, items: items),
        ],
      ),
    );
  }

  Widget _buildCurrencyAmount(double amount, String currency,
      {bool isTotal = false,
      String? targetCurrency,
      List<_PurchaseItemForm>? items}) {
    if (targetCurrency != null && currency != targetCurrency) {
      // Farklı para birimi ise dönüştürülmüş değeri göster
      return FutureBuilder<double?>(
        future: _convertToTargetCurrencyWithProductRate(
            amount, currency, targetCurrency, items ?? []),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final convertedAmount = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyHelper.formatCurrency(amount, currency),
                  style: TextStyle(
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    fontSize: isTotal ? 16.0 : 14.0,
                    color: isTotal ? AppColors.primary : null,
                  ),
                ),
                Text(
                  '(${CurrencyHelper.formatCurrency(convertedAmount, targetCurrency)})',
                  style: TextStyle(
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    fontSize: isTotal ? 14.0 : 12.0,
                    color: isTotal ? AppColors.primary : Colors.grey[600],
                  ),
                ),
              ],
            );
          } else {
            return Text(
              CurrencyHelper.formatCurrency(amount, currency),
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16.0 : 14.0,
                color: isTotal ? AppColors.primary : null,
              ),
            );
          }
        },
      );
    } else {
      // Aynı para birimi ise normal göster
      return Text(
        CurrencyHelper.formatCurrency(amount, currency),
        style: TextStyle(
          fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          fontSize: isTotal ? 16.0 : 14.0,
          color: isTotal ? AppColors.primary : null,
        ),
      );
    }
  }

  Future<double?> _convertToTargetCurrencyWithProductRate(
      double amount,
      String fromCurrency,
      String toCurrency,
      List<_PurchaseItemForm> items) async {
    try {
      if (fromCurrency == toCurrency) return amount;

      // Bu para birimindeki ürünlerin kurlarını kontrol et
      double? usedFxRate;

      // İlk ürünün kurunu kullan (aynı para birimindeki tüm ürünler aynı kur kullanmalı)
      for (final item in items) {
        if (item.currency == fromCurrency &&
            item.fxRateToBase != null &&
            item.fxRateToBase! > 0) {
          usedFxRate = item.fxRateToBase;
          debugPrint(
              'DEBUG: Özet kur bilgisi bulundu - $fromCurrency: ${item.fxRateToBase}');
          break;
        }
      }

      if (usedFxRate != null && usedFxRate > 0) {
        // Ürün kurlarını kullan
        final converted = amount * usedFxRate;
        debugPrint(
            'DEBUG: Özet ürün kuru kullanıldı - $amount $fromCurrency x $usedFxRate = $converted $toCurrency');
        return converted;
      } else {
        // Kur bilgisi yoksa real-time kur kullan
        final rate = await ExchangeRateService().getExchangeRate(fromCurrency);
        if (rate != null) {
          final converted = ExchangeRateService()
              .convertCurrency(amount, fromCurrency, toCurrency);
          debugPrint(
              'DEBUG: Özet real-time kur kullanıldı - $amount $fromCurrency = $converted $toCurrency');
          return converted;
        }
        return null;
      }
    } catch (e) {
      debugPrint('Özet para birimi dönüşüm hatası: $e');
      return null;
    }
  }

  Widget _buildGrandTotalCard(
      double totalInTargetCurrency, String targetCurrency) {
    // Toplam ürün miktarını hesapla
    final totalQuantity = _items.fold(0.0, (sum, item) => sum + item.quantity);
    debugPrint(
        'DEBUG: _buildGrandTotalCard - totalInTargetCurrency: $totalInTargetCurrency, targetCurrency: $targetCurrency');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Toplam ürün miktarı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Toplam ürün miktarı:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  totalQuantity.toStringAsFixed(0),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Genel toplam
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GENEL TOPLAM ($targetCurrency):',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  CurrencyHelper.formatCurrency(
                      totalInTargetCurrency, targetCurrency),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Müşteri seçimi metodları (satış modülünden)
  Widget _buildCustomerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Müşteri Seçimi',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _customerNameController,
                decoration: InputDecoration(
                  labelText: 'Müşteri Adı',
                  border: const OutlineInputBorder(),
                  hintText: _customerNameController.text.isNotEmpty
                      ? 'Müşteri seçili'
                      : 'Müşteri seçin',
                ),
                readOnly: true,
                onTap: _customerNameController.text.isNotEmpty
                    ? null
                    : _showCustomerSelectionDialog,
              ),
            ),
            if (_customerNameController.text.isEmpty) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: _showCustomerSelectionDialog,
                icon: const Icon(Icons.search),
                tooltip: 'Müşteri Ara',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _showCustomerSelectionDialog() async {
    // Müşteri seçimi dialog'u
    final customers = await ref.read(customersProvider.future);

    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : null,
        title: Text(
          'Müşteri Seç',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                title: Text(
                  customer.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                subtitle: Text(
                  customer.email ?? '',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                onTap: () {
                  setState(() {
                    _customerIdController.text = customer.id;
                    _customerNameController.text = customer.name;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
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
  double? fxRateToBase; // Ürün eklerken girilen kur

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

  double get taxAmount {
    final q = double.tryParse(quantityController.text) ?? 0;
    final up = double.tryParse(unitPriceController.text) ?? 0;
    final dr = discountAmount;
    final tr = double.tryParse(taxRateController.text) ?? 0;
    final net = (q * up) - dr;
    return net * (tr / 100);
  }

  void applyProduct(Product p) {
    productId = p.id;
    productName = p.name;
    // Eğer ürün KDV dahil ise, KDV hariç fiyatı kullan
    // Çünkü alış sayfasında KDV tekrar eklenecek
    final priceToUse = p.purchaseTaxInclusive == TaxInclusiveOption.inclusive
        ? (p.purchasePriceWithoutTax ?? p.purchasePrice ?? 0)
        : (p.purchasePrice ?? 0);
    unitPrice = priceToUse;
    unitPriceController.text = priceToUse.toStringAsFixed(2);
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

// Edit Item Dialog (satış modülünden)
class _EditItemDialog extends StatefulWidget {
  final _PurchaseItemForm item;
  final Function(_PurchaseItemForm) onSave;

  const _EditItemDialog({
    required this.item,
    required this.onSave,
  });

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late _PurchaseItemForm _editedItem;
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;
  late TextEditingController _taxRateController;
  late TextEditingController _discountRateController;

  @override
  void initState() {
    super.initState();
    _editedItem = _PurchaseItemForm();
    _editedItem.productId = widget.item.productId;
    _editedItem.productName = widget.item.productName;
    _editedItem.currency = widget.item.currency;
    _editedItem.quantity = widget.item.quantity;
    _editedItem.unitPrice = widget.item.unitPrice;
    _editedItem.taxRate = widget.item.taxRate;
    _editedItem.discountRate = widget.item.discountRate;
    _editedItem.discountAmount = widget.item.discountAmount;

    _quantityController =
        TextEditingController(text: _editedItem.quantity.toString());
    _unitPriceController =
        TextEditingController(text: _editedItem.unitPrice.toString());
    _taxRateController =
        TextEditingController(text: _editedItem.taxRate.toString());
    _discountRateController =
        TextEditingController(text: _editedItem.discountRate.toString());

    _quantityController.addListener(_updateCalculations);
    _unitPriceController.addListener(_updateCalculations);
    _taxRateController.addListener(_updateCalculations);
    _discountRateController.addListener(_updateCalculations);
  }

  void _updateCalculations() {
    setState(() {
      _editedItem.quantity = double.tryParse(_quantityController.text) ?? 0;
      _editedItem.unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
      _editedItem.taxRate = double.tryParse(_taxRateController.text) ?? 0;
      _editedItem.discountRate =
          double.tryParse(_discountRateController.text) ?? 0;

      // İndirim tutarını hesapla
      final subtotal = _editedItem.quantity * _editedItem.unitPrice;
      _editedItem.discountAmount = subtotal * (_editedItem.discountRate / 100);
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _taxRateController.dispose();
    _discountRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? Colors.grey[850] : null,
      title: Text(
        'Ürün Düzenle',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.grey[800],
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: TextEditingController(text: _editedItem.productName),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey[800],
              ),
              decoration: InputDecoration(
                labelText: 'Ürün Adı',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Miktar',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Birim Fiyat',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _taxRateController,
                    decoration: const InputDecoration(
                      labelText: 'KDV Oranı (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _discountRateController,
                    decoration: const InputDecoration(
                      labelText: 'İndirim Oranı (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ara Toplam:'),
                      Text(CurrencyHelper.formatCurrency(
                        _editedItem.quantity * _editedItem.unitPrice,
                        _editedItem.currency,
                      )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('İndirim:'),
                      Text(CurrencyHelper.formatCurrency(
                        _editedItem.discountAmount,
                        _editedItem.currency,
                      )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('KDV:'),
                      Text(CurrencyHelper.formatCurrency(
                        _editedItem.taxAmount,
                        _editedItem.currency,
                      )),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Toplam:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        CurrencyHelper.formatCurrency(
                          _editedItem.lineTotal,
                          _editedItem.currency,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_editedItem);
            Navigator.of(context).pop();
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

// Add Item Dialog (satış modülünden tam olarak kopyalandı)
class _AddItemDialog extends StatefulWidget {
  final void Function(_PurchaseItemForm) onAdd;
  final String paymentCurrencyCode;
  final String baseCurrencyCode;
  final String? customerId;
  final PurchaseType purchaseType;
  final List<_PurchaseItemForm> existingItems;
  final double customerDiscountRate;

  const _AddItemDialog({
    required this.onAdd,
    required this.paymentCurrencyCode,
    required this.baseCurrencyCode,
    this.customerId,
    required this.purchaseType,
    required this.existingItems,
    required this.customerDiscountRate,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _productIdController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitPriceController = TextEditingController();
  final _taxRateController = TextEditingController(text: '18');
  final _discountRateController = TextEditingController(text: '0');
  String _lineCurrencyCode = 'TRY';
  double? _fxRateToTry;
  String _productCurrencyCode = 'TRY';
  final TextEditingController _manualRateController = TextEditingController();

  // Orijinal fiyat ve müşteri iskonto bilgileri
  double? _originalPrice;
  double _customerDiscountRate = 0.0;
  bool _showCurrencySelection = true;
  bool _showExchangeRate = true;

  // Ürün bazında hatırlama için
  static final Map<String, Map<String, double>> _productMemory = {};
  String? _currentProductId;

  @override
  void initState() {
    super.initState();
    // Müşteri iskonto oranını al
    _customerDiscountRate = widget.customerDiscountRate;
    // Aynı para birimindeki ürün varsa kur seçimi gösterme
    _checkExistingCurrency();
  }

  @override
  void didUpdateWidget(_AddItemDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Müşteri iskonto oranı güncellendiğinde güncelle
    if (oldWidget.customerDiscountRate != widget.customerDiscountRate) {
      _customerDiscountRate = widget.customerDiscountRate;
      debugPrint(
          'DEBUG: Müşteri iskonto oranı güncellendi: $_customerDiscountRate');
    }
  }

  void _checkExistingCurrency() {
    // Müşterinin para birimini al (varsayılan olarak TRY)
    final customerCurrency =
        widget.baseCurrencyCode.isNotEmpty ? widget.baseCurrencyCode : 'TRY';

    debugPrint('DEBUG: Müşteri para birimi: $customerCurrency');

    setState(() {
      _showCurrencySelection = true; // Para birimi seçimi her zaman gösterilir
      _lineCurrencyCode =
          customerCurrency; // Varsayılan olarak müşteri para birimi
    });
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _taxRateController.dispose();
    _discountRateController.dispose();
    _manualRateController.dispose();
    super.dispose();
  }

  void _onProductSelected(String id, String? name, double? price, double? tax,
      String salesCurrency) {
    setState(() {
      _currentProductId = id;
      _productIdController.text = id;
      _productNameController.text = name ?? '';
      _unitPriceController.text = price != null ? _formatTrCurrency(price) : '';
      _productCurrencyCode = salesCurrency.toUpperCase();
      _lineCurrencyCode = _productCurrencyCode;

      // Bu ürün için daha önce girilen değerleri kontrol et
      debugPrint(
          'DEBUG: Ürün seçildi - ID: $id, Tax: $tax, CustomerDiscount: $_customerDiscountRate');

      if (_productMemory.containsKey(id)) {
        // Hafızada varsa, hafızadaki değerleri kullan
        final memory = _productMemory[id]!;
        debugPrint(
            'DEBUG: Hafızada bulundu - TaxRate: ${memory['taxRate']}, DiscountRate: ${memory['discountRate']}');

        if (memory.containsKey('taxRate')) {
          _taxRateController.text = memory['taxRate']!.toStringAsFixed(0);
        } else {
          // Hafızada yoksa ürünün KDV oranını kullan
          if (tax != null) {
            _taxRateController.text = tax.toStringAsFixed(0);
            debugPrint('DEBUG: Ürün KDV oranı kullanıldı: $tax');
          }
        }

        if (memory.containsKey('discountRate')) {
          _discountRateController.text =
              memory['discountRate']!.toStringAsFixed(0);
        } else {
          // Hafızada yoksa müşteri iskonto oranını kullan
          _discountRateController.text =
              _customerDiscountRate.toStringAsFixed(0);
          debugPrint(
              'DEBUG: Müşteri iskonto oranı kullanıldı: $_customerDiscountRate');
        }
      } else {
        // Hafızada yoksa otomatik değerleri kullan
        debugPrint('DEBUG: Hafızada yok, otomatik değerler kullanılıyor');

        // Ürünün KDV oranını ayarla
        if (tax != null) {
          _taxRateController.text = tax.toStringAsFixed(0);
          debugPrint('DEBUG: Ürün KDV oranı ayarlandı: $tax');
        }

        // Müşteri iskonto oranını ayarla
        _discountRateController.text = _customerDiscountRate.toStringAsFixed(0);
        debugPrint(
            'DEBUG: Müşteri iskonto oranı ayarlandı: $_customerDiscountRate');
      }
    });
  }

  void _saveProductMemory(String productId) {
    final taxRate = double.tryParse(_taxRateController.text) ?? 0.0;
    final discountRate = double.tryParse(_discountRateController.text) ?? 0.0;

    _productMemory[productId] = {
      'taxRate': taxRate,
      'discountRate': discountRate,
    };

    debugPrint(
        'DEBUG: Ürün hafızaya kaydedildi - ID: $productId, TaxRate: $taxRate, DiscountRate: $discountRate');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? Colors.grey[850] : null,
      title: Text(
        'Ürün Ekle',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.grey[800],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductQuickPicker(
              customerId: widget.customerId,
              purchaseType: widget.purchaseType,
              onSelected: (id, name, price, tax, salesCurrency,
                  {originalPrice, customerDiscountRate}) {
                _onProductSelected(id, name, price, tax, salesCurrency);
              },
            ),
            if (_productIdController.text.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ürün ID / Kod: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                    Expanded(
                      child: Text(
                        _productIdController.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16.0),
            if (_showCurrencySelection) ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _lineCurrencyCode,
                      decoration: const InputDecoration(
                        labelText: 'Satır Para Birimi',
                        border: OutlineInputBorder(),
                      ),
                      items: const ['TRY', 'USD', 'EUR', 'GBP']
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) async {
                        if (v == null) return;
                        setState(() => _lineCurrencyCode = v);

                        debugPrint(
                            'DEBUG: Para birimi seçildi: $v, Müşteri para birimi: ${widget.baseCurrencyCode}, Ürün para birimi: $_productCurrencyCode');

                        // Ürünün para birimi ile müşterinin para birimi farklıysa kur bilgisi göster
                        if (_productCurrencyCode != widget.baseCurrencyCode) {
                          // Ürünün para birimi müşterinin para biriminden farklıysa kur bilgisi göster
                          // Aynı para birimindeki ürün var mı kontrol et
                          final existingItem = widget.existingItems.firstWhere(
                            (item) => item.currency == v,
                            orElse: () => _PurchaseItemForm(),
                          );

                          if (existingItem.currency == v &&
                              existingItem.fxRateToBase != null) {
                            // Aynı para birimindeki ürün varsa, kur bilgisini gizle ve mevcut kur bilgisini kullan
                            setState(() {
                              _showExchangeRate = false;
                              _fxRateToTry = existingItem.fxRateToBase;
                              _manualRateController.text =
                                  _formatTrNumber(existingItem.fxRateToBase!);
                            });
                            debugPrint(
                                'DEBUG: Mevcut ürün kuru kullanıldı: ${existingItem.fxRateToBase}');
                          } else {
                            // Aynı para birimindeki ürün yoksa, kur bilgisini göster
                            setState(() => _showExchangeRate = true);
                            debugPrint(
                                'DEBUG: Kur bilgisi gösterildi - farklı para birimi');

                            // Otomatik kur getirme
                            try {
                              await ExchangeRateService().getExchangeRate(v);
                              final r = ExchangeRateService().convertCurrency(
                                  1.0, v, widget.baseCurrencyCode);
                              setState(() {
                                _fxRateToTry = r;
                                // Manuel kur alanını da otomatik doldur
                                _manualRateController.text = _formatTrNumber(r);
                              });
                              debugPrint('DEBUG: Otomatik kur alındı: $r');
                            } catch (e) {
                              debugPrint('Otomatik kur alma hatası: $e');
                              setState(() => _fxRateToTry = null);
                            }
                          }
                        } else {
                          // Ürünün para birimi müşterinin para birimiyle aynıysa kur bilgisi gizle
                          setState(() {
                            _showExchangeRate = false;
                            _fxRateToTry = null;
                            _manualRateController.clear();
                          });
                          debugPrint(
                              'DEBUG: Kur bilgisi gizlendi - aynı para birimi');
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ] else ...[
              // Aynı para birimi kullanılıyor, bilgi göster
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.blue.shade900.withValues(alpha: 0.3)
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: isDark ? Colors.blue.shade700 : Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color:
                          isDark ? Colors.blue.shade300 : Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Para birimi: $_lineCurrencyCode (İlk ürünün kur bilgisi kullanılıyor)',
                        style: TextStyle(
                          color: isDark
                              ? Colors.blue.shade200
                              : Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
            ],
            Row(
              children: [
                const SizedBox(width: 16.0),
                Expanded(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        final raw = _unitPriceController.text.trim();
                        if (raw.isEmpty) return;
                        final cleaned =
                            raw.replaceAll('.', '').replaceAll(',', '.');
                        final parsed = double.tryParse(cleaned);
                        if (parsed != null) {
                          _unitPriceController.text = _formatTrCurrency(parsed);
                        }
                      }
                    },
                    child: TextFormField(
                      controller: _unitPriceController,
                      decoration: InputDecoration(
                        labelText: 'Birim Fiyat ($_lineCurrencyCode)',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Birim fiyat gerekli';
                        }
                        final cleaned =
                            value.replaceAll('.', '').replaceAll(',', '.');
                        final parsed = double.tryParse(cleaned);
                        if (parsed == null || parsed < 0) {
                          return 'Geçerli fiyat giriniz';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (_showExchangeRate &&
                _productCurrencyCode != widget.baseCurrencyCode)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _manualRateController,
                      decoration: InputDecoration(
                        labelText:
                            'Kur (1 $_lineCurrencyCode = ? ${widget.baseCurrencyCode})',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      onChanged: (value) {
                        // Kullanıcı kur bilgisini girdiğinde _fxRateToTry'ı güncelle
                        if (value.isNotEmpty) {
                          final cleaned =
                              value.replaceAll('.', '').replaceAll(',', '.');
                          final parsed = double.tryParse(cleaned);
                          if (parsed != null) {
                            setState(() {
                              _fxRateToTry = parsed;
                            });
                            debugPrint(
                                'DEBUG: Manuel kur girildi - _fxRateToTry: $_fxRateToTry');
                          }
                        } else {
                          setState(() {
                            _fxRateToTry = null;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Miktar',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Miktar gerekli';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Geçerli miktar giriniz';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _discountRateController,
                    decoration: const InputDecoration(
                      labelText: 'İskonto (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        final raw = _taxRateController.text.trim();
                        if (raw.isEmpty) return;
                        final parsed = double.tryParse(
                            raw.replaceAll('.', '').replaceAll(',', '.'));
                        if (parsed != null) {
                          _taxRateController.text = _formatTrNumber(parsed);
                        }
                      }
                    },
                    child: TextFormField(
                      controller: _taxRateController,
                      decoration: const InputDecoration(
                        labelText: 'KDV (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _productDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: _addItem,
          child: const Text('Ekle'),
        ),
      ],
    );
  }

  void _addItem() {
    debugPrint('_addItem çağrıldı');

    // Form validation'ı atla, manuel kontrol yap
    if (_quantityController.text.isEmpty) {
      debugPrint('Miktar boş');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Miktar gerekli')),
      );
      return;
    }

    if (_unitPriceController.text.isEmpty) {
      debugPrint('Birim fiyat boş');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Birim fiyat gerekli')),
      );
      return;
    }

    // Ürün seçilmiş mi kontrol et
    debugPrint('Ürün ID: ${_productIdController.text}');
    if (_productIdController.text.isEmpty) {
      debugPrint('Ürün seçilmemiş');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir ürün seçiniz')),
      );
      return;
    }

    final quantity = double.parse(_quantityController.text);
    final unitPrice = double.parse(
        _unitPriceController.text.replaceAll('.', '').replaceAll(',', '.'));

    // unitPrice'ı orijinal para biriminde tut (USD ise USD olarak)
    final discountRate = double.tryParse(_discountRateController.text) ?? 0.0;
    final taxRate = double.tryParse(_taxRateController.text) ?? 0.0;

    // Hesaplamaları orijinal para biriminde yap
    final gross = quantity * unitPrice;

    // İskonto hesaplama: Kullanıcının girdiği oranı kullan (müşteri sabit iskontosu otomatik doldurulmuş olabilir)
    debugPrint(
        'DEBUG: _addItem - discountRate: $discountRate, _customerDiscountRate: $_customerDiscountRate');
    final double finalDiscountAmount = gross * (discountRate / 100);

    final net = gross - finalDiscountAmount;
    final taxAmount = net * (taxRate / 100);
    final totalAmount = net + taxAmount;

    // Null kontrolü
    if (taxRate.isNaN || taxAmount.isNaN || totalAmount.isNaN) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hesaplama hatası oluştu')),
      );
      return;
    }

    final item = _PurchaseItemForm();
    item.productId = _productIdController.text;
    item.productName = _productNameController.text;
    item.quantity = quantity;
    item.unitPrice = unitPrice;
    item.discountRate = discountRate;
    item.discountAmount = finalDiscountAmount;
    item.taxRate = taxRate;
    item.currency = _lineCurrencyCode;
    item.fxRateToBase =
        _fxRateToTry; // Ürün eklerken girilen kur bilgisini aktar

    // Debug: İskonto bilgilerini yazdır
    debugPrint(
        'DEBUG: İskonto hesaplama - Gross: $gross, DiscountRate: $discountRate, FinalDiscountAmount: $finalDiscountAmount');

    // Debug: Kur bilgisini yazdır
    debugPrint(
        'DEBUG: Kur bilgisi aktarıldı - fxRateToBase: ${item.fxRateToBase}, currency: ${item.currency}');

    // Controller'ları güncelle
    item.quantityController.text = quantity.toString();
    item.unitPriceController.text = unitPrice.toString();
    item.taxRateController.text = taxRate.toString();

    // Ürün hafızaya kaydet
    if (_currentProductId != null) {
      _saveProductMemory(_currentProductId!);
    }

    widget.onAdd(item);
    Navigator.of(context).pop();
  }

  String _formatTrCurrency(double value) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return formatter.format(value);
  }

  String _formatTrNumber(double value) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return formatter.format(value);
  }
}

// Product Quick Picker (satış modülünden kopyalandı)
class _ProductQuickPicker extends ConsumerStatefulWidget {
  final void Function(
    String id,
    String? name,
    double? price,
    double? taxRate,
    String salesCurrency, {
    double? originalPrice,
    double? customerDiscountRate,
  }) onSelected;
  final String? customerId;
  final PurchaseType purchaseType;

  const _ProductQuickPicker({
    required this.onSelected,
    this.customerId,
    required this.purchaseType,
  });

  @override
  ConsumerState<_ProductQuickPicker> createState() =>
      _ProductQuickPickerState();
}

class _ProductQuickPickerState extends ConsumerState<_ProductQuickPicker> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    return productsAsync.when(
      data: (products) {
        return RawAutocomplete<Product>(
          optionsBuilder: (TextEditingValue tev) {
            final q = tev.text.trim().toLowerCase();
            if (q.isEmpty) return const Iterable.empty();
            // In-memory filtreleme: isim, kod, barkod
            return products.where((p) {
              final name = p.name.toLowerCase();
              final code = (p.productCode ?? '').toLowerCase();
              final sku = (p.sku ?? '').toLowerCase();
              final barcode = (p.barcode ?? '').toLowerCase();
              return name.contains(q) ||
                  code.contains(q) ||
                  sku.contains(q) ||
                  barcode.contains(q);
            });
          },
          displayStringForOption: (Product p) {
            return p.name;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Ürün Kodu/Adı (Hızlı Seçim)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                color: isDark ? Colors.grey[850] : Colors.white,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final product = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(
                          product.name,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Kod: ${product.productCode ?? 'N/A'} | SKU: ${product.sku ?? 'N/A'}',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        trailing: Text(
                          CurrencyHelper.formatCurrency(
                            widget.purchaseType == PurchaseType.purchase
                                ? (product.purchasePrice ?? 0.0)
                                : (product.salesPrice),
                            widget.purchaseType == PurchaseType.purchase
                                ? (product.purchaseCurrency ?? 'TRY')
                                : (product.salesCurrency),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        onTap: () async {
                          onSelected(product);

                          // Alış türüne göre fiyat seçimi
                          double? originalPrice;
                          double? finalPrice;
                          String? currency;

                          if (widget.purchaseType == PurchaseType.purchase) {
                            // Normal Alış: Alış fiyatı kullan
                            // Eğer ürün KDV dahil ise, KDV hariç fiyatı kullan
                            // Çünkü alış sayfasında KDV tekrar eklenecek
                            final basePrice = product.purchaseTaxInclusive ==
                                    TaxInclusiveOption.inclusive
                                ? (product.purchasePriceWithoutTax ??
                                    product.purchasePrice ??
                                    0.0)
                                : (product.purchasePrice ?? 0.0);
                            originalPrice = basePrice;
                            finalPrice = basePrice;
                            currency = product.purchaseCurrency ?? 'TRY';
                          } else {
                            // İade Alışı: Satış fiyatı kullan
                            // Eğer ürün KDV dahil ise, KDV hariç fiyatı kullan
                            // Çünkü alış sayfasında KDV tekrar eklenecek
                            final basePrice = product.salesTaxInclusive ==
                                    TaxInclusiveOption.inclusive
                                ? product.salesPriceWithoutTax
                                : product.salesPrice;
                            originalPrice = basePrice;
                            finalPrice = basePrice;
                            currency = product.salesCurrency;
                          }
                          double customerDiscountRate = 0.0;

                          // Müşteri seçiliyse sabit iskonto uygula
                          if (widget.customerId != null &&
                              widget.customerId!.isNotEmpty) {
                            try {
                              debugPrint(
                                  'DEBUG: Müşteri ID: ${widget.customerId}');
                              final customer = await ref.read(
                                  customerProvider(widget.customerId!).future);
                              debugPrint('DEBUG: Müşteri bilgisi: $customer');
                              if (customer != null &&
                                  customer.fixedDiscountRate != null &&
                                  customer.fixedDiscountRate! > 0) {
                                customerDiscountRate =
                                    customer.fixedDiscountRate!;
                                finalPrice = originalPrice *
                                    (1 - customerDiscountRate / 100);
                                debugPrint(
                                    'DEBUG: Müşteri sabit iskontosu uygulandı: $customerDiscountRate');
                              } else {
                                debugPrint(
                                    'DEBUG: Müşteri sabit iskontosu yok: ${customer?.fixedDiscountRate}');
                              }
                            } catch (e) {
                              debugPrint(
                                  'DEBUG: Müşteri bilgisi alınamadı: $e');
                            }
                          } else {
                            debugPrint(
                                'DEBUG: Müşteri ID yok: ${widget.customerId}');
                          }

                          widget.onSelected(
                            product.id,
                            product.name,
                            finalPrice,
                            product.salesTaxRate,
                            currency,
                            originalPrice: originalPrice,
                            customerDiscountRate: customerDiscountRate,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Ürünler yüklenemedi: $error'),
    );
  }
}
