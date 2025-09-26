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
                  if (_hasSelectedCustomer) ...[
                    const SizedBox(height: 16),
                    _buildCustomerCard(),
                  ],
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
                  const SizedBox(height: 16),
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
                      onChanged: (value) =>
                          setState(() => _selectedType = value!),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Consumer(
      builder: (context, ref, child) {
        final customerAsync =
            ref.watch(customerProvider(_customerIdController.text));

        return customerAsync.when(
          data: (customer) {
            if (customer == null) return const SizedBox.shrink();

            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Müşteri Bilgileri',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCustomerInfoRow('Ad', customer.name),
                    if (customer.customerCode != null &&
                        customer.customerCode!.isNotEmpty)
                      _buildCustomerInfoRow('Kod', customer.customerCode!),
                    if (customer.phone != null && customer.phone!.isNotEmpty)
                      _buildCustomerInfoRow('Telefon', customer.phone!),
                    if (customer.email != null && customer.email!.isNotEmpty)
                      _buildCustomerInfoRow('E-posta', customer.email!),
                    if (customer.address != null &&
                        customer.address!.isNotEmpty)
                      _buildCustomerInfoRow('Adres', customer.address!),
                    if (customer.taxNumber != null &&
                        customer.taxNumber!.isNotEmpty)
                      _buildCustomerInfoRow('Vergi No', customer.taxNumber!),
                    if (customer.creditLimit > 0)
                      _buildCustomerInfoRow('Kredi Limiti',
                          '${customer.creditLimit.toStringAsFixed(2)} ${customer.balanceCurrency}'),
                    if (customer.currentBalance != 0)
                      _buildCustomerInfoRow(
                        'Mevcut Bakiye',
                        '${customer.currentBalance.toStringAsFixed(2)} ${customer.balanceCurrency}',
                        isBalance: true,
                      ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Müşteri bilgileri yüklenemedi: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerInfoRow(String label, String value,
      {bool isBalance = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isBalance
                        ? (value.startsWith('-') ? Colors.red : Colors.green)
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isBalance ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ),
        ],
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
              _buildProductsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTable() {
    return Card(
      child: Column(
        children: [
          // Tablo başlığı
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
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
            itemCount: _items.length,
            separatorBuilder: (context, index) => const Divider(height: 1.0),
            itemBuilder: (context, index) {
              final item = _items[index];
              return _buildProductRow(item, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildProductRow(SaleItem item, int index) {
    return InkWell(
      onTap: () => _editItem(index),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Küçük ekran için basit görünüm
              return _buildSmallScreenRow(item, index);
            } else {
              // Büyük ekran için tam tablo görünümü
              return _buildLargeScreenRow(item, index);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSmallScreenRow(SaleItem item, int index) {
    return Row(
      children: [
        // Ürün bilgileri
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName ?? item.productId,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.productDescription != null &&
                  item.productDescription!.isNotEmpty)
                Text(
                  item.productDescription!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Miktar
        Text(
          '${item.quantity.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 12),
        ),

        const SizedBox(width: 8),

        // Birim Fiyat
        Text(
          _formatMoney(item.unitPrice, currency: item.currency),
          style: const TextStyle(fontSize: 12),
        ),

        const SizedBox(width: 8),

        // Toplam
        Text(
          _formatMoney(item.totalAmount, currency: item.currency),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),

        const SizedBox(width: 8),

        // Silme butonu
        IconButton(
          onPressed: () => _removeItem(index),
          icon: const Icon(Icons.delete, color: Colors.red, size: 16),
          tooltip: 'Ürünü Sil',
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4.0),
        ),
      ],
    );
  }

  Widget _buildLargeScreenRow(SaleItem item, int index) {
    return Row(
      children: [
        // Ürün Adı
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName ?? item.productId,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.productDescription != null &&
                  item.productDescription!.isNotEmpty)
                Text(
                  item.productDescription!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        // Miktar
        Expanded(
          flex: 2,
          child: Text(
            '${item.quantity.toStringAsFixed(0)} adet',
            style: const TextStyle(fontSize: 14),
          ),
        ),

        // Birim Fiyat
        Expanded(
          flex: 2,
          child: Text(
            _formatMoney(item.unitPrice, currency: item.currency),
            style: const TextStyle(fontSize: 14),
          ),
        ),

        // KDV
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatMoney(item.taxAmount, currency: item.currency),
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '%${item.taxRate.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // İskonto
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatMoney(item.discountAmount, currency: item.currency),
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '%${item.discountRate.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // Toplam
        Expanded(
          flex: 2,
          child: Text(
            _formatMoney(item.totalAmount, currency: item.currency),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),

        // Silme butonu
        IconButton(
          onPressed: () => _removeItem(index),
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          tooltip: 'Ürünü Sil',
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8.0),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    // Multi-currency toplam hesaplaması
    final Map<String, double> currencyTotals = {};

    for (final item in _items) {
      final currency = item.currency;
      final itemTotal = item.totalAmount;
      currencyTotals[currency] = (currencyTotals[currency] ?? 0.0) + itemTotal;
    }

    // İndirim tutarını ana para birimine ekle
    if (_discountAmount > 0) {
      currencyTotals[_baseCurrencyCode] =
          (currencyTotals[_baseCurrencyCode] ?? 0.0) - _discountAmount;
    }

    // Eski hesaplama (backward compatibility için)
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Multi-currency toplam gösterimi
                            ...currencyTotals.entries.map((entry) {
                              final currency = entry.key;
                              final amount = entry.value;
                              if (amount <= 0) return const SizedBox.shrink();

                              return Text(
                                _formatMoney(amount, currency: currency),
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ],
                    ),
                    // TRY karşılığı (farklı para birimleri varsa)
                    if (currencyTotals.keys.any((c) => c != 'TRY')) ...[
                      const SizedBox(height: 8),
                      FutureBuilder<double>(
                        future: _calculateTryEquivalent(currencyTotals),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          final tryTotal = snapshot.data!;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TRY Karşılığı:',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '≈ ${_formatMoney(tryTotal, currency: 'TRY')}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
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

  Future<double> _calculateTryEquivalent(
      Map<String, double> currencyTotals) async {
    double tryTotal = 0.0;

    for (final entry in currencyTotals.entries) {
      final currency = entry.key;
      final amount = entry.value;

      if (currency == 'TRY') {
        tryTotal += amount;
      } else {
        // Kur servisini kullanarak TRY'ye çevir
        try {
          await ExchangeRateService().getExchangeRate(currency);
          final convertedAmount =
              ExchangeRateService().convertCurrency(amount, currency, 'TRY');
          tryTotal += convertedAmount;
        } catch (e) {
          debugPrint('Kur çevirme hatası: $e');
          // Hata durumunda orijinal tutarı ekle (fallback)
          tryTotal += amount;
        }
      }
    }

    return tryTotal;
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

  void _editItem(int index) {
    final item = _items[index];
    _showEditItemDialog(item, index);
  }

  void _showEditItemDialog(SaleItem item, int index) {
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
            // onSelected callback'i zaten tüm değerleri set ediyor
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
  final _quantityController = TextEditingController(text: '1');
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
            _ProductQuickPicker(
              onSelected: (id, name, price, tax, salesCurrency) {
                setState(() {
                  _productIdController.text = id;
                  _productNameController.text = name ?? '';
                  _unitPriceController.text =
                      price != null ? _formatTrCurrency(price) : '';
                  if (tax != null) {
                    _taxRateController.text = tax.toStringAsFixed(0);
                  }
                  _productCurrencyCode = (salesCurrency).toUpperCase();
                  _lineCurrencyCode = _productCurrencyCode;
                });
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
                        // Otomatik kur getirme
                        try {
                          await ExchangeRateService().getExchangeRate(v);
                          final r = ExchangeRateService()
                              .convertCurrency(1.0, v, widget.baseCurrencyCode);
                          setState(() {
                            _fxRateToTry = r;
                            // Manuel kur alanını da otomatik doldur
                            _manualRateController.text = _formatTrNumber(r);
                          });
                        } catch (e) {
                          debugPrint('Otomatik kur alma hatası: $e');
                          setState(() => _fxRateToTry = null);
                        }
                      }
                    },
                  ),
                ),
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
    final discountAmount = (gross * (discountRate / 100));
    final net = gross - discountAmount;
    final taxAmount = net * (taxRate / 100);
    final totalAmount = net + taxAmount;

    // Null kontrolü
    if (taxRate.isNaN || taxAmount.isNaN || totalAmount.isNaN) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hesaplama hatası oluştu')),
      );
      return;
    }

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
      unitPrice: unitPrice, // Orijinal para biriminde (USD ise USD)
      discountRate: discountRate,
      discountAmount: discountAmount,
      taxRate: taxRate,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      currency: _lineCurrencyCode, // Orijinal para birimi (USD)
    );

    debugPrint('Ürün ekleniyor: ${item.productName}');
    widget.onAdd(item);
    debugPrint('Ürün eklendi, dialog kapatılıyor');
    Navigator.pop(context);
  }
}

/// Ürün düzenleme dialog'u
class _EditItemDialog extends StatefulWidget {
  final SaleItem item;
  final void Function(SaleItem) onSave;

  const _EditItemDialog({
    required this.item,
    required this.onSave,
  });

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _productIdController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _discountRateController = TextEditingController();
  final _taxRateController = TextEditingController();

  String _lineCurrencyCode = 'TRY';

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final item = widget.item;
    _productIdController.text = item.productId;
    _productNameController.text = item.productName ?? '';
    _productDescriptionController.text = item.productDescription ?? '';
    _quantityController.text = item.quantity.toString();
    _unitPriceController.text = item.unitPrice.toString();
    _discountRateController.text = item.discountRate.toString();
    _taxRateController.text = item.taxRate.toString();
    _lineCurrencyCode = item.currency;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ürün Düzenle'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ürün seçimi
              _ProductQuickPicker(
                onSelected:
                    (productId, productName, unitPrice, taxRate, currency) {
                  setState(() {
                    _productIdController.text = productId;
                    _productNameController.text = productName ?? '';
                    _lineCurrencyCode = currency;
                    if (unitPrice != null) {
                      _unitPriceController.text = unitPrice.toString();
                    }
                    if (taxRate != null) {
                      _taxRateController.text = taxRate.toString();
                    }
                  });
                },
              ),

              const SizedBox(height: 16),

              // Ürün bilgileri
              if (_productIdController.text.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ürün ID: ${_productIdController.text}'),
                      Text('Ürün: ${_productNameController.text}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Miktar ve birim fiyat
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Miktar',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Miktar gerekli';
                        }
                        final cleaned =
                            value.replaceAll('.', '').replaceAll(',', '.');
                        final parsed = double.tryParse(cleaned);
                        if (parsed == null || parsed <= 0) {
                          return 'Geçerli miktar giriniz';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          final raw = _unitPriceController.text.trim();
                          if (raw.isEmpty) return;
                          final parsed = double.tryParse(
                              raw.replaceAll('.', '').replaceAll(',', '.'));
                          if (parsed != null) {
                            _unitPriceController.text =
                                _formatTrCurrency(parsed);
                          }
                        }
                      },
                      child: TextFormField(
                        controller: _unitPriceController,
                        decoration: InputDecoration(
                          labelText: 'Birim Fiyat ($_lineCurrencyCode)',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        onChanged: (_) => setState(() {}),
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
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // İskonto ve KDV
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountRateController,
                      decoration: const InputDecoration(
                        labelText: 'İskonto Oranı (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'İskonto oranı gerekli';
                        }
                        final cleaned =
                            value.replaceAll('.', '').replaceAll(',', '.');
                        final parsed = double.tryParse(cleaned);
                        if (parsed == null || parsed < 0) {
                          return 'Geçerli oran giriniz';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _taxRateController,
                      decoration: const InputDecoration(
                        labelText: 'KDV Oranı (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'KDV oranı gerekli';
                        }
                        final cleaned =
                            value.replaceAll('.', '').replaceAll(',', '.');
                        final parsed = double.tryParse(cleaned);
                        if (parsed == null || parsed < 0) {
                          return 'Geçerli oran giriniz';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Açıklama
              TextFormField(
                controller: _productDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (Maksimum 200 karakter)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                maxLength: 200,
                onChanged: (value) {
                  if (value.length > 200) {
                    _productDescriptionController.text =
                        value.substring(0, 200);
                    _productDescriptionController.selection =
                        TextSelection.fromPosition(
                      const TextPosition(offset: 200),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              // Hesaplama özeti
              _buildProductCalculation(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveItem,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  Widget _buildProductCalculation() {
    final quantity =
        double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0.0;
    final unitPrice =
        double.tryParse(_unitPriceController.text.replaceAll(',', '.')) ?? 0.0;

    if (quantity <= 0 || unitPrice <= 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Miktar ve birim fiyat giriniz',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final discountRate =
        double.tryParse(_discountRateController.text.replaceAll(',', '.')) ??
            0.0;
    final taxRate =
        double.tryParse(_taxRateController.text.replaceAll(',', '.')) ?? 0.0;

    final gross = quantity * unitPrice;
    final discountAmount = gross * (discountRate / 100);
    final subtotal = gross - discountAmount;
    final taxAmount = subtotal * (taxRate / 100);
    final total = subtotal + taxAmount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hesaplama Özeti:',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
          const SizedBox(height: 8),
          _buildCalculationRow(
              'Ara Toplam:', _formatMoney(gross, currency: _lineCurrencyCode)),
          _buildCalculationRow('İskonto:',
              _formatMoney(discountAmount, currency: _lineCurrencyCode)),
          _buildCalculationRow(
              'KDV:', _formatMoney(taxAmount, currency: _lineCurrencyCode)),
          const Divider(),
          _buildCalculationRow(
              'Toplam:', _formatMoney(total, currency: _lineCurrencyCode),
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? Colors.green : null)),
        ],
      ),
    );
  }

  String _formatMoney(double value, {String? currency}) {
    final c = currency ?? _lineCurrencyCode;
    final symbols = {'TRY': '₺', 'USD': '\$', 'EUR': '€', 'GBP': '£'};
    final sym = symbols[c] ?? '';
    final v = _roundMoney(value);
    return '$sym${v.toStringAsFixed(2)}';
  }

  double _roundMoney(double value) {
    return (value * 100).round() / 100;
  }

  String _formatTrCurrency(double value) {
    final formatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2);
    return formatter.format(value).trim();
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity =
        double.parse(_quantityController.text.replaceAll(',', '.'));
    final unitPrice =
        double.parse(_unitPriceController.text.replaceAll(',', '.'));
    final discountRate =
        double.parse(_discountRateController.text.replaceAll(',', '.'));
    final taxRate = double.parse(_taxRateController.text.replaceAll(',', '.'));

    final gross = quantity * unitPrice;
    final discountAmount = gross * (discountRate / 100);
    final subtotal = gross - discountAmount;
    final taxAmount = subtotal * (taxRate / 100);
    final total = subtotal + taxAmount;

    final item = SaleItem(
      id: '',
      saleId: '',
      productId: _productIdController.text,
      productName: _productNameController.text,
      productDescription: _productDescriptionController.text,
      productSku: '',
      quantity: quantity,
      unitPrice: unitPrice,
      discountRate: discountRate,
      discountAmount: discountAmount,
      taxRate: taxRate,
      taxAmount: taxAmount,
      totalAmount: total,
      currency: _lineCurrencyCode,
    );

    widget.onSave(item);
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
