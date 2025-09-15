import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tamgaci/core/errors/error_logger.dart';

/// Permission management class for handling app permissions
class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  /// Check if a permission is granted
  static Future<bool> isGranted(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isGranted;
    } catch (e) {
      ErrorLogger.logError(
        'Error checking permission status',
        error: e,
        context: 'PermissionManager',
        additionalData: {'permission': permission.toString()},
      );
      return false;
    }
  }

  /// Request a permission
  static Future<PermissionStatus> request(Permission permission) async {
    try {
      final status = await permission.request();

      ErrorLogger.logInfo(
        'Permission requested',
        context: 'PermissionManager',
        additionalData: {
          'permission': permission.toString(),
          'status': status.toString(),
        },
      );

      return status;
    } catch (e) {
      ErrorLogger.logError(
        'Error requesting permission',
        error: e,
        context: 'PermissionManager',
        additionalData: {'permission': permission.toString()},
      );
      return PermissionStatus.denied;
    }
  }

  /// Request multiple permissions
  static Future<Map<Permission, PermissionStatus>> requestMultiple(
    List<Permission> permissions,
  ) async {
    try {
      final statuses = await permissions.request();

      ErrorLogger.logInfo(
        'Multiple permissions requested',
        context: 'PermissionManager',
        additionalData: {
          'permissions': permissions.map((p) => p.toString()).toList(),
          'statuses':
              statuses.map((k, v) => MapEntry(k.toString(), v.toString())),
        },
      );

      return statuses;
    } catch (e) {
      ErrorLogger.logError(
        'Error requesting multiple permissions',
        error: e,
        context: 'PermissionManager',
        additionalData: {
          'permissions': permissions.map((p) => p.toString()).toList()
        },
      );
      return {};
    }
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      ErrorLogger.logError(
        'Error checking if permission is permanently denied',
        error: e,
        context: 'PermissionManager',
        additionalData: {'permission': permission.toString()},
      );
      return false;
    }
  }

  /// Check if permission is restricted
  static Future<bool> isRestricted(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isRestricted;
    } catch (e) {
      ErrorLogger.logError(
        'Error checking if permission is restricted',
        error: e,
        context: 'PermissionManager',
        additionalData: {'permission': permission.toString()},
      );
      return false;
    }
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    try {
      final result = await openAppSettings();

      ErrorLogger.logInfo(
        'App settings opened',
        context: 'PermissionManager',
        additionalData: {'result': result},
      );

      return result;
    } catch (e) {
      ErrorLogger.logError(
        'Error opening app settings',
        error: e,
        context: 'PermissionManager',
      );
      return false;
    }
  }

  /// Get permission status
  static Future<PermissionStatus> getStatus(Permission permission) async {
    try {
      return await permission.status;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting permission status',
        error: e,
        context: 'PermissionManager',
        additionalData: {'permission': permission.toString()},
      );
      return PermissionStatus.denied;
    }
  }

  /// Check camera permission
  static Future<bool> checkCameraPermission() async {
    return await isGranted(Permission.camera);
  }

  /// Request camera permission
  static Future<PermissionStatus> requestCameraPermission() async {
    return await request(Permission.camera);
  }

  /// Check storage permission
  static Future<bool> checkStoragePermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await isGranted(Permission.storage);
    } else {
      return await isGranted(Permission.photos);
    }
  }

  /// Request storage permission
  static Future<PermissionStatus> requestStoragePermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await request(Permission.storage);
    } else {
      return await request(Permission.photos);
    }
  }

  /// Check microphone permission
  static Future<bool> checkMicrophonePermission() async {
    return await isGranted(Permission.microphone);
  }

  /// Request microphone permission
  static Future<PermissionStatus> requestMicrophonePermission() async {
    return await request(Permission.microphone);
  }

  /// Check location permission
  static Future<bool> checkLocationPermission() async {
    return await isGranted(Permission.location);
  }

  /// Request location permission
  static Future<PermissionStatus> requestLocationPermission() async {
    return await request(Permission.location);
  }

  /// Check notification permission
  static Future<bool> checkNotificationPermission() async {
    return await isGranted(Permission.notification);
  }

  /// Request notification permission
  static Future<PermissionStatus> requestNotificationPermission() async {
    return await request(Permission.notification);
  }

  /// Check contacts permission
  static Future<bool> checkContactsPermission() async {
    return await isGranted(Permission.contacts);
  }

  /// Request contacts permission
  static Future<PermissionStatus> requestContactsPermission() async {
    return await request(Permission.contacts);
  }

  /// Check calendar permission
  static Future<bool> checkCalendarPermission() async {
    return await isGranted(Permission.calendar);
  }

  /// Request calendar permission
  static Future<PermissionStatus> requestCalendarPermission() async {
    return await request(Permission.calendar);
  }

  /// Check SMS permission
  static Future<bool> checkSmsPermission() async {
    return await isGranted(Permission.sms);
  }

  /// Request SMS permission
  static Future<PermissionStatus> requestSmsPermission() async {
    return await request(Permission.sms);
  }

  /// Check phone permission
  static Future<bool> checkPhonePermission() async {
    return await isGranted(Permission.phone);
  }

  /// Request phone permission
  static Future<PermissionStatus> requestPhonePermission() async {
    return await request(Permission.phone);
  }

  /// Get permission display name
  static String getPermissionDisplayName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Kamera';
      case Permission.storage:
        return 'Depolama';
      case Permission.photos:
        return 'Fotoğraflar';
      case Permission.microphone:
        return 'Mikrofon';
      case Permission.location:
        return 'Konum';
      case Permission.notification:
        return 'Bildirimler';
      case Permission.contacts:
        return 'Kişiler';
      case Permission.calendar:
        return 'Takvim';
      case Permission.sms:
        return 'SMS';
      case Permission.phone:
        return 'Telefon';
      default:
        return 'Bilinmeyen İzin';
    }
  }

  /// Get permission description
  static String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Fotoğraf çekmek için kamera erişimi gereklidir.';
      case Permission.storage:
        return 'Dosyaları kaydetmek ve okumak için depolama erişimi gereklidir.';
      case Permission.photos:
        return 'Fotoğrafları seçmek için galeri erişimi gereklidir.';
      case Permission.microphone:
        return 'Ses kaydetmek için mikrofon erişimi gereklidir.';
      case Permission.location:
        return 'Konum bilgisi almak için konum erişimi gereklidir.';
      case Permission.notification:
        return 'Bildirim göndermek için bildirim izni gereklidir.';
      case Permission.contacts:
        return 'Kişi bilgilerine erişmek için kişiler izni gereklidir.';
      case Permission.calendar:
        return 'Takvim bilgilerine erişmek için takvim izni gereklidir.';
      case Permission.sms:
        return 'SMS göndermek için SMS izni gereklidir.';
      case Permission.phone:
        return 'Telefon araması yapmak için telefon izni gereklidir.';
      default:
        return 'Bu özelliği kullanmak için izin gereklidir.';
    }
  }

  /// Check if all required permissions are granted
  static Future<bool> checkAllRequiredPermissions() async {
    final requiredPermissions = [
      Permission.storage,
      Permission.notification,
    ];

    for (final permission in requiredPermissions) {
      if (!await isGranted(permission)) {
        return false;
      }
    }

    return true;
  }

  /// Request all required permissions
  static Future<Map<Permission, PermissionStatus>>
      requestAllRequiredPermissions() async {
    final requiredPermissions = [
      Permission.storage,
      Permission.notification,
    ];

    return await requestMultiple(requiredPermissions);
  }

  /// Get permission status summary
  static Future<Map<String, bool>> getPermissionStatusSummary() async {
    final permissions = [
      Permission.camera,
      Permission.storage,
      Permission.photos,
      Permission.microphone,
      Permission.location,
      Permission.notification,
      Permission.contacts,
      Permission.calendar,
      Permission.sms,
      Permission.phone,
    ];

    final summary = <String, bool>{};

    for (final permission in permissions) {
      final isGranted = await PermissionManager.isGranted(permission);
      summary[permission.toString()] = isGranted;
    }

    return summary;
  }
}
