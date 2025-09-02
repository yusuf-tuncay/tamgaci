// ========== lib/features/invoices/presentation/pages/invoice_detail_page.dart ==========

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tamgaci/features/customers/data/models/customer_entity.dart';
import '../../../../core/theme/constants.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../data/models/invoice_status.dart';
import '../providers/invoice_providers.dart';

/// Fatura detay sayfası - Tam fonksiyonel
class InvoiceDetailPage extends ConsumerWidget {
  final String invoiceId;

  const InvoiceDetailPage({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoiceProvider(invoiceId));

    return invoiceAsync.when(
      data: (invoice) => invoice != null
          ? _InvoiceDetailView(invoice: invoice)
          : _InvoiceNotFound(),
      loading: () => _InvoiceDetailLoading(),
      error: (error, stack) => _InvoiceDetailError(error: error),
    );
  }
}

/// Fatura detay görünümü
class _InvoiceDetailView extends ConsumerWidget {
  final Invoice invoice;

  const _InvoiceDetailView({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Güncel fatura verilerini al
    final invoicesAsync = ref.watch(invoicesProvider);

    return invoicesAsync.when(
      data: (invoices) {
        // Güncel fatura verisini bul
        final updatedInvoice = invoices.firstWhere(
          (inv) => inv.id == invoice.id,
          orElse: () => invoice, // Fallback olarak eski veriyi kullan
        );

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark
              ? TamgaciConstants.backgroundColorDark
              : TamgaciConstants.backgroundColor,
          appBar: AppBar(
            title: Text(updatedInvoice.invoiceNumber),
            elevation: 0,
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: isDark
                ? TamgaciConstants.textPrimaryDark
                : TamgaciConstants.textPrimary,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios),
            ),
            actions: [
              // Düzenle butonu
              IconButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed('/invoice/edit', arguments: updatedInvoice.id);
                },
                icon: const Icon(Icons.edit_outlined),
              ),

              // Daha fazla seçenek
              PopupMenuButton<String>(
                onSelected: (action) =>
                    _handleAction(context, ref, action, updatedInvoice),
                itemBuilder: (context) => [
                  if (updatedInvoice.canSend)
                    const PopupMenuItem(
                      value: 'send',
                      child: ListTile(
                        leading: Icon(Icons.send_outlined),
                        title: Text('Gönder'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (updatedInvoice.canMarkAsPaid)
                    const PopupMenuItem(
                      value: 'mark_paid',
                      child: ListTile(
                        leading: Icon(
                          Icons.payment_outlined,
                          color: Colors.green,
                        ),
                        title: Text(
                          'Ödendi İşaretle',
                          style: TextStyle(color: Colors.green),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'mark_draft',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined, color: Colors.grey),
                      title: Text(
                        'Taslak İşaretle',
                        style: TextStyle(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'mark_sent',
                    child: ListTile(
                      leading: Icon(Icons.send_outlined, color: Colors.blue),
                      title: Text(
                        'Gönderildi İşaretle',
                        style: TextStyle(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'mark_cancelled',
                    child: ListTile(
                      leading: Icon(Icons.cancel_outlined, color: Colors.red),
                      title: Text(
                        'İptal Et',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: ListTile(
                      leading: Icon(Icons.copy_outlined),
                      title: Text('Kopyala'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Sil', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: TamgaciConstants.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fatura başlık kartı
                _buildHeaderCard(context, updatedInvoice),

                const SizedBox(height: TamgaciConstants.spaceLG),

                // Müşteri bilgileri
                if (updatedInvoice.customer != null)
                  _buildCustomerInfoCard(updatedInvoice),

                if (updatedInvoice.customer != null)
                  const SizedBox(height: TamgaciConstants.spaceLG),

                // Fatura bilgileri
                _buildInvoiceInfoCard(updatedInvoice),

                const SizedBox(height: TamgaciConstants.spaceLG),

                // Fatura kalemleri
                _buildInvoiceItemsCard(updatedInvoice),

                const SizedBox(height: TamgaciConstants.spaceLG),

                // Ek bilgiler
                if (updatedInvoice.paymentTerms != null ||
                    updatedInvoice.notes != null)
                  _buildAdditionalInfoCard(updatedInvoice),

                if (updatedInvoice.paymentTerms != null ||
                    updatedInvoice.notes != null)
                  const SizedBox(height: TamgaciConstants.spaceXXL),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomActions(
            context,
            ref,
            updatedInvoice,
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Hata: $error'))),
    );
  }

  /// Başlık kartı
  Widget _buildHeaderCard(BuildContext context, Invoice invoice) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(invoice.status);

    return Card(
      color: isDark ? TamgaciConstants.cardColorDark : null,
      child: Padding(
        padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fatura numarası ve durum
            Row(
              children: [
                Expanded(
                  child: Text(
                    invoice.invoiceNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? TamgaciConstants.textPrimaryDark
                          : TamgaciConstants.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    invoice.statusDisplayName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            if (invoice.description != null) ...[
              const SizedBox(height: TamgaciConstants.spaceSM),
              Text(
                invoice.description!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? TamgaciConstants.textSecondaryDark
                      : TamgaciConstants.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: TamgaciConstants.spaceLG),

            // Toplam tutar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
              decoration: BoxDecoration(
                color: TamgaciConstants.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
              ),
              child: Column(
                children: [
                  Text(
                    'TOPLAM TUTAR',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? TamgaciConstants.textSecondaryDark
                          : TamgaciConstants.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invoice.formattedTotalAmount,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: TamgaciConstants.primaryColor,
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

  /// Müşteri bilgileri kartı
  Widget _buildCustomerInfoCard(Invoice invoice) {
    final customer = invoice.customer!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Müşteri Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: customer.customerType == CustomerType.company
                        ? TamgaciConstants.primaryLight
                        : TamgaciConstants.secondaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: customer.initials.isEmpty
                        ? Icon(
                            customer.customerType == CustomerType.company
                                ? Icons.business
                                : Icons.person,
                            color: customer.customerType == CustomerType.company
                                ? TamgaciConstants.primaryColor
                                : TamgaciConstants.secondaryColor,
                          )
                        : Text(
                            customer.initials,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color:
                                  customer.customerType == CustomerType.company
                                      ? TamgaciConstants.primaryColor
                                      : TamgaciConstants.secondaryColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: TamgaciConstants.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: TamgaciConstants.textPrimary,
                        ),
                      ),
                      if (customer.email != null)
                        Text(
                          customer.email!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: TamgaciConstants.textSecondary,
                          ),
                        ),
                      if (customer.phone != null)
                        Text(
                          customer.phone!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: TamgaciConstants.textSecondary,
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
    );
  }

  /// Fatura bilgileri kartı
  Widget _buildInvoiceInfoCard(Invoice invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fatura Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            _buildInfoRow(
              'Fatura Tarihi',
              DateFormat('dd/MM/yyyy').format(invoice.invoiceDate),
            ),
            if (invoice.dueDate != null)
              _buildInfoRow(
                'Vade Tarihi',
                DateFormat('dd/MM/yyyy').format(invoice.dueDate!),
              ),
            _buildInfoRow('Durum', invoice.statusDisplayName),
            if (invoice.isPaid && invoice.paidDate != null)
              _buildInfoRow(
                'Ödeme Tarihi',
                DateFormat('dd/MM/yyyy').format(invoice.paidDate!),
              ),
            _buildInfoRow(
              'Oluşturulma Tarihi',
              DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
            ),
            if (invoice.createdAt != invoice.updatedAt)
              _buildInfoRow(
                'Güncellenme Tarihi',
                DateFormat('dd/MM/yyyy HH:mm').format(invoice.updatedAt),
              ),
          ],
        ),
      ),
    );
  }

  /// Fatura kalemleri kartı
  Widget _buildInvoiceItemsCard(Invoice invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fatura Kalemleri (${invoice.items.length} adet)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),

            // Debug: Fatura kalemlerini kontrol et
            if (invoice.items.isEmpty)
              Container(
                padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusSM,
                  ),
                ),
                child: Text(
                  '⚠️ Fatura kalemleri bulunamadı! (Debug: ${invoice.items.length} adet)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
              ),

            // Kalem listesi
            ...invoice.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildInvoiceItemRow(item),
                  if (index < invoice.items.length - 1)
                    const Divider(height: TamgaciConstants.spaceLG),
                ],
              );
            }),

            const Divider(height: TamgaciConstants.spaceXL),

            // Toplamlar
            _buildTotalRows(invoice),
          ],
        ),
      ),
    );
  }

  /// Fatura kalemi satırı
  Widget _buildInvoiceItemRow(InvoiceItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ürün adı ve toplam
        Row(
          children: [
            Expanded(
              child: Text(
                item.productName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TamgaciConstants.textPrimary,
                ),
              ),
            ),
            Text(
              item.formattedTotalWithTax,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ],
        ),

        if (item.description != null) ...[
          const SizedBox(height: 4),
          Text(
            item.description!,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: TamgaciConstants.textSecondary,
            ),
          ),
        ],

        const SizedBox(height: TamgaciConstants.spaceXS),

        // Miktar, fiyat, KDV detayları
        Row(
          children: [
            Text(
              '${item.formattedQuantity} × ${item.formattedUnitPrice}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: TamgaciConstants.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              'KDV %${item.taxRate.toStringAsFixed(0)}: ${item.formattedTaxAmount}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Toplam satırları
  Widget _buildTotalRows(Invoice invoice) {
    return Column(
      children: [
        _buildTotalRow('Ara Toplam', invoice.formattedSubtotal, false),
        const SizedBox(height: TamgaciConstants.spaceXS),
        _buildTotalRow('KDV Toplamı', invoice.formattedTaxAmount, false),
        if (invoice.discountAmount > 0) ...[
          const SizedBox(height: TamgaciConstants.spaceXS),
          _buildTotalRow(
            'İndirim',
            '-${invoice.discountAmount.toStringAsFixed(2)} ${invoice.currencySymbol}',
            false,
          ),
        ],
        const Divider(height: TamgaciConstants.spaceLG),
        _buildTotalRow('GENEL TOPLAM', invoice.formattedTotalAmount, true),
      ],
    );
  }

  /// Toplam satırı
  Widget _buildTotalRow(String title, String amount, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal
                ? TamgaciConstants.primaryColor
                : TamgaciConstants.textSecondary,
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal
                ? TamgaciConstants.primaryColor
                : TamgaciConstants.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Ek bilgiler kartı
  Widget _buildAdditionalInfoCard(Invoice invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ek Bilgiler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            if (invoice.paymentTerms != null)
              _buildInfoRow('Ödeme Koşulları', invoice.paymentTerms!),
            if (invoice.notes != null) ...[
              const SizedBox(height: TamgaciConstants.spaceMD),
              Text(
                'Notlar:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TamgaciConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                invoice.notes!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: TamgaciConstants.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Alt aksiyonlar
  Widget _buildBottomActions(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    if (!invoice.canSend && !invoice.canMarkAsPaid) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: TamgaciConstants.paddingMedium(context),
      decoration: const BoxDecoration(
        color: TamgaciConstants.backgroundColor,
        border: Border(
          top: BorderSide(color: TamgaciConstants.borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (invoice.canSend) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleAction(context, ref, 'send', invoice),
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Gönder'),
                ),
              ),
              if (invoice.canMarkAsPaid)
                const SizedBox(width: TamgaciConstants.spaceMD),
            ],
            if (invoice.canMarkAsPaid)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _handleAction(context, ref, 'mark_paid', invoice),
                  icon: const Icon(Icons.payment_outlined),
                  label: const Text('Ödendi İşaretle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TamgaciConstants.successColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Bilgi satırı
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TamgaciConstants.spaceXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Durum rengini getir
  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return TamgaciConstants.primaryColor;
      case InvoiceStatus.paid:
        return TamgaciConstants.successColor;
      case InvoiceStatus.overdue:
        return TamgaciConstants.errorColor;
      case InvoiceStatus.cancelled:
        return Colors.blueGrey;
      case InvoiceStatus.partiallyPaid:
        return TamgaciConstants.warningColor;
      case InvoiceStatus.unpaid:
        return Colors.deepOrange;
    }
  }

  /// Aksiyon işleyici
  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Invoice invoice,
  ) {
    switch (action) {
      case 'send':
        _showSendConfirmation(context, ref, invoice);
        break;
      case 'mark_paid':
        _showMarkAsPaidConfirmation(context, ref, invoice);
        break;
      case 'mark_draft':
        _showMarkAsDraftConfirmation(context, ref, invoice);
        break;
      case 'mark_sent':
        _showMarkAsSentConfirmation(context, ref, invoice);
        break;
      case 'mark_cancelled':
        _showMarkAsCancelledConfirmation(context, ref, invoice);
        break;
      case 'duplicate':
        _showDuplicateConfirmation(context, ref);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, invoice);
        break;
    }
  }

  /// Gönderme onayı
  void _showSendConfirmation(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Faturayı Gönder'),
        content: Text(
          '${invoice.invoiceNumber} numaralı faturayı gönder durumuna almak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(invoiceRepositoryProvider);
                await repository.updateInvoiceStatus(
                  invoice.id,
                  InvoiceStatus.sent,
                );

                // Provider'ı yenile
                ref.invalidate(invoicesProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${invoice.invoiceNumber} gönderildi'),
                      backgroundColor: TamgaciConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gönderme işlemi başarısız: $e'),
                      backgroundColor: TamgaciConstants.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  /// Ödendi işaretleme onayı
  void _showMarkAsPaidConfirmation(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödendi İşaretle'),
        content: Text(
          '${invoice.invoiceNumber} numaralı faturayı ödendi olarak işaretlemek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(invoiceRepositoryProvider);
                await repository.markInvoiceAsPaid(invoice.id);

                // Provider'ı yenile
                ref.invalidate(invoicesProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${invoice.invoiceNumber} ödendi olarak işaretlendi',
                      ),
                      backgroundColor: TamgaciConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('İşlem başarısız: $e'),
                      backgroundColor: TamgaciConstants.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TamgaciConstants.successColor,
            ),
            child: const Text('Ödendi İşaretle'),
          ),
        ],
      ),
    );
  }

  /// Taslak işaretleme onayı
  void _showMarkAsDraftConfirmation(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Taslak İşaretle'),
        content: Text(
          '${invoice.invoiceNumber} numaralı faturayı taslak olarak işaretlemek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(invoiceRepositoryProvider);
                await repository.updateInvoiceStatus(
                  invoice.id,
                  InvoiceStatus.draft,
                );

                // Provider'ı yenile
                ref.invalidate(invoicesProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${invoice.invoiceNumber} taslak olarak işaretlendi',
                      ),
                      backgroundColor: TamgaciConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('İşlem başarısız: $e'),
                      backgroundColor: TamgaciConstants.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('Taslak İşaretle'),
          ),
        ],
      ),
    );
  }

  /// Gönderildi işaretleme onayı
  void _showMarkAsSentConfirmation(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gönderildi İşaretle'),
        content: Text(
          '${invoice.invoiceNumber} numaralı faturayı gönderildi olarak işaretlemek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(invoiceRepositoryProvider);
                await repository.updateInvoiceStatus(
                  invoice.id,
                  InvoiceStatus.sent,
                );

                // Provider'ı yenile
                ref.invalidate(invoicesProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${invoice.invoiceNumber} gönderildi olarak işaretlendi',
                      ),
                      backgroundColor: TamgaciConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('İşlem başarısız: $e'),
                      backgroundColor: TamgaciConstants.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Gönderildi İşaretle'),
          ),
        ],
      ),
    );
  }

  /// İptal etme onayı
  void _showMarkAsCancelledConfirmation(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Faturayı İptal Et'),
        content: Text(
          '${invoice.invoiceNumber} numaralı faturayı iptal etmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(invoiceRepositoryProvider);
                await repository.updateInvoiceStatus(
                  invoice.id,
                  InvoiceStatus.cancelled,
                );

                // Provider'ı yenile
                ref.invalidate(invoicesProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${invoice.invoiceNumber} iptal edildi'),
                      backgroundColor: TamgaciConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('İşlem başarısız: $e'),
                      backgroundColor: TamgaciConstants.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );
  }

  /// Kopyalama onayı
  void _showDuplicateConfirmation(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fatura kopyalama özelliği yakında eklenecek'),
        backgroundColor: TamgaciConstants.infoColor,
      ),
    );
  }

  /// Silme onayı
  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Faturayı Sil'),
        content: Text(
          '${invoice.invoiceNumber} numaralı faturayı kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(invoiceRepositoryProvider);
                await repository.deleteInvoice(invoice.id);

                // Provider'ı yenile
                ref.invalidate(invoicesProvider);

                if (context.mounted) {
                  Navigator.of(context).pop(); // Detail sayfasından çık
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${invoice.invoiceNumber} başarıyla silindi',
                      ),
                      backgroundColor: TamgaciConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Silme işlemi başarısız: $e'),
                      backgroundColor: TamgaciConstants.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TamgaciConstants.errorColor,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

/// Fatura bulunamadı durumu
class _InvoiceNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fatura Bulunamadı')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: TamgaciConstants.textDisabled,
            ),
            SizedBox(height: TamgaciConstants.spaceLG),
            Text(
              'Fatura bulunamadı',
              style: TextStyle(
                fontSize: 18,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yükleme durumu
class _InvoiceDetailLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fatura Detayı')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

/// Hata durumu
class _InvoiceDetailError extends StatelessWidget {
  final Object error;

  const _InvoiceDetailError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hata')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: TamgaciConstants.errorColor,
            ),
            const SizedBox(height: TamgaciConstants.spaceLG),
            const Text(
              'Fatura yüklenirken hata oluştu',
              style: TextStyle(
                fontSize: 18,
                color: TamgaciConstants.textSecondary,
              ),
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            Text(
              error.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: TamgaciConstants.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
