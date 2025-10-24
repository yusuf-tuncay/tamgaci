// ========== ENHANCED SUPPLIER DETAIL PAGE ==========
// lib/features/suppliers/presentation/pages/enhanced_supplier_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../providers/supplier_providers.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/supplier_enums.dart';
import '../../domain/entities/supplier_transaction.dart';
import 'package:go_router/go_router.dart';
import '../../../payment_collection/presentation/pages/transaction_form_screen.dart';
import '../../../payment_collection/domain/entities/payment_enums.dart';

/// Gelişmiş tedarikçi detay sayfası
class EnhancedSupplierDetailPage extends ConsumerStatefulWidget {
  final String supplierId;

  const EnhancedSupplierDetailPage({super.key, required this.supplierId});

  @override
  ConsumerState<EnhancedSupplierDetailPage> createState() =>
      _EnhancedSupplierDetailPageState();
}

class _EnhancedSupplierDetailPageState
    extends ConsumerState<EnhancedSupplierDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // ignore: unused_field
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(supplierOperationsProvider);
    final supplier = operationsState.suppliers.firstWhere(
      (s) => s.id == widget.supplierId,
      orElse: () => throw Exception('Tedarikçi bulunamadı'),
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: supplier.name,
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: () => _showEditDialog(supplier),
            icon: const Icon(Icons.edit),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, supplier),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Kopyala'),
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Dışa Aktar'),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Sil', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          // Tedarikçi özet bilgileri
          _buildSupplierSummary(supplier),

          // Tab bar
          Container(
            color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Genel Bilgiler'),
                Tab(text: 'Alışlar'),
                Tab(text: 'Faturalar'),
                Tab(text: 'Ödemeler'),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
            ),
          ),

          // Tab içerikleri
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralInfoTab(supplier),
                _buildPurchasesTab(),
                _buildInvoicesTab(),
                _buildPaymentsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActionDialog(supplier),
        icon: const Icon(Icons.add),
        label: const Text('Hızlı İşlem'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSupplierSummary(Supplier supplier) {
    final isActive = supplier.status == SupplierStatus.active;
    final hasOutstandingBalance = supplier.currentBalance > 0;
    final isOverdue = supplier.currentBalance > supplier.creditLimit;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusLG),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Üst kısım - Logo ve temel bilgiler
          Row(
            children: [
              // Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(TamgaciConstants.radiusLG),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              // Temel bilgiler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      supplier.contactPerson ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (supplier.supplierCode != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Kod: ${supplier.supplierCode}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Durum
              _buildStatusChip(isActive, isOverdue),
            ],
          ),

          const SizedBox(height: 20),

          // Finansal özet
          Row(
            children: [
              Expanded(
                child: _buildFinancialSummaryCard(
                  'Kredi Limiti',
                  CurrencyHelper.formatCurrency(
                      supplier.creditLimit, supplier.currency),
                  Icons.credit_card,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFinancialSummaryCard(
                  'Mevcut Bakiye',
                  CurrencyHelper.formatCurrency(
                      supplier.currentBalance, supplier.currency),
                  Icons.account_balance_wallet,
                  hasOutstandingBalance ? AppColors.error : AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFinancialSummaryCard(
                  'Kullanılabilir',
                  CurrencyHelper.formatCurrency(
                    supplier.creditLimit - supplier.currentBalance,
                    supplier.currency,
                  ),
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons
          _buildActionButtons(supplier),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Supplier supplier) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.shopping_cart,
            label: 'Alış Yap',
            color: Colors.orange,
            onTap: () {
              context.go(
                  '/purchases/create?supplierId=${supplier.id}&supplierName=${Uri.encodeComponent(supplier.name)}');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.receipt,
            label: 'Fatura Al',
            color: Colors.blue,
            onTap: () {
              context.go(
                  '/purchases/create?supplierId=${supplier.id}&supplierName=${Uri.encodeComponent(supplier.name)}');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.payment,
            label: 'Ödeme Yap',
            color: Colors.green,
            onTap: () => _navigateToPaymentForm(supplier),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit,
            label: 'Düzenle',
            color: Colors.grey,
            onTap: () {
              context.go('/suppliers/edit/${supplier.id}');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.delete,
            label: 'Sil',
            color: Colors.red,
            onTap: () {
              // Silme işlemi
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
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
            title,
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

  Widget _buildStatusChip(bool isActive, bool isOverdue) {
    Color color;
    String text;

    if (isOverdue) {
      color = AppColors.error;
      text = 'Riskli';
    } else if (isActive) {
      color = AppColors.success;
      text = 'Aktif';
    } else {
      color = AppColors.textSecondary;
      text = 'Pasif';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildGeneralInfoTab(Supplier supplier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İletişim Bilgileri
          _buildInfoSection(
            'İletişim Bilgileri',
            Icons.contact_phone,
            [
              _buildInfoRow('E-posta', supplier.email ?? '', Icons.email),
              _buildInfoRow('Telefon', supplier.phone ?? '', Icons.phone),
              _buildInfoRow('Adres', supplier.address ?? '', Icons.location_on),
            ],
          ),

          const SizedBox(height: 20),

          // Vergi Bilgileri
          _buildInfoSection(
            'Vergi Bilgileri',
            Icons.receipt,
            [
              _buildInfoRow(
                  'Vergi No', supplier.taxNumber ?? '', Icons.business),
              _buildInfoRow('Vergi Dairesi', supplier.taxOffice ?? '',
                  Icons.account_balance),
            ],
          ),

          const SizedBox(height: 20),

          // Banka Bilgileri
          _buildInfoSection(
            'Banka Bilgileri',
            Icons.account_balance,
            [
              _buildInfoRow(
                  'Banka', supplier.bankName ?? '', Icons.business_center),
              _buildInfoRow(
                  'Hesap No', supplier.bankAccount ?? '', Icons.credit_card),
            ],
          ),

          const SizedBox(height: 20),

          // Sistem Bilgileri
          _buildInfoSection(
            'Sistem Bilgileri',
            Icons.info,
            [
              _buildInfoRow(
                  'Oluşturulma',
                  DateFormat('dd.MM.yyyy HH:mm').format(supplier.createdAt),
                  Icons.calendar_today),
              _buildInfoRow(
                  'Son Güncelleme',
                  DateFormat('dd.MM.yyyy HH:mm').format(supplier.updatedAt),
                  Icons.update),
              _buildInfoRow(
                  'Para Birimi', supplier.currency, Icons.attach_money),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasesTab() {
    return _buildTransactionList(SupplierTransactionType.purchase);
  }

  Widget _buildInvoicesTab() {
    return _buildTransactionList(SupplierTransactionType.invoice);
  }

  Widget _buildPaymentsTab() {
    return _buildTransactionList(SupplierTransactionType.payment);
  }

  Widget _buildTransactionList(SupplierTransactionType type) {
    final transactions = _getMockTransactions(type);

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type.icon,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '${type.displayName} bulunamadı',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu tedarikçiye ait ${type.displayName.toLowerCase()} kaydı bulunmuyor.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(SupplierTransaction transaction) {
    final typeColor = _getTransactionTypeColor(transaction.type);
    final typeIcon = transaction.type.icon;
    final statusColor = _getStatusColor(transaction.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withValues(alpha: 0.1),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          transaction.description ?? 'Açıklama yok',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${DateFormat('dd.MM.yyyy HH:mm').format(transaction.transactionDate)} - ${transaction.documentNumber}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyHelper.formatCurrency(
                  transaction.amount, transaction.currency),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: typeColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transaction.status.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetail(transaction),
      ),
    );
  }

  List<SupplierTransaction> _getMockTransactions(SupplierTransactionType type) {
    // Mock data - gerçek veriler provider'dan gelecek
    final now = DateTime.now();
    return [
      SupplierTransaction(
        id: '1',
        supplierId: widget.supplierId,
        type: type,
        status: SupplierTransactionStatus.pending,
        documentNumber: '${type.shortName}-2024-001',
        amount: 1500.0,
        currency: 'TRY',
        transactionDate: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 15)),
        description: 'Test ${type.displayName.toLowerCase()} açıklaması',
        companyId: 'company1',
        tenantId: 'tenant1',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
        createdBy: 'user1',
      ),
      SupplierTransaction(
        id: '2',
        supplierId: widget.supplierId,
        type: type,
        status: SupplierTransactionStatus.completed,
        documentNumber: '${type.shortName}-2024-002',
        amount: 2500.0,
        currency: 'TRY',
        transactionDate: now.subtract(const Duration(days: 10)),
        dueDate: now.add(const Duration(days: 20)),
        description: 'Test ${type.displayName.toLowerCase()} açıklaması 2',
        companyId: 'company1',
        tenantId: 'tenant1',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
        createdBy: 'user1',
      ),
    ];
  }

  Color _getTransactionTypeColor(SupplierTransactionType type) {
    switch (type) {
      case SupplierTransactionType.purchase:
        return AppColors.primary;
      case SupplierTransactionType.invoice:
        return AppColors.warning;
      case SupplierTransactionType.payment:
        return AppColors.success;
      case SupplierTransactionType.credit:
        return AppColors.info;
      case SupplierTransactionType.debit:
        return AppColors.error;
      case SupplierTransactionType.return_:
        return AppColors.textSecondary;
      case SupplierTransactionType.refund:
        return AppColors.textSecondary;
      case SupplierTransactionType.discount:
        return AppColors.info;
      case SupplierTransactionType.other:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(SupplierTransactionStatus status) {
    switch (status) {
      case SupplierTransactionStatus.pending:
        return Colors.orange;
      case SupplierTransactionStatus.completed:
        return Colors.green;
      case SupplierTransactionStatus.cancelled:
        return Colors.grey;
      case SupplierTransactionStatus.reversed:
        return Colors.blue;
    }
  }

  void _showEditDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tedarikçi Düzenle'),
        content: const Text('Tedarikçi düzenleme formu yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showQuickActionDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hızlı İşlem'),
        content: const Text('Hızlı işlem seçenekleri yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(SupplierTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction.type.displayName),
        content: const Text('İşlem detayları yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Supplier supplier) {
    switch (action) {
      case 'duplicate':
        _showDuplicateDialog(supplier);
        break;
      case 'export':
        _showExportDialog(supplier);
        break;
      case 'delete':
        _showDeleteDialog(supplier);
        break;
    }
  }

  void _showDuplicateDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tedarikçi Kopyala'),
        content: const Text('Tedarikçi kopyalama özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dışa Aktar'),
        content: const Text('Dışa aktarım özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tedarikçi Sil'),
        content: Text(
            '${supplier.name} tedarikçisini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Silme işlemi
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Ödeme form ekranına git
  void _navigateToPaymentForm(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormScreen(
          direction: PaymentDirection.outgoing,
          supplierId: supplier.id,
        ),
      ),
    ).then((_) {
      // Form kapatıldığında tedarikçi detaylarını yenile
      ref.invalidate(supplierProvider(supplier.id));
    });
  }
}
