// ========== COMPANY LOGO SERVICE ==========
// lib/core/services/storage/company_logo_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tamgaci/core/services/tenant_service.dart';

/// Company logo upload service
class CompanyLogoService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TenantService _tenantService = TenantService();
  final ImagePicker _picker = ImagePicker();

  /// Logo yükle (mobil)
  Future<String> uploadCompanyLogo(File imageFile) async {
    try {
      final tenantId = await _tenantService.getUserTenantId();
      if (tenantId == null) {
        throw Exception('Tenant ID bulunamadı');
      }

      final fileName =
          'company_logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'companies/$tenantId/logo/$fileName';
      final storageRef = _storage.ref().child(storagePath);

      debugPrint('🔄 Logo yükleniyor...');
      debugPrint('📁 Storage path: $storagePath');
      debugPrint('📊 File size: ${await imageFile.length()} bytes');

      // Upload with metadata
      final uploadTask = await storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'tenantId': tenantId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'company_logo',
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint('✅ Logo başarıyla yüklendi: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      throw Exception('Logo yüklenirken hata: $e');
    }
  }

  /// Logo yükle (web)
  Future<String> uploadCompanyLogoBytes(Uint8List imageBytes) async {
    try {
      final tenantId = await _tenantService.getUserTenantId();
      if (tenantId == null) {
        throw Exception('Tenant ID bulunamadı');
      }

      final fileName =
          'company_logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'companies/$tenantId/logo/$fileName';
      final storageRef = _storage.ref().child(storagePath);

      debugPrint('🔄 Logo yükleniyor (Web)...');
      debugPrint('📁 Storage path: $storagePath');
      debugPrint('📊 Bytes size: ${imageBytes.length} bytes');

      // Auto-detect content type
      String contentType = 'image/jpeg';
      if (imageBytes.length > 8) {
        // Check PNG signature
        if (imageBytes[0] == 0x89 &&
            imageBytes[1] == 0x50 &&
            imageBytes[2] == 0x4E &&
            imageBytes[3] == 0x47) {
          contentType = 'image/png';
        }
        // Check JPEG signature
        else if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
          contentType = 'image/jpeg';
        }
        // Check WebP signature
        else if (imageBytes[0] == 0x52 &&
            imageBytes[1] == 0x49 &&
            imageBytes[2] == 0x46 &&
            imageBytes[3] == 0x46) {
          contentType = 'image/webp';
        }
      }

      debugPrint('📷 Content type: $contentType');

      // Upload with metadata
      final uploadTask = await storageRef.putData(
        imageBytes,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'tenantId': tenantId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'company_logo',
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint('✅ Logo başarıyla yüklendi (Web): $downloadUrl');
      return downloadUrl;
    } catch (e) {
      throw Exception('Logo yüklenirken hata: $e');
    }
  }

  /// Logo sil
  Future<void> deleteCompanyLogo(String logoUrl) async {
    try {
      final ref = _storage.refFromURL(logoUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Logo silinirken hata: $e');
    }
  }

  /// Galeriden logo seç
  Future<XFile?> pickLogoFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Logo seçilirken hata: $e');
    }
  }

  /// Kameradan logo çek
  Future<XFile?> pickLogoFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Logo çekilirken hata: $e');
    }
  }

  /// Logo seçim menüsü göster
  Future<XFile?> showLogoPickerMenu() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Logo seçilirken hata: $e');
    }
  }
}
