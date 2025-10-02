// ========== USER COMPANY SERVICE ==========
// lib/core/services/user_company_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Kullanıcı şirket yönetimi servisi - Multi-tenant için
class UserCompanyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Kullanıcının şirket ID'sini al
  Future<String?> getUserCompanyId() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['companyId'] as String?;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting user company ID', e);
      return null;
    }
  }

  /// Kullanıcının şirket bilgilerini al
  Future<Map<String, dynamic>?> getUserCompany() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Önce kullanıcı dokümanından companyName'i al
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final companyName = userData['companyName'] as String?;

        if (companyName != null && companyName.isNotEmpty) {
          // Timestamp'leri DateTime'a çevir
          DateTime createdAt;
          DateTime updatedAt;

          if (userData['createdAt'] != null) {
            if (userData['createdAt'] is Timestamp) {
              createdAt = (userData['createdAt'] as Timestamp).toDate();
            } else {
              createdAt = DateTime.now();
            }
          } else {
            createdAt = DateTime.now();
          }

          if (userData['updatedAt'] != null) {
            if (userData['updatedAt'] is Timestamp) {
              updatedAt = (userData['updatedAt'] as Timestamp).toDate();
            } else {
              updatedAt = DateTime.now();
            }
          } else {
            updatedAt = DateTime.now();
          }

          // Kullanıcının kendi şirket bilgilerini döndür
          return {
            'id': userData['tenantId'] ?? 'default',
            'name': companyName,
            'description': 'User Company',
            'ownerId': user.uid,
            'createdAt': createdAt.toIso8601String(),
            'updatedAt': updatedAt.toIso8601String(),
            'isActive': true,
          };
        }
      }

      // Fallback: companies koleksiyonundan al
      final companyId = await getUserCompanyId();
      if (companyId != null) {
        final companyDoc =
            await _firestore.collection('companies').doc(companyId).get();
        if (companyDoc.exists) {
          return companyDoc.data();
        }
      }

      return null;
    } catch (e) {
      AppLogger.error('Error getting user company', e);
      return null;
    }
  }

  /// Kullanıcıyı şirkete ata
  Future<bool> assignUserToCompany(String userId, String companyId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'companyId': companyId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      AppLogger.error('Error assigning user to company', e);
      return false;
    }
  }

  /// Şirket oluştur
  Future<String?> createCompany(Map<String, dynamic> companyData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final companyRef = _firestore.collection('companies').doc();
      final companyId = companyRef.id;

      await companyRef.set({
        'id': companyId,
        'name': companyData['name'],
        'description': companyData['description'],
        'ownerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Kullanıcıyı şirkete ata
      await assignUserToCompany(user.uid, companyId);

      return companyId;
    } catch (e) {
      AppLogger.error('Error creating company', e);
      return null;
    }
  }

  /// Şirket üyelerini al
  Future<List<Map<String, dynamic>>> getCompanyMembers() async {
    try {
      final companyId = await getUserCompanyId();
      if (companyId == null) return [];

      final membersQuery = await _firestore
          .collection('users')
          .where('companyId', isEqualTo: companyId)
          .get();

      return membersQuery.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      AppLogger.error('Error getting company members', e);
      return [];
    }
  }

  /// Şirket istatistikleri
  Future<Map<String, dynamic>> getCompanyStats() async {
    try {
      final companyId = await getUserCompanyId();
      if (companyId == null) return {};

      // Ürün sayısı
      final productsQuery = await _firestore
          .collection('products')
          .where('companyId', isEqualTo: companyId)
          .get();

      // Müşteri sayısı
      final customersQuery = await _firestore
          .collection('customers')
          .where('companyId', isEqualTo: companyId)
          .get();

      // Satış sayısı
      final salesQuery = await _firestore
          .collection('sales')
          .where('companyId', isEqualTo: companyId)
          .get();

      return {
        'productCount': productsQuery.docs.length,
        'customerCount': customersQuery.docs.length,
        'saleCount': salesQuery.docs.length,
        'memberCount': (await getCompanyMembers()).length,
      };
    } catch (e) {
      AppLogger.error('Error getting company stats', e);
      return {};
    }
  }
}
