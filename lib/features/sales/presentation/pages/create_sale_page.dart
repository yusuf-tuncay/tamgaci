// ignore_for_file: unused_field
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/features/sales/presentation/providers/sale_providers.dart';
import 'package:tamgaci/features/customers/presentation/providers/customer_providers.dart';
import 'package:flutter/services.dart';
import 'package:tamgaci/features/products/presentation/providers/product_providers.dart';
import 'package:tamgaci/features/products/domain/entities/product.dart';
import 'package:tamgaci/features/customers/domain/entities/customer_branch.dart';
import 'package:tamgaci/core/routes/routes.dart';
import 'package:tamgaci/core/services/business/inventory_service.dart';
import 'package:tamgaci/features/inventory/presentation/providers/warehouse_providers.dart';
import 'package:tamgaci/features/settings/presentation/providers/settings_providers.dart';
import 'package:tamgaci/core/services/utils/exchange_rate_service.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:tamgaci/core/services/business/transaction_service.dart';
import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart'
    as cm;
import 'package:tamgaci/features/cash_management/presentation/providers/cash_management_providers.dart';
// import 'package:tamgaci/features/sales/presentation/widgets/sale_form_widget.dart';
// import 'package:tamgaci/core/theme/app_theme.dart';
import 'package:tamgaci/core/widgets/loading_widget.dart';
import 'package:tamgaci/core/widgets/error_widget.dart' as core_widgets;
import 'package:tamgaci/features/sales/presentation/states/sale_state.dart';

/// Yeni satış oluşturma sayfası
class CreateSalePage extends ConsumerStatefulWidget {
  final String? saleId; // Düzenleme için

  const CreateSalePage({
    super.key,
    this.saleId,
  });

  @override
  ConsumerState<CreateSalePage> createState() => _CreateSalePageState();
}

class _CreateSalePageState extends ConsumerState<CreateSalePage> {
  final _formKey = GlobalKey<FormState>();
  final _saleNumberController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _notesController = TextEditingController();

  SaleType _selectedType = SaleType.invoice;
  SaleStatus _selectedStatus = SaleStatus.draft;
  PaymentStatus _selectedPaymentStatus = PaymentStatus.pending;
  // Payment UI state
  String _paymentMethod =
      'Nakit'; // Ödeme Şekli: Nakit, Banka, Kredi Kartı, Çek, Senet
  bool _isCashPayment = true; // Peşin/Vadeli toggle
  int? _installmentCount;
  String _paymentCurrencyCode = 'TRY';
  final TextEditingController _paymentFxController = TextEditingController();

  // Addresses
  String? _billingAddress;
  String? _shippingAddress;

  double _customerDefaultDiscountRate = 0.0;
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  List<SaleItem> _items = [];
  double _discountAmount = 0.0;
  double _taxRate = 18.0;
  String? _selectedWarehouseId;
  final _interestRateController = TextEditingController();
  List<_InstallmentItem> _installments = [];
  String _infoCurrencyCode = 'TRY';
  String _baseCurrencyCode = 'TRY';
  int _moneyDecimals = 2;
  String _roundMode = 'halfUp'; // halfUp|floor|ceil

  bool get _hasSelectedCustomer => _customerIdController.text.isNotEmpty;
  static const String _kNewAddressValue = '__NEW_ADDRESS__';

