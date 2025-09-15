import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/cash_management/data/models/cash_account_model.dart';
import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';

/// CashAccount Firebase DataSource
/// Firebase Firestore ile doğrudan etkileşimi yönetir.
class CashAccountFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CashAccountFirebaseDataSource(this._firestore, this._firebaseAuth);

  /// Tüm nakit hesapları getirir
  Future<List<CashAccountModel>> getAllCashAccounts({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('cash_accounts')
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('cash_accounts')
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CashAccountModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all cash accounts', e);
      rethrow;
    }
  }

  /// ID'ye göre nakit hesap getirir
  Future<CashAccountModel?> getCashAccountById(String id) async {
    try {
      final doc = await _firestore.collection('cash_accounts').doc(id).get();
      if (doc.exists) {
        return CashAccountModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting cash account by id: $id', e);
      rethrow;
    }
  }

  /// Türüne göre nakit hesapları getirir
  Future<List<CashAccountModel>> getCashAccountsByType(
    CashAccountType type, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('cash_accounts')
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('cash_accounts')
            .where('type', isEqualTo: type.name)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CashAccountModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting cash accounts by type: ${type.name}', e);
      rethrow;
    }
  }

  /// Duruma göre nakit hesapları getirir
  Future<List<CashAccountModel>> getCashAccountsByStatus(
    CashAccountStatus status, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('cash_accounts')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('cash_accounts')
            .where('status', isEqualTo: status.name)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CashAccountModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting cash accounts by status: ${status.name}', e);
      rethrow;
    }
  }

  /// Varsayılan nakit hesabı getirir
  Future<CashAccountModel?> getDefaultCashAccount() async {
    try {
      final snapshot = await _firestore
          .collection('cash_accounts')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return CashAccountModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting default cash account', e);
      rethrow;
    }
  }

  /// Yeni nakit hesap oluşturur
  Future<CashAccountModel> createCashAccount(
      CashAccountModel cashAccount) async {
    try {
      final docRef = _firestore.collection('cash_accounts').doc();
      final newCashAccount = cashAccount.copyWith(id: docRef.id);

      await docRef.set(newCashAccount.toFirestore());
      AppLogger.info('Cash account created: ${newCashAccount.name}');
      return newCashAccount;
    } catch (e) {
      AppLogger.error('Error creating cash account', e);
      rethrow;
    }
  }

  /// Nakit hesap günceller
  Future<CashAccountModel> updateCashAccount(
      CashAccountModel cashAccount) async {
    try {
      await _firestore
          .collection('cash_accounts')
          .doc(cashAccount.id)
          .update(cashAccount.toFirestore());

      AppLogger.info('Cash account updated: ${cashAccount.name}');
      return cashAccount;
    } catch (e) {
      AppLogger.error('Error updating cash account: ${cashAccount.id}', e);
      rethrow;
    }
  }

  /// Nakit hesap siler
  Future<void> deleteCashAccount(String id) async {
    try {
      await _firestore.collection('cash_accounts').doc(id).delete();
      AppLogger.info('Cash account deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting cash account: $id', e);
      rethrow;
    }
  }

  /// Nakit hesap arama
  Future<List<CashAccountModel>> searchCashAccounts(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Basit arama - name ve description'da arama
      final snapshot = await _firestore
          .collection('cash_accounts')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit ?? 50)
          .get();

      final results = snapshot.docs
          .map((doc) => CashAccountModel.fromFirestore(doc))
          .toList();

      // Eğer yeterli sonuç yoksa, description'da da ara
      if (results.length < (limit ?? 50)) {
        final descSnapshot = await _firestore
            .collection('cash_accounts')
            .where('description', isGreaterThanOrEqualTo: query)
            .where('description', isLessThanOrEqualTo: '$query\uf8ff')
            .limit((limit ?? 50) - results.length)
            .get();

        final descResults = descSnapshot.docs
            .map((doc) => CashAccountModel.fromFirestore(doc))
            .where((account) => !results.any((r) => r.id == account.id))
            .toList();

        results.addAll(descResults);
      }

      return results;
    } catch (e) {
      AppLogger.error('Error searching cash accounts: $query', e);
      rethrow;
    }
  }

  /// Nakit hesap sayısını getirir
  Future<int> getCashAccountsCount() async {
    try {
      final snapshot =
          await _firestore.collection('cash_accounts').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting cash accounts count', e);
      rethrow;
    }
  }

  /// Toplam bakiyeyi getirir
  Future<double> getTotalBalance({String? currency}) async {
    try {
      Query query = _firestore.collection('cash_accounts');

      if (currency != null) {
        query = query.where('currency', isEqualTo: currency);
      }

      final snapshot = await query.get();
      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['balance'] as num).toDouble();
      }
      return total;
    } catch (e) {
      AppLogger.error('Error getting total balance', e);
      rethrow;
    }
  }

  /// Türüne göre toplam bakiyeyi getirir
  Future<double> getTotalBalanceByType(CashAccountType type,
      {String? currency}) async {
    try {
      Query query = _firestore
          .collection('cash_accounts')
          .where('type', isEqualTo: type.name);

      if (currency != null) {
        query = query.where('currency', isEqualTo: currency);
      }

      final snapshot = await query.get();
      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['balance'] as num).toDouble();
      }
      return total;
    } catch (e) {
      AppLogger.error('Error getting total balance by type', e);
      rethrow;
    }
  }

  /// Nakit hesap istatistiklerini getirir
  Future<Map<String, dynamic>> getCashAccountsStatistics() async {
    try {
      final snapshot = await _firestore.collection('cash_accounts').get();
      final stats = <String, dynamic>{
        'totalCount': snapshot.docs.length,
        'totalBalance': 0.0,
        'typeCounts': <String, int>{},
        'statusCounts': <String, int>{},
      };

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final balance = (data['balance'] as num).toDouble();
        final type = data['type'] as String;
        final status = data['status'] as String;

        stats['totalBalance'] = (stats['totalBalance'] as double) + balance;

        stats['typeCounts'][type] =
            (stats['typeCounts'][type] as int? ?? 0) + 1;
        stats['statusCounts'][status] =
            (stats['statusCounts'][status] as int? ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      AppLogger.error('Error getting cash accounts statistics', e);
      rethrow;
    }
  }

  /// Nakit hesap numarası oluşturur
  Future<String> generateCashAccountNumber(CashAccountType type) async {
    try {
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');

      final prefix = type.name.toUpperCase();
      final datePrefix = '$year$month$day';

      // Bugünkü aynı tipte kaç tane hesap var?
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('cash_accounts')
          .where('type', isEqualTo: type.name)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
          .get();

      final count = snapshot.docs.length + 1;
      final number = count.toString().padLeft(4, '0');

      return '$prefix-$datePrefix-$number';
    } catch (e) {
      AppLogger.error('Error generating cash account number', e);
      rethrow;
    }
  }
}
