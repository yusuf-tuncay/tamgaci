import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/account.dart';
import '../providers/account_providers.dart';
import '../widgets/account_card.dart';
import '../widgets/account_statistics_card.dart';
import '../../data/services/account_initialization_service.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../core/services/firebase/firebase_auth_service.dart';
import 'create_account_page.dart';
import 'account_detail_page.dart';

/// Hesaplar Ana Sayfası - Premium Tasarım
class AccountsHomePage extends ConsumerStatefulWidget {
  const AccountsHomePage({super.key});

  @override
  ConsumerState<AccountsHomePage> createState() => _AccountsHomePageState();
}

class _AccountsHomePageState extends ConsumerState<AccountsHomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _searchQuery = '';
  AccountType? _selectedType;
  AccountStatus? _selectedStatus;
  String? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // TenantId oluştur (eğer yoksa) ve varsayılan hesapları oluştur
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FirebaseAuthService.createTenantIdForCurrentUser();
      _initializeDefaultAccounts();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final statisticsAsync = ref.watch(accountStatisticsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const Drawer(
        width: 280,
        child: TamgaciDrawerMenu(),
      ),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildHeaderSection(),
          _buildStatisticsSection(statisticsAsync),
          _buildFiltersSection(),
          _buildAccountsSection(accountsAsync),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 1,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87, size: 24),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      flexibleSpace: Container(
        color: Colors.white,
        child: const SafeArea(
          child: SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1), // Indigo-500
              Color(0xFF8B5CF6), // Violet-500
              Color(0xFF7C3AED), // Violet-600
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.25),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hesaplarım',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tüm banka hesaplarınızı yönetin',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
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

  Widget _buildStatisticsSection(
      AsyncValue<Map<String, dynamic>> statisticsAsync) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: statisticsAsync.when(
                data: (stats) => AccountStatisticsCard(statistics: stats),
                loading: () => _buildStatisticsLoading(),
                error: (error, stack) => _buildStatisticsError(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsLoading() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
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
  }

  Widget _buildStatisticsError() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400]),
          const SizedBox(width: 12),
          Text(
            'İstatistikler yüklenemedi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtreler',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSearchField(),
                ),
                const SizedBox(width: 12),
                _buildFilterChip(
                  'Tür',
                  _selectedType?.displayName ?? 'Tümü',
                  () => _showTypeFilter(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Durum',
                  _selectedStatus?.displayName ?? 'Tümü',
                  () => _showStatusFilter(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Para Birimi',
                  _selectedCurrency ?? 'Tümü',
                  () => _showCurrencyFilter(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Hesap ara...',
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[400]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsSection(AsyncValue<List<Account>> accountsAsync) {
    return SliverToBoxAdapter(
      child: accountsAsync.when(
        data: (accounts) {
          final filteredAccounts = _filterAccounts(accounts);

          if (filteredAccounts.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hesaplar (${filteredAccounts.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _refreshAccounts(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(
                        'Yenile',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              ...filteredAccounts.map(
                (account) => AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: AccountCard(
                          account: account,
                          onTap: () => _navigateToAccountDetail(account),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 100), // FAB için boşluk
            ],
          );
        },
        loading: () => _buildAccountsLoading(),
        error: (error, stack) => _buildAccountsError(),
      ),
    );
  }

  List<Account> _filterAccounts(List<Account> accounts) {
    return accounts.where((account) {
      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!account.name.toLowerCase().contains(query) &&
            !account.accountNumber.toLowerCase().contains(query) &&
            !account.bankName.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Tür filtresi
      if (_selectedType != null && account.type != _selectedType) {
        return false;
      }

      // Durum filtresi
      if (_selectedStatus != null && account.status != _selectedStatus) {
        return false;
      }

      // Para birimi filtresi
      if (_selectedCurrency != null && account.currency != _selectedCurrency) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz hesap eklenmemiş',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk hesabınızı ekleyerek başlayın',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateAccount(),
            icon: const Icon(Icons.add),
            label: Text(
              'Hesap Ekle',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsLoading() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 120,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
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
      ),
    );
  }

  Widget _buildAccountsError() {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Hesaplar yüklenemedi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen tekrar deneyin',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.red[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _refreshAccounts(),
            icon: const Icon(Icons.refresh),
            label: Text(
              'Tekrar Dene',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToCreateAccount(),
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: Text(
        'Hesap Ekle',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showTypeFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildTypeFilterSheet(),
    );
  }

  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildStatusFilterSheet(),
    );
  }

  void _showCurrencyFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildCurrencyFilterSheet(),
    );
  }

  Widget _buildTypeFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hesap Türü Seçin',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...AccountType.values.map(
            (type) => ListTile(
              leading: Text(type.icon, style: const TextStyle(fontSize: 24)),
              title: Text(type.displayName),
              onTap: () {
                setState(() {
                  _selectedType = type;
                });
                Navigator.pop(context);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.clear),
            title: const Text('Tümü'),
            onTap: () {
              setState(() {
                _selectedType = null;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hesap Durumu Seçin',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...AccountStatus.values.map(
            (status) => ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(status.displayName),
              onTap: () {
                setState(() {
                  _selectedStatus = status;
                });
                Navigator.pop(context);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.clear),
            title: const Text('Tümü'),
            onTap: () {
              setState(() {
                _selectedStatus = null;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyFilterSheet() {
    final currencies = ['TRY', 'USD', 'EUR', 'GBP'];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Para Birimi Seçin',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...currencies.map(
            (currency) => ListTile(
              leading: Text(currency,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              title: Text(currency),
              onTap: () {
                setState(() {
                  _selectedCurrency = currency;
                });
                Navigator.pop(context);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.clear),
            title: const Text('Tümü'),
            onTap: () {
              setState(() {
                _selectedCurrency = null;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return Colors.green;
      case AccountStatus.inactive:
        return Colors.orange;
      case AccountStatus.blocked:
        return Colors.red;
      case AccountStatus.closed:
        return Colors.grey;
      case AccountStatus.suspended:
        return Colors.yellow;
    }
  }

  void _navigateToCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateAccountPage(),
      ),
    );
  }

  void _navigateToAccountDetail(Account account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountDetailPage(account: account),
      ),
    );
  }

  /// Varsayılan hesapları oluştur
  Future<void> _initializeDefaultAccounts() async {
    try {
      final service = AccountInitializationService();
      await service.initializeDefaultAccounts();
    } catch (e) {
      // Hata durumunda sessizce devam et
      debugPrint('Varsayılan hesaplar oluşturulamadı: $e');
    }
  }

  void _refreshAccounts() {
    ref.read(accountNotifierProvider.notifier).refresh();
    ref.invalidate(accountStatisticsProvider);
  }

}
