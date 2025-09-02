// ========== FIREBASE CONTACT REPOSITORY ==========
// lib/features/directory/data/repositories/firebase_contact_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';

/// Firebase Firestore tabanlı contact repository implementasyonu
class FirebaseContactRepository implements ContactRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'contacts';

  // ========== CONTACT OPERATIONS ==========

  @override
  Future<int> insertContact(Contact contact) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      final contactData =
          _contactToMap(contact.copyWith(id: docRef.id.hashCode));
      await docRef.set(contactData);
      return docRef.id.hashCode;
    } catch (e) {
      print('Error creating contact: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateContact(Contact contact) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(contact.id.toString())
          .update(_contactToMap(contact));
    } catch (e) {
      print('Error updating contact: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteContact(int id) async {
    try {
      await _firestore.collection(_collectionName).doc(id.toString()).delete();
    } catch (e) {
      print('Error deleting contact: $e');
      rethrow;
    }
  }

  @override
  Future<Contact?> getContactById(int id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collectionName).doc(id.toString()).get();
      if (!docSnapshot.exists) return null;
      return _contactFromMap(docSnapshot);
    } catch (e) {
      print('Error getting contact by ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<Contact>> getAllContacts() async {
    try {
      final querySnapshot =
          await _firestore.collection(_collectionName).orderBy('name').get();

      return querySnapshot.docs.map((doc) => _contactFromMap(doc)).toList();
    } catch (e) {
      print('Error getting all contacts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Contact>> getActiveContacts() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      return querySnapshot.docs
          .map((doc) => _contactFromMap(doc))
          .where((contact) => contact.isActive)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      print('Error getting active contacts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Contact>> getFavoriteContacts() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      return querySnapshot.docs
          .map((doc) => _contactFromMap(doc))
          .where((contact) => contact.isFavorite)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      print('Error getting favorite contacts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Contact>> getRecentContacts(int limit) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => _contactFromMap(doc)).toList();
    } catch (e) {
      print('Error getting recent contacts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Contact>> searchContacts(String query) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      final lowercaseQuery = query.toLowerCase();
      return querySnapshot.docs
          .map((doc) => _contactFromMap(doc))
          .where((contact) =>
              contact.name.toLowerCase().contains(lowercaseQuery) ||
              (contact.email?.toLowerCase().contains(lowercaseQuery) ??
                  false) ||
              (contact.phone?.toLowerCase().contains(lowercaseQuery) ?? false))
          .toList();
    } catch (e) {
      print('Error searching contacts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Contact>> getContactsByType(ContactType type) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      return querySnapshot.docs
          .map((doc) => _contactFromMap(doc))
          .where((contact) => contact.type == type.value)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      print('Error getting contacts by type: $e');
      rethrow;
    }
  }

  @override
  Future<int> getContactCount() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting contact count: $e');
      rethrow;
    }
  }

  @override
  Future<int> getContactCountByType(ContactType type) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      return querySnapshot.docs
          .map((doc) => _contactFromMap(doc))
          .where((contact) => contact.type == type.value)
          .length;
    } catch (e) {
      print('Error getting contact count by type: $e');
      rethrow;
    }
  }

  @override
  Future<int> getFavoriteContactCount() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      return querySnapshot.docs
          .map((doc) => _contactFromMap(doc))
          .where((contact) => contact.isFavorite)
          .length;
    } catch (e) {
      print('Error getting favorite contact count: $e');
      rethrow;
    }
  }

  @override
  Future<Contact?> getContactByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return _contactFromMap(querySnapshot.docs.first);
    } catch (e) {
      print('Error getting contact by email: $e');
      rethrow;
    }
  }

  @override
  Future<Contact?> getContactByPhone(String phone) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return _contactFromMap(querySnapshot.docs.first);
    } catch (e) {
      print('Error getting contact by phone: $e');
      rethrow;
    }
  }

  @override
  Future<Contact?> getContactByTaxNumber(String taxNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('taxNumber', isEqualTo: taxNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return _contactFromMap(querySnapshot.docs.first);
    } catch (e) {
      print('Error getting contact by tax number: $e');
      rethrow;
    }
  }

  @override
  Future<List<Contact>> getContactsByCountry(String country) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      return querySnapshot.docs
          .map((doc) => _contactFromMap(doc))
          .where((contact) => contact.country == country)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      print('Error getting contacts by country: $e');
      rethrow;
    }
  }

  @override
  Future<List<Contact>> getContactsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _contactFromMap(doc)).toList();
    } catch (e) {
      print('Error getting contacts by date range: $e');
      rethrow;
    }
  }

  @override
  Future<List<Contact>> getMostUsedContacts(int limit) async {
    try {
      // Bu metod için basit bir implementasyon - son eklenenleri döndür
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => _contactFromMap(doc)).toList();
    } catch (e) {
      print('Error getting most used contacts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Contact>> getContactsByCity(String city) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      return querySnapshot.docs
          .map((doc) => _contactFromMap(doc))
          .where((contact) => contact.city == city)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      print('Error getting contacts by city: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleFavorite(int id) async {
    try {
      final contact = await getContactById(id);
      if (contact != null) {
        await updateContact(contact.copyWith(isFavorite: !contact.isFavorite));
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleActive(int id) async {
    try {
      final contact = await getContactById(id);
      if (contact != null) {
        await updateContact(contact.copyWith(isActive: !contact.isActive));
      }
    } catch (e) {
      print('Error toggling active: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getContactStatistics() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      final contacts =
          querySnapshot.docs.map((doc) => _contactFromMap(doc)).toList();

      final total = contacts.length;
      final active = contacts.where((c) => c.isActive).length;
      final favorite = contacts.where((c) => c.isFavorite).length;
      final customers = contacts.where((c) => c.type == 0).length;
      final suppliers = contacts.where((c) => c.type == 1).length;
      final both = contacts.where((c) => c.type == 2).length;

      return {
        'total': total,
        'active': active,
        'favorite': favorite,
        'customers': customers,
        'suppliers': suppliers,
        'both': both,
      };
    } catch (e) {
      print('Error getting contact statistics: $e');
      rethrow;
    }
  }

  // ========== STREAM OPERATIONS ==========

  @override
  Stream<Contact?> watchContactById(int id) {
    return _firestore
        .collection(_collectionName)
        .doc(id.toString())
        .snapshots()
        .map((doc) => doc.exists ? _contactFromMap(doc) : null);
  }

  @override
  Stream<List<Contact>> watchAllContacts() {
    return _firestore
        .collection(_collectionName)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _contactFromMap(doc)).toList());
  }

  @override
  Stream<List<Contact>> watchActiveContacts() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => _contactFromMap(doc))
            .where((contact) => contact.isActive)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name)));
  }

  @override
  Stream<List<Contact>> watchFavoriteContacts() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => _contactFromMap(doc))
            .where((contact) => contact.isFavorite)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name)));
  }

  // Helper methods for data conversion
  Map<String, dynamic> _contactToMap(Contact contact) {
    return {
      'id': contact.id,
      'name': contact.name,
      'email': contact.email,
      'phone': contact.phone,
      'address': contact.address,
      'city': contact.city,
      'country': contact.country,
      'taxNumber': contact.taxNumber,
      'taxOffice': contact.taxOffice,
      'website': contact.website,
      'type': contact.type,
      'isFavorite': contact.isFavorite,
      'isActive': contact.isActive,
      'notes': contact.notes,
      'createdAt': contact.createdAt,
      'updatedAt': contact.updatedAt,
    };
  }

  Contact _contactFromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Contact(
      id: data['id'] ?? doc.id.hashCode,
      name: data['name'] ?? '',
      email: data['email'],
      phone: data['phone'],
      address: data['address'],
      city: data['city'],
      country: data['country'],
      taxNumber: data['taxNumber'],
      taxOffice: data['taxOffice'],
      website: data['website'],
      type: data['type'] ?? 0,
      isFavorite: data['isFavorite'] ?? false,
      isActive: data['isActive'] ?? true,
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
