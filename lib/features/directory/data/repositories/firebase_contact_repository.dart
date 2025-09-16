// ========== FIREBASE CONTACT REPOSITORY ==========
// lib/features/directory/data/repositories/firebase_contact_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/contact_type.dart';
import '../../domain/repositories/contact_repository.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Firebase Firestore tabanlı contact repository implementasyonu
class FirebaseContactRepository implements ContactRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'contacts';

  // ========== CONTACT OPERATIONS ==========

  @override
  Future<String> insertContact(Contact contact) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      final contactData = _contactToMap(contact.copyWith(id: docRef.id));
      await docRef.set(contactData);
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating contact', e);
      rethrow;
    }
  }

  @override
  Future<void> updateContact(Contact contact) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(contact.id)
          .update(_contactToMap(contact));
    } catch (e) {
      AppLogger.error('Error updating contact', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteContact(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      AppLogger.error('Error deleting contact', e);
      rethrow;
    }
  }

  @override
  Future<Contact?> getContactById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collectionName).doc(id).get();
      if (!docSnapshot.exists) return null;
      return _contactFromMap(docSnapshot);
    } catch (e) {
      AppLogger.error('Error getting contact by ID', e);
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
      AppLogger.error('Error getting all contacts', e);
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
      AppLogger.error('Error getting active contacts', e);
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
      AppLogger.error('Error getting favorite contacts', e);
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
      AppLogger.error('Error getting recent contacts', e);
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
      AppLogger.error('Error searching contacts', e);
      rethrow;
    }
  }

  @override
  Future<List<Contact>> getContactsByType(ContactType type) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      return querySnapshot.docs
          .map((doc) => _contactFromMap(doc))
          .where((contact) => contact.type.value == type.value)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      AppLogger.error('Error getting contacts by type', e);
      rethrow;
    }
  }

  @override
  Future<int> getContactCount() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting contact count', e);
      rethrow;
    }
  }

  @override
  Future<int> getContactCountByType(ContactType type) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      return querySnapshot.docs
          .map((doc) => _contactFromMap(doc))
          .where((contact) => contact.type.value == type.value)
          .length;
    } catch (e) {
      AppLogger.error('Error getting contact count by type', e);
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
      AppLogger.error('Error getting favorite contact count', e);
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
      AppLogger.error('Error getting contact by email', e);
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
      AppLogger.error('Error getting contact by phone', e);
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
      AppLogger.error('Error getting contact by tax number', e);
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
      AppLogger.error('Error getting contacts by country', e);
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
      AppLogger.error('Error getting contacts by date range', e);
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
      AppLogger.error('Error getting most used contacts', e);
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
      AppLogger.error('Error getting contacts by city', e);
      rethrow;
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final contact = await getContactById(id);
      if (contact != null) {
        await updateContact(contact.copyWith(isFavorite: !contact.isFavorite));
      }
    } catch (e) {
      AppLogger.error('Error toggling favorite', e);
      rethrow;
    }
  }

  Future<void> toggleActive(String id) async {
    try {
      final contact = await getContactById(id);
      if (contact != null) {
        await updateContact(contact.copyWith(isActive: !contact.isActive));
      }
    } catch (e) {
      AppLogger.error('Error toggling active', e);
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
      final customers = contacts.where((c) => c.type.value == 0).length;
      final suppliers = contacts.where((c) => c.type.value == 1).length;
      final both = contacts.where((c) => c.type.value == 2).length;

      return {
        'total': total,
        'active': active,
        'favorite': favorite,
        'customers': customers,
        'suppliers': suppliers,
        'both': both,
      };
    } catch (e) {
      AppLogger.error('Error getting contact statistics', e);
      rethrow;
    }
  }

  // ========== STREAM OPERATIONS ==========

  Stream<Contact?> watchContactById(int id) {
    return _firestore
        .collection(_collectionName)
        .doc(id.toString())
        .snapshots()
        .map((doc) => doc.exists ? _contactFromMap(doc) : null);
  }

  Stream<List<Contact>> watchAllContacts() {
    return _firestore
        .collection(_collectionName)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _contactFromMap(doc)).toList());
  }

  Stream<List<Contact>> watchActiveContacts() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => _contactFromMap(doc))
            .where((contact) => contact.isActive)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name)));
  }

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
