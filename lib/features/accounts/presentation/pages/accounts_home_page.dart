import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/account.dart';
import '../providers/account_providers.dart';
import '../widgets/account_card.dart';
import '../widgets/account_statistics_card.dart';
import '../../data/services/account_initialization_service.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../core/services/firebase/firebase_auth_service.dart';
import '../../../../core/theme/constants.dart';

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
  bool _sortAscending = true;

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

    return ResponsiveScaffold(
      appBar: const CustomAppBar(title: 'Hesaplar', showDrawer: true),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeaderSection(),
              _buildStatisticsSection(statisticsAsync),
              _buildFiltersSection(),
              _buildAccountsSection(accountsAsync),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: _buildFloatingActionButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: _buildWelcomeCard(
          []), // Boş liste, mobilde istatistikler ayrı gösterilecek
    );
  }

  /// Türkçe format ile para birimi formatla
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  Widget _buildWelcomeCard(List<Account> accounts) {
    final totalAccounts = accounts.length;
    final activeAccounts =
        accounts.where((a) => a.status == AccountStatus.active).length;
    final totalBalance = accounts.fold<double>(0, (sum, a) => sum + a.balance);
    final totalCredit =
        accounts.fold<double>(0, (sum, a) => sum + a.availableBalance);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TamgaciConstants.primaryColor,
            Color(0xFF4C6EF5),
            TamgaciConstants.primaryColorDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: TamgaciConstants.primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve açıklama
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hesaplarım',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hesap bilgilerini yönetin ve takip edin',
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Özet istatistikler - sadece masaüstünde göster
              if (MediaQuery.of(context).size.width > 768)
                Row(
                  children: [
                    _buildHeaderStatCard('Toplam', totalAccounts.toString()),
                    const SizedBox(width: 8),
                    _buildHeaderStatCard('Aktif', activeAccounts.toString()),
                    const SizedBox(width: 8),
                    _buildHeaderStatCard(
                        'Bakiye', _formatCurrency(totalBalance)),
                    const SizedBox(width: 8),
                    _buildHeaderStatCard('Kredi', _formatCurrency(totalCredit)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 8),
          Text(
            'Bugün: ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now())}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// Header içindeki istatistik kartı - banner timer gibi
  Widget _buildHeaderStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Masaüstünde tek satır, mobilde iki satır
            if (constraints.maxWidth > 768) {
              return Row(
                children: [
                  // Arama çubuğu
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Hesap ara...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tür filtresi
                  Expanded(
                    child: DropdownButtonFormField<AccountType?>(
                      initialValue: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Tür',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tümü')),
                        DropdownMenuItem(
                            value: AccountType.checking,
                            child: Text('Vadesiz')),
                        DropdownMenuItem(
                            value: AccountType.savings, child: Text('Vadeli')),
                        DropdownMenuItem(
                            value: AccountType.credit, child: Text('Kredi')),
                        DropdownMenuItem(
                            value: AccountType.investment,
                            child: Text('Yatırım')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Durum filtresi
                  Expanded(
                    child: DropdownButtonFormField<AccountStatus?>(
                      initialValue: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Durum',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tümü')),
                        DropdownMenuItem(
                            value: AccountStatus.active, child: Text('Aktif')),
                        DropdownMenuItem(
                            value: AccountStatus.inactive,
                            child: Text('Pasif')),
                        DropdownMenuItem(
                            value: AccountStatus.suspended,
                            child: Text('Askıya Alınmış')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Para birimi filtresi
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: _selectedCurrency,
                      decoration: InputDecoration(
                        labelText: 'Para Birimi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tümü')),
                        DropdownMenuItem(value: 'TRY', child: Text('TRY')),
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                        DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sıralama yönü
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                    },
                    icon: Icon(
                      _sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                    ),
                    tooltip: _sortAscending ? 'Artan' : 'Azalan',
                  ),
                  const SizedBox(width: 8),
                  // Excel, CSV, PDF, Import butonları
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Excel Export
                      IconButton(
                        onPressed: _exportToExcel,
                        icon: const Icon(Icons.table_chart),
                        tooltip: 'Excel\'e Aktar',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green.withValues(alpha: 0.1),
                          foregroundColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // CSV Export
                      IconButton(
                        onPressed: _exportToCSV,
                        icon: const Icon(Icons.description),
                        tooltip: 'CSV\'ye Aktar',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // PDF Export
                      IconButton(
                        onPressed: _exportToPDF,
                        icon: const Icon(Icons.picture_as_pdf),
                        tooltip: 'PDF\'ye Aktar',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          foregroundColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Import
                      IconButton(
                        onPressed: _showImportDialog,
                        icon: const Icon(Icons.upload_file),
                        tooltip: 'Dosya İçe Aktar',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.orange.withValues(alpha: 0.1),
                          foregroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              // Mobile - iki satır
              return Column(
                children: [
                  // Arama çubuğu - tam genişlik
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Hesap ara...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filtreler - iki satır
                  Row(
                    children: [
                      // İlk satır: Tür ve Durum
                      Expanded(
                        child: DropdownButtonFormField<AccountType?>(
                          initialValue: _selectedType,
                          decoration: InputDecoration(
                            labelText: 'Tür',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Tümü')),
                            DropdownMenuItem(
                                value: AccountType.checking,
                                child: Text('Vadesiz')),
                            DropdownMenuItem(
                                value: AccountType.savings,
                                child: Text('Vadeli')),
                            DropdownMenuItem(
                                value: AccountType.credit,
                                child: Text('Kredi')),
                            DropdownMenuItem(
                                value: AccountType.investment,
                                child: Text('Yatırım')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<AccountStatus?>(
                          initialValue: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Durum',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Tümü')),
                            DropdownMenuItem(
                                value: AccountStatus.active,
                                child: Text('Aktif')),
                            DropdownMenuItem(
                                value: AccountStatus.inactive,
                                child: Text('Pasif')),
                            DropdownMenuItem(
                                value: AccountStatus.suspended,
                                child: Text('Askıya Alınmış')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // İkinci satır: Para Birimi ve Export/Import
                  Row(
                    children: [
                      // Para birimi filtresi
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _selectedCurrency,
                          decoration: InputDecoration(
                            labelText: 'Para Birimi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Tümü')),
                            DropdownMenuItem(value: 'TRY', child: Text('TRY')),
                            DropdownMenuItem(value: 'USD', child: Text('USD')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                            DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCurrency = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sıralama yönü
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _sortAscending = !_sortAscending;
                          });
                        },
                        icon: Icon(
                          _sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        ),
                        tooltip: _sortAscending ? 'Artan' : 'Azalan',
                      ),
                      const SizedBox(width: 8),
                      // Excel, CSV, PDF, Import butonları
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Excel Export
                          IconButton(
                            onPressed: _exportToExcel,
                            icon: const Icon(Icons.table_chart),
                            tooltip: 'Excel\'e Aktar',
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.green.withValues(alpha: 0.1),
                              foregroundColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // CSV Export
                          IconButton(
                            onPressed: _exportToCSV,
                            icon: const Icon(Icons.description),
                            tooltip: 'CSV\'ye Aktar',
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.blue.withValues(alpha: 0.1),
                              foregroundColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // PDF Export
                          IconButton(
                            onPressed: _exportToPDF,
                            icon: const Icon(Icons.picture_as_pdf),
                            tooltip: 'PDF\'ye Aktar',
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.red.withValues(alpha: 0.1),
                              foregroundColor: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Import
                          IconButton(
                            onPressed: _showImportDialog,
                            icon: const Icon(Icons.upload_file),
                            tooltip: 'Dosya İçe Aktar',
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.orange.withValues(alpha: 0.1),
                              foregroundColor: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }
          },
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

  void _navigateToCreateAccount() {
    context.goNamed('create-account');
  }

  void _exportToExcel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excel\'e Aktar'),
        content: const Text('Excel dosyası oluşturuluyor...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _exportToCSV() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CSV\'ye Aktar'),
        content: const Text('CSV dosyası oluşturuluyor...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _exportToPDF() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF\'ye Aktar'),
        content: const Text('PDF dosyası oluşturuluyor...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dosya İçe Aktar'),
        content: const Text('Dosya seçin ve içe aktarın...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _navigateToAccountDetail(Account account) {
    context.goNamed('account-detail', pathParameters: {'id': account.id});
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