  @override
  void initState() {
    super.initState();
    if (widget.saleId != null) {
      _loadSale();
    }
    _initSaleNumber();
    // Varsayılan KDV oranını ve şirket para birimini ayarlardan çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      settings.whenData((s) {
        final defaultTax = double.tryParse(
              (s.customSettings['defaultTaxRate']?.toString() ?? '18'),
            ) ??
            18;
        final appCurrency = s.currency.name.toUpperCase() == 'TRY'
            ? 'TRY'
            : s.currency.name.toUpperCase();
        final dec = int.tryParse(
              (s.customSettings['roundingDecimals']?.toString() ?? '2'),
            ) ??
            2;
        final mode = (s.customSettings['roundingMode']?.toString() ?? 'halfUp')
            .toLowerCase();
        setState(() {
          _taxRate = defaultTax;
          _baseCurrencyCode = appCurrency;
          _moneyDecimals = dec.clamp(0, 6);
          _roundMode =
              ['halfup', 'floor', 'ceil'].contains(mode) ? mode : 'halfup';
          _paymentCurrencyCode = _paymentCurrencyCode.isNotEmpty
              ? _paymentCurrencyCode
              : appCurrency;
        });
      });
    });
    // Eğer route ile müşteri bilgisi geldiyse doldur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final cid = args['customerId'] as String?;
        final cname = args['customerName'] as String?;
        if (cid != null) {
          _customerIdController.text = cid;
          _loadCustomer(cid);
        }
        if (cname != null) {
          _customerNameController.text = cname;
        }
      }
    });
    // Varsayılan depo seçimi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final warehousesAsync = ref.read(warehousesProvider);
      warehousesAsync.whenData((warehouses) {
        if (_selectedWarehouseId == null && warehouses.isNotEmpty) {
          final def = warehouses.firstWhere(
            (w) => w.isDefault,
            orElse: () => warehouses.first,
          );
          setState(() => _selectedWarehouseId = def.id);
        }
      });
    });
  }

  @override
  void dispose() {
    _saleNumberController.dispose();
    _customerIdController.dispose();
    _customerNameController.dispose();
    _notesController.dispose();
    _interestRateController.dispose();
    _paymentFxController.dispose();
    super.dispose();
  }

  Widget _buildPaymentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ödeme / Tahsilat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _isCashPayment ? 'Peşin' : 'Vadeli',
                    items: const [
                      DropdownMenuItem(value: 'Peşin', child: Text('Peşin')),
                      DropdownMenuItem(value: 'Vadeli', child: Text('Vadeli')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Ödeme Tipi',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      setState(() {
                        _isCashPayment = v == 'Peşin';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _paymentMethod,
                    items: const [
                      DropdownMenuItem(value: 'Nakit', child: Text('Nakit')),
                      DropdownMenuItem(value: 'Banka', child: Text('Banka')),
                      DropdownMenuItem(
                          value: 'Kredi Kartı', child: Text('Kredi Kartı')),
                      DropdownMenuItem(value: 'Çek', child: Text('Çek')),
                      DropdownMenuItem(value: 'Senet', child: Text('Senet')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Ödeme Şekli',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _paymentMethod = v;
                      });
                    },
                  ),
                ),
                // Payment currency and FX moved below on a separate line to avoid overflow
              ],
            ),
            const SizedBox(height: 12),
            Consumer(builder: (context, ref, _) {
              final settingsAsync = ref.watch(settingsProvider);
              return settingsAsync.when(
                data: (s) {
                  final appCcy = s.currency.name.toUpperCase() == 'TRY'
                      ? 'TRY'
                      : s.currency.name.toUpperCase();
                  final options = <String>['TRY', 'USD', 'EUR', 'GBP'];
                  if (!options.contains(appCcy)) options.add(appCcy);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _paymentCurrencyCode.isNotEmpty
                            ? _paymentCurrencyCode
                            : appCcy,
                        decoration: const InputDecoration(
                          labelText: 'Ödeme Para Birimi',
                          border: OutlineInputBorder(),
                        ),
                        items: options
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child:
                                      Text(c, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _paymentCurrencyCode = v);
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_paymentCurrencyCode != 'TRY')
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _paymentFxController,
                                decoration: InputDecoration(
                                  labelText:
                                      'Kur (1 $_paymentCurrencyCode = ? TRY)',
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.,]')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final rate = await ExchangeRateService()
                                        .getExchangeRate(_paymentCurrencyCode);
                                    if (rate != null) {
                                      setState(() {
                                        _paymentFxController.text =
                                            rate.rate.toStringAsFixed(4);
                                      });
                                    }
                                  },
                                  child: const Text('Kuru Getir'),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            }),
            if (!_isCashPayment) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDueDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Vade Tarihi',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_dueDate != null
                            ? _formatDate(_dueDate!)
                            : 'Seçiniz'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Taksit Sayısı (opsiyonel)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _installmentCount = int.tryParse(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _interestRateController,
                      decoration: const InputDecoration(
                        labelText: 'Aylık Faiz (%) (opsiyonel)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _calculateInstallmentPlan,
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Planı Hesapla'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_installments.isNotEmpty) ...[
                const Text('Taksit Planı',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _installments.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final it = _installments[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                          '${index + 1}. Taksit - ${_formatDate(it.dueDate)}'),
                      trailing: Text(_formatMoney(it.amount)),
                      subtitle: Text(
                          'Anapara: ${_formatMoney(it.principal)} • Faiz: ${_formatMoney(it.interestAmount)}'),
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _loadSale() {
    if (widget.saleId != null) {
      ref.read(saleNotifierProvider.notifier).getSale(widget.saleId!);
    }
  }

  Future<void> _loadCustomer(String customerId) async {
    try {
      final customers = await ref.read(customersProvider.future);
      final customer = customers.firstWhere((c) => c.id == customerId);
      setState(() {
        _customerNameController.text = customer.name;
        _customerDefaultDiscountRate = customer.fixedDiscountRate ?? 0.0;
        _billingAddress = customer.address;
        _shippingAddress = customer.shippingAddress ?? customer.address;
        if ((customer.customerCurrency ?? '').isNotEmpty) {
          _infoCurrencyCode =
              (customer.customerCurrency ?? 'TRY').toUpperCase();
        }
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final saleState = ref.watch(saleNotifierProvider);
    final isEditing = widget.saleId != null;

    // Düzenleme modunda ve satış yüklendiyse formu doldur
    if (isEditing && saleState.selectedSale != null) {
      final sale = saleState.selectedSale!;
      _saleNumberController.text = sale.saleNumber;
      _customerIdController.text = sale.customerId;
      _customerNameController.text = sale.customerName ?? '';
      _notesController.text = sale.notes ?? '';
      _selectedType = sale.type;
      _selectedStatus = sale.status;
      _selectedPaymentStatus = sale.paymentStatus;
      _selectedDate = sale.saleDate;
      _dueDate = sale.dueDate;
      _items = List.from(sale.items);
      _discountAmount = sale.discountAmount;
      _taxRate = sale.taxRate;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Satış Düzenle' : 'Yeni Satış'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteDialog,
              tooltip: 'Sil',
            ),
        ],
      ),
      body: _buildBody(saleState),
    );
  }

  Widget _buildBody(SaleState state) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.error != null) {
      return core_widgets.ErrorWidget(
        error: state.error!,
        onRetry: _loadSale,
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16.0),
                  _buildBasicInfoCard(),
                  const SizedBox(height: 16.0),
                  _buildItemsCard(),
                  const SizedBox(height: 16.0),
                  _buildPaymentCard(),
                  const SizedBox(height: 16.0),
                  _buildSummaryCard(),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Satış',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _customerNameController.text.isNotEmpty
                        ? _customerNameController.text
                        : 'Müşteri seçiniz',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickCustomer,
                        icon: const Icon(Icons.person_search),
                        label: Text(_hasSelectedCustomer
                            ? 'Müşteri Değiştir'
                            : 'Müşteri Seç'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _createNewCustomer,
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Yeni Müşteri'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<SaleType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'İşlem Türü',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  SaleType.invoice,
                  SaleType.waybill,
                  SaleType.proforma
                ]
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temel Bilgiler',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            // Depo seçimi
            Consumer(builder: (context, ref, _) {
              final warehousesAsync = ref.watch(activeWarehousesProvider);
              return warehousesAsync.when(
                data: (warehouses) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedWarehouseId ??
                        (warehouses.isNotEmpty ? warehouses.first.id : null),
                    decoration: const InputDecoration(
                      labelText: 'Depo',
                      border: OutlineInputBorder(),
                    ),
                    items: warehouses
                        .map((w) => DropdownMenuItem<String>(
                              value: w.id,
                              child: Text(w.code != null && w.code!.isNotEmpty 
                                  ? '${w.name} (${w.code})' 
                                  : w.name),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedWarehouseId = v),
                  );
                },
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (e, _) => Text('Depolar yüklenemedi: $e'),
              );
            }),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _saleNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Satış Numarası',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Satış numarası gerekli';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    controller: _customerIdController,
                    decoration: const InputDecoration(
                      labelText: 'Müşteri ID',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Müşteri ID gerekli';
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
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Müşteri Adı',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    menuMaxHeight: 320,
                    initialValue: _billingAddress,
                    decoration: const InputDecoration(
                      labelText: 'Fatura Adresi',
                      border: OutlineInputBorder(),
                    ),
                    items: _buildAddressItems(isBilling: true),
                    onChanged: (v) async {
                      if (v == _kNewAddressValue) {
                        await _showAddAddressDialog(isBilling: true);
                        return;
                      }
                      setState(() => _billingAddress = v);
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    menuMaxHeight: 320,
                    initialValue: _shippingAddress,
                    decoration: const InputDecoration(
                      labelText: 'Sevk Adresi',
                      border: OutlineInputBorder(),
                    ),
                    items: _buildAddressItems(isBilling: false),
                    onChanged: (v) async {
                      if (v == _kNewAddressValue) {
                        await _showAddAddressDialog(isBilling: false);
                        return;
                      }
                      setState(() => _shippingAddress = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<SaleStatus>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Durum',
                      border: OutlineInputBorder(),
                    ),
                    items: SaleStatus.values.map((status) {
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
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Satış Tarihi',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_formatDate(_selectedDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: InkWell(
                    onTap: _selectDueDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Vade Tarihi',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_dueDate != null
                          ? _formatDate(_dueDate!)
                          : 'Seçiniz'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notlar',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

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
                  'Satış Ürünleri',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Ürün Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            if (_items.isEmpty)
              const Center(
                child: Text(
                  'Henüz ürün eklenmedi',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1.0),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    title: Text(item.productName ?? item.productId),
                    subtitle: Text(
                        '${item.quantity} ${item.productSku ?? ''} • Birim: ${_formatMoney(item.unitPrice)} • KDV: %${item.taxRate.toStringAsFixed(0)} • İsk: %${item.discountRate.toStringAsFixed(0)}'),
                    trailing: Text(_formatMoney(item.totalAmount)),
                    onTap: () => _removeItem(index),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final gross =
        _items.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
    final totalDiscount =
        _items.fold(0.0, (sum, item) => sum + item.discountAmount);
    final subtotal = gross - totalDiscount;
    final taxAmount = _items.fold(0.0, (sum, item) => sum + item.taxAmount);
    final total = subtotal + taxAmount - _discountAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Özet',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ara Toplam (İskonto sonrası):',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _formatMoney(subtotal),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Toplam KDV:',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _formatMoney(taxAmount),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ek İndirim:',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _formatMoney(_discountAmount),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const Divider(),
            Consumer(builder: (context, ref, _) {
              final settingsAsync = ref.watch(settingsProvider);
              return settingsAsync.when(
                data: (s) {
                  final code = s.currency.name.toUpperCase() == 'TRY'
                      ? 'TRY'
                      : s.currency.name.toUpperCase();
                  if (code == 'TRY') return const SizedBox.shrink();
                  return FutureBuilder<ExchangeRate?>(
                    future: ExchangeRateService().getExchangeRate(code),
                    builder: (context, snap) {
                      final rate = snap.data;
                      if (rate == null) return const SizedBox.shrink();
                      final totalInFx = ExchangeRateService()
                          .convertCurrency(total, 'TRY', rate.code);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Toplam (${rate.code}):'),
                              Text(
                                  '${rate.symbol}${_formatMoney(totalInFx, currency: code)}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kur: 1 ${rate.code} = ${rate.rate.toStringAsFixed(4)} TRY',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            }),
            Builder(builder: (context) {
              if (_paymentCurrencyCode == 'TRY') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Toplam:',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatMoney(total, currency: _baseCurrencyCode),
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }

              // Ödeme para birimi seçilmiş -> Toplamı ödeme para birimine çevir
              double? manual;
              if (_paymentFxController.text.trim().isNotEmpty) {
                manual = double.tryParse(_paymentFxController.text
                    .replaceAll('.', '')
                    .replaceAll(',', '.'));
              }

              if (manual != null && manual > 0) {
                final payAmount = total / manual; // TRY -> PAY
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Toplam ($_paymentCurrencyCode):',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            _formatMoney(payAmount,
                                currency: _paymentCurrencyCode),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      () {
                        final baseVal = _baseCurrencyCode == 'TRY'
                            ? total
                            : ExchangeRateService().convertCurrency(
                                total, 'TRY', _baseCurrencyCode);
                        final m = manual ?? 0.0;
                        final mTxt = m > 0 ? m.toStringAsFixed(4) : '—';
                        return '≈ ${_formatMoney(baseVal, currency: _baseCurrencyCode)}  •  Kur: 1 $_paymentCurrencyCode = $mTxt TRY';
                      }(),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }

              // Manuel yoksa otomatik kurla göster
              return FutureBuilder<ExchangeRate?>(
                future:
                    ExchangeRateService().getExchangeRate(_paymentCurrencyCode),
                builder: (context, snap) {
                  final rate = snap.data;
                  if (rate == null || rate.rate <= 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Toplam ($_paymentCurrencyCode):',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('—')
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Kur yükleniyor...',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                      ],
                    );
                  }
                  final payAmount = total / rate.rate; // TRY -> PAY
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Toplam ($_paymentCurrencyCode):',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              _formatMoney(payAmount,
                                  currency: _paymentCurrencyCode),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        () {
                          final baseVal = _baseCurrencyCode == 'TRY'
                              ? total
                              : ExchangeRateService().convertCurrency(
                                  total, 'TRY', _baseCurrencyCode);
                          return '≈ ${_formatMoney(baseVal, currency: _baseCurrencyCode)}  •  Kur: 1 ${rate.code} = ${rate.rate.toStringAsFixed(4)} TRY';
                        }(),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              );
            }),
            // Bilgi amaçlı çapraz para birimi gösterimleri
            Consumer(builder: (context, ref, _) {
              final settingsAsync = ref.watch(settingsProvider);
              return settingsAsync.when(
                data: (s) {
                  // Uygulama varsayılan para birimi
                  final appCurrency = s.currency.name.toUpperCase() == 'TRY'
                      ? 'TRY'
                      : s.currency.name.toUpperCase();

                  // Müşterinin varsayılan para birimi (müşteri yüklenmişse)
                  final customerId = _customerIdController.text;
                  return FutureBuilder<String?>(
                    future: customerId.isEmpty
                        ? Future<String?>.value(null)
                        : ref.read(customerProvider(customerId)).maybeWhen(
                              data: (c) =>
                                  Future<String?>.value(c?.customerCurrency),
                              orElse: () => Future<String?>.value(null),
                            ),
                    builder: (context, snapCcy) {
                      final customerCurrency =
                          (snapCcy.data ?? '').toUpperCase();
                      // Case A: Uygulama TRY, müşteri farklı (örn. USD)
                      // Case B: Uygulama USD, müşteri TRY veya farklı
                      final fxCode = customerCurrency.isNotEmpty
                          ? customerCurrency
                          : appCurrency;
                      if (fxCode.isEmpty || fxCode == 'TRY') {
                        return const SizedBox.shrink();
                      }
                      return FutureBuilder<ExchangeRate?>(
                        future: ExchangeRateService().getExchangeRate(fxCode),
                        builder: (context, snapRate) {
                          final rate = snapRate.data;
                          if (rate == null) return const SizedBox.shrink();
                          // App currency → TRY bazlı; toplamı müşteri/app dövizine çevirip bilgi olarak göster
                          final toAppFx = ExchangeRateService()
                              .convertCurrency(total, 'TRY', appCurrency);
                          final toCustomerFx = ExchangeRateService()
                              .convertCurrency(total, 'TRY', rate.code);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (appCurrency != 'TRY')
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Toplam ($appCurrency):'),
                                    Text(_formatMoney(toAppFx,
                                        currency: appCurrency)),
                                  ],
                                ),
                              if (customerCurrency.isNotEmpty &&
                                  customerCurrency != 'TRY')
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Toplam (${rate.code}) (müşteri bazlı):'),
                                    Text(
                                        '${rate.symbol}${_formatMoney(toCustomerFx, currency: rate.code)}'),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              Text(
                                'Kur: 1 ${rate.code} = ${rate.rate.toStringAsFixed(4)} TRY',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: OutlinedButton(
              onPressed: _saveSaleDraft,
              child: const Text('Taslak Kaydet'),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveSale,
              child: Text(widget.saleId != null ? 'Güncelle' : 'Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _selectedDate,
      firstDate: _selectedDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  void _addItem() {
    // Başlıktaki zorunlu alanlar boşsa uyarı ver
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
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _saveSale() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir ürün eklemelisiniz')),
      );
      return;
    }

    // Depo otomatik seçimi (yoksa)
    if (_selectedWarehouseId == null) {
      final warehousesAsync = ref.read(warehousesProvider);
      warehousesAsync.whenData((warehouses) {
        if (warehouses.isNotEmpty) {
          final def = warehouses.firstWhere(
            (w) => w.isDefault,
            orElse: () => warehouses.first,
          );
          _selectedWarehouseId = def.id;
        }
      });
      if (_selectedWarehouseId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir depo seçiniz')),
        );
        return;
      }
    }

    final subtotalTry = _items.fold(0.0, (sum, item) => sum + item.totalAmount);
    final taxAmountTry = subtotalTry * (_taxRate / 100);
    final totalTry = subtotalTry + taxAmountTry - _discountAmount;

    // Şirket para birimine çevir
    double totalBase = totalTry;
    if (_baseCurrencyCode != 'TRY') {
      // Rates'i hazırla ve dönüştür
      await ExchangeRateService().getExchangeRate(_baseCurrencyCode);
      totalBase = ExchangeRateService()
          .convertCurrency(totalTry, 'TRY', _baseCurrencyCode);
    }

    final autoPaymentStatus =
        _isCashPayment ? PaymentStatus.paid : PaymentStatus.pending;

    final sale = Sale(
      id: widget.saleId ?? '',
      saleNumber: _saleNumberController.text,
      customerId: _customerIdController.text,
      customerName: _customerNameController.text.isNotEmpty
          ? _customerNameController.text
          : null,
      type: _selectedType,
      status: _selectedStatus,
      paymentStatus: autoPaymentStatus,
      saleDate: _selectedDate,
      dueDate: _dueDate,
      items: _items,
      subtotal: _baseCurrencyCode == 'TRY'
          ? subtotalTry
          : ExchangeRateService()
              .convertCurrency(subtotalTry, 'TRY', _baseCurrencyCode),
      taxRate: _taxRate,
      taxAmount: _baseCurrencyCode == 'TRY'
          ? taxAmountTry
          : ExchangeRateService()
              .convertCurrency(taxAmountTry, 'TRY', _baseCurrencyCode),
      discountAmount: _baseCurrencyCode == 'TRY'
          ? _discountAmount
          : ExchangeRateService()
              .convertCurrency(_discountAmount, 'TRY', _baseCurrencyCode),
      totalAmount: totalBase,
      currency: _baseCurrencyCode,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final notifier = ref.read(saleNotifierProvider.notifier);
    final inventory = InventoryService();
    Future<void> afterSave(String saleId) async {
      // Stok hareketleri (taslak dışında)
      for (final item in _items) {
        final movement = StockMovement(
          id: '',
          productId: item.productId,
          warehouseId: _selectedWarehouseId!,
          type: StockMovementType.stockOut,
          quantity: item.quantity.round(),
          reason: 'Satış',
          reference: saleId,
          notes: 'Satış hareketi',
          createdBy: 'system',
          createdAt: DateTime.now(),
        );
        await inventory.recordStockMovement(movement);
      }

      // Ekstre ve müşteri bakiyesi için fatura işlemi kaydı (şirket para biriminde)
      try {
        final transactionService = TransactionService();
        final now = DateTime.now();
        final t = Transaction(
          id: '',
          customerId: _customerIdController.text,
          supplierId: null,
          type: TransactionType.invoice,
          amount: totalBase,
          currency: _baseCurrencyCode,
          description: 'Satış faturası',
          reference: _saleNumberController.text,
          transactionDate: now,
          dueDate: _dueDate,
          invoiceId: saleId,
          paymentMethod: _paymentMethod,
          documentNumber: _saleNumberController.text,
          status: TransactionStatus.completed,
          companyId: '',
          createdAt: now,
          updatedAt: now,
          createdBy: 'system',
          updatedBy: null,
          metadata: {
            'totalTry': totalTry,
            'baseCurrency': _baseCurrencyCode,
            'paymentCurrency': _paymentCurrencyCode,
          },
        );
        await transactionService.createTransaction(t);
      } catch (_) {}

      // Peşin ödemeyse: müşteri ekstresine payment ve nakit yönetime kasa geliri
      if (_isCashPayment) {
        double fxRate = 1.0;
        if (_paymentCurrencyCode != _baseCurrencyCode) {
          final manualText = _paymentFxController.text.trim();
          final manual = manualText.isNotEmpty
              ? double.tryParse(
                  manualText.replaceAll('.', '').replaceAll(',', '.'))
              : null;
          if (manual != null && manual > 0) {
            fxRate = manual;
          } else {
            await ExchangeRateService().getExchangeRate(_paymentCurrencyCode);
            final amt = ExchangeRateService()
                .convertCurrency(1.0, _paymentCurrencyCode, _baseCurrencyCode);
            fxRate = amt > 0 ? amt : 1.0;
          }
        }

        final transactionService = TransactionService();
        final now = DateTime.now();
        final customerId = _customerIdController.text;

        // 1) Müşteri ekstresi ödeme işlemi (base para birimi)
        try {
          final payTxn = Transaction(
            id: '',
            customerId: customerId,
            supplierId: null,
            type: TransactionType.payment,
            amount: totalBase, // defter base currency
            currency: _baseCurrencyCode,
            description: 'Satış tahsilatı ($_paymentCurrencyCode)',
            reference: _saleNumberController.text,
            transactionDate: now,
            dueDate: null,
            invoiceId: saleId,
            paymentMethod: _paymentMethod,
            documentNumber: _saleNumberController.text,
            status: TransactionStatus.completed,
            companyId: '',
            createdAt: now,
            updatedAt: now,
            createdBy: 'system',
            updatedBy: null,
            metadata: {
              'paymentCurrency': _paymentCurrencyCode,
              'paymentFxToBase': fxRate,
              'paymentAmountInPaymentCcy':
                  _paymentCurrencyCode == _baseCurrencyCode
                      ? totalBase
                      : (fxRate > 0 ? (totalBase / fxRate) : totalBase),
              'baseCurrency': _baseCurrencyCode,
            },
          );
          await transactionService.createTransaction(payTxn);
        } catch (_) {}

        // 2) Nakit yönetimi: uygun kasayı bul ve gelir işlemi oluştur
        try {
          // Kasaları çek
          final notifier = ref.read(cashManagementNotifierProvider.notifier);
          await notifier.getCashAccounts();
          final state = ref.read(cashManagementNotifierProvider);
          final accounts = state.cashAccounts;
          // Öncelik: ödeme para birimi ile aynı olan kasa → yoksa base para birimli kasa
          final target = accounts.firstWhere(
            (a) =>
                a.currency.toUpperCase() == _paymentCurrencyCode.toUpperCase(),
            orElse: () => accounts.firstWhere(
              (a) =>
                  a.currency.toUpperCase() == _baseCurrencyCode.toUpperCase(),
              orElse: () => accounts.isNotEmpty
                  ? accounts.first
                  : throw Exception('Kasa bulunamadı'),
            ),
          );

          final amountInAccountCurrency = target.currency.toUpperCase() ==
                  _paymentCurrencyCode.toUpperCase()
              ? (fxRate > 0 ? (totalBase / fxRate) : totalBase)
              : totalBase;

          final useCase = ref.read(createCashTransactionUseCaseProvider);
          final trx = cm.CashTransaction(
            id: '',
            transactionNumber: '',
            type: cm.CashTransactionType.income,
            category: cm.CashTransactionCategory.sales,
            status: cm.CashTransactionStatus.completed,
            fromAccountId: target.id,
            toAccountId: null,
            amount: amountInAccountCurrency,
            currency: target.currency,
            description:
                'Satış tahsilatı ${_saleNumberController.text} ($_paymentCurrencyCode)',
            reference: _saleNumberController.text,
            relatedDocumentId: saleId,
            relatedDocumentType: 'sale',
            transactionDate: now,
            dueDate: null,
            notes: null,
            attachments: const [],
            metadata: {
              'baseCurrency': _baseCurrencyCode,
              'paymentCurrency': _paymentCurrencyCode,
              'fxToBase': fxRate,
              'amountInBase': totalBase,
            },
            createdAt: now,
            updatedAt: now,
            createdBy: 'system',
            updatedBy: null,
          );
          await useCase.call(trx);
        } catch (_) {}
      }
    }

    if (widget.saleId != null) {
      notifier.updateSale(sale);
      await afterSave(sale.id);
    } else {
      notifier.createSale(sale);
      await afterSave(_saleNumberController.text);
    }

    Navigator.pop(context);
  }

  void _saveSaleDraft() async {
    if (_customerIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Müşteri seçiniz')),
      );
      return;
    }

    final subtotalTry = _items.fold(0.0, (sum, item) => sum + item.totalAmount);
    final taxAmountTry = subtotalTry * (_taxRate / 100);
    final totalTry = subtotalTry + taxAmountTry - _discountAmount;

    double totalBase = totalTry;
    if (_baseCurrencyCode != 'TRY') {
      await ExchangeRateService().getExchangeRate(_baseCurrencyCode);
      totalBase = ExchangeRateService()
          .convertCurrency(totalTry, 'TRY', _baseCurrencyCode);
    }

    final sale = Sale(
      id: widget.saleId ?? '',
      saleNumber: _saleNumberController.text,
      customerId: _customerIdController.text,
      customerName: _customerNameController.text.isNotEmpty
          ? _customerNameController.text
          : null,
      type: _selectedType,
      status: SaleStatus.draft,
      paymentStatus: PaymentStatus.pending,
      saleDate: _selectedDate,
      dueDate: _dueDate,
      items: _items,
      subtotal: _baseCurrencyCode == 'TRY'
          ? subtotalTry
          : ExchangeRateService()
              .convertCurrency(subtotalTry, 'TRY', _baseCurrencyCode),
      taxRate: _taxRate,
      taxAmount: _baseCurrencyCode == 'TRY'
          ? taxAmountTry
          : ExchangeRateService()
              .convertCurrency(taxAmountTry, 'TRY', _baseCurrencyCode),
      discountAmount: _baseCurrencyCode == 'TRY'
          ? _discountAmount
          : ExchangeRateService()
              .convertCurrency(_discountAmount, 'TRY', _baseCurrencyCode),
      totalAmount: totalBase,
      currency: _baseCurrencyCode,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final notifier = ref.read(saleNotifierProvider.notifier);
    if (widget.saleId != null) {
      notifier.updateSale(sale);
    } else {
      notifier.createSale(sale);
    }
    Navigator.pop(context);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Satışı Sil'),
        content: const Text('Bu satışı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.saleId != null) {
                ref
                    .read(saleNotifierProvider.notifier)
                    .deleteSale(widget.saleId!);
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _calculateInstallmentPlan() {
    _installments = [];
    if (_isCashPayment) {
      setState(() {});
      return;
    }
    final count = (_installmentCount ?? 0) <= 0 ? 1 : _installmentCount!;
    final startDate = _dueDate ?? _selectedDate;

    final gross =
        _items.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
    final totalDiscount =
        _items.fold(0.0, (sum, item) => sum + item.discountAmount);
    final subtotal = gross - totalDiscount;
    final taxAmount = _items.fold(0.0, (sum, item) => sum + item.taxAmount);
    final total = subtotal + taxAmount - _discountAmount;

    final monthlyRate =
        double.tryParse(_interestRateController.text.replaceAll(',', '.'));

    if (monthlyRate == null || monthlyRate <= 0) {
      final installment = (total / count);
      for (int i = 0; i < count; i++) {
        final due =
            DateTime(startDate.year, startDate.month + i, startDate.day);
        _installments.add(_InstallmentItem(
          dueDate: due,
          amount: installment,
          principal: installment,
          interestAmount: 0,
        ));
      }
    } else {
      final r = monthlyRate / 100.0;
      final n = count;
      final principal = total;
      final annuity =
          principal * (r * math.pow(1 + r, n)) / (math.pow(1 + r, n) - 1);
      double remaining = principal;
      for (int i = 0; i < n; i++) {
        final interest = remaining * r;
        final principalPart = annuity - interest;
        remaining -= principalPart;
        final due =
            DateTime(startDate.year, startDate.month + i, startDate.day);
        _installments.add(_InstallmentItem(
          dueDate: due,
          amount: annuity,
          principal: principalPart,
          interestAmount: interest,
        ));
      }
    }
    setState(() {});
  }

  Future<void> _initSaleNumber() async {
    if (widget.saleId != null) return; // editing mode uses existing number
    try {
      final repo = ref.read(saleRepositoryProvider);
      final generated = await repo.generateSaleNumber(_selectedType);
      if (mounted && _saleNumberController.text.isEmpty) {
        setState(() {
          _saleNumberController.text = generated;
        });
      }
    } catch (_) {
      // Fallback: leave empty and let user fill
    }
  }

  Future<void> _pickCustomer() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Consumer(builder: (context, ref, _) {
              final customersAsync = ref.watch(customersProvider);
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Müşteri Seç',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: customersAsync.when(
                        data: (list) {
                          if (list.isEmpty) {
                            return const Center(
                                child: Text('Kayıtlı müşteri bulunamadı'));
                          }
                          return ListView.builder(
                            controller: scrollController,
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final c = list[index];
                              return ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: Text(c.name),
                                subtitle: Text(c.customerCode ?? c.id),
                                onTap: () {
                                  _customerIdController.text = c.id;
                                  _customerNameController.text = c.name;
                                  _loadCustomer(c.id);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) =>
                            Center(child: Text('Müşteriler yüklenemedi: $e')),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _createNewCustomer();
                        },
                        icon: const Icon(Icons.person_add_alt),
                        label: const Text('Yeni Müşteri Oluştur'),
                      ),
                    )
                  ],
                ),
              );
            });
          },
        );
      },
    );
  }

  Future<void> _createNewCustomer() async {
    await TamgaciRoutes.pushNamed(context, TamgaciRoutes.createCustomer);
    if (mounted) {
      ref.invalidate(customersProvider);
    }
  }

  List<DropdownMenuItem<String>> _buildAddressItems({required bool isBilling}) {
    final customerId = _customerIdController.text;
    if (customerId.isEmpty) {
      final addr = isBilling ? _billingAddress : _shippingAddress;
      if (addr == null) {
        return [
          const DropdownMenuItem(
            value: _kNewAddressValue,
            child: Row(
              children: [
                Icon(Icons.add_location_alt_outlined, size: 18),
                SizedBox(width: 6),
                Expanded(child: Text('Yeni adres ekle')),
              ],
            ),
          )
        ];
      }
      return [
        DropdownMenuItem(
            value: addr, child: Text(addr, overflow: TextOverflow.ellipsis)),
        const DropdownMenuItem(
          value: _kNewAddressValue,
          child: Row(
            children: [
              Icon(Icons.add_location_alt_outlined, size: 18),
              SizedBox(width: 6),
              Expanded(child: Text('Yeni adres ekle')),
            ],
          ),
        )
      ];
    }

    // Prefer up-to-date single customer fetch
    final asyncCustomer = ref.read(customerProvider(customerId));
    String? baseAddress;
    if (asyncCustomer.hasValue && asyncCustomer.value != null) {
      baseAddress = isBilling
          ? asyncCustomer.value!.address
          : (asyncCustomer.value!.shippingAddress ??
              asyncCustomer.value!.address);
    } else {
      baseAddress = isBilling ? _billingAddress : _shippingAddress;
    }

    final items = <DropdownMenuItem<String>>[];
    if (baseAddress != null && baseAddress.isNotEmpty) {
      items.add(DropdownMenuItem(
        value: baseAddress,
        child: Text(
          baseAddress,
          overflow: TextOverflow.ellipsis,
        ),
      ));
    }
    // If customer has branches, include branch addresses
    if (asyncCustomer.hasValue && asyncCustomer.value?.branches != null) {
      for (final br in asyncCustomer.value!.branches!) {
        if (br.address.isNotEmpty) {
          items.add(DropdownMenuItem(
              value: br.address,
              child: Text('${br.name} • ${br.address}',
                  overflow: TextOverflow.ellipsis)));
        }
      }
    }
    // De-duplicate items by value
    final seen = <String>{};
    final deduped = <DropdownMenuItem<String>>[];
    for (final it in items) {
      final val = it.value;
      if (val != null && !seen.contains(val)) {
        seen.add(val);
        deduped.add(it);
      }
    }
    items
      ..clear()
      ..addAll(deduped);
    // Yeni adres ekle seçeneği
    items.add(const DropdownMenuItem(
      value: _kNewAddressValue,
      child: Row(
        children: [
          Icon(Icons.add_location_alt_outlined, size: 18),
          SizedBox(width: 6),
          Expanded(child: Text('Yeni adres ekle')),
        ],
      ),
    ));
    return items;
  }

  Future<void> _showAddAddressDialog({required bool isBilling}) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final added = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBilling ? 'Yeni Fatura Adresi' : 'Yeni Sevk Adresi'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Adres',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Adres giriniz' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );

    if (added == null) return;

    // Set locally
    setState(() {
      if (isBilling) {
        _billingAddress = added;
      } else {
        _shippingAddress = added;
      }
    });

    // Persist as a new branch if customer selected
    final customerId = _customerIdController.text;
    if (customerId.isEmpty) return;

    final asyncCustomer = await ref.read(customerProvider(customerId).future);
    if (asyncCustomer == null) return;

    final branches = List<CustomerBranch>.from(asyncCustomer.branches ?? []);
    branches.add(CustomerBranch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: isBilling ? 'Fatura Adresi' : 'Sevk Adresi',
      address: added,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    final updated = asyncCustomer.copyWith(
      branches: branches,
      // keep other fields same
    );

    // Simple persist via operations provider if present
    try {
      await ref
          .read(customerOperationsProvider.notifier)
          .updateCustomer(updated);
      ref.invalidate(customersProvider);
    } catch (_) {
      // ignore persistence failure silently for now, UI already updated
    }
  }

  double _roundMoney(double value) {
    final factor = math.pow(10, _moneyDecimals).toDouble();
    switch (_roundMode) {
      case 'floor':
        return (value * factor).floor() / factor;
      case 'ceil':
        return (value * factor).ceil() / factor;
      default: // halfUp
        return (value * factor).round() / factor;
    }
  }

  String _formatMoney(double value, {String? currency}) {
    final c = (currency ?? _baseCurrencyCode).toUpperCase();
    final symbols = {'TRY': '₺', 'USD': '\$', 'EUR': '€', 'GBP': '£'};
    final sym = symbols[c] ?? '';
    final v = _roundMoney(value);
    return '$sym${v.toStringAsFixed(_moneyDecimals)}';
  }
}

class _ProductQuickPicker extends ConsumerStatefulWidget {
  final void Function(
    String id,
    String? name,
    double? price,
    double? taxRate,
    String salesCurrency,
  ) onSelected;

  const _ProductQuickPicker({required this.onSelected});

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
            final left = (p.productCode ?? p.sku ?? p.barcode ?? '').trim();
            return left.isEmpty ? p.name : '$left • ${p.name}';
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
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 300, minWidth: 320),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final p = options.elementAt(index);
                      return ListTile(
                        title: Text(p.name, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          (p.productCode ?? p.sku ?? p.barcode ?? '-'),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => onSelected(p),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (Product p) {
            widget.onSelected(
              p.id,
              p.name,
              p.salesPrice,
              18.0, // Varsayılan KDV oranı
              p.salesCurrency,
            );
            final state =
                context.findAncestorStateOfType<_AddItemDialogState>();
            if (state != null) {
              state._productIdController.text = p.productCode ?? p.id;
              state._productNameController.text = p.name;
              state._unitPriceController.text = _formatTrCurrency(p.salesPrice);
              state._taxRateController.text = '18'; // Varsayılan KDV oranı
              state._productCurrencyCode = (p.salesCurrency).toUpperCase();
              // Varsayılan satır para birimini ürün para birimine set et
              state.setState(() {
                state._lineCurrencyCode = (p.salesCurrency).toUpperCase();
              });
            }
          },
        );
      },
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Ürünler yüklenemedi: $e'),
    );
  }
}

class _InstallmentItem {
  final DateTime dueDate;
  final double amount;
  final double principal;
  final double interestAmount;

  _InstallmentItem({
    required this.dueDate,
    required this.amount,
    required this.principal,
    required this.interestAmount,
  });
}

/// Ürün ekleme dialog'u
class _AddItemDialog extends StatefulWidget {
  final void Function(SaleItem) onAdd;
  final String paymentCurrencyCode;
  final String baseCurrencyCode;
  const _AddItemDialog(
      {required this.onAdd,
      required this.paymentCurrencyCode,
      required this.baseCurrencyCode});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _productIdController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _taxRateController = TextEditingController(text: '18');
  final _discountRateController = TextEditingController(text: '0');
  String _lineCurrencyCode = 'TRY';
  double? _fxRateToTry;
  String _productCurrencyCode = 'TRY';
  final TextEditingController _manualRateController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ürün Ekle'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _productIdController,
              decoration: const InputDecoration(
                labelText: 'Ürün ID / Kod',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ürün ID/Kod gerekli';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _ProductQuickPicker(
              onSelected: (id, name, price, tax, salesCurrency) {
                _productIdController.text = id;
                _productNameController.text = name ?? '';
                _unitPriceController.text =
                    price != null ? _formatTrCurrency(price) : '';
                if (tax != null) {
                  _taxRateController.text = tax.toStringAsFixed(0);
                }
                _productCurrencyCode = (salesCurrency).toUpperCase();
                _lineCurrencyCode = _productCurrencyCode;
              },
            ),
            const SizedBox(height: 16.0),
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
                      // Kur: 1 LINE = ? BASE
                      if (v == widget.baseCurrencyCode) {
                        setState(() => _fxRateToTry = 1.0);
                      } else {
                        await ExchangeRateService()
                            .getExchangeRate(widget.baseCurrencyCode);
                        final r = ExchangeRateService()
                            .convertCurrency(1.0, v, widget.baseCurrencyCode);
                        setState(() => _fxRateToTry = r);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
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
              ],
            ),
            const SizedBox(height: 6),
            if (_lineCurrencyCode != _productCurrencyCode &&
                _lineCurrencyCode != widget.baseCurrencyCode)
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
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: OutlinedButton(
                        onPressed: () async {
                          await ExchangeRateService()
                              .getExchangeRate(widget.baseCurrencyCode);
                          final rate = ExchangeRateService().convertCurrency(
                              1.0, _lineCurrencyCode, widget.baseCurrencyCode);
                          setState(() {
                            _manualRateController.text =
                                rate.toStringAsFixed(4);
                          });
                        },
                        child: const Text('Kuru Getir'),
                      ),
                    ),
                  ),
                ],
              ),
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Ürün Adı',
                border: OutlineInputBorder(),
              ),
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
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        final raw = _discountRateController.text.trim();
                        if (raw.isEmpty) return;
                        final parsed = double.tryParse(
                            raw.replaceAll('.', '').replaceAll(',', '.'));
                        if (parsed != null) {
                          _discountRateController.text =
                              _formatTrNumber(parsed);
                        }
                      }
                    },
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = double.parse(_quantityController.text);
    final unitPrice = double.parse(
        _unitPriceController.text.replaceAll('.', '').replaceAll(',', '.'));
    double priceInBase;
    if (_lineCurrencyCode == widget.baseCurrencyCode) {
      priceInBase = unitPrice;
    } else {
      final manual = double.tryParse(
          _manualRateController.text.replaceAll('.', '').replaceAll(',', '.'));
      if (manual != null && manual > 0) {
        priceInBase = unitPrice * manual; // 1 LINE = manual BASE
      } else if (_fxRateToTry != null && _fxRateToTry! > 0) {
        priceInBase = unitPrice * _fxRateToTry!; // 1 LINE = fx BASE
      } else {
        // Son çare: hafızadaki kurlarla çevir
        priceInBase = ExchangeRateService().convertCurrency(
            unitPrice, _lineCurrencyCode, widget.baseCurrencyCode);
      }
    }
    final discountRate = double.tryParse(_discountRateController.text) ?? 0;
    final taxRate = double.tryParse(_taxRateController.text) ?? 0;
    final gross = quantity * priceInBase;
    final discountAmount = (gross * (discountRate / 100));
    final net = gross - discountAmount;
    final taxAmount = net * (taxRate / 100);
    final totalAmount = net + taxAmount;

    final item = SaleItem(
      id: '',
      saleId: '',
      productId: _productIdController.text,
      productName: _productNameController.text.isNotEmpty
          ? _productNameController.text
          : null,
      productDescription: _productDescriptionController.text.isNotEmpty
          ? _productDescriptionController.text
          : null,
      quantity: quantity,
      unitPrice: priceInBase,
      discountRate: discountRate,
      discountAmount: discountAmount,
      taxRate: taxRate,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      currency: _lineCurrencyCode,
    );

    widget.onAdd(item);
    Navigator.pop(context);
  }
}

String _formatTrCurrency(double value) {
  final formatter =
      NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2);
  return formatter.format(value).trim();
}

// removed realtime formatter; formatting now on blur

String _formatTrNumber(double value) {
  final nf = NumberFormat('#,##0.##', 'tr_TR');
  return nf.format(value);
}
