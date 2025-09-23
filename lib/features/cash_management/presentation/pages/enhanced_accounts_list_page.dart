// ========== ENHANCED ACCOUNTS LIST PAGE ==========
// lib/features/cash_management/presentation/pages/enhanced_accounts_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/account.dart';

/// Gelişmiş hesaplar listesi sayfası
class EnhancedAccountsListPage extends ConsumerStatefulWidget {
  const EnhancedAccountsListPage({super.key});

  @override
  ConsumerState<EnhancedAccountsListPage> createState() =>
      _EnhancedAccountsListPageState();
}

class _EnhancedAccountsListPageState
    extends ConsumerState<EnhancedAccountsListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedType = 'Tümü';
  String _selectedStatus = 'Tümü';
  String _sortBy = 'name';
  String _selectedCurrency = 'Tümü';

  final List<String> _types = [
    'Tümü',
    'Nakit',
    'Banka',
    'Kredi',
    'Yatırım',
    'Diğer'
  ];
  final List<String> _statuses = [
    'Tümü',
    'Aktif',
    'Pasif',
    'Kapalı',
    'Askıya Alınmış'
  ];
  final List<String> _sortOptions = ['name', 'balance', 'type', 'createdAt'];
  final List<String> _currencies = ['Tümü', 'TRY', 'USD', 'EUR', 'GBP'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _navigateToCreate() {
    Navigator.of(context).pushNamed('/accounts/create');
  }

  void _navigateToDetail(String accountId) {
    Navigator.of(context).pushNamed('/accounts/detail', arguments: accountId);
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text;
    final accounts = _getMockAccounts();

    Theme.of(context);

    return ResponsiveScaffold(
      appBar: CustomAppBar(
        title: 'Hesaplarım',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _showExportDialog,
            icon: const Icon(Icons.download),
          ),
          IconButton(
            onPressed: _navigateToCreate,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: Column(
        children: [
          // Arama ve filtre çubuğu
          _buildSearchAndFilterBar(),

          // İstatistik kartları
          _buildStatsCards(accounts),

          // Hesaplar listesi
          Expanded(child: _buildAccountsList(accounts, searchQuery)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        children: [
          // Arama çubuğu
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Hesap ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Filtre çipleri
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tür', _selectedType, _types, (value) {
                  setState(() {
                    _selectedType = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Durum', _selectedStatus, _statuses, (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Para Birimi', _selectedCurrency, _currencies,
                    (value) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Sırala', _getSortDisplayName(_sortBy),
                    _sortOptions.map(_getSortDisplayName).toList(), (value) {
                  setState(() {
                    _sortBy = _getSortKeyFromDisplayName(value);
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String selectedValue,
      List<String> options, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selectedValue == options.first
            ? AppColors.primary
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: selectedValue == options.first
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  String _getSortDisplayName(String key) {
    switch (key) {
      case 'name':
        return 'İsim';
      case 'balance':
        return 'Bakiye';
      case 'type':
        return 'Tür';
      case 'createdAt':
        return 'Oluşturma';
      default:
        return 'İsim';
    }
  }

  String _getSortKeyFromDisplayName(String displayName) {
    switch (displayName) {
      case 'İsim':
        return 'name';
      case 'Bakiye':
        return 'balance';
      case 'Tür':
        return 'type';
      case 'Oluşturma':
        return 'createdAt';
      default:
        return 'name';
    }
  }

  Widget _buildStatsCards(List<Account> accounts) {
    final totalAccounts = accounts.length;
    final totalBalance = accounts.fold<double>(
        0, (sum, account) => sum + account.currentBalance);
    final activeAccounts =
        accounts.where((a) => a.status == AccountStatus.active).length;
    final negativeBalance = accounts.where((a) => a.currentBalance < 0).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Toplam Hesap',
              totalAccounts.toString(),
              Icons.account_balance,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Toplam Bakiye',
              CurrencyHelper.formatCurrency(totalBalance, 'TRY'),
              Icons.attach_money,
              AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Aktif Hesap',
              activeAccounts.toString(),
              Icons.check_circle,
              AppColors.info,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Negatif Bakiye',
              negativeBalance.toString(),
              Icons.warning,
              AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
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
      ),
    );
  }

  Widget _buildAccountsList(List<Account> accounts, String searchQuery) {
    List<Account> filteredAccounts = _applyFilters(accounts, searchQuery);

    if (filteredAccounts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.account_balance_outlined,
        title: 'Hesap Bulunamadı',
        message: searchQuery.isNotEmpty ||
                _selectedType != 'Tümü' ||
                _selectedStatus != 'Tümü' ||
                _selectedCurrency != 'Tümü'
            ? 'Arama kriterlerinize uygun hesap bulunamadı.'
            : 'Henüz hesap kaydı bulunmuyor.\nYeni hesap eklemek için + butonuna tıklayın.',
        actionButton: searchQuery.isEmpty &&
                _selectedType == 'Tümü' &&
                _selectedStatus == 'Tümü' &&
                _selectedCurrency == 'Tümü'
            ? ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add),
                label: const Text('Hesap Ekle'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Hesap listesini yenile
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredAccounts.length,
        itemBuilder: (context, index) {
          final account = filteredAccounts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAccountCard(account),
          );
        },
      ),
    );
  }

  List<Account> _applyFilters(List<Account> accounts, String searchQuery) {
    List<Account> filtered = List.from(accounts);

    // Arama filtresi
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((account) {
        return account.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (account.description
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (account.bankName
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (account.accountNumber
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Tür filtresi
    if (_selectedType != 'Tümü') {
      filtered = filtered
          .where((account) => account.type.displayName == _selectedType)
          .toList();
    }

    // Durum filtresi
    if (_selectedStatus != 'Tümü') {
      filtered = filtered
          .where((account) => account.status.displayName == _selectedStatus)
          .toList();
    }

    // Para birimi filtresi
    if (_selectedCurrency != 'Tümü') {
      filtered = filtered
          .where((account) => account.currency == _selectedCurrency)
          .toList();
    }

    // Sıralama
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'balance':
          return b.currentBalance.compareTo(a.currentBalance);
        case 'type':
          return a.type.displayName.compareTo(b.type.displayName);
        case 'createdAt':
          return b.createdAt.compareTo(a.createdAt);
        default:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  Widget _buildAccountCard(Account account) {
    final statusColor = _getStatusColor(account.status);
    final balanceColor = _getBalanceColor(account.currentBalance);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(account.id),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: TamgaciConstants.cardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım - Hesap adı ve durum
              Row(
                children: [
                  // Hesap türü ikonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(TamgaciConstants.radiusSM),
                    ),
                    child: Icon(
                      _getAccountTypeIcon(account.type),
                      color: statusColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Hesap bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                account.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                account.type.displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (account.bankName != null)
                          Text(
                            account.bankName!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primary,
                            ),
                          ),
                        if (account.accountNumber != null)
                          Text(
                            'Hesap: ${account.accountNumber}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceSM),

                  // Durum
                  _buildStatusChip(account.status, statusColor),
                ],
              ),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // Alt kısım - Bakiye ve kredi bilgileri
              Row(
                children: [
                  // Mevcut bakiye
                  Expanded(
                    child: _buildInfoCard(
                      label: 'Mevcut Bakiye',
                      value: CurrencyHelper.formatCurrency(
                          account.currentBalance, account.currency),
                      color: balanceColor,
                      icon: Icons.account_balance_wallet,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Kredi limiti
                  if (account.hasCreditLimit)
                    Expanded(
                      child: _buildInfoCard(
                        label: 'Kredi Limiti',
                        value: CurrencyHelper.formatCurrency(
                            account.creditLimit!, account.currency),
                        color: AppColors.info,
                        icon: Icons.credit_card,
                      ),
                    ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Kullanım oranı
                  if (account.hasCreditLimit)
                    Expanded(
                      child: _buildInfoCard(
                        label: 'Kullanım Oranı',
                        value:
                            '${(account.creditUtilization * 100).toStringAsFixed(1)}%',
                        color: account.isOverCreditLimit
                            ? AppColors.error
                            : AppColors.warning,
                        icon: Icons.pie_chart,
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

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.account_balance_wallet;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.credit:
        return Icons.credit_card;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.other:
        return Icons.category;
    }
  }

  Color _getStatusColor(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return AppColors.success;
      case AccountStatus.inactive:
        return AppColors.warning;
      case AccountStatus.closed:
        return AppColors.error;
      case AccountStatus.suspended:
        return AppColors.textSecondary;
    }
  }

  Color _getBalanceColor(double balance) {
    if (balance > 0) return AppColors.success;
    if (balance < 0) return AppColors.error;
    return AppColors.textSecondary;
  }

  Widget _buildStatusChip(AccountStatus status, Color color) {
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

  Widget _buildInfoCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 8,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Account> _getMockAccounts() {
    return [
      Account(
        id: '1',
        name: 'Ana Nakit Kasa',
        description: 'Günlük nakit işlemler için ana kasa',
        type: AccountType.cash,
        status: AccountStatus.active,
        currentBalance: 15000.0,
        currency: 'TRY',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Account(
        id: '2',
        name: 'İş Bankası TRY Hesabı',
        description: 'Ana işletme hesabı',
        type: AccountType.bank,
        status: AccountStatus.active,
        bankName: 'Türkiye İş Bankası',
        accountNumber: '1234567890',
        iban: 'TR1234567890123456789012345',
        currentBalance: 250000.0,
        currency: 'TRY',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
      Account(
        id: '3',
        name: 'Kredi Kartı',
        description: 'İş kredi kartı',
        type: AccountType.credit,
        status: AccountStatus.active,
        currentBalance: -5000.0,
        currency: 'TRY',
        creditLimit: 50000.0,
        interestRate: 1.5,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
      ),
      Account(
        id: '4',
        name: 'USD Döviz Hesabı',
        description: 'Döviz işlemleri için',
        type: AccountType.bank,
        status: AccountStatus.active,
        bankName: 'Garanti BBVA',
        accountNumber: '9876543210',
        currentBalance: 10000.0,
        currency: 'USD',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gelişmiş Filtreler'),
        content: const Text('Gelişmiş filtre özellikleri yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dışa Aktar'),
        content:
            const Text('Excel/PDF dışa aktarım özellikleri yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
