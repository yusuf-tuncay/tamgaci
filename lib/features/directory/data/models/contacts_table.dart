// ========== CONTACTS TABLE ==========
// lib/features/directory/data/models/contacts_table.dart

import 'package:drift/drift.dart';

/// Contacts tablosu
class Contacts extends Table {
  /// ID (Primary Key)
  IntColumn get id => integer().autoIncrement()();

  /// Kişi/kurum adı
  TextColumn get name => text()();

  /// Kişi/kurum tipi (müşteri, tedarikçi, her ikisi)
  TextColumn get type => textEnum<ContactType>()();

  /// E-posta adresi
  TextColumn get email => text().nullable()();

  /// Telefon numarası
  TextColumn get phone => text().nullable()();

  /// Adres
  TextColumn get address => text().nullable()();

  /// Şehir
  TextColumn get city => text().nullable()();

  /// Ülke
  TextColumn get country => text().nullable()();

  /// Vergi numarası
  TextColumn get taxNumber => text().nullable()();

  /// Vergi dairesi
  TextColumn get taxOffice => text().nullable()();

  /// Web sitesi
  TextColumn get website => text().nullable()();

  /// Notlar
  TextColumn get notes => text().nullable()();

  /// Favori mi?
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  /// Aktif mi?
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Oluşturulma tarihi
  DateTimeColumn get createdAt => dateTime()();

  /// Güncellenme tarihi
  DateTimeColumn get updatedAt => dateTime()();
}

/// Kişi/kurum tipi enum'u
enum ContactType {
  /// Müşteri
  customer,

  /// Tedarikçi
  supplier,

  /// Her ikisi
  both,
}

/// ContactType için extension
extension ContactTypeExtension on ContactType {
  /// Türkçe adını döndür
  String get displayName {
    switch (this) {
      case ContactType.customer:
        return 'Müşteri';
      case ContactType.supplier:
        return 'Tedarikçi';
      case ContactType.both:
        return 'Müşteri & Tedarikçi';
    }
  }

  /// İkon adını döndür
  String get iconName {
    switch (this) {
      case ContactType.customer:
        return 'person';
      case ContactType.supplier:
        return 'business';
      case ContactType.both:
        return 'people';
    }
  }
}

