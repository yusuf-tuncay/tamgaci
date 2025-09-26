// ========== USER SETUP SERVICE ==========
// lib/core/services/user_setup_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/core/services/user_company_service.dart';

/// Kullanıcı kurulum servisi - Multi-tenant için
class UserSetupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserCompanyService _companyService = UserCompanyService();

  /// Kullanıcı kurulumunu kontrol et ve gerekirse şirket oluştur
  Future<bool> ensureUserSetup() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.warning('User not authenticated');
        return false;
      }

      // Kullanıcının şirket ID'sini kontrol et
      final companyId = await _companyService.getUserCompanyId();
      if (companyId != null && companyId.isNotEmpty) {
        AppLogger.info('User already has company', {'companyId': companyId});
        return true;
      }

      // Kullanıcı için varsayılan şirket oluştur
      AppLogger.info('Creating default company for user', {'userId': user.uid});
      
      final companyData = {
        'name': '${user.displayName ?? user.email?.split('@')[0] ?? 'User'}\'s Company',
        'description': 'Default company created automatically',
      };

      final newCompanyId = await _companyService.createCompany(companyData);
      if (newCompanyId != null) {
        AppLogger.info('Default company created successfully', {'companyId': newCompanyId});
        return true;
      } else {
        AppLogger.error('Failed to create default company');
        return false;
      }
    } catch (e) {
      AppLogger.error('Error in user setup', e);
      return false;
    }
  }

  /// Kullanıcı bilgilerini güncelle
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userData = {
        'id': user.uid,
        'email': user.email,
        'displayName': displayName ?? user.displayName,
        'photoURL': photoURL ?? user.photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      await _firestore.collection('users').doc(user.uid).set(userData, SetOptions(merge: true));
      AppLogger.info('User profile updated successfully');
      return true;
    } catch (e) {
      AppLogger.error('Error updating user profile', e);
      return false;
    }
  }

  /// Kullanıcı kurulum durumunu kontrol et
  Future<Map<String, dynamic>> getUserSetupStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'isAuthenticated': false,
          'hasCompany': false,
          'needsSetup': true,
        };
      }

      final companyId = await _companyService.getUserCompanyId();
      final hasCompany = companyId != null && companyId.isNotEmpty;

      return {
        'isAuthenticated': true,
        'hasCompany': hasCompany,
        'needsSetup': !hasCompany,
        'userId': user.uid,
        'companyId': companyId,
      };
    } catch (e) {
      AppLogger.error('Error checking user setup status', e);
      return {
        'isAuthenticated': false,
        'hasCompany': false,
        'needsSetup': true,
        'error': e.toString(),
      };
    }
  }

  /// Kullanıcıyı mevcut şirkete davet et
  Future<bool> inviteUserToCompany(String userEmail, String companyId) async {
    try {
      // Bu özellik gelecekte implement edilecek
      AppLogger.info('Inviting user to company', {
        'userEmail': userEmail,
        'companyId': companyId,
      });
      return true;
    } catch (e) {
      AppLogger.error('Error inviting user to company', e);
      return false;
    }
  }
}
