// ========== lib/features/dashboard/presentation/pages/dashboard_page.dart ==========

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/routes/routes.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../providers/dashboard_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../data/services/stock_market_service.dart';
import '../../data/services/date_time_service.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';

/// Tamgaci Ana Dashboard Sayfası
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);
    final recentTransactionsAsync = ref.watch(recentTransactionsProvider);
    final monthlyChartDataAsync = ref.watch(monthlyChartDataProvider);
    final unreadNotificationsAsync = ref.watch(
      unreadNotificationsCountProvider,
    );
    final currentDateTimeAsync = ref.watch(currentDateTimeProvider);
    final stockMarketDataAsync = ref.watch(stockMarketDataProvider);
    final userName = ref.watch(userNameProvider);

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        elevation: 0,
        backgroundColor: TamgaciConstants.appBarColor,
        foregroundColor: TamgaciConstants.textPrimary,
        actions: [
          // Bildirimler
          IconButton(
            onPressed: () {
              TamgaciRoutes.pushNamed(context, TamgaciRoutes.notifications);
            },
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                unreadNotificationsAsync.when(
                  data: (count) => count > 0
                      ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: TamgaciConstants.errorColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                count > 9 ? '9+' : count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Dashboard verilerini yenile
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(recentTransactionsProvider);
          ref.invalidate(monthlyChartDataProvider);
          ref.invalidate(stockMarketDataProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: TamgaciConstants.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hoş geldin mesajı ve borsa verileri
              _buildWelcomeAndMarketSection(
                  currentDateTimeAsync, userName, stockMarketDataAsync),

              const SizedBox(height: TamgaciConstants.spaceLG),

              // Özet kartları ve hızlı istatistikler
              dashboardSummaryAsync.when(
                data: (summary) => Column(
                  children: [
                    _buildSummaryCards(context, summary),
                    const SizedBox(height: TamgaciConstants.spaceLG),
                    _buildQuickStats(context, summary),
                  ],
                ),
                loading: () => Column(
                  children: [
                    _buildSummaryCardsLoading(),
                    const SizedBox(height: TamgaciConstants.spaceLG),
                    _buildQuickStatsLoading(context),
                  ],
                ),
                error: (error, stack) => Column(
                  children: [
                    _buildSummaryCardsError(error),
                    const SizedBox(height: TamgaciConstants.spaceLG),
                    _buildQuickStatsError(error),
                  ],
                ),
              ),

              const SizedBox(height: TamgaciConstants.spaceLG),

              // Hızlı işlemler
              _buildQuickActions(context),

              const SizedBox(height: TamgaciConstants.spaceLG),

              // Aylık grafik
              monthlyChartDataAsync.when(
                data: (chartData) => _buildMonthlyChart(chartData),
                loading: () => _buildChartLoading(),
                error: (error, stack) => _buildChartError(error),
              ),

              const SizedBox(height: TamgaciConstants.spaceLG),

              // Son işlemler
              recentTransactionsAsync.when(
                data: (transactions) =>
                    _buildRecentTransactions(context, transactions),
                loading: () => _buildTransactionsLoading(),
                error: (error, stack) => _buildTransactionsError(error),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickActionMenu(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Hoş geldin ve borsa verileri bölümü
  Widget _buildWelcomeAndMarketSection(
    AsyncValue<DateTime> currentDateTimeAsync,
    String userName,
    AsyncValue<StockMarketData> stockMarketDataAsync,
  ) {
    return _buildCombinedWelcomeMarketCard(
      currentDateTimeAsync,
      userName,
      stockMarketDataAsync,
    );
  }

  /// Birleştirilmiş hoş geldin ve piyasa verileri kartı
  Widget _buildCombinedWelcomeMarketCard(
    AsyncValue<DateTime> currentDateTimeAsync,
    String userName,
    AsyncValue<StockMarketData> stockMarketDataAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TamgaciConstants.primaryColor, TamgaciConstants.primaryDark],
        ),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusLG),
      ),
      child: Column(
        children: [
          // Üst kısım: Hoş geldin ve tarih
          Row(
            children: [
              // Sol taraf: Hoş geldin ve tarih
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoş Geldiniz,',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: TamgaciConstants.textOnPrimary
                            .withValues(alpha: 0.9),
                      ),
                    ),
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: TamgaciConstants.textOnPrimary,
                      ),
                    ),
                    const SizedBox(height: TamgaciConstants.spaceSM),
                    currentDateTimeAsync.when(
                      data: (dateTime) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${DateTimeService.getDayName(dateTime)}, ${dateTime.day} ${DateTimeService.getMonthName(dateTime)} ${dateTime.year}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: TamgaciConstants.textOnPrimary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                          Text(
                            DateTimeService.formatTime(dateTime),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: TamgaciConstants.textOnPrimary,
                            ),
                          ),
                        ],
                      ),
                      loading: () => Text(
                        'Tarih yükleniyor...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: TamgaciConstants.textOnPrimary
                              .withValues(alpha: 0.8),
                        ),
                      ),
                      error: (_, __) => Text(
                        'Tarih alınamadı',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: TamgaciConstants.textOnPrimary
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sağ taraf: Piyasa verileri
              Expanded(
                flex: 3,
                child: stockMarketDataAsync.when(
                  data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Piyasa Verileri',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: TamgaciConstants.textOnPrimary
                              .withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: TamgaciConstants.spaceSM),
                      // Döviz kurları
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildMarketItemCompact(
                            'USD/TRY',
                            data.usdTry.toStringAsFixed(2),
                            data.usdTryChange,
                            data.usdTryChangePercent,
                            Icons.attach_money,
                          ),
                          const SizedBox(width: TamgaciConstants.spaceSM),
                          _buildMarketItemCompact(
                            'EUR/TRY',
                            data.eurTry.toStringAsFixed(2),
                            data.eurTryChange,
                            data.eurTryChangePercent,
                            Icons.euro,
                          ),
                        ],
                      ),
                      const SizedBox(height: TamgaciConstants.spaceSM),
                      // Altın
                      _buildMarketItemCompact(
                        'Altın (TL)',
                        data.goldPrice.toStringAsFixed(2),
                        data.goldPriceChange,
                        data.goldPriceChangePercent,
                        Icons.monetization_on,
                      ),
                    ],
                  ),
                  loading: () => const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  error: (_, __) => Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: TamgaciConstants.textOnPrimary
                              .withValues(alpha: 0.7),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Veriler yüklenemedi',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: TamgaciConstants.textOnPrimary
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Kompakt piyasa veri öğesi (birleştirilmiş kart için)
  Widget _buildMarketItemCompact(
    String title,
    String value,
    double change,
    String changePercent,
    IconData icon,
  ) {
    final isPositive = change >= 0;

    return Container(
      padding: const EdgeInsets.all(TamgaciConstants.spaceSM),
      decoration: BoxDecoration(
        color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        border: Border.all(
          color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TamgaciConstants.textOnPrimary,
            ),
          ),
          Text(
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} ($changePercent)',
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: isPositive ? Colors.green[300] : Colors.red[300],
            ),
          ),
        ],
      ),
    );
  }

  /// Piyasa veri öğesi
  Widget _buildMarketItem(
    String title,
    String value,
    double change,
    String changePercent,
    IconData icon, {
    bool isSmall = false,
  }) {
    final isPositive = change >= 0;
    final fontSize = isSmall ? 12.0 : 14.0;
    final valueFontSize = isSmall ? 16.0 : 18.0;

    return Container(
      padding: EdgeInsets.all(
          isSmall ? TamgaciConstants.spaceSM : TamgaciConstants.spaceMD),
      decoration: BoxDecoration(
        color: TamgaciConstants.backgroundColor,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        border: Border.all(color: TamgaciConstants.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: isSmall ? 14 : 16,
                color: TamgaciConstants.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: TamgaciConstants.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w600,
              color: TamgaciConstants.textPrimary,
            ),
          ),
          Text(
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} ($changePercent)',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 9 : 10,
              fontWeight: FontWeight.w500,
              color: isPositive
                  ? TamgaciConstants.successColor
                  : TamgaciConstants.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Özet kartları
  Widget _buildSummaryCards(BuildContext context, DashboardSummary summary) {
    final summaryData = [
      {
        'title': 'Bu Ay Gelir',
        'amount': summary.formattedCurrentMonthIncome,
        'change': summary.formattedIncomeChange,
        'color': summary.incomeChangePercent >= 0
            ? TamgaciConstants.successColor
            : TamgaciConstants.errorColor,
        'icon': Icons.trending_up,
        'route': TamgaciRoutes.incomeList,
        'onTap': () {
          TamgaciRoutes.pushNamed(context, TamgaciRoutes.incomeList);
        },
      },
      {
        'title': 'Bu Ay Gider',
        'amount': summary.formattedCurrentMonthExpense,
        'change': summary.formattedExpenseChange,
        'color': summary.expenseChangePercent >= 0
            ? TamgaciConstants.errorColor
            : TamgaciConstants.successColor,
        'icon': Icons.trending_down,
        'route': TamgaciRoutes.expensesList,
        'onTap': () {
          TamgaciRoutes.pushNamed(context, TamgaciRoutes.expensesList);
        },
      },
      {
        'title': 'Net Kar',
        'amount': summary.formattedNetProfit,
        'change': summary.formattedNetProfitChange,
        'color': summary.netProfitChangePercent >= 0
            ? TamgaciConstants.primaryColor
            : TamgaciConstants.errorColor,
        'icon': Icons.account_balance_wallet,
        'route': TamgaciRoutes.reportsOverview,
        'onTap': () {
          TamgaciRoutes.pushNamed(context, TamgaciRoutes.reportsOverview);
        },
      },
      {
        'title': 'Bekleyen Fatura',
        'amount': '${summary.pendingInvoicesCount}',
        'change': 'Adet',
        'color': TamgaciConstants.warningColor,
        'icon': Icons.receipt_long,
        'route': TamgaciRoutes.invoicesList,
        'onTap': () {
          TamgaciRoutes.pushNamed(context, TamgaciRoutes.invoicesList);
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: TamgaciConstants.isMobile(context) ? 2 : 4,
        crossAxisSpacing: TamgaciConstants.spaceMD,
        mainAxisSpacing: TamgaciConstants.spaceMD,
        childAspectRatio: 1.2,
      ),
      itemCount: summaryData.length,
      itemBuilder: (context, index) {
        final data = summaryData[index];
        return InkWell(
          onTap: data['onTap'] as VoidCallback,
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
          child: Container(
            padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
            decoration: BoxDecoration(
              color: TamgaciConstants.cardColor,
              borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
              boxShadow: TamgaciConstants.shadowLight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      data['icon'] as IconData,
                      color: data['color'] as Color,
                      size: 24,
                    ),
                    Text(
                      data['change'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: data['color'] as Color,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  data['amount'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TamgaciConstants.textPrimary,
                  ),
                ),
                Text(
                  data['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: TamgaciConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Özet kartları loading
  Widget _buildSummaryCardsLoading() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TamgaciConstants.cardColor,
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
            boxShadow: TamgaciConstants.shadowLight,
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  /// Özet kartları error
  Widget _buildSummaryCardsError(Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TamgaciConstants.cardColor,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        boxShadow: TamgaciConstants.shadowLight,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: TamgaciConstants.errorColor,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Veri yüklenirken hata oluştu',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: TamgaciConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Hızlı istatistikler loading
  Widget _buildQuickStatsLoading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İstatistikler',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: TamgaciConstants.isMobile(context) ? 2 : 4,
            crossAxisSpacing: TamgaciConstants.spaceMD,
            mainAxisSpacing: TamgaciConstants.spaceMD,
            childAspectRatio: 1.2,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
              decoration: BoxDecoration(
                color: TamgaciConstants.cardColor,
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
                boxShadow: TamgaciConstants.shadowLight,
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ],
    );
  }

  /// Hızlı istatistikler error
  Widget _buildQuickStatsError(Object error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İstatistikler',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        Container(
          padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
          decoration: BoxDecoration(
            color: TamgaciConstants.cardColor,
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
            boxShadow: TamgaciConstants.shadowLight,
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: TamgaciConstants.errorColor,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'İstatistikler yüklenirken hata oluştu',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TamgaciConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Hızlı istatistikler
  Widget _buildQuickStats(BuildContext context, DashboardSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İstatistikler',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: TamgaciConstants.isMobile(context) ? 2 : 4,
            crossAxisSpacing: TamgaciConstants.spaceMD,
            mainAxisSpacing: TamgaciConstants.spaceMD,
            childAspectRatio: 1.2,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final stats = [
              {
                'title': 'Toplam Müşteri',
                'amount': '${summary.totalCustomers}',
                'change': 'Müşteri',
                'color': TamgaciConstants.successColor,
                'icon': Icons.people,
                'route': TamgaciRoutes.customersList,
              },
              {
                'title': 'Toplam Ürün',
                'amount': '${summary.totalProducts}',
                'change': 'Ürün',
                'color': TamgaciConstants.primaryColor,
                'icon': Icons.inventory,
                'route': TamgaciRoutes.productsList,
              },
              {
                'title': 'Toplam Tedarikçi',
                'amount': '${summary.totalSuppliers}',
                'change': 'Tedarikçi',
                'color': TamgaciConstants.warningColor,
                'icon': Icons.business,
                'route': TamgaciRoutes.suppliersList,
              },
              {
                'title': 'Stok Değeri',
                'amount': summary.formattedTotalStockValue,
                'change': 'Değer',
                'color': TamgaciConstants.errorColor,
                'icon': Icons.warehouse,
                'route': TamgaciRoutes.inventory,
              },
            ];

            final stat = stats[index];
            return InkWell(
              onTap: () {
                TamgaciRoutes.pushNamed(context, stat['route'] as String);
              },
              borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
              child: Container(
                padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
                decoration: BoxDecoration(
                  color: TamgaciConstants.cardColor,
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                  boxShadow: TamgaciConstants.shadowLight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          stat['icon'] as IconData,
                          color: stat['color'] as Color,
                          size: 24,
                        ),
                        Text(
                          stat['change'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: stat['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      stat['amount'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TamgaciConstants.textPrimary,
                      ),
                    ),
                    Text(
                      stat['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Hızlı işlemler
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: TamgaciConstants.isMobile(context) ? 2 : 4,
            crossAxisSpacing: TamgaciConstants.spaceMD,
            mainAxisSpacing: TamgaciConstants.spaceMD,
            childAspectRatio: 1.2,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final actions = [
              {
                'title': 'Yeni Fatura Oluştur',
                'icon': Icons.receipt_long_outlined,
                'route': TamgaciRoutes.createInvoice,
                'color': TamgaciConstants.primaryColor,
                'gradient': LinearGradient(
                  colors: [
                    TamgaciConstants.primaryColor.withValues(alpha: 0.15),
                    TamgaciConstants.primaryColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              },
              {
                'title': 'Gider Ekle',
                'icon': Icons.money_off_outlined,
                'route': TamgaciRoutes.createExpense,
                'color': TamgaciConstants.errorColor,
                'gradient': LinearGradient(
                  colors: [
                    TamgaciConstants.errorColor.withValues(alpha: 0.15),
                    TamgaciConstants.errorColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              },
              {
                'title': 'Gelir Ekle',
                'icon': Icons.attach_money_outlined,
                'route': TamgaciRoutes.createIncome,
                'color': TamgaciConstants.successColor,
                'gradient': LinearGradient(
                  colors: [
                    TamgaciConstants.successColor.withValues(alpha: 0.15),
                    TamgaciConstants.successColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              },
              {
                'title': 'Stok Hareketi',
                'icon': Icons.inventory_2_outlined,
                'route': TamgaciRoutes.inventory,
                'color': TamgaciConstants.warningColor,
                'gradient': LinearGradient(
                  colors: [
                    TamgaciConstants.warningColor.withValues(alpha: 0.15),
                    TamgaciConstants.warningColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              },
            ];

            final action = actions[index];
            return InkWell(
              onTap: () {
                TamgaciRoutes.pushNamed(context, action['route'] as String);
              },
              borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
              child: Container(
                padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
                decoration: BoxDecoration(
                  gradient: action['gradient'] as LinearGradient,
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                  border: Border.all(
                    color: (action['color'] as Color).withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (action['color'] as Color).withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      action['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TamgaciConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Aylık grafik
  Widget _buildMonthlyChart(List<MonthlyChartData> chartData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aylık Gelir-Gider Grafiği',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TamgaciConstants.cardColor,
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
            boxShadow: TamgaciConstants.shadowLight,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: chartData.map((data) {
              final maxValue = chartData.fold<double>(
                0,
                (max, item) => [
                          item.income,
                          item.expense,
                          item.profit,
                        ].reduce((a, b) => a > b ? a : b) >
                        max
                    ? [
                        item.income,
                        item.expense,
                        item.profit,
                      ].reduce((a, b) => a > b ? a : b)
                    : max,
              );

              return Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Gelir bar
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: TamgaciConstants.successColor.withValues(
                                  alpha: 0.8,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              height: maxValue > 0
                                  ? (data.income / maxValue * 150)
                                  : 0,
                            ),
                          ),
                          // Gider bar
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: TamgaciConstants.errorColor.withValues(
                                  alpha: 0.8,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              height: maxValue > 0
                                  ? (data.expense / maxValue * 150)
                                  : 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.month,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem('Gelir', TamgaciConstants.successColor),
            _buildLegendItem('Gider', TamgaciConstants.errorColor),
          ],
        ),
      ],
    );
  }

  /// Grafik loading
  Widget _buildChartLoading() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TamgaciConstants.cardColor,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        boxShadow: TamgaciConstants.shadowLight,
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  /// Grafik error
  Widget _buildChartError(Object error) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TamgaciConstants.cardColor,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        boxShadow: TamgaciConstants.shadowLight,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: TamgaciConstants.errorColor,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Grafik yüklenirken hata oluştu',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: TamgaciConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Grafik açıklaması
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: TamgaciConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Son işlemler
  Widget _buildRecentTransactions(
    BuildContext context,
    List<TransactionItem> transactions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son İşlemler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // Tüm işlemleri göster - gelir sayfasına yönlendir
                TamgaciRoutes.pushNamed(context, TamgaciRoutes.incomeList);
              },
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return InkWell(
              onTap: () {
                _navigateToTransactionDetail(context, transaction);
              },
              borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: TamgaciConstants.primaryLight,
                  child: Icon(
                    _getTransactionIcon(transaction.type),
                    color: _getTransactionColor(transaction.type),
                  ),
                ),
                title: Text(
                  transaction.title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  transaction.formattedDate,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: TamgaciConstants.textSecondary,
                  ),
                ),
                trailing: Text(
                  transaction.formattedAmountWithSign,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: _getTransactionColor(transaction.type),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// İşlem detaylarına yönlendir
  void _navigateToTransactionDetail(
    BuildContext context,
    TransactionItem transaction,
  ) {
    switch (transaction.type) {
      case TransactionType.income:
        TamgaciRoutes.pushNamed(
          context,
          TamgaciRoutes.incomeDetail,
          arguments: transaction.id,
        );
        break;
      case TransactionType.expense:
        TamgaciRoutes.pushNamed(
          context,
          TamgaciRoutes.expenseDetail,
          arguments: transaction.id,
        );
        break;
      case TransactionType.invoice:
        TamgaciRoutes.pushNamed(
          context,
          TamgaciRoutes.invoiceDetail,
          arguments: transaction.id,
        );
        break;
    }
  }

  /// İşlemler loading
  Widget _buildTransactionsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son İşlemler',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  /// İşlemler error
  Widget _buildTransactionsError(Object error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son İşlemler',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TamgaciConstants.cardColor,
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
            boxShadow: TamgaciConstants.shadowLight,
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: TamgaciConstants.errorColor,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'İşlemler yüklenirken hata oluştu',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TamgaciConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// İşlem türüne göre icon
  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.trending_up;
      case TransactionType.expense:
        return Icons.trending_down;
      case TransactionType.invoice:
        return Icons.receipt_long;
    }
  }

  /// İşlem türüne göre renk
  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return TamgaciConstants.successColor;
      case TransactionType.expense:
        return TamgaciConstants.errorColor;
      case TransactionType.invoice:
        return TamgaciConstants.primaryColor;
    }
  }

  /// Hızlı işlem menüsünü göster
  void _showQuickActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TamgaciConstants.radiusLG),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hızlı İşlem Seç',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: TamgaciConstants.spaceLG),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Yeni Fatura Oluştur'),
                onTap: () {
                  Navigator.pop(context);
                  TamgaciRoutes.pushNamed(context, TamgaciRoutes.createInvoice);
                },
              ),
              ListTile(
                leading: const Icon(Icons.money_off_outlined),
                title: const Text('Gider Ekle'),
                onTap: () {
                  Navigator.pop(context);
                  TamgaciRoutes.pushNamed(context, TamgaciRoutes.createExpense);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money_outlined),
                title: const Text('Gelir Ekle'),
                onTap: () {
                  Navigator.pop(context);
                  TamgaciRoutes.pushNamed(context, TamgaciRoutes.createIncome);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
