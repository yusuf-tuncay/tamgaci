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

      // Varsayılan hesapları kontrol et
      final existingAccounts = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .get();

      AppLogger.info('Mevcut hesap sayısı: ${existingAccounts.docs.length}');

      if (existingAccounts.docs.isNotEmpty) {
        AppLogger.info('Varsayılan hesaplar zaten mevcut');
        return;
      }

      // Varsayılan hesapları oluştur
      await _createDefaultAccounts(tenantId, user.uid);

      AppLogger.info('Varsayılan hesaplar başarıyla oluşturuldu');
    } catch (e) {
      AppLogger.error('Varsayılan hesaplar oluşturulurken hata', e);
    }
  }

  /// Varsayılan hesapları oluştur
  Future<void> _createDefaultAccounts(String tenantId, String userId) async {
    final now = DateTime.now();
    final accounts = [
      // Nakit Kasası
      Account(
        id: '',
        name: 'Nakit Kasa',
        accountNumber: 'CASH-001',
        iban: '',
        swiftCode: '',
        bankName: 'Nakit Kasa',
        branchName: '',
        currency: 'TRY',
        balance: 0.0,
        availableBalance: 0.0,
        blockedAmount: 0.0,
        type: AccountType.cash,
        status: AccountStatus.active,
        isActive: true,
        isDefault: true, // Varsayılan hesap
        description: 'Ana nakit kasa hesabı',
        notes: 'Otomatik oluşturulan varsayılan hesap',
        tenantId: tenantId,
        createdBy: userId,
        updatedBy: userId,
        createdAt: now,
        updatedAt: now,
      ),

      // Kredi Kartı
      Account(
        id: '',
        name: 'Kredi Kartı',
        accountNumber: 'CC-001',
        iban: '',
        swiftCode: '',
        bankName: 'Kredi Kartı',
        branchName: '',
        currency: 'TRY',
        balance: 0.0,
        availableBalance: 0.0,
        blockedAmount: 0.0,
        type: AccountType.credit,
        status: AccountStatus.active,
        isActive: true,
        isDefault: true, // Varsayılan hesap
        description: 'Kredi kartı hesabı',
        notes: 'Otomatik oluşturulan varsayılan hesap',
        tenantId: tenantId,
        createdBy: userId,
        updatedBy: userId,
        createdAt: now,
        updatedAt: now,
      ),

      // Çek Hesabı
      Account(
        id: '',
        name: 'Çek Hesabı',
        accountNumber: 'CHECK-001',
        iban: '',
        swiftCode: '',
        bankName: 'Çek Hesabı',
        branchName: '',
        currency: 'TRY',
        balance: 0.0,
        availableBalance: 0.0,
        blockedAmount: 0.0,
        type: AccountType.other,
        status: AccountStatus.active,
        isActive: true,
        isDefault: true, // Varsayılan hesap
        description: 'Çek işlemleri hesabı',
        notes: 'Otomatik oluşturulan varsayılan hesap',
        tenantId: tenantId,
        createdBy: userId,
        updatedBy: userId,
        createdAt: now,
        updatedAt: now,
      ),

      // Senet Hesabı
      Account(
        id: '',
        name: 'Senet Hesabı',
        accountNumber: 'PROM-001',
        iban: '',
        swiftCode: '',
        bankName: 'Senet Hesabı',
        branchName: '',
        currency: 'TRY',
        balance: 0.0,
        availableBalance: 0.0,
        blockedAmount: 0.0,
        type: AccountType.other,
        status: AccountStatus.active,
        isActive: true,
        isDefault: true, // Varsayılan hesap
        description: 'Senet işlemleri hesabı',
        notes: 'Otomatik oluşturulan varsayılan hesap',
        tenantId: tenantId,
        createdBy: userId,
        updatedBy: userId,
        createdAt: now,
        updatedAt: now,
      ),

      // POS Hesabı
      Account(
        id: '',
        name: 'POS Hesabı',
        accountNumber: 'POS-001',
        iban: '',
        swiftCode: '',
        bankName: 'POS Hesabı',
        branchName: '',
        currency: 'TRY',
        balance: 0.0,
        availableBalance: 0.0,
        blockedAmount: 0.0,
        type: AccountType.other,
        status: AccountStatus.active,
        isActive: true,
        isDefault: true, // Varsayılan hesap
        description: 'POS işlemleri hesabı',
        notes: 'Otomatik oluşturulan varsayılan hesap',
        tenantId: tenantId,
        createdBy: userId,
        updatedBy: userId,
        createdAt: now,
        updatedAt: now,
      ),

      // USD Kasa
      Account(
        id: '',
        name: 'USD Kasa',
        accountNumber: 'USD-001',
        iban: '',
        swiftCode: '',
        bankName: 'USD Kasa',
        branchName: '',
        currency: 'USD',
        balance: 0.0,
        availableBalance: 0.0,
        blockedAmount: 0.0,
        type: AccountType.cash,
        status: AccountStatus.active,
        isActive: true,
        isDefault: true, // Varsayılan hesap
        description: 'USD nakit kasa hesabı',
        notes: 'Otomatik oluşturulan varsayılan hesap',
        tenantId: tenantId,
        createdBy: userId,
        updatedBy: userId,
        createdAt: now,
        updatedAt: now,
      ),

      // EUR Kasa
      Account(
        id: '',
        name: 'EUR Kasa',
        accountNumber: 'EUR-001',
        iban: '',
        swiftCode: '',
        bankName: 'EUR Kasa',
        branchName: '',
        currency: 'EUR',
        balance: 0.0,
        availableBalance: 0.0,
        blockedAmount: 0.0,
        type: AccountType.cash,
        status: AccountStatus.active,
        isActive: true,
        isDefault: true, // Varsayılan hesap
        description: 'EUR nakit kasa hesabı',
        notes: 'Otomatik oluşturulan varsayılan hesap',
        tenantId: tenantId,
        createdBy: userId,
        updatedBy: userId,
        createdAt: now,
        updatedAt: now,
      ),

      // GBP Kasa
      Account(
        id: '',
        name: 'GBP Kasa',
        accountNumber: 'GBP-001',
        iban: '',
        swiftCode: '',
        bankName: 'GBP Kasa',
        branchName: '',
        currency: 'GBP',
        balance: 0.0,
        availableBalance: 0.0,
        blockedAmount: 0.0,
        type: AccountType.cash,
        status: AccountStatus.active,
        isActive: true,
        isDefault: true, // Varsayılan hesap
        description: 'GBP nakit kasa hesabı',
        notes: 'Otomatik oluşturulan varsayılan hesap',
        tenantId: tenantId,
        createdBy: userId,
        updatedBy: userId,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // Hesapları Firestore'a kaydet
    final batch = _firestore.batch();
    for (final account in accounts) {
      final accountEntity = FirebaseAccountEntity.fromDomain(account);
      final docRef = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accounts')
          .doc();

      batch.set(docRef, accountEntity.toFirestore());
    }

    await batch.commit();
    AppLogger.info('${accounts.length} varsayılan hesap oluşturuldu');
  }
}
