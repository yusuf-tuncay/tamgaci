import '../entities/company_info.dart';
import '../repositories/company_repository.dart';

/// Firma bilgilerini getir use case
class GetCompanyInfoUseCase {
  final CompanyRepository _repository;

  GetCompanyInfoUseCase(this._repository);

  Future<CompanyInfo?> call() async {
    return await _repository.getCompanyInfo();
  }
}
