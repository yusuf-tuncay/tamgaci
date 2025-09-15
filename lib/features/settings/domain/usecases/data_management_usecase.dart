import 'package:tamgaci/features/settings/domain/repositories/settings_repository.dart';

/// Veri yönetimi use case'i
class DataManagementUseCase {
  final SettingsRepository _repository;

  DataManagementUseCase(this._repository);

  /// Veri yedeklemesi oluşturur
  /// [userId]: Kullanıcı ID'si
  /// Returns: Yedekleme dosyası URL'si
  Future<String> createDataBackup(String userId) async {
    return await _repository.createDataBackup(userId);
  }

  /// Veri yedeklemesini geri yükler
  /// [userId]: Kullanıcı ID'si
  /// [backupUrl]: Yedekleme dosyası URL'si
  /// Returns: İşlem başarılı mı
  Future<bool> restoreDataBackup(String userId, String backupUrl) async {
    return await _repository.restoreDataBackup(userId, backupUrl);
  }

  /// Tüm kullanıcı verilerini siler (GDPR)
  /// [userId]: Kullanıcı ID'si
  /// Returns: İşlem başarılı mı
  Future<bool> deleteAllUserData(String userId) async {
    return await _repository.deleteAllUserData(userId);
  }

  /// Kullanıcı verilerini dışa aktarır (GDPR)
  /// [userId]: Kullanıcı ID'si
  /// Returns: Veri dosyası URL'si
  Future<String> exportUserData(String userId) async {
    return await _repository.exportUserData(userId);
  }
}
