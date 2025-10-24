// ========== PAYMENT SOURCE REPOSITORY ==========
// lib/features/payment_collection/domain/repositories/payment_source_repository.dart

import '../entities/payment_source.dart';
import '../entities/payment_enums.dart';

/// Ödeme kaynağı repository interface'i
abstract class PaymentSourceRepository {
  /// Tüm ödeme kaynaklarını getir
  Future<List<PaymentSource>> getAllSources({
    String? companyId,
    String? tenantId,
    bool? isActive,
  });

  /// ID'ye göre ödeme kaynağı getir
  Future<PaymentSource?> getSourceById(String id);

  /// Aktif ödeme kaynaklarını getir
  Future<List<PaymentSource>> getActiveSources({
    String? companyId,
    String? tenantId,
  });

  /// Varsayılan ödeme kaynağını getir
  Future<PaymentSource?> getDefaultSource({
    String? companyId,
    String? tenantId,
  });

  /// Kaynak türüne göre kaynakları getir
  Future<List<PaymentSource>> getSourcesByType(
    PaymentSourceType type, {
    String? companyId,
    String? tenantId,
  });

  /// Ödeme kaynağı oluştur
  Future<PaymentSource> createSource(PaymentSource source);

  /// Ödeme kaynağı güncelle
  Future<PaymentSource> updateSource(PaymentSource source);

  /// Ödeme kaynağı sil
  Future<void> deleteSource(String id);

  /// Ödeme kaynağı aktif/pasif yap
  Future<PaymentSource> toggleSourceStatus(String id, bool isActive);

  /// Varsayılan kaynak ayarla
  Future<PaymentSource> setDefaultSource(String id);

  /// Bakiye güncelle
  Future<PaymentSource> updateBalance(
    String id,
    double newBalance,
  );

  /// Kullanılabilir bakiye güncelle
  Future<PaymentSource> updateAvailableBalance(
    String id,
    double newAvailableBalance,
  );

  /// Bloke tutar güncelle
  Future<PaymentSource> updateBlockedAmount(
    String id,
    double newBlockedAmount,
  );

  /// Limitleri güncelle
  Future<PaymentSource> updateLimits(
    String id, {
    double? dailyLimit,
    double? monthlyLimit,
    double? transactionLimit,
  });

  /// Bakiye yeterli mi?
  Future<bool> hasSufficientBalance(
    String sourceId,
    double amount,
  );

  /// Günlük limit aşıldı mı?
  Future<bool> isDailyLimitExceeded(
    String sourceId,
    double dailyAmount,
  );

  /// Aylık limit aşıldı mı?
  Future<bool> isMonthlyLimitExceeded(
    String sourceId,
    double monthlyAmount,
  );

  /// İşlem limiti aşıldı mı?
  Future<bool> isTransactionLimitExceeded(
    String sourceId,
    double amount,
  );

  /// Limitler içinde mi?
  Future<bool> isWithinLimits(
    String sourceId,
    double amount,
    double dailyAmount,
    double monthlyAmount,
  );

  /// Kaynak doğrula
  Future<bool> validateSource(PaymentSource source);

  /// Kaynak kullanılabilir mi?
  Future<bool> isSourceAvailable(
    String sourceId,
    double amount,
  );

