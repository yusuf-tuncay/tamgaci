// ========== FIREBASE SERVICE ==========
// lib/core/firebase/firebase_service.dart

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'collections.dart';

/// Firebase servis sınıfı
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();

  // Getters
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseStorage get storage => _storage;
  Logger get logger => _logger;

  /// Kullanıcı ID'sini al
  String? get currentUserId => _auth.currentUser?.uid;

  /// Kullanıcının şirket ID'lerini al
  Future<List<String>> getUserCompanyIds() async {
    try {
      final userDoc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        return List<String>.from(data?['companies'] ?? []);
      }
      return [];
    } catch (e) {
      _logger.e('Kullanıcı şirket ID\'leri alınırken hata: $e');
      return [];
    }
  }

  /// Koleksiyon referansı al
  CollectionReference getCollection(String collectionName) {
    return _firestore.collection(collectionName);
  }

  /// Doküman referansı al
  DocumentReference getDocument(String collectionName, String docId) {
    return _firestore.collection(collectionName).doc(docId);
  }

  /// Alt koleksiyon referansı al
  CollectionReference getSubCollection(
    String collectionName,
    String docId,
    String subCollectionName,
  ) {
    return _firestore
        .collection(collectionName)
        .doc(docId)
        .collection(subCollectionName);
  }

  /// Batch işlem başlat
  WriteBatch batch() {
    return _firestore.batch();
  }

  /// Transaction başlat
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) {
    return _firestore.runTransaction(updateFunction);
  }

  /// Doküman oluştur
  Future<DocumentReference> createDocument(
    String collectionName,
    Map<String, dynamic> data,
  ) async {
    try {
      // Otomatik alanları ekle
      data[FirebaseFields.createdAt] = FieldValue.serverTimestamp();
      data[FirebaseFields.updatedAt] = FieldValue.serverTimestamp();
      data[FirebaseFields.createdBy] = currentUserId;
      data[FirebaseFields.updatedBy] = currentUserId;
      data[FirebaseFields.isActive] = true;
      data[FirebaseFields.isDeleted] = false;

      final docRef = await _firestore.collection(collectionName).add(data);
      _logger.i('Doküman oluşturuldu: $collectionName/${docRef.id}');
      return docRef;
    } catch (e) {
      _logger.e('Doküman oluşturulurken hata: $e');
      rethrow;
    }
  }

  /// Doküman güncelle
  Future<void> updateDocument(
    String collectionName,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Otomatik alanları ekle
      data[FirebaseFields.updatedAt] = FieldValue.serverTimestamp();
      data[FirebaseFields.updatedBy] = currentUserId;

      await _firestore.collection(collectionName).doc(docId).update(data);
      _logger.i('Doküman güncellendi: $collectionName/$docId');
    } catch (e) {
      _logger.e('Doküman güncellenirken hata: $e');
      rethrow;
    }
  }

  /// Doküman sil (soft delete)
  Future<void> deleteDocument(String collectionName, String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).update({
        FirebaseFields.isDeleted: true,
        FirebaseFields.updatedAt: FieldValue.serverTimestamp(),
        FirebaseFields.updatedBy: currentUserId,
      });
      _logger.i('Doküman silindi: $collectionName/$docId');
    } catch (e) {
      _logger.e('Doküman silinirken hata: $e');
      rethrow;
    }
  }

  /// Doküman kalıcı olarak sil
  Future<void> permanentlyDeleteDocument(
    String collectionName,
    String docId,
  ) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
      _logger.i('Doküman kalıcı olarak silindi: $collectionName/$docId');
    } catch (e) {
      _logger.e('Doküman kalıcı olarak silinirken hata: $e');
      rethrow;
    }
  }

  /// Doküman oku
  Future<DocumentSnapshot> getDocumentById(
    String collectionName,
    String docId,
  ) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(docId).get();
      return doc;
    } catch (e) {
      _logger.e('Doküman okunurken hata: $e');
      rethrow;
    }
  }

  /// Koleksiyon oku
  Future<QuerySnapshot> getCollectionData(
    String collectionName, {
    int? limit,
    DocumentSnapshot? startAfter,
    String? orderBy,
    bool descending = false,
    Map<String, dynamic>? whereConditions,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);

      // Where koşulları ekle
      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      // Sıralama ekle
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Limit ekle
      if (limit != null) {
        query = query.limit(limit);
      }

      // Başlangıç noktası ekle
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot;
    } catch (e) {
      _logger.e('Koleksiyon okunurken hata: $e');
      rethrow;
    }
  }

  /// Gerçek zamanlı dinleyici başlat
  Stream<QuerySnapshot> listenToCollection(
    String collectionName, {
    int? limit,
    String? orderBy,
    bool descending = false,
    Map<String, dynamic>? whereConditions,
  }) {
    try {
      Query query = _firestore.collection(collectionName);

      // Where koşulları ekle
      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      // Sıralama ekle
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Limit ekle
      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots();
    } catch (e) {
      _logger.e('Koleksiyon dinlenirken hata: $e');
      rethrow;
    }
  }

  /// Gerçek zamanlı doküman dinleyici başlat
  Stream<DocumentSnapshot> listenToDocument(
    String collectionName,
    String docId,
  ) {
    try {
      return _firestore.collection(collectionName).doc(docId).snapshots();
    } catch (e) {
      _logger.e('Doküman dinlenirken hata: $e');
      rethrow;
    }
  }

  /// Dosya yükle
  Future<String> uploadFile(
    String path,
    List<int> fileBytes,
    String fileName,
  ) async {
    try {
      final ref = _storage.ref().child('$path/$fileName');
      final uploadTask = ref.putData(
        Uint8List.fromList(fileBytes),
        SettableMetadata(contentType: 'application/octet-stream'),
      );
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      _logger.i('Dosya yüklendi: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('Dosya yüklenirken hata: $e');
      rethrow;
    }
  }

  /// Dosya sil
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
      _logger.i('Dosya silindi: $path');
    } catch (e) {
      _logger.e('Dosya silinirken hata: $e');
      rethrow;
    }
  }

  /// Dosya URL'si al
  Future<String> getFileUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      _logger.e('Dosya URL\'si alınırken hata: $e');
      rethrow;
    }
  }

  /// Toplu işlem örneği
  Future<void> batchOperation(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final type = operation['type'] as String;
        final collection = operation['collection'] as String;
        final docId = operation['docId'] as String?;
        final data = operation['data'] as Map<String, dynamic>?;

        switch (type) {
          case 'create':
            if (docId != null) {
              batch.set(_firestore.collection(collection).doc(docId), data!);
            } else {
              final docRef = _firestore.collection(collection).doc();
              batch.set(docRef, data!);
            }
            break;
          case 'update':
            batch.update(_firestore.collection(collection).doc(docId!), data!);
            break;
          case 'delete':
            batch.delete(_firestore.collection(collection).doc(docId!));
            break;
        }
      }

      await batch.commit();
      _logger.i('Toplu işlem tamamlandı: ${operations.length} işlem');
    } catch (e) {
      _logger.e('Toplu işlem sırasında hata: $e');
      rethrow;
    }
  }

  /// Firestore bağlantısını test et
  Future<bool> testConnection() async {
    try {
      await _firestore.collection('test').limit(1).get();
      _logger.i('Firestore bağlantısı başarılı');
      return true;
    } catch (e) {
      _logger.e('Firestore bağlantı hatası: $e');
      return false;
    }
  }

  /// Kullanıcı oturumunu kapat
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _logger.i('Kullanıcı oturumu kapatıldı');
    } catch (e) {
      _logger.e('Oturum kapatılırken hata: $e');
      rethrow;
    }
  }

  /// Kullanıcı oturum durumunu dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;
}
