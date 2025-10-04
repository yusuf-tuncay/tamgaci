// ========== ENHANCED SALE DETAIL PAGE ==========
// lib/features/sales/presentation/pages/enhanced_sale_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../domain/entities/sale.dart';

/// Gelişmiş satış detay sayfası
class EnhancedSaleDetailPage extends ConsumerStatefulWidget {
  final String saleId;

  const EnhancedSaleDetailPage({
    super.key,
    required this.saleId,
  });

  @override
  ConsumerState<EnhancedSaleDetailPage> createState() =>
      _EnhancedSaleDetailPageState();
}

class _EnhancedSaleDetailPageState extends ConsumerState<EnhancedSaleDetailPage>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sale = _getMockSale(widget.saleId);
    if (sale == null) {
      return const Scaffold(
        appBar: CustomAppBar(
          title: 'Satış Detayı',
          showDrawer: true,
        ),
        drawer: TamgaciDrawerMenu(),
        body: Center(
          child: Text('Satış bulunamadı'),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Satış Detayı',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: () => _editSale(sale),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _showOptions(sale),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          // Satış özet kartı
          _buildSaleSummaryCard(sale),

          // Tab bar
          _buildTabBar(),

          // Tab içeriği
          Expanded(
            child: _buildTabContent(sale),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleSummaryCard(Sale sale) {
    final statusColor = _getStatusColor(sale.status);
    final paymentColor = _getPaymentStatusColor(sale.paymentStatus);

    return Card(
      margin: TamgaciConstants.paddingMedium(context),
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst kısım - Satış numarası ve durum
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(TamgaciConstants.radiusMD),
                  ),
                  child: Icon(
                    _getSaleTypeIcon(sale.type),
                    color: statusColor,
                    size: 28,
                  ),
                ),

                const SizedBox(width: TamgaciConstants.spaceMD),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.saleNumber,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        sale.customerName ?? 'Müşteri Bilgisi Yok',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        _formatDate(sale.saleDate),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Durum çipleri
                Column(
                  children: [
                    _buildStatusChip(sale.status, statusColor),
                    const SizedBox(height: 4),
                    _buildPaymentStatusChip(sale.paymentStatus, paymentColor),
                  ],
                ),
              ],
            ),

            const SizedBox(height: TamgaciConstants.spaceMD),

            // Tutar bilgileri
            Row(
              children: [
                Expanded(
                  child: _buildAmountCard(
                    'Toplam Tutar',
                    CurrencyHelper.formatCurrency(
                        sale.totalAmount, sale.currency),
                    AppColors.primary,
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(width: TamgaciConstants.spaceMD),
                Expanded(
                  child: _buildAmountCard(
                    'Alt Toplam',
                    CurrencyHelper.formatCurrency(sale.subtotal, sale.currency),
                    AppColors.info,
                    Icons.calculate,
                  ),
                ),
                const SizedBox(width: TamgaciConstants.spaceMD),
                Expanded(
                  child: _buildAmountCard(
                    'KDV',
                    CurrencyHelper.formatCurrency(
                        sale.taxAmount, sale.currency),
                    AppColors.warning,
                    Icons.receipt,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: TabController(
            length: 3, vsync: this, initialIndex: _selectedTabIndex),
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: 'Detaylar'),
          Tab(text: 'Kalemler'),
          Tab(text: 'İşlemler'),
        ],
      ),
    );
  }

  Widget _buildTabContent(Sale sale) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildDetailsTab(sale);
      case 1:
        return _buildItemsTab(sale);
      case 2:
        return _buildTransactionsTab(sale);
      default:
        return _buildDetailsTab(sale);
    }
  }

  Widget _buildDetailsTab(Sale sale) {
    return SingleChildScrollView(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genel Bilgiler
          _buildSectionCard(
            'Genel Bilgiler',
            Icons.info_outline,
            [
              _buildDetailRow('Satış Numarası', sale.saleNumber),
              _buildDetailRow('Satış Türü', sale.type.displayName),
              _buildDetailRow('Satış Tarihi', _formatDate(sale.saleDate)),
              _buildDetailRow(
                  'Vade Tarihi',
                  sale.dueDate != null
                      ? _formatDate(sale.dueDate!)
                      : 'Belirtilmemiş'),
              _buildDetailRow(
                  'Teslimat Tarihi',
                  sale.deliveryDate != null
                      ? _formatDate(sale.deliveryDate!)
                      : 'Belirtilmemiş'),
              _buildDetailRow('Para Birimi', sale.currency),
            ],
          ),

          const SizedBox(height: TamgaciConstants.spaceMD),

          // Müşteri Bilgileri
          _buildSectionCard(
            'Müşteri Bilgileri',
            Icons.person_outline,
            [
              _buildDetailRow(
                  'Müşteri Adı', sale.customerName ?? 'Belirtilmemiş'),
              _buildDetailRow('Müşteri ID', sale.customerId),
            ],
          ),

          const SizedBox(height: TamgaciConstants.spaceMD),

          // Adres Bilgileri
          if (sale.shippingAddress != null || sale.billingAddress != null)
            _buildSectionCard(
              'Adres Bilgileri',
              Icons.location_on_outlined,
              [
                if (sale.shippingAddress != null)
                  _buildDetailRow('Teslimat Adresi', sale.shippingAddress!),
                if (sale.billingAddress != null)
                  _buildDetailRow('Fatura Adresi', sale.billingAddress!),
              ],
            ),

          const SizedBox(height: TamgaciConstants.spaceMD),

          // Ödeme Bilgileri
          _buildSectionCard(
            'Ödeme Bilgileri',
            Icons.payment,
            [
              _buildDetailRow(
                  'Ödeme Yöntemi', sale.paymentMethod ?? 'Belirtilmemiş'),
              _buildDetailRow(
                  'Ödeme Koşulları', sale.paymentTerms ?? 'Belirtilmemiş'),
              _buildDetailRow(
                  'Kargo Ücreti',
                  sale.shippingCost != null
                      ? CurrencyHelper.formatCurrency(
                          sale.shippingCost!, sale.currency)
                      : 'Belirtilmemiş'),
            ],
          ),

          const SizedBox(height: TamgaciConstants.spaceMD),

          // Notlar
          if (sale.notes != null || sale.description != null)
            _buildSectionCard(
              'Notlar',
              Icons.note_outlined,
              [
                if (sale.description != null)
                  _buildDetailRow('Açıklama', sale.description!),
                if (sale.notes != null) _buildDetailRow('Notlar', sale.notes!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildItemsTab(Sale sale) {
    return SingleChildScrollView(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Satış kalemleri
          _buildSectionCard(
            'Satış Kalemleri',
            Icons.list_alt,
            sale.items.map((item) => _buildItemCard(item)).toList(),
          ),

          const SizedBox(height: TamgaciConstants.spaceMD),

          // Toplam özeti
          _buildTotalSummaryCard(sale),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(Sale sale) {
    return SingleChildScrollView(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İşlem geçmişi
          _buildSectionCard(
            'İşlem Geçmişi',
            Icons.history,
            _getMockTransactions(sale.id)
                .map((transaction) => _buildTransactionCard(transaction))
                .toList(),
          ),
        ],
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
            const SizedBox(height: TamgaciConstants.spaceMD),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(SaleItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.productName ?? 'Ürün Adı Yok',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                CurrencyHelper.formatCurrency(item.totalAmount, 'TRY'),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (item.productSku != null)
            Text(
              'SKU: ${item.productSku}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Miktar: ${item.quantity}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Birim Fiyat: ${CurrencyHelper.formatCurrency(item.unitPrice, 'TRY')}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (item.discountAmount > 0)
            Text(
              'İndirim: ${CurrencyHelper.formatCurrency(item.discountAmount, 'TRY')}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.warning,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalSummaryCard(Sale sale) {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          children: [
            _buildSummaryRow('Alt Toplam', sale.subtotal, sale.currency),
            if (sale.discountAmount > 0)
              _buildSummaryRow('İndirim', -sale.discountAmount, sale.currency,
                  AppColors.warning),
            _buildSummaryRow(
                'KDV', sale.taxAmount, sale.currency, AppColors.info),
            if (sale.shippingCost != null && sale.shippingCost! > 0)
              _buildSummaryRow('Kargo', sale.shippingCost!, sale.currency),
            const Divider(),
            _buildSummaryRow('Toplam', sale.totalAmount, sale.currency,
                AppColors.primary, true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, String currency,
      [Color? color, bool isTotal = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            CurrencyHelper.formatCurrency(amount, currency),
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: color ??
                  (isTotal ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            _getTransactionIcon(transaction['type']),
            color: _getTransactionColor(transaction['type']),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _formatDate(transaction['date']),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyHelper.formatCurrency(transaction['amount'], 'TRY'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getTransactionColor(transaction['type']),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(SaleStatus status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(PaymentStatus status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  IconData _getSaleTypeIcon(SaleType type) {
    switch (type) {
      case SaleType.sale:
        return Icons.sell;
      case SaleType.invoice:
        return Icons.receipt;
      case SaleType.proforma:
        return Icons.description;
      case SaleType.waybill:
        return Icons.local_shipping;
      case SaleType.receipt:
        return Icons.point_of_sale;
      case SaleType.estimate:
        return Icons.assessment;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'refund':
        return Icons.keyboard_return;
      case 'adjustment':
        return Icons.edit;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(SaleStatus status) {
    switch (status) {
      case SaleStatus.draft:
        return AppColors.textSecondary;
      case SaleStatus.pending:
        return AppColors.warning;
      case SaleStatus.confirmed:
        return AppColors.info;
      case SaleStatus.shipped:
        return AppColors.primary;
      case SaleStatus.delivered:
        return AppColors.success;
      case SaleStatus.paid:
        return AppColors.success;
      case SaleStatus.cancelled:
        return AppColors.error;
      case SaleStatus.returned:
        return AppColors.warning;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.partial:
        return AppColors.info;
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.overdue:
        return AppColors.error;
      case PaymentStatus.refunded:
        return AppColors.warning;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'payment':
        return AppColors.success;
      case 'refund':
        return AppColors.warning;
      case 'adjustment':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Sale? _getMockSale(String saleId) {
    // Mock data - gerçek uygulamada provider'dan gelecek
    final sales = [
      Sale(
        id: '1',
        tenantId: 'mock-tenant',
        saleNumber: 'SAT-2024-001',
        type: SaleType.invoice,
        status: SaleStatus.delivered,
        paymentStatus: PaymentStatus.paid,
        isPaid: true,
        customerId: '1',
        customerName: 'ABC Şirketi',
        saleDate: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        subtotal: 1000.0,
        taxRate: 18.0,
        taxAmount: 180.0,
        discountAmount: 50.0,
        totalAmount: 1130.0,
        currency: 'TRY',
        notes: 'Özel notlar burada yer alır.',
        description: 'Satış açıklaması',
        shippingAddress: 'İstanbul, Türkiye',
        billingAddress: 'İstanbul, Türkiye',
        shippingCost: 25.0,
        paymentMethod: 'Banka Havalesi',
        paymentTerms: '30 gün',
        items: [
          const SaleItem(
            id: '1',
            saleId: '1',
            productId: '1',
            productName: 'Ürün 1',
            productSku: 'SKU-001',
            quantity: 2,
            unitPrice: 500.0,
            discountAmount: 50.0,
            taxRate: 18.0,
            taxAmount: 90.0,
            totalAmount: 1040.0,
            currency: 'TRY',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    try {
      return sales.firstWhere((sale) => sale.id == saleId);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> _getMockTransactions(String saleId) {
    return [
      {
        'type': 'payment',
        'description': 'Ödeme alındı',
        'amount': 1130.0,
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'type': 'adjustment',
        'description': 'Fatura oluşturuldu',
        'amount': 1130.0,
        'date': DateTime.now().subtract(const Duration(days: 5)),
      },
    ];
  }

  void _editSale(Sale sale) {
    // Satış düzenleme sayfasına git
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Satış Düzenle'),
        content: const Text('Satış düzenleme formu yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showOptions(Sale sale) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Yazdır'),
            onTap: () {
              Navigator.pop(context);
              // Yazdırma işlemi
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Paylaş'),
            onTap: () {
              Navigator.pop(context);
              // Paylaşma işlemi
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Kopyala'),
            onTap: () {
              Navigator.pop(context);
              // Kopyalama işlemi
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Sil', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // Silme işlemi
            },
          ),
        ],
      ),
    );
  }
}
