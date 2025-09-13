// ========== CONTACT REPOSITORY IMPLEMENTATION ==========
// lib/features/directory/data/repositories/contact_repository_impl.dart

import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_dao.dart';

/// Fihrist repository implementation'ı
class ContactRepositoryImpl implements ContactRepository {
  final ContactDao _contactDao;

  ContactRepositoryImpl(this._contactDao);

  @override
  Future<List<Contact>> getAllContacts() async {
    try {
      return await _contactDao.getAllContacts();
    } catch (e) {
      throw Exception('Kişi/kurumlar getirilirken hata oluştu: $e');
    }
  }

  @override
  Future<List<Contact>> getActiveContacts() async {
    try {
      return await _contactDao.getActiveContacts();
    } catch (e) {
      throw Exception('Aktif kişi/kurumlar getirilirken hata oluştu: $e');
    }
  }

  @override
  Future<Contact?> getContactById(int id) async {
    try {
      return await _contactDao.getContactById(id);
    } catch (e) {
      throw Exception('Kişi/kurum getirilirken hata oluştu: $e');
    }
  }

  @override
  Future<List<Contact>> getContactsByType(ContactType type) async {
    try {
      return await _contactDao.getContactsByType(type.index);
    } catch (e) {
      throw Exception("Tip'e göre kişi/kurumlar getirilirken hata oluştu: $e");
    }
  }

  @override
  Future<List<Contact>> getFavoriteContacts() async {
    try {
      return await _contactDao.getFavoriteContacts();
    } catch (e) {
      throw Exception('Favori kişi/kurumlar getirilirken hata oluştu: $e');
    }
  }

  @override
  Future<List<Contact>> searchContacts(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getActiveContacts();
      }
      return await _contactDao.searchContacts(query.trim());
    } catch (e) {
      throw Exception('Arama yapılırken hata oluştu: $e');
    }
  }

  @override
  Future<int> insertContact(Contact contact) async {
    try {
      return await _contactDao.insertContact(contact);
    } catch (e) {
      throw Exception('Kişi/kurum eklenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> updateContact(Contact contact) async {
    try {
      await _contactDao.updateContact(contact);
    } catch (e) {
      throw Exception('Kişi/kurum güncellenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> deleteContact(int id) async {
    try {
      await _contactDao.softDeleteContact(id);
    } catch (e) {
      throw Exception('Kişi/kurum silinirken hata oluştu: $e');
    }
  }

  @override
  Future<int> getContactCount() async {
    try {
      final count = await _contactDao.getContactCount();
      return count;
    } catch (e) {
      throw Exception('Kişi/kurum sayısı getirilirken hata oluştu: $e');
    }
  }

  @override
  Future<int> getContactCountByType(ContactType type) async {
    try {
      final count = await _contactDao.getContactCountByType(type.index);
      return count;
    } catch (e) {
      throw Exception(
          "Tip'e göre kişi/kurum sayısı getirilirken hata oluştu: $e");
    }
  }

  @override
  Future<int> getFavoriteContactCount() async {
    try {
      final count = await _contactDao.getFavoriteContactCount();
      return count;
    } catch (e) {
      throw Exception('Favori kişi/kurum sayısı getirilirken hata oluştu: $e');
    }
  }

  @override
  Future<Contact?> getContactByEmail(String email) async {
    try {
      return await _contactDao.getContactByEmail(email);
    } catch (e) {
      throw Exception('E-posta ile kişi/kurum aranırken hata oluştu: $e');
    }
  }

  @override
  Future<Contact?> getContactByPhone(String phone) async {
    try {
      return await _contactDao.getContactByPhone(phone);
    } catch (e) {
      throw Exception('Telefon ile kişi/kurum aranırken hata oluştu: $e');
    }
  }

  @override
  Future<Contact?> getContactByTaxNumber(String taxNumber) async {
    try {
      return await _contactDao.getContactByTaxNumber(taxNumber);
    } catch (e) {
      throw Exception(
          'Vergi numarası ile kişi/kurum aranırken hata oluştu: $e');
    }
  }

  @override
  Future<List<Contact>> getContactsByCity(String city) async {
    try {
      return await _contactDao.getContactsByCity(city);
    } catch (e) {
      throw Exception(
          "Şehir'e göre kişi/kurumlar getirilirken hata oluştu: $e");
    }
  }

  @override
  Future<List<Contact>> getContactsByCountry(String country) async {
    try {
      return await _contactDao.getContactsByCountry(country);
    } catch (e) {
      throw Exception(
          "Ülke'ye göre kişi/kurumlar getirilirken hata oluştu: $e");
    }
  }

  @override
  Future<List<Contact>> getContactsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      return await _contactDao.getContactsByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception(
          'Tarih aralığına göre kişi/kurumlar getirilirken hata oluştu: $e');
    }
  }

  @override
  Future<List<Contact>> getRecentContacts(int limit) async {
    try {
      return await _contactDao.getRecentContacts(limit);
    } catch (e) {
      throw Exception('Son eklenen kişi/kurumlar getirilirken hata oluştu: $e');
    }
  }

  @override
  Future<List<Contact>> getMostUsedContacts(int limit) async {
    try {
      // Bu özellik için ayrı bir tablo veya sayaç gerekebilir
      // Şimdilik son eklenenleri döndürüyoruz
      return await getRecentContacts(limit);
    } catch (e) {
      throw Exception(
          'En çok kullanılan kişi/kurumlar getirilirken hata oluştu: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getContactStatistics() async {
    try {
      final totalCount = await getContactCount();
      final customerCount = await getContactCountByType(ContactType.customer);
      final supplierCount = await getContactCountByType(ContactType.supplier);
      final bothCount = await getContactCountByType(ContactType.both);
      final favoriteCount = await getFavoriteContactCount();
      final recentContacts = await getRecentContacts(5);

      return {
        'total': totalCount,
        'customers': customerCount,
        'suppliers': supplierCount,
        'both': bothCount,
        'favorites': favoriteCount,
        'recent': recentContacts.length,
        'recentContacts': recentContacts,
      };
    } catch (e) {
      throw Exception('Kişi/kurum istatistikleri getirilirken hata oluştu: $e');
    }
  }
}
