// ========== CONTACT DAO ==========
// lib/features/directory/data/datasources/contact_dao.dart

import 'package:drift/drift.dart';
import '../models/contacts_table.dart';

/// Contact DAO sınıfı
/// Veritabanı işlemlerini yönetir
@DriftAccessor(tables: [Contacts])
class ContactDao extends DatabaseAccessor<TamgaciDatabase>
    with _$ContactDaoMixin {
  ContactDao(TamgaciDatabase db) : super(db);

  /// Tüm kişi/kurumları getir
  Future<List<Contact>> getAllContacts() {
    return select(contacts).get();
  }

  /// Aktif kişi/kurumları getir
  Future<List<Contact>> getActiveContacts() {
    return (select(contacts)..where((c) => c.isActive.equals(true))).get();
  }

  /// ID'ye göre kişi/kurum getir
  Future<Contact?> getContactById(int id) {
    return (select(contacts)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Tip'e göre kişi/kurumları getir
  Future<List<Contact>> getContactsByType(ContactType type) {
    return (select(contacts)..where((c) => c.type.equals(type))).get();
  }

  /// Favori kişi/kurumları getir
  Future<List<Contact>> getFavoriteContacts() {
    return (select(contacts)..where((c) => c.isFavorite.equals(true))).get();
  }

  /// Son eklenen kişi/kurumları getir
  Future<List<Contact>> getRecentContacts(int limit) {
    return (select(contacts)
          ..orderBy([(c) => OrderingTerm.desc(c.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Kişi/kurum ara
  Future<List<Contact>> searchContacts(String query) {
    final searchQuery = '%$query%';
    return (select(contacts)
          ..where((c) =>
              c.name.like(searchQuery) |
              c.email.like(searchQuery) |
              c.phone.like(searchQuery) |
              c.address.like(searchQuery) |
              c.city.like(searchQuery)))
        .get();
  }

  /// Yeni kişi/kurum ekle
  Future<int> insertContact(ContactsCompanion contact) {
    return into(contacts).insert(contact);
  }

  /// Kişi/kurum güncelle
  Future<bool> updateContact(ContactsCompanion contact) {
    return update(contacts).replace(contact);
  }

  /// Kişi/kurum sil
  Future<int> deleteContact(int id) {
    return (delete(contacts)..where((c) => c.id.equals(id))).go();
  }

  /// Kişi/kurum sayısını getir
  Future<int> getContactCount() {
    return (select(contacts)..where((c) => c.isActive.equals(true)))
        .get()
        .then((contacts) => contacts.length);
  }

  /// Kişi/kurum istatistiklerini getir
  Future<Map<String, dynamic>> getContactStatistics() {
    return Future.wait([
      getContactCount(),
      getFavoriteContacts().then((contacts) => contacts.length),
      getContactsByType(ContactType.customer)
          .then((contacts) => contacts.length),
      getContactsByType(ContactType.supplier)
          .then((contacts) => contacts.length),
      getContactsByType(ContactType.both).then((contacts) => contacts.length),
    ]).then((results) {
      return {
        'total': results[0],
        'favorites': results[1],
        'customers': results[2],
        'suppliers': results[3],
        'both': results[4],
      };
    });
  }
}
