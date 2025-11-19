import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
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
import '../../../company/domain/entities/company_info.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../../core/services/utils/exchange_rate_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
  
  // PDF için logo ve font cache
  static pw.MemoryImage? _cachedTamgaciLogo;
  static pw.MemoryImage? _cachedCompanyLogo;
  static pw.Font? _cachedRobotoFont;
  static pw.Font? _cachedRobotoBoldFont;

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
          onBackPressed: widget.isFromSale
              ? () {
                  // Fatura satıştan oluşturulduysa müşteri detay ekranına dön
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).pushNamed(
                    '/customers/detail/${_currentInvoice.customerId}',
                  );
                }
              : null, // null ise varsayılan geri davranışı kullanılır
          actions: [
            if (widget.isEditable) ...[
              IconButton(
                onPressed: _toggleEdit,
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                tooltip: _isEditing ? 'Kaydet' : 'Düzenle',
              ),
            ],
            IconButton(
              onPressed: _downloadPDF,
              icon: const Icon(Icons.download),
              tooltip: 'PDF İndir',
            ),
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
              FutureBuilder(
                future: _buildTotals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return snapshot.data ?? const SizedBox.shrink();
                },
              ),
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  if (companyInfo?.taxOffice != null)
                    Text(
                      'Vergi Dairesi: ${companyInfo!.taxOffice}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  if (companyInfo?.fullAddress.isNotEmpty == true)
                    Text(
                      companyInfo!.fullAddress,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  if (companyInfo?.contactInfo.isNotEmpty == true)
                    Text(
                      companyInfo!.contactInfo,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
              ],

              if (taxOffice.isNotEmpty) ...[
                Text(
                  'Vergi Dairesi: $taxOffice',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
              ],

              if (customerAddress.isNotEmpty) ...[
                Text(
                  customerAddress,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              if (phone.isNotEmpty) ...[
                Text(
                  'Tel: $phone',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
              ],

              if (email.isNotEmpty) ...[
                Text(
                  'E-posta: $email',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
              ],

              if (website.isNotEmpty) ...[
                Text(
                  'Web: $website',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Ödeme Durumu:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          size: 18,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ürün bulunamadı',
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
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
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
              color: index.isEven 
                  ? Theme.of(context).colorScheme.surface 
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
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
              color: index.isEven 
                  ? Theme.of(context).colorScheme.surface 
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), 
                  width: 0.5,
                ),
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
                  icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error, size: 20),
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
                      currentProduct.salesPrice.toString();
                  _taxRateControllers[index].text =
                      currentProduct.salesTaxRate.toString();
                });
              });
            }

            return DropdownButtonFormField<Product>(
              initialValue: _selectedProducts[index],
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
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
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
                      fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Ürünler yüklenemedi',
              style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.error),
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
  Future<List<Widget>> _buildProductDetails() async {
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

    // Her para birimi için ayrı özet bölümü oluştur
    for (final entry in currencyGroups.entries) {
      final currency = entry.key;
      final items = entry.value;

      // Para birimi başlığı
      details.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              // Para birimi başlığı
              Text(
                'Para Birimi: $currency',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Bu para birimindeki hesaplamalar
              ...await _buildCurrencySummary(currency, items, customerCurrency),
            ],
          ),
        ),
      );
    }

    return details;
  }

  // Her para birimi için özet hesaplamaları
  Future<List<Widget>> _buildCurrencySummary(String currency,
      List<Map<String, dynamic>> items, String customerCurrency) async {
    final List<Widget> summary = [];

    // Ara toplam hesapla
    double currencySubtotal = 0.0;

    for (final itemData in items) {
      final quantity = itemData['quantity'] as double;
      final unitPrice = itemData['unitPrice'] as double;
      final lineTotal = quantity * unitPrice;
      currencySubtotal += lineTotal;
    }

    // Ara toplam
    summary.add(
      _buildCurrencyRow(
        label: 'Ara Toplam:',
        amount: CurrencyHelper.formatCurrency(currencySubtotal, currency),
        isSubtotal: true,
      ),
    );

    // İskonto hesapla (ürün iskontoları)
    double totalDiscount = 0.0;
    for (final itemData in items) {
      final item = itemData['item'] as InvoiceItem;

      if (item.discountAmount > 0) {
        totalDiscount += item.discountAmount;
      }
    }

    if (totalDiscount > 0) {
      summary.add(
        _buildCurrencyRow(
          label: 'İskonto:',
          amount: '-${CurrencyHelper.formatCurrency(totalDiscount, currency)}',
          isDiscount: true,
        ),
      );
    }

    // KDV hesapla
    double taxAmount = 0.0;
    for (final itemData in items) {
      final item = itemData['item'] as InvoiceItem;
      final quantity = itemData['quantity'] as double;
      final unitPrice = itemData['unitPrice'] as double;

      final lineTotal = quantity * unitPrice;
      final discountAmount = item.discountAmount;
      final taxableAmount = lineTotal - discountAmount;
      final itemTax = taxableAmount * (item.taxRate / 100);
      taxAmount += itemTax;
    }

    if (taxAmount > 0) {
      summary.add(
        _buildCurrencyRow(
          label: 'KDV:',
          amount: '+${CurrencyHelper.formatCurrency(taxAmount, currency)}',
          isTax: true,
        ),
      );
    }

    // Bu para biriminin toplamı
    final currencyTotal = currencySubtotal - totalDiscount + taxAmount;

    // Kur bilgisi (farklı para birimlerinde)
    if (currency != customerCurrency) {
      // Önce ürünlerde kayıtlı kur bilgisini kontrol et
      double exchangeRate = 1.0;
      final item = items.first['item'] as InvoiceItem;

      if (item.exchangeRate != null && item.exchangeRate! > 0) {
        // Satış yap modülünde girilen kur bilgisini kullan
        exchangeRate = item.exchangeRate!;
      } else {
        // Kur bilgisi yoksa gerçek kurları al
        try {
          await ExchangeRateService().getExchangeRate(currency);
          exchangeRate = ExchangeRateService()
              .convertCurrency(1.0, currency, customerCurrency);
        } catch (e) {
          // Hata durumunda varsayılan kur
          exchangeRate = 1.0;
        }
      }

      final convertedTotal = currencyTotal * exchangeRate;

      summary.add(
        _buildCurrencyRow(
          label: 'Kur: 1 $currency = ${exchangeRate.toStringAsFixed(4)} TL',
          amount: '',
          isInfo: true,
        ),
      );

      summary.add(
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyHelper.formatCurrency(currencyTotal, currency),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    '(${convertedTotal.toStringAsFixed(2)})',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      // Aynı para birimi - sadece toplam göster
      summary.add(
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                CurrencyHelper.formatCurrency(currencyTotal, currency),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return summary;
  }

  Widget _buildCurrencyRow({
    required String label,
    required String amount,
    bool isSubtotal = false,
    bool isDiscount = false,
    bool isTax = false,
    bool isInfo = false,
  }) {
    final theme = Theme.of(context);
    Color? textColor;
    if (isDiscount) textColor = theme.colorScheme.error;
    if (isTax) textColor = theme.colorScheme.primary;
    if (isInfo) textColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSubtotal ? FontWeight.w600 : FontWeight.normal,
              color: textColor,
            ),
          ),
          if (amount.isNotEmpty)
            Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSubtotal ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
        ],
      ),
    );
  }

  Future<Widget> _buildTotals() async {
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
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
                  ...await _buildProductDetails(),
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

                  // Genel toplam bölümü
                  Container(
                    padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ),
                    child: Column(
                      children: [
                        // Toplam ürün miktarı
                        _buildTotalRow(
                          label: 'Toplam ürün miktarı:',
                          amount: '${_currentInvoice.items.length}',
                          isSubtotal: true,
                        ),
                        const SizedBox(height: 8),

                        // GENEL TOPLAM (TL)
                        Consumer(
                          builder: (context, ref, child) {
                            final customersAsync =
                                ref.watch(customersStreamProvider);
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
                                final subtotalAfterCustomerDiscount =
                                    rawSubtotal - customerDiscountAmount;
                                final finalTotal =
                                    subtotalAfterCustomerDiscount +
                                        taxAmountAfterCustomerDiscount;

                                return _buildTotalRow(
                                  label: 'GENEL TOPLAM (TL):',
                                  amount: CurrencyHelper.formatCurrency(
                                      finalTotal, customerCurrency),
                                  isTotal: true,
                                );
                              },
                              loading: () => _buildTotalRow(
                                label: 'GENEL TOPLAM (TL):',
                                amount: CurrencyHelper.formatCurrency(
                                    total, customerCurrency),
                                isTotal: true,
                              ),
                              error: (error, stack) => _buildTotalRow(
                                label: 'GENEL TOPLAM (TL):',
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.invoice.notes ?? 'Not yok',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: widget.invoice.notes != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

      // Firebase'e kaydet
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

  Future<void> _downloadPDF() async {
    try {
      debugPrint('=== PDF İNDİRME BAŞLADI ===');
      
      // Loading göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 16),
                Text(
                  'PDF oluşturuluyor...',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            duration: const Duration(seconds: 30),
          ),
        );
      }

      // Company bilgilerini al (async olarak bekle)
      final companyInfoAsync = ref.read(companyInfoStreamProvider);
      CompanyInfo? companyInfo;
      await companyInfoAsync.when(
        data: (info) async => companyInfo = info,
        loading: () async {},
        error: (_, __) async {},
      );

      // Logoları ve fontları yükle
      debugPrint('Logo ve font yükleme başlıyor...');
      try {
        await _ensureTamgaciLogoLoaded();
        debugPrint('TAMGACI logo yüklendi');
      } catch (e) {
        debugPrint('TAMGACI logo yükleme hatası: $e');
      }
      
      try {
        if (companyInfo?.logoUrl != null && companyInfo!.logoUrl!.isNotEmpty) {
          await _ensureCompanyLogoLoaded(companyInfo!.logoUrl);
          debugPrint('Firma logo yüklendi');
        }
      } catch (e) {
        debugPrint('Firma logo yükleme hatası: $e');
      }
      
      try {
        await _ensureRobotoFontLoaded();
        debugPrint('Font yükleme tamamlandı');
      } catch (e) {
        debugPrint('Font yükleme hatası: $e');
        // Font yüklenemezse devam et, varsayılan font kullanılacak
      }
      
      debugPrint('PDF oluşturma başlıyor...');

      // PDF oluştur
      final pdf = pw.Document();
      final customerCurrency = _getCustomerCurrency();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          footer: (pw.Context context) {
            return _buildPDFFooter(context);
          },
          build: (pw.Context context) {
            return [
              // Header
              _buildPDFHeader(companyInfo),
              pw.SizedBox(height: 30),
              
              // Customer Info
              _buildPDFCustomerInfo(),
              pw.SizedBox(height: 20),
              
              // Invoice Details
              _buildPDFInvoiceDetails(),
              pw.SizedBox(height: 20),
              
              // Items Table
              _buildPDFItemsTable(),
              pw.SizedBox(height: 20),
              
              // Totals
              _buildPDFTotals(customerCurrency),
              pw.SizedBox(height: 20),
              
              // Notes
              if (_currentInvoice.notes != null && _currentInvoice.notes!.isNotEmpty)
                _buildPDFNotes(),
            ];
          },
        ),
      );

      // PDF'i kaydet
      final bytes = await pdf.save();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'Fatura_${_currentInvoice.invoiceNumber}_$timestamp.pdf';

      if (kIsWeb) {
        // Web'de indirme
        final uint8List = Uint8List.fromList(bytes);
        final blob = web.Blob([uint8List.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.HTMLAnchorElement()
          ..href = url
          ..download = fileName
          ..style.display = 'none';
        web.document.body?.appendChild(anchor);
        anchor.click();
        anchor.remove();
        web.URL.revokeObjectURL(url);
      } else {
        // Mobil'de kaydet
        final directory = await getDownloadsDirectory();
        if (directory == null) {
          throw Exception('Downloads klasörü bulunamadı');
        }
        final filePath = path.join(directory.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(bytes);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb 
                ? 'PDF indirildi: $fileName'
                : 'PDF kaydedildi: $fileName',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('=== PDF OLUŞTURMA HATASI ===');
      debugPrint('Hata: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PDF oluşturma hatası: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  pw.Widget _buildPDFHeader(CompanyInfo? companyInfo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Sol taraf: Firma logosu ve adı
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (_cachedCompanyLogo != null) ...[
              pw.Container(
                width: 60,
                height: 60,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Image(
                  _cachedCompanyLogo!,
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.SizedBox(width: 12),
            ],
            // Firma adı ve bilgileri - firma bilgisi varsa göster
            if (companyInfo != null && companyInfo.name.isNotEmpty)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _convertTurkishChars(companyInfo.name),
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue700,
                      font: _cachedRobotoBoldFont,
                    ),
                  ),
                  if (companyInfo.taxNumber != null && companyInfo.taxNumber!.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _convertTurkishChars('Vergi No: ${companyInfo.taxNumber}'),
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: _cachedRobotoFont,
                      ),
                    ),
                  ],
                  if (companyInfo.taxOffice != null && companyInfo.taxOffice!.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      _convertTurkishChars('Vergi Dairesi: ${companyInfo.taxOffice}'),
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: _cachedRobotoFont,
                      ),
                    ),
                  ],
                  if (companyInfo.fullAddress.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      _convertTurkishChars(companyInfo.fullAddress),
                      style: pw.TextStyle(
                        fontSize: 11,
                        font: _cachedRobotoFont,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
        // Sağ taraf: Fatura bilgileri
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              _convertTurkishChars('FATURA'),
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue700,
                font: _cachedRobotoBoldFont,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              _convertTurkishChars('Fatura No: ${_currentInvoice.invoiceNumber}'),
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                font: _cachedRobotoBoldFont,
              ),
            ),
            pw.Text(
              _convertTurkishChars('Tarih: ${DateFormat('dd.MM.yyyy').format(_currentInvoice.invoiceDate)}'),
              style: pw.TextStyle(
                fontSize: 14,
                font: _cachedRobotoFont,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPDFCustomerInfo() {
    final customerName = _customerNameController.text.isNotEmpty
        ? _customerNameController.text
        : (_currentInvoice.customerName ?? '');
    
    if (customerName.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            customerName,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
              font: _cachedRobotoBoldFont,
            ),
          ),
          if (_customerTaxNumberController.text.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Vergi No: ${_customerTaxNumberController.text}',
              style: pw.TextStyle(
                fontSize: 12,
                font: _cachedRobotoFont,
              ),
            ),
          ],
          if (_customerAddressController.text.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              _customerAddressController.text,
              style: pw.TextStyle(
                fontSize: 12,
                font: _cachedRobotoFont,
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPDFInvoiceDetails() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                _convertTurkishChars('Fatura Tarihi:'),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  font: _cachedRobotoBoldFont,
                ),
              ),
              pw.Text(
                _convertTurkishChars(DateFormat('dd.MM.yyyy').format(_currentInvoice.invoiceDate)),
                style: pw.TextStyle(font: _cachedRobotoFont),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                _convertTurkishChars('Vade Tarihi:'),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  font: _cachedRobotoBoldFont,
                ),
              ),
              pw.Text(
                _convertTurkishChars(_currentInvoice.dueDate != null
                    ? DateFormat('dd.MM.yyyy').format(_currentInvoice.dueDate!)
                    : 'Belirtilmemiş'),
                style: pw.TextStyle(font: _cachedRobotoFont),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                _convertTurkishChars('Ödeme Durumu:'),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  font: _cachedRobotoBoldFont,
                ),
              ),
              pw.Text(
                _convertTurkishChars(_currentInvoice.isPaid ? 'Ödendi' : 'Beklemede'),
                style: pw.TextStyle(
                  color: _currentInvoice.isPaid ? PdfColors.green700 : PdfColors.orange700,
                  font: _cachedRobotoFont,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFItemsTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildPDFTableCell('Ürün Adı', isHeader: true),
            _buildPDFTableCell('Miktar', isHeader: true),
            _buildPDFTableCell('Birim Fiyat', isHeader: true),
            _buildPDFTableCell('KDV', isHeader: true),
            _buildPDFTableCell('Toplam', isHeader: true),
          ],
        ),
        // Items
        ..._currentInvoice.items.map((item) {
          return pw.TableRow(
            children: [
              _buildPDFTableCell(item.productName),
              _buildPDFTableCell(item.quantity.toString()),
              _buildPDFTableCell(
                CurrencyHelper.formatCurrency(item.unitPrice, item.currencyCode),
              ),
              _buildPDFTableCell('${item.taxRate.toStringAsFixed(1)}%'),
              _buildPDFTableCell(
                CurrencyHelper.formatCurrency(item.lineTotal, item.currencyCode),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildPDFTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        _convertTurkishChars(text),
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          font: isHeader ? _cachedRobotoBoldFont : _cachedRobotoFont,
        ),
      ),
    );
  }

  pw.Widget _buildPDFTotals(String customerCurrency) {
    final subtotal = _currentInvoice.subtotal;
    final taxAmount = _currentInvoice.taxAmount;
    final total = _currentInvoice.totalAmount;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Ara Toplam:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  font: _cachedRobotoBoldFont,
                ),
              ),
              pw.Text(
                CurrencyHelper.formatCurrency(subtotal, customerCurrency),
                style: pw.TextStyle(font: _cachedRobotoFont),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'KDV:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  font: _cachedRobotoBoldFont,
                ),
              ),
              pw.Text(
                CurrencyHelper.formatCurrency(taxAmount, customerCurrency),
                style: pw.TextStyle(font: _cachedRobotoFont),
              ),
            ],
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'GENEL TOPLAM:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                  font: _cachedRobotoBoldFont,
                ),
              ),
              pw.Text(
                CurrencyHelper.formatCurrency(total, customerCurrency),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                  font: _cachedRobotoBoldFont,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFNotes() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Notlar:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _currentInvoice.notes!,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Ödeme durumu rengini döndürür
  Color _getPaymentStatusColor(bool isPaid) {
    final theme = Theme.of(context);
    if (isPaid) {
      return theme.colorScheme.primaryContainer;
    } else {
      return theme.colorScheme.errorContainer;
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
    final theme = Theme.of(context);
    if (isPaid) {
      return theme.colorScheme.onPrimaryContainer;
    } else {
      return theme.colorScheme.onErrorContainer;
    }
  }


  // TAMGACI logosu yükleme
  Future<void> _ensureTamgaciLogoLoaded() async {
    if (_cachedTamgaciLogo != null) return;

    final List<String> logoPaths = [
      'assets/images/logos/256x256logorenkli.png',
      'assets/images/logos/512x512logo.png',
      'assets/images/logos/192x192logo.png',
    ];

    for (String logoPath in logoPaths) {
      try {
        final logoData = await rootBundle.load(logoPath);
        final logoBytes = logoData.buffer.asUint8List();
        _cachedTamgaciLogo = pw.MemoryImage(logoBytes);
        return;
      } catch (e) {
        continue;
      }
    }
  }

  // Firma logosu yükleme
  Future<void> _ensureCompanyLogoLoaded(String? logoUrl) async {
    if (logoUrl == null || logoUrl.isEmpty) {
      _cachedCompanyLogo = null;
      return;
    }

    try {
      final response = await http.get(Uri.parse(logoUrl));
      if (response.statusCode == 200) {
        final logoBytes = response.bodyBytes;
        _cachedCompanyLogo = pw.MemoryImage(logoBytes);
      }
    } catch (e) {
      _cachedCompanyLogo = null;
    }
  }

  // Roboto font yükleme
  Future<void> _ensureRobotoFontLoaded() async {
    if (_cachedRobotoFont != null && _cachedRobotoBoldFont != null) return;

    try {
      // Sadece mobil için font yükleme yap
      // Web'de varsayılan font kullan (sorun çıkarıyor)
      if (!kIsWeb) {
        try {
          // Mobil'de asset'ten yükle
          final regularFontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
          final boldFontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
          
          _cachedRobotoFont = pw.Font.ttf(regularFontData);
          _cachedRobotoBoldFont = pw.Font.ttf(boldFontData);
          debugPrint('Roboto font başarıyla yüklendi (Mobile)');
        } catch (e) {
          debugPrint('Mobile font yükleme hatası: $e');
          // Font yükleme başarısız, varsayılan font kullanılacak
        }
      } else {
        debugPrint('Web platformu - varsayılan font kullanılıyor (Türkçe karakterler ASCII\'ye dönüştürülecek)');
        // Web'de font yüklemeyi atla, varsayılan fontları kullan
        // _convertTurkishChars fonksiyonu Türkçe karakterleri dönüştürecek
      }
    } catch (e) {
      // Font yükleme başarısız, varsayılan font kullanılacak
      debugPrint('Font yükleme hatası: $e');
    }
  }

  // Türkçe karakterleri dönüştür (font yoksa veya web'de)
  String _convertTurkishChars(String text) {
    // Web'de veya font yoksa ASCII'ye dönüştür
    // Mobil'de font yüklüyse, orijinal metni kullan
    if (!kIsWeb && _cachedRobotoFont != null) {
      return text; // Mobil'de font varsa, orijinal Türkçe karakterleri kullan
    }
    
    // Web'de veya font yoksa ASCII'ye dönüştür
    return text
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'C')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'G')
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'I')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'O')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 'S')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U');
  }

  // PDF Footer (TAMGACI logosu ve yazısı)
  pw.Widget _buildPDFFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Sol taraf: TAMGACI branding
          pw.Row(
            children: [
              if (_cachedTamgaciLogo != null) ...[
                pw.Container(
                  width: 20,
                  height: 20,
                  child: pw.Image(_cachedTamgaciLogo!),
                ),
                pw.SizedBox(width: 8),
              ],
              pw.Text(
                _convertTurkishChars('TAMGACI'),
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                  font: _cachedRobotoBoldFont,
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Text(
                _convertTurkishChars('Muhasebe ve İş Yönetim Sistemi'),
                style: pw.TextStyle(
                  fontSize: 6,
                  color: PdfColors.grey600,
                  font: _cachedRobotoFont,
                ),
              ),
            ],
          ),
          // Sağ taraf: Sayfa numarası
          pw.Text(
            '${context.pageNumber}/${context.pagesCount}',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
              font: _cachedRobotoFont,
            ),
          ),
        ],
      ),
    );
  }
}
