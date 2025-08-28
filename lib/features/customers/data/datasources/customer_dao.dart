// ========== lib/features/customers/data/datasources/customer_dao.dart ==========

import 'package:floor/floor.dart';
import 'package:tamgaci/features/customers/data/models/stats_views.dart';
import '../models/customer_entity.dart';

/// Müşteri Data Access Object (DAO)
/// Database işlemlerini yöneten sınıf
@dao
abstract class CustomerDao {
  // ========== CREATE (OLUŞTURMA) ==========

  /// Yeni müşteri ekleme
  @Insert()
  Future<void> insertCustomer(CustomerEntity customer);

  /// Birden fazla müşteri ekleme
  @Insert()
  Future<void> insertCustomers(List<CustomerEntity> customers);

  // ========== READ (OKUMA) ==========

  /// Tüm müşteriləri getirme
  @Query('SELECT * FROM customers ORDER BY name ASC')
  Future<List<CustomerEntity>> getAllCustomers();

  /// Aktif müşterileri getirme
  @Query('SELECT * FROM customers WHERE is_active = 1 ORDER BY name ASC')
  Future<List<CustomerEntity>> getActiveCustomers();

  /// ID ile müşteri getirme
  @Query('SELECT * FROM customers WHERE id = :id')
  Future<CustomerEntity?> getCustomerById(String id);

  /// İsme göre müşteri arama
  @Query(
    'SELECT * FROM customers WHERE name LIKE :searchTerm ORDER BY name ASC',
  )
  Future<List<CustomerEntity>> searchCustomersByName(String searchTerm);

  /// Müşteri tipine göre filtreleme
  @Query(
    'SELECT * FROM customers WHERE customer_type = :type AND is_active = 1 ORDER BY name ASC',
  )
  Future<List<CustomerEntity>> getCustomersByType(String type);

  /// Şehre göre müşteri arama
  @Query(
    'SELECT * FROM customers WHERE city = :city AND is_active = 1 ORDER BY name ASC',
  )
  Future<List<CustomerEntity>> getCustomersByCity(String city);

  /// E-posta ile müşteri bulma
  @Query('SELECT * FROM customers WHERE email = :email LIMIT 1')
  Future<CustomerEntity?> getCustomerByEmail(String email);

  /// Telefon ile müşteri bulma
  @Query('SELECT * FROM customers WHERE phone = :phone LIMIT 1')
  Future<CustomerEntity?> getCustomerByPhone(String phone);

  /// Vergi numarası ile müşteri bulma
  @Query('SELECT * FROM customers WHERE tax_number = :taxNumber LIMIT 1')
  Future<CustomerEntity?> getCustomerByTaxNumber(String taxNumber);

  /// Müşteri sayısını getirme
  @Query('SELECT COUNT(*) FROM customers WHERE is_active = 1')
  Future<int?> getActiveCustomerCount();

  /// Toplam müşteri sayısını getirme
  @Query('SELECT COUNT(*) FROM customers')
  Future<int?> getTotalCustomerCount();

  /// Pasif müşteri sayısını getirme
  @Query('SELECT COUNT(*) FROM customers WHERE is_active = 0')
  Future<int?> getInactiveCustomerCount();

  /// Son eklenen müşterileri getirme
  @Query(
    'SELECT * FROM customers WHERE is_active = 1 ORDER BY created_at DESC LIMIT :limit',
  )
  Future<List<CustomerEntity>> getRecentCustomers(int limit);

  // ========== UPDATE (GÜNCELLEME) ==========

  /// Müşteri güncelleme
  @Update()
  Future<void> updateCustomer(CustomerEntity customer);

  /// Müşteri durumunu değiştirme (aktif/pasif)
  @Query(
    'UPDATE customers SET is_active = :isActive, updated_at = :updatedAt WHERE id = :id',
  )
  Future<void> updateCustomerStatus(String id, bool isActive, int updatedAt);

  /// Müşteri notunu güncelleme
  @Query(
    'UPDATE customers SET notes = :notes, updated_at = :updatedAt WHERE id = :id',
  )
  Future<void> updateCustomerNotes(String id, String notes, int updatedAt);

  // ========== DELETE (SİLME) ==========

  /// Müşteri silme (fiziksel)
  @delete
  Future<void> deleteCustomer(CustomerEntity customer);

  /// ID ile müşteri silme
  @Query('DELETE FROM customers WHERE id = :id')
  Future<void> deleteCustomerById(String id);

  /// Pasif müşterileri silme
  @Query('DELETE FROM customers WHERE is_active = 0')
  Future<void> deleteInactiveCustomers();

  /// Tüm müşterileri silme (dikkatli kullanın!)
  @Query('DELETE FROM customers')
  Future<void> deleteAllCustomers();

  // ========== STREAM (REACTIVE) ==========

  /// Tüm müşterileri stream olarak izleme
  @Query('SELECT * FROM customers ORDER BY name ASC')
  Stream<List<CustomerEntity>> watchAllCustomers();

  /// Aktif müşterileri stream olarak izleme
  @Query('SELECT * FROM customers WHERE is_active = 1 ORDER BY name ASC')
  Stream<List<CustomerEntity>> watchActiveCustomers();

  /// Pasif müşterileri stream olarak izleme
  @Query('SELECT * FROM customers WHERE is_active = 0 ORDER BY name ASC')
  Stream<List<CustomerEntity>> watchInactiveCustomers();

  /// Belirli müşteriyi stream olarak izleme
  @Query('SELECT * FROM customers WHERE id = :id')
  Stream<CustomerEntity?> watchCustomerById(String id);

  /// Aktif müşteri sayısını stream olarak izleme
  @Query('SELECT COUNT(*) FROM customers WHERE is_active = 1')
  Stream<int?> watchActiveCustomerCount();

  /// Pasif müşteri sayısını stream olarak izleme
  @Query('SELECT COUNT(*) FROM customers WHERE is_active = 0')
  Stream<int?> watchInactiveCustomerCount();

  // ========== İSTATİSTİK SORGULARI ==========

  /// Müşteri tipine göre istatistik
  @Query('''
  SELECT 
    customer_type AS customerType,
    COUNT(*) AS count
  FROM customers 
  WHERE is_active = 1 
  GROUP BY customer_type
''')
  Future<List<CustomerTypeStat>> getCustomerTypeStats();

  /// Şehirlere göre müşteri dağılımı
  @Query('''
    SELECT 
      city,
      COUNT(*) as count
    FROM customers 
    WHERE is_active = 1 AND city IS NOT NULL
    GROUP BY city
    ORDER BY count DESC
    LIMIT 10
  ''')
  Future<List<CityCustomerCount>> getCityCustomerCounts();

  /// Aylık müşteri ekleme istatistikleri
  @Query('''
    SELECT 
      strftime('%Y-%m', datetime(created_at / 1000, 'unixepoch')) as month,
      COUNT(*) as count
    FROM customers
    GROUP BY month
    ORDER BY month DESC
    LIMIT 12
  ''')
  Future<List<MonthlyCustomerStat>> getMonthlyCustomerStats();
}
