import '../entities/company_info.dart';

/// Firma bilgileri repository interface
abstract class CompanyRepository {
  /// Firma bilgilerini getir
  Future<CompanyInfo?> getCompanyInfo();

  /// Firma bilgilerini kaydet
  Future<void> saveCompanyInfo(CompanyInfo companyInfo);

  /// Firma bilgilerini güncelle
  Future<void> updateCompanyInfo(CompanyInfo companyInfo);

  /// Firma bilgilerini sil
  Future<void> deleteCompanyInfo();
}
