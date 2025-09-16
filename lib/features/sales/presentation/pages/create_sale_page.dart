import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/features/sales/presentation/providers/sale_providers.dart';
// import 'package:tamgaci/features/sales/presentation/widgets/sale_form_widget.dart';
// import 'package:tamgaci/core/routes/routes.dart';
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

  SaleType _selectedType = SaleType.sale;
  SaleStatus _selectedStatus = SaleStatus.draft;
  PaymentStatus _selectedPaymentStatus = PaymentStatus.pending;
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  List<SaleItem> _items = [];
  double _discountAmount = 0.0;
  double _taxRate = 18.0;

  @override
  void initState() {
    super.initState();
    if (widget.saleId != null) {
      _loadSale();
    }
  }

  @override
  void dispose() {
    _saleNumberController.dispose();
    _customerIdController.dispose();
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadSale() {
    if (widget.saleId != null) {
      ref.read(saleNotifierProvider.notifier).getSale(widget.saleId!);
    }
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
        message: state.error!,
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
                  _buildBasicInfoCard(),
                  const SizedBox(height: 16.0),
                  _buildItemsCard(),
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
                Expanded(
                  child: DropdownButtonFormField<SaleType>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Satış Türü',
                      border: OutlineInputBorder(),
                    ),
                    items: SaleType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
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
                  child: TextFormField(
                    controller: _customerIdController,
                    decoration: const InputDecoration(
                      labelText: 'Müşteri ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Müşteri ID gerekli';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Müşteri Adı',
                      border: OutlineInputBorder(),
                    ),
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
                const SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<PaymentStatus>(
                    initialValue: _selectedPaymentStatus,
                    decoration: const InputDecoration(
                      labelText: 'Ödeme Durumu',
                      border: OutlineInputBorder(),
                    ),
                    items: PaymentStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentStatus = value!;
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
                        '${item.quantity} x ₺${item.unitPrice.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₺${item.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final subtotal = _items.fold(0.0, (sum, item) => sum + item.totalAmount);
    final taxAmount = subtotal * (_taxRate / 100);
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ara Toplam:'),
                Text('₺${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('KDV (%${_taxRate.toStringAsFixed(0)}):'),
                Text('₺${taxAmount.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('İndirim:'),
                Text('₺${_discountAmount.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(),
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
                  '₺${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
    // Basit bir ürün ekleme dialog'u
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onAdd: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _saveSale() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir ürün eklemelisiniz')),
      );
      return;
    }

    final subtotal = _items.fold(0.0, (sum, item) => sum + item.totalAmount);
    final taxAmount = subtotal * (_taxRate / 100);
    final total = subtotal + taxAmount - _discountAmount;

    final sale = Sale(
      id: widget.saleId ?? '',
      saleNumber: _saleNumberController.text,
      customerId: _customerIdController.text,
      customerName: _customerNameController.text.isNotEmpty
          ? _customerNameController.text
          : null,
      type: _selectedType,
      status: _selectedStatus,
      paymentStatus: _selectedPaymentStatus,
      saleDate: _selectedDate,
      dueDate: _dueDate,
      items: _items,
      subtotal: subtotal,
      taxRate: _taxRate,
      taxAmount: taxAmount,
      discountAmount: _discountAmount,
      totalAmount: total,
      currency: 'TRY',
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.saleId != null) {
      ref.read(saleNotifierProvider.notifier).updateSale(sale);
    } else {
      ref.read(saleNotifierProvider.notifier).createSale(sale);
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
}

/// Ürün ekleme dialog'u
class _AddItemDialog extends StatefulWidget {
  final Function(SaleItem) onAdd;

  const _AddItemDialog({required this.onAdd});

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

  @override
  void dispose() {
    _productIdController.dispose();
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ürün Ekle'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _productIdController,
              decoration: const InputDecoration(
                labelText: 'Ürün ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ürün ID gerekli';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
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
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    controller: _unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Birim Fiyat',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Birim fiyat gerekli';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) < 0) {
                        return 'Geçerli fiyat giriniz';
                      }
                      return null;
                    },
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
    final unitPrice = double.parse(_unitPriceController.text);
    final totalAmount = quantity * unitPrice;

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
      unitPrice: unitPrice,
      discountRate: 0,
      discountAmount: 0,
      taxRate: 0,
      taxAmount: 0,
      totalAmount: totalAmount,
    );

    widget.onAdd(item);
    Navigator.pop(context);
  }
}
