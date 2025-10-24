// ========== PAYMENT METHOD REPOSITORY ==========
// lib/features/payment_collection/domain/repositories/payment_method_repository.dart

import '../entities/payment_method.dart';
import '../entities/payment_enums.dart';

/// Ödeme yöntemi repository interface'i
abstract class PaymentMethodRepository {
  /// Tüm ödeme yöntemlerini getir
  Future<List<PaymentMethod>> getAllMethods({
    String? companyId,
    String? tenantId,
    bool? isActive,
  });

  /// ID'ye göre ödeme yöntemi getir
  Future<PaymentMethod?> getMethodById(String id);

  /// Aktif ödeme yöntemlerini getir
  Future<List<PaymentMethod>> getActiveMethods({
    String? companyId,
    String? tenantId,
  });

  /// Varsayılan ödeme yöntemini getir
  Future<PaymentMethod?> getDefaultMethod({
    String? companyId,
    String? tenantId,
  });

  /// Yöntem türüne göre yöntemleri getir
  Future<List<PaymentMethod>> getMethodsByType(
    PaymentMethodType type, {
    String? companyId,
    String? tenantId,
  });

  /// Ödeme yöntemi oluştur
  Future<PaymentMethod> createMethod(PaymentMethod method);

  /// Ödeme yöntemi güncelle
  Future<PaymentMethod> updateMethod(PaymentMethod method);

  /// Ödeme yöntemi sil
  Future<void> deleteMethod(String id);

  /// Ödeme yöntemi aktif/pasif yap
  Future<PaymentMethod> toggleMethodStatus(String id, bool isActive);

  /// Varsayılan yöntem ayarla
  Future<PaymentMethod> setDefaultMethod(String id);

  /// Yöntem ayarlarını güncelle
  Future<PaymentMethod> updateMethodSettings(
    String id,
    Map<String, dynamic> settings,
  );

  /// Limitleri güncelle
  Future<PaymentMethod> updateLimits(
    String id, {
    double? minimumAmount,
    double? maximumAmount,
    double? dailyLimit,
    double? monthlyLimit,
  });

  /// Komisyon oranını güncelle
  Future<PaymentMethod> updateCommissionRate(
    String id,
    double commissionRate,
  );

  /// Onay seviyesini güncelle
  Future<PaymentMethod> updateApprovalLevel(
    String id,
    PaymentApprovalLevel approvalLevel,
  );

  /// Öncelik seviyesini güncelle
  Future<PaymentMethod> updatePriority(
    String id,
    PaymentPriority priority,
  );

  /// Yöntem doğrula
  Future<bool> validateMethod(PaymentMethod method);

  /// Tutar limitler içinde mi?
  Future<bool> isAmountWithinLimits(
    String methodId,
    double amount,
  );

  /// Günlük limit aşıldı mı?
  Future<bool> isDailyLimitExceeded(
    String methodId,
    double dailyAmount,
  );

  /// Aylık limit aşıldı mı?
  Future<bool> isMonthlyLimitExceeded(
    String methodId,
    double monthlyAmount,
  );

  /// Komisyon hesapla
  Future<double> calculateCommission(
    String methodId,
    double amount,
  );

  /// Yöntem kullanılabilir mi?
  Future<bool> isMethodAvailable(
    String methodId,
    double amount,
  );

