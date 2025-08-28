// ========== CONTACT ENTITY ==========
// lib/features/directory/domain/entities/contact.dart

import 'package:floor/floor.dart';

/// Fihrist kişi/kurum varlığı
@Entity(tableName: 'contacts')
class Contact {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Kişi/kurum adı
  @ColumnInfo(name: 'name')
  final String name;

  /// Kişi/kurum tipi (müşteri, tedarikçi, her ikisi)
  @ColumnInfo(name: 'type')
  final ContactType type;

  /// E-posta adresi
  @ColumnInfo(name: 'email')
  final String? email;

  /// Telefon numarası
  @ColumnInfo(name: 'phone')
  final String? phone;

  /// Adres
  @ColumnInfo(name: 'address')
  final String? address;

  /// Şehir
  @ColumnInfo(name: 'city')
  final String? city;

  /// Ülke
  @ColumnInfo(name: 'country')
  final String? country;

  /// Vergi numarası
  @ColumnInfo(name: 'tax_number')
  final String? taxNumber;

  /// Vergi dairesi
  @ColumnInfo(name: 'tax_office')
  final String? taxOffice;

  /// Web sitesi
  @ColumnInfo(name: 'website')
  final String? website;

  /// Notlar
  @ColumnInfo(name: 'notes')
  final String? notes;

  /// Favori mi?
  @ColumnInfo(name: 'is_favorite')
  final bool isFavorite;

  /// Aktif mi?
  @ColumnInfo(name: 'is_active')
  final bool isActive;

  /// Oluşturulma tarihi
  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;

  /// Güncellenme tarihi
  @ColumnInfo(name: 'updated_at')
  final DateTime updatedAt;

  Contact({
    this.id,
    required this.name,
    required this.type,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.taxNumber,
    this.taxOffice,
    this.website,
    this.notes,
    this.isFavorite = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Kopyalama metodu
  Contact copyWith({
    int? id,
    String? name,
    ContactType? type,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? taxNumber,
    String? taxOffice,
    String? website,
    String? notes,
    bool? isFavorite,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      taxNumber: taxNumber ?? this.taxNumber,
      taxOffice: taxOffice ?? this.taxOffice,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan Contact oluştur
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as int?,
      name: json['name'] as String,
      type: ContactType.values.firstWhere(
        (e) => e.toString() == 'ContactType.${json['type']}',
        orElse: () => ContactType.customer,
      ),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      taxNumber: json['tax_number'] as String?,
      taxOffice: json['tax_office'] as String?,
      website: json['website'] as String?,
      notes: json['notes'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Contact'ı JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'tax_number': taxNumber,
      'tax_office': taxOffice,
      'website': website,
      'notes': notes,
      'is_favorite': isFavorite,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, type: $type)';
  }
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
