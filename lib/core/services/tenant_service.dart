// ========== TENANT SERVICE ==========
// lib/core/services/tenant_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/entities/tenant.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Multi-tenant yönetimi servisi
class TenantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Kullanıcının tenant ID'sini al
  Future<String?> getUserTenantId() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['tenantId'] as String?;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting user tenant ID', e);
      return null;
    }
  }

  /// Kullanıcının tenant bilgilerini al
  Future<Tenant?> getUserTenant() async {
    try {
      final tenantId = await getUserTenantId();
      if (tenantId == null) return null;

      final tenantDoc =
          await _firestore.collection('tenants').doc(tenantId).get();
      if (tenantDoc.exists) {
        final tenantData = tenantDoc.data() as Map<String, dynamic>;
        return Tenant.fromJson(tenantData);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting user tenant', e);
      return null;
    }
  }

  /// Tenant oluştur
  Future<String?> createTenant({
    required String name,
    String? description,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final tenantRef = _firestore.collection('tenants').doc();
      final tenantId = tenantRef.id;

      final tenant = Tenant(
        id: tenantId,
        name: name,
        description: description,
        ownerId: user.uid,
        memberIds: [user.uid],
        settings: settings ?? {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tenantRef.set(tenant.toJson());

      // Kullanıcıyı tenant'a ata
      await _firestore.collection('users').doc(user.uid).update({
        'tenantId': tenantId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Tenant created successfully', {'tenantId': tenantId});
      return tenantId;
    } catch (e) {
      AppLogger.error('Error creating tenant', e);
      return null;
    }
  }

  /// Tenant ID'yi al (string döndürür)
  Future<String> getUserTenantIdString() async {
    final tenantId = await getUserTenantId();
    return tenantId ?? '';
  }

  /// Tenant'ı ID'ye göre al
  Future<Tenant?> getTenantById(String tenantId) async {
    try {
      final tenantDoc =
          await _firestore.collection('tenants').doc(tenantId).get();
      if (tenantDoc.exists) {
        final tenantData = tenantDoc.data() as Map<String, dynamic>;
        return Tenant.fromJson(tenantData);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting tenant by ID', e);
      return null;
    }
  }

  /// Tenant oluştur (geliştirilmiş)
  Future<String> createTenantWithEntity(Tenant tenant) async {
    try {
      final tenantRef = _firestore.collection('tenants').doc(tenant.id);
      await tenantRef.set(tenant.toJson());

      // Kullanıcıyı tenant'a ata
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'tenantId': tenant.id,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      AppLogger.info('Tenant created successfully', {'tenantId': tenant.id});
      return tenant.id;
    } catch (e) {
      AppLogger.error('Error creating tenant', e);
      rethrow;
    }
  }

  /// Tenant'a üye ekle
  Future<void> addMemberToTenant(String tenantId, String userId) async {
    try {
      await _firestore.collection('tenants').doc(tenantId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Kullanıcıyı tenant'a ata
      await _firestore.collection('users').doc(userId).update({
        'tenantId': tenantId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info(
          'Member added to tenant', {'tenantId': tenantId, 'userId': userId});
    } catch (e) {
      AppLogger.error('Error adding member to tenant', e);
      rethrow;
    }
  }

  /// Tenant'tan üye çıkar
  Future<void> removeMemberFromTenant(String tenantId, String userId) async {
    try {
      await _firestore.collection('tenants').doc(tenantId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Kullanıcının tenant ID'sini temizle
      await _firestore.collection('users').doc(userId).update({
        'tenantId': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Member removed from tenant',
          {'tenantId': tenantId, 'userId': userId});
    } catch (e) {
      AppLogger.error('Error removing member from tenant', e);
      rethrow;
    }
  }

  /// Tenant ayarlarını güncelle
  Future<void> updateTenantSettings(
      String tenantId, Map<String, dynamic> settings) async {
    try {
      await _firestore.collection('tenants').doc(tenantId).update({
        'settings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Tenant settings updated', {'tenantId': tenantId});
    } catch (e) {
      AppLogger.error('Error updating tenant settings', e);
      rethrow;
    }
  }

  /// Kullanıcıyı tenant'a davet et
  Future<bool> inviteUserToTenant(String userEmail, String tenantId) async {
    try {
      // Bu özellik gelecekte implement edilecek
      AppLogger.info('Inviting user to tenant', {
        'userEmail': userEmail,
        'tenantId': tenantId,
      });
      return true;
    } catch (e) {
      AppLogger.error('Error inviting user to tenant', e);
      return false;
    }
  }

  /// Tenant istatistikleri
  Future<Map<String, dynamic>> getTenantStats(String tenantId) async {
    try {
      // Ürün sayısı
      final productsQuery = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .get();

      // Müşteri sayısı
      final customersQuery = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .get();

      // Satış sayısı
      final salesQuery = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('sales')
          .get();

      return {
        'productCount': productsQuery.docs.length,
        'customerCount': customersQuery.docs.length,
        'saleCount': salesQuery.docs.length,
      };
    } catch (e) {
      AppLogger.error('Error getting tenant stats', e);
      return {};
    }
  }

  /// Kullanıcı kurulumunu kontrol et ve gerekirse tenant oluştur
  Future<bool> ensureUserTenantSetup() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.warning('User not authenticated');
        return false;
      }

      // Kullanıcının tenant ID'sini kontrol et
      final tenantId = await getUserTenantId();
      if (tenantId != null && tenantId.isNotEmpty) {
        AppLogger.info('User already has tenant', {'tenantId': tenantId});
        return true;
      }

      // Kullanıcı için varsayılan tenant oluştur
      AppLogger.info('Creating default tenant for user', {'userId': user.uid});

      final tenantName =
          '${user.displayName ?? user.email?.split('@')[0] ?? 'User'}\'s Company';
      final newTenantId = await createTenant(
        name: tenantName,
        description: 'Default tenant created automatically',
      );

      if (newTenantId != null) {
        AppLogger.info(
            'Default tenant created successfully', {'tenantId': newTenantId});
        return true;
      } else {
        AppLogger.error('Failed to create default tenant');
        return false;
      }
    } catch (e) {
      AppLogger.error('Error in user tenant setup', e);
      return false;
    }
  }
}