  /// Yöntem istatistikleri
  Future<Map<String, dynamic>> getMethodStatistics(
    String methodId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Yöntem kullanım raporu
  Future<Map<String, dynamic>> getMethodUsageReport(
    String methodId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Yöntem performans raporu
  Future<Map<String, dynamic>> getMethodPerformanceReport(
    String methodId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Yöntem sıralaması
  Future<List<PaymentMethod>> getMethodsByPriority({
    String? companyId,
    String? tenantId,
  });

  /// Yöntem arama
  Future<List<PaymentMethod>> searchMethods(
    String query, {
    String? companyId,
    String? tenantId,
  });

  /// Yöntem kopyala
  Future<PaymentMethod> duplicateMethod(
    String id,
    String newName,
  );

  /// Yöntem import
  Future<List<PaymentMethod>> importMethods(
    List<PaymentMethod> methods,
  );

  /// Yöntem export
  Future<String> exportMethods({
    String? companyId,
    String? tenantId,
  });

  /// Yöntem şablonu oluştur
  Future<PaymentMethod> createMethodTemplate(
    PaymentMethodType type,
    String name,
  );

  /// Yöntem şablonlarını getir
  Future<List<PaymentMethod>> getMethodTemplates();

  /// Yöntem şablonundan oluştur
  Future<PaymentMethod> createFromTemplate(
    String templateId,
    String name,
    String companyId,
    String tenantId,
    String createdBy,
  );

  /// Yöntem geçmişi
  Future<List<Map<String, dynamic>>> getMethodHistory(String id);

  /// Yöntem değişiklikleri
  Future<List<Map<String, dynamic>>> getMethodChanges(String id);

  /// Yöntem yedekle
  Future<String> backupMethod(String id);

  /// Yöntem geri yükle
  Future<PaymentMethod> restoreMethod(String backupId);

  /// Yöntem senkronizasyonu
  Future<void> syncMethods({
    String? companyId,
    String? tenantId,
  });

  /// Yöntem doğrulama
  Future<Map<String, dynamic>> validateMethodSettings(
    PaymentMethod method,
  );

  /// Yöntem test
  Future<bool> testMethod(String id);

  /// Yöntem durumu
  Future<Map<String, dynamic>> getMethodStatus(String id);

  /// Yöntem sağlık kontrolü
  Future<Map<String, dynamic>> getMethodHealthCheck(String id);

  /// Yöntem güncelleme kontrolü
  Future<bool> checkForUpdates(String id);

  /// Yöntem güncelle
  Future<PaymentMethod> updateMethodVersion(String id);

  /// Yöntem rollback
  Future<PaymentMethod> rollbackMethod(String id, String version);

  /// Yöntem versiyonları
  Future<List<Map<String, dynamic>>> getMethodVersions(String id);

  /// Yöntem karşılaştırma
  Future<Map<String, dynamic>> compareMethods(
    String methodId1,
    String methodId2,
  );

  /// Yöntem bağımlılıkları
  Future<List<String>> getMethodDependencies(String id);

  /// Yöntem kullanım yerleri
  Future<List<String>> getMethodUsageLocations(String id);

  /// Yöntem etkisi analizi
  Future<Map<String, dynamic>> analyzeMethodImpact(String id);

  /// Yöntem önerileri
  Future<List<Map<String, dynamic>>> getMethodRecommendations({
    String? companyId,
    String? tenantId,
  });

  /// Yöntem optimizasyonu
  Future<PaymentMethod> optimizeMethod(String id);

  /// Yöntem performans analizi
  Future<Map<String, dynamic>> analyzeMethodPerformance(
    String id, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Yöntem güvenlik analizi
  Future<Map<String, dynamic>> analyzeMethodSecurity(String id);

  /// Yöntem uyumluluk kontrolü
  Future<Map<String, dynamic>> checkMethodCompatibility(
    String id,
    String targetVersion,
  );

  /// Yöntem migrasyon
  Future<PaymentMethod> migrateMethod(
    String id,
    String targetVersion,
  );

  /// Yöntem temizleme
  Future<void> cleanupMethod(String id);

  /// Yöntem arşivleme
  Future<void> archiveMethod(String id);

  /// Yöntem geri alma
  Future<PaymentMethod> unarchiveMethod(String id);

  /// Arşivlenmiş yöntemler
  Future<List<PaymentMethod>> getArchivedMethods({
    String? companyId,
    String? tenantId,
  });

  /// Yöntem geri yükleme
  Future<PaymentMethod> restoreArchivedMethod(String id);

  /// Yöntem kalıcı silme
  Future<void> permanentlyDeleteMethod(String id);

  /// Yöntem toplu işlemler
  Future<List<PaymentMethod>> bulkUpdateMethods(
    List<PaymentMethod> methods,
  );

  Future<void> bulkDeleteMethods(List<String> ids);

  Future<List<PaymentMethod>> bulkCreateMethods(
    List<PaymentMethod> methods,
  );

  /// Yöntem toplu durum değişikliği
  Future<List<PaymentMethod>> bulkToggleStatus(
    List<String> ids,
    bool isActive,
  );

  /// Yöntem toplu varsayılan ayarlama
  Future<PaymentMethod> bulkSetDefault(String id);

  /// Yöntem toplu limit güncelleme
  Future<List<PaymentMethod>> bulkUpdateLimits(
    List<String> ids, {
    double? minimumAmount,
    double? maximumAmount,
    double? dailyLimit,
    double? monthlyLimit,
  });

  /// Yöntem toplu komisyon güncelleme
  Future<List<PaymentMethod>> bulkUpdateCommissionRates(
    Map<String, double> methodCommissionRates,
  );

  /// Yöntem toplu onay seviyesi güncelleme
  Future<List<PaymentMethod>> bulkUpdateApprovalLevels(
    Map<String, PaymentApprovalLevel> methodApprovalLevels,
  );

  /// Yöntem toplu öncelik güncelleme
  Future<List<PaymentMethod>> bulkUpdatePriorities(
    Map<String, PaymentPriority> methodPriorities,
  );
}
