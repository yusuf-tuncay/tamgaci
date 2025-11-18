// ========== ENHANCED PURCHASE DETAIL PAGE ==========
// lib/features/purchases/presentation/pages/enhanced_purchase_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../domain/entities/purchase.dart';

/// Gelişmiş alış detay sayfası
class EnhancedPurchaseDetailPage extends ConsumerStatefulWidget {
  final String purchaseId;

  const EnhancedPurchaseDetailPage({
    super.key,
    required this.purchaseId,
  });

  @override
  ConsumerState<EnhancedPurchaseDetailPage> createState() =>
      _EnhancedPurchaseDetailPageState();
}

class _EnhancedPurchaseDetailPageState
    extends ConsumerState<EnhancedPurchaseDetailPage>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final purchase = _getMockPurchase(widget.purchaseId);
    if (purchase == null) {
      return const Scaffold(
        appBar: CustomAppBar(
          title: 'Alış Detayı',
          showDrawer: true,
        ),
        drawer: TamgaciDrawerMenu(),
        body: Center(
          child: Text('Alış bulunamadı'),
        ),
      );
    }


    return ResponsiveScaffold(
      appBar: CustomAppBar(
        title: 'Alış Detayı',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: () => _editPurchase(purchase),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _showOptions(purchase),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: Column(
        children: [
          // Alış özet kartı
          _buildPurchaseSummaryCard(purchase),

          // Tab bar
          _buildTabBar(),

          // Tab içeriği
          Expanded(
            child: _buildTabContent(purchase),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseSummaryCard(Purchase purchase) {
    final statusColor = _getStatusColor(purchase.status);
    final paymentColor = _getPaymentStatusColor(purchase.paymentStatus);

    return Card(
      margin: TamgaciConstants.paddingMedium(context),
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst kısım - Alış numarası ve durum
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
                    _getPurchaseTypeIcon(purchase.type),
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
                        purchase.purchaseNumber,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        purchase.supplierName ?? 'Tedarikçi Bilgisi Yok',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        _formatDate(purchase.purchaseDate),
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
                    _buildStatusChip(purchase.status, statusColor),
                    const SizedBox(height: 4),
                    _buildPaymentStatusChip(
                        purchase.paymentStatus, paymentColor),
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
                        purchase.totalAmount, purchase.currency),
                    AppColors.primary,
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(width: TamgaciConstants.spaceMD),
                Expanded(
                  child: _buildAmountCard(
                    'Alt Toplam',
                    CurrencyHelper.formatCurrency(
                        purchase.subtotal, purchase.currency),
                    AppColors.info,
                    Icons.calculate,
                  ),
                ),
                const SizedBox(width: TamgaciConstants.spaceMD),
                Expanded(
                  child: _buildAmountCard(
                    'KDV',
                    CurrencyHelper.formatCurrency(
                        purchase.taxAmount, purchase.currency),
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

  Widget _buildTabContent(Purchase purchase) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildDetailsTab(purchase);
      case 1:
        return _buildItemsTab(purchase);
      case 2:
        return _buildTransactionsTab(purchase);
      default:
        return _buildDetailsTab(purchase);
    }
  }

  Widget _buildDetailsTab(Purchase purchase) {
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
              _buildDetailRow('Alış Numarası', purchase.purchaseNumber),
              _buildDetailRow('Alış Türü', purchase.type.displayName),
              _buildDetailRow(
                  'Alış Tarihi', _formatDate(purchase.purchaseDate)),
              _buildDetailRow(
                  'Vade Tarihi',
                  purchase.dueDate != null
                      ? _formatDate(purchase.dueDate!)
                      : 'Belirtilmemiş'),
              _buildDetailRow(
                  'Teslim Alma Tarihi',
                  purchase.receivedDate != null
                      ? _formatDate(purchase.receivedDate!)
                      : 'Belirtilmemiş'),
              _buildDetailRow('Para Birimi', purchase.currency),
            ],
          ),

          const SizedBox(height: TamgaciConstants.spaceMD),

          // Tedarikçi Bilgileri
          _buildSectionCard(
            'Tedarikçi Bilgileri',
            Icons.business_outlined,
            [
              _buildDetailRow(
                  'Tedarikçi Adı', purchase.supplierName ?? 'Belirtilmemiş'),
              _buildDetailRow('Tedarikçi ID', purchase.supplierId),
            ],
          ),

          const SizedBox(height: TamgaciConstants.spaceMD),

          // Adres Bilgileri
          if (purchase.shippingAddress != null ||
              purchase.billingAddress != null)
            _buildSectionCard(
              'Adres Bilgileri',
              Icons.location_on_outlined,
              [
                if (purchase.shippingAddress != null)
                  _buildDetailRow('Teslimat Adresi', purchase.shippingAddress!),
                if (purchase.billingAddress != null)
                  _buildDetailRow('Fatura Adresi', purchase.billingAddress!),
              ],
            ),

          const SizedBox(height: TamgaciConstants.spaceMD),

          // Ödeme Bilgileri
          _buildSectionCard(
            'Ödeme Bilgileri',
            Icons.payment,
            [
              _buildDetailRow(
                  'Ödeme Yöntemi', purchase.paymentMethod ?? 'Belirtilmemiş'),
              _buildDetailRow(
                  'Ödeme Koşulları', purchase.paymentTerms ?? 'Belirtilmemiş'),
              _buildDetailRow(
                  'Kargo Ücreti',
                  purchase.shippingCost != null
                      ? CurrencyHelper.formatCurrency(
                          purchase.shippingCost!, purchase.currency)
                      : 'Belirtilmemiş'),
            ],
          ),

          const SizedBox(height: TamgaciConstants.spaceMD),

          // Notlar
          if (purchase.notes != null || purchase.description != null)
            _buildSectionCard(
              'Notlar',
              Icons.note_outlined,
              [
                if (purchase.description != null)
                  _buildDetailRow('Açıklama', purchase.description!),
                if (purchase.notes != null)
                  _buildDetailRow('Notlar', purchase.notes!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildItemsTab(Purchase purchase) {
    return SingleChildScrollView(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alış kalemleri
          _buildSectionCard(
            'Alış Kalemleri',
            Icons.list_alt,
            purchase.items.map((item) => _buildItemCard(item)).toList(),
          ),

          const SizedBox(height: TamgaciConstants.spaceMD),

          // Toplam özeti
          _buildTotalSummaryCard(purchase),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(Purchase purchase) {
    return SingleChildScrollView(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İşlem geçmişi
          _buildSectionCard(
            'İşlem Geçmişi',
            Icons.history,
            _getMockTransactions(purchase.id)
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

  Widget _buildItemCard(PurchaseItem item) {
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

  Widget _buildTotalSummaryCard(Purchase purchase) {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          children: [
            _buildSummaryRow(
                'Alt Toplam', purchase.subtotal, purchase.currency),
            if (purchase.discountAmount > 0)
              _buildSummaryRow('İndirim', -purchase.discountAmount,
                  purchase.currency, AppColors.warning),
            _buildSummaryRow(
                'KDV', purchase.taxAmount, purchase.currency, AppColors.info),
            if (purchase.shippingCost != null && purchase.shippingCost! > 0)
              _buildSummaryRow(
                  'Kargo', purchase.shippingCost!, purchase.currency),
            const Divider(),
            _buildSummaryRow('Toplam', purchase.totalAmount, purchase.currency,
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

  Widget _buildStatusChip(PurchaseStatus status, Color color) {
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

  Widget _buildPaymentStatusChip(PurchasePaymentStatus status, Color color) {
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

  IconData _getPurchaseTypeIcon(PurchaseType type) {
    switch (type) {
      case PurchaseType.invoice:
        return Icons.receipt;
      case PurchaseType.proforma:
        return Icons.description;
      case PurchaseType.waybill:
        return Icons.local_shipping;
      case PurchaseType.receipt:
        return Icons.point_of_sale;
      case PurchaseType.purchase:
        return Icons.shopping_cart;
      case PurchaseType.returnPurchase:
        return Icons.keyboard_return;
      case PurchaseType.estimate:
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

  Color _getStatusColor(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.draft:
        return AppColors.textSecondary;
      case PurchaseStatus.pending:
        return AppColors.warning;
      case PurchaseStatus.confirmed:
        return AppColors.info;
      case PurchaseStatus.received:
        return AppColors.success;
      case PurchaseStatus.paid:
        return AppColors.success;
      case PurchaseStatus.cancelled:
        return AppColors.error;
      case PurchaseStatus.returned:
        return AppColors.warning;
    }
  }

  Color _getPaymentStatusColor(PurchasePaymentStatus status) {
    switch (status) {
      case PurchasePaymentStatus.pending:
        return AppColors.warning;
      case PurchasePaymentStatus.partial:
        return AppColors.info;
      case PurchasePaymentStatus.paid:
        return AppColors.success;
      case PurchasePaymentStatus.overdue:
        return AppColors.error;
      case PurchasePaymentStatus.refunded:
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

  Purchase? _getMockPurchase(String purchaseId) {
    // Mock data - gerçek uygulamada provider'dan gelecek
    final purchases = [
      Purchase(
        id: '1',
        tenantId: 'mock-tenant',
        purchaseNumber: 'ALI-2024-001',
        type: PurchaseType.invoice,
        status: PurchaseStatus.received,
        paymentStatus: PurchasePaymentStatus.paid,
        supplierId: '1',
        supplierName: 'ABC Tedarik A.Ş.',
        purchaseDate: DateTime.now().subtract(const Duration(days: 7)),
        dueDate: DateTime.now().subtract(const Duration(days: 4)),
        receivedDate: DateTime.now().subtract(const Duration(days: 5)),
        subtotal: 2000.0,
        taxRate: 18.0,
        taxAmount: 360.0,
        discountAmount: 100.0,
        totalAmount: 2260.0,
        currency: 'TRY',
        notes: 'Özel notlar burada yer alır.',
        description: 'Alış açıklaması',
        shippingAddress: 'İstanbul, Türkiye',
        billingAddress: 'İstanbul, Türkiye',
        shippingCost: 50.0,
        paymentMethod: 'Banka Havalesi',
        paymentTerms: '30 gün',
        items: [
          const PurchaseItem(
            id: '1',
            purchaseId: '1',
            productId: '1',
            productName: 'Hammadde 1',
            productSku: 'SKU-001',
            quantity: 10,
            unitPrice: 200.0,
            discountAmount: 100.0,
            taxRate: 18.0,
            taxAmount: 180.0,
            totalAmount: 1900.0,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];

    try {
      return purchases.firstWhere((purchase) => purchase.id == purchaseId);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> _getMockTransactions(String purchaseId) {
    return [
      {
        'type': 'payment',
        'description': 'Ödeme yapıldı',
        'amount': 2260.0,
        'date': DateTime.now().subtract(const Duration(days: 4)),
      },
      {
        'type': 'adjustment',
        'description': 'Alış oluşturuldu',
        'amount': 2260.0,
        'date': DateTime.now().subtract(const Duration(days: 7)),
      },
    ];
  }

  void _editPurchase(Purchase purchase) {
    // Alış düzenleme sayfasına git
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : null,
        title: Text(
          'Alış Düzenle',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
        content: Text(
          'Alış düzenleme formu yakında eklenecek.',
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showOptions(Purchase purchase) {
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
