import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../domain/entities/invoice.dart';
import 'package:tamgaci/core/widgets/disposed_view_suppressor.dart';
import 'package:tamgaci/core/errors/smart_error_suppressor.dart';

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
  late TextEditingController _notesController;
  late TextEditingController _customerNameController;
  late TextEditingController _customerAddressController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.invoice.notes ?? '');
    _customerNameController =
        TextEditingController(text: widget.invoice.customerName ?? '');
    _customerAddressController =
        TextEditingController(text: widget.invoice.customerAddress ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                      'Fatura No: ${widget.invoice.invoiceNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Tarih: ${DateFormat('dd.MM.yyyy').format(widget.invoice.invoiceDate)}',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
                Column(
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fatura Edilecek',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isEditing) ...[
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Müşteri Adı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerAddressController,
                decoration: const InputDecoration(
                  labelText: 'Adres',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ] else ...[
              Text(
                widget.invoice.customerName ?? 'N/A',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.invoice.customerAddress ?? 'Adres bilgisi yok',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fatura Tarihi:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(
                  DateFormat('dd.MM.yyyy').format(widget.invoice.invoiceDate),
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vade Tarihi:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(
                  widget.invoice.dueDate != null
                      ? DateFormat('dd.MM.yyyy').format(widget.invoice.dueDate!)
                      : 'N/A',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ödeme Durumu:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(widget.invoice.isPaid),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPaymentStatusText(widget.invoice.isPaid),
                    style: GoogleFonts.poppins(
                      color: _getPaymentStatusTextColor(widget.invoice.isPaid),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ürünler',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.invoice.items.isEmpty)
              Center(
                child: Text(
                  'Ürün bulunamadı',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              )
            else
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
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
                      color: AppColors.primary.withValues(alpha: 0.1),
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
                  ...widget.invoice.items.map((item) => TableRow(
                        children: [
                          _buildTableCell(item.productName),
                          _buildTableCell(item.quantity.toString()),
                          _buildTableCell(CurrencyHelper.formatCurrency(
                              item.unitPrice, item.currencyCode)),
                          _buildTableCell(
                              '${item.taxRate.toStringAsFixed(1)}%'),
                          _buildTableCell(CurrencyHelper.formatCurrency(
                              item.lineTotal, item.currencyCode)),
                        ],
                      )),
                ],
              ),
          ],
        ),
      ),
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

  Widget _buildTotals() {
    final subtotal = widget.invoice.subtotal;
    final taxAmount = widget.invoice.taxAmount;
    final total = widget.invoice.totalAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ara Toplam:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(
                  CurrencyHelper.formatCurrency(
                      subtotal, widget.invoice.currencyCode),
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KDV:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(
                  CurrencyHelper.formatCurrency(
                      taxAmount, widget.invoice.currencyCode),
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toplam:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  CurrencyHelper.formatCurrency(
                      total, widget.invoice.currencyCode),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notlar',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isEditing)
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              )
            else
              Text(
                widget.invoice.notes ?? 'Not yok',
                style: GoogleFonts.poppins(fontSize: 14),
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
    setState(() {
      _isEditing = !_isEditing;
    });
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
    // TODO: PDF oluşturma işlevselliği
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF kaydetme özelliği yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
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
