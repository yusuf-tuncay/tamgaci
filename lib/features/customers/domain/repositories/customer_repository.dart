// ========== lib/features/customers/domain/repositories/customer_repository.dart ==========

import '../entities/customer.dart';
import '../entities/customer_enums.dart';

/// Müşteri repository interface'i - Domain katmanı
abstract class CustomerRepository {
  // ========== CREATE ==========

  /// Yeni müşteri oluşturma
  Future<String> createCustomer(Customer customer);

  /// Birden fazla müşteri oluşturma
  Future<void> createCustomers(List<Customer> customers);

  // ========== READ ==========

  /// Tüm müşterileri getirme
  Future<List<Customer>> getAllCustomers();

  /// Aktif müşterileri getirme
  Future<List<Customer>> getActiveCustomers();

  /// ID ile müşteri getirme
  Future<Customer?> getCustomerById(String id);

  /// İsme göre müşteri arama
  Future<List<Customer>> searchCustomers(String query);

  /// Müşteri tipine göre filtreleme
  Future<List<Customer>> getCustomersByType(CustomerType type);

  /// Şehre göre müşteri filtreleme
  Future<List<Customer>> getCustomersByCity(String city);

  /// E-posta kontrolü
  Future<Customer?> getCustomerByEmail(String email);

  /// Telefon kontrolü
  Future<Customer?> getCustomerByPhone(String phone);

  /// Vergi numarası kontrolü
  Future<Customer?> getCustomerByTaxNumber(String taxNumber);

  /// Toplam müşteri sayısı
  Future<int> getTotalCustomerCount();

  /// Aktif müşteri sayısı
  Future<int> getActiveCustomerCount();

  /// Pasif müşteri sayısı
  Future<int> getInactiveCustomerCount();

  /// Son eklenen müşteriler
  Future<List<Customer>> getRecentCustomers({int limit = 10});

  // ========== UPDATE ==========

  /// Müşteri güncelleme
  Future<void> updateCustomer(Customer customer);

  /// Müşteri durumu güncelleme
  Future<void> updateCustomerStatus(String id, bool isActive);

  /// Müşteri bakiyesini güncelleme
  Future<void> updateCustomerBalance(String id, double newBalance);

  /// Müşteri bakiyesini hesaplama
  Future<double> calculateCustomerBalance(String id);

  /// Tüm müşteri bakiyelerini yeniden hesaplama
  Future<void> recalculateAllCustomerBalances();

  // ========== DELETE ==========

  /// Müşteri silme
  Future<void> deleteCustomer(String id);

  /// Pasif müşterileri silme
  Future<void> deleteInactiveCustomers();

  // ========== STREAM/REACTIVE ==========

  /// Tüm müşterileri stream olarak izleme
  Stream<List<Customer>> watchAllCustomers();

  /// Aktif müşterileri stream olarak izleme
  Stream<List<Customer>> watchActiveCustomers();

  /// Pasif müşterileri stream olarak izleme
  Stream<List<Customer>> watchInactiveCustomers();

  /// Belirli müşteriyi stream olarak izleme
  Stream<Customer?> watchCustomerById(String id);

  /// Aktif müşteri sayısını stream olarak izleme
  Stream<int> watchActiveCustomerCount();

  /// Pasif müşteri sayısını stream olarak izleme
  Stream<int> watchInactiveCustomerCount();

  // ========== İSTATİSTİKLER ==========

  /// Müşteri tipi istatistikleri
  Future<Map<CustomerType, int>> getCustomerTypeStats();

  /// Şehirlere göre müşteri dağılımı
  Future<Map<String, int>> getCustomerCityStats();

  /// Aylık müşteri ekleme istatistikleri
  Future<Map<String, int>> getMonthlyCustomerStats();
}
