// ========== CONTACT PROVIDERS ==========
// lib/features/directory/presentation/providers/contact_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../data/datasources/contact_dao.dart';
import '../../data/repositories/contact_repository_impl.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';

/// Contact DAO provider
final contactDaoProvider = Provider<ContactDao?>((ref) {
  if (kIsWeb) {
    // Web platformunda database olmadığı için null döndür
    return null;
  }
  throw UnimplementedError('ContactDao provider must be overridden');
});

/// Contact repository provider
final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final dao = ref.watch(contactDaoProvider);
  if (dao == null) {
    // Web platformu için mock repository döndür
    return _MockContactRepository();
  }
  return ContactRepositoryImpl(dao);
});

/// Tüm kişi/kurumlar provider
final allContactsProvider = FutureProvider<List<Contact>>((ref) async {
  final repository = ref.watch(contactRepositoryProvider);
  return await repository.getActiveContacts();
});

/// Aktif kişi/kurumlar provider
final activeContactsProvider = FutureProvider<List<Contact>>((ref) async {
  final repository = ref.watch(contactRepositoryProvider);
  return await repository.getActiveContacts();
});

/// Favori kişi/kurumlar provider
final favoriteContactsProvider = FutureProvider<List<Contact>>((ref) async {
  final repository = ref.watch(contactRepositoryProvider);
  return await repository.getFavoriteContacts();
});

/// Son eklenen kişi/kurumlar provider
final recentContactsProvider = FutureProvider<List<Contact>>((ref) async {
  final repository = ref.watch(contactRepositoryProvider);
  return await repository.getRecentContacts(10);
});

/// Kişi/kurum istatistikleri provider
final contactStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(contactRepositoryProvider);
  return await repository.getContactStatistics();
});

/// Contact operations state sınıfı
class ContactOperationsState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<Contact> contacts;

  const ContactOperationsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.contacts = const [],
  });

  ContactOperationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<Contact>? contacts,
  }) {
    return ContactOperationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      contacts: contacts ?? this.contacts,
    );
  }
}

/// Contact operations notifier'ı
class ContactOperations extends StateNotifier<ContactOperationsState> {
  final ContactRepository _repository;

  ContactOperations(this._repository) : super(const ContactOperationsState());

  /// Tüm kişi/kurumları yükle
  Future<void> loadContacts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final contacts = await _repository.getActiveContacts();
      state = state.copyWith(
        isLoading: false,
        contacts: contacts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Kişi/kurumlar yüklenirken hata oluştu: $e',
      );
    }
  }

  /// Yeni kişi/kurum ekle
  Future<void> addContact(Contact contact) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);

    try {
      await _repository.insertContact(contact);
      await loadContacts(); // Listeyi yenile
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Kişi/kurum başarıyla eklendi',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Kişi/kurum eklenirken hata oluştu: $e',
      );
    }
  }

  /// Kişi/kurum güncelle
  Future<void> updateContact(Contact contact) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);

    try {
      await _repository.updateContact(contact);
      await loadContacts(); // Listeyi yenile
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Kişi/kurum başarıyla güncellendi',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Kişi/kurum güncellenirken hata oluştu: $e',
      );
    }
  }

  /// Kişi/kurum sil
  Future<void> deleteContact(int id) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);

    try {
      await _repository.deleteContact(id);
      await loadContacts(); // Listeyi yenile
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Kişi/kurum başarıyla silindi',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Kişi/kurum silinirken hata oluştu: $e',
      );
    }
  }

  /// Kişi/kurum ara
  Future<void> searchContacts(String query) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final contacts = await _repository.searchContacts(query);
      state = state.copyWith(
        isLoading: false,
        contacts: contacts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Arama yapılırken hata oluştu: $e',
      );
    }
  }

  /// Tip'e göre kişi/kurumları getir
  Future<void> getContactsByType(ContactType type) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final contacts = await _repository.getContactsByType(type);
      state = state.copyWith(
        isLoading: false,
        contacts: contacts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Kişi/kurumlar getirilirken hata oluştu: $e',
      );
    }
  }

  /// Favori durumunu güncelle
  Future<void> toggleFavorite(Contact contact) async {
    try {
      final updatedContact = contact.copyWith(
        isFavorite: !contact.isFavorite,
        updatedAt: DateTime.now(),
      );
      await _repository.updateContact(updatedContact);
      await loadContacts(); // Listeyi yenile
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Favori durumu güncellenirken hata oluştu: $e',
      );
    }
  }

  /// Hata mesajını temizle
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Başarı mesajını temizle
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }
}

/// Contact operations provider
final contactOperationsProvider =
    StateNotifierProvider<ContactOperations, ContactOperationsState>((ref) {
  final repository = ref.watch(contactRepositoryProvider);
  return ContactOperations(repository);
});

/// Seçili kişi/kurum provider
final selectedContactProvider = StateProvider<Contact?>((ref) => null);

/// Arama sorgusu provider
final contactSearchQueryProvider = StateProvider<String>((ref) => '');

/// Seçili tip provider
final selectedContactTypeProvider = StateProvider<ContactType?>((ref) => null);

/// Web platformu için mock repository
class _MockContactRepository implements ContactRepository {
  @override
  Future<List<Contact>> getAllContacts() async => [];

  @override
  Future<List<Contact>> getActiveContacts() async => [];

  @override
  Future<Contact?> getContactById(int id) async => null;

  @override
  Future<List<Contact>> getContactsByType(ContactType type) async => [];

  @override
  Future<List<Contact>> getFavoriteContacts() async => [];

  @override
  Future<List<Contact>> getRecentContacts(int limit) async => [];

  @override
  Future<List<Contact>> searchContacts(String query) async => [];

  @override
  Future<int> insertContact(Contact contact) async => 0;

  @override
  Future<void> updateContact(Contact contact) async {}

  @override
  Future<void> deleteContact(int id) async {}

  @override
  Future<int> getContactCount() async => 0;

  @override
  Future<int> getContactCountByType(ContactType type) async => 0;

  @override
  Future<int> getFavoriteContactCount() async => 0;

  @override
  Future<Contact?> getContactByEmail(String email) async => null;

  @override
  Future<Contact?> getContactByPhone(String phone) async => null;

  @override
  Future<Contact?> getContactByTaxNumber(String taxNumber) async => null;

  @override
  Future<List<Contact>> getContactsByCity(String city) async => [];

  @override
  Future<List<Contact>> getContactsByCountry(String country) async => [];

  @override
  Future<List<Contact>> getContactsByDateRange(
          DateTime startDate, DateTime endDate) async =>
      [];

  @override
  Future<List<Contact>> getMostUsedContacts(int limit) async => [];

  @override
  Future<Map<String, dynamic>> getContactStatistics() async => {};
}
