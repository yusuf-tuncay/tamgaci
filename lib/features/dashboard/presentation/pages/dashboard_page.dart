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
import '../../../../core/guards/subscription_guard.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/providers/currency_providers.dart';
import '../../../../core/providers/company_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user.dart' as auth_domain;
import '../providers/dashboard_providers.dart';
import '../widgets/exchange_rates_widget.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/recent_activities_widget.dart';
// Silinen widget: product_variants_widget - gereksiz
import '../../domain/entities/dashboard_summary.dart';
// Silinen modül: user_profile
// Silinen modül: payments
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
        if (mounted) {
          setState(() {
            _weather = data['current_weather'] as Map<String, dynamic>?;
          });
        }
      }
    } catch (_) {
      // ignore silently
    }
  }

  Widget _buildWeatherPill() {
    final w = _weather;
    final temp = w != null ? (w['temperature']?.toString() ?? '') : '';
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 6, vertical: 4), // Smaller padding
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16), // Smaller border radius
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // Center content
        children: [
          const Icon(Icons.wb_sunny,
              color: Colors.white, size: 14), // Smaller icon
          const SizedBox(width: 4), // Smaller spacing
          Flexible(
            // Added Flexible
            child: Text(
              w == null ? 'Hava' : '$temp°C', // Shorter text
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10, // Smaller font size
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis, // Added overflow handling
              maxLines: 1, // Added maxLines
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Sadece kritik verileri hemen yükle
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);
    // Diğer verileri lazy load yap
    final recentActivitiesAsync = ref.watch(recentTransactionsProvider);
    final monthlyChartAsync = ref.watch(monthlyChartDataProvider);

    return SubscriptionGuard(
      allowTrial: true, // Deneme süresi kullanıcılarına izin ver
      allowExpired: false, // Süresi dolan kullanıcılara izin verme
      child: ResponsiveScaffold(
        appBar: const CustomAppBar(title: 'Dashboard', showDrawer: true),
        drawerContent: const TamgaciDrawerMenu(),
        persistentOnLarge: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Masaüstü için optimize edilmiş layout
            if (constraints.maxWidth >= 1200) {
              return _buildDesktopLayout(
                dashboardSummaryAsync,
                recentActivitiesAsync,
                monthlyChartAsync,
                isDark,
              );
            }
            // Tablet için layout
            else if (constraints.maxWidth >= 768) {
              return _buildTabletLayout(
                dashboardSummaryAsync,
                recentActivitiesAsync,
                monthlyChartAsync,
                isDark,
              );
            }
            // Mobil için layout
            else {
              return _buildMobileLayout(
                dashboardSummaryAsync,
                recentActivitiesAsync,
                monthlyChartAsync,
                isDark,
              );
            }
          },
        ),
      ),
    );
  }

  Widget? _buildSubscriptionBanner(auth_domain.User? user) {
    if (user == null) return null;
    final now = DateTime.now();

    // Debug bilgileri
    // Deneme süresi kullanıcıları için özel kart

    // 1. Deneme süresi hiç abonelik satın almamış olanlar (trial status)
    if (user.subscriptionStatus == auth_domain.SubscriptionStatus.trial &&
        user.trialEndAt != null) {
      final trialEnd = user.trialEndAt!;
      final remainingDays = trialEnd.difference(now).inDays;
      final remainingHours = trialEnd.difference(now).inHours % 24;

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange[400]!,
              Colors.orange[600]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.access_time,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text ve süre bilgisi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deneme Süreniz',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remainingDays > 0
                        ? '$remainingDays gün, $remainingHours saat kaldı'
                        : 'Deneme süreniz doldu',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Süre satın al butonu
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(TamgaciRoutes.subscription),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[600],
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Süre Satın Al',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. Süresi bitmiş olanlar (expired status)
    if (user.subscriptionStatus == auth_domain.SubscriptionStatus.expired) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red[400]!,
              Colors.red[600]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text ve bilgi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Abonelik Süresi Doldu',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aboneliğinizi yenileyerek tüm özelliklerden yararlanmaya devam edin',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Abonelik yenile butonu
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(TamgaciRoutes.subscription),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red[600],
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Abonelik Yenile',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Daha önce abonelik almış ama süresi azalan (45 günden az kalan)
    if (user.subscriptionStatus == auth_domain.SubscriptionStatus.active &&
        user.subscriptionEndAt != null) {
      final subscriptionEnd = user.subscriptionEndAt!;
      final remainingDays = subscriptionEnd.difference(now).inDays;

      if (remainingDays <= 45 && remainingDays > 0) {
        debugPrint(
            '=== DEBUG: Showing subscription renewal card ($remainingDays days left) ===');
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue[400]!,
                Colors.blue[600]!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text ve bilgi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Abonelik Süresi Azalıyor',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$remainingDays gün kaldı. Yenilemeyi unutmayın!',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              // Abonelik yenile butonu
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(TamgaciRoutes.subscription),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[600],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Abonelik Yenile',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    return null;
  }

  Widget _buildMobileLayout(
    AsyncValue<DashboardSummary> dashboardSummaryAsync,
    AsyncValue<List<TransactionItem>> recentActivitiesAsync,
    AsyncValue<List<MonthlyChartData>> monthlyChartAsync,
    bool isDark,
  ) {
    final user = ref.watch(currentUserProvider);
    final banner = _buildSubscriptionBanner(user.value);
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh dashboard data and exchange rates
        ref.invalidate(exchangeRatesProvider);
        ref.invalidate(dashboardSummaryProvider);
        ref.invalidate(recentTransactionsProvider);
        ref.invalidate(monthlyChartDataProvider);
        // Silinen modül: payments
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
            // Stats Grid + Exchange Rates (3x3 grid)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildStatsGrid(dashboardSummaryAsync, isDark),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  flex: 1,
                  child: ExchangeRatesWidget(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Silinen widget: ProductVariantsWidget - gereksiz
            _buildRecentActivitiesSection(recentActivitiesAsync, isDark),
          ],
        ),
      ),
    );
  }

  /// Tablet için optimize edilmiş dashboard layout'u
  Widget _buildTabletLayout(
    AsyncValue<DashboardSummary> dashboardSummaryAsync,
    AsyncValue<List<TransactionItem>> recentActivitiesAsync,
    AsyncValue<List<MonthlyChartData>> monthlyChartAsync,
    bool isDark,
  ) {
    final user = ref.watch(currentUserProvider);
    final banner = _buildSubscriptionBanner(user.value);

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh dashboard data and exchange rates
        ref.invalidate(exchangeRatesProvider);
        ref.invalidate(dashboardSummaryProvider);
        ref.invalidate(recentTransactionsProvider);
        ref.invalidate(monthlyChartDataProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner (if exists)
            if (banner != null) ...[
              banner,
              const SizedBox(height: 20),
            ],

            // Üst satır: Welcome Card (full width)
            _buildWelcomeCard(isDark),

            const SizedBox(height: 20),

            // Quick Actions
            _buildQuickActions(isDark),

            const SizedBox(height: 20),

            // Stats Grid + Exchange Rates (3x3 grid)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildStatsGrid(dashboardSummaryAsync, isDark),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  flex: 1,
                  child: ExchangeRatesWidget(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Recent Activities
            _buildRecentActivitiesSection(recentActivitiesAsync, isDark),
          ],
        ),
      ),
    );
  }

  /// Masaüstü için optimize edilmiş dashboard layout'u
  Widget _buildDesktopLayout(
    AsyncValue<DashboardSummary> dashboardSummaryAsync,
    AsyncValue<List<TransactionItem>> recentActivitiesAsync,
    AsyncValue<List<MonthlyChartData>> monthlyChartAsync,
    bool isDark,
  ) {
    final user = ref.watch(currentUserProvider);
    final banner = _buildSubscriptionBanner(user.value);

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh dashboard data and exchange rates
        ref.invalidate(exchangeRatesProvider);
        ref.invalidate(dashboardSummaryProvider);
        ref.invalidate(recentTransactionsProvider);
        ref.invalidate(monthlyChartDataProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner (if exists)
            if (banner != null) ...[
              banner,
              const SizedBox(height: 24),
            ],

            // Üst satır: Welcome Card (full width)
            _buildWelcomeCard(isDark),

            const SizedBox(height: 24),

            // İkinci satır: Quick Actions (full width, compact)
            _buildQuickActionsCompactFull(isDark),

            const SizedBox(height: 24),

            // Üçüncü satır: Stats Grid + Exchange Rates (3x3 grid)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildStatsGrid(dashboardSummaryAsync, isDark),
                ),
                const SizedBox(width: 24),
                const Expanded(
                  flex: 1,
                  child: ExchangeRatesWidget(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Alt satır: Recent Activities (full width)
            _buildRecentActivitiesSection(recentActivitiesAsync, isDark),
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
                  final companyName = ref.watch(companyNameProvider);
                  return Text(
                    companyName,
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
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildActionCard('Fatura Oluştur', Icons.receipt_long,
                  TamgaciConstants.primaryColor, () {
                Navigator.of(context).pushNamed(TamgaciRoutes.invoicesList);
              }, isDark),
              // Silinen modül: expenses
              // Silinen modül: income
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
              _buildActionCard('Logger Test', Icons.color_lens, Colors.pink,
                  () {
                Navigator.of(context)
                    .pushNamed(TamgaciRoutes.colorizedLoggerTest);
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

  /// Tam genişlikte kompakt hızlı işlemler widget'ı
  Widget _buildQuickActionsCompactFull(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : TamgaciConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // 4x2 grid layout for full width compact view
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildActionCardMini(
                      'Fatura',
                      Icons.receipt,
                      Colors.blue,
                      () => Navigator.of(context)
                          .pushNamed(TamgaciRoutes.invoicesList),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionCardMini(
                      'Alış',
                      Icons.shopping_cart,
                      Colors.orange,
                      () => Navigator.of(context)
                          .pushNamed(TamgaciRoutes.purchasesList),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionCardMini(
                      'Müşteri',
                      Icons.person_add,
                      Colors.green,
                      () => Navigator.of(context)
                          .pushNamed(TamgaciRoutes.createCustomer),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionCardMini(
                      'Ürün',
                      Icons.add_box,
                      Colors.purple,
                      () => Navigator.of(context)
                          .pushNamed(TamgaciRoutes.createProduct),
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCardMini(
                      'Stok',
                      Icons.warehouse,
                      Colors.teal,
                      () => Navigator.of(context)
                          .pushNamed(TamgaciRoutes.inventory),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionCardMini(
                      'Depo',
                      Icons.list,
                      Colors.indigo,
                      () => Navigator.of(context)
                          .pushNamed(TamgaciRoutes.warehouseList),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionCardMini(
                      'Rapor',
                      Icons.analytics,
                      Colors.pink,
                      () => Navigator.of(context)
                          .pushNamed(TamgaciRoutes.dashboard),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionCardMini(
                      'Ayarlar',
                      Icons.settings,
                      Colors.grey,
                      () => Navigator.of(context)
                          .pushNamed(TamgaciRoutes.settings),
                      isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Mini action card
  Widget _buildActionCardMini(String title, IconData icon, Color color,
      VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : TamgaciConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Silinen modül: payments - _buildPaymentStatCard metodu kaldırıldı

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

        // 3x3 grid için sabit 3 sütun
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) => cards[index],
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
