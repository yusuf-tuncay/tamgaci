import '../entities/company_info.dart';
import '../repositories/company_repository.dart';

/// Firma bilgilerini kaydet use case
class SaveCompanyInfoUseCase {
  final CompanyRepository _repository;

  SaveCompanyInfoUseCase(this._repository);

  Future<void> call(CompanyInfo companyInfo) async {
    return await _repository.saveCompanyInfo(companyInfo);
  }
}
