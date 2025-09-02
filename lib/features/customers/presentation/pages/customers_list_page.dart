// ========== lib/features/customers/presentation/pages/customers_list_page.dart ==========

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/providers/currency_providers.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../data/models/customer_entity.dart';
import '../providers/customer_providers.dart';
import '../../domain/entities/customer.dart';

/// Müşteri listesi sayfası
class CustomersListPage extends ConsumerStatefulWidget {
  const CustomersListPage({super.key});

  @override
  ConsumerState<CustomersListPage> createState() => _CustomersListPageState();
}

class _CustomersListPageState extends ConsumerState<CustomersListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadCustomers();
  }

  void _loadCustomers() {
    // Müşteriler zaten provider'da yüklü olmalı
    // Eğer yüklü değilse yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final operationsState = ref.read(customerOperationsProvider);
      if (operationsState.customers.isEmpty && !operationsState.isLoading) {
        ref.read(customerOperationsProvider.notifier).loadCustomers();
      }
    });
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _navigateToDetail(String customerId) {
    Navigator.of(context).pushNamed('/customers/detail', arguments: customerId);
  }

  void _navigateToCreate() {
    Navigator.of(context).pushNamed('/customers/create');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);
    final searchQuery = _searchController.text;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Müşteriler',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _navigateToCreate,
            icon: const Icon(Icons.add),
            tooltip: 'Yeni Müşteri',
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          // Arama çubuğu
          Container(
            padding: TamgaciConstants.paddingMedium(context),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Müşteri ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                ),
              ),
            ),
          ),

          // Müşteri listesi
          Expanded(child: _buildCustomersList(customersAsync, searchQuery)),
        ],
      ),
    );
  }

  /// Müşteri listesini oluşturur
  Widget _buildCustomersList(
    AsyncValue<List<Customer>> customersAsync,
    String searchQuery,
  ) {
    return customersAsync.when(
      data: (customers) => _buildCustomersListView(customers, searchQuery),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hata: $error'),
            ElevatedButton(
              onPressed: _loadCustomers,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  /// Müşteri listesi view'ını oluşturur
  Widget _buildCustomersListView(List<Customer> customers, String searchQuery) {
    // Arama filtresi uygula
    List<Customer> filteredCustomers = customers;
    if (searchQuery.isNotEmpty) {
      filteredCustomers = customers.where((customer) {
        return customer.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
            (customer.email?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ==
                true) ||
            (customer.phone?.contains(searchQuery) == true);
      }).toList();
    }

    if (filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 80,
              color: TamgaciConstants.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? '"$searchQuery" için sonuç bulunamadı'
                  : 'Henüz müşteri eklenmemiş',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _navigateToCreate,
              icon: const Icon(Icons.person_add),
              label: const Text('Yeni Müşteri Ekle'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(customersStreamProvider);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredCustomers.length,
        itemBuilder: (context, index) {
          final customer = filteredCustomers[index];
          return _buildCustomerCard(customer);
        },
      ),
    );
  }

  /// Müşteri kartı oluşturur
  Widget _buildCustomerCard(Customer customer) {
    final isActive = customer.isActive;
    final isCompany = customer.customerType == CustomerType.company;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(customer.id),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: TamgaciConstants.cardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım - Müşteri adı ve durum
              Row(
                children: [
                  // Müşteri ikonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isActive
                          ? TamgaciConstants.successColor.withValues(alpha: 0.1)
                          : TamgaciConstants.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        TamgaciConstants.radiusSM,
                      ),
                    ),
                    child: Icon(
                      isCompany ? Icons.business : Icons.person,
                      color: isActive
                          ? TamgaciConstants.successColor
                          : TamgaciConstants.errorColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Müşteri bilgileri
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          customer.customerType.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: TamgaciConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceSM),

                  // Durum
                  _buildStatusChip(isActive),
                ],
              ),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // İletişim bilgileri
              if (customer.email != null && customer.email!.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.email,
                      size: 16,
                      color: TamgaciConstants.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        customer.email!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: TamgaciConstants.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              if (customer.phone != null && customer.phone!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 16,
                      color: TamgaciConstants.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      customer.phone!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: TamgaciConstants.spaceMD),

              // Bakiye bilgisi
              _buildBalanceInfo(customer),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // Alt kısım - Adres ve tarih bilgileri
              Row(
                children: [
                  // Şehir
                  Expanded(
                    child: _buildInfoItem(
                      label: 'Şehir',
                      value: customer.city ?? 'Belirtilmemiş',
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Kayıt tarihi
                  Expanded(
                    child: _buildInfoItem(
                      label: 'Kayıt Tarihi',
                      value: DateFormat(
                        'dd.MM.yy',
                        'tr_TR',
                      ).format(customer.createdAt),
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Durum chip'i oluşturur
  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? TamgaciConstants.successColor.withValues(alpha: 0.1)
            : TamgaciConstants.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Pasif',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isActive
              ? TamgaciConstants.successColor
              : TamgaciConstants.errorColor,
        ),
      ),
    );
  }

  /// Bakiye bilgisi widget'ı oluşturur
  Widget _buildBalanceInfo(Customer customer) {
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final exchangeRatesAsync = ref.watch(exchangeRatesProvider);

    return Container(
      padding: const EdgeInsets.all(TamgaciConstants.spaceSM),
      decoration: BoxDecoration(
        color: customer.hasPositiveBalance
            ? TamgaciConstants.successColor.withValues(alpha: 0.1)
            : customer.hasNegativeBalance
                ? TamgaciConstants.errorColor.withValues(alpha: 0.1)
                : TamgaciConstants.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        border: Border.all(
          color: customer.hasPositiveBalance
              ? TamgaciConstants.successColor.withValues(alpha: 0.3)
              : customer.hasNegativeBalance
                  ? TamgaciConstants.errorColor.withValues(alpha: 0.3)
                  : TamgaciConstants.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            customer.hasPositiveBalance
                ? Icons.account_balance_wallet
                : customer.hasNegativeBalance
                    ? Icons.money_off
                    : Icons.account_balance,
            size: 16,
            color: customer.hasPositiveBalance
                ? TamgaciConstants.successColor
                : customer.hasNegativeBalance
                    ? TamgaciConstants.errorColor
                    : TamgaciConstants.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bakiye',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: TamgaciConstants.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      customer.formattedBalance,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: customer.hasPositiveBalance
                            ? TamgaciConstants.successColor
                            : customer.hasNegativeBalance
                                ? TamgaciConstants.errorColor
                                : TamgaciConstants.textSecondary,
                      ),
                    ),
                    // Varsayılan para birimi gösterimi
                    if (customer.balanceCurrency != selectedCurrency.code)
                      exchangeRatesAsync.when(
                        data: (exchangeRates) {
                          final convertedAmount = CurrencyHelper.convertCurrency(
                            amount: customer.balance,
                            fromCurrencyCode: customer.balanceCurrency,
                            toCurrencyCode: selectedCurrency.code,
                            exchangeRates: exchangeRates,
                          );
                          return Text(
                            ' (${convertedAmount.toStringAsFixed(2)} ${selectedCurrency.symbol})',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: TamgaciConstants.textSecondary,
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bilgi öğesi widget'ı oluşturur
  Widget _buildInfoItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: TamgaciConstants.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
