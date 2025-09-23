// ========== STORAGE PERMISSION SERVICE ==========
// lib/core/services/permissions/storage_permission_service.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class StoragePermissionService {
  const StoragePermissionService();

  /// Ensures the app has permissions needed to read/write media (images) from/to device storage/camera roll.
  /// Returns true if granted or not required (web/desktop), false otherwise.
  Future<bool> ensureMediaPermissions() async {
    if (kIsWeb) return true; // Web doesn't require runtime storage permissions

    final List<Permission> toRequest = <Permission>[];

    if (Platform.isAndroid) {
      // Camera for capture, Storage for legacy (< Android 13), ManageExternalStorage for some vendors
      toRequest.add(Permission.camera);
      toRequest.add(Permission.storage);
      // Attempt broader access if available (ignored on older SDKs)
      toRequest.add(Permission.manageExternalStorage);
    } else if (Platform.isIOS) {
      // iOS requires Photos (read/write) and optionally Camera
      toRequest.add(Permission.photos);
      toRequest.add(Permission.camera);
    } else if (Platform.isMacOS) {
      toRequest.add(Permission.photos);
    } else {
      // Windows/Linux typically do not require runtime storage permission
      return true;
    }

    bool anyPermanentlyDenied = false;
    for (final p in toRequest) {
      final status = await p.status;
      if (status.isGranted) continue;
      final req = await p.request();
      if (!req.isGranted) {
        if (req.isPermanentlyDenied) {
          anyPermanentlyDenied = true;
        } else {
          // If any critical permission denied, fail
          return false;
        }
      }
    }

    if (anyPermanentlyDenied) {
      // Let caller decide to open settings; return false to indicate not available
      return false;
    }
    return true;
  }

  /// Opens OS app settings so user can grant permissions manually.
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
