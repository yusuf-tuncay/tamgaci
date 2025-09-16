// ========== PERMISSION SERVICE ==========
// lib/core/services/permission_service.dart

import 'package:permission_handler/permission_handler.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// İzin yönetimi servisi
class PermissionService {
  /// Kamera izni iste
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      AppLogger.info('Camera permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.error('Camera permission request failed', e);
      return false;
    }
  }

  /// Galeri izni iste
  static Future<bool> requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();
      AppLogger.info('Photos permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.error('Photos permission request failed', e);
      return false;
    }
  }

  /// Dosya okuma izni iste
  static Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      AppLogger.info('Storage permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.error('Storage permission request failed', e);
      return false;
    }
  }

  /// Konum izni iste
  static Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      AppLogger.info('Location permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.error('Location permission request failed', e);
      return false;
    }
  }

  /// Bildirim izni iste
  static Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      AppLogger.info('Notification permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.error('Notification permission request failed', e);
      return false;
    }
  }

  /// İzin durumunu kontrol et
  static Future<bool> checkPermission(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isGranted;
    } catch (e) {
      AppLogger.error('Permission check failed', e);
      return false;
    }
  }

  /// Tüm gerekli izinleri iste
  static Future<Map<Permission, bool>> requestAllPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.photos,
      Permission.storage,
      Permission.location,
      Permission.notification,
    ];

    final results = <Permission, bool>{};

    for (final permission in permissions) {
      try {
        final status = await permission.request();
        results[permission] = status.isGranted;
      } catch (e) {
        AppLogger.error('Permission request failed for $permission', e);
        results[permission] = false;
      }
    }

    AppLogger.info('All permissions requested: $results');
    return results;
  }
}
