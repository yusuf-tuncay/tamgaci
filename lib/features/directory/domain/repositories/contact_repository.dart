// ========== CONTACT REPOSITORY ==========
// lib/features/directory/domain/repositories/contact_repository.dart

import '../entities/contact.dart';
import '../entities/contact_type.dart';

/// Fihrist repository interface'i
abstract class ContactRepository {
  /// Tüm kişi/kurumları getir
  Future<List<Contact>> getAllContacts();

  /// Aktif kişi/kurumları getir
  Future<List<Contact>> getActiveContacts();

  /// ID'ye göre kişi/kurum getir
  Future<Contact?> getContactById(String id);

  /// Tip'e göre kişi/kurumları getir
  Future<List<Contact>> getContactsByType(ContactType type);

  /// Favori kişi/kurumları getir
  Future<List<Contact>> getFavoriteContacts();

  /// Arama yap
  Future<List<Contact>> searchContacts(String query);

  /// Yeni kişi/kurum ekle
  Future<String> insertContact(Contact contact);

  /// Kişi/kurum güncelle
  Future<void> updateContact(Contact contact);

  /// Kişi/kurum sil
  Future<void> deleteContact(String id);

  /// Kişi/kurum sayısını getir
  Future<int> getContactCount();

  /// Tip'e göre kişi/kurum sayısını getir
  Future<int> getContactCountByType(ContactType type);

  /// Favori kişi/kurum sayısını getir
  Future<int> getFavoriteContactCount();

  /// E-posta ile kişi/kurum ara
  Future<Contact?> getContactByEmail(String email);

  /// Telefon ile kişi/kurum ara
  Future<Contact?> getContactByPhone(String phone);

  /// Vergi numarası ile kişi/kurum ara
  Future<Contact?> getContactByTaxNumber(String taxNumber);

  /// Şehir'e göre kişi/kurumları getir
  Future<List<Contact>> getContactsByCity(String city);

  /// Ülke'ye göre kişi/kurumları getir
  Future<List<Contact>> getContactsByCountry(String country);

  /// Tarih aralığına göre kişi/kurumları getir
  Future<List<Contact>> getContactsByDateRange(
      DateTime startDate, DateTime endDate);

  /// Son eklenen kişi/kurumları getir
  Future<List<Contact>> getRecentContacts(int limit);

  /// En çok kullanılan kişi/kurumları getir
  Future<List<Contact>> getMostUsedContacts(int limit);

  /// Kişi/kurum istatistiklerini getir
  Future<Map<String, dynamic>> getContactStatistics();
}
