// ========== PERMISSION SERVICE (WEB) ==========
// Web-safe implementation without dart:io.

import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<bool> isInternetConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

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

  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  Future<PermissionStatus> getLocationPermissionStatus() async {
    return await Permission.location.status;
  }

  Future<PermissionStatus> requestLocationPermission() async {
    return await Permission.location.request();
  }

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
      await openAppSettings();
      return false;
    }

    return false;
  }

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

  Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

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

  Future<PermissionStatus> getStoragePermissionStatus() async {
    // Web'de dosya sistemi izni yok, granted sayalım
    return PermissionStatus.granted;
  }

  Future<PermissionStatus> requestStoragePermission() async {
    return PermissionStatus.granted;
  }

  Future<bool> ensureStoragePermission() async {
    return true;
  }

  Future<PermissionStatus> getMicrophonePermissionStatus() async {
    return await Permission.microphone.status;
  }

  Future<PermissionStatus> requestMicrophonePermission() async {
    return await Permission.microphone.request();
  }

  Future<bool> ensureMicrophonePermission() async {
    final status = await getMicrophonePermissionStatus();
    if (status.isGranted) return true;
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

  Future<PermissionStatus> getNotificationPermissionStatus() async {
    try {
      // Web için basit permission kontrolü - permission_handler kullan
      return await Permission.notification.status;
    } catch (e) {
      return PermissionStatus.denied;
    }
  }

  Future<PermissionStatus> requestNotificationPermission() async {
    try {
      // Web için basit permission request - permission_handler kullan
      return await Permission.notification.request();
    } catch (e) {
      return PermissionStatus.denied;
    }
  }

  Future<bool> ensureNotificationPermission() async {
    try {
      final status = await getNotificationPermissionStatus();
      if (status.isGranted) return true;
      if (status.isDenied) {
        final result = await requestNotificationPermission();
        return result.isGranted;
      }
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final webInfo = await _deviceInfo.webBrowserInfo;
      return {
        'platform': 'Web',
        'browser': webInfo.browserName.name,
        'version': webInfo.appVersion,
        'userAgent': webInfo.userAgent,
      };
    } catch (e) {
      return {'platform': 'Error', 'error': e.toString()};
    }
  }

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

  Future<Map<String, bool>> checkAllPermissions() async {
    // Sadece izin durumlarını kontrol et, izin isteme
    // Bu metod uygulamanın açılışında çağrılıyor
    return {
      'internet': await isInternetConnected(),
      'location': (await getLocationPermissionStatus()).isGranted,
      'camera': (await getCameraPermissionStatus()).isGranted,
      'storage': (await getStoragePermissionStatus()).isGranted,
      'microphone': (await getMicrophonePermissionStatus()).isGranted,
      'notification': (await getNotificationPermissionStatus()).isGranted,
    };
  }

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
