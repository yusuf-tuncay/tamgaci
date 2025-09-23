// ========== PRICE LIST REPOSITORY ==========
// lib/features/products/domain/repositories/price_list_repository.dart

import '../entities/price_list.dart';

/// Fiyat listesi repository interface'i
abstract class PriceListRepository {
  /// Tüm fiyat listelerini getir
  Stream<List<PriceList>> getAllPriceLists();

  /// Aktif fiyat listelerini getir
  Stream<List<PriceList>> getActivePriceLists();

  /// ID'ye göre fiyat listesi getir
  Future<PriceList?> getPriceListById(String id);

  /// Müşteri özel fiyat listelerini getir
  Stream<List<PriceList>> getCustomerPriceLists(String customerId);

  /// Kategori özel fiyat listelerini getir
  Stream<List<PriceList>> getCategoryPriceLists(String categoryId);

  /// Geçerli fiyat listelerini getir (tarih aralığında)
  Stream<List<PriceList>> getValidPriceLists();

  /// Belirli bir ürün için geçerli fiyat listelerini getir
  Stream<List<PriceList>> getValidPriceListsForProduct(String productId);

  /// Belirli bir müşteri için geçerli fiyat listelerini getir
  Stream<List<PriceList>> getValidPriceListsForCustomer(String customerId);

  /// Fiyat listesi oluştur
  Future<void> createPriceList(PriceList priceList);

  /// Fiyat listesi güncelle
  Future<void> updatePriceList(PriceList priceList);

  /// Fiyat listesi sil
  Future<void> deletePriceList(String id);

  /// Fiyat listesi durumunu değiştir
  Future<void> updatePriceListStatus(String id, bool isActive);

  /// Ürün fiyatını güncelle
  Future<void> updateProductPrice(
      String priceListId, String productId, double price);

  /// Ürün iskontosunu güncelle
  Future<void> updateProductDiscount(
      String priceListId, String productId, double discount);

  /// Toplam fiyat listesi sayısı
  Future<int> getActivePriceListCount();

  /// Fiyat listesi türlerini getir
  Stream<List<PriceListType>> getPriceListTypes();
}
