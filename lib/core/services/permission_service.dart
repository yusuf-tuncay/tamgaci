// ========== PERMISSION SERVICE ==========
// lib/core/services/permission_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as internet_checker;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// İzin ve sistem kontrolleri için servis sınıfı
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // ========== İNTERNET KONTROLÜ ==========

  /// İnternet bağlantısı durumunu kontrol et
  Future<bool> isInternetConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  /// İnternet bağlantısı tipini al
  Future<String> getConnectionType() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      switch (connectivityResult) {
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.mobile:
          return 'Mobil Veri';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.vpn:
          return 'VPN';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth';
        case ConnectivityResult.other:
          return 'Diğer';
        case ConnectivityResult.none:
          return 'Bağlantı Yok';
      }
    } catch (e) {
      return 'Bilinmiyor';
    }
  }

  // ========== KONUM İZİNLERİ ==========

  /// Konum servislerinin açık olup olmadığını kontrol et
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Konum iznini kontrol et
  Future<PermissionStatus> getLocationPermissionStatus() async {
    return await Permission.location.status;
  }

  /// Konum iznini iste
  Future<PermissionStatus> requestLocationPermission() async {
    return await Permission.location.request();
  }

  /// Konum iznini kontrol et ve gerekirse iste
  Future<bool> ensureLocationPermission() async {
    final status = await getLocationPermissionStatus();

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await requestLocationPermission();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      // Kullanıcıyı ayarlara yönlendir
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Mevcut konumu al
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await ensureLocationPermission();
      if (!hasPermission) {
        return null;
      }

      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  /// Konumdan adres bilgisi al
  Future<String?> getAddressFromLocation(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ========== KAMERA İZİNLERİ ==========

  /// Kamera iznini kontrol et
  Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  /// Kamera iznini iste
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// Kamera iznini kontrol et ve gerekirse iste
  Future<bool> ensureCameraPermission() async {
    final status = await getCameraPermissionStatus();

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await requestCameraPermission();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  // ========== DEPOLAMA İZİNLERİ ==========

  /// Depolama iznini kontrol et
  Future<PermissionStatus> getStoragePermissionStatus() async {
    if (Platform.isAndroid) {
      return await Permission.storage.status;
    } else if (Platform.isIOS) {
      return await Permission.photos.status;
    }
    return PermissionStatus.granted;
  }

  /// Depolama iznini iste
  Future<PermissionStatus> requestStoragePermission() async {
    if (Platform.isAndroid) {
      return await Permission.storage.request();
    } else if (Platform.isIOS) {
      return await Permission.photos.request();
    }
    return PermissionStatus.granted;
  }

  /// Depolama iznini kontrol et ve gerekirse iste
  Future<bool> ensureStoragePermission() async {
    final status = await getStoragePermissionStatus();

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await requestStoragePermission();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  // ========== MİKROFON İZİNLERİ ==========

  /// Mikrofon iznini kontrol et
  Future<PermissionStatus> getMicrophonePermissionStatus() async {
    return await Permission.microphone.status;
  }

  /// Mikrofon iznini iste
  Future<PermissionStatus> requestMicrophonePermission() async {
    return await Permission.microphone.request();
  }

  /// Mikrofon iznini kontrol et ve gerekirse iste
  Future<bool> ensureMicrophonePermission() async {
    final status = await getMicrophonePermissionStatus();

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await requestMicrophonePermission();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  // ========== BİLDİRİM İZİNLERİ ==========

  /// Bildirim iznini kontrol et
  Future<PermissionStatus> getNotificationPermissionStatus() async {
    return await Permission.notification.status;
  }

  /// Bildirim iznini iste
  Future<PermissionStatus> requestNotificationPermission() async {
    return await Permission.notification.request();
  }

  /// Bildirim iznini kontrol et ve gerekirse iste
  Future<bool> ensureNotificationPermission() async {
    final status = await getNotificationPermissionStatus();

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await requestNotificationPermission();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  // ========== CİHAZ BİLGİLERİ ==========

  /// Cihaz bilgilerini al
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return {
          'platform': 'Web',
          'browser': webInfo.browserName.name,
          'version': webInfo.appVersion,
          'userAgent': webInfo.userAgent,
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'sdkVersion': androidInfo.version.sdkInt.toString(),
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'name': iosInfo.name,
          'model': iosInfo.model,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return {
          'platform': 'Windows',
          'computerName': windowsInfo.computerName,
          'majorVersion': windowsInfo.majorVersion,
          'minorVersion': windowsInfo.minorVersion,
          'buildNumber': windowsInfo.buildNumber,
        };
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        return {
          'platform': 'macOS',
          'computerName': macInfo.computerName,
          'osRelease': macInfo.osRelease,
          'activeCPUs': macInfo.activeCPUs,
        };
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return {
          'platform': 'Linux',
          'name': linuxInfo.name,
          'version': linuxInfo.version,
          'id': linuxInfo.id,
        };
      }

      return {'platform': 'Unknown'};
    } catch (e) {
      return {'platform': 'Error', 'error': e.toString()};
    }
  }

  /// Uygulama bilgilerini al
  Future<Map<String, dynamic>> getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // ========== GENEL İZİN KONTROLÜ ==========

  /// Tüm gerekli izinleri kontrol et
  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'internet': await isInternetConnected(),
      'location': await ensureLocationPermission(),
      'camera': await ensureCameraPermission(),
      'storage': await ensureStoragePermission(),
      'microphone': await ensureMicrophonePermission(),
      'notification': await ensureNotificationPermission(),
    };
  }

  /// İzin durumlarını al (istemeden)
  Future<Map<String, PermissionStatus>> getAllPermissionStatuses() async {
    return {
      'location': await getLocationPermissionStatus(),
      'camera': await getCameraPermissionStatus(),
      'storage': await getStoragePermissionStatus(),
      'microphone': await getMicrophonePermissionStatus(),
      'notification': await getNotificationPermissionStatus(),
    };
  }
}
