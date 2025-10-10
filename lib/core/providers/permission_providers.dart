// ========== PERMISSION PROVIDERS ==========
// lib/core/providers/permission_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/utils/permission_service.dart';

/// Permission service provider
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

/// İnternet bağlantısı durumu provider
final internetConnectionProvider = StreamProvider<bool>((ref) async* {
  final service = ref.read(permissionServiceProvider);

  // İlk kontrol
  yield await service.isInternetConnected();

  // Sürekli kontrol için stream
  while (true) {
    await Future.delayed(const Duration(seconds: 5));
    yield await service.isInternetConnected();
  }
});

/// Bağlantı tipi provider
final connectionTypeProvider = FutureProvider<String>((ref) async {
  final service = ref.read(permissionServiceProvider);
  return await service.getConnectionType();
});

/// Konum izni durumu provider
final locationPermissionProvider =
    FutureProvider<PermissionStatus>((ref) async {
  final service = ref.read(permissionServiceProvider);
  return await service.getLocationPermissionStatus();
});

/// Kamera izni durumu provider
final cameraPermissionProvider = FutureProvider<PermissionStatus>((ref) async {
  final service = ref.read(permissionServiceProvider);
  return await service.getCameraPermissionStatus();
});

/// Depolama izni durumu provider
final storagePermissionProvider = FutureProvider<PermissionStatus>((ref) async {
  final service = ref.read(permissionServiceProvider);
  return await service.getStoragePermissionStatus();
});

/// Mikrofon izni durumu provider
final microphonePermissionProvider =
    FutureProvider<PermissionStatus>((ref) async {
  final service = ref.read(permissionServiceProvider);
  return await service.getMicrophonePermissionStatus();
});

/// Bildirim izni durumu provider
final notificationPermissionProvider =
    FutureProvider<PermissionStatus>((ref) async {
  final service = ref.read(permissionServiceProvider);
  return await service.getNotificationPermissionStatus();
});

/// Tüm izin durumları provider
final allPermissionStatusesProvider =
    FutureProvider<Map<String, PermissionStatus>>((ref) async {
  final service = ref.read(permissionServiceProvider);
  return await service.getAllPermissionStatuses();
});

/// Cihaz bilgileri provider
final deviceInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(permissionServiceProvider);
  return await service.getDeviceInfo();
});

/// Uygulama bilgileri provider
final appInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(permissionServiceProvider);
  return await service.getAppInfo();
});

/// İzin kontrol notifier'ı
class PermissionNotifier extends StateNotifier<Map<String, bool>> {
  final PermissionService _service;

  PermissionNotifier(this._service) : super({}) {
    // İzinleri asenkron olarak arka planda kontrol et
    // Uygulamanın açılmasını engelleme
    _checkAllPermissionsInBackground();
  }

  /// İzinleri arka planda kontrol et (non-blocking)
  void _checkAllPermissionsInBackground() {
    // Asenkron olarak çalıştır, await kullanma
    Future.microtask(() async {
      try {
        final permissions = await _service.checkAllPermissions();
        if (mounted) {
          state = permissions;
        }
      } catch (e) {
        // Hata durumunda boş state tut
        if (mounted) {
          state = {};
        }
      }
    });
  }

  Future<void> _checkAllPermissions() async {
    final permissions = await _service.checkAllPermissions();
    state = permissions;
  }

  Future<void> refreshPermissions() async {
    await _checkAllPermissions();
  }

  Future<bool> requestLocationPermission() async {
    final result = await _service.ensureLocationPermission();
    await _checkAllPermissions();
    return result;
  }

  Future<bool> requestCameraPermission() async {
    final result = await _service.ensureCameraPermission();
    await _checkAllPermissions();
    return result;
  }

  Future<bool> requestStoragePermission() async {
    final result = await _service.ensureStoragePermission();
    await _checkAllPermissions();
    return result;
  }

  Future<bool> requestMicrophonePermission() async {
    final result = await _service.ensureMicrophonePermission();
    await _checkAllPermissions();
    return result;
  }

  Future<bool> requestNotificationPermission() async {
    final result = await _service.ensureNotificationPermission();
    await _checkAllPermissions();
    return result;
  }
}

/// İzin kontrol provider'ı
final permissionNotifierProvider =
    StateNotifierProvider<PermissionNotifier, Map<String, bool>>((ref) {
  final service = ref.read(permissionServiceProvider);
  return PermissionNotifier(service);
});
