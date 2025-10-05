import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/company_firebase_datasource.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../domain/usecases/get_company_info_usecase.dart';
import '../../domain/usecases/save_company_info_usecase.dart';
import '../../domain/entities/company_info.dart';

/// Firebase data source provider
final companyFirebaseDataSourceProvider =
    Provider<CompanyFirebaseDataSource>((ref) {
  return CompanyFirebaseDataSource();
});

/// Repository provider
final companyRepositoryProvider = Provider<CompanyRepositoryImpl>((ref) {
  final dataSource = ref.watch(companyFirebaseDataSourceProvider);
  return CompanyRepositoryImpl(dataSource);
});

/// Get company info use case provider
final getCompanyInfoUseCaseProvider = Provider<GetCompanyInfoUseCase>((ref) {
  final repository = ref.watch(companyRepositoryProvider);
  return GetCompanyInfoUseCase(repository);
});

/// Save company info use case provider
final saveCompanyInfoUseCaseProvider = Provider<SaveCompanyInfoUseCase>((ref) {
  final repository = ref.watch(companyRepositoryProvider);
  return SaveCompanyInfoUseCase(repository);
});

/// Company info stream provider
final companyInfoStreamProvider = StreamProvider<CompanyInfo?>((ref) {
  final useCase = ref.watch(getCompanyInfoUseCaseProvider);

  // Tek seferlik stream
  return Stream.fromFuture(useCase.call());
});

/// Company info refresh provider
final companyInfoRefreshProvider = StateProvider<int>((ref) => 0);

/// Company info with refresh capability
final companyInfoWithRefreshProvider = StreamProvider<CompanyInfo?>((ref) {
  final useCase = ref.watch(getCompanyInfoUseCaseProvider);
  ref.watch(companyInfoRefreshProvider); // Refresh trigger'ı dinle

  // Refresh trigger değiştiğinde yeniden yükle
  return Stream.fromFuture(useCase.call());
});
