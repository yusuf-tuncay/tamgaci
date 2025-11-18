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
import 'package:go_router/go_router.dart';
import '../../domain/entities/customer.dart';
// import '../../domain/entities/customer_transaction.dart';
import '../providers/customer_providers.dart';
import '../../../cash_management/presentation/providers/cash_management_providers.dart';
import '../../../cash_management/domain/entities/cash_transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import '../../../../core/services/business/transaction_service.dart'
    show TransactionService, Transaction, TransactionType;
import '../../../sales/presentation/providers/sale_providers.dart' as sales;
import '../../../purchases/presentation/providers/purchase_providers.dart'
    as purchases;
import '../../../../core/widgets/lifecycle_mixin.dart';
import '../../../payment_collection/presentation/pages/transaction_form_screen.dart';
import '../../../payment_collection/domain/entities/payment_enums.dart';
import '../../../payment_collection/domain/entities/payment_transaction.dart';
import '../../../payment_collection/presentation/providers/payment_collection_providers.dart';
import '../../../../core/services/utils/export_service.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

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
    with SingleTickerProviderStateMixin, ConsumerLifecycleMixin {
  late TabController _tabController;
  // ignore: unused_field
  int _selectedTabIndex = 0;
  final bool _hasLoadedTransactions = false;
  bool _isCustomerInfoExpanded = false; // Müşteri bilgileri açılır/kapanır kontrolü
  bool _isAccountSummaryExpanded = true; // Hesap özeti açılır/kapanır kontrolü
  int _transactionLimit = 20; // Gösterilecek işlem sayısı
  int _transactionsBadgeCount = 0;
  int _invoicesBadgeCount = 0;
  int _paymentsBadgeCount = 0;
  int _statementBadgeCount = 0;

  void _tabListener() {
    if (mounted) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_tabListener);
    // Load cash transactions to enable payment counts and lists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(cashManagementNotifierProvider.notifier).getCashTransactions();
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_tabListener);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customersAsync = ref.watch(customersProvider);

    return ResponsiveScaffold(
      appBar: const CustomAppBar(title: 'Müşteri Detayı', showBackButton: true, showDrawer: false),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: customersAsync.when(
        data: (customers) {
          // Widget dispose edildiyse boş widget döndür
          if (!mounted) return const SizedBox.shrink();

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
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

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
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

    final invoicesAsync =
        ref.watch(sales.customerInvoicesStreamProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);
    final paymentTransactionsAsync =
        ref.watch(customerPaymentTransactionsProvider(customer.id));

    // Hesap ekstresinden net bakiyeyi hesapla
    double calculatedBalance = customer.balance;
    
    if (invoicesAsync.hasValue && paymentTransactionsAsync.hasValue) {
      final invoices = invoicesAsync.value ?? [];
      final invoiceIds = invoices.map((e) => e['id'] as String).toSet();
      final payments = cashState.cashTransactions
          .where((t) => invoiceIds.contains(t.relatedDocumentId))
          .toList();
      final paymentTransactions = paymentTransactionsAsync.value ?? [];

      double totalDebit = 0.0;
      double totalCredit = 0.0;

      // Faturalardan borç
      for (var invoice in invoices) {
        final totalAmount =
            (invoice['totalAmount'] as num?)?.toDouble() ?? 0.0;
        totalDebit += totalAmount;
      }

      // Ödemelerden alacak
      for (var payment in payments) {
        totalCredit += payment.amount;
      }

      // Payment transactions'dan
      for (var pt in paymentTransactions) {
        if (pt.direction == PaymentDirection.incoming) {
          totalCredit += pt.amount;
        } else {
          totalDebit += pt.amount;
        }
      }

      calculatedBalance = totalCredit - totalDebit;
    }

    final balanceColor = calculatedBalance > 0
        ? Colors.green
        : calculatedBalance < 0
            ? Colors.red
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tıklanabilir başlık satırı
          InkWell(
            onTap: () {
              setState(() {
                _isCustomerInfoExpanded = !_isCustomerInfoExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
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
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (customer.customerCode != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Kod: ${customer.customerCode}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                      CurrencyHelper.formatCurrency(calculatedBalance, 'TRY'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: balanceColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isCustomerInfoExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          // Açılır kapanır detay bilgileri
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isCustomerInfoExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 16),
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
                  )
                : const SizedBox.shrink(),
          ),
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButtons(Customer customer, bool isDark) {
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

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
                context.push(
                  '/sales/create?customerId=${customer.id}&customerName=${Uri.encodeComponent(customer.name)}',
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
                context.go('/purchases/create');
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              icon: Icons.payment,
              label: 'Tahsilat',
              color: Colors.blue,
              onTap: () => _navigateToPaymentForm(customer),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              icon: Icons.edit,
              label: 'Düzenle',
              color: Colors.grey,
              onTap: () {
                context.go('/customers/edit');
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
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

    final invoicesAsync =
        ref.watch(sales.customerInvoicesStreamProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);

    final invoices = invoicesAsync.maybeWhen(
      data: (list) => !mounted ? <dynamic>[] : list,
      orElse: () => <dynamic>[],
    );
    final paymentTransactionsAsync =
        ref.watch(customerPaymentTransactionsProvider(customer.id));
    final paymentTransactionsList = paymentTransactionsAsync.maybeWhen(
      data: (value) => !mounted ? <PaymentTransaction>[] : value,
      orElse: () => <PaymentTransaction>[],
    );
    final paymentTransactionIds =
        paymentTransactionsList.map((e) => e.id).toSet();
    final invoiceIds = invoices.map((e) => e['id'] as String).toSet();
    final paymentsForCustomerRaw = cashState.cashTransactions
        .where((t) => invoiceIds.contains(t.relatedDocumentId))
        .toList();
    final paymentsForCustomer = paymentsForCustomerRaw.where((t) {
      final metaId = t.metadata['paymentTransactionId']?.toString();
      if (metaId != null && paymentTransactionIds.contains(metaId)) {
        return false;
      }
      return true;
    }).toList();

    final invoicesCount =
        _invoicesBadgeCount != 0 ? _invoicesBadgeCount : invoices.length;
    final paymentsCount = _paymentsBadgeCount != 0
        ? _paymentsBadgeCount
        : paymentsForCustomer.length + paymentTransactionsList.length;
    final transactionsCount = _transactionsBadgeCount != 0
        ? _transactionsBadgeCount
        : invoicesCount + paymentsCount;
    final statementCount =
        _statementBadgeCount != 0 ? _statementBadgeCount : transactionsCount;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceContainerHighest,
            Theme.of(context).colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: isDark ? 0.3 : 0.1),
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
              ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
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
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                      ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isSelected ? 22 : 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.15),
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
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

    // Tüm işlemler: Faturalar + Ödemeler + İşlemler + Payment Transactions
    final invoicesAsync =
        ref.watch(sales.customerInvoicesStreamProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);
    final paymentTransactionsAsync =
        ref.watch(customerPaymentTransactionsProvider(customer.id));

    return FutureBuilder<List<dynamic>>(
      future: _loadCustomerTransactions(customer.id),
      builder: (context, transactionSnapshot) {
        // Widget dispose edildiyse boş widget döndür
        if (!mounted) return const SizedBox.shrink();

        if (transactionSnapshot.connectionState == ConnectionState.waiting) {
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

        if (transactionSnapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'İşlemler yüklenirken hata oluştu',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hata: ${transactionSnapshot.error}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Tüm işlemleri birleştir: Faturalar + Ödemeler + İşlemler + Payment Transactions
        return invoicesAsync.when(
          data: (invoices) {
            // Widget dispose edildiyse boş widget döndür
            if (!mounted) return const SizedBox.shrink();

            final transactionsRaw = transactionSnapshot.data ?? [];
            final paymentTransactions = paymentTransactionsAsync.maybeWhen(
              data: (value) => value,
              orElse: () => <PaymentTransaction>[],
            );

            final paymentTransactionIds =
                paymentTransactions.map((e) => e.id).toSet();
            final invoiceIds = invoices.map((e) => e['id'] as String).toSet();
            final payments = cashState.cashTransactions
                .where((t) => invoiceIds.contains(t.relatedDocumentId))
                .where((t) {
              final metaId =
                  t.metadata['paymentTransactionId']?.toString();
              if (metaId != null && paymentTransactionIds.contains(metaId)) {
                return false;
              }
              return true;
            }).toList();

            final invoiceKeys = <String>{};
            final paymentKeys = <String>{};
            final paymentTxnKeys = <String>{};
            final transactionKeys = <String>{};
            final uniqueKeys = <String>{};
            final allItems = <Map<String, dynamic>>[];

            void addItem(String key, Map<String, dynamic> item) {
              if (uniqueKeys.add(key)) {
                allItems.add(item);
              }
            }

            for (final invoice in invoices) {
              final invoiceId = invoice['id'] as String?;
              final invoiceNumber = invoice['invoiceNumber']?.toString();
              final key = 'invoice-${invoiceId ?? invoiceNumber ?? ''}';
              if (invoiceKeys.add(key)) {
                addItem(
                  key,
                  {
                    'type': 'invoice',
                    'date': _parseDateTime(invoice['saleDate']) ??
                        _parseDateTime(invoice['invoiceDate']) ??
                        DateTime.now(),
                    'data': invoice,
                  },
                );
              }
            }

            for (final payment in payments) {
              final key = 'payment-${payment.id}';
              if (paymentKeys.add(key)) {
                addItem(
                  key,
                  {
                    'type': 'payment',
                    'date': payment.transactionDate,
                    'data': payment,
                  },
                );
              }
            }

            for (final pt in paymentTransactions) {
              final key = 'paymentTransaction-${pt.id}';
              if (paymentTxnKeys.add(key)) {
                addItem(
                  key,
                  {
                    'type': 'payment_transaction',
                    'date': pt.transactionDate,
                    'data': pt,
                  },
                );
              }
            }

            for (final t in transactionsRaw.whereType<Transaction>()) {
              final invoiceRef = t.invoiceId;
              final docNumber = t.documentNumber;
              if ((invoiceRef != null && invoiceIds.contains(invoiceRef)) ||
                  (docNumber != null &&
                      docNumber.isNotEmpty &&
                      invoiceKeys.contains('invoice-$docNumber')) ||
                  t.type == TransactionType.invoice ||
                  t.type == TransactionType.sale) {
                continue;
              }
              final key = 'transaction-${docNumber ?? t.id}';
              if (transactionKeys.add(key)) {
                addItem(
                  key,
                  {
                    'type': 'transaction',
                    'date': _parseDateTime(t.transactionDate) ?? DateTime.now(),
                    'data': t,
                  },
                );
              }
            }

            allItems.sort((a, b) {
              final dateA = a['date'] as DateTime?;
              final dateB = b['date'] as DateTime?;
              if (dateA == null && dateB == null) return 0;
              if (dateA == null) return 1;
              if (dateB == null) return -1;
              return dateB.compareTo(dateA); // En yeni en üstte
            });

            final invoicesCount = invoiceKeys.length;
            final paymentsCount = paymentKeys.length + paymentTxnKeys.length;
            final transactionsCount = uniqueKeys.length;
            final statementCount = transactionsCount;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (_transactionsBadgeCount != transactionsCount ||
                  _invoicesBadgeCount != invoicesCount ||
                  _paymentsBadgeCount != paymentsCount ||
                  _statementBadgeCount != statementCount) {
                setState(() {
                  _transactionsBadgeCount = transactionsCount;
                  _invoicesBadgeCount = invoicesCount;
                  _paymentsBadgeCount = paymentsCount;
                  _statementBadgeCount = statementCount;
                });
              }
            });

            if (allItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz işlem bulunmuyor',
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

            return Column(
              children: [
                // Tümünü Gör butonu
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/customers/${customer.id}/all-transactions');
                      },
                      icon: const Icon(Icons.list_alt),
                      label: Text(
                        'Tümünü Gör (${allItems.length} işlem)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                // İşlemler listesi
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: allItems.length,
                    itemBuilder: (context, index) {
                      final item = allItems[index];
                      final type = item['type'] as String;
                      if (type == 'invoice') {
                        final invoice = item['data'];
                        return GestureDetector(
                          onTap: () {
                            final invoiceId = invoice['id'] as String?;
                            if (invoiceId != null && invoiceId.isNotEmpty) {
                              context.push('/sales/detail/$invoiceId');
                            }
                          },
                          child: _buildInvoiceTile(invoice, isDark),
                        );
                      } else if (type == 'payment') {
                        final payment = item['data'] as CashTransaction;
                        return GestureDetector(
                          onTap: () => _showPaymentDetail(payment),
                          child: _buildPaymentTile(payment, isDark),
                        );
                      } else if (type == 'payment_transaction') {
                        final pt = item['data'] as PaymentTransaction;
                        return GestureDetector(
                          onTap: () => _showPaymentTransactionDetail(pt),
                          child: _buildPaymentTransactionTile(pt, isDark),
                        );
                      } else {
                        final txn = item['data'] as Transaction;
                        return GestureDetector(
                          onTap: () => _showCustomerTransactionDetail(txn),
                          child: _buildTransactionTile(txn, isDark),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'İşlemler yüklenemedi',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  Future<List<dynamic>> _loadCustomerTransactions(String customerId) async {
    try {
      // Widget dispose edildiyse işlemi durdur
      if (!mounted) return [];

      final transactionService = TransactionService();
      final transactions =
          await transactionService.getCustomerTransactions(customerId);

      // Widget dispose edildiyse işlemi durdur
      if (!mounted) return [];

      return transactions;
    } catch (e) {
      debugPrint('Error loading customer transactions: $e');
      rethrow;
    }
  }

  Widget _buildInvoicesTab(Customer customer, bool isDark) {
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

    final invoicesAsync =
        ref.watch(sales.customerInvoicesStreamProvider(customer.id));

    final invoices = invoicesAsync.maybeWhen(
      data: (value) => !mounted ? const [] : value,
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
                            // Fatura (Satış) - invoice type ile filtrele
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

                                // Invoice type'a göre filtrele
                                final filteredInvoices =
                                    invoices.where((invoice) {
                                  return _isInvoiceType(invoice, 'invoice');
                                }).toList();

                                if (filteredInvoices.isEmpty) {
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
                                  itemCount: filteredInvoices.length,
                                  itemBuilder: (context, index) {
                                    final invoice = filteredInvoices[index];
                                    return _buildInvoiceTile(invoice, isDark);
                                  },
                                );
                              },
                            ),
                            // İrsaliye (Satış) - waybill type ile filtrele
                            Builder(
                              builder: (_) {
                                if (isLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (hasError) {
                                  return Center(
                                    child: Text(
                                      'İrsaliyeler yüklenemedi',
                                      style: GoogleFonts.poppins(
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                }

                                // Waybill type'a göre filtrele
                                final filteredInvoices =
                                    invoices.where((invoice) {
                                  return _isInvoiceType(invoice, 'waybill');
                                }).toList();

                                if (filteredInvoices.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'İrsaliye bulunamadı',
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
                                  itemCount: filteredInvoices.length,
                                  itemBuilder: (context, index) {
                                    final invoice = filteredInvoices[index];
                                    return _buildInvoiceTile(invoice, isDark);
                                  },
                                );
                              },
                            ),
                            // Proforma (Satış) - proforma type ile filtrele
                            Builder(
                              builder: (_) {
                                if (isLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (hasError) {
                                  return Center(
                                    child: Text(
                                      'Proformalar yüklenemedi',
                                      style: GoogleFonts.poppins(
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                }

                                // Proforma type'a göre filtrele
                                final filteredInvoices =
                                    invoices.where((invoice) {
                                  return _isInvoiceType(invoice, 'proforma');
                                }).toList();

                                if (filteredInvoices.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'Proforma bulunamadı',
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
                                  itemCount: filteredInvoices.length,
                                  itemBuilder: (context, index) {
                                    final invoice = filteredInvoices[index];
                                    return _buildInvoiceTile(invoice, isDark);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Alış Faturaları
                _buildPurchasesTab(customer, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab(Customer customer, bool isDark) {
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

    final invoicesAsync =
        ref.watch(sales.customerInvoicesStreamProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);
    final paymentTransactionsAsync =
        ref.watch(customerPaymentTransactionsProvider(customer.id));
    
    return invoicesAsync.when(
      data: (invoices) {
        // Widget dispose edildiyse boş widget döndür
        if (!mounted) return const SizedBox.shrink();

        final invoiceIds = invoices.map((e) => e['id'] as String).toSet();
        final payments = cashState.cashTransactions
            .where((t) => invoiceIds.contains(t.relatedDocumentId))
            .toList();
        
        final paymentTransactions = paymentTransactionsAsync.maybeWhen(
          data: (value) => value,
          orElse: () => <PaymentTransaction>[],
        );
        
        // Sadece ödemeleri göster (faturalar değil) - Cash payments ve Payment Transactions
        final paymentItems = [
          ...payments.map((t) => {
                'type': 'payment',
                'date': t.transactionDate,
                'data': t,
              }),
          ...paymentTransactions.map((pt) => {
                'type': 'payment_transaction',
                'date': pt.transactionDate,
                'data': pt,
              }),
        ]..sort((a, b) {
            final dateA = a['date'] as DateTime?;
            final dateB = b['date'] as DateTime?;
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA); // En yeni en üstte
          });

        if (paymentItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payment,
                  size: 64,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz ödeme bulunmuyor',
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: paymentItems.length,
          itemBuilder: (context, index) {
            final item = paymentItems[index];
            if (item['type'] == 'payment') {
              final payment = item['data'] as CashTransaction;
              return GestureDetector(
                onTap: () => _showPaymentDetail(payment),
                child: _buildPaymentTile(payment, isDark),
              );
            } else {
              final pt = item['data'] as PaymentTransaction;
              return GestureDetector(
                onTap: () => _showPaymentTransactionDetail(pt),
                child: _buildPaymentTransactionTile(pt, isDark),
              );
            }
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

  Widget _buildPurchasesTab(Customer customer, bool isDark) {
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

    final purchasesAsync =
        ref.watch(purchases.customerPurchasesStreamProvider(customer.id));

    final purchasesList = purchasesAsync.maybeWhen(
      data: (value) => !mounted ? const [] : value,
      orElse: () => const [],
    );
    final isLoading = purchasesAsync.isLoading;
    final hasError = purchasesAsync.hasError;

    return DefaultTabController(
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
          Expanded(
            child: TabBarView(
              children: [
                // Normal Alış - normal purchase type ile filtrele
                Builder(
                  builder: (_) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (hasError) {
                      return Center(
                        child: Text(
                          'Normal alışlar yüklenemedi',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                          ),
                        ),
                      );
                    }

                    // Normal purchase type'a göre filtrele
                    final filteredPurchases = purchasesList.where((purchase) {
                      return _isPurchaseType(purchase, 'normal');
                    }).toList();

                    if (filteredPurchases.isEmpty) {
                      return Center(
                        child: Text(
                          'Normal alış bulunamadı',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPurchases.length,
                      itemBuilder: (context, index) {
                        final purchase = filteredPurchases[index];
                        return _buildPurchaseTile(purchase, isDark);
                      },
                    );
                  },
                ),
                // Satıştan İade Alışı - returnFromSale purchase type ile filtrele
                Builder(
                  builder: (_) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (hasError) {
                      return Center(
                        child: Text(
                          'Satıştan iade alışları yüklenemedi',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                          ),
                        ),
                      );
                    }

                    // ReturnFromSale purchase type'a göre filtrele
                    final filteredPurchases = purchasesList.where((purchase) {
                      return _isPurchaseType(purchase, 'returnFromSale');
                    }).toList();

                    if (filteredPurchases.isEmpty) {
                      return Center(
                        child: Text(
                          'Satıştan iade alışı bulunamadı',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPurchases.length,
                      itemBuilder: (context, index) {
                        final purchase = filteredPurchases[index];
                        return _buildPurchaseTile(purchase, isDark);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStatementTab(Customer customer, bool isDark) {
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

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

  // Transaction helper methods
  Color _getTransactionColor(dynamic type) {
    switch (type.toString()) {
      case 'TransactionType.sale':
        return Colors.green;
      case 'TransactionType.purchase':
        return Colors.orange;
      case 'TransactionType.payment':
        return Colors.blue;
      case 'TransactionType.refund':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(dynamic type) {
    switch (type.toString()) {
      case 'TransactionType.sale':
        return Icons.shopping_cart;
      case 'TransactionType.purchase':
        return Icons.shopping_bag;
      case 'TransactionType.payment':
        return Icons.payment;
      case 'TransactionType.refund':
        return Icons.undo;
      default:
        return Icons.receipt;
    }
  }

  String _getTransactionTypeText(dynamic type) {
    switch (type.toString()) {
      case 'TransactionType.sale':
        return 'Satış';
      case 'TransactionType.purchase':
        return 'Alış';
      case 'TransactionType.payment':
        return 'Ödeme';
      case 'TransactionType.refund':
        return 'İade';
      default:
        return 'İşlem';
    }
  }

  String _getPaymentTypeName(PaymentTransactionType type) {
    switch (type) {
      case PaymentTransactionType.cash:
        return 'Nakit';
      case PaymentTransactionType.check:
        return 'Çek';
      case PaymentTransactionType.promissoryNote:
        return 'Senet';
      case PaymentTransactionType.eftTransfer:
        return 'Havale/EFT';
      case PaymentTransactionType.creditCard:
        return 'Kredi Kartı';
      case PaymentTransactionType.debtReceipt:
        return 'Borç Fişi';
      case PaymentTransactionType.creditReceipt:
        return 'Alacak Fişi';
      case PaymentTransactionType.accountTransfer:
        return 'Cari Virman';
    }
  }

  // Purchase type filtreleme helper metodları
  bool _isPurchaseType(dynamic purchase, String targetType) {
    final type = purchase['type']?.toString() ?? '';
    final purchaseType = purchase['purchaseType']?.toString() ?? '';

    // Debug için type'ları logla
    debugPrint(
        'Purchase type: $type, purchaseType: $purchaseType, targetType: $targetType');

    // PurchaseType enum kontrolü
    if (type == 'PurchaseType.$targetType' ||
        purchaseType == 'PurchaseType.$targetType') {
      return true;
    }

    // String kontrolü
    if (type == targetType || purchaseType == targetType) {
      return true;
    }

    // Capitalize kontrolü
    if (type == _capitalize(targetType) ||
        purchaseType == _capitalize(targetType)) {
      return true;
    }

    return false;
  }

  // Invoice type filtreleme helper metodları
  bool _isInvoiceType(dynamic invoice, String targetType) {
    final type = invoice['type']?.toString() ?? '';
    final saleType = invoice['saleType']?.toString() ?? '';

    // Debug için type'ları logla
    debugPrint(
        'Invoice type: $type, saleType: $saleType, targetType: $targetType');

    // SaleType enum kontrolü
    if (type == 'SaleType.$targetType' || saleType == 'SaleType.$targetType') {
      return true;
    }

    // String kontrolü
    if (type == targetType || saleType == targetType) {
      return true;
    }

    // Capitalize kontrolü
    if (type == _capitalize(targetType) ||
        saleType == _capitalize(targetType)) {
      return true;
    }

    return false;
  }

  // Purchase modülü entegrasyonu yapıldığında kullanılacak
  // bool _isPurchaseType(dynamic purchase, String targetType) {
  //   final type = purchase['type']?.toString() ?? '';
  //   return type == 'PurchaseType.$targetType' ||
  //          type == targetType ||
  //          type == _capitalize(targetType);
  // }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Hesap ekstresi tablosu
  Widget _buildAccountStatementTable(
      List<Map<String, dynamic>> entries, bool isDark) {
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

    // Mobil için kompakt görünüm, masaüstü için tablo
    final isMobile = TamgaciConstants.isMobile(context);
    
    if (isMobile) {
      return _buildMobileStatementList(entries, isDark);
    }

    double runningBalance = 0.0;

    return !mounted
        ? const SizedBox.shrink()
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                isDark ? Colors.grey[800] : Colors.grey[100],
              ),
              dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return isDark ? Colors.grey[700] : Colors.grey[200];
                  }
                  return null;
                },
              ),
              columns: [
                DataColumn(
                  label: Text(
                    'Tarih/Saat',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'İşlem Adı',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Açıklama',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Borç',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Alacak',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Bakiye',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
              rows: entries.map((entry) {
                // Widget dispose edildiyse boş row döndür
                if (!mounted) return const DataRow(cells: []);

                final transaction = entry['data'];
                final date = entry['date'] as DateTime? ?? DateTime.now();
                final isInvoice = entry['type'] == 'invoice';
                final isPayment = entry['type'] == 'payment';
                final isPaymentTransaction = entry['type'] == 'payment_transaction';
                final isOpeningBalance = entry['type'] == 'opening_balance';

                // İşlem adı ve açıklama
                String transactionName = '';
                String description = '';
                double debit = 0.0;
                double credit = 0.0;
                String currency = 'TRY';

                if (isOpeningBalance) {
                  // Açılış bakiyesi işlemi
                  transactionName = 'Açılış Bakiyesi';
                  description = 'Müşteri kayıt açılış bakiyesi';
                  final openingBalance = (transaction['openingBalance'] as num?)?.toDouble() ?? 0.0;
                  currency = transaction['currency'] ?? 'TRY';
                  
                  // Açılış bakiyesi pozitifse alacak, negatifse borç
                  if (openingBalance > 0) {
                    credit = openingBalance;
                  } else if (openingBalance < 0) {
                    debit = openingBalance.abs();
                  }
                } else if (isInvoice) {
                  // Fatura işlemi
                  transactionName = 'Fatura';
                  description = transaction['saleNumber'] ??
                      transaction['invoiceNumber'] ??
                      'N/A';
                  final totalAmount =
                      (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
                  currency = transaction['currencyCode'] ?? 'TRY';

                  // Fatura borç (müşteri borçlu)
                  debit = totalAmount;
                } else if (isPayment) {
                  // Ödeme işlemi
                  transactionName = 'Ödeme';
                  description = transaction.description ?? 'Ödeme';
                  final amount = transaction.amount ?? 0.0;
                  currency = transaction.currency ?? 'TRY';

                  // Ödeme alacak (müşteri alacaklı)
                  credit = amount;
                } else if (isPaymentTransaction) {
                  // Payment Transaction işlemi
                  final pt = transaction as PaymentTransaction;
                  // Ödeme türüne göre isim
                  switch (pt.type) {
                    case PaymentTransactionType.cash:
                      transactionName = 'Nakit';
                      break;
                    case PaymentTransactionType.check:
                      transactionName = 'Çek';
                      break;
                    case PaymentTransactionType.promissoryNote:
                      transactionName = 'Senet';
                      break;
                    case PaymentTransactionType.eftTransfer:
                      transactionName = 'Havale/EFT';
                      break;
                    case PaymentTransactionType.creditCard:
                      transactionName = 'Kredi Kartı';
                      break;
                    case PaymentTransactionType.debtReceipt:
                      transactionName = 'Borç Fişi';
                      break;
                    case PaymentTransactionType.creditReceipt:
                      transactionName = 'Alacak Fişi';
                      break;
                    case PaymentTransactionType.accountTransfer:
                      transactionName = 'Cari Virman';
                      break;
                  }
                  description = '${pt.transactionNumber} - ${pt.description ?? ""}';
                  final amount = pt.amount;
                  currency = pt.currency;

                  // Direction'a göre borç/alacak
                  if (pt.direction == PaymentDirection.incoming) {
                    credit = amount; // Tahsilat - alacak
                  } else {
                    debit = amount; // Ödeme - borç
                  }
                } else {
                  // Diğer işlemler
                  transactionName = _getTransactionTypeText(transaction.type);
                  description = transaction.description ?? '';
                  final amount = transaction.amount ?? 0.0;
                  currency = transaction.currency ?? 'TRY';

                  // İşlem tipine göre borç/alacak
                  if (transaction.type.toString().contains('sale') ||
                      transaction.type.toString().contains('purchase')) {
                    debit = amount;
                  } else {
                    credit = amount;
                  }
                }

                // Bakiye hesaplama
                runningBalance += credit - debit;

                return DataRow(
                  cells: [
                    DataCell(
                      !mounted
                          ? const SizedBox.shrink()
                          : Text(
                              DateFormat('dd.MM.yyyy HH:mm').format(date),
                              style: GoogleFonts.poppins(fontSize: 11),
                            ),
                    ),
                    DataCell(
                      Text(
                        transactionName,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        description,
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      Text(
                        debit > 0
                            ? CurrencyHelper.formatCurrency(debit, currency)
                            : '-',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: debit > 0 ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        credit > 0
                            ? CurrencyHelper.formatCurrency(credit, currency)
                            : '-',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: credit > 0 ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        CurrencyHelper.formatCurrency(runningBalance, currency),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color:
                              runningBalance >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
  }

  // Mobil için kompakt hesap ekstresi listesi
  Widget _buildMobileStatementList(
      List<Map<String, dynamic>> entries, bool isDark) {
    if (!mounted) return const SizedBox.shrink();

    double runningBalance = 0.0;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (!mounted) return const SizedBox.shrink();

        final entry = entries[index];
        final transaction = entry['data'];
        final date = entry['date'] as DateTime? ?? DateTime.now();
        final isInvoice = entry['type'] == 'invoice';
        final isPayment = entry['type'] == 'payment';
        final isPaymentTransaction = entry['type'] == 'payment_transaction';
        final isOpeningBalance = entry['type'] == 'opening_balance';

        // İşlem adı ve açıklama
        String transactionName = '';
        String description = '';
        double debit = 0.0;
        double credit = 0.0;
        String currency = 'TRY';

        if (isOpeningBalance) {
          transactionName = 'Açılış Bakiyesi';
          description = 'Müşteri kayıt açılış bakiyesi';
          final openingBalance = (transaction['openingBalance'] as num?)?.toDouble() ?? 0.0;
          currency = transaction['currency'] ?? 'TRY';
          if (openingBalance > 0) {
            credit = openingBalance;
          } else if (openingBalance < 0) {
            debit = openingBalance.abs();
          }
        } else if (isInvoice) {
          transactionName = 'Fatura';
          description = transaction['saleNumber'] ??
              transaction['invoiceNumber'] ??
              'N/A';
          final totalAmount =
              (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
          currency = transaction['currencyCode'] ?? 'TRY';
          debit = totalAmount;
        } else if (isPayment) {
          transactionName = 'Ödeme';
          description = transaction.description ?? 'Ödeme';
          final amount = transaction.amount ?? 0.0;
          currency = transaction.currency ?? 'TRY';
          credit = amount;
        } else if (isPaymentTransaction) {
          final pt = transaction as PaymentTransaction;
          switch (pt.type) {
            case PaymentTransactionType.cash:
              transactionName = 'Nakit';
              break;
            case PaymentTransactionType.check:
              transactionName = 'Çek';
              break;
            case PaymentTransactionType.promissoryNote:
              transactionName = 'Senet';
              break;
            case PaymentTransactionType.eftTransfer:
              transactionName = 'Havale/EFT';
              break;
            case PaymentTransactionType.creditCard:
              transactionName = 'Kredi Kartı';
              break;
            case PaymentTransactionType.debtReceipt:
              transactionName = 'Borç Fişi';
              break;
            case PaymentTransactionType.creditReceipt:
              transactionName = 'Alacak Fişi';
              break;
            case PaymentTransactionType.accountTransfer:
              transactionName = 'Cari Virman';
              break;
          }
          description = '${pt.transactionNumber} - ${pt.description ?? ""}';
          final amount = pt.amount;
          currency = pt.currency;
          if (pt.direction == PaymentDirection.incoming) {
            credit = amount;
          } else {
            debit = amount;
          }
        } else {
          transactionName = _getTransactionTypeText(transaction.type);
          description = transaction.description ?? '';
          final amount = transaction.amount ?? 0.0;
          currency = transaction.currency ?? 'TRY';
          if (transaction.type.toString().contains('sale') ||
              transaction.type.toString().contains('purchase')) {
            debit = amount;
          } else {
            credit = amount;
          }
        }

        // Bakiye hesaplama
        runningBalance += credit - debit;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır: Tarih ve İşlem Adı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      transactionName,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('dd.MM.yyyy').format(date),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Açıklama
              if (description.isNotEmpty)
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              // Alt satır: Borç, Alacak ve Bakiye
              Row(
                children: [
                  // Borç
                  if (debit > 0) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Borç',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyHelper.formatCurrency(debit, currency),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Alacak
                  if (credit > 0) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alacak',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyHelper.formatCurrency(credit, currency),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Bakiye (her zaman göster)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Bakiye',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyHelper.formatCurrency(runningBalance, currency),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: runningBalance >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Purchase tile widget
  Widget _buildPurchaseTile(dynamic purchase, bool isDark) {
    // purchase entity with known fields
    final isPaid = purchase['isPaid'] as bool? ?? false;
    final paymentStatus = purchase['paymentStatus']?.toString() ?? '';
    final status = purchase['status']?.toString() ?? '';

    // Debug için payment bilgilerini logla
    debugPrint(
        'Purchase payment - isPaid: $isPaid, paymentStatus: $paymentStatus, status: $status');

    // Payment status'a göre isPaid hesapla
    // isPaid field'ı primary, diğerleri sadece fallback
    final actuallyPaid = isPaid ||
        (paymentStatus == 'PaymentStatus.paid' && status != 'draft') ||
        (status == 'PurchaseStatus.paid');

    debugPrint('Final result - actuallyPaid: $actuallyPaid');
    final color = actuallyPaid ? Colors.green : Colors.orange;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: const Icon(Icons.shopping_bag, color: Colors.orange),
        ),
        title: Text(
          '${_getPurchaseTypeTitle(purchase)}: ${purchase['purchaseNumber'] ?? purchase['invoiceNumber'] ?? 'N/A'}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('dd.MM.yyyy').format(
              _parseDateTime(purchase['purchaseDate']) ??
                  _parseDateTime(purchase['invoiceDate']) ??
                  DateTime.now()),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyHelper.formatCurrency(purchase['totalAmount'] ?? 0.0,
                  purchase['currencyCode'] ?? 'TRY'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              actuallyPaid ? 'Ödendi' : 'Beklemede',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: actuallyPaid ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Purchase type'a göre başlık oluştur
  String _getPurchaseTypeTitle(dynamic purchase) {
    final type = purchase['type']?.toString() ?? '';
    final purchaseType = purchase['purchaseType']?.toString() ?? '';

    // Debug için type'ları logla
    debugPrint('Purchase type for title: $type, purchaseType: $purchaseType');

    // PurchaseType enum kontrolü
    if (type == 'PurchaseType.normal' ||
        purchaseType == 'PurchaseType.normal') {
      return 'Normal Alış';
    }
    if (type == 'PurchaseType.returnFromSale' ||
        purchaseType == 'PurchaseType.returnFromSale') {
      return 'Satıştan İade Alışı';
    }

    // String kontrolü
    if (type == 'normal' || purchaseType == 'normal') {
      return 'Normal Alış';
    }
    if (type == 'returnFromSale' || purchaseType == 'returnFromSale') {
      return 'Satıştan İade Alışı';
    }

    // Capitalize kontrolü
    if (type == 'Normal' || purchaseType == 'Normal') {
      return 'Normal Alış';
    }
    if (type == 'ReturnFromSale' || purchaseType == 'ReturnFromSale') {
      return 'Satıştan İade Alışı';
    }

    // Default fallback
    return 'Normal Alış';
  }

  // Invoice type'a göre başlık oluştur
  String _getInvoiceTypeTitle(dynamic invoice) {
    final type = invoice['type']?.toString() ?? '';
    final saleType = invoice['saleType']?.toString() ?? '';

    // Debug için type'ları logla
    debugPrint('Invoice type for title: $type, saleType: $saleType');

    // SaleType enum kontrolü
    if (type == 'SaleType.invoice' || saleType == 'SaleType.invoice') {
      return 'Fatura';
    }
    if (type == 'SaleType.waybill' || saleType == 'SaleType.waybill') {
      return 'İrsaliye';
    }
    if (type == 'SaleType.proforma' || saleType == 'SaleType.proforma') {
      return 'Proforma';
    }

    // String kontrolü
    if (type == 'invoice' || saleType == 'invoice') {
      return 'Fatura';
    }
    if (type == 'waybill' || saleType == 'waybill') {
      return 'İrsaliye';
    }
    if (type == 'proforma' || saleType == 'proforma') {
      return 'Proforma';
    }

    // Capitalize kontrolü
    if (type == 'Invoice' || saleType == 'Invoice') {
      return 'Fatura';
    }
    if (type == 'Waybill' || saleType == 'Waybill') {
      return 'İrsaliye';
    }
    if (type == 'Proforma' || saleType == 'Proforma') {
      return 'Proforma';
    }

    // Default fallback
    return 'Fatura';
  }

  // Timestamp'i DateTime'a çevirme
  DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null || !mounted) return null;

    if (dateValue is DateTime) return dateValue;
    if (dateValue is Timestamp) return dateValue.toDate();

    if (dateValue is String) {
      final formats = [
        DateFormat('yyyy-MM-ddTHH:mm:ss'),
        DateFormat('yyyy-MM-dd HH:mm:ss'),
        DateFormat('dd.MM.yyyy HH:mm'),
        DateFormat('dd.MM.yyyy'),
        DateFormat('yyyy-MM-dd'),
      ];
      for (final format in formats) {
        try {
          return format.parse(dateValue);
        } catch (_) {}
      }
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        debugPrint('Error parsing date: $e');
        return null;
      }
    }

    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }

    if (dateValue is double) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue.toInt());
    }

    return null;
  }

  Widget _buildPaymentTransactionTile(PaymentTransaction pt, bool isDark) {
    // Payment Transaction with detailed type information
    final color = pt.direction == PaymentDirection.incoming
        ? Colors.green
        : Colors.red;
    
    // Ödeme türüne göre ikon ve metin
    String typeText = '';
    IconData icon = Icons.payment;
    
    switch (pt.type) {
      case PaymentTransactionType.cash:
        typeText = pt.direction == PaymentDirection.incoming 
            ? 'Nakit Tahsilat' 
            : 'Nakit Ödeme';
        icon = Icons.money;
        break;
      case PaymentTransactionType.check:
        typeText = pt.direction == PaymentDirection.incoming 
            ? 'Çek Tahsilatı' 
            : 'Çek Ödemesi';
        icon = Icons.check_circle_outline;
        break;
      case PaymentTransactionType.promissoryNote:
        typeText = pt.direction == PaymentDirection.incoming 
            ? 'Senet Tahsilatı' 
            : 'Senet Ödemesi';
        icon = Icons.description;
        break;
      case PaymentTransactionType.eftTransfer:
        typeText = pt.direction == PaymentDirection.incoming 
            ? 'Havale/EFT Tahsilat' 
            : 'Havale/EFT Ödeme';
        icon = Icons.account_balance;
        break;
      case PaymentTransactionType.creditCard:
        typeText = 'Kredi Kartı';
        icon = Icons.credit_card;
        break;
      case PaymentTransactionType.debtReceipt:
        typeText = 'Borç Fişi';
        icon = Icons.receipt;
        break;
      case PaymentTransactionType.creditReceipt:
        typeText = 'Alacak Fişi';
        icon = Icons.receipt_long;
        break;
      case PaymentTransactionType.accountTransfer:
        typeText = 'Cari Virman';
        icon = Icons.swap_horiz;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                typeText,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pt.category.name.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'İşlem No: ${pt.transactionNumber}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              DateFormat('dd.MM.yyyy HH:mm').format(pt.transactionDate),
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            if (pt.description != null && pt.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  pt.description!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyHelper.formatCurrency(pt.amount, pt.currency),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            Text(
              pt.status.name.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: _getStatusColor(pt.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PaymentTransactionStatus status) {
    switch (status) {
      case PaymentTransactionStatus.pending:
        return Colors.orange;
      case PaymentTransactionStatus.completed:
        return Colors.green;
      case PaymentTransactionStatus.cancelled:
        return Colors.red;
      case PaymentTransactionStatus.approved:
        return Colors.blue;
      case PaymentTransactionStatus.rejected:
        return Colors.red;
      case PaymentTransactionStatus.reversed:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTransactionTile(dynamic t, bool isDark) {
    // Transaction object from TransactionService
    final color = _getTransactionColor(t.type);
    final icon = _getTransactionIcon(t.type);
    final typeText = _getTransactionTypeText(t.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          '$typeText - ${t.documentNumber ?? t.id}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd.MM.yyyy HH:mm')
                  .format(_parseDateTime(t.transactionDate) ?? DateTime.now()),
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
              CurrencyHelper.formatCurrency(
                  t.amount ?? 0.0, t.currency ?? 'TRY'),
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

  void _showPaymentDetail(CashTransaction payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Ödeme Detayı',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('İşlem No', payment.transactionNumber),
              _buildDetailRow('Tutar',
                  CurrencyHelper.formatCurrency(payment.amount, payment.currency)),
              _buildDetailRow('Tarih',
                  DateFormat('dd.MM.yyyy HH:mm').format(payment.transactionDate)),
              if (payment.description != null && payment.description!.isNotEmpty)
                _buildDetailRow('Açıklama', payment.description!),
              _buildDetailRow('Tip', payment.type.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _exportPaymentToPDF(payment);
            },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF İndir'),
          ),
        ],
      ),
    );
  }

  void _showPaymentTransactionDetail(PaymentTransaction pt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tahsilat/Ödeme Detayı',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('İşlem No', pt.transactionNumber),
              _buildDetailRow('Tip', _getPaymentTypeName(pt.type)),
              _buildDetailRow(
                  'Yön', pt.direction == PaymentDirection.incoming ? 'Tahsilat' : 'Ödeme'),
              _buildDetailRow('Tutar',
                  CurrencyHelper.formatCurrency(pt.amount, pt.currency)),
              _buildDetailRow('Tarih',
                  DateFormat('dd.MM.yyyy HH:mm').format(pt.transactionDate)),
              if (pt.dueDate != null)
                _buildDetailRow('Vade Tarihi',
                    DateFormat('dd.MM.yyyy').format(pt.dueDate!)),
              _buildDetailRow('Durum', pt.status.name.toUpperCase()),
              _buildDetailRow('Kategori', pt.category.name),
              if (pt.description != null && pt.description!.isNotEmpty)
                _buildDetailRow('Açıklama', pt.description!),
              if (pt.referenceNumber != null &&
                  pt.referenceNumber!.isNotEmpty)
                _buildDetailRow('Referans', pt.referenceNumber!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _exportPaymentTransactionToPDF(pt);
            },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF İndir'),
          ),
        ],
      ),
    );
  }

  void _showCustomerTransactionDetail(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'İşlem Detayı',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (transaction.documentNumber != null &&
                  transaction.documentNumber!.isNotEmpty)
                _buildDetailRow('Belge No', transaction.documentNumber!),
              _buildDetailRow('Tutar',
                  CurrencyHelper.formatCurrency(transaction.amount, transaction.currency)),
              _buildDetailRow('Tarih',
                  DateFormat('dd.MM.yyyy HH:mm').format(transaction.transactionDate)),
              _buildDetailRow('İşlem Türü', transaction.type.name),
              _buildDetailRow('Durum', transaction.status.name),
              if (transaction.reference != null &&
                  transaction.reference!.isNotEmpty)
                _buildDetailRow('Referans', transaction.reference!),
              if (transaction.paymentMethod != null &&
                  transaction.paymentMethod!.isNotEmpty)
                _buildDetailRow('Ödeme Yöntemi', transaction.paymentMethod!),
              if (transaction.description != null &&
                  transaction.description!.isNotEmpty)
                _buildDetailRow('Açıklama', transaction.description!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _exportCustomerTransactionToPDF(transaction);
            },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF İndir'),
          ),
        ],
      ),
    );
  }

  void _exportPaymentToPDF(CashTransaction payment) async {
    final exportService = ExportService();
    final details = <String, String>{
      'İşlem No': payment.transactionNumber,
      'Tarih':
          DateFormat('dd.MM.yyyy HH:mm').format(payment.transactionDate),
      'Tutar': _formatPdfCurrency(payment.amount, payment.currency),
      'Tip': payment.type.toString(),
      if (payment.description != null && payment.description!.isNotEmpty)
        'Açıklama': payment.description!,
    };

    try {
      final bytes = await exportService.exportTransactionDetailPDF(
        title: 'Ödeme Detayı',
        subtitle:
            'Rapor Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
        details: details,
      );

      final fileName =
          'odeme_${payment.transactionNumber}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        final blob = web.Blob([bytes.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = url;
        anchor.download = fileName;
        anchor.click();
        web.URL.revokeObjectURL(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF indirme şu an sadece web üzerinde destekleniyor'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _exportPaymentTransactionToPDF(PaymentTransaction pt) async {
    final exportService = ExportService();

    final details = <String, String>{
      'İşlem No': pt.transactionNumber,
      'Tip': _getPaymentTypeName(pt.type),
      'Yön': pt.direction == PaymentDirection.incoming ? 'Tahsilat' : 'Ödeme',
      'Tutar': _formatPdfCurrency(pt.amount, pt.currency),
      'Tarih': DateFormat('dd.MM.yyyy HH:mm').format(pt.transactionDate),
      'Durum': pt.status.name.toUpperCase(),
      'Kategori': pt.category.name,
      if (pt.referenceNumber != null && pt.referenceNumber!.isNotEmpty)
        'Referans': pt.referenceNumber!,
      if (pt.description != null && pt.description!.isNotEmpty)
        'Açıklama': pt.description!,
    };

    try {
      final bytes = await exportService.exportTransactionDetailPDF(
        title: 'Tahsilat/Ödeme Detayı',
        subtitle:
            'Rapor Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
        details: details,
      );

      final fileName =
          'payment_transaction_${pt.transactionNumber}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        final blob = web.Blob([bytes.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = url;
        anchor.download = fileName;
        anchor.click();
        web.URL.revokeObjectURL(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF indirme şu an sadece web üzerinde destekleniyor'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _exportCustomerTransactionToPDF(Transaction transaction) async {
    final exportService = ExportService();

    final details = <String, String>{
      'İşlem ID': transaction.id,
      'İşlem Türü': transaction.type.name,
      'Durum': transaction.status.name,
      'Tutar':
          _formatPdfCurrency(transaction.amount, transaction.currency),
      'Tarih':
          DateFormat('dd.MM.yyyy HH:mm').format(transaction.transactionDate),
      if (transaction.dueDate != null)
        'Vade Tarihi':
            DateFormat('dd.MM.yyyy').format(transaction.dueDate!),
      if (transaction.reference != null && transaction.reference!.isNotEmpty)
        'Referans': transaction.reference!,
      if (transaction.description != null && transaction.description!.isNotEmpty)
        'Açıklama': transaction.description!,
      if (transaction.paymentMethod != null &&
          transaction.paymentMethod!.isNotEmpty)
        'Ödeme Yöntemi': transaction.paymentMethod!,
    };

    if (transaction.metadata != null && transaction.metadata!.isNotEmpty) {
      details['Ek Bilgiler'] = transaction.metadata!.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
    }

    try {
      final bytes = await exportService.exportTransactionDetailPDF(
        title: 'İşlem Detayı',
        subtitle:
            'Rapor Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
        details: details,
      );

      final fileName =
          'transaction_${transaction.id}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        final blob = web.Blob([bytes.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = url;
        anchor.download = fileName;
        anchor.click();
        web.URL.revokeObjectURL(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF indirme şu an sadece web üzerinde destekleniyor'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatPdfCurrency(double amount, String currency) {
    if (currency.toUpperCase() == 'TRY' ||
        currency == '₺' ||
        currency.toUpperCase() == 'TL') {
      final formatted = NumberFormat.currency(
        locale: 'tr_TR',
        symbol: '',
        decimalDigits: 2,
      ).format(amount.abs());
      final prefix = amount < 0 ? '-' : '';
      return '$prefix$formatted TL';
    }
    return CurrencyHelper.formatCurrency(amount, currency);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTile(dynamic invoice, bool isDark) {
    // invoice entity with known fields
    final isPaid = invoice['isPaid'] as bool? ?? false;
    final paymentStatus = invoice['paymentStatus']?.toString() ?? '';
    final status = invoice['status']?.toString() ?? '';

    // Debug için payment bilgilerini logla
    debugPrint(
        'Invoice payment - isPaid: $isPaid, paymentStatus: $paymentStatus, status: $status');
    debugPrint(
        'Payment logic - isPaid: $isPaid, paymentStatus==PaymentStatus.paid: ${paymentStatus == 'PaymentStatus.paid'}, status!=draft: ${status != 'draft'}, status==SaleStatus.paid: ${status == 'SaleStatus.paid'}');

    // Payment status'a göre isPaid hesapla
    // isPaid field'ı primary, diğerleri sadece fallback
    final actuallyPaid = isPaid ||
        (paymentStatus == 'PaymentStatus.paid' && status != 'draft') ||
        (status == 'SaleStatus.paid');

    debugPrint('Final result - actuallyPaid: $actuallyPaid');
    final color = actuallyPaid ? Colors.green : Colors.blue;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: const Icon(Icons.receipt, color: Colors.blue),
        ),
        title: Text(
          '${_getInvoiceTypeTitle(invoice)}: ${invoice['saleNumber'] ?? invoice['invoiceNumber'] ?? 'N/A'}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('dd.MM.yyyy').format(_parseDateTime(invoice['saleDate']) ??
              _parseDateTime(invoice['invoiceDate']) ??
              DateTime.now()),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyHelper.formatCurrency(invoice['totalAmount'] ?? 0.0,
                  invoice['currencyCode'] ?? 'TRY'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              actuallyPaid ? 'Ödendi' : 'Beklemede',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: actuallyPaid ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSummaryCard(Customer customer, bool isDark) {
    final invoicesAsync =
        ref.watch(sales.customerInvoicesStreamProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);
    final paymentTransactionsAsync =
        ref.watch(customerPaymentTransactionsProvider(customer.id));
    
    return invoicesAsync.when(
      data: (invoices) {
        if (!mounted) return const SizedBox.shrink();

        final invoiceIds = invoices.map((e) => e['id'] as String).toSet();
        final payments = cashState.cashTransactions
            .where((t) => invoiceIds.contains(t.relatedDocumentId))
            .toList();
        
        final paymentTransactions = paymentTransactionsAsync.maybeWhen(
          data: (value) => value,
          orElse: () => <PaymentTransaction>[],
        );

        // Hesap ekstresi toplamlarını hesapla
        double totalDebit = 0.0;
        double totalCredit = 0.0;

        // Faturalardan borç
        for (var invoice in invoices) {
          final totalAmount =
              (invoice['totalAmount'] as num?)?.toDouble() ?? 0.0;
          totalDebit += totalAmount;
        }

        // Ödemelerden alacak
        for (var payment in payments) {
          totalCredit += payment.amount;
        }

        // Payment transactions'dan
        for (var pt in paymentTransactions) {
          if (pt.direction == PaymentDirection.incoming) {
            totalCredit += pt.amount;
          } else {
            totalDebit += pt.amount;
          }
        }

        final netBalance = totalCredit - totalDebit;

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tıklanabilir başlık
              InkWell(
                onTap: () {
                  setState(() {
                    _isAccountSummaryExpanded = !_isAccountSummaryExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Hesap Özeti',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        _isAccountSummaryExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              // Açılır kapanır içerik
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isAccountSummaryExpanded
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryItem(
                                    'Toplam Alacak',
                                    CurrencyHelper.formatCurrency(totalCredit, 'TRY'),
                                    Colors.green,
                                    isDark,
                                  ),
                                ),
                                Expanded(
                                  child: _buildSummaryItem(
                                    'Toplam Borç',
                                    CurrencyHelper.formatCurrency(totalDebit, 'TRY'),
                                    Colors.red,
                                    isDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryItem(
                              'Net Bakiye',
                              CurrencyHelper.formatCurrency(netBalance, 'TRY'),
                              netBalance >= 0 ? Colors.green : Colors.red,
                              isDark,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
      loading: () => Card(
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
              const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Hesap özeti yüklenemedi',
            style: GoogleFonts.poppins(color: Colors.red),
          ),
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
        ref.watch(sales.customerInvoicesStreamProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);
    final paymentTransactionsAsync =
        ref.watch(customerPaymentTransactionsProvider(customer.id));
    
    return invoicesAsync.when(
      data: (invoices) {
        // Widget dispose edildiyse boş widget döndür
        if (!mounted) return const SizedBox.shrink();

        final invoiceIds = invoices.map((e) => e['id'] as String).toSet();
        final payments = cashState.cashTransactions
            .where((t) => invoiceIds.contains(t.relatedDocumentId))
            .toList();
        
        final paymentTransactions = paymentTransactionsAsync.maybeWhen(
          data: (value) => value,
          orElse: () => <PaymentTransaction>[],
        );
        
        final entries = <Map<String, dynamic>>[];
        
        // Açılış bakiyesi varsa ekle (en eski tarihli işlem olarak)
        if (customer.openingBalance != null && customer.openingBalance != 0) {
          final openingBalanceDate = customer.createdAt.subtract(const Duration(days: 1));
          entries.add({
            'type': 'opening_balance',
            'date': openingBalanceDate,
            'data': {
              'openingBalance': customer.openingBalance,
              'currency': customer.customerCurrency ?? 'TRY',
            },
          });
        }
        
        // Diğer işlemleri ekle
        entries.addAll([
          ...invoices.map((i) => {
                'type': 'invoice',
                'date': i['invoiceDate'] ?? DateTime.now(),
                'data': i,
              }),
          ...payments.map((t) => {
                'type': 'payment',
                'date': t.transactionDate,
                'data': t,
              }),
          ...paymentTransactions.map((pt) => {
                'type': 'payment_transaction',
                'date': pt.transactionDate,
                'data': pt,
              }),
        ]);
        
        // Tarihe göre sırala (en eski en üstte)
        entries.sort((a, b) {
            final dateA = a['date'] as DateTime?;
            final dateB = b['date'] as DateTime?;
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateA.compareTo(dateB); // En eski en üstte (kronolojik sıra)
          });

        // Gösterilecek işlemleri limitle
        final displayedEntries = entries.take(_transactionLimit).toList();
        final hasMore = entries.length > _transactionLimit;

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve Export butonu
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Detaylı İşlem Listesi',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (entries.isNotEmpty)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.download),
                        tooltip: 'Dışa Aktar',
                        onSelected: (value) {
                          if (value == 'excel') {
                            _exportStatementToExcel(customer, entries);
                          } else if (value == 'pdf') {
                            _exportStatementToPDF(customer, entries);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'excel',
                            child: Row(
                              children: [
                                Icon(Icons.table_chart, size: 20),
                                SizedBox(width: 8),
                                Text('Excel\'e Aktar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'pdf',
                            child: Row(
                              children: [
                                Icon(Icons.picture_as_pdf, size: 20),
                                SizedBox(width: 8),
                                Text('PDF\'e Aktar'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
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
              else ...[
                _buildAccountStatementTable(displayedEntries, isDark),
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _transactionLimit += 20;
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: Text(
                          'Daha Fazla Göster (${entries.length - _transactionLimit} işlem daha var)',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ),
                  ),
              ],
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

  Future<void> _exportStatementToExcel(
    Customer customer,
    List<Map<String, dynamic>> entries,
  ) async {
    try {
      // Başlıklar
      final headers = [
        'Tarih/Saat',
        'İşlem Adı',
        'Açıklama',
        'Borç',
        'Alacak',
        'Bakiye',
      ];

      // Excel için veri hazırla
      final data = <List<dynamic>>[];
      double runningBalance = 0.0;
      double totalDebit = 0.0;
      double totalCredit = 0.0;

      for (var entry in entries) {
        final transaction = entry['data'];
        final date = entry['date'] as DateTime? ?? DateTime.now();
        final isInvoice = entry['type'] == 'invoice';
        final isPayment = entry['type'] == 'payment';
        final isPaymentTransaction = entry['type'] == 'payment_transaction';
        final isOpeningBalance = entry['type'] == 'opening_balance';

        String transactionName = '';
        String description = '';
        double debit = 0.0;
        double credit = 0.0;

        if (isOpeningBalance) {
          transactionName = 'Açılış Bakiyesi';
          description = 'Müşteri kayıt açılış bakiyesi';
          final openingBalance = (transaction['openingBalance'] as num?)?.toDouble() ?? 0.0;
          if (openingBalance > 0) {
            credit = openingBalance;
          } else if (openingBalance < 0) {
            debit = openingBalance.abs();
          }
        } else if (isInvoice) {
          transactionName = 'Fatura';
          description = transaction['saleNumber'] ??
              transaction['invoiceNumber'] ??
              'N/A';
          final totalAmount =
              (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
          debit = totalAmount;
        } else if (isPayment) {
          transactionName = 'Ödeme';
          description = transaction.description ?? 'Ödeme';
          final amount = transaction.amount ?? 0.0;
          credit = amount;
        } else if (isPaymentTransaction) {
          final pt = transaction as PaymentTransaction;
          switch (pt.type) {
            case PaymentTransactionType.cash:
              transactionName = 'Nakit';
              break;
            case PaymentTransactionType.check:
              transactionName = 'Çek';
              break;
            case PaymentTransactionType.promissoryNote:
              transactionName = 'Senet';
              break;
            case PaymentTransactionType.eftTransfer:
              transactionName = 'Havale/EFT';
              break;
            case PaymentTransactionType.creditCard:
              transactionName = 'Kredi Kartı';
              break;
            case PaymentTransactionType.debtReceipt:
              transactionName = 'Borç Fişi';
              break;
            case PaymentTransactionType.creditReceipt:
              transactionName = 'Alacak Fişi';
              break;
            case PaymentTransactionType.accountTransfer:
              transactionName = 'Cari Virman';
              break;
          }
          description = '${pt.transactionNumber} - ${pt.description ?? ""}';
          final amount = pt.amount;
          if (pt.direction == PaymentDirection.incoming) {
            credit = amount;
          } else {
            debit = amount;
          }
        } else {
          transactionName = _getTransactionTypeText(transaction.type);
          description = transaction.description ?? '';
          final amount = transaction.amount ?? 0.0;
          if (transaction.type.toString().contains('sale') ||
              transaction.type.toString().contains('purchase')) {
            debit = amount;
          } else {
            credit = amount;
          }
        }

        runningBalance += credit - debit;
        totalDebit += debit;
        totalCredit += credit;

        // Format numbers for Turkish locale
        String formatAmount(double amount) {
          if (amount == 0) return '-';
          final parts = amount.abs().toStringAsFixed(2).split('.');
          final intPart = parts[0];
          final decPart = parts[1];
          final formattedInt = intPart.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
          final formatted = '$formattedInt,$decPart';
          return '${amount < 0 ? '-' : ''}$formatted TL';
        }

        data.add([
          DateFormat('dd.MM.yyyy HH:mm').format(date),
          transactionName,
          description,
          formatAmount(debit),
          formatAmount(credit),
          formatAmount(runningBalance),
        ]);
      }

      // Özet satırları ekle
      data.add([]);
      data.add([
        '',
        '',
        'TOPLAM',
        formatAmount(totalDebit),
        formatAmount(totalCredit),
        formatAmount(totalCredit - totalDebit),
      ]);

      // Export service kullan
      final exportService = ExportService();
      final fileBytes = await exportService.exportToExcel(
        title: '${customer.name} - Hesap Ekstresi',
        headers: headers,
        data: data,
        sheetName: 'Ekstre',
      );

      // Dosya adı oluştur
      final fileName =
          '${customer.name}_Ekstre_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';

      // Web için indirme
      if (kIsWeb) {
        final blob = web.Blob([fileBytes.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = url;
        anchor.download = fileName;
        anchor.click();
        web.URL.revokeObjectURL(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ekstre başarıyla indirildi: $fileName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String formatAmount(double amount) {
    if (amount == 0) return '-';
    final parts = amount.abs().toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final formattedInt = intPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    final formatted = '$formattedInt,$decPart';
    return '${amount < 0 ? '-' : ''}$formatted TL';
  }

  Future<void> _exportStatementToPDF(
    Customer customer,
    List<Map<String, dynamic>> entries,
  ) async {
    try {
      // Başlıklar
      final headers = [
        'Tarih/Saat',
        'İşlem Adı',
        'Açıklama',
        'Borç',
        'Alacak',
        'Bakiye',
      ];

      // PDF için veri hazırla
      final data = <List<dynamic>>[];
      double runningBalance = 0.0;
      double totalDebit = 0.0;
      double totalCredit = 0.0;

      for (var entry in entries) {
        final transaction = entry['data'];
        final date = entry['date'] as DateTime? ?? DateTime.now();
        final isInvoice = entry['type'] == 'invoice';
        final isPayment = entry['type'] == 'payment';
        final isPaymentTransaction = entry['type'] == 'payment_transaction';
        final isOpeningBalance = entry['type'] == 'opening_balance';

        String transactionName = '';
        String description = '';
        double debit = 0.0;
        double credit = 0.0;

        if (isOpeningBalance) {
          transactionName = 'Açılış Bakiyesi';
          description = 'Müşteri kayıt açılış bakiyesi';
          final openingBalance = (transaction['openingBalance'] as num?)?.toDouble() ?? 0.0;
          if (openingBalance > 0) {
            credit = openingBalance;
          } else if (openingBalance < 0) {
            debit = openingBalance.abs();
          }
        } else if (isInvoice) {
          transactionName = 'Fatura';
          description = transaction['saleNumber'] ??
              transaction['invoiceNumber'] ??
              'N/A';
          final totalAmount =
              (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
          debit = totalAmount;
        } else if (isPayment) {
          transactionName = 'Ödeme';
          description = transaction.description ?? 'Ödeme';
          final amount = transaction.amount ?? 0.0;
          credit = amount;
        } else if (isPaymentTransaction) {
          final pt = transaction as PaymentTransaction;
          switch (pt.type) {
            case PaymentTransactionType.cash:
              transactionName = 'Nakit';
              break;
            case PaymentTransactionType.check:
              transactionName = 'Çek';
              break;
            case PaymentTransactionType.promissoryNote:
              transactionName = 'Senet';
              break;
            case PaymentTransactionType.eftTransfer:
              transactionName = 'Havale/EFT';
              break;
            case PaymentTransactionType.creditCard:
              transactionName = 'Kredi Kartı';
              break;
            case PaymentTransactionType.debtReceipt:
              transactionName = 'Borç Fişi';
              break;
            case PaymentTransactionType.creditReceipt:
              transactionName = 'Alacak Fişi';
              break;
            case PaymentTransactionType.accountTransfer:
              transactionName = 'Cari Virman';
              break;
          }
          description = '${pt.transactionNumber} - ${pt.description ?? ""}';
          final amount = pt.amount;
          if (pt.direction == PaymentDirection.incoming) {
            credit = amount;
          } else {
            debit = amount;
          }
        } else {
          transactionName = _getTransactionTypeText(transaction.type);
          description = transaction.description ?? '';
          final amount = transaction.amount ?? 0.0;
          if (transaction.type.toString().contains('sale') ||
              transaction.type.toString().contains('purchase')) {
            debit = amount;
          } else {
            credit = amount;
          }
        }

        runningBalance += credit - debit;
        totalDebit += debit;
        totalCredit += credit;

        // Format numbers for Turkish locale
        String formatAmountLocal(double amount) {
          if (amount == 0) return '-';
          final formatted = NumberFormat.currency(
            locale: 'tr_TR',
            symbol: '',
            decimalDigits: 2,
          ).format(amount.abs());
          return '$formatted ₺';
        }

        data.add([
          DateFormat('dd.MM.yyyy HH:mm').format(date),
          transactionName,
          description.length > 40 
              ? '${description.substring(0, 40)}...' 
              : description,
          formatAmountLocal(debit),
          formatAmountLocal(credit),
          formatAmountLocal(runningBalance),
        ]);
      }

      // Özet bilgileri
      final summary = {
        'Toplam Borç':
            CurrencyHelper.formatCurrency(totalDebit, 'TRY').replaceAll('₺', 'TL'),
        'Toplam Alacak': CurrencyHelper.formatCurrency(totalCredit, 'TRY')
            .replaceAll('₺', 'TL'),
        'Net Bakiye': CurrencyHelper
            .formatCurrency(totalCredit - totalDebit, 'TRY')
            .replaceAll('₺', 'TL'),
      };

      // Export service kullan
      final exportService = ExportService();
      final fileBytes = await exportService.exportToPDF(
        title: '${customer.name} - Hesap Ekstresi',
        subtitle: 'Müşteri Kodu: ${customer.customerCode ?? "Yok"}\n'
            'Rapor Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
        headers: headers,
        data: data,
        summary: summary,
      );

      // Dosya adı oluştur
      final fileName =
          '${customer.name}_Ekstre_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      // Web için indirme
      if (kIsWeb) {
        final blob = web.Blob([fileBytes.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = url;
        anchor.download = fileName;
        anchor.click();
        web.URL.revokeObjectURL(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF başarıyla indirildi: $fileName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF export hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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

  /// Tahsilat form dialog'unu aç
  void _navigateToPaymentForm(Customer customer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width > 768
              ? MediaQuery.of(context).size.width *
                  0.6 // Masaüstü için %60 genişlik
              : double.infinity, // Mobil için tam genişlik
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: TransactionFormScreen(
              direction: PaymentDirection.incoming,
              customerId: customer.id,
            ),
          ),
        ),
      ),
    ).then((result) {
      // Form kapatıldığında müşteri detaylarını yenile
      if (result == true && mounted) {
        setState(() {});
      }
      ref.invalidate(customerProvider(customer.id));
    });
  }
}
