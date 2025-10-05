import '../../domain/entities/company_info.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_firebase_datasource.dart';

/// Firma bilgileri repository implementation
class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyFirebaseDataSource _dataSource;

  CompanyRepositoryImpl(this._dataSource);

  @override
  Future<CompanyInfo?> getCompanyInfo() async {
    return await _dataSource.getCompanyInfo();
  }

  @override
  Future<void> saveCompanyInfo(CompanyInfo companyInfo) async {
    return await _dataSource.saveCompanyInfo(companyInfo);
  }

  @override
  Future<void> updateCompanyInfo(CompanyInfo companyInfo) async {
    return await _dataSource.updateCompanyInfo(companyInfo);
  }

  @override
  Future<void> deleteCompanyInfo() async {
    return await _dataSource.deleteCompanyInfo();
  }
}
