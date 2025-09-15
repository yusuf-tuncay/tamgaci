import 'package:tamgaci/features/settings/domain/entities/app_settings.dart';
import 'package:tamgaci/features/settings/domain/repositories/settings_repository.dart';

/// Uygulama ayarlarını getirme use case'i
class GetAppSettingsUseCase {
  final SettingsRepository _repository;

  GetAppSettingsUseCase(this._repository);

  /// Kullanıcı ayarlarını getirir
  /// [userId]: Kullanıcı ID'si
  /// Returns: Uygulama ayarları veya null
  Future<AppSettings?> call(String userId) async {
    return await _repository.getAppSettings(userId);
  }

  /// Sistem ayarlarını getirir
  /// Returns: Sistem ayarları
  Future<Map<String, dynamic>> getSystemSettings() async {
    return await _repository.getSystemSettings();
  }
}
