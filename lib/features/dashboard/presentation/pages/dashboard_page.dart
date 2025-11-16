// ========== DASHBOARD PAGE ==========
// lib/features/dashboard/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
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
  DateTime? _sunrise;
  DateTime? _sunset;
  Timer? _dayNightUpdateTimer;

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

    // Gece/gündüz durumunu her dakika güncelle (animasyon için)
    _dayNightUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // Sadece state'i güncelle, API çağrısı yapma
        });
      }
    });
  }

  @override
  void dispose() {
    _dayNightUpdateTimer?.cancel();
    super.dispose();
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

      // Open-Meteo free API (no key) - weather data with additional parameters
      final weatherUri = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=relativehumidity_2m&daily=sunrise,sunset&timezone=auto');
      final weatherRes =
          await http.get(weatherUri).timeout(const Duration(seconds: 6));

      // Location name (reverse geocoding not available in Open-Meteo free API)
      String locationName = defaultLocation;

      if (weatherRes.statusCode == 200) {
        final data = json.decode(weatherRes.body) as Map<String, dynamic>;
        if (mounted) {
          final currentWeather = data['current_weather'] as Map<String, dynamic>?;
          final hourly = data['hourly'] as Map<String, dynamic>?;
          final daily = data['daily'] as Map<String, dynamic>?;
          
          // Get current hour index for humidity
          int? humidity;
          if (hourly != null && hourly['relativehumidity_2m'] != null) {
            final humidityList = hourly['relativehumidity_2m'] as List<dynamic>?;
            if (humidityList != null && humidityList.isNotEmpty) {
              // Get first hour (current hour) humidity
              humidity = (humidityList[0] as num?)?.toInt();
            }
          }
          
          // Get sunrise and sunset times
          DateTime? sunrise;
          DateTime? sunset;
          if (daily != null) {
            final sunriseList = daily['sunrise'] as List<dynamic>?;
            final sunsetList = daily['sunset'] as List<dynamic>?;
            if (sunriseList != null && sunriseList.isNotEmpty) {
              try {
                final sunriseStr = sunriseList[0] as String?;
                if (sunriseStr != null) {
                  // Parse ISO 8601 format (e.g., "2024-01-15T07:30" or "2024-01-15T07:30Z")
                  DateTime parsedSunrise = DateTime.parse(sunriseStr);
                  // Convert to local timezone if it's UTC
                  if (parsedSunrise.isUtc) {
                    parsedSunrise = parsedSunrise.toLocal();
                  }
                  // Store only the time part (hour and minute) for today's date
                  sunrise = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    parsedSunrise.hour,
                    parsedSunrise.minute,
                  );
                }
              } catch (_) {
                // ignore parsing errors
              }
            }
            if (sunsetList != null && sunsetList.isNotEmpty) {
              try {
                final sunsetStr = sunsetList[0] as String?;
                if (sunsetStr != null) {
                  // Parse ISO 8601 format (e.g., "2024-01-15T18:45" or "2024-01-15T18:45Z")
                  DateTime parsedSunset = DateTime.parse(sunsetStr);
                  // Convert to local timezone if it's UTC
                  if (parsedSunset.isUtc) {
                    parsedSunset = parsedSunset.toLocal();
                  }
                  // Store only the time part (hour and minute) for today's date
                  sunset = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    parsedSunset.hour,
                    parsedSunset.minute,
                  );
                }
              } catch (_) {
                // ignore parsing errors
              }
            }
          }
          
          // Merge weather data with additional info
          final weatherData = <String, dynamic>{
            if (currentWeather != null) ...currentWeather,
            if (humidity != null) 'humidity': humidity,
          };
          
          setState(() {
            _weather = weatherData.isNotEmpty ? weatherData : null;
            _locationName = locationName;
            _sunrise = sunrise;
            _sunset = sunset;
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

  /// Gece mi gündüz mü olduğunu kontrol eder (konum ve saate göre)
  bool _isNightTime() {
    final now = DateTime.now();
    if (_sunrise == null || _sunset == null) {
      // Eğer güneş doğuş/batış bilgisi yoksa, saat bazlı tahmin yap
      final hour = now.hour;
      return hour < 6 || hour >= 20; // 20:00-06:00 arası gece kabul et
    }
    
    // Güneş doğuş ve batış saatlerini bugünün tarihi ile birleştir
    final today = DateTime(now.year, now.month, now.day);
    final todaySunrise = DateTime(
      today.year,
      today.month,
      today.day,
      _sunrise!.hour,
      _sunrise!.minute,
    );
    final todaySunset = DateTime(
      today.year,
      today.month,
      today.day,
      _sunset!.hour,
      _sunset!.minute,
    );
    
    // Güneş batışından 30 dakika önce ve güneş doğuşundan 30 dakika sonra gece kabul et
    final sunsetWithMargin = todaySunset.subtract(const Duration(minutes: 30));
    final sunriseWithMargin = todaySunrise.add(const Duration(minutes: 30));
    
    // Eğer şu an güneş batışından sonra veya güneş doğuşundan önceyse gece
    if (now.isAfter(sunsetWithMargin)) {
      return true; // Güneş batışından sonra = gece
    }
    if (now.isBefore(sunriseWithMargin)) {
      return true; // Güneş doğuşundan önce = gece
    }
    
    return false; // Gündüz
  }

  /// Gece/gündüz durumunu metin olarak döndürür
  String _getDayNightStatus() {
    final isNight = _isNightTime();
    if (_sunrise != null && _sunset != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      if (isNight) {
        // Gece ise, güneş doğuşuna ne kadar kaldığını göster
        var nextSunrise = DateTime(
          today.year,
          today.month,
          today.day,
          _sunrise!.hour,
          _sunrise!.minute,
        );
        // Eğer bugünün güneş doğuşu geçmişse, yarının güneş doğuşunu kullan
        if (nextSunrise.isBefore(now)) {
          nextSunrise = nextSunrise.add(const Duration(days: 1));
        }
        final timeUntilSunrise = nextSunrise.difference(now);
        if (timeUntilSunrise.inHours < 24 && timeUntilSunrise.inMinutes > 0) {
          final hours = timeUntilSunrise.inHours;
          final minutes = timeUntilSunrise.inMinutes % 60;
          if (hours > 0) {
            return 'Gece • Güneş $hours saat $minutes dakika sonra doğacak';
          } else if (minutes > 0) {
            return 'Gece • Güneş $minutes dakika sonra doğacak';
          }
        }
        return 'Gece';
      } else {
        // Gündüz ise, güneş batışına ne kadar kaldığını göster
        var nextSunset = DateTime(
          today.year,
          today.month,
          today.day,
          _sunset!.hour,
          _sunset!.minute,
        );
        // Eğer bugünün güneş batışı geçmişse, yarının güneş batışını kullan
        if (nextSunset.isBefore(now)) {
          nextSunset = nextSunset.add(const Duration(days: 1));
        }
        final timeUntilSunset = nextSunset.difference(now);
        if (timeUntilSunset.inHours < 24 && timeUntilSunset.inMinutes > 0) {
          final hours = timeUntilSunset.inHours;
          final minutes = timeUntilSunset.inMinutes % 60;
          if (hours > 0) {
            return 'Gündüz • Güneş $hours saat $minutes dakika sonra batacak';
          } else if (minutes > 0) {
            return 'Gündüz • Güneş $minutes dakika sonra batacak';
          }
        }
        return 'Gündüz';
      }
    }
    return isNight ? 'Gece' : 'Gündüz';
  }

  /// Hava durumu, sıcaklık, rüzgar ve nemi göz önünde bulundurarak entegre uyarı döndürür
  Map<String, dynamic>? _getIntegratedWeatherAlert(
    int? weatherCode,
    double? temperature,
    double? windSpeed,
    int? humidity,
  ) {
    if (weatherCode == null || temperature == null) return null;
    
    final isNight = _isNightTime();

    // Rüzgar hızı kontrolü (km/h cinsinden)
    final isWindy = windSpeed != null && windSpeed > 30; // 30 km/h üzeri rüzgarlı
    final isVeryWindy = windSpeed != null && windSpeed > 50; // 50 km/h üzeri çok rüzgarlı

    // Nem kontrolü
    final isHumid = humidity != null && humidity > 70; // %70 üzeri nemli
    final isVeryHumid = humidity != null && humidity > 85; // %85 üzeri çok nemli

    // Sıcaklık kategorileri
    final isExtremelyHot = temperature >= 40;
    final isVeryHot = temperature >= 35;
    final isHot = temperature >= 30;
    final isWarm = temperature >= 20;
    final isMild = temperature >= 10;
    final isCool = temperature >= 5;
    final isCold = temperature >= 0;
    final isVeryCold = temperature >= -5;
    final isExtremelyCold = temperature < -5;

    // Hava durumu kodlarına göre temel durum
    final isClear = weatherCode == 0;
    final isPartlyCloudy = weatherCode >= 1 && weatherCode <= 3;
    final isFoggy = weatherCode == 45 || weatherCode == 48;
    final isDrizzling = weatherCode >= 51 && weatherCode <= 55;
    final isFreezingDrizzle = weatherCode == 56 || weatherCode == 57;
    final isRaining = weatherCode >= 61 && weatherCode <= 65;
    final isFreezingRain = weatherCode == 66 || weatherCode == 67;
    final isSnowing = weatherCode >= 71 && weatherCode <= 77;
    final isRainShower = weatherCode >= 80 && weatherCode <= 82;
    final isSnowShower = weatherCode == 85 || weatherCode == 86;
    final isThunderstorm = weatherCode == 95;
    final isThunderstormWithHail = weatherCode == 96 || weatherCode == 99;

    // Entegre uyarı mantığı
    // 1. Önce kritik durumlar (fırtına, dolu, don yağmuru)
    if (isThunderstormWithHail) {
      return {
        'message': 'Dolu ile fırtına: Mutlaka kapalı alanda bekleyin.',
        'type': 'warning',
        'icon': Icons.warning_amber,
      };
    }
    if (isThunderstorm) {
      return {
        'message': 'Fırtınalı hava: Güvenli bir yerde bekleyin.',
        'type': 'warning',
        'icon': Icons.flash_on,
      };
    }
    if (isFreezingRain) {
      return {
        'message': 'Don yağmuru: Kaygan yollarda dikkatli olun.',
        'type': 'warning',
        'icon': Icons.warning_amber,
      };
    }
    if (isFreezingDrizzle) {
      return {
        'message': 'Don çiselemesi: Yürürken dikkatli olun.',
        'type': 'info',
        'icon': Icons.ac_unit,
      };
    }

    // 2. Kar durumları
    if (isSnowShower) {
      String message = 'Sağanak kar: Sıcak giyinmeyi ve dikkatli sürüş yapmayı unutmayın.';
      if (isExtremelyCold) {
        message = 'Sağanak kar ve aşırı soğuk: Kalın giysiler ve kapalı alanda kalmayı unutmayın.';
      } else if (isVeryCold) {
        message = 'Sağanak kar ve çok soğuk: Sıcak giyinmeyi unutmayın.';
      }
      return {
        'message': message,
        'type': 'warning',
        'icon': Icons.snowing,
      };
    }
    if (isSnowing) {
      String message = 'Karlı hava: Sıcak giyinmeyi unutmayın.';
      if (isExtremelyCold) {
        message = 'Karlı ve aşırı soğuk hava: Kalın giysiler ve sıcak içecekler alın.';
      } else if (isVeryCold) {
        message = 'Karlı ve soğuk hava: Sıcak giyinmeyi unutmayın.';
      }
      return {
        'message': message,
        'type': 'info',
        'icon': Icons.snowing,
      };
    }

    // 3. Yağmur durumları
    if (isRainShower) {
      String message = 'Sağanak yağmur: Şemsiye ve su geçirmez kıyafet alın.';
      if (isCold || isVeryCold || isExtremelyCold) {
        message = 'Sağanak yağmur ve soğuk: Şemsiye ve sıcak giysiler alın.';
      } else if (isVeryWindy) {
        message = 'Sağanak yağmur ve güçlü rüzgar: Şemsiye ve dikkatli olun.';
      }
      return {
        'message': message,
        'type': 'warning',
        'icon': Icons.umbrella,
      };
    }
    if (isRaining) {
      String message = 'Yağmurlu hava: Şemsiye ve yağmurluk almayı unutmayın.';
      if (isCold || isVeryCold || isExtremelyCold) {
        message = 'Yağmurlu ve soğuk hava: Şemsiye ve sıcak giysiler alın.';
      } else if (isVeryWindy) {
        message = 'Yağmurlu ve rüzgarlı hava: Şemsiye ve dikkatli olun.';
      }
      return {
        'message': message,
        'type': 'info',
        'icon': Icons.umbrella,
      };
    }
    if (isDrizzling) {
      String message = 'Hafif yağış: Şemsiyenizi yanınıza alın.';
      if (isCold || isVeryCold || isExtremelyCold) {
        message = 'Hafif yağış ve soğuk: Şemsiye ve sıcak giysiler alın.';
      }
      return {
        'message': message,
        'type': 'info',
        'icon': Icons.umbrella,
      };
    }

    // 4. Sis durumu
    if (isFoggy) {
      String message = 'Sisli hava: Araç kullanırken dikkatli olun.';
      if (isCold || isVeryCold || isExtremelyCold) {
        message = 'Sisli ve soğuk hava: Araç kullanırken dikkatli olun, sıcak giyinmeyi unutmayın.';
      }
      return {
        'message': message,
        'type': 'info',
        'icon': Icons.foggy,
      };
    }

    // 5. Açık ve kısmen bulutlu hava - sıcaklığa göre öneriler
    if (isClear) {
      // Aşırı sıcak
      if (isExtremelyHot) {
        String message = isNight
            ? 'Berrak gece ve aşırı sıcak: Bol su almayı unutmayın.'
            : 'Aşırı sıcak ve güneşli: Güneş koruması ve bol su almayı unutmayın.';
        if (isVeryHumid) {
          message = isNight
              ? 'Berrak gece, aşırı sıcak ve nemli: Bol su ve serin yerlerde kalın.'
              : 'Aşırı sıcak, güneşli ve nemli: Güneş koruması, bol su ve serin yerlerde kalın.';
        } else if (isHumid) {
          message = isNight
              ? 'Berrak gece ve nemli: Bol su almayı unutmayın.'
              : 'Aşırı sıcak ve nemli: Güneş koruması ve bol su almayı unutmayın.';
        }
        return {
          'message': message,
          'type': 'warning',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_sunny,
        };
      }
      // Çok sıcak
      if (isVeryHot) {
        String message = isNight
            ? 'Berrak gece ve çok sıcak: Su almayı unutmayın.'
            : 'Çok sıcak ve güneşli: Şapka, güneş gözlüğü ve su alın.';
        if (isVeryHumid) {
          message = isNight
              ? 'Berrak gece, sıcak ve nemli: Su ve serin yerlerde kalın.'
              : 'Çok sıcak, güneşli ve nemli: Şapka, güneş gözlüğü, su ve serin yerlerde kalın.';
        } else if (isHumid) {
          message = isNight
              ? 'Berrak gece ve nemli: Su almayı unutmayın.'
              : 'Çok sıcak ve nemli: Şapka, güneş gözlüğü ve su alın.';
        }
        return {
          'message': message,
          'type': 'info',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_sunny,
        };
      }
      // Sıcak
      if (isHot) {
        String message = isNight
            ? 'Berrak gece ve sıcak: Keyifli bir gece!'
            : 'Sıcak ve güneşli hava: Güneş koruması almanızı öneririz.';
        if (isVeryHumid) {
          message = isNight
              ? 'Berrak gece, sıcak ve nemli: Su almayı unutmayın.'
              : 'Sıcak, güneşli ve nemli: Güneş koruması ve su almayı unutmayın.';
        } else if (isHumid) {
          message = isNight
              ? 'Berrak gece ve nemli: Keyifli bir gece!'
              : 'Sıcak ve nemli: Güneş koruması almanızı öneririz.';
        }
        return {
          'message': message,
          'type': 'info',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_sunny,
        };
      }
      // Ilık
      if (isWarm) {
        String message = isNight
            ? 'Berrak gece ve ılık: Keyifli bir gece!'
            : 'Güneşli ve ılık hava: Keyifli bir gün!';
        if (isVeryWindy) {
          message = isNight
              ? 'Berrak gece ama rüzgarlı: Hafif bir ceket alabilirsiniz.'
              : 'Güneşli ama rüzgarlı: Hafif bir ceket alabilirsiniz.';
        } else if (isWindy) {
          message = isNight
              ? 'Berrak gece ve hafif rüzgarlı: Keyifli bir gece!'
              : 'Güneşli ve hafif rüzgarlı: Keyifli bir gün!';
        }
        return {
          'message': message,
          'type': 'info',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_sunny,
        };
      }
      // Serin
      if (isMild) {
        String message = isNight
            ? 'Berrak gece ama serin: Hafif bir ceket almanızı öneririz.'
            : 'Açık ama serin hava: Hafif bir ceket almanızı öneririz.';
        if (isVeryWindy) {
          message = isNight
              ? 'Berrak gece, rüzgarlı ve serin: Ceket almanızı öneririz.'
              : 'Açık ama rüzgarlı ve serin: Ceket almanızı öneririz.';
        } else if (isWindy) {
          message = isNight
              ? 'Berrak gece ama rüzgarlı: Hafif bir ceket almanızı öneririz.'
              : 'Açık ama rüzgarlı: Hafif bir ceket almanızı öneririz.';
        }
        return {
          'message': message,
          'type': 'info',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_sunny,
        };
      }
      // Soğuk
      if (isCool) {
        String message = isNight
            ? 'Berrak gece ama soğuk: Sıcak giyinmeyi unutmayın.'
            : 'Açık ama soğuk hava: Sıcak giyinmeyi unutmayın.';
        if (isVeryWindy) {
          message = isNight
              ? 'Berrak gece, rüzgarlı ve soğuk: Kalın giysiler almanızı öneririz.'
              : 'Açık ama rüzgarlı ve soğuk: Kalın giysiler almanızı öneririz.';
        } else if (isWindy) {
          message = isNight
              ? 'Berrak gece, rüzgarlı ve soğuk: Sıcak giyinmeyi unutmayın.'
              : 'Açık ama rüzgarlı ve soğuk: Sıcak giyinmeyi unutmayın.';
        }
        return {
          'message': message,
          'type': 'info',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_sunny,
        };
      }
      // Çok soğuk
      if (isCold) {
        String message = isNight
            ? 'Berrak gece ama soğuk: Sıcak giyinmeyi unutmayın.'
            : 'Açık ama soğuk hava: Sıcak giyinmeyi unutmayın.';
        if (isVeryWindy) {
          message = isNight
              ? 'Berrak gece, rüzgarlı ve soğuk: Kalın giysiler almanızı öneririz.'
              : 'Açık ama rüzgarlı ve soğuk: Kalın giysiler almanızı öneririz.';
        } else if (isWindy) {
          message = isNight
              ? 'Berrak gece, rüzgarlı ve soğuk: Sıcak giyinmeyi unutmayın.'
              : 'Açık ama rüzgarlı ve soğuk: Sıcak giyinmeyi unutmayın.';
        }
        return {
          'message': message,
          'type': 'info',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_sunny,
        };
      }
      // Aşırı soğuk
      if (isVeryCold) {
        String message = isNight
            ? 'Berrak gece ama çok soğuk: Kalın giysiler ve sıcak içecekler alın.'
            : 'Açık ama çok soğuk: Kalın giysiler ve sıcak içecekler alın.';
        if (isVeryWindy) {
          message = isNight
              ? 'Berrak gece, rüzgarlı ve çok soğuk: Kalın giysiler ve kapalı alanda kalmayı unutmayın.'
              : 'Açık ama rüzgarlı ve çok soğuk: Kalın giysiler ve kapalı alanda kalmayı unutmayın.';
        } else if (isWindy) {
          message = isNight
              ? 'Berrak gece, rüzgarlı ve çok soğuk: Kalın giysiler alın.'
              : 'Açık ama rüzgarlı ve çok soğuk: Kalın giysiler alın.';
        }
        return {
          'message': message,
          'type': 'info',
          'icon': Icons.ac_unit,
        };
      }
      // Çok aşırı soğuk
      if (isExtremelyCold) {
        String message = isNight
            ? 'Berrak gece ama aşırı soğuk: Sıcak giyinmeyi ve kapalı alanda kalmayı unutmayın.'
            : 'Açık ama aşırı soğuk: Sıcak giyinmeyi ve kapalı alanda kalmayı unutmayın.';
        if (isVeryWindy) {
          message = isNight
              ? 'Berrak gece, rüzgarlı ve aşırı soğuk: Mutlaka kalın giysiler ve kapalı alanda kalın.'
              : 'Açık ama rüzgarlı ve aşırı soğuk: Mutlaka kalın giysiler ve kapalı alanda kalın.';
        } else if (isWindy) {
          message = isNight
              ? 'Berrak gece, rüzgarlı ve aşırı soğuk: Kalın giysiler ve kapalı alanda kalmayı unutmayın.'
              : 'Açık ama rüzgarlı ve aşırı soğuk: Kalın giysiler ve kapalı alanda kalmayı unutmayın.';
        }
        return {
          'message': message,
          'type': 'warning',
          'icon': Icons.ac_unit,
        };
      }
    }

    // 6. Kısmen bulutlu hava
    if (isPartlyCloudy) {
      // Aşırı sıcak
      if (isExtremelyHot) {
        String message = isNight
            ? 'Kısmen bulutlu gece ve aşırı sıcak: Bol su almayı unutmayın.'
            : 'Kısmen bulutlu ve aşırı sıcak: Güneş koruması ve bol su almayı unutmayın.';
        if (isVeryHumid) {
          message = isNight
              ? 'Kısmen bulutlu gece, aşırı sıcak ve nemli: Bol su ve serin yerlerde kalın.'
              : 'Kısmen bulutlu, aşırı sıcak ve nemli: Güneş koruması, bol su ve serin yerlerde kalın.';
        }
        return {
          'message': message,
          'type': 'warning',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_cloudy,
        };
      }
      // Çok sıcak
      if (isVeryHot) {
        String message = isNight
            ? 'Kısmen bulutlu gece ve çok sıcak: Su almayı unutmayın.'
            : 'Kısmen bulutlu ve çok sıcak: Güneş koruması almanızı öneririz.';
        if (isVeryHumid) {
          message = isNight
              ? 'Kısmen bulutlu gece, sıcak ve nemli: Su almayı unutmayın.'
              : 'Kısmen bulutlu, sıcak ve nemli: Güneş koruması ve su almayı unutmayın.';
        }
        return {
          'message': message,
          'type': 'info',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_cloudy,
        };
      }
      // Sıcak
      if (isHot) {
        String message = isNight
            ? 'Kısmen bulutlu gece ve sıcak: Keyifli bir gece!'
            : 'Kısmen bulutlu ve sıcak: Güneş koruması almanızı öneririz.';
        return {
          'message': message,
          'type': 'info',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_cloudy,
        };
      }
      // Ilık
      if (isWarm) {
        String message = isNight
            ? 'Kısmen bulutlu gece ve ılık: Keyifli bir gece!'
            : 'Kısmen bulutlu ve ılık hava: Keyifli bir gün!';
        if (isVeryWindy) {
          message = isNight
              ? 'Kısmen bulutlu gece ve rüzgarlı: Hafif bir ceket alabilirsiniz.'
              : 'Kısmen bulutlu ve rüzgarlı: Hafif bir ceket alabilirsiniz.';
        }
        return {
          'message': message,
          'type': 'info',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_cloudy,
        };
      }
      // Serin ve soğuk
      if (isMild || isCool || isCold) {
        String message = isNight
            ? 'Kısmen bulutlu gece ve serin: Hafif bir ceket almanızı öneririz.'
            : 'Kısmen bulutlu ve serin: Hafif bir ceket almanızı öneririz.';
        if (isVeryWindy) {
          message = isNight
              ? 'Kısmen bulutlu gece, rüzgarlı ve serin: Ceket almanızı öneririz.'
              : 'Kısmen bulutlu, rüzgarlı ve serin: Ceket almanızı öneririz.';
        } else if (isWindy) {
          message = isNight
              ? 'Kısmen bulutlu gece ve rüzgarlı: Hafif bir ceket almanızı öneririz.'
              : 'Kısmen bulutlu ve rüzgarlı: Hafif bir ceket almanızı öneririz.';
        }
        if (isCold) {
          message = isNight
              ? 'Kısmen bulutlu gece ve soğuk: Sıcak giyinmeyi unutmayın.'
              : 'Kısmen bulutlu ve soğuk: Sıcak giyinmeyi unutmayın.';
        }
        return {
          'message': message,
          'type': 'info',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_cloudy,
        };
      }
      // Çok soğuk
      if (isVeryCold || isExtremelyCold) {
        String message = isNight
            ? 'Kısmen bulutlu gece ve soğuk: Sıcak giyinmeyi unutmayın.'
            : 'Kısmen bulutlu ve soğuk: Sıcak giyinmeyi unutmayın.';
        if (isExtremelyCold) {
          message = isNight
              ? 'Kısmen bulutlu gece ve aşırı soğuk: Kalın giysiler alın.'
              : 'Kısmen bulutlu ve aşırı soğuk: Kalın giysiler alın.';
        }
        if (isVeryWindy) {
          message = isNight
              ? 'Kısmen bulutlu gece, rüzgarlı ve soğuk: Kalın giysiler almanızı öneririz.'
              : 'Kısmen bulutlu, rüzgarlı ve soğuk: Kalın giysiler almanızı öneririz.';
        }
        return {
          'message': message,
          'type': 'info',
          'icon': isNight ? Icons.nightlight_round : Icons.wb_cloudy,
        };
      }
    }

    return null;
  }

  /// Weather code'larına göre gradient renklerini döndürür (light/dark mode desteği ile)
  List<Color> _getWeatherGradientColors(int? weatherCode, bool isDark) {
    if (weatherCode == null) {
      // Default sunny gradient
      return isDark
          ? [Colors.orange.shade700, Colors.orange.shade900]
          : [Colors.orange.shade300, Colors.orange.shade500];
    }

    // WMO Weather interpretation codes (WW)
    switch (weatherCode) {
      // Clear sky - Sunny gradient
      case 0:
        return isDark
            ? [Colors.orange.shade700, Colors.orange.shade900]
            : [Colors.orange.shade300, Colors.orange.shade500];

      // Mainly clear - Light blue gradient
      case 1:
      case 2:
      case 3:
        return isDark
            ? [Colors.lightBlue.shade700, Colors.lightBlue.shade900]
            : [Colors.lightBlue.shade300, Colors.lightBlue.shade500];

      // Fog - Gray gradient
      case 45:
      case 48:
        return isDark
            ? [Colors.grey.shade700, Colors.grey.shade900]
            : [Colors.grey.shade400, Colors.grey.shade600];

      // Drizzle - Blue gradient
      case 51:
      case 53:
      case 55:
        return isDark
            ? [Colors.blue.shade700, Colors.blue.shade900]
            : [Colors.blue.shade300, Colors.blue.shade500];

      // Freezing drizzle - Cyan gradient
      case 56:
      case 57:
        return isDark
            ? [Colors.cyan.shade700, Colors.cyan.shade900]
            : [Colors.cyan.shade300, Colors.cyan.shade500];

      // Rain - Dark blue gradient
      case 61:
      case 63:
      case 65:
        return isDark
            ? [Colors.blue.shade800, Colors.blue.shade900]
            : [Colors.blue.shade400, Colors.blue.shade600];

      // Freezing rain - Cyan gradient
      case 66:
      case 67:
        return isDark
            ? [Colors.cyan.shade800, Colors.cyan.shade900]
            : [Colors.cyan.shade400, Colors.cyan.shade600];

      // Snow fall - White gradient
      case 71:
      case 73:
      case 75:
        return isDark
            ? [Colors.blue.shade800, Colors.blue.shade900]
            : [Colors.white.withValues(alpha: 0.8), Colors.blue.shade100];

      // Snow grains - Light white gradient
      case 77:
        return isDark
            ? [Colors.blue.shade700, Colors.blue.shade800]
            : [Colors.white.withValues(alpha: 0.6), Colors.blue.shade50];

      // Rain showers - Indigo gradient
      case 80:
      case 81:
      case 82:
        return isDark
            ? [Colors.indigo.shade800, Colors.indigo.shade900]
            : [Colors.indigo.shade400, Colors.indigo.shade600];

      // Snow showers - Light white gradient
      case 85:
      case 86:
        return isDark
            ? [Colors.blue.shade700, Colors.blue.shade800]
            : [Colors.white.withValues(alpha: 0.7), Colors.blue.shade200];

      // Thunderstorm - Purple gradient
      case 95:
        return isDark
            ? [Colors.purple.shade800, Colors.purple.shade900]
            : [Colors.purple.shade400, Colors.purple.shade600];

      // Thunderstorm with hail - Dark purple gradient
      case 96:
      case 99:
        return isDark
            ? [Colors.deepPurple.shade800, Colors.deepPurple.shade900]
            : [Colors.deepPurple.shade500, Colors.deepPurple.shade700];

      default:
        // Default sunny gradient
        return isDark
            ? [Colors.orange.shade700, Colors.orange.shade900]
            : [Colors.orange.shade300, Colors.orange.shade500];
    }
  }

  /// Weather code'larına göre renk temasını döndürür (light/dark mode desteği ile)
  Map<String, Color> _getWeatherColors(int? weatherCode, bool isDark) {
    if (weatherCode == null) {
      // Default sunny theme
      return {
        'border': isDark
            ? Colors.orange.withValues(alpha: 0.4)
            : Colors.orange.withValues(alpha: 0.6),
        'shadow': isDark
            ? Colors.orange.withValues(alpha: 0.2)
            : Colors.orange.withValues(alpha: 0.3),
      };
    }

    // WMO Weather interpretation codes (WW)
    switch (weatherCode) {
      // Clear sky - Sunny theme
      case 0:
        return {
          'border': isDark
              ? Colors.orange.withValues(alpha: 0.4)
              : Colors.orange.withValues(alpha: 0.6),
          'shadow': isDark
              ? Colors.orange.withValues(alpha: 0.2)
              : Colors.orange.withValues(alpha: 0.3),
        };

      // Mainly clear - Light blue theme
      case 1:
      case 2:
      case 3:
        return {
          'border': isDark
              ? Colors.lightBlue.withValues(alpha: 0.4)
              : Colors.lightBlue.withValues(alpha: 0.6),
          'shadow': isDark
              ? Colors.lightBlue.withValues(alpha: 0.2)
              : Colors.lightBlue.withValues(alpha: 0.3),
        };

      // Fog - Gray theme
      case 45:
      case 48:
        return {
          'border': isDark
              ? Colors.grey.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.6),
          'shadow': isDark
              ? Colors.grey.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.3),
        };

      // Drizzle - Light blue theme
      case 51:
      case 53:
      case 55:
        return {
          'border': isDark
              ? Colors.blue.withValues(alpha: 0.4)
              : Colors.blue.withValues(alpha: 0.5),
          'shadow': isDark
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.blue.withValues(alpha: 0.2),
        };

      // Freezing drizzle - Light cyan theme
      case 56:
      case 57:
        return {
          'border': isDark
              ? Colors.cyan.withValues(alpha: 0.4)
              : Colors.cyan.withValues(alpha: 0.6),
          'shadow': isDark
              ? Colors.cyan.withValues(alpha: 0.2)
              : Colors.cyan.withValues(alpha: 0.3),
        };

      // Rain - Blue theme
      case 61:
      case 63:
      case 65:
        return {
          'border': isDark
              ? Colors.blue.withValues(alpha: 0.5)
              : Colors.blue.withValues(alpha: 0.7),
          'shadow': isDark
              ? Colors.blue.withValues(alpha: 0.3)
              : Colors.blue.withValues(alpha: 0.4),
        };

      // Freezing rain - Cyan theme
      case 66:
      case 67:
        return {
          'border': isDark
              ? Colors.cyan.withValues(alpha: 0.5)
              : Colors.cyan.withValues(alpha: 0.7),
          'shadow': isDark
              ? Colors.cyan.withValues(alpha: 0.3)
              : Colors.cyan.withValues(alpha: 0.4),
        };

      // Snow fall - White theme
      case 71:
      case 73:
      case 75:
        return {
          'border': isDark
              ? Colors.blue.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.8),
          'shadow': isDark
              ? Colors.blue.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.5),
        };

      // Snow grains - Light white theme
      case 77:
        return {
          'border': isDark
              ? Colors.blue.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.7),
          'shadow': isDark
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.4),
        };

      // Rain showers - Dark blue theme
      case 80:
      case 81:
      case 82:
        return {
          'border': isDark
              ? Colors.indigo.withValues(alpha: 0.5)
              : Colors.indigo.withValues(alpha: 0.7),
          'shadow': isDark
              ? Colors.indigo.withValues(alpha: 0.3)
              : Colors.indigo.withValues(alpha: 0.4),
        };

      // Snow showers - Light white theme
      case 85:
      case 86:
        return {
          'border': isDark
              ? Colors.blue.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.6),
          'shadow': isDark
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.3),
        };

      // Thunderstorm - Purple theme
      case 95:
        return {
          'border': isDark
              ? Colors.purple.withValues(alpha: 0.5)
              : Colors.purple.withValues(alpha: 0.7),
          'shadow': isDark
              ? Colors.purple.withValues(alpha: 0.3)
              : Colors.purple.withValues(alpha: 0.4),
        };

      // Thunderstorm with hail - Dark purple theme
      case 96:
      case 99:
        return {
          'border': isDark
              ? Colors.deepPurple.withValues(alpha: 0.6)
              : Colors.deepPurple.withValues(alpha: 0.8),
          'shadow': isDark
              ? Colors.deepPurple.withValues(alpha: 0.4)
              : Colors.deepPurple.withValues(alpha: 0.5),
        };

      default:
        // Default sunny theme
        return {
          'border': isDark
              ? Colors.orange.withValues(alpha: 0.4)
              : Colors.orange.withValues(alpha: 0.6),
          'shadow': isDark
              ? Colors.orange.withValues(alpha: 0.2)
              : Colors.orange.withValues(alpha: 0.3),
        };
    }
  }

  /// Uyarı tipine göre renk döndürür (hava durumu kartı için)
  Color _getAlertColor(String alertType, bool isDark) {
    // Hava durumu kartı üzerinde olduğu için beyaz/açık renk kullan
    if (isDark) {
      // Dark mode: daha parlak beyaz
      return alertType == 'warning'
          ? Colors.white.withValues(alpha: 0.95)
          : Colors.white.withValues(alpha: 0.9);
    } else {
      // Light mode: beyaz
      return alertType == 'warning'
          ? Colors.white.withValues(alpha: 0.95)
          : Colors.white.withValues(alpha: 0.9);
    }
  }

  /// Hava durumu kartı için metin rengi döndürür
  Color _getWeatherTextColor(bool isDark, {double alpha = 1.0}) {
    // Gradient üzerinde olduğu için beyaz kullan
    return Colors.white.withValues(alpha: alpha);
  }

  /// Hava durumu kartı için ikon rengi döndürür
  Color _getWeatherIconColor(bool isDark) {
    // Gradient üzerinde olduğu için beyaz kullan
    return Colors.white;
  }

  /// Animasyonlu gece/gündüz göstergesi widget'ı
  Widget _buildDayNightIndicator(bool isDark) {
    final isNight = _isNightTime();
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.85 + (value * 0.15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 0.5).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    isNight ? Icons.nightlight_round : Icons.wb_sunny,
                    key: ValueKey(isNight),
                    color: _getWeatherTextColor(isDark, alpha: 0.9),
                    size: 14,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.2),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _getDayNightStatus(),
                    key: ValueKey(_getDayNightStatus()),
                    style: GoogleFonts.poppins(
                      color: _getWeatherTextColor(isDark, alpha: 0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Rüzgar yönünü derece cinsinden metin olarak döndürür
  String _getWindDirection(int? windDirection) {
    if (windDirection == null) return '';
    
    // Rüzgar yönü 0-360 derece arasında
    if (windDirection >= 337.5 || windDirection < 22.5) return 'K';
    if (windDirection >= 22.5 && windDirection < 67.5) return 'KD';
    if (windDirection >= 67.5 && windDirection < 112.5) return 'D';
    if (windDirection >= 112.5 && windDirection < 157.5) return 'GD';
    if (windDirection >= 157.5 && windDirection < 202.5) return 'G';
    if (windDirection >= 202.5 && windDirection < 247.5) return 'GB';
    if (windDirection >= 247.5 && windDirection < 292.5) return 'B';
    if (windDirection >= 292.5 && windDirection < 337.5) return 'KB';
    
    return '';
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
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remainingDays > 0
                        ? '$remainingDays gün, $remainingHours saat kaldı'
                        : 'Deneme süreniz doldu',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
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
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aboneliğinizi yenileyerek tüm özelliklerden yararlanmaya devam edin',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
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
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$remainingDays gün kaldı. Yenilemeyi unutmayın!',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
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
          mainAxisSize: MainAxisSize.min,
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
          mainAxisSize: MainAxisSize.min,
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
          mainAxisSize: MainAxisSize.min,
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
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08)),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo + text (open calculator on tap)
          GestureDetector(
              onTap: () => CalculatorOverlay.instance.toggle(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.25),
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
              mainAxisSize: MainAxisSize.min,
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
                      color: Theme.of(context).colorScheme.onPrimary,
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
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.12),
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
      final loadingColors = _getWeatherGradientColors(null, isDark);
      final loadingTheme = _getWeatherColors(null, isDark);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: loadingColors,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: loadingTheme['border']!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hava durumu yükleniyor...',
                    style: GoogleFonts.poppins(
                      color: _getWeatherTextColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'İstanbul',
                    style: GoogleFonts.poppins(
                      color: _getWeatherTextColor(isDark, alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.wb_sunny,
              color: _getWeatherIconColor(isDark),
              size: 24,
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
              _weather != null ? _weather!['weathercode'] as int? : null, isDark),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getWeatherColors(_weather != null
              ? _weather!['weathercode'] as int?
              : null, isDark)['border']!,
        ),
        boxShadow: [
          BoxShadow(
            color: _getWeatherColors(_weather != null
                ? _weather!['weathercode'] as int?
                : null, isDark)['shadow']!,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
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
                        color: _getWeatherTextColor(isDark),
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
                        color: _getWeatherTextColor(isDark, alpha: 0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Weather Alert (if exists) - Desktop - Entegre uyarı sistemi
                if (_getIntegratedWeatherAlert(
                      _weather != null ? _weather!['weathercode'] as int? : null,
                      _weather != null ? (_weather!['temperature'] as num?)?.toDouble() : null,
                      _weather != null ? (_weather!['windspeed'] as num?)?.toDouble() : null,
                      _weather != null ? (_weather!['humidity'] as int?) : null,
                    ) !=
                    null)
                  Text(
                    _getIntegratedWeatherAlert(
                      _weather != null ? _weather!['weathercode'] as int? : null,
                      _weather != null ? (_weather!['temperature'] as num?)?.toDouble() : null,
                      _weather != null ? (_weather!['windspeed'] as num?)?.toDouble() : null,
                      _weather != null ? (_weather!['humidity'] as int?) : null,
                    )!['message'],
                    style: GoogleFonts.poppins(
                      color: _getAlertColor(
                        _getIntegratedWeatherAlert(
                          _weather != null ? _weather!['weathercode'] as int? : null,
                          _weather != null ? (_weather!['temperature'] as num?)?.toDouble() : null,
                          _weather != null ? (_weather!['windspeed'] as num?)?.toDouble() : null,
                          _weather != null ? (_weather!['humidity'] as int?) : null,
                        )!['type'],
                        isDark,
                      ),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                const SizedBox(height: 4),
                // Additional weather info: Wind and Humidity
                Row(
                  children: [
                    // Wind Speed
                    if (_weather != null && _weather!['windspeed'] != null) ...[
                      Icon(
                        Icons.air,
                        size: 12,
                        color: _getWeatherTextColor(isDark, alpha: 0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(_weather!['windspeed'] as num).toStringAsFixed(0)} km/h',
                        style: GoogleFonts.poppins(
                          color: _getWeatherTextColor(isDark, alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Wind Direction
                      if (_weather != null && _weather!['winddirection'] != null) ...[
                        const SizedBox(width: 2),
                        Text(
                          _getWindDirection((_weather!['winddirection'] as num?)?.toInt()),
                          style: GoogleFonts.poppins(
                            color: _getWeatherTextColor(isDark, alpha: 0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                    // Separator
                    if (_weather != null && 
                        _weather!['windspeed'] != null && 
                        _weather!['humidity'] != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 12,
                        color: _getWeatherTextColor(isDark, alpha: 0.4),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Humidity
                    if (_weather != null && _weather!['humidity'] != null) ...[
                      Icon(
                        Icons.water_drop,
                        size: 12,
                        color: _getWeatherTextColor(isDark, alpha: 0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '%${_weather!['humidity']}',
                        style: GoogleFonts.poppins(
                          color: _getWeatherTextColor(isDark, alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Day/Night Indicator with Animation
                _buildDayNightIndicator(isDark),
                const SizedBox(height: 4),
                // Location
                Text(
                  _locationName ?? 'İstanbul',
                  style: GoogleFonts.poppins(
                    color: _getWeatherTextColor(isDark, alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Weather Icon (moved to right)
          Icon(
            _getWeatherIcon(
                _weather != null ? _weather!['weathercode'] as int? : null),
            color: _getWeatherIconColor(isDark),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherRowMobile(bool isDark) {
    // Weather verisi yoksa loading göster
    if (_weather == null) {
      final loadingColors = _getWeatherGradientColors(null, isDark);
      final loadingTheme = _getWeatherColors(null, isDark);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: loadingColors,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: loadingTheme['border']!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hava durumu yükleniyor...',
                    style: GoogleFonts.poppins(
                      color: _getWeatherTextColor(isDark),
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
                      color: _getWeatherTextColor(isDark, alpha: 0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.wb_sunny,
              color: _getWeatherIconColor(isDark),
              size: 20,
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
              _weather != null ? _weather!['weathercode'] as int? : null, isDark),
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getWeatherColors(_weather != null
              ? _weather!['weathercode'] as int?
              : null, isDark)['border']!,
        ),
        boxShadow: [
          BoxShadow(
            color: _getWeatherColors(_weather != null
                ? _weather!['weathercode'] as int?
                : null, isDark)['shadow']!,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
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
                        color: _getWeatherTextColor(isDark),
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
                          color: _getWeatherTextColor(isDark, alpha: 0.95),
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
                // Weather Alert (if exists) - Mobile - Entegre uyarı sistemi
                if (_getIntegratedWeatherAlert(
                      _weather != null ? _weather!['weathercode'] as int? : null,
                      _weather != null ? (_weather!['temperature'] as num?)?.toDouble() : null,
                      _weather != null ? (_weather!['windspeed'] as num?)?.toDouble() : null,
                      _weather != null ? (_weather!['humidity'] as int?) : null,
                    ) !=
                    null)
                  Text(
                    _getIntegratedWeatherAlert(
                      _weather != null ? _weather!['weathercode'] as int? : null,
                      _weather != null ? (_weather!['temperature'] as num?)?.toDouble() : null,
                      _weather != null ? (_weather!['windspeed'] as num?)?.toDouble() : null,
                      _weather != null ? (_weather!['humidity'] as int?) : null,
                    )!['message'],
                    style: GoogleFonts.poppins(
                      color: _getAlertColor(
                        _getIntegratedWeatherAlert(
                          _weather != null ? _weather!['weathercode'] as int? : null,
                          _weather != null ? (_weather!['temperature'] as num?)?.toDouble() : null,
                          _weather != null ? (_weather!['windspeed'] as num?)?.toDouble() : null,
                          _weather != null ? (_weather!['humidity'] as int?) : null,
                        )!['type'],
                        isDark,
                      ),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                const SizedBox(height: 2),
                // Additional weather info: Wind and Humidity (Mobile)
                Row(
                  children: [
                    // Wind Speed
                    if (_weather != null && _weather!['windspeed'] != null) ...[
                      Icon(
                        Icons.air,
                        size: 10,
                        color: _getWeatherTextColor(isDark, alpha: 0.9),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${(_weather!['windspeed'] as num).toStringAsFixed(0)} km/h',
                        style: GoogleFonts.poppins(
                          color: _getWeatherTextColor(isDark, alpha: 0.9),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Wind Direction
                      if (_weather != null && _weather!['winddirection'] != null) ...[
                        const SizedBox(width: 2),
                        Text(
                          _getWindDirection((_weather!['winddirection'] as num?)?.toInt()),
                          style: GoogleFonts.poppins(
                            color: _getWeatherTextColor(isDark, alpha: 0.85),
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                    // Separator
                    if (_weather != null && 
                        _weather!['windspeed'] != null && 
                        _weather!['humidity'] != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 1,
                        height: 10,
                        color: _getWeatherTextColor(isDark, alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                    ],
                    // Humidity
                    if (_weather != null && _weather!['humidity'] != null) ...[
                      Icon(
                        Icons.water_drop,
                        size: 10,
                        color: _getWeatherTextColor(isDark, alpha: 0.9),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '%${_weather!['humidity']}',
                        style: GoogleFonts.poppins(
                          color: _getWeatherTextColor(isDark, alpha: 0.9),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                // Day/Night Indicator with Animation (Mobile)
                _buildDayNightIndicator(isDark),
                const SizedBox(height: 2),
                // Location
                Text(
                  _locationName ?? 'İstanbul',
                  style: GoogleFonts.poppins(
                    color: _getWeatherTextColor(isDark, alpha: 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Weather Icon (moved to right)
          Icon(
            _getWeatherIcon(
                _weather != null ? _weather!['weathercode'] as int? : null),
            color: _getWeatherIconColor(isDark),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Hızlı İşlemler',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
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
                        isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB), () {
                      context.pushNamed('invoices-list');
                    }, isDark),
                    const SizedBox(width: 12),
                    _buildActionCardHorizontal(isMobile ? 'Ürün' : 'Ürün Ekle',
                        Icons.inventory_2, isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706), () {
                      context.pushNamed('create-product');
                    }, isDark),
                    const SizedBox(width: 12),
                    _buildActionCardHorizontal(
                        isMobile ? 'Müşteri' : 'Müşteri Ekle',
                        Icons.person_add,
                        isDark ? const Color(0xFF8B5CF6) : const Color(0xFF7C3AED), () {
                      context.pushNamed('create-customer');
                    }, isDark),
                    const SizedBox(width: 12),
                    _buildActionCardHorizontal(
                        isMobile ? 'Stok' : 'Stok İşlemi',
                        Icons.warehouse,
                        isDark ? const Color(0xFF10B981) : const Color(0xFF059669), () {
                      context.pushNamed('inventory');
                    }, isDark),
                    const SizedBox(width: 12),
                    _buildActionCardHorizontal(
                        isMobile ? 'Depo' : 'Depo Listesi',
                        Icons.list,
                        isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5), () {
                      context.pushNamed('warehouses-home');
                    }, isDark),
                    const SizedBox(width: 12),
                    _buildActionCardHorizontal(
                        isMobile ? 'Stok Listesi' : 'Stok Listesi',
                        Icons.inventory,
                        isDark ? const Color(0xFF14B8A6) : const Color(0xFF0D9488), () {
                      context.pushNamed('stock-list');
                    }, isDark),
                    const SizedBox(width: 12),
                    _buildActionCardHorizontal(
                        isMobile ? 'Test' : 'Logger Test',
                        Icons.color_lens,
                        isDark ? const Color(0xFFEC4899) : const Color(0xFFDB2777), () {
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.4 : 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Hızlı İşlemler',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
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
        // Modern renk paleti - light ve dark mode için optimize edilmiş
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        // Satış - Yeşil tonları
        final salesColor = isDark ? const Color(0xFF10B981) : const Color(0xFF059669);
        // Alış - Turuncu tonları
        final purchaseColor = isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);
        // Kar - Yeşil, Zarar - Kırmızı
        final profitColor = summary.netProfit >= 0
            ? (isDark ? const Color(0xFF10B981) : const Color(0xFF059669))
            : (isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626));
        // Bakiye - Mavi tonları
        final balanceColor = isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);
        // Kritik Stok - Turuncu/Kırmızı tonları
        final criticalColor = isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C);
        // Müşteri - Mor tonları
        final customerColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFF7C3AED);
        // Tahsilat - Teal tonları
        final receivablesColor = isDark ? const Color(0xFF14B8A6) : const Color(0xFF0D9488);
        // Ödeme - Pembe tonları
        final payablesColor = isDark ? const Color(0xFFEC4899) : const Color(0xFFDB2777);

        final cards = <Widget>[
          DashboardStatsCard(
            title: 'Toplam Satış',
            value: summary.totalSales,
            currency: 'TRY',
            icon: Icons.trending_up,
            iconColor: salesColor,
            backgroundColor: salesColor,
            percentageChange: summary.salesGrowthRate,
            percentageColor:
                summary.salesGrowthRate >= 0 ? salesColor : (isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626)),
          ),
          DashboardStatsCard(
            title: 'Toplam Alış',
            value: summary.totalPurchases,
            currency: 'TRY',
            icon: Icons.shopping_cart,
            iconColor: purchaseColor,
            backgroundColor: purchaseColor,
          ),
          DashboardStatsCard(
            title: 'Net Kar/Zarar',
            value: summary.netProfit,
            currency: 'TRY',
            icon: Icons.account_balance_wallet,
            iconColor: profitColor,
            backgroundColor: profitColor,
          ),
          DashboardStatsCard(
            title: 'Toplam Bakiye',
            value: summary.totalBalance,
            currency: 'TRY',
            icon: Icons.account_balance,
            iconColor: balanceColor,
            backgroundColor: balanceColor,
          ),
          DashboardStatsCard(
            title: 'Kritik Stok',
            value: summary.criticalStockCount.toDouble(),
            currency: '',
            subtitle: 'ürün',
            icon: Icons.warning,
            iconColor: criticalColor,
            backgroundColor: criticalColor,
          ),
          DashboardStatsCard(
            title: 'Toplam Müşteri',
            value: summary.totalCustomers.toDouble(),
            currency: '',
            subtitle: 'kişi',
            icon: Icons.people,
            iconColor: customerColor,
            backgroundColor: customerColor,
          ),
          DashboardStatsCard(
            title: 'Bekleyen Tahsilat',
            value: summary.pendingReceivables,
            currency: 'TRY',
            icon: Icons.download,
            iconColor: receivablesColor,
            backgroundColor: receivablesColor,
          ),
          DashboardStatsCard(
            title: 'Bekleyen Ödeme',
            value: summary.pendingPayables,
            currency: 'TRY',
            icon: Icons.upload,
            iconColor: payablesColor,
            backgroundColor: payablesColor,
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
