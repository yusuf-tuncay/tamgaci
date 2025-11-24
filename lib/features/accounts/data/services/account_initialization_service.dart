import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import '../models/firebase_account_entity.dart';
import '../../domain/entities/account.dart';

/// Otomatik hesap oluşturma servisi
class AccountInitializationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Kullanıcı için varsayılan hesapları oluştur
  Future<void> initializeDefaultAccounts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.warning(
            'Kullanıcı giriş yapmamış, varsayılan hesaplar oluşturulamadı');
        return;
      }

      AppLogger.info('Varsayılan hesaplar oluşturuluyor...');

      // Kullanıcının tenantId'sini al
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        AppLogger.warning('Kullanıcı dokümanı bulunamadı');
        return;
      }

      final tenantId = userDoc.data()?['tenantId'] as String?;
      if (tenantId == null) {
        AppLogger.warning('Kullanıcının tenantId\'si bulunamadı');
        return;
      }

      AppLogger.info('Tenant ID: $tenantId');

      final tenantDocRef = _firestore.collection('tenants').doc(tenantId);
      final tenantSnapshot = await tenantDocRef.get();
      final alreadyInitialized =
          tenantSnapshot.data()?['defaultAccountsInitialized'] as bool? ??
              false;

      if (alreadyInitialized) {
        AppLogger.info(
            'Varsayılan hesaplar daha önce oluşturulmuş, işlem yapılmadı');
        return;
      }

      // Koleksiyonda herhangi bir hesap varsa tekrar oluşturma
      final existingAccountsSnapshot =
          await tenantDocRef.collection('accounts').limit(1).get();

      if (existingAccountsSnapshot.docs.isNotEmpty) {
        AppLogger.info(
            'Tenant için hesaplar zaten mevcut, varsayılan oluşturma atlandı');
        await tenantDocRef.set(
          {
            'defaultAccountsInitialized': true,
            'defaultAccountsInitializedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        return;
      }

      await _createDefaultAccounts(
        tenantDocRef: tenantDocRef,
        tenantId: tenantId,
        userId: user.uid,
      );

      AppLogger.info('Varsayılan hesaplar başarıyla oluşturuldu');
    } on FirebaseException catch (e) {
      AppLogger.error(
          'Varsayılan hesaplar oluşturulurken Firestore hatası: code=${e.code}, message=${e.message}',
          e);
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Varsayılan hesaplar oluşturulurken beklenmeyen hata', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _createDefaultAccounts({
    required DocumentReference<Map<String, dynamic>> tenantDocRef,
    required String tenantId,
    required String userId,
  }) async {
    AppLogger.info(
        '_createDefaultAccounts başlatılıyor: tenantId=$tenantId, userId=$userId');

    try {
      int createdCount = 0;
      int skippedCount = 0;

      await _firestore.runTransaction((transaction) async {
        AppLogger.info('Transaction başladı');

        final tenantSnapshot = await transaction.get(tenantDocRef);
        final alreadyInitialized =
            tenantSnapshot.data()?['defaultAccountsInitialized'] as bool? ??
                false;

        if (alreadyInitialized) {
          AppLogger.info(
              'Zaten initialize edilmiş, transaction sonlandırılıyor');
          return;
        }

        AppLogger.info(
            '${_defaultAccountDefinitions.length} varsayılan hesap kontrol ediliyor');

        // ÖNCE: Tüm read işlemlerini yap (Firestore transaction kuralı)
        final accountSnapshots =
            <String, DocumentSnapshot<Map<String, dynamic>>>{};
        for (final template in _defaultAccountDefinitions) {
          final docRef =
              tenantDocRef.collection('accounts').doc(template.documentId);
          final accountSnapshot = await transaction.get(docRef);
          accountSnapshots[template.documentId] = accountSnapshot;
        }

        // SONRA: Tüm write işlemlerini yap
        for (final template in _defaultAccountDefinitions) {
          final accountSnapshot = accountSnapshots[template.documentId]!;

          // Sadece yoksa oluştur
          if (!accountSnapshot.exists) {
            AppLogger.info('Hesap oluşturuluyor: ${template.name}');

            final account = template.toAccount(tenantId, userId);
            final accountEntity = FirebaseAccountEntity.fromDomain(account);
            final firestoreData = accountEntity.toFirestore();

            final docRef =
                tenantDocRef.collection('accounts').doc(template.documentId);
            transaction.set(docRef, firestoreData);
            createdCount++;
          } else {
            AppLogger.info('Hesap zaten mevcut, atlanıyor: ${template.name}');
            skippedCount++;
          }
        }

        AppLogger.info('Tenant flag güncelleniyor');
        transaction.set(
          tenantDocRef,
          {
            'defaultAccountsInitialized': true,
            'defaultAccountsInitializedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        AppLogger.info(
            'Transaction commit ediliyor: $createdCount yeni, $skippedCount zaten mevcut');
      });

      AppLogger.info(
          'Transaction başarılı: $createdCount yeni hesap oluşturuldu, $skippedCount zaten mevcuttu');
    } on FirebaseException catch (e) {
      AppLogger.error(
          'Firestore transaction hatası: code=${e.code}, message=${e.message}',
          e);
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Varsayılan hesaplar oluşturulurken beklenmeyen hata', e, stackTrace);
      rethrow;
    }
  }
}

