// ========== TRANSACTION SERVICE ==========
// lib/core/firebase/transaction_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'firebase_service.dart';
import 'collections.dart';

/// Transaction türleri
enum TransactionType {
  sale('Satış'),
  purchase('Alış'),
  stockMovement('Stok Hareketi'),
  cashTransaction('Nakit İşlem'),
  customerTransaction('Müşteri İşlemi'),
  supplierTransaction('Tedarikçi İşlemi'),
  productTransaction('Ürün İşlemi'),
  accountTransaction('Hesap İşlemi');

  const TransactionType(this.displayName);
  final String displayName;
}

/// Transaction durumu
enum TransactionStatus {
  pending('Beklemede'),
  processing('İşleniyor'),
  completed('Tamamlandı'),
  failed('Başarısız'),
  cancelled('İptal Edildi');

  const TransactionStatus(this.displayName);
  final String displayName;
}

/// Transaction entity
class Transaction {
  final String id;
  final String type;
  final String status;
  final String
      entityType; // 'customer', 'supplier', 'product', 'sale', 'purchase', etc.
  final String entityId;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final Map<String, dynamic> data;
  final String? description;
  final String? reference;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;
  final String companyId;

  const Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.entityType,
    required this.entityId,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.data,
    this.description,
    this.reference,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
    required this.companyId,
  });
}

/// Çapraz kayıt sistemi servisi
class TransactionService {
  final FirebaseService _firebaseService = FirebaseService();
  final Logger _logger = Logger();

  /// Transaction oluştur
  Future<String> createTransaction({
    required String type,
    required String entityType,
    required String entityId,
    String? relatedEntityType,
    String? relatedEntityId,
    required Map<String, dynamic> data,
    String? description,
    String? reference,
  }) async {
    try {
      final transactionData = {
        'type': type,
        'status': TransactionStatus.pending.name,
        'entityType': entityType,
        'entityId': entityId,
        'relatedEntityType': relatedEntityType,
        'relatedEntityId': relatedEntityId,
        'data': data,
        'description': description,
        'reference': reference,
        'companyId': await _getCurrentCompanyId(),
      };

      final docRef = await _firebaseService.createDocument(
        FirebaseCollections.transactions,
        transactionData,
      );

      _logger.i('Transaction oluşturuldu: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.e('Transaction oluşturulurken hata: $e');
      rethrow;
    }
  }

  /// Transaction güncelle
  Future<void> updateTransaction(
    String transactionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['status'] = TransactionStatus.processing.name;
      await _firebaseService.updateDocument(
        FirebaseCollections.transactions,
        transactionId,
        updates,
      );
      _logger.i('Transaction güncellendi: $transactionId');
    } catch (e) {
      _logger.e('Transaction güncellenirken hata: $e');
      rethrow;
    }
  }

  /// Transaction tamamla
  Future<void> completeTransaction(String transactionId) async {
    try {
      await _firebaseService.updateDocument(
        FirebaseCollections.transactions,
        transactionId,
        {'status': TransactionStatus.completed.name},
      );
      _logger.i('Transaction tamamlandı: $transactionId');
    } catch (e) {
      _logger.e('Transaction tamamlanırken hata: $e');
      rethrow;
    }
  }

  /// Transaction başarısız olarak işaretle
  Future<void> failTransaction(
      String transactionId, String? errorMessage) async {
    try {
      await _firebaseService.updateDocument(
        FirebaseCollections.transactions,
        transactionId,
        {
          'status': TransactionStatus.failed.name,
          'errorMessage': errorMessage,
        },
      );
      _logger.i('Transaction başarısız: $transactionId');
    } catch (e) {
      _logger.e('Transaction başarısız işaretlenirken hata: $e');
      rethrow;
    }
  }

