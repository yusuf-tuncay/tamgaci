import 'package:tamgaci/features/settings/domain/entities/app_settings.dart';
import 'package:tamgaci/features/settings/domain/repositories/settings_repository.dart';

/// Uygulama ayarlarını oluşturma use case'i
class CreateAppSettingsUseCase {
  final SettingsRepository _repository;

  CreateAppSettingsUseCase(this._repository);

  /// Yeni uygulama ayarları oluşturur
  /// [appSettings]: Oluşturulacak uygulama ayarları
  /// Returns: Oluşturulan uygulama ayarları
  Future<AppSettings> call(AppSettings appSettings) async {
    final newSettings = appSettings.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createAppSettings(newSettings);
  }

  /// Varsayılan ayarlarla yeni uygulama ayarları oluşturur
  /// [userId]: Kullanıcı ID'si
  /// Returns: Oluşturulan uygulama ayarları
  Future<AppSettings> createDefault(String userId) async {
    final now = DateTime.now();

    final defaultSettings = AppSettings(
      id: userId, // ID olarak userId kullanıyoruz
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );

    return await _repository.createAppSettings(defaultSettings);
  }
}
