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
  String _paymentCurrencyCode = '';
  double? _paymentAmount; // Ödenecek miktar
  final _paymentAmountController = TextEditingController();
  final _paymentAmountFocusNode = FocusNode();

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
    _paymentAmountController.dispose();
    _paymentAmountFocusNode.dispose();
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
                            : null,
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
                      TextFormField(
                        controller: _paymentAmountController,
                        focusNode: _paymentAmountFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Ödenecek Miktar (Opsiyonel)',
                          border: OutlineInputBorder(),
                          hintText: 'Boş bırakılabilir',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          _PaymentAmountFormatter(),
                        ],
                        onChanged: (value) {
                          if (value.trim().isEmpty) {
                            setState(() => _paymentAmount = null);
                          } else {
                            // Nokta ve virgülü koruyarak parse et
                            String cleanValue =
                                value.replaceAll(RegExp(r'[^\d.,]'), '');

                            // Virgülü nokta ile değiştir (double.parse için)
                            cleanValue = cleanValue.replaceAll(',', '.');

                            if (cleanValue.isNotEmpty) {
                              final parsed = double.tryParse(cleanValue);
                              setState(() => _paymentAmount = parsed);
                            }
                          }
                        },
                        onTapOutside: (event) {
                          // Focus kaybedildiğinde küsüratsız sayılara ,00 ekle
                          final currentText = _paymentAmountController.text;
                          if (currentText.isNotEmpty &&
                              !currentText.contains(',')) {
                            // Sadece rakamlar varsa ve virgül yoksa ,00 ekle
                            final cleanValue =
                                currentText.replaceAll(RegExp(r'[^\d]'), '');
                            if (cleanValue.isNotEmpty) {
                              final number = int.tryParse(cleanValue);
                              if (number != null) {
                                final formatter =
                                    NumberFormat('#,##0', 'tr_TR');
                                final formatted = formatter.format(number);
                                _paymentAmountController.text = '$formatted,00';
                                setState(
                                    () => _paymentAmount = number.toDouble());
                              }
                            }
                          }
                        },
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
                  _buildSummaryCard(),
                  const SizedBox(height: 16.0),
                  _buildPaymentCard(),
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
    // Aynı ürün, aynı para birimi ve aynı birim fiyat olan ürünleri birleştir
    final mergedItems = _mergeIdenticalItems(_items);

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
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  /// Aynı ürün, aynı para birimi ve aynı birim fiyat olan ürünleri birleştir
  List<SaleItem> _mergeIdenticalItems(List<SaleItem> items) {
    if (items.isEmpty) return items;

    // Birleştirme için Map kullan
    final Map<String, SaleItem> mergedMap = {};

    for (final item in items) {
      // Benzersiz anahtar oluştur: productId + currency + unitPrice + taxRate + discountRate
      final key =
          '${item.productId}_${item.currency}_${item.unitPrice}_${item.taxRate}_${item.discountRate}';

      if (mergedMap.containsKey(key)) {
        // Mevcut ürünü güncelle
        final existingItem = mergedMap[key]!;
        final mergedItem = SaleItem(
          id: existingItem.id,
          saleId: existingItem.saleId,
          productId: existingItem.productId,
          productName: existingItem.productName,
          productDescription: existingItem.productDescription,
          productSku: existingItem.productSku,
          quantity: existingItem.quantity + item.quantity,
          unitPrice: existingItem.unitPrice,
          discountRate: existingItem.discountRate,
          discountAmount: existingItem.discountAmount + item.discountAmount,
          taxRate: existingItem.taxRate,
          taxAmount: existingItem.taxAmount + item.taxAmount,
          totalAmount: existingItem.totalAmount + item.totalAmount,
          currency: existingItem.currency,
        );
        mergedMap[key] = mergedItem;
      } else {
        // Yeni ürün ekle
        mergedMap[key] = item;
      }
    }

    return mergedMap.values.toList();
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
          item.quantity.toStringAsFixed(0),
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

    // Ödeme para birimi seçilmişse, tüm hesaplamaları o para birimine göre yap
    if (_paymentCurrencyCode.isNotEmpty) {
      return _buildPaymentCurrencySummary();
    }

    // Para birimi bazlı gruplandırma (ödeme para birimi seçilmemişse)
    final Map<String, List<SaleItem>> itemsByCurrency = {};
    for (final item in _items) {
      final currency = item.currency;
      if (!itemsByCurrency.containsKey(currency)) {
        itemsByCurrency[currency] = [];
      }
      itemsByCurrency[currency]!.add(item);
    }

    // Her para birimi için hesaplamalar
    final List<Widget> currencyCards = [];
    double totalInTRY = 0.0;

    for (final currency in itemsByCurrency.keys) {
      final items = itemsByCurrency[currency]!;

      // Bu para birimi için hesaplamalar
      final subtotal = items.fold(
          0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
      final totalDiscount =
          items.fold(0.0, (sum, item) => sum + item.discountAmount);
      final totalTax = items.fold(0.0, (sum, item) => sum + item.taxAmount);
      final total = subtotal - totalDiscount + totalTax;

      currencyCards.add(_buildCurrencySummaryCard(
        currency: currency,
        subtotal: subtotal,
        discount: totalDiscount,
        tax: totalTax,
        total: total,
        onTotalCalculated: (tryAmount) {
          totalInTRY += tryAmount;
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
          _buildGrandTotalCard(totalInTRY),
        ],
      ],
    );
  }

  Widget _buildPaymentCurrencySummary() {
    // Para birimi bazlı gruplandırma
    final Map<String, List<SaleItem>> itemsByCurrency = {};
    for (final item in _items) {
      final currency = item.currency;
      if (!itemsByCurrency.containsKey(currency)) {
        itemsByCurrency[currency] = [];
      }
      itemsByCurrency[currency]!.add(item);
    }

    // Her para birimi için hesaplamalar ve toplam hesaplama
    final List<Widget> currencyCards = [];
    double totalInPaymentCurrency = 0.0;

    for (final currency in itemsByCurrency.keys) {
      final items = itemsByCurrency[currency]!;

      // Bu para birimi için hesaplamalar
      final subtotal = items.fold(
          0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
      final totalDiscount =
          items.fold(0.0, (sum, item) => sum + item.discountAmount);
      final totalTax = items.fold(0.0, (sum, item) => sum + item.taxAmount);
      final total = subtotal - totalDiscount + totalTax;

      // Bu para biriminin ödeme para birimindeki karşılığını hesapla
      double totalInPaymentCurrencyForThisCurrency = total;
      if (currency != _paymentCurrencyCode) {
        // Ürün kurlarını kullanarak dönüşüm yap
        try {
          // Bu para birimindeki ürünlerin kurlarını kontrol et
          double? usedFxRate;
          for (final item in items) {
            if (item.currency == currency &&
                item.fxRateToBase != null &&
                item.fxRateToBase! > 0) {
              usedFxRate = item.fxRateToBase;
              break;
            }
          }

          if (usedFxRate != null && usedFxRate > 0) {
            // Ürün kurlarını kullan
            totalInPaymentCurrencyForThisCurrency = total * usedFxRate;
            debugPrint(
                'DEBUG: Genel toplam ürün kuru kullanıldı - $total $currency x $usedFxRate = $totalInPaymentCurrencyForThisCurrency $_paymentCurrencyCode');
          } else {
            // Kur bilgisi yoksa real-time kur kullan
            totalInPaymentCurrencyForThisCurrency = ExchangeRateService()
                .convertCurrency(total, currency, _paymentCurrencyCode);
            debugPrint(
                'DEBUG: Genel toplam real-time kur kullanıldı - $total $currency = $totalInPaymentCurrencyForThisCurrency $_paymentCurrencyCode');
          }
        } catch (e) {
          debugPrint('Genel toplam para birimi dönüşüm hatası: $e');
          totalInPaymentCurrencyForThisCurrency = total;
        }
      }
      totalInPaymentCurrency += totalInPaymentCurrencyForThisCurrency;

      currencyCards.add(_buildCurrencySummaryCardWithPaymentCurrency(
        currency: currency,
        subtotal: subtotal,
        discount: totalDiscount,
        tax: totalTax,
        total: total,
        paymentCurrency: _paymentCurrencyCode,
        onTotalCalculated: (paymentCurrencyAmount) {
          // Bu callback artık kullanılmıyor ama metodun imzası için gerekli
        },
        items: items,
      ));
    }

    return Column(
      children: [
        // Her para birimi için ayrı kart
        ...currencyCards,
        // GENEL TOPLAM kartı
        const SizedBox(height: 16.0),
        _buildGrandTotalCardWithPaymentCurrency(
            totalInPaymentCurrency, _paymentCurrencyCode),
      ],
    );
  }

  Widget _buildCurrencySummaryCardWithPaymentCurrency({
    required String currency,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required String paymentCurrency,
    required Function(double) onTotalCalculated,
    required List<SaleItem> items,
  }) {
    return FutureBuilder<double?>(
      future: _convertToTargetCurrencyWithProductRate(
          total, currency, paymentCurrency, items),
      builder: (context, snapshot) {
        double totalInPaymentCurrency = total;

        if (snapshot.hasData && snapshot.data != null) {
          totalInPaymentCurrency = snapshot.data!;
          onTotalCalculated(totalInPaymentCurrency);
        } else if (currency == paymentCurrency) {
          onTotalCalculated(total);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Para birimi başlığı
                Text(
                  'Para Birimi: $currency',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16.0),

                // Ara Toplam
                _buildSummaryRow(
                    'Ara Toplam:', _formatMoney(subtotal, currency: currency)),

                // İskonto
                if (discount > 0)
                  _buildSummaryRow('İskonto:',
                      '-${_formatMoney(discount, currency: currency)}',
                      isNegative: true),

                // KDV
                if (tax > 0)
                  _buildSummaryRow(
                      'KDV:', '+${_formatMoney(tax, currency: currency)}',
                      isPositive: true),

                const SizedBox(height: 8.0),

                // Kur bilgisi (ödeme para birimi dışındaki para birimleri için)
                if (currency != paymentCurrency) ...[
                  Text(
                    'Kur: 1 $currency = ${(totalInPaymentCurrency / total).toStringAsFixed(4)} $paymentCurrency',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],

                // Toplam
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatMoney(total, currency: currency),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green.shade700,
                            ),
                          ),
                          if (currency != paymentCurrency) ...[
                            const SizedBox(height: 2.0),
                            Text(
                              '(${_formatMoney(totalInPaymentCurrency, currency: paymentCurrency)})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Ürün kurlarını kullanarak para birimi dönüşümü yapar
  Future<double?> _convertToTargetCurrencyWithProductRate(double amount,
      String fromCurrency, String toCurrency, List<SaleItem> items) async {
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

  Widget _buildCurrencySummaryCard({
    required String currency,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required Function(double) onTotalCalculated,
    required List<SaleItem> items,
  }) {
    return FutureBuilder<double?>(
      future: _convertToTargetCurrencyWithProductRate(
          total, currency, 'TRY', items),
      builder: (context, snapshot) {
        double totalInTRY = total;

        if (snapshot.hasData && snapshot.data != null) {
          totalInTRY = snapshot.data!;
          onTotalCalculated(totalInTRY);
        } else if (currency == 'TRY') {
          onTotalCalculated(total);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Para birimi başlığı
                Text(
                  'Para Birimi: $currency',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16.0),

                // Ara Toplam
                _buildSummaryRow(
                    'Ara Toplam:', _formatMoney(subtotal, currency: currency)),

                // İskonto
                if (discount > 0)
                  _buildSummaryRow('İskonto:',
                      '-${_formatMoney(discount, currency: currency)}',
                      isNegative: true),

                // KDV
                if (tax > 0)
                  _buildSummaryRow(
                      'KDV:', '+${_formatMoney(tax, currency: currency)}',
                      isPositive: true),

                const SizedBox(height: 8.0),

                // Kur bilgisi (TRY dışındaki para birimleri için)
                if (currency != 'TRY') ...[
                  Text(
                    'Kur: 1 $currency = ${(totalInTRY / total).toStringAsFixed(4)} TRY',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],

                // Toplam
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatMoney(total, currency: currency),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green.shade700,
                            ),
                          ),
                          if (currency != 'TRY') ...[
                            const SizedBox(height: 2.0),
                            Text(
                              '(${_formatMoney(totalInTRY, currency: 'TRY')})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isNegative = false, bool isPositive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isNegative
                  ? Colors.red.shade600
                  : isPositive
                      ? Colors.green.shade600
                      : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandTotalCardWithPaymentCurrency(
      double totalInPaymentCurrency, String paymentCurrency) {
    // Toplam ürün miktarını hesapla
    final totalQuantity = _items.fold(0.0, (sum, item) => sum + item.quantity);

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
                  'GENEL TOPLAM ($paymentCurrency):',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _formatMoney(totalInPaymentCurrency,
                      currency: paymentCurrency),
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

  Widget _buildGrandTotalCard(double totalInTRY) {
    // Toplam ürün miktarını hesapla
    final totalQuantity = _items.fold(0.0, (sum, item) => sum + item.quantity);

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
                const Text(
                  'GENEL TOPLAM (TRY):',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _formatMoney(totalInTRY, currency: 'TRY'),
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
        existingItems: _items,
        customerDiscountRate: _customerDefaultDiscountRate,
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
      tenantId: '', // Repository'de set edilecek
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
        AppLogger.info('Stock movement recorded for product: ${item.productId}');
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
        AppLogger.info('Transaction created successfully for sale: $saleId');
      } catch (e) {
        AppLogger.error('Error creating transaction for sale: $saleId', e);
      }

      // Ödeme miktarı girilmişse tahsilat kaydı oluştur
      if (_paymentAmount != null && _paymentAmount! > 0) {
        double fxRate = 1.0;
        if (_paymentCurrencyCode.isNotEmpty &&
            _paymentCurrencyCode != _baseCurrencyCode) {
          await ExchangeRateService().getExchangeRate(_paymentCurrencyCode);
          final amt = ExchangeRateService()
              .convertCurrency(1.0, _paymentCurrencyCode, _baseCurrencyCode);
          fxRate = amt > 0 ? amt : 1.0;
        }

        final transactionService = TransactionService();
        final now = DateTime.now();
        final customerId = _customerIdController.text;
        final paymentCurrency = _paymentCurrencyCode.isNotEmpty
            ? _paymentCurrencyCode
            : _baseCurrencyCode;

        // 1) Müşteri ekstresi ödeme işlemi (base para birimi)
        double paymentAmountInBase = 0.0;
        try {
          paymentAmountInBase = paymentCurrency == _baseCurrencyCode
              ? _paymentAmount!
              : ExchangeRateService().convertCurrency(
                  _paymentAmount!, paymentCurrency, _baseCurrencyCode);

          final payTxn = Transaction(
            id: '',
            customerId: customerId,
            supplierId: null,
            type: TransactionType.payment,
            amount: paymentAmountInBase,
            currency: _baseCurrencyCode,
            description: 'Satış tahsilatı ($paymentCurrency)',
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
              'paymentCurrency': paymentCurrency,
              'paymentFxToBase': fxRate,
              'paymentAmountInPaymentCcy': _paymentAmount!,
              'baseCurrency': _baseCurrencyCode,
            },
          );
          await transactionService.createTransaction(payTxn);
          AppLogger.info('Payment transaction created successfully for sale: $saleId');
        } catch (e) {
          AppLogger.error('Error creating payment transaction for sale: $saleId', e);
        }

        // 2) Nakit yönetimi: uygun kasayı bul ve gelir işlemi oluştur
        try {
          // Kasaları çek
          final notifier = ref.read(cashManagementNotifierProvider.notifier);
          await notifier.getCashAccounts();
          final state = ref.read(cashManagementNotifierProvider);
          final accounts = state.cashAccounts;

          // Öncelik: ödeme para birimi ile aynı olan kasa → yoksa base para birimli kasa
          final target = accounts.firstWhere(
            (a) => a.currency.toUpperCase() == paymentCurrency.toUpperCase(),
            orElse: () => accounts.firstWhere(
              (a) =>
                  a.currency.toUpperCase() == _baseCurrencyCode.toUpperCase(),
              orElse: () => accounts.isNotEmpty
                  ? accounts.first
                  : throw Exception('Kasa bulunamadı'),
            ),
          );

          final amountInAccountCurrency =
              target.currency.toUpperCase() == paymentCurrency.toUpperCase()
                  ? _paymentAmount!
                  : ExchangeRateService().convertCurrency(
                      _paymentAmount!, paymentCurrency, target.currency);

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
                'Satış tahsilatı ${_saleNumberController.text} ($paymentCurrency)',
            reference: _saleNumberController.text,
            relatedDocumentId: saleId,
            relatedDocumentType: 'sale',
            transactionDate: now,
            dueDate: null,
            notes: null,
            attachments: const [],
            metadata: {
              'baseCurrency': _baseCurrencyCode,
              'paymentCurrency': paymentCurrency,
              'fxToBase': fxRate,
              'amountInBase': paymentAmountInBase,
            },
            createdAt: now,
            updatedAt: now,
            createdBy: 'system',
            updatedBy: null,
          );
          await useCase.call(trx);
          AppLogger.info('Cash transaction created successfully for sale: $saleId');
        } catch (e) {
          AppLogger.error('Error creating cash transaction for sale: $saleId', e);
        }
      }

      // Peşin ödemeyse: müşteri ekstresine payment ve nakit yönetime kasa geliri
      if (_isCashPayment) {
        double fxRate = 1.0;
        if (_paymentCurrencyCode != _baseCurrencyCode) {
          await ExchangeRateService().getExchangeRate(_paymentCurrencyCode);
          final amt = ExchangeRateService()
              .convertCurrency(1.0, _paymentCurrencyCode, _baseCurrencyCode);
          fxRate = amt > 0 ? amt : 1.0;
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
      tenantId: '', // Repository'de set edilecek
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
    final items = <DropdownMenuItem<String>>[];
    final seen = <String>{};

    // Customer seçili değilse her iki adresi de göster
    if (customerId.isEmpty) {
      // Fatura adresi
      if (_billingAddress != null &&
          _billingAddress!.isNotEmpty &&
          !seen.contains(_billingAddress!)) {
        seen.add(_billingAddress!);
        items.add(DropdownMenuItem(
          value: _billingAddress!,
          child: Text(_billingAddress!, overflow: TextOverflow.ellipsis),
        ));
      }

      // Sevk adresi (fatura adresinden farklıysa)
      if (_shippingAddress != null &&
          _shippingAddress!.isNotEmpty &&
          !seen.contains(_shippingAddress!)) {
        seen.add(_shippingAddress!);
        items.add(DropdownMenuItem(
          value: _shippingAddress!,
          child: Text(_shippingAddress!, overflow: TextOverflow.ellipsis),
        ));
      }
    } else {
      // Customer seçiliyse customer adreslerini al
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

      // Ana adres
      if (baseAddress != null &&
          baseAddress.isNotEmpty &&
          !seen.contains(baseAddress)) {
        seen.add(baseAddress);
        items.add(DropdownMenuItem(
          value: baseAddress,
          child: Text(baseAddress, overflow: TextOverflow.ellipsis),
        ));
      }

      // Branch adresleri
      if (asyncCustomer.hasValue && asyncCustomer.value?.branches != null) {
        for (final br in asyncCustomer.value!.branches!) {
          if (br.address.isNotEmpty && !seen.contains(br.address)) {
            seen.add(br.address);
            items.add(DropdownMenuItem(
              value: br.address,
              child: Text('${br.name} • ${br.address}',
                  overflow: TextOverflow.ellipsis),
            ));
          }
        }
      }

      // Local adresleri de ekle (customer seçili olsa bile)
      if (_billingAddress != null &&
          _billingAddress!.isNotEmpty &&
          !seen.contains(_billingAddress!)) {
        seen.add(_billingAddress!);
        items.add(DropdownMenuItem(
          value: _billingAddress!,
          child: Text(_billingAddress!, overflow: TextOverflow.ellipsis),
        ));
      }

      if (_shippingAddress != null &&
          _shippingAddress!.isNotEmpty &&
          !seen.contains(_shippingAddress!)) {
        seen.add(_shippingAddress!);
        items.add(DropdownMenuItem(
          value: _shippingAddress!,
          child: Text(_shippingAddress!, overflow: TextOverflow.ellipsis),
        ));
      }
    }

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

    // Final duplicate check - bu çok önemli!
    final finalItems = <DropdownMenuItem<String>>[];
    final finalSeen = <String>{};

    for (final item in items) {
      if (item.value != null && !finalSeen.contains(item.value)) {
        finalSeen.add(item.value!);
        finalItems.add(item);
      }
    }

    return finalItems;
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
              p.salesTaxRate, // Ürünün gerçek KDV oranı
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
  final List<SaleItem> existingItems;
  final double customerDiscountRate;
  const _AddItemDialog(
      {required this.onAdd,
      required this.paymentCurrencyCode,
      required this.baseCurrencyCode,
      required this.existingItems,
      required this.customerDiscountRate});

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
    // Mevcut ürünlerde aynı para birimi var mı kontrol et
    final existingCurrencies =
        widget.existingItems.map((item) => item.currency).toSet();

    // Eğer mevcut ürün yoksa, para birimi seçimi ve kur bilgisi göster
    if (existingCurrencies.isEmpty) {
      setState(() {
        _showCurrencySelection = true;
        _showExchangeRate = true;
        _lineCurrencyCode = 'TRY'; // Varsayılan para birimi
      });
      return;
    }

    // Eğer sadece TRY varsa, para birimi seçimi göster (kullanıcı farklı para birimi seçebilir)
    if (existingCurrencies.length == 1 && existingCurrencies.contains('TRY')) {
      setState(() {
        _showCurrencySelection = true;
        _showExchangeRate = true;
        _lineCurrencyCode = 'TRY';
      });
      return;
    }

    // Eğer birden fazla para birimi varsa veya TRY dışında para birimi varsa
    // Kullanıcı yeni para birimi seçebilir, para birimi seçimi göster
    setState(() {
      _showCurrencySelection = true;
      _showExchangeRate = true;
      _lineCurrencyCode = 'TRY'; // Varsayılan para birimi
    });
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

                        // Aynı para birimindeki ürün var mı kontrol et
                        final existingItem = widget.existingItems.firstWhere(
                          (item) => item.currency == v,
                          orElse: () => const SaleItem(
                            id: '',
                            saleId: '',
                            productId: '',
                            productName: '',
                            quantity: 0,
                            unitPrice: 0,
                            discountRate: 0,
                            discountAmount: 0,
                            taxRate: 0,
                            taxAmount: 0,
                            totalAmount: 0,
                            currency: '',
                            description: '',
                          ),
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
                        } else {
                          // Aynı para birimindeki ürün yoksa, kur bilgisini göster
                          setState(() => _showExchangeRate = true);

                          // Kur: 1 LINE = ? BASE
                          if (v == widget.baseCurrencyCode) {
                            setState(() => _fxRateToTry = 1.0);
                          } else {
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
                            } catch (e) {
                              debugPrint('Otomatik kur alma hatası: $e');
                              setState(() => _fxRateToTry = null);
                            }
                          }
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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Para birimi: $_lineCurrencyCode (İlk ürünün kur bilgisi kullanılıyor)',
                        style: TextStyle(
                          color: Colors.blue.shade800,
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
                _lineCurrencyCode != _productCurrencyCode &&
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
      fxRateToBase: _fxRateToTry, // Ürün eklerken girilen kur bilgisini aktar
    );

    // Ürün hafızasını kaydet
    if (_currentProductId != null) {
      _saveProductMemory(_currentProductId!);
    }

    debugPrint('Ürün ekleniyor: ${item.productName}');
    widget.onAdd(item);
    debugPrint('Ürün eklendi, dialog kapatılıyor');
    Navigator.pop(context);
  }
}

/// Ürün düzenleme dialog'u
class _PaymentAmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Sadece rakamları, nokta ve virgülü al
    final cleanValue = newValue.text.replaceAll(RegExp(r'[^\d.,]'), '');
    if (cleanValue.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Eğer sadece rakamlar varsa, ondalık kısmı olmayan sayı olarak kabul et
    if (!cleanValue.contains('.') && !cleanValue.contains(',')) {
      // Sadece rakamlar - binlik ayırıcı ekle
      final number = int.tryParse(cleanValue);
      if (number == null) return oldValue;

      final formatter = NumberFormat('#,##0', 'tr_TR');
      final formatted = formatter.format(number);

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // Ondalık sayı formatı
    String formatted = cleanValue;

    // Nokta ve virgül kontrolü
    final dotCount = cleanValue.split('.').length - 1;
    final commaCount = cleanValue.split(',').length - 1;

    if (dotCount > 1 || commaCount > 1) {
      return oldValue; // Geçersiz format
    }

    // Nokta ondalık ayırıcı, virgül kuruş ayırıcı
    if (cleanValue.contains('.') && cleanValue.contains(',')) {
      // Hem nokta hem virgül var - nokta binlik, virgül kuruş
      final parts = cleanValue.split(',');
      if (parts.length == 2) {
        final mainPart = parts[0].replaceAll('.', '');
        final decimalPart = parts[1];

        if (decimalPart.length <= 2) {
          final number = int.tryParse(mainPart);
          if (number != null) {
            final formatter = NumberFormat('#,##0', 'tr_TR');
            final formattedMain = formatter.format(number);
            formatted = '$formattedMain,$decimalPart';
          }
        } else {
          return oldValue; // Kuruş kısmı 2 haneden fazla
        }
      }
    } else if (cleanValue.contains(',')) {
      // Sadece virgül var - kuruş ayırıcı
      final parts = cleanValue.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        final mainPart = parts[0];
        final decimalPart = parts[1];

        final number = int.tryParse(mainPart);
        if (number != null) {
          final formatter = NumberFormat('#,##0', 'tr_TR');
          final formattedMain = formatter.format(number);
          formatted = '$formattedMain,$decimalPart';
        }
      } else {
        return oldValue;
      }
    } else if (cleanValue.contains('.')) {
      // Sadece nokta var - binlik ayırıcı
      final number = int.tryParse(cleanValue.replaceAll('.', ''));
      if (number != null) {
        final formatter = NumberFormat('#,##0', 'tr_TR');
        formatted = formatter.format(number);
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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
