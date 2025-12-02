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
    show TransactionService, Transaction;
import '../../../sales/presentation/providers/sale_providers.dart' as sales;
import '../../../purchases/presentation/providers/purchase_providers.dart'
    as purchases;
import '../../../purchases/domain/entities/purchase.dart' show PurchaseType;
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
  final int? initialTabIndex;

  const EnhancedCustomerDetailPageV2({
    super.key,
    required this.customerId,
    this.initialTabIndex,
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
  bool _isCustomerInfoExpanded =
      false; // Müşteri bilgileri açılır/kapanır kontrolü
  bool _isAccountSummaryExpanded = true; // Hesap özeti açılır/kapanır kontrolü
  int _transactionLimit = 20; // Gösterilecek işlem sayısı
  int _transactionsBadgeCount = 0;
  int _invoicesBadgeCount = 0;
  int _paymentsBadgeCount = 0;
  int _statementBadgeCount = 0;

  // Hesap ekstresi filtreleme
  DateTime? _statementStartDate;
  DateTime? _statementEndDate;
  String _statementSortBy = 'date'; // date, amount, type
  bool _statementSortAscending = true; // true = en eskiden en yeniye
  bool _isStatementFiltersExpanded = false; // Filtreler açılır/kapanır kontrolü

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
        // Eğer initialTabIndex belirtilmişse, tab'ı değiştir
        if (widget.initialTabIndex != null &&
            widget.initialTabIndex! >= 0 &&
            widget.initialTabIndex! < 4) {
          _tabController.animateTo(widget.initialTabIndex!);
        }
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
      appBar: CustomAppBar(
        title: 'Müşteri Detayı',
        showBackButton: true,
        showDrawer: false,
        onBackPressed: () {
          context.go('/customers');
        },
      ),
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

  String _customerCurrencyCode(Customer customer) {
    final primary = customer.customerCurrency?.trim();
    if (primary != null && primary.isNotEmpty) {
      return primary.toUpperCase();
    }
    final balanceCurrency = customer.balanceCurrency.trim();
    if (balanceCurrency.isNotEmpty) {
      return balanceCurrency.toUpperCase();
    }
    return 'TRY';
  }

  Widget _buildCustomerInfoCard(Customer customer, bool isDark) {
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

    final invoicesAsync =
        ref.watch(sales.customerInvoicesStreamProvider(customer.id));
    final purchasesAsync =
        ref.watch(purchases.customerPurchasesStreamProvider(customer.id));
    final paymentTransactionsAsync =
        ref.watch(customerPaymentTransactionsProvider(customer.id));

    // Hesap ekstresinden net bakiyeyi hesapla (açılış bakiyesi dahil)
    double calculatedBalance = customer.balance;

    if (invoicesAsync.hasValue &&
        paymentTransactionsAsync.hasValue &&
        purchasesAsync.hasValue) {
      final invoices = invoicesAsync.value ?? [];
      final purchasesList = purchasesAsync.value ?? [];
      final paymentTransactions = paymentTransactionsAsync.value ?? [];

      double totalDebit = 0.0; // Borç hanesi
      double totalCredit = 0.0; // Alacak hanesi

      // Açılış bakiyesini hesaba kat
      if (customer.openingBalance != null && customer.openingBalance != 0) {
        if (customer.openingBalance! > 0) {
          // Pozitif açılış bakiyesi: Cari hesap firmaya borçlu (Alacak)
          totalCredit += customer.openingBalance!;
        } else {
          // Negatif açılış bakiyesi: Firma cari hesaba borçlu (Borç)
          totalDebit += customer.openingBalance!.abs();
        }
      }

      // Satışlardan alacak (Pozitif) - Proformalar hariç
      for (var invoice in invoices) {
        // Proformaları filtrele
        if (_isInvoiceType(invoice, 'proforma')) {
          continue;
        }
        final totalAmount = (invoice['totalAmount'] as num?)?.toDouble() ?? 0.0;
        // Satış: Alacak hanesine pozitif (Müşteri firmaya borçlanır)
        totalCredit += totalAmount;
      }

      // Payment transactions'dan (Ön Muhasebe Kuralları)
      for (var pt in paymentTransactions) {
        if (pt.direction == PaymentDirection.incoming) {
          // Gelen tahsilat: Müşteri borcunu azaltır → Borç hanesine pozitif
          totalDebit += pt.amount;
        } else {
          // Giden tahsilat: Firma borcunu azaltır → Alacak hanesine pozitif
          totalCredit += pt.amount;
        }
      }

      // Alışlardan borç (Pozitif)
      for (var purchase in purchasesList) {
        final totalAmount =
            (purchase['totalAmount'] as num?)?.toDouble() ?? 0.0;
        // Alış: Borç hanesine pozitif (Firma karşı tarafa borçlanır)
        totalDebit += totalAmount;
      }

      // Cari Bakiye = Alacak Toplamı - Borç Toplamı (Ön Muhasebe Kuralları)
      calculatedBalance = totalCredit - totalDebit;
    }

    final currencyCode = _customerCurrencyCode(customer);
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
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
                      CurrencyHelper.formatCurrency(
                          calculatedBalance, currencyCode),
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
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
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
                context.push(
                  '/purchases/create?customerId=${customer.id}&customerName=${Uri.encodeComponent(customer.name)}',
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
                context.push('/customers/edit/${customer.id}');
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
    final invoicesCount =
        _invoicesBadgeCount != 0 ? _invoicesBadgeCount : invoices.length;
    final paymentsCount = _paymentsBadgeCount != 0
        ? _paymentsBadgeCount
        : paymentTransactionsList.length;
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
            color: Theme.of(context)
                .colorScheme
                .shadow
                .withValues(alpha: isDark ? 0.3 : 0.1),
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
              ? Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3)
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.8),
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
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
              label: 'Satışlar / Alışlar',
              isSelected: _selectedTabIndex == 1,
              isDark: isDark,
              badgeCount: null,
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
                      ? Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isSelected ? 22 : 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
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
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withValues(alpha: 0.15),
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
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
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
    final purchasesAsync =
        ref.watch(purchases.customerPurchasesStreamProvider(customer.id));
    final paymentTransactionsAsync =
        ref.watch(customerPaymentTransactionsProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);

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

            final paymentTransactions = paymentTransactionsAsync.maybeWhen(
              data: (value) => value,
              orElse: () => <PaymentTransaction>[],
            );
            final purchasesList = purchasesAsync.maybeWhen(
              data: (value) => value,
              orElse: () => <dynamic>[],
            );
            final paymentTransactionIds =
                paymentTransactions.map((pt) => pt.id).toSet();
            final cashPayments = cashState.cashTransactions.where((t) {
              final metaCustomerId =
                  t.metadata['customerId']?.toString() ??
                      t.metadata['customer_id']?.toString();
              final relatedCustomer = t.relatedDocumentType == 'customer'
                  ? t.relatedDocumentId
                  : null;
              final isCustomerMatch =
                  metaCustomerId == customer.id || relatedCustomer == customer.id;
              if (!isCustomerMatch) return false;

              final metaPaymentTxnId =
                  t.metadata['paymentTransactionId']?.toString();
              if (metaPaymentTxnId != null &&
                  paymentTransactionIds.contains(metaPaymentTxnId)) {
                return false;
              }
              return true;
            }).toList();

            final invoiceCoverage = _computeInvoiceCoverage(
              invoices,
              paymentTransactions,
              cashPayments,
            );

            final invoiceKeys = <String>{};
            final paymentKeys = <String>{};
            final paymentTxnKeys = <String>{};
            final purchaseKeys = <String>{};
            final uniqueKeys = <String>{};
            final allItems = <Map<String, dynamic>>[];

            void addItem(String key, Map<String, dynamic> item) {
              if (uniqueKeys.add(key)) {
                allItems.add(item);
              }
            }

            for (final invoice in invoices) {
              // Proformalar işlem sekmesinde görünür; sadece ekstrede filtrelenir
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

            // CashTransaction döngüsü kaldırıldı - sadece PaymentTransaction kullanılıyor

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

            // Transaction döngüsü kaldırıldı - duplikasyon önlendi

            for (final purchase in purchasesList) {
              final purchaseId = purchase['id']?.toString() ??
                  purchase['purchaseNumber'] ??
                  '';
              final key = 'purchase-$purchaseId';
              if (purchaseKeys.add(key)) {
                final date =
                    _parseDateTime(purchase['purchaseDate']) ?? DateTime.now();
                final entryType =
                    _isPurchaseType(purchase, PurchaseType.returnPurchase)
                        ? 'RETURN'
                        : 'PURCHASE';
                addItem(
                  key,
                  {
                    'type': entryType,
                    'date': date,
                    'data': purchase,
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
            // statementCount artık _buildDetailedTransactionList içinde hesaplanıyor

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (_transactionsBadgeCount != transactionsCount ||
                  _invoicesBadgeCount != invoicesCount ||
                  _paymentsBadgeCount != paymentsCount) {
                setState(() {
                  _transactionsBadgeCount = transactionsCount;
                  _invoicesBadgeCount = invoicesCount;
                  _paymentsBadgeCount = paymentsCount;
                  // _statementBadgeCount artık _buildDetailedTransactionList içinde güncelleniyor
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
                        context
                            .push('/customers/${customer.id}/all-transactions');
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
                          child: _buildInvoiceTile(
                            invoice,
                            isDark,
                            coveredFromPayments:
                                invoiceCoverage[_invoiceKey(invoice)],
                          ),
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
                      } else if (type == 'PURCHASE' || type == 'RETURN') {
                        final purchase = item['data'] as Map<String, dynamic>;
                        final isReturn = type == 'RETURN';
                        return GestureDetector(
                          onTap: () {
                            final purchaseId = purchase['id']?.toString() ?? '';
                            if (purchaseId.isNotEmpty) {
                              context.push('/purchases/detail/$purchaseId');
                            }
                          },
                          child: _buildPurchaseActivityTile(
                              purchase, isReturn, isDark),
                        );
                      }
                      return const SizedBox.shrink();
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
    final paymentTransactionsAsync =
        ref.watch(customerPaymentTransactionsProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);

    final invoices = invoicesAsync.maybeWhen(
      data: (value) => !mounted ? const [] : value,
      orElse: () => const [],
    );
    final isLoading = invoicesAsync.isLoading;
    final hasError = invoicesAsync.hasError;

    final paymentTransactions = paymentTransactionsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => <PaymentTransaction>[],
    );

    final paymentTransactionIds =
        paymentTransactions.map((pt) => pt.id).toSet();
    final cashPayments = cashState.cashTransactions.where((t) {
      final metaCustomerId =
          t.metadata['customerId']?.toString() ??
              t.metadata['customer_id']?.toString();
      final relatedCustomer =
          t.relatedDocumentType == 'customer' ? t.relatedDocumentId : null;
      final isCustomerMatch =
          metaCustomerId == customer.id || relatedCustomer == customer.id;
      if (!isCustomerMatch) return false;

      final metaPaymentTxnId =
          t.metadata['paymentTransactionId']?.toString();
      if (metaPaymentTxnId != null &&
          paymentTransactionIds.contains(metaPaymentTxnId)) {
        return false;
      }

      // Sadece müşteri tahsilatları (gelir) dikkate alınsın
      return t.type == CashTransactionType.income;
    }).toList();

    final invoicePaymentCoverage =
        _computeInvoiceCoverage(invoices, paymentTransactions, cashPayments);

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
                                    return _buildInvoiceTile(
                                      invoice,
                                      isDark,
                                      coveredFromPayments: invoicePaymentCoverage[
                                          _invoiceKey(invoice)],
                                    );
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
                                    return _buildInvoiceTile(
                                      invoice,
                                      isDark,
                                      coveredFromPayments:
                                          invoicePaymentCoverage[_invoiceKey(
                                              invoice)],
                                    );
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
                                    return _buildInvoiceTile(
                                      invoice,
                                      isDark,
                                      coveredFromPayments:
                                          invoicePaymentCoverage[_invoiceKey(
                                              invoice)],
                                    );
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
    // Widget dispose edildiyse bos widget dondur
    if (!mounted) return const SizedBox.shrink();

    final invoicesAsync =
        ref.watch(sales.customerInvoicesStreamProvider(customer.id));
    final paymentTransactionsAsync =
        ref.watch(customerPaymentTransactionsProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);

    return invoicesAsync.when(
      data: (invoices) {
        if (!mounted) return const SizedBox.shrink();

        final paymentTransactions = paymentTransactionsAsync.maybeWhen(
          data: (value) => value,
          orElse: () => <PaymentTransaction>[],
        );
        final paymentTransactionIds =
            paymentTransactions.map((pt) => pt.id).toSet();

        final cashPayments = cashState.cashTransactions.where((t) {
          final metaCustomerId =
              t.metadata['customerId']?.toString() ??
                  t.metadata['customer_id']?.toString();
          final relatedCustomer =
              t.relatedDocumentType == 'customer' ? t.relatedDocumentId : null;
          final isCustomerMatch =
              metaCustomerId == customer.id || relatedCustomer == customer.id;
          if (!isCustomerMatch) return false;

          final metaPaymentTxnId =
              t.metadata['paymentTransactionId']?.toString();
          if (metaPaymentTxnId != null &&
              paymentTransactionIds.contains(metaPaymentTxnId)) {
            return false;
          }
          return true;
        }).toList();

        final incomingItems = <Map<String, dynamic>>[
          ...cashPayments
              .where((p) => p.type == CashTransactionType.income)
              .map((p) => {
                    'type': 'payment',
                    'date': p.transactionDate,
                    'data': p,
                  }),
          ...paymentTransactions
              .where((pt) => pt.direction == PaymentDirection.incoming)
              .map((pt) => {
                    'type': 'payment_transaction',
                    'date': pt.transactionDate,
                    'data': pt,
                  }),
        ]
          ..sort((a, b) {
            final dateA = a['date'] as DateTime?;
            final dateB = b['date'] as DateTime?;
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA);
          });

        final outgoingItems = <Map<String, dynamic>>[
          ...cashPayments
              .where((p) => p.type == CashTransactionType.expense)
              .map((p) => {
                    'type': 'payment',
                    'date': p.transactionDate,
                    'data': p,
                  }),
          ...paymentTransactions
              .where((pt) => pt.direction == PaymentDirection.outgoing)
              .map((pt) => {
                    'type': 'payment_transaction',
                    'date': pt.transactionDate,
                    'data': pt,
                  }),
        ]
          ..sort((a, b) {
            final dateA = a['date'] as DateTime?;
            final dateB = b['date'] as DateTime?;
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA);
          });

        Widget buildList(List<Map<String, dynamic>> items, String emptyText) {
          if (items.isEmpty) {
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
                    emptyText,
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
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
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
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const SizedBox(height: 8),
              TabBar(
                isScrollable: true,
                labelColor: Theme.of(context).colorScheme.onSurface,
                tabs: const [
                  Tab(text: 'Gelen Ödemeler'),
                  Tab(text: 'Giden Ödemeler'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    buildList(incomingItems, 'Henüz gelen ödeme yok'),
                    buildList(outgoingItems, 'Henüz giden ödeme yok'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Odemeler yuklenemedi',
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
    debugPrint(
        'Purchases tab data count: ${purchasesList.length}, types: ${purchasesList.map((p) => p['type']).toList()}');

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.onSurface,
            tabs: const [
              Tab(text: 'PURCHASE'),
              Tab(text: 'RETURN'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // PURCHASE - normal purchase type ile filtrele
                Builder(
                  builder: (_) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (hasError) {
                      return Center(
                        child: Text(
                          'PURCHASE kayıtları yüklenemedi',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                          ),
                        ),
                      );
                    }

                    // Normal purchase type'a göre filtrele
                    final filteredPurchases = purchasesList.where((purchase) {
                      return _isPurchaseType(purchase, PurchaseType.purchase);
                    }).toList();

                    if (filteredPurchases.isEmpty) {
                      return Center(
                        child: Text(
                          'Herhangi bir PURCHASE bulunamadı',
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
                // RETURN - returnFromSale purchase type ile filtrele
                Builder(
                  builder: (_) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (hasError) {
                      return Center(
                        child: Text(
                          'RETURN kayıtları yüklenemedi',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                          ),
                        ),
                      );
                    }

                    // ReturnFromSale purchase type'a göre filtrele
                    final filteredPurchases = purchasesList.where((purchase) {
                      return _isPurchaseType(
                          purchase, PurchaseType.returnPurchase);
                    }).toList();

                    if (filteredPurchases.isEmpty) {
                      return Center(
                        child: Text(
                          'Herhangi bir RETURN bulunamadı',
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
    const color = AppColors.success;
    final displayAmount = _formatSignedCurrency(t.amount, t.currency, false);
    const directionLabel = 'Müşteriden Tahsilat';
    final statusText = (t.status.name).toUpperCase();
    final subtitleText = (t.description?.trim().isNotEmpty ?? false)
        ? t.description!.trim()
        : directionLabel;

    return _buildUnifiedActivityTile(
      title: directionLabel,
      icon: Icons.payment,
      color: color,
      amountText: displayAmount,
      amountColor: color,
      date: t.transactionDate,
      line1: 'İşlem No: ${t.transactionNumber}',
      description: subtitleText,
      statusText: statusText,
      isDark: isDark,
    );
  }

  Widget _buildUnifiedActivityTile({
    required String title,
    required IconData icon,
    required Color color,
    required String amountText,
    required Color amountColor,
    required DateTime date,
    required String line1,
    String? description,
    String? statusText,
    bool isDark = false,
  }) {
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

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
                title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              line1,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: subtitleColor,
              ),
            ),
            Text(
              DateFormat('dd.MM.yyyy HH:mm').format(date),
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            if (description != null && description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: subtitleColor,
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
              amountText,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: amountColor,
              ),
            ),
            if (statusText != null && statusText.isNotEmpty)
              Text(
                statusText,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: amountColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Transaction helper methods
  // ignore: unused_element
  Color _getTransactionColor(dynamic type) {
    switch (type.toString()) {
      case 'TransactionType.sale':
        return AppColors.success;
      case 'TransactionType.purchase':
        return AppColors.error;
      case 'TransactionType.payment':
        return AppColors.info;
      case 'TransactionType.refund':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  // ignore: unused_element
  IconData _getTransactionIcon(dynamic type) {
    switch (type.toString()) {
      case 'TransactionType.sale':
        return Icons.receipt;
      case 'TransactionType.purchase':
        return Icons.shopping_cart;
      case 'TransactionType.payment':
        return Icons.payment;
      case 'TransactionType.refund':
        return Icons.keyboard_return;
      default:
        return Icons.receipt;
    }
  }

  String _getTransactionTypeText(dynamic type) {
    switch (type.toString()) {
      case 'TransactionType.sale':
        return 'SALE';
      case 'TransactionType.purchase':
        return 'PURCHASE';
      case 'TransactionType.payment':
        return 'PAYMENT';
      case 'TransactionType.refund':
        return 'RETURN';
      default:
        return 'TRANSACTION';
    }
  }

  bool _isCreditTransactionType(dynamic type) {
    final typeStr = (type?.toString() ?? '').toLowerCase();

    if (typeStr.contains('purchase') ||
        typeStr.contains('return') ||
        typeStr.contains('refund')) {
      return false;
    }

    // Refund, sale, payment vb. işlemleri alacak (credit) olarak kabul et
    return true;
  }

  String _formatSignedCurrency(double amount, String? currency, bool isCredit) {
    final normalizedCurrency =
        currency == null || currency.isEmpty ? 'TRY' : currency;
    final formatted =
        CurrencyHelper.formatCurrency(amount.abs(), normalizedCurrency);
    if (amount == 0) return formatted;
    final sign = isCredit ? '+' : '-';
    return '$sign$formatted';
  }

  String _getTransactionTypeTextFromString(String typeStr) {
    switch (typeStr) {
      case 'TransactionType.sale':
      case 'sale':
        return 'SALE';
      case 'TransactionType.purchase':
      case 'purchase':
        return 'PURCHASE';
      case 'TransactionType.payment':
      case 'payment':
        return 'PAYMENT';
      case 'TransactionType.refund':
      case 'refund':
        return 'RETURN';
      default:
        return 'TRANSACTION';
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
  bool _isPurchaseType(dynamic purchase, PurchaseType targetType) {
    final typeValue = purchase['type']?.toString() ?? '';
    final purchaseTypeValue = purchase['purchaseType']?.toString() ?? '';
    final targetName = targetType.name;

    // Debug için type'ları logla
    debugPrint(
        'Purchase type: $typeValue, purchaseType: $purchaseTypeValue, targetType: $targetName');

    bool matches(String value) {
      if (value.isEmpty) return false;
      return value == targetName ||
          value == 'PurchaseType.$targetName' ||
          value == targetType.displayName ||
          value == _capitalize(targetName) ||
          _legacyPurchaseTypeAliases(targetType).contains(value);
    }

    return matches(typeValue) || matches(purchaseTypeValue);
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
                final isPaymentTransaction =
                    entry['type'] == 'payment_transaction';
                final isCashPayment = entry['type'] == 'payment';
                final isPurchase = entry['type'] == 'PURCHASE';
                final isPurchaseReturn = entry['type'] == 'RETURN';
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
                  final openingBalance =
                      (transaction['openingBalance'] as num?)?.toDouble() ??
                          0.0;
                  currency = transaction['currency'] ?? 'TRY';

                  // Açılış bakiyesi: Pozitifse cari hesap firmaya borçlu (Alacak), negatifse firma cari hesaba borçlu (Borç)
                  if (openingBalance > 0) {
                    credit = openingBalance; // Alacak hanesi
                  } else if (openingBalance < 0) {
                    debit = openingBalance.abs(); // Borç hanesi
                  }
                } else if (isInvoice) {
                  // Fatura/İrsaliye işlemi (Satış)
                  transactionName = _getInvoiceTypeTitle(transaction);
                  description = transaction['saleNumber'] ??
                      transaction['invoiceNumber'] ??
                      'N/A';
                  final totalAmount =
                      (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
                  currency = transaction['currencyCode'] ?? 'TRY';

                  // Satış: Müşteri firmaya borçlanır → Alacak hanesi (pozitif)
                  credit = totalAmount;
                  // CashTransaction (payment) işleme kısmı kaldırıldı
                } else if (isPaymentTransaction) {
                  // Payment Transaction işlemi
                  PaymentTransactionType? ptType;
                  String? ptDescription;
                  String? ptTransactionNumber;
                  double ptAmount = 0.0;
                  String ptCurrency = 'TRY';
                  PaymentDirection? ptDirection;

                  if (transaction is PaymentTransaction) {
                    ptType = transaction.type;
                    ptDescription = transaction.description;
                    ptTransactionNumber = transaction.transactionNumber;
                    ptAmount = transaction.amount;
                    ptCurrency = transaction.currency;
                    ptDirection = transaction.direction;
                  } else if (transaction is Map<String, dynamic>) {
                    final typeStr = transaction['type']?.toString() ?? '';
                    ptType = PaymentTransactionType.values.firstWhere(
                      (e) => e.name == typeStr,
                      orElse: () => PaymentTransactionType.cash,
                    );
                    ptDescription = transaction['description']?.toString();
                    ptTransactionNumber =
                        transaction['transactionNumber']?.toString();
                    ptAmount =
                        (transaction['amount'] as num?)?.toDouble() ?? 0.0;
                    ptCurrency = transaction['currency']?.toString() ?? 'TRY';
                    final directionStr =
                        transaction['direction']?.toString() ?? '';
                    ptDirection = PaymentDirection.values.firstWhere(
                      (e) => e.name == directionStr,
                      orElse: () => PaymentDirection.outgoing,
                    );
                  }

                  if (ptType != null) {
                    // Ödeme türüne göre isim
                    switch (ptType) {
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
                  }
                  final directionLabel =
                      ptDirection == PaymentDirection.incoming ? 'Tahsilat' : 'Ödeme';
                  transactionName = '$directionLabel - $transactionName';
                  // Açıklama oluştur
                  final txnNumber = ptTransactionNumber?.isNotEmpty == true
                      ? ptTransactionNumber
                      : 'TXN-${DateTime.now().millisecondsSinceEpoch}';
                  final desc = ptDescription?.isNotEmpty == true
                      ? ptDescription
                      : '${ptDirection == PaymentDirection.incoming ? "Müşteri" : "Firma"} tahsilatı';
                  description = '$txnNumber - $desc';
                  final amount = ptAmount;
                  currency = ptCurrency;

                  // Direction'a göre borç/alacak (Ön Muhasebe Kuralları)
                  if (ptDirection == PaymentDirection.incoming) {
                    // Gelen tahsilat: borç hanesi (bakiyeyi azaltır)
                    debit = amount;
                  } else {
                    // Giden ödeme: alacak hanesi (bakiyeyi artırır)
                    credit = amount;
                  }
                } else if (isCashPayment) {
                  transactionName = 'Nakit Tahsilat';
                  if (transaction is CashTransaction) {
                    description = transaction.description ?? '';
                    currency = transaction.currency;
                    debit = transaction.amount;
                  } else if (transaction is Map<String, dynamic>) {
                    description = transaction['description']?.toString() ?? '';
                    currency = transaction['currency']?.toString() ?? 'TRY';
                    debit =
                        (transaction['amount'] as num?)?.toDouble() ?? 0.0;
                  }
                } else if (isPurchase) {
                  // Purchase işlemi
                  transactionName = 'Satın Alma';
                  if (transaction is Map<String, dynamic>) {
                    description = transaction['purchaseNumber']?.toString() ??
                        transaction['invoiceNumber']?.toString() ??
                        'N/A';
                    final totalAmount =
                        (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
                    currency = transaction['currencyCode']?.toString() ??
                        transaction['currency']?.toString() ??
                        'TRY';
                    // Alış: Borç hanesine pozitif (Firma karşı tarafa borçlanır)
                    debit = totalAmount;
                  }
                } else if (isPurchaseReturn) {
                  // Return işlemi
                  transactionName = 'Alış İadesi';
                  if (transaction is Map<String, dynamic>) {
                    description = transaction['purchaseNumber']?.toString() ??
                        transaction['invoiceNumber']?.toString() ??
                        'N/A';
                    final totalAmount =
                        (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
                    currency = transaction['currencyCode']?.toString() ??
                        transaction['currency']?.toString() ??
                        'TRY';
                    // Return: Borç hanesine pozitif (Firma karşı tarafa borçlanır)
                    debit = totalAmount;
                  }
                } else {
                  // Diğer işlemler (Transaction nesnesi)
                  if (transaction is Transaction) {
                    transactionName = _getTransactionTypeText(transaction.type);
                    description = transaction.description ?? '';
                    final amount = transaction.amount;
                    currency = transaction.currency;

                    final typeStr = transaction.type.toString().toLowerCase();
                    if (typeStr.contains('sale')) {
                      credit = amount;
                    } else if (typeStr.contains('purchase') ||
                        typeStr.contains('return')) {
                      debit = amount;
                    } else {
                      credit = amount;
                    }
                  } else if (transaction is Map<String, dynamic>) {
                    final typeStrRaw = transaction['type']?.toString() ?? '';
                    final typeStr = typeStrRaw.toLowerCase();
                    transactionName =
                        _getTransactionTypeTextFromString(typeStrRaw);
                    description = transaction['description']?.toString() ?? '';
                    final amount =
                        (transaction['amount'] as num?)?.toDouble() ?? 0.0;
                    currency = transaction['currency']?.toString() ?? 'TRY';

                    if (typeStr.contains('sale')) {
                      credit = amount;
                    } else if (typeStr.contains('purchase') ||
                        typeStr.contains('return')) {
                      debit = amount;
                    } else {
                      credit = amount;
                    }
                  }
                }

                // Bakiye hesaplama (Ön Muhasebe: Borç - Alacak)
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
        final isPaymentTransaction = entry['type'] == 'payment_transaction';
        final isCashPayment = entry['type'] == 'payment';
        final isPurchase = entry['type'] == 'PURCHASE';
        final isPurchaseReturn = entry['type'] == 'RETURN';
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
          final openingBalance =
              (transaction['openingBalance'] as num?)?.toDouble() ?? 0.0;
          currency = transaction['currency'] ?? 'TRY';
          if (openingBalance > 0) {
            // Pozitif açılış bakiyesi: Cari hesap firmaya borçlu (Alacak)
            credit = openingBalance;
          } else if (openingBalance < 0) {
            // Negatif açılış bakiyesi: Firma cari hesaba borçlu (Borç)
            debit = openingBalance.abs();
          }
        } else if (isInvoice) {
          // Satış: Müşteri firmaya borçlanır → Alacak hanesi (pozitif)
          transactionName = _getInvoiceTypeTitle(transaction);
          description = transaction['saleNumber'] ??
              transaction['invoiceNumber'] ??
              'N/A';
          final totalAmount =
              (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
          currency = transaction['currencyCode'] ?? 'TRY';
          credit = totalAmount;
          // CashTransaction (payment) işleme kısmı kaldırıldı
        } else if (isPaymentTransaction) {
          PaymentTransactionType? ptType;
          String? ptDescription;
          String? ptTransactionNumber;
          double ptAmount = 0.0;
          String ptCurrency = 'TRY';
          PaymentDirection? ptDirection;

          if (transaction is PaymentTransaction) {
            ptType = transaction.type;
            ptDescription = transaction.description;
            ptTransactionNumber = transaction.transactionNumber;
            ptAmount = transaction.amount;
            ptCurrency = transaction.currency;
            ptDirection = transaction.direction;
          } else if (transaction is Map<String, dynamic>) {
            final typeStr = transaction['type']?.toString() ?? '';
            ptType = PaymentTransactionType.values.firstWhere(
              (e) => e.name == typeStr,
              orElse: () => PaymentTransactionType.cash,
            );
            ptDescription = transaction['description']?.toString();
            ptTransactionNumber = transaction['transactionNumber']?.toString();
            ptAmount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
            ptCurrency = transaction['currency']?.toString() ?? 'TRY';
            final directionStr = transaction['direction']?.toString() ?? '';
            ptDirection = PaymentDirection.values.firstWhere(
              (e) => e.name == directionStr,
              orElse: () => PaymentDirection.outgoing,
            );
          }

          if (ptType != null) {
            switch (ptType) {
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
          }
          final directionLabel =
              ptDirection == PaymentDirection.incoming ? 'Tahsilat' : 'Ödeme';
          transactionName = '$directionLabel - $transactionName';
          // Açıklama oluştur
          final txnNumber = ptTransactionNumber?.isNotEmpty == true
              ? ptTransactionNumber
              : 'TXN-${DateTime.now().millisecondsSinceEpoch}';
          final desc = ptDescription?.isNotEmpty == true
              ? ptDescription
              : '${ptDirection == PaymentDirection.incoming ? "Müşteri" : "Firma"} tahsilatı';
          description = '$txnNumber - $desc';
          final amount = ptAmount;
          currency = ptCurrency;
          // Direction'a göre borç/alacak (Ön Muhasebe Kuralları)
          if (ptDirection == PaymentDirection.incoming) {
            // Gelen tahsilat: borç hanesi (bakiyeyi azaltır)
            debit = amount;
          } else {
            // Giden ödeme: alacak hanesi (bakiyeyi artırır)
            credit = amount;
          }
        } else if (isCashPayment) {
          transactionName = 'Nakit Tahsilat';
          if (transaction is CashTransaction) {
            description = transaction.description ?? '';
            currency = transaction.currency;
            debit = transaction.amount;
          } else if (transaction is Map<String, dynamic>) {
            description = transaction['description']?.toString() ?? '';
            currency = transaction['currency']?.toString() ?? 'TRY';
            debit = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
          }
        } else if (isPurchase) {
          transactionName = 'Satın Alma';
          if (transaction is Map<String, dynamic>) {
            description = transaction['purchaseNumber']?.toString() ??
                transaction['invoiceNumber']?.toString() ??
                'N/A';
            final totalAmount =
                (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
            currency = transaction['currencyCode']?.toString() ??
                transaction['currency']?.toString() ??
                'TRY';
            // Alış: Borç hanesine pozitif (Firma karşı tarafa borçlanır)
            debit = totalAmount;
          }
        } else if (isPurchaseReturn) {
          transactionName = 'Alış İadesi';
          if (transaction is Map<String, dynamic>) {
            description = transaction['purchaseNumber']?.toString() ??
                transaction['invoiceNumber']?.toString() ??
                'N/A';
            final totalAmount =
                (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
            currency = transaction['currencyCode']?.toString() ??
                transaction['currency']?.toString() ??
                'TRY';
            // Return: Borç hanesine pozitif (Firma karşı tarafa borçlanır)
            debit = totalAmount;
          }
        } else {
          if (transaction is Transaction) {
            transactionName = _getTransactionTypeText(transaction.type);
            description = transaction.description ?? '';
            final amount = transaction.amount;
            currency = transaction.currency;
            if (transaction.type.toString().contains('sale') ||
                transaction.type.toString().contains('purchase')) {
              debit = amount;
            } else {
              credit = amount;
            }
          } else if (transaction is Map<String, dynamic>) {
            final typeStr = transaction['type']?.toString() ?? '';
            transactionName = _getTransactionTypeTextFromString(typeStr);
            description = transaction['description']?.toString() ?? '';
            final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
            currency = transaction['currency']?.toString() ?? 'TRY';
            if (typeStr.contains('sale') || typeStr.contains('purchase')) {
              debit = amount;
            } else {
              credit = amount;
            }
          }
        }

        // Bakiye hesaplama (Ön Muhasebe: Borç - Alacak)
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
                    DateFormat('dd.MM.yyyy HH:mm').format(date),
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
                          CurrencyHelper.formatCurrency(
                              runningBalance, currency),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color:
                                runningBalance >= 0 ? Colors.green : Colors.red,
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

    // Purchase type'ını kontrol et
    final isReturn = _isPurchaseType(purchase, PurchaseType.returnPurchase);

    // Debug için payment bilgilerini logla
    debugPrint(
        'Purchase payment - isPaid: $isPaid, paymentStatus: $paymentStatus, status: $status, isReturn: $isReturn');

    // Payment status'a göre isPaid hesapla
    // isPaid field'ı primary, diğerleri sadece fallback
    final actuallyPaid = isPaid ||
        (paymentStatus == 'PaymentStatus.paid' && status != 'draft') ||
        (status == 'PurchaseStatus.paid');

    debugPrint('Final result - actuallyPaid: $actuallyPaid');

    // Return için farklı renk ve ikon
    final localizedTitle = isReturn ? 'Alış İadesi' : 'Satın Alma';
    final color = isReturn ? AppColors.warning : AppColors.error;
    final icon = isReturn ? Icons.keyboard_return : Icons.shopping_cart;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          localizedTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Belge No: ${purchase['purchaseNumber'] ?? purchase['invoiceNumber'] ?? 'N/A'}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            Text(
              DateFormat('dd.MM.yyyy HH:mm').format(
                _parseDateTime(purchase['purchaseDate']) ??
                    _parseDateTime(purchase['invoiceDate']) ??
                    DateTime.now(),
              ),
            ),
          ],
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
                color: color,
              ),
            ),
            Text(
              localizedTitle,
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

  Set<String> _legacyPurchaseTypeAliases(PurchaseType target) {
    switch (target) {
      case PurchaseType.purchase:
        return {
          'normal',
          'Normal',
          'PurchaseType.normal',
          'purchase_normal',
        };
      case PurchaseType.returnPurchase:
        return {
          'return',
          'Return',
          'RETURN',
          'returnFromSale',
          'ReturnFromSale',
          'PurchaseType.returnFromSale',
        };
      default:
        return {};
    }
  }

  // Invoice type'a göre başlık oluştur
  String _getInvoiceTypeTitle(dynamic invoice) {
    final type = invoice['type']?.toString() ?? '';
    final saleType = invoice['saleType']?.toString() ?? '';

    // Debug için type'ları logla
    debugPrint('Invoice type for title: $type, saleType: $saleType');

    // SaleType enum kontrolü
    if (type == 'SaleType.invoice' || saleType == 'SaleType.invoice') {
      return 'Satış Faturası';
    }
    if (type == 'SaleType.waybill' || saleType == 'SaleType.waybill') {
      return 'İrsaliye';
    }
    if (type == 'SaleType.proforma' || saleType == 'SaleType.proforma') {
      return 'Proforma';
    }

    // String kontrolü
    if (type == 'invoice' || saleType == 'invoice') {
      return 'Satış Faturası';
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
    // Gelen tahsilat bakiyeyi azaltır (negatif), giden ödeme bakiyeyi artırır (pozitif)
    final color = pt.direction == PaymentDirection.incoming
        ? AppColors.success
        : AppColors.error;
    final displayAmount = _formatSignedCurrency(
      pt.amount,
      pt.currency,
      pt.direction == PaymentDirection.outgoing,
    );

    // Ödeme yönü ve tür bilgisi
    final directionLabel = pt.direction == PaymentDirection.incoming
        ? 'Müşteriden Tahsilat'
        : 'Müşteriye Ödeme';
    String methodText = '';
    IconData icon = Icons.payment;

    switch (pt.type) {
      case PaymentTransactionType.cash:
        methodText = pt.direction == PaymentDirection.incoming
            ? 'Nakit Tahsilat'
            : 'Nakit Ödeme';
        icon = Icons.money;
        break;
      case PaymentTransactionType.check:
        methodText = pt.direction == PaymentDirection.incoming
            ? 'Çek Tahsilatı'
            : 'Çek Ödemesi';
        icon = Icons.check_circle_outline;
        break;
      case PaymentTransactionType.promissoryNote:
        methodText = pt.direction == PaymentDirection.incoming
            ? 'Senet Tahsilatı'
            : 'Senet Ödemesi';
        icon = Icons.description;
        break;
      case PaymentTransactionType.eftTransfer:
        methodText = pt.direction == PaymentDirection.incoming
            ? 'Havale/EFT Tahsilat'
            : 'Havale/EFT Ödeme';
        icon = Icons.account_balance;
        break;
      case PaymentTransactionType.creditCard:
        methodText = 'Kredi Kartı';
        icon = Icons.credit_card;
        break;
      case PaymentTransactionType.debtReceipt:
        methodText = 'Borç Fişi';
        icon = Icons.receipt;
        break;
      case PaymentTransactionType.creditReceipt:
        methodText = 'Alacak Fişi';
        icon = Icons.receipt_long;
        break;
      case PaymentTransactionType.accountTransfer:
        methodText = 'Cari Virman';
        icon = Icons.swap_horiz;
        break;
    }

    // Açıklama metnini yön etiketine göre ayarla
    final rawDesc = pt.description?.trim() ?? '';
    final descLower = rawDesc.toLowerCase();
    const autoDescriptions = {
      'müşteri tahsilatı',
      'müşteri tahsilat',
      'firma tahsilatı',
      'firma tahsilat',
      'müşteriye ödeme',
      'müşteri ödeme',
    };
    final subtitleText =
        (rawDesc.isEmpty || autoDescriptions.contains(descLower))
            ? directionLabel
            : rawDesc;

    return _buildUnifiedActivityTile(
      title: methodText.isNotEmpty ? methodText : directionLabel,
      icon: icon,
      color: color,
      amountText: displayAmount,
      amountColor: color,
      date: pt.transactionDate,
      line1: 'İşlem No: ${pt.transactionNumber}',
      description: subtitleText,
      statusText: null,
      isDark: isDark,
    );
  }

  Map<String, bool> _computeInvoiceCoverage(
    List<dynamic> invoices,
    List<PaymentTransaction> paymentTransactions,
    List<CashTransaction> cashPayments,
  ) {
    final totalIncomingPayments = paymentTransactions
        .where((pt) => pt.direction == PaymentDirection.incoming)
        .fold<double>(0, (sum, pt) => sum + pt.amount);
    final totalIncomingCash =
        cashPayments.fold<double>(0, (sum, t) => sum + t.amount);

    var remaining = totalIncomingPayments + totalIncomingCash;

    final invoiceList = invoices
        .where((inv) =>
            _isInvoiceType(inv, 'invoice') || _isInvoiceType(inv, 'waybill'))
        .map((inv) {
          final date = _parseDateTime(inv['saleDate']) ??
              _parseDateTime(inv['invoiceDate']) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final key = _invoiceKey(inv);
          return {
            'data': inv,
            'date': date,
            'key': key,
          };
        })
        .toList()
      ..sort((a, b) =>
          (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    final coverage = <String, bool>{};
    for (final item in invoiceList) {
      final inv = item['data'];
      final key = item['key'] as String;
      final amount = (inv['totalAmount'] as num?)?.toDouble() ?? 0.0;
      final alreadyPaid = (inv['isPaid'] as bool?) ?? false;

      if (alreadyPaid || amount <= 0) {
        coverage[key] = true;
        continue;
      }

      if (remaining + 1e-6 >= amount) {
        coverage[key] = true;
        remaining -= amount;
      } else {
        coverage[key] = false;
      }
    }

    return coverage;
  }

  String _invoiceKey(dynamic invoice) {
    return (invoice['id'] ??
            invoice['saleNumber'] ??
            invoice['invoiceNumber'] ??
            invoice.hashCode)
        .toString();
  }

  Widget _buildPurchaseActivityTile(
      Map<String, dynamic> purchase, bool isReturn, bool isDark) {
    final purchaseNumber = (purchase['purchaseNumber'] ?? purchase['id'] ?? '')
        .toString()
        .toUpperCase();
    final date = _parseDateTime(purchase['purchaseDate']) ?? DateTime.now();
    final amount = (purchase['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final currency = (purchase['currency'] ??
            purchase['currencyCode'] ??
            purchase['paymentCurrency'] ??
            'TRY')
        .toString();

    // Purchase verisinden de type kontrolü yap (güvenlik için)
    final actualIsReturn =
        isReturn || _isPurchaseType(purchase, PurchaseType.returnPurchase);

    final localizedTitle = actualIsReturn ? 'Alış İadesi' : 'Satın Alma';
    final color = actualIsReturn ? AppColors.warning : AppColors.error;
    final icon = actualIsReturn ? Icons.keyboard_return : Icons.shopping_cart;
    final description = purchase['description']?.toString();
    final displayAmount = _formatSignedCurrency(amount, currency, false);

    return _buildUnifiedActivityTile(
      title: localizedTitle,
      icon: icon,
      color: color,
      amountText: displayAmount,
      amountColor: color,
      date: date,
      line1: purchaseNumber,
      description: (description?.isNotEmpty == true)
          ? description!
          : (purchase['notes']?.toString() ?? ''),
      statusText: null,
      isDark: isDark,
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
              _buildDetailRow(
                  'Tutar',
                  CurrencyHelper.formatCurrency(
                      payment.amount, payment.currency)),
              _buildDetailRow(
                  'Tarih',
                  DateFormat('dd.MM.yyyy HH:mm')
                      .format(payment.transactionDate)),
              if (payment.description != null &&
                  payment.description!.isNotEmpty)
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
                  'Yön',
                  pt.direction == PaymentDirection.incoming
                      ? 'Tahsilat'
                      : 'Ödeme'),
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
              if (pt.referenceNumber != null && pt.referenceNumber!.isNotEmpty)
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
  void _exportPaymentToPDF(CashTransaction payment) async {
    final exportService = ExportService();
    final details = <String, String>{
      'İşlem No': payment.transactionNumber,
      'Tarih': DateFormat('dd.MM.yyyy HH:mm').format(payment.transactionDate),
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
              content:
                  Text('PDF indirme şu an sadece web üzerinde destekleniyor'),
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
              content:
                  Text('PDF indirme şu an sadece web üzerinde destekleniyor'),
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

  // ignore: unused_element
  void _exportCustomerTransactionToPDF(Transaction transaction) async {
    final exportService = ExportService();

    final details = <String, String>{
      'İşlem ID': transaction.id,
      'İşlem Türü': transaction.type.name,
      'Durum': transaction.status.name,
      'Tutar': _formatPdfCurrency(transaction.amount, transaction.currency),
      'Tarih':
          DateFormat('dd.MM.yyyy HH:mm').format(transaction.transactionDate),
      if (transaction.dueDate != null)
        'Vade Tarihi': DateFormat('dd.MM.yyyy').format(transaction.dueDate!),
      if (transaction.reference != null && transaction.reference!.isNotEmpty)
        'Referans': transaction.reference!,
      if (transaction.description != null &&
          transaction.description!.isNotEmpty)
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
              content:
                  Text('PDF indirme şu an sadece web üzerinde destekleniyor'),
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

  Widget _buildInvoiceTile(
    dynamic invoice,
    bool isDark, {
    bool? coveredFromPayments,
  }) {
    // invoice entity with known fields
    final isPaid = invoice['isPaid'] as bool? ?? false;
    final paymentStatus = invoice['paymentStatus']?.toString() ?? '';
    final status = invoice['status']?.toString() ?? '';
    final isProforma = _isInvoiceType(invoice, 'proforma');

    // Debug için payment bilgilerini logla
    debugPrint(
        'Invoice payment - isPaid: $isPaid, paymentStatus: $paymentStatus, status: $status');
    debugPrint(
        'Payment logic - isPaid: $isPaid, paymentStatus==PaymentStatus.paid: ${paymentStatus == 'PaymentStatus.paid'}, status!=draft: ${status != 'draft'}, status==SaleStatus.paid: ${status == 'SaleStatus.paid'}');

    // Payment status'a göre isPaid hesapla
    // isPaid field'ı primary, diğerleri sadece fallback
    final actuallyPaid = coveredFromPayments ??
        isPaid ||
        (paymentStatus == 'PaymentStatus.paid' && status != 'draft') ||
        (status == 'SaleStatus.paid');

    debugPrint('Final result - actuallyPaid: $actuallyPaid');
    final statusLower = status.toLowerCase();
    final isCancelled =
        statusLower.contains('cancel'); // cancelled / canceled / cancel
    final label = isCancelled
        ? 'İptal'
        : actuallyPaid
            ? 'Ödendi'
            : 'Ödenmedi';
    final color = actuallyPaid ? Colors.green : Colors.blue;

    final title = _getInvoiceTypeTitle(invoice);
    final docNo =
        invoice['saleNumber'] ?? invoice['invoiceNumber'] ?? 'N/A';
    final date = _parseDateTime(invoice['saleDate']) ??
        _parseDateTime(invoice['invoiceDate']) ??
        DateTime.now();
    final amountText = CurrencyHelper.formatCurrency(
        invoice['totalAmount'] ?? 0.0, invoice['currencyCode'] ?? 'TRY');

    return _buildUnifiedActivityTile(
      title: '$title: $docNo',
      icon: Icons.receipt,
      color: color,
      amountText: amountText,
      amountColor: color,
      date: date,
      line1: 'Belge No: $docNo',
      description: null,
      statusText: isProforma ? null : label,
      isDark: isDark,
    );
  }

  Widget _buildAccountSummaryCard(Customer customer, bool isDark) {
    final invoicesAsync =
        ref.watch(sales.customerInvoicesStreamProvider(customer.id));
    final purchasesAsync =
        ref.watch(purchases.customerPurchasesStreamProvider(customer.id));
    final paymentTransactionsAsync =
        ref.watch(customerPaymentTransactionsProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);

    final currencyCode = _customerCurrencyCode(customer);
    return invoicesAsync.when(
      data: (invoices) {
        if (!mounted) return const SizedBox.shrink();

        final paymentTransactions = paymentTransactionsAsync.maybeWhen(
          data: (value) => value,
          orElse: () => <PaymentTransaction>[],
        );

        final purchasesList = purchasesAsync.maybeWhen(
          data: (value) => value,
          orElse: () => <dynamic>[],
        );

        final paymentTransactionIds =
            paymentTransactions.map((pt) => pt.id).toSet();
        final cashPayments = cashState.cashTransactions.where((t) {
          final metaCustomerId =
              t.metadata['customerId']?.toString() ??
                  t.metadata['customer_id']?.toString();
          final relatedCustomer =
              t.relatedDocumentType == 'customer' ? t.relatedDocumentId : null;
          final isCustomerMatch =
              metaCustomerId == customer.id || relatedCustomer == customer.id;
          if (!isCustomerMatch) return false;

          final metaPaymentTxnId =
              t.metadata['paymentTransactionId']?.toString();
          if (metaPaymentTxnId != null &&
              paymentTransactionIds.contains(metaPaymentTxnId)) {
            return false;
          }
          return true;
        }).toList();

        // Hesap ekstresi toplamlarını hesapla (Ön Muhasebe Kuralları)
        double totalDebit = 0.0; // Borç hanesi
        double totalCredit = 0.0; // Alacak hanesi

        // Açılış bakiyesi
        if (customer.openingBalance != null && customer.openingBalance != 0) {
          if (customer.openingBalance! > 0) {
            // Pozitif açılış bakiyesi: Cari hesap firmaya borçlu (Alacak)
            totalCredit += customer.openingBalance!;
          } else {
            // Negatif açılış bakiyesi: Firma cari hesaba borçlu (Borç)
            totalDebit += customer.openingBalance!.abs();
          }
        }

        // Satışlardan alacak (Pozitif) - Proformalar hariç
        for (var invoice in invoices) {
          // Proformaları filtrele
          if (_isInvoiceType(invoice, 'proforma')) {
            continue;
          }
          final totalAmount =
              (invoice['totalAmount'] as num?)?.toDouble() ?? 0.0;
          // Satış: Alacak hanesine pozitif (Müşteri firmaya borçlanır)
          totalCredit += totalAmount;
        }

        // Payment transactions'dan (Ön Muhasebe Kuralları)
        for (var pt in paymentTransactions) {
          if (pt.direction == PaymentDirection.incoming) {
            // Gelen tahsilat: Müşteri borcunu azaltır → Borç hanesine pozitif
            totalDebit += pt.amount;
          } else {
            // Giden tahsilat: Firma borcunu azaltır → Alacak hanesine pozitif
            totalCredit += pt.amount;
          }
        }

        // Nakit işlemlerinden gelen tahsilatlar (customer'a bağlı olanlar)
        for (var cp in cashPayments) {
          totalDebit += cp.amount;
        }

        // Alışlardan borç (Pozitif)
        for (var purchase in purchasesList) {
          final totalAmount =
              (purchase['totalAmount'] as num?)?.toDouble() ?? 0.0;
          // Alış: Borç hanesine pozitif (Firma karşı tarafa borçlanır)
          totalDebit += totalAmount;
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
                                    CurrencyHelper.formatCurrency(
                                        totalCredit, currencyCode),
                                    Colors.green,
                                    isDark,
                                  ),
                                ),
                                Expanded(
                                  child: _buildSummaryItem(
                                    'Toplam Borç',
                                    CurrencyHelper.formatCurrency(
                                        totalDebit, currencyCode),
                                    Colors.red,
                                    isDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryItem(
                              'Net Bakiye',
                              CurrencyHelper.formatCurrency(
                                  netBalance, currencyCode),
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
    final purchasesAsync =
        ref.watch(purchases.customerPurchasesStreamProvider(customer.id));
    final paymentTransactionsAsync =
        ref.watch(customerPaymentTransactionsProvider(customer.id));
    final cashState = ref.watch(cashManagementNotifierProvider);

    return invoicesAsync.when(
      data: (invoices) {
        // Widget dispose edildiyse boş widget döndür
        if (!mounted) return const SizedBox.shrink();

        final paymentTransactions = paymentTransactionsAsync.maybeWhen(
          data: (value) => value,
          orElse: () => <PaymentTransaction>[],
        );

        final purchasesList = purchasesAsync.maybeWhen(
          data: (value) => value,
          orElse: () => <dynamic>[],
        );

        final paymentTransactionIds =
            paymentTransactions.map((pt) => pt.id).toSet();
        final cashPayments = cashState.cashTransactions.where((t) {
          final metaCustomerId =
              t.metadata['customerId']?.toString() ??
                  t.metadata['customer_id']?.toString();
          final relatedCustomer =
              t.relatedDocumentType == 'customer' ? t.relatedDocumentId : null;
          final isCustomerMatch =
              metaCustomerId == customer.id || relatedCustomer == customer.id;
          if (!isCustomerMatch) return false;

          final metaPaymentTxnId =
              t.metadata['paymentTransactionId']?.toString();
          if (metaPaymentTxnId != null &&
              paymentTransactionIds.contains(metaPaymentTxnId)) {
            return false;
          }
          return true;
        }).toList();

        final entries = <Map<String, dynamic>>[];

        // Açılış bakiyesi varsa ekle (en eski tarihli işlem olarak)
        if (customer.openingBalance != null && customer.openingBalance != 0) {
          final openingBalanceDate =
              customer.createdAt.subtract(const Duration(days: 1));
          entries.add({
            'type': 'opening_balance',
            'date': openingBalanceDate,
            'data': {
              'openingBalance': customer.openingBalance,
              'currency': _customerCurrencyCode(customer),
            },
          });
        }

        // Diğer işlemleri ekle (proformalar hariç)
        entries.addAll([
          ...invoices.where((i) => !_isInvoiceType(i, 'proforma')).map((i) {
                final invoiceDate = _parseDateTime(i['invoiceDate']) ??
                    _parseDateTime(i['saleDate']) ??
                    DateTime.fromMillisecondsSinceEpoch(0);
                return {
                  'type': 'invoice',
                  'date': invoiceDate,
                  'data': i,
                };
              }),
          ...paymentTransactions.map((pt) => {
                'type': 'payment_transaction',
                'date': pt.transactionDate,
                'data': pt,
              }),
          ...cashPayments.map((p) => {
                'type': 'payment',
                'date': p.transactionDate,
                'data': p,
              }),
          ...purchasesList.map((purchase) {
            final entryType =
                _isPurchaseType(purchase, PurchaseType.returnPurchase)
                    ? 'RETURN'
                    : 'PURCHASE';
            return {
              'type': entryType,
              'date': _parseDateTime(purchase['purchaseDate']) ??
                  DateTime.fromMillisecondsSinceEpoch(0),
              'data': purchase,
            };
          }),
        ]);

        // Tarih aralığı filtresi uygula
        if (_statementStartDate != null || _statementEndDate != null) {
          entries.removeWhere((entry) {
            final entryDate = entry['date'] as DateTime?;
            if (entryDate == null) return false;

            if (_statementStartDate != null &&
                entryDate.isBefore(_statementStartDate!)) {
              return true;
            }
            if (_statementEndDate != null &&
                entryDate
                    .isAfter(_statementEndDate!.add(const Duration(days: 1)))) {
              return true;
            }
            return false;
          });
        }

        // Ekstre sayacını hesapla (açılış bakiyesi dahil, proformalar hariç)
        final statementCount = entries.length;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_statementBadgeCount != statementCount) {
            setState(() {
              _statementBadgeCount = statementCount;
            });
          }
        });

        // Sıralama uygula
        _sortStatementEntries(entries);

        // Ekstreden son bakiyeyi hesapla ve müşteri bakiyesine yansıt
        double finalBalance = 0.0;
        for (var entry in entries) {
          final transaction = entry['data'];
          final isInvoice = entry['type'] == 'invoice';
          final isPaymentTransaction = entry['type'] == 'payment_transaction';
          final isCashPayment = entry['type'] == 'payment';
          final isPurchase = entry['type'] == 'PURCHASE';
          final isPurchaseReturn = entry['type'] == 'RETURN';
          final isOpeningBalance = entry['type'] == 'opening_balance';

          double debit = 0.0;
          double credit = 0.0;

          if (isOpeningBalance) {
            final openingBalance =
                (transaction['openingBalance'] as num?)?.toDouble() ?? 0.0;
            if (openingBalance > 0) {
              // Pozitif açılış bakiyesi: Müşteri bize borçlu (Alacak)
              credit = openingBalance;
            } else if (openingBalance < 0) {
              // Negatif açılış bakiyesi: Biz müşteriye borçlu (Borç)
              debit = openingBalance.abs();
            }
          } else if (isInvoice) {
            // Satış: Müşteri bize borçlu → Credit (Alacak)
            final totalAmount =
                (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
            credit = totalAmount;
          } else if (isPaymentTransaction) {
            // Payment Transaction (Ön Muhasebe Kuralları)
            if (transaction is PaymentTransaction) {
              if (transaction.direction == PaymentDirection.incoming) {
                debit = transaction.amount;
              } else {
                credit = transaction.amount;
              }
            } else {
              final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
              final direction = transaction['direction']?.toString() ?? '';
              if (direction == 'PaymentDirection.incoming' ||
                  direction == 'incoming') {
                debit = amount;
              } else {
                credit = amount;
              }
            }
          } else if (isCashPayment) {
            if (transaction is CashTransaction) {
              debit = transaction.amount;
            } else if (transaction is Map<String, dynamic>) {
              debit = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
            }
          } else if (isPurchase) {
            // Alış: Biz müşteriye borçlu → Debit (Borç)
            final totalAmount =
                (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
            debit = totalAmount;
          } else if (isPurchaseReturn) {
            // İade Alış: Biz müşteriye borçlu → Debit (Borç)
            final totalAmount =
                (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
            debit = totalAmount;
          } else {
            final typeStrRaw = transaction is Map<String, dynamic>
                ? transaction['type']?.toString() ?? ''
                : transaction is Transaction
                    ? transaction.type.toString()
                    : '';
            final typeStr = typeStrRaw.toLowerCase();
            final amount = transaction is Transaction
                ? transaction.amount
                : (transaction['amount'] as num?)?.toDouble() ?? 0.0;

            if (typeStr.contains('sale')) {
              credit = amount;
            } else if (typeStr.contains('purchase') ||
                typeStr.contains('return')) {
              debit = amount;
            } else if (typeStr.contains('payment') &&
                transaction is PaymentTransaction) {
              debit = amount;
            } else {
              credit = amount;
            }
          }

          finalBalance += credit - debit;
        }

        // Hesaplanan bakiyeyi müşteri entity'sine yansıt (sadece farklıysa)
        if ((finalBalance - customer.balance).abs() > 0.01) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              await ref.read(customerRepositoryProvider).updateCustomerBalance(
                    customer.id,
                    finalBalance,
                  );
              // Müşteri listesini yenile
              ref.invalidate(customersProvider);
            } catch (e) {
              debugPrint('Bakiye güncellenirken hata: $e');
            }
          });
        }

        // Gösterilecek işlemleri limitle
        final displayedEntries = entries.take(_transactionLimit).toList();
        final hasMore = entries.length > _transactionLimit;

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık, Filtreler ve Export butonu
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    const SizedBox(height: 16),
                    _buildStatementFilters(isDark),
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

  // Helper metodları
  void _sortStatementEntries(List<Map<String, dynamic>> entries) {
    entries.sort((a, b) {
      int comparison = 0;

      switch (_statementSortBy) {
        case 'date':
          final dateA = a['date'] as DateTime?;
          final dateB = b['date'] as DateTime?;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          comparison = dateA.compareTo(dateB);
          break;
        case 'amount':
          final amountA = _getEntryAmount(a);
          final amountB = _getEntryAmount(b);
          comparison = amountA.compareTo(amountB);
          break;
        case 'type':
          final typeA = a['type'] as String? ?? '';
          final typeB = b['type'] as String? ?? '';
          comparison = typeA.compareTo(typeB);
          break;
      }

      return _statementSortAscending ? comparison : -comparison;
    });
  }

  double _getEntryAmount(Map<String, dynamic> entry) {
    final transaction = entry['data'];
    final type = entry['type'] as String;

    if (type == 'opening_balance') {
      return ((transaction['openingBalance'] as num?)?.toDouble() ?? 0.0).abs();
    } else if (type == 'invoice') {
      return (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
    } else if (type == 'payment') {
      if (transaction is CashTransaction) {
        return transaction.amount;
      } else if (transaction is Map<String, dynamic>) {
        return (transaction['amount'] as num?)?.toDouble() ?? 0.0;
      }
    } else if (type == 'payment_transaction') {
      if (transaction is PaymentTransaction) {
        return transaction.amount;
      } else if (transaction is Map<String, dynamic>) {
        return (transaction['amount'] as num?)?.toDouble() ?? 0.0;
      }
    } else if (type == 'PURCHASE' || type == 'RETURN') {
      return (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
    }

    return 0.0;
  }

  Widget _buildStatementFilters(bool isDark) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tıklanabilir başlık
          InkWell(
            onTap: () {
              setState(() {
                _isStatementFiltersExpanded = !_isStatementFiltersExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 18,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtreler ve Sıralama',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Aktif filtre göstergesi
                  if (_statementStartDate != null ||
                      _statementEndDate != null ||
                      _statementSortBy != 'date' ||
                      !_statementSortAscending)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Aktif',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  Icon(
                    _isStatementFiltersExpanded
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
            child: _isStatementFiltersExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        // Tarih aralığı seçimi
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectStartDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _statementStartDate != null
                                              ? DateFormat('dd.MM.yyyy')
                                                  .format(_statementStartDate!)
                                              : 'Başlangıç Tarihi',
                                          style:
                                              GoogleFonts.poppins(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectEndDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _statementEndDate != null
                                              ? DateFormat('dd.MM.yyyy')
                                                  .format(_statementEndDate!)
                                              : 'Bitiş Tarihi',
                                          style:
                                              GoogleFonts.poppins(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _statementStartDate = null;
                                  _statementEndDate = null;
                                });
                              },
                              icon: const Icon(Icons.clear, size: 20),
                              tooltip: 'Tarihleri Temizle',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Sıralama seçenekleri
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _statementSortBy,
                                decoration: const InputDecoration(
                                  labelText: 'Sıralama',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'date',
                                      child: Text('Tarihe Göre')),
                                  DropdownMenuItem(
                                      value: 'amount',
                                      child: Text('Tutara Göre')),
                                  DropdownMenuItem(
                                      value: 'type',
                                      child: Text('İşlem Türüne Göre')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _statementSortBy = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _statementSortAscending =
                                      !_statementSortAscending;
                                });
                              },
                              icon: Icon(
                                _statementSortAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 20,
                              ),
                              tooltip: _statementSortAscending
                                  ? 'Artan Sıralama'
                                  : 'Azalan Sıralama',
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _statementStartDate ??
          DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != _statementStartDate) {
      setState(() {
        _statementStartDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _statementEndDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != _statementEndDate) {
      setState(() {
        _statementEndDate = picked;
      });
    }
  }

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

      final currencyCode = _customerCurrencyCode(customer);
      final currencySymbol = CurrencyHelper.getCurrencySymbol(currencyCode);

      for (var entry in entries) {
        final transaction = entry['data'];
        final date = entry['date'] as DateTime? ?? DateTime.now();
        final isInvoice = entry['type'] == 'invoice';
        final isPaymentTransaction = entry['type'] == 'payment_transaction';
        final isPurchase = entry['type'] == 'PURCHASE';
        final isPurchaseReturn = entry['type'] == 'RETURN';
        final isOpeningBalance = entry['type'] == 'opening_balance';

        String transactionName = '';
        String description = '';
        double debit = 0.0;
        double credit = 0.0;

        if (isOpeningBalance) {
          transactionName = 'Açılış Bakiyesi';
          description = 'Müşteri kayıt açılış bakiyesi';
          final openingBalance =
              (transaction['openingBalance'] as num?)?.toDouble() ?? 0.0;
          if (openingBalance > 0) {
            credit = openingBalance;
          } else if (openingBalance < 0) {
            debit = openingBalance.abs();
          }
        } else if (isInvoice) {
          // Satış: Müşteri satış yapıyor, müşteri alacaklı → Credit (Alacak)
          transactionName = 'Fatura';
          description = transaction['saleNumber'] ??
              transaction['invoiceNumber'] ??
              'N/A';
          final totalAmount =
              (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
          credit = totalAmount;
          // CashTransaction (payment) işleme kısmı kaldırıldı
        } else if (isPaymentTransaction) {
          PaymentTransactionType? ptType;
          String? ptDescription;
          String? ptTransactionNumber;
          double ptAmount = 0.0;
          PaymentDirection? ptDirection;

          if (transaction is PaymentTransaction) {
            ptType = transaction.type;
            ptDescription = transaction.description;
            ptTransactionNumber = transaction.transactionNumber;
            ptAmount = transaction.amount;
            ptDirection = transaction.direction;
          } else if (transaction is Map<String, dynamic>) {
            final typeStr = transaction['type']?.toString() ?? '';
            ptType = PaymentTransactionType.values.firstWhere(
              (e) => e.name == typeStr,
              orElse: () => PaymentTransactionType.cash,
            );
            ptDescription = transaction['description']?.toString();
            ptTransactionNumber = transaction['transactionNumber']?.toString();
            ptAmount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
            final directionStr = transaction['direction']?.toString() ?? '';
            ptDirection = PaymentDirection.values.firstWhere(
              (e) => e.name == directionStr,
              orElse: () => PaymentDirection.outgoing,
            );
          }

          if (ptType != null) {
            switch (ptType) {
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
          }
          description = '${ptTransactionNumber ?? ""} - ${ptDescription ?? ""}';
          final amount = ptAmount;
          if (ptDirection == PaymentDirection.incoming) {
            credit = amount;
          } else {
            debit = amount;
          }
        } else if (isPurchase) {
          // PURCHASE: Müşteri tedarikçiye ödeme yapıyor → Debit (Borç)
          transactionName = 'PURCHASE';
          if (transaction is Map<String, dynamic>) {
            description = transaction['purchaseNumber']?.toString() ??
                transaction['invoiceNumber']?.toString() ??
                'N/A';
            final totalAmount =
                (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
            debit = totalAmount;
          }
        } else if (isPurchaseReturn) {
          // RETURN: Müşteri iade alıyor → Debit (Borç)
          transactionName = 'RETURN';
          if (transaction is Map<String, dynamic>) {
            description = transaction['purchaseNumber']?.toString() ??
                transaction['invoiceNumber']?.toString() ??
                'N/A';
            final totalAmount =
                (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;
            debit = totalAmount;
          }
        } else {
          // Diğer işlemler (Transaction nesnesi)
          if (transaction is Transaction) {
            transactionName = _getTransactionTypeText(transaction.type);
            description = transaction.description ?? '';
            final amount = transaction.amount;
            // Transaction tipine göre borç/alacak
            if (transaction.type.toString().contains('sale')) {
              // Satış: Credit
              credit = amount;
            } else if (transaction.type.toString().contains('purchase')) {
              // Alış: Debit
              debit = amount;
            } else {
              credit = amount;
            }
          } else if (transaction is Map<String, dynamic>) {
            final typeStr = transaction['type']?.toString() ?? '';
            transactionName = _getTransactionTypeTextFromString(typeStr);
            description = transaction['description']?.toString() ?? '';
            final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
            // Transaction tipine göre borç/alacak
            if (typeStr.contains('sale')) {
              // Satış: Credit
              credit = amount;
            } else if (typeStr.contains('purchase')) {
              // Alış: Debit
              debit = amount;
            } else {
              credit = amount;
            }
          }
        }

        // Bakiye hesaplama (Ön Muhasebe: Borç - Alacak)
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
          final sign = amount < 0 ? '-' : '';
          return '$sign$formatted $currencySymbol';
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

      final currencyCode = _customerCurrencyCode(customer);
      final currencySymbol = CurrencyHelper.getCurrencySymbol(currencyCode);

      for (var entry in entries) {
        final transaction = entry['data'];
        final date = entry['date'] as DateTime? ?? DateTime.now();
        final isInvoice = entry['type'] == 'invoice';
        final isPaymentTransaction = entry['type'] == 'payment_transaction';
        final isOpeningBalance = entry['type'] == 'opening_balance';

        String transactionName = '';
        String description = '';
        double debit = 0.0;
        double credit = 0.0;

        if (isOpeningBalance) {
          transactionName = 'Açılış Bakiyesi';
          description = 'Müşteri kayıt açılış bakiyesi';
          final openingBalance =
              (transaction['openingBalance'] as num?)?.toDouble() ?? 0.0;
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
          // CashTransaction (payment) işleme kısmı kaldırıldı
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

        // Bakiye hesaplama (Ön Muhasebe: Borç - Alacak)
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
          final sign = amount < 0 ? '-' : '';
          return '$sign$formatted $currencySymbol';
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
        'Toplam Borç': CurrencyHelper.formatCurrency(totalDebit, currencyCode),
        'Toplam Alacak':
            CurrencyHelper.formatCurrency(totalCredit, currencyCode),
        'Net Bakiye': CurrencyHelper.formatCurrency(
            totalCredit - totalDebit, currencyCode),
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

  // ignore: unused_element
  Widget _removedBuildTransactionTile(dynamic t, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          'Ödeme',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('dd.MM.yyyy HH:mm')
              .format(_parseDateTime(t.transactionDate) ?? DateTime.now()),
        ),
        trailing: Text(
          _formatSignedCurrency(
            (t.amount is num ? (t.amount as num).toDouble() : 0.0).abs(),
            t.currency ?? 'TRY',
            _isCreditTransactionType(t.type),
          ),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ignore: unused_element
  void _removedShowCustomerTransactionDetail(Transaction transaction) {
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
              _buildDetailRow(
                'Tarih',
                DateFormat('dd.MM.yyyy HH:mm')
                    .format(transaction.transactionDate),
              ),
              _buildDetailRow('Tür', _getTransactionTypeText(transaction.type)),
              _buildDetailRow(
                'Tutar',
                _formatSignedCurrency(
                  transaction.amount,
                  transaction.currency,
                  _isCreditTransactionType(transaction.type),
                ),
              ),
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
        ],
      ),
    );
  }
}
