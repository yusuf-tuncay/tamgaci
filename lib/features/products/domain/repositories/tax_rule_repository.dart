// ========== TAX RULE REPOSITORY ==========
// lib/features/products/domain/repositories/tax_rule_repository.dart

import '../entities/tax_rule.dart';

/// Vergi kuralı repository interface'i
abstract class TaxRuleRepository {
  /// Tüm vergi kurallarını getir
  Stream<List<TaxRule>> getAllTaxRules();

  /// Aktif vergi kurallarını getir
  Stream<List<TaxRule>> getActiveTaxRules();

  /// ID'ye göre vergi kuralı getir
  Future<TaxRule?> getTaxRuleById(String id);

  /// Vergi türüne göre kuralları getir
  Stream<List<TaxRule>> getTaxRulesByType(TaxType type);

  /// Geçerli vergi kurallarını getir (tarih aralığında)
  Stream<List<TaxRule>> getValidTaxRules();

  /// Belirli bir ürün için geçerli vergi kurallarını getir
  Stream<List<TaxRule>> getValidTaxRulesForProduct(
      String productId, String? categoryId);

  /// Belirli bir müşteri için geçerli vergi kurallarını getir
  Stream<List<TaxRule>> getValidTaxRulesForCustomer(String? customerId);

  /// Kategoriye göre vergi kurallarını getir
  Stream<List<TaxRule>> getTaxRulesByCategory(String categoryId);

  /// Müşteriye göre vergi kurallarını getir
  Stream<List<TaxRule>> getTaxRulesByCustomer(String customerId);

  /// Vergi kuralı oluştur
  Future<void> createTaxRule(TaxRule taxRule);

  /// Vergi kuralı güncelle
  Future<void> updateTaxRule(TaxRule taxRule);

  /// Vergi kuralı sil
  Future<void> deleteTaxRule(String id);

  /// Vergi kuralı durumunu değiştir
  Future<void> updateTaxRuleStatus(String id, bool isActive);

  /// Toplam vergi kuralı sayısı
  Future<int> getActiveTaxRuleCount();

  /// Vergi türlerini getir
  Stream<List<TaxType>> getTaxTypes();

  /// Vergi hesaplama yöntemlerini getir
  Stream<List<TaxCalculationMethod>> getTaxCalculationMethods();
}
