// ========== CONTACT ENTITY ==========
// lib/features/directory/domain/entities/contact.dart

import 'package:floor/floor.dart';

/// Contact entity sınıfı
/// Kişi/kurum bilgilerini temsil eder
@Entity(tableName: 'contacts')
class Contact {
  /// Benzersiz ID
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Ad/Unvan
  @ColumnInfo(name: 'name')
  final String name;

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
  @ColumnInfo(name: 'taxNumber')
  final String? taxNumber;

  /// Vergi dairesi
  @ColumnInfo(name: 'taxOffice')
  final String? taxOffice;

  /// Web sitesi
  @ColumnInfo(name: 'website')
  final String? website;

  /// Tip (0: Müşteri, 1: Tedarikçi, 2: Her ikisi)
  @ColumnInfo(name: 'type')
  final int type;

  /// Favori mi?
  @ColumnInfo(name: 'isFavorite')
  final bool isFavorite;

  /// Aktif mi?
  @ColumnInfo(name: 'isActive')
  final bool isActive;

  /// Notlar
  @ColumnInfo(name: 'notes')
  final String? notes;

  /// Oluşturulma tarihi
  @ColumnInfo(name: 'createdAt')
  final DateTime createdAt;

  /// Güncellenme tarihi
  @ColumnInfo(name: 'updatedAt')
  final DateTime updatedAt;

  /// Constructor
  const Contact({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.taxNumber,
    this.taxOffice,
    this.website,
    required this.type,
    this.isFavorite = false,
    this.isActive = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Contact kopyalama metodu
  Contact copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? taxNumber,
    String? taxOffice,
    String? website,
    int? type,
    bool? isFavorite,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      taxNumber: taxNumber ?? this.taxNumber,
      taxOffice: taxOffice ?? this.taxOffice,
      website: website ?? this.website,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan Contact oluştur
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      taxNumber: json['taxNumber'] as String?,
      taxOffice: json['taxOffice'] as String?,
      website: json['website'] as String?,
      type: json['type'] as int,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Contact'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'taxNumber': taxNumber,
      'taxOffice': taxOffice,
      'website': website,
      'type': type,
      'isFavorite': isFavorite,
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
    return 'Contact(id: $id, name: $name, email: $email, phone: $phone)';
  }
}

/// Contact tip enum'u
enum ContactType {
  customer(0),
  supplier(1),
  both(2);

  const ContactType(this.value);
  final int value;

  static ContactType fromValue(int value) {
    switch (value) {
      case 0:
        return ContactType.customer;
      case 1:
        return ContactType.supplier;
      case 2:
        return ContactType.both;
      default:
        return ContactType.customer;
    }
  }

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
