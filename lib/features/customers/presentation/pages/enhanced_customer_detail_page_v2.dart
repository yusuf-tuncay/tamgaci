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
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../core/routes/routes.dart';
import '../../domain/entities/customer.dart';
// import '../../domain/entities/customer_transaction.dart';
import '../providers/customer_providers.dart';
import '../../../invoices/presentation/providers/invoice_providers.dart';
import '../../../cash_management/presentation/providers/cash_management_providers.dart';
import '../../../cash_management/domain/entities/cash_transaction.dart';

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
  bool _hasLoadedTransactions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    // Load cash transactions to enable payment counts and lists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cashManagementNotifierProvider.notifier).getCashTransactions();
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

    return ResponsiveScaffold(
      appBar: const CustomAppBar(title: 'Müşteri Detayı', showDrawer: true),
      drawerContent: const TamgaciDrawerMenu(),
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
        _buildTabBar(customer, isDark),
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
        if (customer.category1 != null) ...[
          Expanded(
            child: _buildInfoItem(
              icon: Icons.category,
              label: 'Kategori',
              value: customer.category1!,
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
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.createSale,
                  arguments: {
                    'customerId': customer.id,
                    'customerName': customer.name,
                  },
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
                Navigator.pushNamed(
                  context,
                  TamgaciRoutes.createPurchase,
                  arguments: {
                    'supplierId': customer.id,
                    'supplierName': customer.name,
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              icon: Icons.payment,
              label: 'Tahsilat',
              color: Colors.grey,
              onTap: () {}, // Silinen modül: payments
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
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              icon: Icons.delete,
              label: 'Sil',
              color: Colors.red,
              onTap: () {
                _showDeleteConfirmationDialog(customer);
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
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
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(Customer customer, bool isDark) {
    final invoicesAsync =
        ref.watch(customerInvoicesStreamProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);

    final invoices = invoicesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <dynamic>[],
    );
    final invoiceIds = invoices.map((e) => e.id as String).toSet();
    final paymentsForCustomer = cashState.cashTransactions
        .where((t) => invoiceIds.contains(t.relatedDocumentId))
        .toList();
    final invoicesCount = invoices.length;
    final paymentsCount = paymentsForCustomer.length;
    final transactionsCount = invoicesCount + paymentsCount;
    final statementCount = transactionsCount;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.grey[850]!,
                  Colors.grey[800]!,
                  Colors.grey[850]!,
                ]
              : [
                  Colors.white,
                  Colors.grey[50]!,
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.grey[700]!.withValues(alpha: 0.3)
              : Colors.grey[200]!.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicator: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(6),
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
          overlayColor: WidgetStateProperty.all(
            AppColors.primary.withValues(alpha: 0.1),
          ),
          splashFactory: InkRipple.splashFactory,
          tabs: [
            _buildPremiumTab(
              icon: Icons.swap_horiz_rounded,
              label: 'İşlemler',
              isSelected: _selectedTabIndex == 0,
              isDark: isDark,
              badgeCount: transactionsCount,
            ),
            _buildPremiumTab(
              icon: Icons.receipt_long_rounded,
              label: 'Faturalar',
              isSelected: _selectedTabIndex == 1,
              isDark: isDark,
              badgeCount: invoicesCount,
            ),
            _buildPremiumTab(
              icon: Icons.payment_rounded,
              label: 'Ödemeler',
              isSelected: _selectedTabIndex == 2,
              isDark: isDark,
              badgeCount: paymentsCount,
            ),
            _buildPremiumTab(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Hesap Ekstresi',
              isSelected: _selectedTabIndex == 3,
              isDark: isDark,
              badgeCount: statementCount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDark,
    int? badgeCount,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isSelected ? 22 : 20,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
              if ((badgeCount ?? 0) > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      (badgeCount ?? 0) > 99
                          ? '99+'
                          : (badgeCount ?? 0).toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.primary : Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            style: GoogleFonts.poppins(
              fontSize: isSelected ? 12 : 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              letterSpacing: isSelected ? 0.5 : 0.3,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(Customer customer, bool isDark) {
    final invoicesAsync =
        ref.watch(customerInvoicesStreamProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);

    // Cash transactions'ı yükle (sadece bir kez, hata durumunda retry yapma)
    // Sadece ilk yüklemede çağır, tekrar yükleme yapma
    debugPrint(
        '🐛 hasLoadedTransactions: ${cashState.hasLoadedTransactions}, isLoading: ${cashState.isLoading}, error: ${cashState.error}');
    debugPrint('🐛 Local _hasLoadedTransactions: $_hasLoadedTransactions');

    if (!_hasLoadedTransactions &&
        !cashState.isLoading &&
        cashState.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('🔄 Loading cash transactions for customer: ${customer.id}');
        _hasLoadedTransactions = true; // Local flag'i hemen true yap
        ref.read(cashManagementNotifierProvider.notifier).getCashTransactions();
      });
    }

    return Builder(
      builder: (context) {
        // İrsaliye/Proforma/Alış vb. belgeler faturalar üzerinden geliyor olabilir.
        // Fatura stream'inde hata/izin sorunu olsa bile UI'ı bloklamayalım.
        final invoices = invoicesAsync.maybeWhen(
          data: (value) => value,
          orElse: () => const [],
        );

        // Sadece nakit işlemler yüklenirken loading göster
        if (cashState.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'İşlemler yükleniyor...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final invoiceIds = invoices.map((e) => e.id).toSet();
        final payments = cashState.cashTransactions
            .where((t) => invoiceIds.contains(t.relatedDocumentId))
            .toList();

        // Müşteriye özel işlemler (satış, alış, tahsilat)
        final customerTransactions = cashState.cashTransactions
            .where((t) =>
                t.relatedDocumentId == customer.id ||
                t.metadata['customerId'] == customer.id)
            .toList();

        final entries = <Map<String, dynamic>>[
          // Faturalar
          ...invoices.map((i) => {
                'type': 'invoice',
                'date': i.invoiceDate,
                'data': i,
              }),
          // Ödemeler
          ...payments.map((t) => {
                'type': 'payment',
                'date': t.transactionDate,
                'data': t,
              }),
          // Müşteri işlemleri
          ...customerTransactions.map((t) => {
                'type': 'transaction',
                'date': t.transactionDate,
                'data': t,
              }),
        ]..sort(
            (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

        if (entries.isEmpty || cashState.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cashState.error != null
                      ? Icons.error_outline
                      : Icons.swap_horiz,
                  size: 64,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  cashState.error != null
                      ? 'İşlemler yüklenirken hata oluştu'
                      : 'Henüz işlem bulunmuyor',
              style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
                ),
                if (cashState.error != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(cashManagementNotifierProvider.notifier)
                          .getCashTransactions();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.blue[800] : Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Bu müşteri için satış, alış veya tahsilat işlemi yapılmamış',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            if (entry['type'] == 'invoice') {
              return _buildInvoiceTile(entry['data'], isDark);
            } else if (entry['type'] == 'payment') {
              return _buildPaymentTile(entry['data'], isDark);
            } else {
              return _buildTransactionTile(entry['data'], isDark);
            }
          },
        );
      },
    );
  }

  Widget _buildInvoicesTab(Customer customer, bool isDark) {
    final invoicesAsync =
        ref.watch(customerInvoicesStreamProvider(customer.id));

    final invoices = invoicesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const [],
    );
    final isLoading = invoicesAsync.isLoading;
    final hasError = invoicesAsync.hasError;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.onSurface,
            tabs: const [
              Tab(text: 'Satış Faturaları'),
              Tab(text: 'Alış Faturaları'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Satış Faturaları
                DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      TabBar(
                        isScrollable: true,
                        labelColor: Theme.of(context).colorScheme.onSurface,
                        tabs: const [
                          Tab(text: 'Fatura'),
                          Tab(text: 'İrsaliye'),
                          Tab(text: 'Proforma'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Fatura (Satış) - eldeki invoices ile
                            Builder(
                              builder: (_) {
                                if (isLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (hasError) {
                                  return Center(
                                    child: Text(
                                      'Faturalar yüklenemedi',
                                      style: GoogleFonts.poppins(
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                }
        if (invoices.isEmpty) {
          return Center(
            child: Text(
              'Fatura bulunamadı',
              style: GoogleFonts.poppins(
                fontSize: 14,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return _buildInvoiceTile(invoice, isDark);
          },
        );
      },
                            ),
                            // İrsaliye (Satış) - henüz ayrıştırma alanı yok
                            Center(
        child: Text(
                                'İrsaliye listesi için alan henüz entegre değil',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Proforma (Satış) - henüz ayrıştırma alanı yok
                            Center(
                              child: Text(
                                'Proforma listesi için alan henüz entegre değil',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Alış Faturaları
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      TabBar(
                        isScrollable: true,
                        labelColor: Theme.of(context).colorScheme.onSurface,
                        tabs: const [
                          Tab(text: 'Normal Alış'),
                          Tab(text: 'Satıştan İade Alışı'),
                        ],
                      ),
                      const Expanded(
                        child: TabBarView(
                          children: [
                            Center(
                              child: Text(
                                'Normal alış belgeleri müşteri yerine tedarikçi bazlıdır',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Center(
                              child: Text(
                                'Satıştan iade alışı listesi için alan henüz entegre değil',
                                textAlign: TextAlign.center,
                              ),
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
        ],
      ),
    );
  }

  Widget _buildPaymentsTab(Customer customer, bool isDark) {
    final invoicesAsync =
        ref.watch(customerInvoicesStreamProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);
    return invoicesAsync.when(
      data: (invoices) {
        final invoiceIds = invoices.map((e) => e.id).toSet();
        final payments = cashState.cashTransactions
            .where((t) => invoiceIds.contains(t.relatedDocumentId))
            .toList();
        if (payments.isEmpty) {
          return Center(
            child: Text(
              'Ödeme bulunamadı',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final t = payments[index];
            return _buildPaymentTile(t, isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Ödemeler yüklenemedi',
          style: GoogleFonts.poppins(color: Colors.red),
        ),
      ),
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

  // legacy invoice card (replaced by _buildInvoiceTile)

  Widget _buildPaymentTile(CashTransaction t, bool isDark) {
    final color =
        t.type == CashTransactionType.income ? Colors.green : Colors.red;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(Icons.payment, color: color),
        ),
        title: Text(
          t.transactionNumber,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('dd.MM.yyyy').format(t.transactionDate),
        ),
        trailing: Text(
          CurrencyHelper.formatCurrency(t.amount, t.currency),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(CashTransaction t, bool isDark) {
    final color =
        t.type == CashTransactionType.income ? Colors.green : Colors.red;
    final icon = t.type == CashTransactionType.income
        ? Icons.trending_up
        : Icons.trending_down;
    final typeText =
        t.type == CashTransactionType.income ? 'Tahsilat' : 'Ödeme';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          '$typeText - ${t.transactionNumber}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd.MM.yyyy HH:mm').format(t.transactionDate),
            ),
            if (t.description != null && t.description!.isNotEmpty)
              Text(
                t.description!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyHelper.formatCurrency(t.amount, t.currency),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              typeText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceTile(dynamic invoice, bool isDark) {
    // invoice entity with known fields
    final color = invoice.isPaid ? Colors.green : Colors.blue;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: const Icon(Icons.receipt, color: Colors.blue),
        ),
        title: Text(
          'Fatura: ${invoice.invoiceNumber}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('dd.MM.yyyy').format(invoice.invoiceDate),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyHelper.formatCurrency(
                  invoice.totalAmount, invoice.currencyCode),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              invoice.isPaid ? 'Ödendi' : 'Beklemede',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: invoice.isPaid ? Colors.green : Colors.orange,
              ),
            ),
          ],
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
    final invoicesAsync =
        ref.watch(customerInvoicesStreamProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);
    return invoicesAsync.when(
      data: (invoices) {
        final invoiceIds = invoices.map((e) => e.id).toSet();
        final payments = cashState.cashTransactions
            .where((t) => invoiceIds.contains(t.relatedDocumentId))
            .toList();
        final entries = <Map<String, dynamic>>[
          ...invoices.map((i) => {
                'type': 'invoice',
                'date': i.invoiceDate,
                'data': i,
              }),
          ...payments.map((t) => {
                'type': 'payment',
                'date': t.transactionDate,
                'data': t,
              }),
        ]..sort(
            (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

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
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Kayıt yok',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    if (entry['type'] == 'invoice') {
                      return _buildInvoiceTile(entry['data'], isDark);
                    } else {
                      return _buildPaymentTile(entry['data'], isDark);
                    }
                  },
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Hesap ekstresi yüklenemedi',
          style: GoogleFonts.poppins(color: Colors.red),
        ),
      ),
    );
  }

  // Removed mock data methods; using live Firestore data via providers

  // Removed unused legacy helpers: _getTransactionTypeColor, _getTransactionTypeIcon,
  // _getStatusDisplayName, _getStatusColor

  Future<void> _showDeleteConfirmationDialog(Customer customer) async {
    final canDelete = customer.currentBalance == 0.0;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Müşteri Sil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${customer.name} müşterisini silmek istediğinizden emin misiniz?'),
              const SizedBox(height: 16),
              if (!canDelete) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bu müşterinin ${CurrencyHelper.formatCurrency(customer.currentBalance, customer.customerCurrency ?? 'TRY')} bakiyesi var. Bakiye sıfır olmadığı sürece müşteri silinemez.',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('İptal'),
            ),
            if (canDelete)
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await _deleteCustomer(customer);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sil'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCustomer(Customer customer) async {
    try {
      await ref
          .read(customerOperationsProvider.notifier)
          .deleteCustomer(customer.id);

      // Provider'ı yenile
      ref.invalidate(customersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customer.name} başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );

        // Müşteri listesine geri dön
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Müşteri silinirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