  /// Kaynak istatistikleri
  Future<Map<String, dynamic>> getSourceStatistics(
    String sourceId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Kaynak arama
  Future<List<PaymentSource>> searchSources(
    String query, {
    String? companyId,
    String? tenantId,
  });

  /// Kaynak kopyala
  Future<PaymentSource> duplicateSource(
    String id,
    String newName,
  );

  /// Kaynak import
  Future<List<PaymentSource>> importSources(
    List<PaymentSource> sources,
  );

  /// Kaynak export
  Future<String> exportSources({
    String? companyId,
    String? tenantId,
  });

  /// Kaynak geçmişi
  Future<List<Map<String, dynamic>>> getSourceHistory(String id);

  /// Kaynak değişiklikleri
  Future<List<Map<String, dynamic>>> getSourceChanges(String id);

  /// Kaynak yedekle
  Future<String> backupSource(String id);

  /// Kaynak geri yükle
  Future<PaymentSource> restoreSource(String backupId);

  /// Kaynak senkronizasyonu
  Future<void> syncSources({
    String? companyId,
    String? tenantId,
  });

  /// Kaynak doğrulama
  Future<Map<String, dynamic>> validateSourceSettings(
    PaymentSource source,
  );

  /// Kaynak test
  Future<bool> testSource(String id);

  /// Kaynak durumu
  Future<Map<String, dynamic>> getSourceStatus(String id);

  /// Kaynak sağlık kontrolü
  Future<Map<String, dynamic>> getSourceHealthCheck(String id);

  /// Kaynak güncelleme kontrolü
  Future<bool> checkForUpdates(String id);

  /// Kaynak güncelle
  Future<PaymentSource> updateSourceVersion(String id);

  /// Kaynak rollback
  Future<PaymentSource> rollbackSource(String id, String version);

  /// Kaynak versiyonları
  Future<List<Map<String, dynamic>>> getSourceVersions(String id);

  /// Kaynak karşılaştırma
  Future<Map<String, dynamic>> compareSources(
    String sourceId1,
    String sourceId2,
  );

  /// Kaynak bağımlılıkları
  Future<List<String>> getSourceDependencies(String id);

  /// Kaynak kullanım yerleri
  Future<List<String>> getSourceUsageLocations(String id);

  /// Kaynak etkisi analizi
  Future<Map<String, dynamic>> analyzeSourceImpact(String id);

  /// Kaynak önerileri
  Future<List<Map<String, dynamic>>> getSourceRecommendations({
    String? companyId,
    String? tenantId,
  });

  /// Kaynak optimizasyonu
  Future<PaymentSource> optimizeSource(String id);

  /// Kaynak performans analizi
  Future<Map<String, dynamic>> analyzeSourcePerformance(
    String id, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Kaynak güvenlik analizi
  Future<Map<String, dynamic>> analyzeSourceSecurity(String id);

  /// Kaynak uyumluluk kontrolü
  Future<Map<String, dynamic>> checkSourceCompatibility(
    String id,
    String targetVersion,
  );

  /// Kaynak migrasyon
  Future<PaymentSource> migrateSource(
    String id,
    String targetVersion,
  );

  /// Kaynak temizleme
  Future<void> cleanupSource(String id);

  /// Kaynak arşivleme
  Future<void> archiveSource(String id);

  /// Kaynak geri alma
  Future<PaymentSource> unarchiveSource(String id);

  /// Arşivlenmiş kaynaklar
  Future<List<PaymentSource>> getArchivedSources({
    String? companyId,
    String? tenantId,
  });

  /// Kaynak geri yükleme
  Future<PaymentSource> restoreArchivedSource(String id);

  /// Kaynak kalıcı silme
  Future<void> permanentlyDeleteSource(String id);

  /// Kaynak toplu işlemler
  Future<List<PaymentSource>> bulkUpdateSources(
    List<PaymentSource> sources,
  );

  Future<void> bulkDeleteSources(List<String> ids);

  Future<List<PaymentSource>> bulkCreateSources(
    List<PaymentSource> sources,
  );

  /// Kaynak toplu durum değişikliği
  Future<List<PaymentSource>> bulkToggleStatus(
    List<String> ids,
    bool isActive,
  );

  /// Kaynak toplu varsayılan ayarlama
  Future<PaymentSource> bulkSetDefault(String id);

  /// Kaynak toplu bakiye güncelleme
  Future<List<PaymentSource>> bulkUpdateBalances(
    Map<String, double> sourceBalances,
  );

  /// Kaynak toplu limit güncelleme
  Future<List<PaymentSource>> bulkUpdateLimits(
    Map<String, Map<String, double>> sourceLimits,
  );

  /// Kaynak toplu ayar güncelleme
  Future<List<PaymentSource>> bulkUpdateSettings(
    Map<String, Map<String, dynamic>> sourceSettings,
  );

  /// Kaynak toplu senkronizasyon
  Future<void> bulkSyncSources(List<String> ids);

  /// Kaynak toplu test
  Future<Map<String, bool>> bulkTestSources(List<String> ids);

  /// Kaynak toplu yedekleme
  Future<Map<String, String>> bulkBackupSources(List<String> ids);

  /// Kaynak toplu geri yükleme
  Future<List<PaymentSource>> bulkRestoreSources(List<String> backupIds);

  /// Kaynak toplu arşivleme
  Future<void> bulkArchiveSources(List<String> ids);

  /// Kaynak toplu geri alma
  Future<List<PaymentSource>> bulkUnarchiveSources(List<String> ids);

  /// Kaynak toplu temizleme
  Future<void> bulkCleanupSources(List<String> ids);

  /// Kaynak toplu optimizasyon
  Future<List<PaymentSource>> bulkOptimizeSources(List<String> ids);

  /// Kaynak toplu performans analizi
  Future<Map<String, Map<String, dynamic>>> bulkAnalyzePerformance(
    List<String> ids, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Kaynak toplu güvenlik analizi
  Future<Map<String, Map<String, dynamic>>> bulkAnalyzeSecurity(
    List<String> ids,
  );

  /// Kaynak toplu uyumluluk kontrolü
  Future<Map<String, Map<String, dynamic>>> bulkCheckCompatibility(
    List<String> ids,
    String targetVersion,
  );

  /// Kaynak toplu migrasyon
  Future<List<PaymentSource>> bulkMigrateSources(
    List<String> ids,
    String targetVersion,
  );

  /// Kaynak toplu güncelleme kontrolü
  Future<Map<String, bool>> bulkCheckForUpdates(List<String> ids);

  /// Kaynak toplu güncelleme
  Future<List<PaymentSource>> bulkUpdateVersions(List<String> ids);

  /// Kaynak toplu rollback
  Future<List<PaymentSource>> bulkRollbackSources(
    Map<String, String> sourceVersions,
  );

  /// Kaynak toplu karşılaştırma
  Future<Map<String, Map<String, dynamic>>> bulkCompareSources(
    List<String> ids,
  );

  /// Kaynak toplu bağımlılık analizi
  Future<Map<String, List<String>>> bulkAnalyzeDependencies(
    List<String> ids,
  );

  /// Kaynak toplu kullanım analizi
  Future<Map<String, List<String>>> bulkAnalyzeUsage(List<String> ids);

  /// Kaynak toplu etki analizi
  Future<Map<String, Map<String, dynamic>>> bulkAnalyzeImpact(
    List<String> ids,
  );

  /// Kaynak toplu öneriler
  Future<Map<String, List<Map<String, dynamic>>>> bulkGetRecommendations(
    List<String> ids,
  );
}
