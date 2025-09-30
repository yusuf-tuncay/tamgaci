// ========== DASHBOARD PAGE ==========
// lib/features/dashboard/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../../../../shared/overlays/calculator_overlay.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/providers/currency_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user.dart' as auth_domain;
import '../providers/dashboard_providers.dart';
import '../widgets/exchange_rates_widget.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/dashboard_chart_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/recent_activities_widget.dart';
import '../widgets/product_variants_widget.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../../inventory/presentation/providers/warehouse_providers.dart';
import '../../../inventory/presentation/providers/stock_providers.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
// imports removed: invoice backfill kaldırıldı

/// Dashboard Sayfası
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  // Backfill kaldırıldı: bazı projelerde kurallar nedeniyle uyarı üretiyordu
  Map<String, dynamic>? _weather;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      // Lightweight geolocation (best effort)
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      double lat = 41.015137;
      double lon = 28.979530;
      if (perm != LocationPermission.denied &&
          perm != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low);
        lat = pos.latitude;
        lon = pos.longitude;
      }
      // Open-Meteo free API (no key)
      final uri = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true');
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        setState(() {
          _weather = data['current_weather'] as Map<String, dynamic>?;
        });
      }
    } catch (_) {
      // ignore silently
    }
  }

  Widget _buildWeatherPill() {
    final w = _weather;
    final temp = w != null ? (w['temperature']?.toString() ?? '') : '';
    final wind = w != null ? (w['windspeed']?.toString() ?? '') : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wb_sunny, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            w == null ? 'Hava durumu' : '$temp°C, rüzgar $wind km/s',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);
    final recentActivitiesAsync = ref.watch(recentTransactionsProvider);
    final monthlyChartAsync = ref.watch(monthlyChartDataProvider);

    return ResponsiveScaffold(
      appBar: const CustomAppBar(title: 'Dashboard', showDrawer: true),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: _buildMobileLayout(
        dashboardSummaryAsync,
        recentActivitiesAsync,
        monthlyChartAsync,
        isDark,
      ),
    );
  }

  Widget? _buildSubscriptionBanner(auth_domain.User? user) {
    if (user == null) return null;
    final now = DateTime.now();
    DateTime? end;
    if (user.subscriptionStatus == auth_domain.SubscriptionStatus.trial) {
      end = user.trialEndAt;
    } else if (user.subscriptionStatus ==
        auth_domain.SubscriptionStatus.active) {
      end = user.subscriptionEndAt;
    }
    if (end == null) return null;
    final remaining = end.difference(now).inDays;
    if (remaining > 3 && now.isBefore(end)) return null;
    final isExpired = now.isAfter(end);
    final text = isExpired
        ? 'Abonelik süreniz doldu. Devam etmek için lütfen aboneliğinizi yenileyin.'
        : 'Aboneliğinizin bitmesine $remaining gün kaldı. Yenilemeyi unutmayın.';
    final color = isExpired ? Colors.red : Colors.orange;
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(TamgaciRoutes.subscription),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    AsyncValue<DashboardSummary> dashboardSummaryAsync,
    AsyncValue<List<TransactionItem>> recentActivitiesAsync,
    AsyncValue<List<MonthlyChartData>> monthlyChartAsync,
    bool isDark,
  ) {
    final user = ref.watch(currentUserProvider);
    final banner = _buildSubscriptionBanner(user);
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh dashboard data and exchange rates
        ref.invalidate(exchangeRatesProvider);
        ref.invalidate(dashboardSummaryProvider);
        ref.invalidate(recentTransactionsProvider);
        ref.invalidate(monthlyChartDataProvider);
        ref.invalidate(paymentsProvider);
        ref.invalidate(paymentStatsProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (banner != null) banner,
            _buildWelcomeCard(isDark),
            const SizedBox(height: 16),
            const QuickActionsWidget(),
            const SizedBox(height: 16),
            _buildStatsGrid(dashboardSummaryAsync, isDark),
            const SizedBox(height: 16),
            _buildPaymentsSection(isDark),
            const SizedBox(height: 16),
            _buildChartSection(monthlyChartAsync, isDark),
            const SizedBox(height: 16),
            const ExchangeRatesWidget(),
            const SizedBox(height: 16),
            const ProductVariantsWidget(),
            const SizedBox(height: 16),
            _buildRecentActivitiesSection(recentActivitiesAsync, isDark),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildTabletLayout(
      AsyncValue<DashboardSummary> dashboardSummaryAsync, bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh dashboard data and exchange rates
        ref.invalidate(exchangeRatesProvider);
        ref.invalidate(dashboardSummaryProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(flex: 2, child: _buildWelcomeCard(isDark)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildQuickStats(dashboardSummaryAsync, isDark)),
              ],
            ),
            const SizedBox(height: 24),
            _buildQuickActions(isDark),
            const SizedBox(height: 24),
            _buildRecentActivities(isDark),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildDesktopLayout(
      AsyncValue<DashboardSummary> dashboardSummaryAsync, bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh dashboard data and exchange rates
        ref.invalidate(exchangeRatesProvider);
        ref.invalidate(dashboardSummaryProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(flex: 3, child: _buildWelcomeCard(isDark)),
                const SizedBox(width: 24),
                Expanded(
                    flex: 2,
                    child: _buildQuickStats(dashboardSummaryAsync, isDark)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildQuickActions(isDark)),
                const SizedBox(width: 24),
                Expanded(flex: 3, child: _buildRecentActivities(isDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + text (open calculator on tap)
          GestureDetector(
              onTap: () => CalculatorOverlay.instance.toggle(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'assets/images/logos/140x140logo.png',
                    fit: BoxFit.contain,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              )),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer(builder: (context, ref, _) {
                  final profileAsync = ref.watch(userProfileProvider);
                  return Text(
                    profileAsync.value?.company ?? 'Şirket Adı',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  );
                }),
                const SizedBox(height: 6),
                LayoutBuilder(builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 280;
                  return Text(
                    'Tamgacı profesyonel iş yönetim uygulaması',
                    maxLines: narrow ? 2 : 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: narrow ? 11 : 12,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hoş Geldiniz! Bugün: ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now())}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Weather on the right
          _buildWeatherPill(),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
      AsyncValue<DashboardSummary> dashboardSummaryAsync, bool isDark) {
    final warehousesAsync = ref.watch(warehousesProvider);
    final lowStocksAsync = ref.watch(lowStocksProvider);
    final totalStockValueAsync = ref.watch(totalStockValueProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TamgaciConstants.borderColor : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İstatistikler',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : TamgaciConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatItem(
              'Toplam Müşteri', '12', Icons.people, Colors.blue, isDark),
          const SizedBox(height: 8),
          _buildStatItem(
              'Toplam Ürün', '45', Icons.inventory, Colors.orange, isDark),
          const SizedBox(height: 8),
          warehousesAsync.when(
            data: (warehouses) {
              final activeWarehouses =
                  warehouses.where((w) => w.isActive).length;
              return _buildStatItem('Aktif Depo', activeWarehouses.toString(),
                  Icons.warehouse, Colors.green, isDark);
            },
            loading: () => _buildStatItem(
                'Aktif Depo', '...', Icons.warehouse, Colors.green, isDark),
            error: (error, stack) => _buildStatItem(
                'Aktif Depo', '0', Icons.warehouse, Colors.green, isDark),
          ),
          const SizedBox(height: 8),
          lowStocksAsync.when(
            data: (lowStocks) => _buildStatItem('Düşük Stok',
                lowStocks.length.toString(), Icons.warning, Colors.red, isDark),
            loading: () => _buildStatItem(
                'Düşük Stok', '...', Icons.warning, Colors.red, isDark),
            error: (error, stack) => _buildStatItem(
                'Düşük Stok', '0', Icons.warning, Colors.red, isDark),
          ),
          const SizedBox(height: 8),
          totalStockValueAsync.when(
            data: (totalStockValue) => _buildStatItem(
                'Stok Değeri',
                '₺${totalStockValue.toStringAsFixed(0)}',
                Icons.attach_money,
                Colors.purple,
                isDark),
            loading: () => _buildStatItem('Stok Değeri', '...',
                Icons.attach_money, Colors.purple, isDark),
            error: (error, stack) => _buildStatItem(
                'Stok Değeri', '₺0', Icons.attach_money, Colors.purple, isDark),
          ),
          const SizedBox(height: 8),
          _buildStatItem(
              'Bekleyen Fatura', '5', Icons.receipt, Colors.red, isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark
                      ? TamgaciConstants.textSecondaryDark
                      : TamgaciConstants.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TamgaciConstants.borderColor : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İşlemler',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : TamgaciConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard('Fatura Oluştur', Icons.receipt_long,
                  TamgaciConstants.primaryColor, () {
                Navigator.of(context).pushNamed(TamgaciRoutes.invoicesList);
              }, isDark),
              _buildActionCard('Gider Ekle', Icons.remove_circle, Colors.red,
                  () {
                Navigator.of(context).pushNamed(TamgaciRoutes.createExpense);
              }, isDark),
              _buildActionCard('Gelir Ekle', Icons.add_circle, Colors.green,
                  () {
                Navigator.of(context).pushNamed(TamgaciRoutes.createIncome);
              }, isDark),
              _buildActionCard('Ürün Ekle', Icons.inventory_2, Colors.orange,
                  () {
                Navigator.of(context).pushNamed(TamgaciRoutes.createProduct);
              }, isDark),
              _buildActionCard('Müşteri Ekle', Icons.person_add, Colors.blue,
                  () {
                Navigator.of(context).pushNamed(TamgaciRoutes.createCustomer);
              }, isDark),
              _buildActionCard('Stok İşlemi', Icons.warehouse, Colors.purple,
                  () {
                Navigator.of(context).pushNamed(TamgaciRoutes.inventory);
              }, isDark),
              _buildActionCard('Depo Listesi', Icons.list, Colors.indigo, () {
                Navigator.of(context).pushNamed(TamgaciRoutes.warehouseList);
              }, isDark),
              _buildActionCard('Stok Listesi', Icons.inventory, Colors.teal,
                  () {
                Navigator.of(context).pushNamed(TamgaciRoutes.stockList);
              }, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color,
      VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : TamgaciConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TamgaciConstants.borderColor : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son Aktiviteler',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(TamgaciRoutes.expensesList);
                },
                child: Text(
                  'Tümünü Gör',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: TamgaciConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEmptyActivities(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyActivities(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: isDark
                ? TamgaciConstants.textSecondaryDark
                : TamgaciConstants.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz aktivite yok',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Tahsilat bölümü
  Widget _buildPaymentsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Tahsilat İstatistikleri',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, TamgaciRoutes.paymentsHome);
                },
                child: Text(
                  'Tümünü Gör',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final paymentsAsync = ref.watch(paymentsProvider);
              final paymentStatsAsync = ref.watch(paymentStatsProvider);

              return paymentsAsync.when(
                data: (payments) {
                  return paymentStatsAsync.when(
                    data: (stats) {
                      return Row(
                        children: [
                          Expanded(
                            child: _buildPaymentStatCard(
                              'Toplam Tahsilat',
                              '${payments.length}',
                              'işlem',
                              Icons.payments,
                              Colors.green,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPaymentStatCard(
                              'Toplam Tutar',
                              '₺${stats['totalAmount']?.toStringAsFixed(0) ?? '0'}',
                              'TRY',
                              Icons.attach_money,
                              Colors.blue,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPaymentStatCard(
                              'Tamamlanan',
                              '${stats['completed'] ?? 0}',
                              'işlem',
                              Icons.check_circle,
                              Colors.teal,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPaymentStatCard(
                              'Bekleyen',
                              '${stats['pending'] ?? 0}',
                              'işlem',
                              Icons.schedule,
                              Colors.orange,
                              isDark,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Text('Hata: $error'),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Hata: $error'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// İstatistik kartları grid'i
  Widget _buildStatsGrid(
      AsyncValue<DashboardSummary> dashboardSummaryAsync, bool isDark) {
    return dashboardSummaryAsync.when(
      data: (summary) {
        final cards = <Widget>[
          DashboardStatsCard(
            title: 'Toplam Satış',
            value: summary.totalSales,
            currency: 'TRY',
            icon: Icons.trending_up,
            iconColor: Colors.green,
            backgroundColor: Colors.green,
            percentageChange: summary.salesGrowthRate,
            percentageColor:
                summary.salesGrowthRate >= 0 ? Colors.green : Colors.red,
          ),
          DashboardStatsCard(
            title: 'Toplam Alış',
            value: summary.totalPurchases,
            currency: 'TRY',
            icon: Icons.shopping_cart,
            iconColor: Colors.orange,
            backgroundColor: Colors.orange,
          ),
          DashboardStatsCard(
            title: 'Net Kar/Zarar',
            value: summary.netProfit,
            currency: 'TRY',
            icon: Icons.account_balance_wallet,
            iconColor: summary.netProfit >= 0 ? Colors.green : Colors.red,
            backgroundColor: summary.netProfit >= 0 ? Colors.green : Colors.red,
          ),
          DashboardStatsCard(
            title: 'Toplam Bakiye',
            value: summary.totalBalance,
            currency: 'TRY',
            icon: Icons.account_balance,
            iconColor: Colors.blue,
            backgroundColor: Colors.blue,
          ),
          DashboardStatsCard(
            title: 'Kritik Stok',
            value: summary.criticalStockCount.toDouble(),
            currency: '',
            subtitle: 'ürün',
            icon: Icons.warning,
            iconColor: Colors.red,
            backgroundColor: Colors.red,
          ),
          DashboardStatsCard(
            title: 'Toplam Müşteri',
            value: summary.totalCustomers.toDouble(),
            currency: '',
            subtitle: 'kişi',
            icon: Icons.people,
            iconColor: Colors.purple,
            backgroundColor: Colors.purple,
          ),
          DashboardStatsCard(
            title: 'Bekleyen Tahsilat',
            value: summary.pendingReceivables,
            currency: 'TRY',
            icon: Icons.download,
            iconColor: Colors.teal,
            backgroundColor: Colors.teal,
          ),
          DashboardStatsCard(
            title: 'Bekleyen Ödeme',
            value: summary.pendingPayables,
            currency: 'TRY',
            icon: Icons.upload,
            iconColor: Colors.indigo,
            backgroundColor: Colors.indigo,
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            // Responsive max item width so small screens do not overflow
            double maxExtent = 260;
            if (width < 400) {
              maxExtent = 300; // allow single column if very narrow
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: maxExtent,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) => cards[index],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Veri yüklenirken hata oluştu: $error',
          style: GoogleFonts.poppins(color: Colors.red),
        ),
      ),
    );
  }

  /// Grafik bölümü
  Widget _buildChartSection(
      AsyncValue<List<MonthlyChartData>> monthlyChartAsync, bool isDark) {
    return monthlyChartAsync.when(
      data: (chartData) {
        final chartDataList = chartData
            .map((data) => ChartData(
                  label: data.month,
                  value: data.income,
                ))
            .toList();

        return DashboardChartWidget(
          title: 'Aylık Satış Grafiği',
          data: chartDataList,
          type: ChartType.bar,
        );
      },
      loading: () => Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Grafik yüklenirken hata oluştu',
            style: GoogleFonts.poppins(color: Colors.red),
          ),
        ),
      ),
    );
  }

  /// Son aktiviteler bölümü
  Widget _buildRecentActivitiesSection(
      AsyncValue<List<TransactionItem>> recentActivitiesAsync, bool isDark) {
    return recentActivitiesAsync.when(
      data: (transactions) {
        final activities = transactions
            .map((transaction) => ActivityItem(
                  title: transaction.title,
                  description: transaction.description,
                  icon: _getIconForTransactionType(transaction.type),
                  color: _getColorForTransactionType(transaction.type),
                  date: transaction.date,
                  amount: transaction.amount,
                  currency: 'TRY',
                ))
            .toList();

        return RecentActivitiesWidget(activities: activities);
      },
      loading: () => Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Aktiviteler yüklenirken hata oluştu',
            style: GoogleFonts.poppins(color: Colors.red),
          ),
        ),
      ),
    );
  }

  /// İşlem türüne göre ikon döndürür
  IconData _getIconForTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.attach_money;
      case TransactionType.expense:
        return Icons.money_off;
      case TransactionType.invoice:
        return Icons.receipt;
      case TransactionType.payment:
        return Icons.payments;
    }
  }

  /// İşlem türüne göre renk döndürür
  Color _getColorForTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.invoice:
        return Colors.blue;
      case TransactionType.payment:
        return Colors.teal;
    }
  }
}