class _DefaultAccountDefinition {
  final String key;
  final String name;
  final String accountNumber;
  final AccountType type;
  final String currency;
  final String bankName;
  final String description;
  final String notes;

  const _DefaultAccountDefinition({
    required this.key,
    required this.name,
    required this.accountNumber,
    required this.type,
    required this.currency,
    required this.bankName,
    required this.description,
    required this.notes,
  });

  String get documentId => 'default_account_$key';

  Account toAccount(String tenantId, String userId) {
    final now = DateTime.now();
    return Account(
      id: documentId,
      name: name,
      accountNumber: accountNumber,
      iban: '',
      swiftCode: '',
      bankName: bankName,
      branchName: '',
      currency: currency,
      balance: 0.0,
      availableBalance: 0.0,
      blockedAmount: 0.0,
      type: type,
      status: AccountStatus.active,
      isActive: true,
      isDefault: true,
      description: description,
      notes: notes,
      tenantId: tenantId,
      createdBy: userId,
      updatedBy: userId,
      createdAt: now,
      updatedAt: now,
    );
  }
}

const List<_DefaultAccountDefinition> _defaultAccountDefinitions = [
  _DefaultAccountDefinition(
    key: 'cash_try',
    name: 'Nakit Kasa',
    accountNumber: 'CASH-001',
    type: AccountType.cash,
    currency: 'TRY',
    bankName: 'Nakit Kasa',
    description: 'Ana nakit kasa hesabı',
    notes: 'Otomatik oluşturulan varsayılan hesap',
  ),
  _DefaultAccountDefinition(
    key: 'credit_card',
    name: 'Kredi Kartı',
    accountNumber: 'CC-001',
    type: AccountType.credit,
    currency: 'TRY',
    bankName: 'Kredi Kartı',
    description: 'Kredi kartı hesabı',
    notes: 'Otomatik oluşturulan varsayılan hesap',
  ),
  _DefaultAccountDefinition(
    key: 'check_tr',
    name: 'Çek Hesabı',
    accountNumber: 'CHECK-001',
    type: AccountType.other,
    currency: 'TRY',
    bankName: 'Çek Hesabı',
    description: 'Çek işlemleri hesabı',
    notes: 'Otomatik oluşturulan varsayılan hesap',
  ),
  _DefaultAccountDefinition(
    key: 'promissory_tr',
    name: 'Senet Hesabı',
    accountNumber: 'PROM-001',
    type: AccountType.other,
    currency: 'TRY',
    bankName: 'Senet Hesabı',
    description: 'Senet işlemleri hesabı',
    notes: 'Otomatik oluşturulan varsayılan hesap',
  ),
  _DefaultAccountDefinition(
    key: 'pos_tr',
    name: 'POS Hesabı',
    accountNumber: 'POS-001',
    type: AccountType.other,
    currency: 'TRY',
    bankName: 'POS Hesabı',
    description: 'POS işlemleri hesabı',
    notes: 'Otomatik oluşturulan varsayılan hesap',
  ),
  _DefaultAccountDefinition(
    key: 'cash_usd',
    name: 'USD Kasa',
    accountNumber: 'USD-001',
    type: AccountType.cash,
    currency: 'USD',
    bankName: 'USD Kasa',
    description: 'USD nakit kasa hesabı',
    notes: 'Otomatik oluşturulan varsayılan hesap',
  ),
  _DefaultAccountDefinition(
    key: 'cash_eur',
    name: 'EUR Kasa',
    accountNumber: 'EUR-001',
    type: AccountType.cash,
    currency: 'EUR',
    bankName: 'EUR Kasa',
    description: 'EUR nakit kasa hesabı',
    notes: 'Otomatik oluşturulan varsayılan hesap',
  ),
];
