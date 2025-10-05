import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/company_info.dart';
import '../../../../core/services/tenant_service.dart';

/// Firebase firma bilgileri data source
class CompanyFirebaseDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TenantService _tenantService = TenantService();

  /// Firma bilgilerini getir
  Future<CompanyInfo?> getCompanyInfo() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final tenantId = await _tenantService.getUserTenantId();
      if (tenantId == null) return null;

      final doc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('companies')
          .doc(tenantId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return CompanyInfo.fromJson({
        'id': doc.id,
        ...data,
      });
    } catch (e) {
      throw Exception('Firma bilgileri getirilemedi: $e');
    }
  }

  /// Firma bilgilerini kaydet
  Future<void> saveCompanyInfo(CompanyInfo companyInfo) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı girişi gerekli');

      final tenantId = await _tenantService.getUserTenantId();
      if (tenantId == null) throw Exception('Tenant ID bulunamadı');

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('companies')
          .doc(tenantId)
          .set(companyInfo.toJson());
    } catch (e) {
      throw Exception('Firma bilgileri kaydedilemedi: $e');
    }
  }

  /// Firma bilgilerini güncelle
  Future<void> updateCompanyInfo(CompanyInfo companyInfo) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı girişi gerekli');

      final tenantId = await _tenantService.getUserTenantId();
      if (tenantId == null) throw Exception('Tenant ID bulunamadı');

      await _firestore
          .collection('company_info')
          .doc(tenantId)
          .update(companyInfo.toJson());
    } catch (e) {
      throw Exception('Firma bilgileri güncellenemedi: $e');
    }
  }

  /// Firma bilgilerini sil
  Future<void> deleteCompanyInfo() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı girişi gerekli');

      final tenantId = await _tenantService.getUserTenantId();
      if (tenantId == null) throw Exception('Tenant ID bulunamadı');

      await _firestore.collection('company_info').doc(tenantId).delete();
    } catch (e) {
      throw Exception('Firma bilgileri silinemedi: $e');
    }
  }
}
