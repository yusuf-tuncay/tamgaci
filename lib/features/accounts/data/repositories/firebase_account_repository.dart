import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../models/firebase_account_entity.dart';

/// Firebase Account Repository Implementation
class FirebaseAccountRepository implements AccountRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tenant ID'yi al
  Future<String> _tenantId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      AppLogger.error('User is not authenticated');
      throw Exception('User not authenticated');
    }

    AppLogger.info('Getting tenant ID for user: ${user.uid}');

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      AppLogger.error('User document not found for user: ${user.uid}');
      throw Exception('User document not found');
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final tenantId = userData['tenantId'] as String?;

    AppLogger.info('User tenant ID: $tenantId');

    if (tenantId == null || tenantId.isEmpty) {
      AppLogger.error('User is not assigned to any tenant');
      throw Exception('User is not assigned to any tenant');
    }

    return tenantId;
  }

  /// User ID'yi al
  String? _uid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Future<List<Account>> getAccounts() async {
    try {
      AppLogger.info('Getting accounts...');
      final tenantId = await _tenantId();
      AppLogger.info('Tenant ID obtained: $tenantId');

      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .orderBy('createdAt', descending: true)
          .get();

      AppLogger.info('Found ${snapshot.docs.length} accounts');

      final accounts = snapshot.docs
          .map((doc) => FirebaseAccountEntity.fromFirestore(doc).toDomain())
          .toList();

      AppLogger.info('Successfully loaded ${accounts.length} accounts');
      return accounts;
    } catch (e) {
      AppLogger.error('Error getting accounts', e);
      rethrow;
    }
  }

  @override
  Future<Account?> getAccountById(String id) async {
    try {
      final tenantId = await _tenantId();
      final doc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .doc(id)
          .get();

      if (!doc.exists) return null;

      return FirebaseAccountEntity.fromFirestore(doc).toDomain();
    } catch (e) {
      AppLogger.error('Error getting account by id', e);
      rethrow;
    }
  }

  /// Tek bir hesabı realtime olarak dinle
  @override
  Stream<Account?> getAccountStream(String id) async* {
    try {
      final tenantId = await _tenantId();
      yield* _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .doc(id)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return null;
        return FirebaseAccountEntity.fromFirestore(doc).toDomain();
      });
    } catch (e) {
      AppLogger.error('Error getting account stream', e);
      yield null;
    }
  }

  @override
  Future<String> createAccount(Account account) async {
    try {
      final tenantId = await _tenantId();
      final userId = _uid();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final accountWithTenant = account.copyWith(
        tenantId: tenantId,
        createdBy: userId,
        updatedBy: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final accountEntity = FirebaseAccountEntity.fromDomain(accountWithTenant);

      final docRef = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .add(accountEntity.toFirestore());

      AppLogger.info('Account created successfully: ${account.name}');
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating account', e);
      rethrow;
    }
  }

  @override
  Future<void> updateAccount(Account account) async {
    try {
      final tenantId = await _tenantId();
      final userId = _uid();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final accountWithTenant = account.copyWith(
        tenantId: tenantId,
        updatedBy: userId,
        updatedAt: DateTime.now(),
      );
      final accountEntity = FirebaseAccountEntity.fromDomain(accountWithTenant);

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .doc(account.id)
          .update(accountEntity.toFirestore());

      AppLogger.info('Account updated successfully: ${account.name}');
    } catch (e) {
      AppLogger.error('Error updating account', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    try {
      final tenantId = await _tenantId();

      // Önce hesabı kontrol et
      final accountDoc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .doc(id)
          .get();

      if (!accountDoc.exists) {
        throw Exception('Hesap bulunamadı');
      }

      final accountData = accountDoc.data() as Map<String, dynamic>;
      final isDefault = accountData['isDefault'] as bool? ?? false;

      if (isDefault) {
        throw Exception('Varsayılan hesaplar silinemez');
      }

      double readNumeric(String key) {
        final value = accountData[key];
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }

      const balanceTolerance = 0.01;
      final balance = readNumeric('balance');
      final availableBalance = readNumeric('availableBalance');
      final blockedAmount = readNumeric('blockedAmount');

      final hasBalance = balance.abs() > balanceTolerance ||
          availableBalance.abs() > balanceTolerance ||
          blockedAmount.abs() > balanceTolerance;

      if (hasBalance) {
        throw Exception(
            'Bakiyesi olan hesaplar silinemez. Lütfen bakiyeleri sıfırlayın.');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .doc(id)
          .delete();

      AppLogger.info('Account deleted successfully: $id');
    } catch (e) {
      AppLogger.error('Error deleting account', e);
      rethrow;
    }
  }

  @override
  Future<List<Account>> searchAccounts(String query) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();

      return snapshot.docs
          .map((doc) => FirebaseAccountEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error searching accounts', e);
      rethrow;
    }
  }

  @override
  Future<List<Account>> getAccountsByCurrency(String currency) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .where('currency', isEqualTo: currency)
          .get();

      return snapshot.docs
          .map((doc) => FirebaseAccountEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting accounts by currency', e);
      rethrow;
    }
  }

  @override
  Future<List<Account>> getActiveAccounts() async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => FirebaseAccountEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting active accounts', e);
      rethrow;
    }
  }

  @override
  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      final tenantId = await _tenantId();

      // Mevcut hesap bilgilerini al (blockedAmount için)
      final accountDoc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .doc(accountId)
          .get();

      if (!accountDoc.exists) {
        throw Exception('Account not found: $accountId');
      }

      final accountData = accountDoc.data()!;
      final blockedAmount =
          (accountData['blockedAmount'] as num?)?.toDouble() ?? 0.0;
      final availableBalance = newBalance - blockedAmount;

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .doc(accountId)
          .update({
        'balance': newBalance,
        'availableBalance': availableBalance,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid() ?? 'system',
      });

      AppLogger.info(
          'Account balance updated: $accountId -> $newBalance (available: $availableBalance)');
    } catch (e) {
      AppLogger.error('Error updating account balance', e);
      rethrow;
    }
  }

  @override
  Future<void> updateAccountStatus(
      String accountId, AccountStatus status) async {
    try {
      final tenantId = await _tenantId();
      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .doc(accountId)
          .update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid() ?? 'system',
      });

      AppLogger.info('Account status updated: $accountId -> ${status.name}');
    } catch (e) {
      AppLogger.error('Error updating account status', e);
      rethrow;
    }
  }
}
