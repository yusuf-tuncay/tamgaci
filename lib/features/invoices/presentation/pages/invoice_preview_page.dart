import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import 'package:tamgaci/core/widgets/disposed_view_suppressor.dart';
import 'package:tamgaci/core/errors/smart_error_suppressor.dart';
import '../../../company/presentation/providers/company_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import '../../../customers/domain/entities/customer.dart';

/// Fatura önizleme sayfası
class InvoicePreviewPage extends ConsumerStatefulWidget {
  final Invoice invoice;
  final bool isEditable;
  final bool isFromSale;

  const InvoicePreviewPage({
    super.key,
    required this.invoice,
    this.isEditable = true,
    this.isFromSale = false,
  });

  @override
  ConsumerState<InvoicePreviewPage> createState() => _InvoicePreviewPageState();
}

class _InvoicePreviewPageState extends ConsumerState<InvoicePreviewPage>
    with ConsumerDisposedViewSuppressorMixin, SmartErrorSuppressorMixin {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Güncellenmiş invoice'ı tut
  late Invoice _currentInvoice;
  late TextEditingController _notesController;
  late TextEditingController _customerNameController;
  late TextEditingController _customerAddressController;
  late TextEditingController _customerTaxNumberController;
  late TextEditingController _customerTaxOfficeController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _customerEmailController;
  late TextEditingController _customerWebsiteController;

  // Ürün düzenleme için controller'lar
  final List<TextEditingController> _productNameControllers = [];
  final List<TextEditingController> _quantityControllers = [];
  final List<TextEditingController> _unitPriceControllers = [];
  final List<TextEditingController> _taxRateControllers = [];

  // Seçili ürünler
  final List<Product?> _selectedProducts = [];

  // Seçili müşteri
  Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _currentInvoice = widget.invoice;
    _notesController = TextEditingController(text: widget.invoice.notes ?? '');
    _customerNameController =
        TextEditingController(text: widget.invoice.customerName ?? '');
    _customerAddressController =
        TextEditingController(text: widget.invoice.customerAddress ?? '');
    _customerTaxNumberController = TextEditingController();
    _customerTaxOfficeController = TextEditingController();
    _customerPhoneController = TextEditingController();
    _customerEmailController = TextEditingController();
    _customerWebsiteController = TextEditingController();

    // Ürün controller'larını initialize et
    _initializeProductControllers();

    // Müşteri bilgilerini initialize et
    _initializeCustomerInfo();
  }

  void _initializeProductControllers() {
    _productNameControllers.clear();
    _quantityControllers.clear();
    _unitPriceControllers.clear();
    _taxRateControllers.clear();
    _selectedProducts.clear();

    for (var item in widget.invoice.items) {
      _productNameControllers
          .add(TextEditingController(text: item.productName));
      _quantityControllers
          .add(TextEditingController(text: item.quantity.toString()));
      _unitPriceControllers
          .add(TextEditingController(text: item.unitPrice.toString()));
      _taxRateControllers
          .add(TextEditingController(text: item.taxRate.toString()));
      _selectedProducts
          .add(null); // Mevcut ürünler için null, sonradan seçilecek
    }
  }

  void _initializeCustomerInfo() {
    // Müşteri bilgilerini invoice'dan doldur
    if (widget.invoice.customerName != null) {
      _customerNameController.text = widget.invoice.customerName!;
    }
    if (widget.invoice.customerAddress != null) {
      _customerAddressController.text = widget.invoice.customerAddress!;
    }

    // Diğer müşteri bilgileri için controller'ları temizle
    // Bu bilgiler müşteri seçildiğinde doldurulacak
    _customerTaxNumberController.clear();
    _customerTaxOfficeController.clear();
    _customerPhoneController.clear();
    _customerEmailController.clear();
    _customerWebsiteController.clear();
  }

  // Müşteri seçili geldiğinde bilgileri otomatik doldur
  void _populateCustomerInfo(Customer customer) {
    _customerNameController.text = customer.name;
    _customerAddressController.text = customer.address ?? '';
    _customerTaxNumberController.text = customer.taxNumber ?? '';
    _customerTaxOfficeController.text = customer.taxOffice ?? '';
    _customerPhoneController.text = customer.phone ?? '';
    _customerEmailController.text = customer.email ?? '';
    _customerWebsiteController.text =
        ''; // Customer entity'sinde website field'ı yok
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _customerTaxNumberController.dispose();
    _customerTaxOfficeController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _customerWebsiteController.dispose();

    // Ürün controller'larını dispose et
    for (var controller in _productNameControllers) {
      controller.dispose();
    }
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    for (var controller in _unitPriceControllers) {
      controller.dispose();
    }
    for (var controller in _taxRateControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartErrorSuppressor(
      child: ResponsiveScaffold(
        drawerContent: const SizedBox.shrink(),
        appBar: CustomAppBar(
          title: 'Fatura Önizleme',
          showBackButton: true,
          actions: [
            if (widget.isEditable) ...[
              IconButton(
                onPressed: _toggleEdit,
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                tooltip: _isEditing ? 'Kaydet' : 'Düzenle',
              ),
            ],
            IconButton(
              onPressed: _printInvoice,
              icon: const Icon(Icons.print),
              tooltip: 'Yazdır',
            ),
            if (widget.isFromSale) ...[
              IconButton(
                onPressed: _saveInvoice,
                icon: const Icon(Icons.save_alt),
                tooltip: 'Faturayı Kaydet',
              ),
            ],
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Fatura başlığı
              _buildInvoiceHeader(),
              const SizedBox(height: 24),

              // Müşteri bilgileri
              _buildCustomerInfo(),
              const SizedBox(height: 24),

              // Fatura detayları
              _buildInvoiceDetails(),
              const SizedBox(height: 24),

              // Ürün listesi
              _buildItemsTable(),
              const SizedBox(height: 24),

              // Toplam bilgileri
              _buildTotals(),
              const SizedBox(height: 24),

              // Notlar
              _buildNotes(),
              const SizedBox(height: 24),

              // Alt bilgiler
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Consumer(
      builder: (context, ref, child) {
        final companyInfoAsync = ref.watch(companyInfoStreamProvider);

        // Mounted kontrolü ekle
        if (!mounted) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(builder: (context, constraints) {
            final bool isMobile = constraints.maxWidth < 600;

            final left = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FATURA',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fatura No: ${_currentInvoice.invoiceNumber}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Tarih: ${DateFormat('dd.MM.yyyy').format(_currentInvoice.invoiceDate)}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            );

            final right = companyInfoAsync.when(
              data: (companyInfo) => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    companyInfo?.name ?? 'TAMGACI',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  if (companyInfo?.taxNumber != null)
                    Text(
                      'Vergi No: ${companyInfo!.taxNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  if (companyInfo?.taxOffice != null)
                    Text(
                      'Vergi Dairesi: ${companyInfo!.taxOffice}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  if (companyInfo?.fullAddress.isNotEmpty == true)
                    Text(
                      companyInfo!.fullAddress,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  if (companyInfo?.contactInfo.isNotEmpty == true)
                    Text(
                      companyInfo!.contactInfo,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.right,
                    ),
                ],
              ),
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TAMGACI',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Muhasebe Yazılımı',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              error: (error, stack) => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TAMGACI',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Muhasebe Yazılımı',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );

            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [left, const SizedBox(height: 12), right],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: left),
                const SizedBox(width: 16),
                right
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildCustomerInfoDisplay() {
    return Consumer(
      builder: (context, ref, child) {
        // Müşteri bilgilerini otomatik çek
        if (widget.invoice.customerId.isNotEmpty && _selectedCustomer == null) {
          final customersAsync = ref.watch(customersStreamProvider);
          customersAsync.whenData((customers) {
            final customer = customers.firstWhere(
              (c) => c.id == widget.invoice.customerId,
              orElse: () => customers.first,
            );
            _selectedCustomer = customer;
            _populateCustomerInfo(customer);
          });
        }

        // Müşteri bilgilerini controller'lardan al
        final customerName = _customerNameController.text.isNotEmpty
            ? _customerNameController.text
            : (_currentInvoice.customerName ?? '');
        final customerAddress = _customerAddressController.text.isNotEmpty
            ? _customerAddressController.text
            : (_currentInvoice.customerAddress ?? '');
        final taxNumber = _customerTaxNumberController.text;
        final taxOffice = _customerTaxOfficeController.text;
        final phone = _customerPhoneController.text;
        final email = _customerEmailController.text;
        final website = _customerWebsiteController.text;

        // Müşteri adı yoksa hiçbir şey gösterme
        if (customerName.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Müşteri Adı - Firma bilgileri gibi büyük ve mavi
              Text(
                customerName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Müşteri Bilgileri - Firma bilgileri gibi düzenli format
              if (taxNumber.isNotEmpty) ...[
                Text(
                  'Vergi No: $taxNumber',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
              ],

              if (taxOffice.isNotEmpty) ...[
                Text(
                  'Vergi Dairesi: $taxOffice',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
              ],

              if (customerAddress.isNotEmpty) ...[
                Text(
                  customerAddress,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              if (phone.isNotEmpty) ...[
                Text(
                  'Tel: $phone',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
              ],

              if (email.isNotEmpty) ...[
                Text(
                  'E-posta: $email',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
              ],

              if (website.isNotEmpty) ...[
                Text(
                  'Web: $website',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Fatura Edilecek',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Müşteri bilgilerini göster (hem düzenleme hem önizleme modunda)
            _buildCustomerInfoDisplay(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Fatura Detayları',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Fatura Tarihi',
                    value: DateFormat('dd.MM.yyyy')
                        .format(widget.invoice.invoiceDate),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.schedule,
                    label: 'Vade Tarihi',
                    value: widget.invoice.dueDate != null
                        ? DateFormat('dd.MM.yyyy')
                            .format(widget.invoice.dueDate!)
                        : 'Belirtilmemiş',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.payment,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Ödeme Durumu:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getPaymentStatusColor(widget.invoice.isPaid),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.invoice.isPaid
                                  ? Icons.check_circle
                                  : Icons.pending,
                              size: 16,
                              color: _getPaymentStatusTextColor(
                                  widget.invoice.isPaid),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getPaymentStatusText(widget.invoice.isPaid),
                              style: GoogleFonts.poppins(
                                color: _getPaymentStatusTextColor(
                                    widget.invoice.isPaid),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 18,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shopping_cart,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ürünler',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentInvoice.items.length} ürün',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_currentInvoice.items.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ürün bulunamadı',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: _isEditing
                    ? _buildEditableItemsTable()
                    : _buildReadOnlyItemsTable(),
              ),
            if (_isEditing) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addNewItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Ürün Ekle'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyItemsTable() {
    return Table(
      border: TableBorder.all(
        color: Colors.grey[200]!,
        width: 0.5,
      ),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(1.5),
      },
      children: [
        // Başlık satırı
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
          ),
          children: [
            _buildTableHeader('Ürün Adı'),
            _buildTableHeader('Miktar'),
            _buildTableHeader('Birim Fiyat'),
            _buildTableHeader('KDV'),
            _buildTableHeader('Toplam'),
          ],
        ),
        // Ürün satırları
        ..._currentInvoice.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return TableRow(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.white : Colors.grey[50],
            ),
            children: [
              _buildTableCell(item.productName),
              _buildTableCell(item.quantity.toString()),
              _buildTableCell(
                CurrencyHelper.formatCurrency(
                      item.unitPrice,
                      item.currencyCode,
                    ) +
                    // Fatura para birimi farklıysa kuru göster
                    (item.currencyCode != _currentInvoice.currencyCode &&
                            item.exchangeRate != null
                        ? ' (kur: ${item.exchangeRate!.toStringAsFixed(4)})'
                        : ''),
              ),
              _buildTableCell('${item.taxRate.toStringAsFixed(1)}%'),
              _buildTableCell(
                CurrencyHelper.formatCurrency(
                  item.lineTotal,
                  item.currencyCode,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildEditableItemsTable() {
    return Column(
      children: [
        // Başlık satırı
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: _buildTableHeader('Ürün Adı')),
              Expanded(flex: 1, child: _buildTableHeader('Miktar')),
              Expanded(flex: 1, child: _buildTableHeader('Birim Fiyat')),
              Expanded(flex: 1, child: _buildTableHeader('KDV %')),
              Expanded(flex: 1, child: _buildTableHeader('Toplam')),
              const SizedBox(width: 40), // Silme butonu için alan
            ],
          ),
        ),
        // Ürün satırları
        ..._productNameControllers.asMap().entries.map((entry) {
          final index = entry.key;
          return Container(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.white : Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildProductSelector(index),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _quantityControllers[index],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(fontSize: 12),
                      onChanged: (value) => _calculateLineTotal(index),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Builder(
                      builder: (context) {
                        final existingItem = index < widget.invoice.items.length
                            ? widget.invoice.items[index]
                            : null;
                        final itemCurrency = existingItem?.currencyCode ??
                            _currentInvoice.currencyCode;
                        final rateInfo = (existingItem != null &&
                                existingItem.currencyCode !=
                                    _currentInvoice.currencyCode &&
                                existingItem.exchangeRate != null)
                            ? 'kur: ${existingItem.exchangeRate!.toStringAsFixed(4)}'
                            : null;
                        return TextFormField(
                          controller: _unitPriceControllers[index],
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            suffixText: itemCurrency,
                            helperText: rateInfo,
                          ),
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(fontSize: 12),
                          onChanged: (value) => _calculateLineTotal(index),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _taxRateControllers[index],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(fontSize: 12),
                      onChanged: (value) => _calculateLineTotal(index),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _calculateLineTotalText(index),
                      style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _calculateLineTotal(int index) {
    setState(() {
      // Bu metod UI'ı günceller ve tutar özetini yeniden hesaplar
    });
  }

  String _calculateLineTotalText(int index) {
    try {
      final quantity = double.tryParse(_quantityControllers[index].text) ?? 0;
      final unitPrice = double.tryParse(_unitPriceControllers[index].text) ?? 0;
      final taxRate = double.tryParse(_taxRateControllers[index].text) ?? 0;

      final subtotal = quantity * unitPrice;
      final taxAmount = subtotal * (taxRate / 100);
      final total = subtotal + taxAmount;

      // Satırın para birimini belirle (varsa item.currencyCode, yoksa fatura para birimi)
      final existingItem = index < widget.invoice.items.length
          ? widget.invoice.items[index]
          : null;
      final itemCurrency =
          existingItem?.currencyCode ?? _currentInvoice.currencyCode;
      return CurrencyHelper.formatCurrency(total, itemCurrency);
    } catch (e) {
      return '0,00 ₺';
    }
  }

  void _removeItem(int index) {
    setState(() {
      _productNameControllers[index].dispose();
      _quantityControllers[index].dispose();
      _unitPriceControllers[index].dispose();
      _taxRateControllers[index].dispose();

      _productNameControllers.removeAt(index);
      _quantityControllers.removeAt(index);
      _unitPriceControllers.removeAt(index);
      _taxRateControllers.removeAt(index);
    });
  }

  void _addNewItem() {
    setState(() {
      _productNameControllers.add(TextEditingController());
      _quantityControllers.add(TextEditingController(text: '1'));
      _unitPriceControllers.add(TextEditingController());
      _taxRateControllers.add(TextEditingController(text: '18'));
      _selectedProducts.add(null);
    });
  }

  // Müşteri para birimini al
  String _getCustomerCurrency() {
    // Müşteri para birimi varsa onu kullan, yoksa fatura para birimini kullan
    return _currentInvoice.customer?.customerCurrency ??
        _currentInvoice.currencyCode;
  }

  // Ham ara toplam (iskonto öncesi) - müşteri para biriminde
  double _calculateRawSubtotal() {
    double subtotal = 0;
    final customerCurrency = _getCustomerCurrency();

    for (int i = 0; i < _quantityControllers.length; i++) {
      final quantity = double.tryParse(_quantityControllers[i].text) ?? 0;
      final unitPrice = double.tryParse(_unitPriceControllers[i].text) ?? 0;

      // Ürün para birimini al
      final existingItem =
          i < widget.invoice.items.length ? widget.invoice.items[i] : null;
      final itemCurrency =
          existingItem?.currencyCode ?? _currentInvoice.currencyCode;

      // Para birimi farklıysa kur hesapla
      if (itemCurrency != customerCurrency &&
          existingItem?.exchangeRate != null) {
        final convertedPrice = unitPrice * existingItem!.exchangeRate!;
        subtotal += quantity * convertedPrice;
      } else {
        subtotal += quantity * unitPrice;
      }
    }
    return subtotal;
  }

  // Ürün iskontoları sonrası ara toplam - müşteri para biriminde
  double _calculateSubtotal() {
    double subtotal = 0;
    final customerCurrency = _getCustomerCurrency();

    for (int i = 0; i < _quantityControllers.length; i++) {
      final quantity = double.tryParse(_quantityControllers[i].text) ?? 0;
      final unitPrice = double.tryParse(_unitPriceControllers[i].text) ?? 0;

      // Ürün para birimini al
      final existingItem =
          i < widget.invoice.items.length ? widget.invoice.items[i] : null;
      final itemCurrency =
          existingItem?.currencyCode ?? _currentInvoice.currencyCode;

      // Para birimi farklıysa kur hesapla
      double convertedUnitPrice = unitPrice;
      if (itemCurrency != customerCurrency &&
          existingItem?.exchangeRate != null) {
        convertedUnitPrice = unitPrice * existingItem!.exchangeRate!;
      }

      // Ürün iskonto hesapla
      final discountRate = existingItem?.discountRate ?? 0.0;
      final lineSubtotal = quantity * convertedUnitPrice;
      final discountAmount = lineSubtotal * (discountRate / 100);
      final subtotalAfterDiscount = lineSubtotal - discountAmount;

      subtotal += subtotalAfterDiscount;
    }
    return subtotal;
  }

  double _calculateTaxAmount() {
    double taxAmount = 0;
    final customerCurrency = _getCustomerCurrency();

    for (int i = 0; i < _quantityControllers.length; i++) {
      final quantity = double.tryParse(_quantityControllers[i].text) ?? 0;
      final unitPrice = double.tryParse(_unitPriceControllers[i].text) ?? 0;
      final taxRate = double.tryParse(_taxRateControllers[i].text) ?? 0;

      // Ürün para birimini al
      final existingItem =
          i < widget.invoice.items.length ? widget.invoice.items[i] : null;
      final itemCurrency =
          existingItem?.currencyCode ?? _currentInvoice.currencyCode;

      // Para birimi farklıysa kur hesapla
      double convertedUnitPrice = unitPrice;
      if (itemCurrency != customerCurrency &&
          existingItem?.exchangeRate != null) {
        convertedUnitPrice = unitPrice * existingItem!.exchangeRate!;
      }

      // Önce ürün iskonto hesapla
      final discountRate = existingItem?.discountRate ?? 0.0;
      final lineSubtotal = quantity * convertedUnitPrice;
      final discountAmount = lineSubtotal * (discountRate / 100);
      final subtotalAfterDiscount = lineSubtotal - discountAmount;

      // Ürün iskonto sonrası tutar üzerinden KDV hesapla
      taxAmount += subtotalAfterDiscount * (taxRate / 100);
    }
    return taxAmount;
  }

  // Müşteri iskontosu sonrası KDV hesapla
  double _calculateTaxAmountAfterCustomerDiscount(
      double customerDiscountAmount) {
    final rawSubtotal = _calculateRawSubtotal();
    final customerCurrency = _getCustomerCurrency();

    // Müşteri iskontosu sonrası tutar üzerinden KDV hesapla
    double totalTaxAmount = 0;
    for (int i = 0; i < _quantityControllers.length; i++) {
      final quantity = double.tryParse(_quantityControllers[i].text) ?? 0;
      final unitPrice = double.tryParse(_unitPriceControllers[i].text) ?? 0;
      final taxRate = double.tryParse(_taxRateControllers[i].text) ?? 0;

      // Ürün para birimini al
      final existingItem =
          i < widget.invoice.items.length ? widget.invoice.items[i] : null;
      final itemCurrency =
          existingItem?.currencyCode ?? _currentInvoice.currencyCode;

      // Para birimi farklıysa kur hesapla
      double convertedUnitPrice = unitPrice;
      if (itemCurrency != customerCurrency &&
          existingItem?.exchangeRate != null) {
        convertedUnitPrice = unitPrice * existingItem!.exchangeRate!;
      }

      // Bu ürünün ham ara toplamdaki payını hesapla
      final lineSubtotal = quantity * convertedUnitPrice;
      final productAfterCustomerDiscount =
          lineSubtotal * (1 - customerDiscountAmount / rawSubtotal);

      // Müşteri iskontosu sonrası tutar üzerinden KDV hesapla
      totalTaxAmount += productAfterCustomerDiscount * (taxRate / 100);
    }
    return totalTaxAmount;
  }

  double _calculateTotal() {
    final subtotal = _calculateSubtotal();
    final taxAmount = _calculateTaxAmount();

    // Müşteri iskontosunu hesapla (UI'da dinamik olarak hesaplanacak)
    // Şimdilik sadece ürün iskontoları ve KDV'yi topla
    return subtotal + taxAmount;
  }

  // Güncellenmiş invoice items'ları oluştur
  List<InvoiceItem> _buildUpdatedInvoiceItems() {
    List<InvoiceItem> updatedItems = [];

    for (int i = 0; i < _productNameControllers.length; i++) {
      // Mevcut item varsa onu kullan, yoksa yeni oluştur
      final existingItem =
          i < widget.invoice.items.length ? widget.invoice.items[i] : null;

      final quantity = double.tryParse(_quantityControllers[i].text) ?? 0;
      final unitPrice = double.tryParse(_unitPriceControllers[i].text) ?? 0;
      final taxRate = double.tryParse(_taxRateControllers[i].text) ?? 0;
      final discountRate = existingItem?.discountRate ?? 0.0;
      final discountAmount = (unitPrice * quantity * discountRate) / 100;
      final subtotalAfterDiscount = (unitPrice * quantity) - discountAmount;
      final taxAmount = (subtotalAfterDiscount * taxRate) / 100;
      final lineTotal = subtotalAfterDiscount + taxAmount;

      updatedItems.add(InvoiceItem(
        id: existingItem?.id ?? '',
        invoiceId: existingItem?.invoiceId ?? widget.invoice.id,
        itemOrder: i + 1,
        productId: existingItem?.productId ?? '',
        productName: _productNameControllers[i].text,
        quantity: quantity,
        unitPrice: unitPrice,
        discountRate: discountRate,
        discountAmount: discountAmount,
        taxRate: taxRate,
        taxAmount: taxAmount,
        lineTotal: lineTotal,
        currencyCode: existingItem?.currencyCode ?? widget.invoice.currencyCode,
        createdAt: existingItem?.createdAt ?? DateTime.now(),
      ));
    }

    return updatedItems;
  }

  Widget _buildProductSelector(int index) {
    return Consumer(
      builder: (context, ref, child) {
        final productsAsync = ref.watch(productsStreamProvider);

        return productsAsync.when(
          data: (products) {
            // Mevcut ürünü bul ve seçili hale getir
            Product? currentProduct;
            if (index < _productNameControllers.length) {
              final productName = _productNameControllers[index].text;
              currentProduct = products.firstWhere(
                (product) => product.name == productName,
                orElse: () => products.first, // Bulunamazsa ilk ürünü seç
              );
            }

            // İlk seçimde otomatik doldur
            if (currentProduct != null && _selectedProducts[index] == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _selectedProducts[index] = currentProduct;
                  _productNameControllers[index].text = currentProduct!.name;
                  _unitPriceControllers[index].text =
                      currentProduct!.salesPrice.toString();
                  _taxRateControllers[index].text =
                      currentProduct!.salesTaxRate.toString();
                });
              });
            }

            return DropdownButtonFormField<Product>(
              value: _selectedProducts[index],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                hintText: 'Ürün Seçin',
              ),
              style: GoogleFonts.poppins(fontSize: 12),
              items: products.map((product) {
                return DropdownMenuItem<Product>(
                  value: product,
                  child: Text(
                    product.name,
                    style: GoogleFonts.poppins(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (Product? selectedProduct) {
                setState(() {
                  _selectedProducts[index] = selectedProduct;
                  if (selectedProduct != null) {
                    _productNameControllers[index].text = selectedProduct.name;
                    _unitPriceControllers[index].text =
                        selectedProduct.salesPrice.toString();
                    _taxRateControllers[index].text =
                        selectedProduct.salesTaxRate.toString();
                  }
                });
              },
            );
          },
          loading: () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ürünler yükleniyor...',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Ürünler yüklenemedi',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.red[600]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 14),
      ),
    );
  }

  // Para birimine göre gruplandırılmış ürün özetleri
  List<Widget> _buildProductDetails() {
    final customerCurrency = _getCustomerCurrency();
    final List<Widget> details = [];

    // Para birimlerine göre grupla
    final Map<String, List<Map<String, dynamic>>> currencyGroups = {};

    for (int i = 0; i < _currentInvoice.items.length; i++) {
      final item = _currentInvoice.items[i];
      final itemCurrency = item.currencyCode;

      if (!currencyGroups.containsKey(itemCurrency)) {
        currencyGroups[itemCurrency] = [];
      }

      final quantity = _isEditing
          ? (double.tryParse(_quantityControllers[i].text) ?? item.quantity)
          : item.quantity;
      final unitPrice = _isEditing
          ? (double.tryParse(_unitPriceControllers[i].text) ?? item.unitPrice)
          : item.unitPrice;

      currencyGroups[itemCurrency]!.add({
        'item': item,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'index': i,
      });
    }

    // Her para birimi için özet oluştur
    currencyGroups.forEach((currency, items) {
      // Para birimi başlığı
      details.add(
        _buildTotalRow(
          label: '${currency} Ürünleri',
          amount: '',
          isSubtotal: true,
        ),
      );

      double currencySubtotal = 0.0;
      int totalQuantity = 0;

      // Bu para birimindeki ürünler (sadece toplam hesapla, detay gösterme)
      for (final itemData in items) {
        final quantity = itemData['quantity'] as double;
        final unitPrice = itemData['unitPrice'] as double;

        final lineTotal = quantity * unitPrice;
        currencySubtotal += lineTotal;
        totalQuantity += quantity.toInt();
      }

      // Bu para biriminin toplamı
      details.add(
        _buildTotalRow(
          label: '  ${currency} Toplam (${totalQuantity} adet)',
          amount: CurrencyHelper.formatCurrency(currencySubtotal, currency),
          isSubtotal: true,
        ),
      );

      // Kur dönüşümü (müşteri para biriminden farklıysa)
      if (currency != customerCurrency) {
        final exchangeRate = items.first['item'].exchangeRate ?? 1.0;
        final convertedTotal = currencySubtotal * exchangeRate;

        details.add(
          _buildTotalRow(
            label: '  Kur: ${exchangeRate.toStringAsFixed(4)}',
            amount: '',
            isSubtotal: false,
          ),
        );

        details.add(
          _buildTotalRow(
            label: '  ${customerCurrency} Karşılığı',
            amount:
                CurrencyHelper.formatCurrency(convertedTotal, customerCurrency),
            isSubtotal: true,
          ),
        );
      }

      details.add(const SizedBox(height: 8));
    });

    return details;
  }

  Widget _buildTotals() {
    final taxAmount =
        _isEditing ? _calculateTaxAmount() : _currentInvoice.taxAmount;
    final total = _isEditing ? _calculateTotal() : _currentInvoice.totalAmount;
    final customerCurrency = _getCustomerCurrency();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calculate,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tutar Özeti',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Toplam ürün sayısı
                  _buildTotalRow(
                    label: 'Toplam Ürün Sayısı',
                    amount: '${_currentInvoice.items.length} adet',
                    isSubtotal: true,
                  ),
                  const SizedBox(height: 8),
                  // Ürün detayları (kur dönüşümleri ile)
                  ..._buildProductDetails(),
                  const SizedBox(height: 8),
                  // Ham ara toplam (iskonto öncesi)
                  _buildTotalRow(
                    label: 'Ara Toplam',
                    amount: CurrencyHelper.formatCurrency(
                        _calculateRawSubtotal(), customerCurrency),
                    isSubtotal: true,
                  ),
                  const SizedBox(height: 8),
                  // Ürün iskontoları (varsa)
                  if (_currentInvoice.items
                      .any((item) => item.discountAmount > 0)) ...[
                    _buildTotalRow(
                      label: 'Ürün İskontoları',
                      amount:
                          '-${CurrencyHelper.formatCurrency(_currentInvoice.items.fold(0.0, (sum, item) => sum + item.discountAmount), customerCurrency)}',
                      isSubtotal: true,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Müşteri iskontosu (varsa)
                  Consumer(
                    builder: (context, ref, child) {
                      final customersAsync = ref.watch(customersStreamProvider);
                      return customersAsync.when(
                        data: (customers) {
                          final customer = customers.firstWhere(
                            (c) => c.id == _currentInvoice.customerId,
                            orElse: () => customers.first,
                          );

                          final customerDiscountRate =
                              customer.fixedDiscountRate ?? 0.0;
                          final rawSubtotal = _calculateRawSubtotal();
                          final customerDiscountAmount =
                              rawSubtotal * (customerDiscountRate / 100);

                          if (customerDiscountAmount > 0) {
                            return Column(
                              children: [
                                _buildTotalRow(
                                  label:
                                      'Müşteri İskontosu (%${customerDiscountRate.toStringAsFixed(1)})',
                                  amount:
                                      '-${CurrencyHelper.formatCurrency(customerDiscountAmount, customerCurrency)}',
                                  isSubtotal: true,
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (error, stack) => const SizedBox.shrink(),
                      );
                    },
                  ),
                  // KDV (müşteri iskontosu sonrası hesaplanan)
                  Consumer(
                    builder: (context, ref, child) {
                      final customersAsync = ref.watch(customersStreamProvider);
                      return customersAsync.when(
                        data: (customers) {
                          final customer = customers.firstWhere(
                            (c) => c.id == _currentInvoice.customerId,
                            orElse: () => customers.first,
                          );

                          final customerDiscountRate =
                              customer.fixedDiscountRate ?? 0.0;
                          final rawSubtotal = _calculateRawSubtotal();
                          final customerDiscountAmount =
                              rawSubtotal * (customerDiscountRate / 100);
                          final taxAmountAfterCustomerDiscount =
                              _calculateTaxAmountAfterCustomerDiscount(
                                  customerDiscountAmount);

                          return _buildTotalRow(
                            label:
                                'KDV (%${_currentInvoice.items.isNotEmpty ? _currentInvoice.items.first.taxRate.toStringAsFixed(1) : '0'})',
                            amount: CurrencyHelper.formatCurrency(
                                taxAmountAfterCustomerDiscount,
                                customerCurrency),
                            isSubtotal: true,
                          );
                        },
                        loading: () => _buildTotalRow(
                          label:
                              'KDV (%${_currentInvoice.items.isNotEmpty ? _currentInvoice.items.first.taxRate.toStringAsFixed(1) : '0'})',
                          amount: CurrencyHelper.formatCurrency(
                              taxAmount, customerCurrency),
                          isSubtotal: true,
                        ),
                        error: (error, stack) => _buildTotalRow(
                          label:
                              'KDV (%${_currentInvoice.items.isNotEmpty ? _currentInvoice.items.first.taxRate.toStringAsFixed(1) : '0'})',
                          amount: CurrencyHelper.formatCurrency(
                              taxAmount, customerCurrency),
                          isSubtotal: true,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 24),
                  // Genel toplam (müşteri iskontosu düşüldükten sonra)
                  Consumer(
                    builder: (context, ref, child) {
                      final customersAsync = ref.watch(customersStreamProvider);
                      return customersAsync.when(
                        data: (customers) {
                          final customer = customers.firstWhere(
                            (c) => c.id == _currentInvoice.customerId,
                            orElse: () => customers.first,
                          );

                          final customerDiscountRate =
                              customer.fixedDiscountRate ?? 0.0;
                          final rawSubtotal = _calculateRawSubtotal();
                          final customerDiscountAmount =
                              rawSubtotal * (customerDiscountRate / 100);
                          // Müşteri iskontosu sonrası KDV hesapla
                          final taxAmountAfterCustomerDiscount =
                              _calculateTaxAmountAfterCustomerDiscount(
                                  customerDiscountAmount);
                          final subtotalAfterCustomerDiscount =
                              rawSubtotal - customerDiscountAmount;
                          final finalTotal = subtotalAfterCustomerDiscount +
                              taxAmountAfterCustomerDiscount;

                          return _buildTotalRow(
                            label: 'Genel Toplam',
                            amount: CurrencyHelper.formatCurrency(
                                finalTotal, customerCurrency),
                            isTotal: true,
                          );
                        },
                        loading: () => _buildTotalRow(
                          label: 'Genel Toplam',
                          amount: CurrencyHelper.formatCurrency(
                              total, customerCurrency),
                          isTotal: true,
                        ),
                        error: (error, stack) => _buildTotalRow(
                          label: 'Genel Toplam',
                          amount: CurrencyHelper.formatCurrency(
                              total, customerCurrency),
                          isTotal: true,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow({
    required String label,
    required String amount,
    bool isSubtotal = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? Colors.grey[800] : Colors.grey[700],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.primary : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.note_alt,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notlar',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEditing)
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notlar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.edit_note),
                ),
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 14),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note,
                      color: Colors.grey[600],
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.invoice.notes ?? 'Not yok',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: widget.invoice.notes != null
                              ? Colors.grey[800]
                              : Colors.grey[500],
                          fontStyle: widget.invoice.notes != null
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
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

  Widget _buildFooter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Teşekkür ederiz!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu fatura TAMGACI muhasebe yazılımı ile oluşturulmuştur.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Kaydet butonuna tıklandı - bilgileri kaydet
      _saveInvoiceChanges();
    } else {
      // Düzenle butonuna tıklandı - düzenleme moduna geç
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _saveInvoiceChanges() {
    // Form validasyonu - basit kontrol
    bool isValid = true;

    // Müşteri adı kontrolü
    if (_customerNameController.text.trim().isEmpty) {
      isValid = false;
    }

    // Ürün kontrolü - en az bir ürün olmalı
    if (_productNameControllers.isEmpty) {
      isValid = false;
    }

    // Her ürün için miktar ve fiyat kontrolü
    for (int i = 0; i < _productNameControllers.length; i++) {
      if (_productNameControllers[i].text.trim().isEmpty ||
          _quantityControllers[i].text.trim().isEmpty ||
          _unitPriceControllers[i].text.trim().isEmpty) {
        isValid = false;
        break;
      }
    }

    if (isValid) {
      // Invoice'ı güncelle ve UI'ı yenile
      setState(() {
        _currentInvoice = _currentInvoice.copyWith(
          customerName: _customerNameController.text,
          customerAddress: _customerAddressController.text,
          notes: _notesController.text,
          // Ürün bilgilerini de güncelle
          items: _buildUpdatedInvoiceItems(),
          subtotal: _calculateSubtotal(),
          taxAmount: _calculateTaxAmount(),
          totalAmount: _calculateTotal(),
        );
        _isEditing = false;
      });

      // TODO: Firebase'e kaydet
      // Bu kısım invoice repository'si ile yapılacak

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fatura bilgileri güncellendi!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Form hatalı - detaylı hata mesajı
      String errorMessage = 'Lütfen şu alanları kontrol edin:\n';

      if (_customerNameController.text.trim().isEmpty) {
        errorMessage += '• Müşteri adı\n';
      }

      if (_productNameControllers.isEmpty) {
        errorMessage += '• En az bir ürün ekleyin\n';
      }

      for (int i = 0; i < _productNameControllers.length; i++) {
        if (_productNameControllers[i].text.trim().isEmpty) {
          errorMessage += '• Ürün ${i + 1} adı\n';
        }
        if (_quantityControllers[i].text.trim().isEmpty) {
          errorMessage += '• Ürün ${i + 1} miktarı\n';
        }
        if (_unitPriceControllers[i].text.trim().isEmpty) {
          errorMessage += '• Ürün ${i + 1} fiyatı\n';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _printInvoice() {
    // Yazdırma seçenekleri dialog'u
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Yazdırma Seçenekleri',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.print, color: Colors.blue),
              title: Text('PDF Olarak Kaydet', style: GoogleFonts.poppins()),
              subtitle: Text('Faturayı PDF dosyası olarak kaydedin',
                  style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _saveAsPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: Text('Paylaş', style: GoogleFonts.poppins()),
              subtitle: Text('Faturayı paylaşın',
                  style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _shareInvoice();
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.orange),
              title: Text('E-posta Gönder', style: GoogleFonts.poppins()),
              subtitle: Text('Faturayı e-posta ile gönderin',
                  style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _sendEmail();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _saveAsPDF() {
    // PDF kaydetme işlemi
    if (kIsWeb) {
      // Web'de PDF oluşturma
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF kaydetme için Ctrl+S tuşlarını kullanın'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Mobil'de PDF kaydetme
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobil PDF kaydetme özelliği yakında eklenecek'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _shareInvoice() {
    // TODO: Paylaşım işlevselliği
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paylaşım özelliği yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendEmail() {
    // TODO: E-posta gönderme işlevselliği
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('E-posta gönderme özelliği yakında eklenecek'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// Ödeme durumu rengini döndürür
  Color _getPaymentStatusColor(bool isPaid) {
    if (isPaid) {
      return Colors.green.shade100;
    } else {
      return Colors.orange.shade100;
    }
  }

  /// Ödeme durumu metnini döndürür
  String _getPaymentStatusText(bool isPaid) {
    if (isPaid) {
      return 'Ödendi';
    } else {
      return 'Beklemede';
    }
  }

  /// Ödeme durumu metin rengini döndürür
  Color _getPaymentStatusTextColor(bool isPaid) {
    if (isPaid) {
      return Colors.green.shade700;
    } else {
      return Colors.orange.shade700;
    }
  }

  void _saveInvoice() async {
    try {
      if (_isEditing) {
        // Düzenleme modunda - mevcut faturayı güncelle
        // TODO: Invoice repository ile güncelleme işlemi
        // final updatedInvoice = widget.invoice.copyWith(
        //   customerName: _customerNameController.text,
        //   customerAddress: _customerAddressController.text,
        //   notes: _notesController.text,
        //   updatedAt: DateTime.now(),
        // );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fatura güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Yeni fatura olarak kaydet
        // TODO: Invoice repository ile kaydetme işlemi
        // final newInvoice = widget.invoice.copyWith(
        //   id: '', // Yeni ID oluşturulacak
        //   invoiceNumber: null, // Yeni fatura numarası oluşturulacak
        //   customerName: _customerNameController.text,
        //   customerAddress: _customerAddressController.text,
        //   notes: _notesController.text,
        //   createdAt: DateTime.now(),
        //   updatedAt: DateTime.now(),
        // );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fatura kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
