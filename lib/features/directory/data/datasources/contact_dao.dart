// ========== CONTACT DAO ==========
// lib/features/directory/data/datasources/contact_dao.dart

import 'package:floor/floor.dart';
import '../../domain/entities/contact.dart';

/// Contact DAO sınıfı
/// Veritabanı işlemlerini yönetir
@dao
abstract class ContactDao {
  /// Tüm kişi/kurumları getir
  @Query('SELECT * FROM contacts WHERE isActive = 1')
  Future<List<Contact>> getAllContacts();

  /// Aktif kişi/kurumları getir
  @Query('SELECT * FROM contacts WHERE isActive = 1')
  Future<List<Contact>> getActiveContacts();

  /// ID'ye göre kişi/kurum getir
  @Query('SELECT * FROM contacts WHERE id = :id')
  Future<Contact?> getContactById(int id);

  /// Tip'e göre kişi/kurumları getir
  @Query('SELECT * FROM contacts WHERE type = :type AND isActive = 1')
  Future<List<Contact>> getContactsByType(int type);

  /// Favori kişi/kurumları getir
  @Query('SELECT * FROM contacts WHERE isFavorite = 1 AND isActive = 1')
  Future<List<Contact>> getFavoriteContacts();

  /// Son eklenen kişi/kurumları getir
  @Query(
      'SELECT * FROM contacts WHERE isActive = 1 ORDER BY createdAt DESC LIMIT :limit')
  Future<List<Contact>> getRecentContacts(int limit);

  /// Kişi/kurum ara
  @Query('''
    SELECT * FROM contacts 
    WHERE isActive = 1 
    AND (name LIKE :query OR email LIKE :query OR phone LIKE :query OR address LIKE :query OR city LIKE :query)
  ''')
  Future<List<Contact>> searchContacts(String query);

  /// Yeni kişi/kurum ekle
  @insert
  Future<int> insertContact(Contact contact);

  /// Kişi/kurum güncelle
  @update
  Future<int> updateContact(Contact contact);

  /// Kişi/kurum sil
  @delete
  Future<int> deleteContact(Contact contact);

  /// Soft delete - kişi/kurumu pasif yap
  @Query('UPDATE contacts SET isActive = 0 WHERE id = :id')
  Future<int> softDeleteContact(int id);

  /// Kişi/kurum sayısını getir
  @Query('SELECT COUNT(*) FROM contacts WHERE isActive = 1')
  Future<int> getContactCount();

  /// Tip'e göre kişi/kurum sayısını getir
  @Query('SELECT COUNT(*) FROM contacts WHERE type = :type AND isActive = 1')
  Future<int> getContactCountByType(int type);

  /// Favori kişi/kurum sayısını getir
  @Query('SELECT COUNT(*) FROM contacts WHERE isFavorite = 1 AND isActive = 1')
  Future<int> getFavoriteContactCount();

  /// E-posta ile kişi/kurum getir
  @Query('SELECT * FROM contacts WHERE email = :email AND isActive = 1')
  Future<Contact?> getContactByEmail(String email);

  /// Telefon ile kişi/kurum getir
  @Query('SELECT * FROM contacts WHERE phone = :phone AND isActive = 1')
  Future<Contact?> getContactByPhone(String phone);

  /// Vergi numarası ile kişi/kurum getir
  @Query('SELECT * FROM contacts WHERE taxNumber = :taxNumber AND isActive = 1')
  Future<Contact?> getContactByTaxNumber(String taxNumber);

  /// Şehir'e göre kişi/kurumları getir
  @Query('SELECT * FROM contacts WHERE city = :city AND isActive = 1')
  Future<List<Contact>> getContactsByCity(String city);

  /// Ülke'ye göre kişi/kurumları getir
  @Query('SELECT * FROM contacts WHERE country = :country AND isActive = 1')
  Future<List<Contact>> getContactsByCountry(String country);

  /// Tarih aralığına göre kişi/kurumları getir
  @Query(
      'SELECT * FROM contacts WHERE createdAt BETWEEN :startDate AND :endDate AND isActive = 1')
  Future<List<Contact>> getContactsByDateRange(
      DateTime startDate, DateTime endDate);
}
