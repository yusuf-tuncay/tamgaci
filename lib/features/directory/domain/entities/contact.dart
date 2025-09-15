// ========== CONTACT ENTITY ==========
// lib/features/directory/domain/entities/contact.dart

import 'contact_type.dart';

/// Contact entity sınıfı
/// Kişi/kurum bilgilerini temsil eder
class Contact {
  /// Benzersiz ID
  final String id;

  /// Ad/Unvan
  final String name;

  /// E-posta adresi
  final String? email;

  /// Telefon numarası
  final String? phone;

  /// Adres
  final String? address;

  /// Şehir
  final String? city;

  /// Ülke
  final String? country;

  /// Vergi numarası
  final String? taxNumber;

  /// Vergi dairesi
  final String? taxOffice;

  /// Web sitesi
  final String? website;

  /// Tip (Müşteri, Tedarikçi, Her ikisi)
  final ContactType type;

  /// Favori mi?
  final bool isFavorite;

  /// Aktif mi?
  final bool isActive;

  /// Notlar
  final String? notes;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  const Contact({
    required this.id,
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
    required this.isFavorite,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Contact'ı kopyala ve güncelle
  Contact copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? taxNumber,
    String? taxOffice,
    String? website,
    ContactType? type,
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
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      taxNumber: json['taxNumber'] as String?,
      taxOffice: json['taxOffice'] as String?,
      website: json['website'] as String?,
      type: ContactType.fromValue(json['type'] as int),
      isFavorite: json['isFavorite'] as bool,
      isActive: json['isActive'] as bool,
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
      'type': type.value,
      'isFavorite': isFavorite,
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