  /// Transaction iptal et
  Future<void> cancelTransaction(String transactionId) async {
    try {
      await _firebaseService.updateDocument(
        FirebaseCollections.transactions,
        transactionId,
        {'status': TransactionStatus.cancelled.name},
      );
      _logger.i('Transaction iptal edildi: $transactionId');
    } catch (e) {
      _logger.e('Transaction iptal edilirken hata: $e');
      rethrow;
    }
  }

  /// Entity'ye ait transaction'ları getir
  Future<List<Transaction>> getEntityTransactions({
    required String entityType,
    required String entityId,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      final snapshot = await _firebaseService.getCollectionData(
        FirebaseCollections.transactions,
        limit: limit,
        startAfter: startAfter,
        orderBy: FirebaseFields.createdAt,
        descending: true,
        whereConditions: {
          'entityType': entityType,
          'entityId': entityId,
          FirebaseFields.isDeleted: false,
        },
      );

      return snapshot.docs
          .map((doc) =>
              _mapToTransaction(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Entity transaction\'ları getirilirken hata: $e');
      rethrow;
    }
  }

  /// Transaction'ları gerçek zamanlı dinle
  Stream<List<Transaction>> listenToTransactions({
    String? entityType,
    String? entityId,
    String? status,
    int? limit,
  }) {
    try {
      final whereConditions = <String, dynamic>{
        FirebaseFields.isDeleted: false,
      };

      if (entityType != null) {
        whereConditions['entityType'] = entityType;
      }

      if (entityId != null) {
        whereConditions['entityId'] = entityId;
      }

      if (status != null) {
        whereConditions['status'] = status;
      }

      return _firebaseService
          .listenToCollection(
        FirebaseCollections.transactions,
        limit: limit,
        orderBy: FirebaseFields.createdAt,
        descending: true,
        whereConditions: whereConditions,
      )
          .map((snapshot) {
        return snapshot.docs
            .map((doc) =>
                _mapToTransaction(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      _logger.e('Transaction\'lar dinlenirken hata: $e');
      rethrow;
    }
  }

  /// Çapraz referans oluştur
  Future<void> createCrossReference({
    required String fromEntityType,
    required String fromEntityId,
    required String toEntityType,
    required String toEntityId,
    required String relationshipType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Her iki yönde de referans oluştur
      final batch = _firebaseService.batch();

      // İlk referans
      final ref1 = _firebaseService.firestore
          .collection(FirebaseCollections.transactions)
          .doc();
      batch.set(ref1, {
        'type': 'cross_reference',
        'status': TransactionStatus.completed.name,
        'entityType': fromEntityType,
        'entityId': fromEntityId,
        'relatedEntityType': toEntityType,
        'relatedEntityId': toEntityId,
        'relationshipType': relationshipType,
        'metadata': metadata ?? {},
        'description': '$fromEntityType -> $toEntityType referansı',
        'companyId': await _getCurrentCompanyId(),
        FirebaseFields.createdAt: FieldValue.serverTimestamp(),
        FirebaseFields.updatedAt: FieldValue.serverTimestamp(),
        FirebaseFields.createdBy: _firebaseService.currentUserId,
        FirebaseFields.updatedBy: _firebaseService.currentUserId,
        FirebaseFields.isActive: true,
        FirebaseFields.isDeleted: false,
      });

      // İkinci referans
      final ref2 = _firebaseService.firestore
          .collection(FirebaseCollections.transactions)
          .doc();
      batch.set(ref2, {
        'type': 'cross_reference',
        'status': TransactionStatus.completed.name,
        'entityType': toEntityType,
        'entityId': toEntityId,
        'relatedEntityType': fromEntityType,
        'relatedEntityId': fromEntityId,
        'relationshipType': relationshipType,
        'metadata': metadata ?? {},
        'description': '$toEntityType -> $fromEntityType referansı',
        'companyId': await _getCurrentCompanyId(),
        FirebaseFields.createdAt: FieldValue.serverTimestamp(),
        FirebaseFields.updatedAt: FieldValue.serverTimestamp(),
        FirebaseFields.createdBy: _firebaseService.currentUserId,
        FirebaseFields.updatedBy: _firebaseService.currentUserId,
        FirebaseFields.isActive: true,
        FirebaseFields.isDeleted: false,
      });

      await batch.commit();
      _logger.i(
          'Çapraz referans oluşturuldu: $fromEntityType:$fromEntityId <-> $toEntityType:$toEntityId');
    } catch (e) {
      _logger.e('Çapraz referans oluşturulurken hata: $e');
      rethrow;
    }
  }

  /// İlişkili entity'leri getir
  Future<List<Map<String, dynamic>>> getRelatedEntities({
    required String entityType,
    required String entityId,
    String? relationshipType,
  }) async {
    try {
      final snapshot = await _firebaseService.getCollectionData(
        FirebaseCollections.transactions,
        whereConditions: {
          'entityType': entityType,
          'entityId': entityId,
          'type': 'cross_reference',
          'status': TransactionStatus.completed.name,
          FirebaseFields.isDeleted: false,
        },
      );

      final relatedEntities = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (relationshipType == null ||
            data['relationshipType'] == relationshipType) {
          relatedEntities.add({
            'entityType': data['relatedEntityType'],
            'entityId': data['relatedEntityId'],
            'relationshipType': data['relationshipType'],
            'metadata': data['metadata'] ?? {},
            'createdAt': data[FirebaseFields.createdAt],
          });
        }
      }

      return relatedEntities;
    } catch (e) {
      _logger.e('İlişkili entity\'ler getirilirken hata: $e');
      rethrow;
    }
  }

  /// Transaction istatistiklerini getir
  Future<Map<String, dynamic>> getTransactionStats() async {
    try {
      final snapshot = await _firebaseService.getCollectionData(
        FirebaseCollections.transactions,
        whereConditions: {
          FirebaseFields.isDeleted: false,
        },
      );

      final transactions = snapshot.docs
          .map((doc) =>
              _mapToTransaction(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final totalTransactions = transactions.length;
      final pendingTransactions = transactions
          .where((t) => t.status == TransactionStatus.pending.name)
          .length;
      final completedTransactions = transactions
          .where((t) => t.status == TransactionStatus.completed.name)
          .length;
      final failedTransactions = transactions
          .where((t) => t.status == TransactionStatus.failed.name)
          .length;

      // Entity türlerine göre dağılım
      final entityTypeStats = <String, int>{};
      for (final transaction in transactions) {
        entityTypeStats[transaction.entityType] =
            (entityTypeStats[transaction.entityType] ?? 0) + 1;
      }

      return {
        'totalTransactions': totalTransactions,
        'pendingTransactions': pendingTransactions,
        'completedTransactions': completedTransactions,
        'failedTransactions': failedTransactions,
        'entityTypeStats': entityTypeStats,
      };
    } catch (e) {
      _logger.e('Transaction istatistikleri getirilirken hata: $e');
      rethrow;
    }
  }

  /// Mevcut şirket ID'sini al
  Future<String> _getCurrentCompanyId() async {
    final companyIds = await _firebaseService.getUserCompanyIds();
    return companyIds.isNotEmpty ? companyIds.first : '';
  }

  /// Map'i Transaction entity'sine çevir
  Transaction _mapToTransaction(String id, Map<String, dynamic> data) {
    return Transaction(
      id: id,
      type: data['type'] ?? '',
      status: data['status'] ?? TransactionStatus.pending.name,
      entityType: data['entityType'] ?? '',
      entityId: data['entityId'] ?? '',
      relatedEntityType: data['relatedEntityType'],
      relatedEntityId: data['relatedEntityId'],
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      description: data['description'],
      reference: data['reference'],
      createdAt: (data[FirebaseFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (data[FirebaseFields.updatedAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      createdBy: data[FirebaseFields.createdBy] ?? '',
      updatedBy: data[FirebaseFields.updatedBy],
      companyId: data['companyId'] ?? '',
    );
  }
}
