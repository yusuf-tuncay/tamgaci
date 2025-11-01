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
import '../../../../core/providers/subscription_state_provider.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/providers/currency_providers.dart';
import '../../../../core/providers/company_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user.dart' as auth_domain;
import '../providers/dashboard_providers.dart';
import '../widgets/exchange_rates_widget.dart';
import '../widgets/dashboard_stats_card.dart';
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
  String? _locationName;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _startRealTimeListener();

    // Weather verilerini tekrar yükle
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _loadWeather();
      }
    });
  }

  /// Real-time listener başlat
  void _startRealTimeListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final user = ref.read(currentUserProvider).value;
        if (user != null) {
          // Real-time listener başlat
          ref
              .read(subscriptionStateProvider.notifier)
              .listenToSubscriptionUpdates(user.id);
        }
      }
    });
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
      String defaultLocation = 'İstanbul';

      if (perm != LocationPermission.denied &&
          perm != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low);
        lat = pos.latitude;
        lon = pos.longitude;
      }

      // Open-Meteo free API (no key) - weather data
      final weatherUri = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&timezone=auto');
      final weatherRes =
          await http.get(weatherUri).timeout(const Duration(seconds: 6));

      // Location name (reverse geocoding not available in Open-Meteo free API)
      String locationName = defaultLocation;

      if (weatherRes.statusCode == 200) {
        final data = json.decode(weatherRes.body) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _weather = data['current_weather'] as Map<String, dynamic>?;
            _locationName = locationName;
          });
        }
      }
    } catch (_) {
      // ignore silently
    }
  }

  /// Weather code'larına göre uygun ikonu döndürür
  IconData _getWeatherIcon(int? weatherCode) {
    if (weatherCode == null) return Icons.wb_sunny;

    // WMO Weather interpretation codes (WW)
    switch (weatherCode) {
      // Clear sky - Güneşli
      case 0:
        return Icons.wb_sunny;

      // Mainly clear - Kısmen bulutlu
      case 1:
      case 2:
      case 3:
        return Icons.wb_cloudy;

      // Fog - Sis
      case 45:
      case 48:
        return Icons.foggy;

      // Drizzle - Hafif yağmur
      case 51:
      case 53:
      case 55:
        return Icons.water_drop;

      // Freezing drizzle - Don çiselemesi
      case 56:
      case 57:
        return Icons.ac_unit;

      // Rain - Yağmur
      case 61:
      case 63:
      case 65:
        return Icons.water_drop;

      // Freezing rain - Don yağmuru
      case 66:
      case 67:
        return Icons.ac_unit;

      // Snow fall - Kar
      case 71:
      case 73:
      case 75:
        return Icons.snowing;

      // Snow grains - Kar taneleri
      case 77:
        return Icons.snowing;

      // Rain showers - Sağanak yağmur
      case 80:
      case 81:
      case 82:
        return Icons.water_drop;

      // Snow showers - Sağanak kar
      case 85:
      case 86:
        return Icons.snowing;

      // Thunderstorm - Fırtına
      case 95:
        return Icons.flash_on;

      // Thunderstorm with slight and heavy hail - Dolu ile fırtına
      case 96:
      case 99:
        return Icons.flash_on;

      default:
        return Icons.wb_sunny;
    }
  }

  /// Weather code'larına göre hava durumu açıklamasını döndürür
  String _getWeatherDescription(int? weatherCode) {
    if (weatherCode == null) return 'Hava';

    // WMO Weather interpretation codes (WW)
    switch (weatherCode) {
      // Clear sky
      case 0:
        return 'Açık';

      // Mainly clear
      case 1:
        return 'Çoğunlukla açık';
      case 2:
        return 'Kısmen bulutlu';
      case 3:
        return 'Kapalı';

      // Fog
      case 45:
        return 'Sis';
      case 48:
        return 'Don sisi';

      // Drizzle
      case 51:
        return 'Hafif çiseleme';
      case 53:
        return 'Orta çiseleme';
      case 55:
        return 'Yoğun çiseleme';

      // Freezing drizzle
      case 56:
        return 'Hafif don çiselemesi';
      case 57:
        return 'Yoğun don çiselemesi';

      // Rain
      case 61:
        return 'Hafif yağmur';
      case 63:
        return 'Orta yağmur';
      case 65:
        return 'Yoğun yağmur';

      // Freezing rain
      case 66:
        return 'Hafif don yağmuru';
      case 67:
        return 'Yoğun don yağmuru';

      // Snow fall
      case 71:
        return 'Hafif kar';
      case 73:
        return 'Orta kar';
      case 75:
        return 'Yoğun kar';

      // Snow grains
      case 77:
        return 'Kar taneleri';

      // Rain showers
      case 80:
        return 'Hafif yağmur sağanağı';
      case 81:
        return 'Orta yağmur sağanağı';
      case 82:
        return 'Yoğun yağmur sağanağı';

      // Snow showers
      case 85:
        return 'Hafif kar sağanağı';
      case 86:
        return 'Yoğun kar sağanağı';

      // Thunderstorm
      case 95:
        return 'Fırtına';

      // Thunderstorm with slight and heavy hail
      case 96:
        return 'Dolu ile fırtına';
      case 99:
        return 'Yoğun dolu ile fırtına';

      default:
        return 'Hava';
    }
  }

  /// Sıcaklık bazlı ısı uyarısını döndürür
  Map<String, dynamic>? _getHeatAlert(double? temperature) {
    if (temperature == null) return null;

    // Sıcaklık bazlı uyarı seviyeleri
    if (temperature >= 40) {
      return {
        'message': 'Aşırı sıcak: Güneş koruması ve bol su almayı unutmayın.',
        'type': 'warning',
        'icon': Icons.wb_sunny,
      };
    } else if (temperature >= 35) {
      return {
        'message': 'Çok sıcak: Şapka, güneş gözlüğü ve su alın.',
        'type': 'info',
        'icon': Icons.wb_sunny,
      };
    } else if (temperature >= 30) {
      return {
        'message': 'Sıcak hava: Güneş koruması almanızı öneririz.',
        'type': 'info',
        'icon': Icons.wb_sunny,
      };
    } else if (temperature <= -10) {
      return {
        'message':
            'Aşırı soğuk: Sıcak giyinmeyi ve kapalı alanda kalmayı unutmayın.',
        'type': 'warning',
        'icon': Icons.ac_unit,
      };
    } else if (temperature <= -5) {
      return {
        'message': 'Çok soğuk: Kalın giysiler ve sıcak içecekler alın.',
        'type': 'info',
        'icon': Icons.ac_unit,
      };
    } else if (temperature <= 0) {
      return {
        'message': 'Soğuk hava: Sıcak giyinmeyi unutmayın.',
        'type': 'info',
        'icon': Icons.ac_unit,
      };
    }

    return null;
  }

  /// Weather code'larına göre uyarı mesajını döndürür
  Map<String, dynamic>? _getWeatherAlert(int? weatherCode) {
    if (weatherCode == null) return null;

    // WMO Weather interpretation codes (WW)
    switch (weatherCode) {
      // Clear sky - Sunny day tips
      case 0:
        return {
          'message': 'Güneşli hava: Güneş gözlüğü ve şapka almayı unutmayın.',
          'type': 'info',
          'icon': Icons.wb_sunny,
        };

      // Mainly clear - Partly cloudy tips
      case 1:
      case 2:
      case 3:
        return {
          'message': 'Kısmen bulutlu: Güneş koruması almanızı öneririz.',
          'type': 'info',
          'icon': Icons.wb_cloudy,
        };

      // Fog - Gentle fog advice
      case 45:
      case 48:
        return {
          'message': 'Sisli hava: Araç kullanırken dikkatli olun.',
          'type': 'info',
          'icon': Icons.foggy,
        };

      // Drizzle - Light rain advice
      case 51:
      case 53:
      case 55:
        return {
          'message': 'Hafif yağış: Şemsiyenizi yanınıza alın.',
          'type': 'info',
          'icon': Icons.umbrella,
        };

      // Freezing drizzle - Gentle ice advice
      case 56:
      case 57:
        return {
          'message': 'Don çiselemesi: Yürürken dikkatli olun.',
          'type': 'info',
          'icon': Icons.ac_unit,
        };

      // Rain - Gentle rain advice
      case 61:
      case 63:
      case 65:
        return {
          'message': 'Yağmurlu hava: Şemsiye ve yağmurluk almayı unutmayın.',
          'type': 'info',
          'icon': Icons.umbrella,
        };

      // Freezing rain - Gentle ice advice
      case 66:
      case 67:
        return {
          'message': 'Don yağmuru: Kaygan yollarda dikkatli olun.',
          'type': 'warning',
          'icon': Icons.warning_amber,
        };

      // Snow fall - Gentle snow advice
      case 71:
      case 73:
      case 75:
        return {
          'message':
              'Karlı hava: Sıcak giyinmeyi ve kar lastiği almayı unutmayın.',
          'type': 'info',
          'icon': Icons.snowing,
        };

      // Snow grains - Gentle snow advice
      case 77:
        return {
          'message': 'Hafif kar: Sıcak giyinmeyi unutmayın.',
          'type': 'info',
          'icon': Icons.snowing,
        };

      // Rain showers - Gentle rain advice
      case 80:
      case 81:
      case 82:
        return {
          'message': 'Sağanak yağmur: Şemsiye ve su geçirmez kıyafet alın.',
          'type': 'warning',
          'icon': Icons.umbrella,
        };

      // Snow showers - Gentle snow advice
      case 85:
      case 86:
        return {
          'message':
              'Sağanak kar: Sıcak giyinmeyi ve dikkatli sürüş yapmayı unutmayın.',
          'type': 'warning',
          'icon': Icons.snowing,
        };

      // Thunderstorm - Gentle storm advice
      case 95:
        return {
          'message': 'Fırtınalı hava: Güvenli bir yerde bekleyin.',
          'type': 'warning',
          'icon': Icons.flash_on,
        };

      // Thunderstorm with hail - Gentle storm advice
      case 96:
      case 99:
        return {
          'message': 'Dolu ile fırtına: Kapalı alanda bekleyin.',
          'type': 'warning',
          'icon': Icons.warning_amber,
        };

      default:
        return null;
    }
  }

  /// Weather code'larına göre gradient renklerini döndürür
  List<Color> _getWeatherGradientColors(int? weatherCode) {
    if (weatherCode == null) {
      // Default sunny gradient
      return [
        Colors.orange.shade300,
        Colors.orange.shade500,
      ];
    }

    // WMO Weather interpretation codes (WW)
    switch (weatherCode) {
      // Clear sky - Sunny gradient
      case 0:
        return [
          Colors.orange.shade300,
          Colors.orange.shade500,
        ];

      // Mainly clear - Light blue gradient
      case 1:
      case 2:
      case 3:
        return [
          Colors.lightBlue.shade300,
          Colors.lightBlue.shade500,
        ];

      // Fog - Gray gradient
      case 45:
      case 48:
        return [
          Colors.grey.shade400,
          Colors.grey.shade600,
        ];

      // Drizzle - Blue gradient
      case 51:
      case 53:
      case 55:
        return [
          Colors.blue.shade300,
          Colors.blue.shade500,
        ];

      // Freezing drizzle - Cyan gradient
      case 56:
      case 57:
        return [
          Colors.cyan.shade300,
          Colors.cyan.shade500,
        ];

      // Rain - Dark blue gradient
      case 61:
      case 63:
      case 65:
        return [
          Colors.blue.shade400,
          Colors.blue.shade600,
        ];

      // Freezing rain - Cyan gradient
      case 66:
      case 67:
        return [
          Colors.cyan.shade400,
          Colors.cyan.shade600,
        ];

      // Snow fall - White gradient
      case 71:
      case 73:
      case 75:
        return [
          Colors.white.withValues(alpha: 0.8),
          Colors.blue.shade100,
        ];

      // Snow grains - Light white gradient
      case 77:
        return [
          Colors.white.withValues(alpha: 0.6),
          Colors.blue.shade50,
        ];

      // Rain showers - Indigo gradient
      case 80:
      case 81:
      case 82:
        return [
          Colors.indigo.shade400,
          Colors.indigo.shade600,
        ];

      // Snow showers - Light white gradient
      case 85:
      case 86:
        return [
          Colors.white.withValues(alpha: 0.7),
          Colors.blue.shade200,
        ];

      // Thunderstorm - Purple gradient
      case 95:
        return [
          Colors.purple.shade400,
          Colors.purple.shade600,
        ];

      // Thunderstorm with hail - Dark purple gradient
      case 96:
      case 99:
        return [
          Colors.deepPurple.shade500,
          Colors.deepPurple.shade700,
        ];

      default:
        // Default sunny gradient
        return [
          Colors.orange.shade300,
          Colors.orange.shade500,
        ];
    }
  }

  /// Weather code'larına göre renk temasını döndürür
  Map<String, Color> _getWeatherColors(int? weatherCode) {
    if (weatherCode == null) {
      // Default sunny theme
      return {
        'border': Colors.orange.withValues(alpha: 0.6),
        'shadow': Colors.orange.withValues(alpha: 0.3),
      };
    }

    // WMO Weather interpretation codes (WW)
    switch (weatherCode) {
      // Clear sky - Sunny theme
      case 0:
        return {
          'border': Colors.orange.withValues(alpha: 0.6),
          'shadow': Colors.orange.withValues(alpha: 0.3),
        };

      // Mainly clear - Light blue theme
      case 1:
      case 2:
      case 3:
        return {
          'border': Colors.lightBlue.withValues(alpha: 0.6),
          'shadow': Colors.lightBlue.withValues(alpha: 0.3),
        };

      // Fog - Gray theme
      case 45:
      case 48:
        return {
          'border': Colors.grey.withValues(alpha: 0.6),
          'shadow': Colors.grey.withValues(alpha: 0.3),
        };

      // Drizzle - Light blue theme
      case 51:
      case 53:
      case 55:
        return {
          'border': Colors.blue.withValues(alpha: 0.5),
          'shadow': Colors.blue.withValues(alpha: 0.2),
        };

      // Freezing drizzle - Light cyan theme
      case 56:
      case 57:
        return {
          'border': Colors.cyan.withValues(alpha: 0.6),
          'shadow': Colors.cyan.withValues(alpha: 0.3),
        };

      // Rain - Blue theme
      case 61:
      case 63:
      case 65:
        return {
          'border': Colors.blue.withValues(alpha: 0.7),
          'shadow': Colors.blue.withValues(alpha: 0.4),
        };

      // Freezing rain - Cyan theme
      case 66:
      case 67:
        return {
          'border': Colors.cyan.withValues(alpha: 0.7),
          'shadow': Colors.cyan.withValues(alpha: 0.4),
        };

      // Snow fall - White theme
      case 71:
      case 73:
      case 75:
        return {
          'border': Colors.white.withValues(alpha: 0.8),
          'shadow': Colors.white.withValues(alpha: 0.5),
        };

      // Snow grains - Light white theme
      case 77:
        return {
          'border': Colors.white.withValues(alpha: 0.7),
          'shadow': Colors.white.withValues(alpha: 0.4),
        };

      // Rain showers - Dark blue theme
      case 80:
      case 81:
      case 82:
        return {
          'border': Colors.indigo.withValues(alpha: 0.7),
          'shadow': Colors.indigo.withValues(alpha: 0.4),
        };

      // Snow showers - Light white theme
      case 85:
      case 86:
        return {
          'border': Colors.white.withValues(alpha: 0.6),
          'shadow': Colors.white.withValues(alpha: 0.3),
        };

      // Thunderstorm - Purple theme
      case 95:
        return {
          'border': Colors.purple.withValues(alpha: 0.7),
          'shadow': Colors.purple.withValues(alpha: 0.4),
        };

      // Thunderstorm with hail - Dark purple theme
      case 96:
      case 99:
        return {
          'border': Colors.deepPurple.withValues(alpha: 0.8),
          'shadow': Colors.deepPurple.withValues(alpha: 0.5),
        };

      default:
        // Default sunny theme
        return {
          'border': Colors.orange.withValues(alpha: 0.6),
          'shadow': Colors.orange.withValues(alpha: 0.3),
        };
    }
  }

  /// Uyarı tipine göre renk döndürür
  Color _getAlertColor(String alertType) {
    return Colors.white; // Tüm uyarı mesajları beyaz
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
              onPressed: () => context.go('/settings/subscription'),
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
              onPressed: () => context.go('/settings/subscription'),
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
                onPressed: () => context.go('/settings/subscription'),
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

            // Weather Row (full width) - Mobile optimized
            _buildWeatherRowMobile(isDark),

            const SizedBox(height: 16),
            _buildQuickActions(isDark),
            const SizedBox(height: 16),
            // Stats Grid (full width on mobile)
            _buildStatsGrid(dashboardSummaryAsync, isDark),
            const SizedBox(height: 16),
            // Exchange Rates (below stats on mobile)
            const ExchangeRatesWidget(),
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

            const SizedBox(height: 16),

            // Weather Row (full width)
            _buildWeatherRow(isDark),

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

            const SizedBox(height: 16),

            // Weather Row (full width)
            _buildWeatherRow(isDark),

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
        ],
      ),
    );
  }

  Widget _buildWeatherRow(bool isDark) {
    // Weather verisi yoksa loading göster
    if (_weather == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange, Colors.orange],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.wb_sunny,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hava durumu yükleniyor...',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'İstanbul',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getWeatherGradientColors(
              _weather != null ? _weather!['weathercode'] as int? : null),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getWeatherColors(_weather != null
              ? _weather!['weathercode'] as int?
              : null)['border']!,
        ),
        boxShadow: [
          BoxShadow(
            color: _getWeatherColors(_weather != null
                ? _weather!['weathercode'] as int?
                : null)['shadow']!,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Weather Icon
          Icon(
            _getWeatherIcon(
                _weather != null ? _weather!['weathercode'] as int? : null),
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          // Weather Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Temperature and Description
                Row(
                  children: [
                    Text(
                      _weather != null
                          ? '${_weather!['temperature']}°C'
                          : 'Hava',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getWeatherDescription(_weather != null
                          ? _weather!['weathercode'] as int?
                          : null),
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Weather Alert (if exists) - Desktop
                if (_getWeatherAlert(_weather != null
                            ? _weather!['weathercode'] as int?
                            : null) !=
                        null ||
                    _getHeatAlert(_weather != null
                            ? (_weather!['temperature'] as num?)?.toDouble()
                            : null) !=
                        null)
                  Text(
                    _getWeatherAlert(_weather != null
                                ? _weather!['weathercode'] as int?
                                : null) !=
                            null
                        ? _getWeatherAlert(_weather != null
                            ? _weather!['weathercode'] as int?
                            : null)!['message']
                        : _getHeatAlert(_weather != null
                            ? (_weather!['temperature'] as num?)?.toDouble()
                            : null)!['message'],
                    style: GoogleFonts.poppins(
                      color: _getAlertColor(_getWeatherAlert(_weather != null
                                  ? _weather!['weathercode'] as int?
                                  : null) !=
                              null
                          ? _getWeatherAlert(_weather != null
                              ? _weather!['weathercode'] as int?
                              : null)!['type']
                          : _getHeatAlert(_weather != null
                              ? (_weather!['temperature'] as num?)?.toDouble()
                              : null)!['type']),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                const SizedBox(height: 4),
                // Location
                Text(
                  _locationName ?? 'İstanbul',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherRowMobile(bool isDark) {
    // Weather verisi yoksa loading göster
    if (_weather == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange, Colors.orange],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.wb_sunny,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hava durumu yükleniyor...',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'İstanbul',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getWeatherGradientColors(
              _weather != null ? _weather!['weathercode'] as int? : null),
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getWeatherColors(_weather != null
              ? _weather!['weathercode'] as int?
              : null)['border']!,
        ),
        boxShadow: [
          BoxShadow(
            color: _getWeatherColors(_weather != null
                ? _weather!['weathercode'] as int?
                : null)['shadow']!,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Weather Icon
          Icon(
            _getWeatherIcon(
                _weather != null ? _weather!['weathercode'] as int? : null),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          // Weather Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Temperature and Description
                Row(
                  children: [
                    Text(
                      _weather != null
                          ? '${_weather!['temperature']}°C'
                          : 'Hava',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getWeatherDescription(_weather != null
                            ? _weather!['weathercode'] as int?
                            : null),
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Weather Alert (if exists) - Mobile
                if (_getWeatherAlert(_weather != null
                            ? _weather!['weathercode'] as int?
                            : null) !=
                        null ||
                    _getHeatAlert(_weather != null
                            ? (_weather!['temperature'] as num?)?.toDouble()
                            : null) !=
                        null)
                  Text(
                    _getWeatherAlert(_weather != null
                                ? _weather!['weathercode'] as int?
                                : null) !=
                            null
                        ? _getWeatherAlert(_weather != null
                            ? _weather!['weathercode'] as int?
                            : null)!['message']
                        : _getHeatAlert(_weather != null
                            ? (_weather!['temperature'] as num?)?.toDouble()
                            : null)!['message'],
                    style: GoogleFonts.poppins(
                      color: _getAlertColor(_getWeatherAlert(_weather != null
                                  ? _weather!['weathercode'] as int?
                                  : null) !=
                              null
                          ? _getWeatherAlert(_weather != null
                              ? _weather!['weathercode'] as int?
                              : null)!['type']
                          : _getHeatAlert(_weather != null
                              ? (_weather!['temperature'] as num?)?.toDouble()
                              : null)!['type']),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                const SizedBox(height: 2),
                // Location
                Text(
                  _locationName ?? 'İstanbul',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white, // Beyaz
            Colors.grey.shade100, // Açık gri
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İşlemler',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              return SizedBox(
                height: isMobile ? 60 : 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildActionCardHorizontal(
                        isMobile ? 'Fatura' : 'Fatura Oluştur',
                        Icons.receipt_long,
                        TamgaciConstants.primaryColor, () {
                      context.pushNamed('invoices-list');
                    }, isDark),
                    const SizedBox(width: 12),
                    _buildActionCardHorizontal(isMobile ? 'Ürün' : 'Ürün Ekle',
                        Icons.inventory_2, Colors.orange, () {
                      context.pushNamed('create-product');
                    }, isDark),
                    const SizedBox(width: 12),
                    _buildActionCardHorizontal(
                        isMobile ? 'Müşteri' : 'Müşteri Ekle',
                        Icons.person_add,
                        Colors.blue, () {
                      context.pushNamed('create-customer');
                    }, isDark),
                    const SizedBox(width: 12),
                    _buildActionCardHorizontal(
                        isMobile ? 'Stok' : 'Stok İşlemi',
                        Icons.warehouse,
                        Colors.green, () {
                      context.pushNamed('inventory');
                    }, isDark),
                    const SizedBox(width: 12),
                    _buildActionCardHorizontal(
                        isMobile ? 'Depo' : 'Depo Listesi',
                        Icons.list,
                        Colors.indigo, () {
                      context.pushNamed('warehouses-home');
                    }, isDark),
                    const SizedBox(width: 12),
                    _buildActionCardHorizontal(
                        isMobile ? 'Stok Listesi' : 'Stok Listesi',
                        Icons.inventory,
                        Colors.teal, () {
                      context.pushNamed('stock-list');
                    }, isDark),
                    const SizedBox(width: 12),
                    _buildActionCardHorizontal(
                        isMobile ? 'Test' : 'Logger Test',
                        Icons.color_lens,
                        Colors.pink, () {
                      context.pushNamed('colorized-logger-test');
                    }, isDark),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Yatay kaydırılabilir action card
  Widget _buildActionCardHorizontal(String title, IconData icon, Color color,
      VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.8), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white, // Beyaz
            Colors.grey.shade100, // Açık gri
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İşlemler',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildActionCardHorizontal('Fatura', Icons.receipt, Colors.blue,
                    () => context.pushNamed('invoices-list'), isDark),
                const SizedBox(width: 8),
                _buildActionCardHorizontal(
                    'Alış',
                    Icons.shopping_cart,
                    Colors.orange,
                    () => context.pushNamed('purchases-list'),
                    isDark),
                const SizedBox(width: 8),
                _buildActionCardHorizontal(
                    'Müşteri',
                    Icons.person_add,
                    Colors.green,
                    () => context.pushNamed('create-customer'),
                    isDark),
                const SizedBox(width: 8),
                _buildActionCardHorizontal('Ürün', Icons.add_box, Colors.orange,
                    () => context.pushNamed('create-product'), isDark),
                const SizedBox(width: 8),
                _buildActionCardHorizontal('Stok', Icons.warehouse, Colors.teal,
                    () => context.pushNamed('inventory'), isDark),
                const SizedBox(width: 8),
                _buildActionCardHorizontal('Depo', Icons.list, Colors.indigo,
                    () => context.pushNamed('warehouses-home'), isDark),
                const SizedBox(width: 8),
                _buildActionCardHorizontal('Rapor', Icons.analytics,
                    Colors.pink, () => context.pushNamed('dashboard'), isDark),
                const SizedBox(width: 8),
                _buildActionCardHorizontal('Ayarlar', Icons.settings,
                    Colors.grey, () => context.go('/settings'), isDark),
              ],
            ),
          ),
        ],
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
            iconColor: Colors.amber,
            backgroundColor: Colors.amber,
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
            iconColor: Colors.cyan,
            backgroundColor: Colors.cyan,
          ),
          DashboardStatsCard(
            title: 'Kritik Stok',
            value: summary.criticalStockCount.toDouble(),
            currency: '',
            subtitle: 'ürün',
            icon: Icons.warning,
            iconColor: Colors.deepOrange,
            backgroundColor: Colors.deepOrange,
          ),
          DashboardStatsCard(
            title: 'Toplam Müşteri',
            value: summary.totalCustomers.toDouble(),
            currency: '',
            subtitle: 'kişi',
            icon: Icons.people,
            iconColor: Colors.deepPurple,
            backgroundColor: Colors.deepPurple,
          ),
          DashboardStatsCard(
            title: 'Bekleyen Tahsilat',
            value: summary.pendingReceivables,
            currency: 'TRY',
            icon: Icons.download,
            iconColor: Colors.lightGreen,
            backgroundColor: Colors.lightGreen,
          ),
          DashboardStatsCard(
            title: 'Bekleyen Ödeme',
            value: summary.pendingPayables,
            currency: 'TRY',
            icon: Icons.upload,
            iconColor: Colors.pink,
            backgroundColor: Colors.pink,
          ),
        ];

        // Responsive grid - mobilde 2 sütun, desktop'ta 3 sütun
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: isMobile ? 1.2 : 1.1,
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
