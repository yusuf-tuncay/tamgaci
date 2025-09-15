// ========== ENHANCED CUSTOMER DETAIL PAGE V2 ==========
// lib/features/customers/presentation/pages/enhanced_customer_detail_page_v2.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../core/routes/routes.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_transaction.dart';
import '../providers/customer_providers.dart';

/// Gelişmiş müşteri detay sayfası
class EnhancedCustomerDetailPageV2 extends ConsumerStatefulWidget {
  final String customerId;

  const EnhancedCustomerDetailPageV2({
    super.key,
    required this.customerId,
  });

  @override
  ConsumerState<EnhancedCustomerDetailPageV2> createState() =>
      _EnhancedCustomerDetailPageV2State();
}

class _EnhancedCustomerDetailPageV2State
    extends ConsumerState<EnhancedCustomerDetailPageV2>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Müşteri Detayı', showDrawer: true),
      drawer: const TamgaciDrawerMenu(),
      body: customersAsync.when(
        data: (customers) {
          final customer = customers.firstWhere(
            (c) => c.id == widget.customerId,
            orElse: () => throw Exception('Müşteri bulunamadı'),
          );
          return _buildCustomerDetail(customer, isDark);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Müşteri yüklenirken hata oluştu: $error',
            style: GoogleFonts.poppins(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDetail(Customer customer, bool isDark) {
    return Column(
      children: [
        // Müşteri bilgi kartı
        _buildCustomerInfoCard(customer, isDark),
        // Hızlı işlem butonları
        _buildQuickActionButtons(customer, isDark),
        // Tab bar
        _buildTabBar(isDark),
        // Tab içerikleri
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionsTab(customer, isDark),
              _buildInvoicesTab(customer, isDark),
              _buildPaymentsTab(customer, isDark),
              _buildAccountStatementTab(customer, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfoCard(Customer customer, bool isDark) {
    final balanceColor = customer.balance > 0
        ? Colors.green
        : customer.balance < 0
            ? Colors.red
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık satırı
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : 'M',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    if (customer.customerCode != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Kod: ${customer.customerCode}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: balanceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: balanceColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  CurrencyHelper.formatCurrency(customer.balance, 'TRY'),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: balanceColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // İletişim bilgileri
          _buildContactInfo(customer, isDark),
          const SizedBox(height: 16),
          // Adres bilgileri
          if (customer.address != null) ...[
            _buildAddressInfo(customer, isDark),
            const SizedBox(height: 16),
          ],
          // Kategori ve tarih bilgileri
          _buildCategoryAndDateInfo(customer, isDark),
        ],
      ),
    );
  }

  Widget _buildContactInfo(Customer customer, bool isDark) {
    return Row(
      children: [
        if (customer.phone != null) ...[
          Expanded(
            child: _buildInfoItem(
              icon: Icons.phone,
              label: 'Telefon',
              value: customer.phone!,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 16),
        ],
        if (customer.email != null) ...[
          Expanded(
            child: _buildInfoItem(
              icon: Icons.email,
              label: 'E-posta',
              value: customer.email!,
              isDark: isDark,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddressInfo(Customer customer, bool isDark) {
    return _buildInfoItem(
      icon: Icons.location_on,
      label: 'Adres',
      value: customer.address!,
      isDark: isDark,
    );
  }

  Widget _buildCategoryAndDateInfo(Customer customer, bool isDark) {
    return Row(
      children: [
        if (customer.category != null) ...[
          Expanded(
            child: _buildInfoItem(
              icon: Icons.category,
              label: 'Kategori',
              value: customer.category!,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: _buildInfoItem(
            icon: Icons.calendar_today,
            label: 'Kayıt Tarihi',
            value: DateFormat('dd.MM.yyyy').format(customer.createdAt),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButtons(Customer customer, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.sell,
              label: 'Satış Yap',
              color: Colors.green,
              onTap: () {
                // Satış yap
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Satış yapma özelliği yakında eklenecek')),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              icon: Icons.shopping_cart,
              label: 'Alış Yap',
              color: Colors.orange,
              onTap: () {
                // Alış yap
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Alış yapma özelliği yakında eklenecek')),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              icon: Icons.payment,
              label: 'Tahsilat',
              color: Colors.blue,
              onTap: () {
                // Tahsilat yap
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Tahsilat özelliği yakında eklenecek')),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              icon: Icons.edit,
              label: 'Düzenle',
              color: Colors.grey,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.editCustomer,
                  arguments: customer.id,
                );
              },
            ),
          ),
        ],
      ),
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
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
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

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'İşlemler'),
          Tab(text: 'Faturalar'),
          Tab(text: 'Ödemeler'),
          Tab(text: 'Hesap Ekstresi'),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(Customer customer, bool isDark) {
    // Mock transaction data
    final transactions = _getMockTransactions(customer.id);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(transaction, isDark);
      },
    );
  }

  Widget _buildInvoicesTab(Customer customer, bool isDark) {
    // Mock invoice data
    final invoices = _getMockInvoices(customer.id);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return _buildInvoiceCard(invoice, isDark);
      },
    );
  }

  Widget _buildPaymentsTab(Customer customer, bool isDark) {
    // Mock payment data
    final payments = _getMockPayments(customer.id);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(payment, isDark);
      },
    );
  }

  Widget _buildAccountStatementTab(Customer customer, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Hesap özeti kartı
          _buildAccountSummaryCard(customer, isDark),
          const SizedBox(height: 16),
          // Detaylı işlem listesi
          _buildDetailedTransactionList(customer, isDark),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(CustomerTransaction transaction, bool isDark) {
    final typeColor = _getTransactionTypeColor(transaction.type);
    final typeIcon = _getTransactionTypeIcon(transaction.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
                fontWeight: FontWeight.bold,
                color: typeColor,
              ),
            ),
            Text(
              _getStatusDisplayName(transaction.status),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _getStatusColor(transaction.status),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.receipt, color: Colors.white),
        ),
        title: Text(
          'Fatura: ${invoice['number']}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('dd.MM.yyyy').format(invoice['date']),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyHelper.formatCurrency(invoice['amount'], 'TRY'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              invoice['status'],
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: invoice['status'] == 'Ödendi'
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.payment, color: Colors.white),
        ),
        title: Text(
          'Ödeme: ${payment['method']}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('dd.MM.yyyy').format(payment['date']),
        ),
        trailing: Text(
          CurrencyHelper.formatCurrency(payment['amount'], 'TRY'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSummaryCard(Customer customer, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hesap Özeti',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Toplam Alacak',
                    '₺ 25,000.00',
                    Colors.green,
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Toplam Borç',
                    '₺ 15,000.00',
                    Colors.red,
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              'Net Bakiye',
              CurrencyHelper.formatCurrency(customer.balance, 'TRY'),
              customer.balance >= 0 ? Colors.green : Colors.red,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedTransactionList(Customer customer, bool isDark) {
    final transactions = _getMockTransactions(customer.id);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Detaylı İşlem Listesi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionCard(transaction, isDark);
            },
          ),
        ],
      ),
    );
  }

  // Mock data methods
  List<CustomerTransaction> _getMockTransactions(String customerId) {
    final now = DateTime.now();
    return [
      CustomerTransaction(
        id: '1',
        customerId: customerId,
        type: CustomerTransactionType.invoice,
        documentNumber: 'FAT-2024-001',
        amount: 15000.0,
        currency: 'TRY',
        transactionDate: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 30)),
        status: 'pending',
        description: 'Ürün satışı',
        companyId: 'company_1',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        createdBy: 'user_1',
      ),
      CustomerTransaction(
        id: '2',
        customerId: customerId,
        type: CustomerTransactionType.payment,
        documentNumber: 'TAH-2024-001',
        amount: 10000.0,
        currency: 'TRY',
        transactionDate: now.subtract(const Duration(days: 2)),
        dueDate: now,
        status: 'paid',
        description: 'Nakit ödeme',
        companyId: 'company_1',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        createdBy: 'user_1',
      ),
    ];
  }

  List<Map<String, dynamic>> _getMockInvoices(String customerId) {
    final now = DateTime.now();
    return [
      {
        'number': 'FAT-2024-001',
        'date': now.subtract(const Duration(days: 1)),
        'amount': 15000.0,
        'status': 'Beklemede',
      },
      {
        'number': 'FAT-2024-002',
        'date': now.subtract(const Duration(days: 5)),
        'amount': 25000.0,
        'status': 'Ödendi',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockPayments(String customerId) {
    final now = DateTime.now();
    return [
      {
        'method': 'Nakit',
        'date': now.subtract(const Duration(days: 2)),
        'amount': 10000.0,
      },
      {
        'method': 'Havale',
        'date': now.subtract(const Duration(days: 7)),
        'amount': 15000.0,
      },
    ];
  }

  Color _getTransactionTypeColor(CustomerTransactionType type) {
    switch (type) {
      case CustomerTransactionType.invoice:
        return Colors.blue;
      case CustomerTransactionType.proforma:
        return Colors.orange;
      case CustomerTransactionType.waybill:
        return Colors.purple;
      case CustomerTransactionType.payment:
        return Colors.green;
      case CustomerTransactionType.credit:
        return Colors.teal;
      case CustomerTransactionType.debit:
        return Colors.red;
      case CustomerTransactionType.sale:
        return Colors.indigo;
      case CustomerTransactionType.purchase:
        return Colors.brown;
      case CustomerTransactionType.refund:
        return Colors.pink;
    }
  }

  IconData _getTransactionTypeIcon(CustomerTransactionType type) {
    switch (type) {
      case CustomerTransactionType.invoice:
        return Icons.receipt;
      case CustomerTransactionType.proforma:
        return Icons.description;
      case CustomerTransactionType.waybill:
        return Icons.local_shipping;
      case CustomerTransactionType.payment:
        return Icons.payment;
      case CustomerTransactionType.credit:
        return Icons.add_circle;
      case CustomerTransactionType.debit:
        return Icons.remove_circle;
      case CustomerTransactionType.sale:
        return Icons.shopping_cart;
      case CustomerTransactionType.purchase:
        return Icons.shopping_bag;
      case CustomerTransactionType.refund:
        return Icons.undo;
    }
  }

  String _getStatusDisplayName(String? status) {
    if (status == null) return 'Bilinmiyor';

    switch (status.toLowerCase()) {
      case 'pending':
        return 'Beklemede';
      case 'paid':
        return 'Ödendi';
      case 'overdue':
        return 'Vadesi Geçmiş';
      case 'cancelled':
        return 'İptal Edildi';
      case 'completed':
        return 'Tamamlandı';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
