// ========== FIREBASE STORAGE SERVICE ==========
// lib/features/products/data/services/firebase_storage_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

/// Firebase Storage servis sınıfı
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Fotoğraf yükle
  Future<String> uploadProductImage(String productId, File imageFile) async {
    try {
      final fileName = path.basename(imageFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';

      final ref = _storage
          .ref()
          .child('products')
          .child(productId)
          .child(uniqueFileName);

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Fotoğraf yüklenirken hata: $e');
    }
  }

  /// Birden fazla fotoğraf yükle
  Future<List<String>> uploadProductImages(
      String productId, List<File> imageFiles) async {
    try {
      final List<String> downloadUrls = [];

      for (final imageFile in imageFiles) {
        final downloadUrl = await uploadProductImage(productId, imageFile);
        downloadUrls.add(downloadUrl);
      }

      return downloadUrls;
    } catch (e) {
      throw Exception('Fotoğraflar yüklenirken hata: $e');
    }
  }

  /// Fotoğraf sil
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Fotoğraf silinirken hata: $e');
    }
  }

  /// Ürün fotoğraflarını sil
  Future<void> deleteProductImages(List<String> imageUrls) async {
    try {
      for (final imageUrl in imageUrls) {
        await deleteProductImage(imageUrl);
      }
    } catch (e) {
      throw Exception('Fotoğraflar silinirken hata: $e');
    }
  }

  /// Bytes ile fotoğraf yükle (Web için)
  Future<String> uploadProductImageBytes(String productId, Uint8List imageBytes, String fileName) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      
      final ref = _storage
          .ref()
          .child('products')
          .child(productId)
          .child(uniqueFileName);

      final uploadTask = await ref.putData(imageBytes);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Fotoğraf yüklenirken hata: $e');
    }
  }

  /// Birden fazla fotoğraf yükle (Bytes - Web için)
  Future<List<String>> uploadProductImageBytesList(String productId, List<Uint8List> imageBytes) async {
    try {
      final List<String> downloadUrls = [];
      
      for (int i = 0; i < imageBytes.length; i++) {
        final downloadUrl = await uploadProductImageBytes(productId, imageBytes[i], 'image_$i.jpg');
        downloadUrls.add(downloadUrl);
      }
      
      return downloadUrls;
    } catch (e) {
      throw Exception('Fotoğraflar yüklenirken hata: $e');
    }
  }
}
