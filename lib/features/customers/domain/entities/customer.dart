// ========== lib/features/customers/domain/entities/customer.dart ==========

import '../../data/models/customer_entity.dart';

/// Müşteri domain entity'si - Business logic katmanı için
class Customer {
  /// Müşteri benzersiz ID'si
  final String id;

  /// Müşteri/Şirket adı
  final String name;

  /// E-posta adresi
  final String? email;

  /// Telefon numarası
  final String? phone;

  /// Adres bilgisi
  final String? address;

  /// Vergi numarası
  final String? taxNumber;

  /// Vergi dairesi
  final String? taxOffice;

  /// Müşteri tipi
  final CustomerType customerType;

  /// Şehir
  final String? city;

  /// Ülke
  final String? country;

  /// Posta kodu
  final String? postalCode;

  /// Notlar
  final String? notes;

  /// Aktif/Pasif durumu
  final bool isActive;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.taxNumber,
    this.taxOffice,
    required this.customerType,
    this.city,
    this.country,
    this.postalCode,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// CustomerEntity'den Customer'a dönüştürme
  factory Customer.fromEntity(CustomerEntity entity) {
    return Customer(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      address: entity.address,
      taxNumber: entity.taxNumber,
      taxOffice: entity.taxOffice,
      customerType: CustomerType.fromValue(entity.customerType),
      city: entity.city,
      country: entity.country,
      postalCode: entity.postalCode,
      notes: entity.notes,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Customer'dan CustomerEntity'ye dönüştürme
  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      taxNumber: taxNumber,
      taxOffice: taxOffice,
      customerType: customerType.value,
      city: city,
      country: country,
      postalCode: postalCode,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// CopyWith metodu
  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? taxOffice,
    CustomerType? customerType,
    String? city,
    String? country,
    String? postalCode,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      taxOffice: taxOffice ?? this.taxOffice,
      customerType: customerType ?? this.customerType,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Müşterinin tam adres bilgisini döndürür
  String get fullAddress {
    final parts = <String>[];
    
    if (address != null && address!.isNotEmpty) {
      parts.add(address!);
    }
    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }
    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add(postalCode!);
    }
    
    return parts.join(', ');
  }

  /// Müşterinin görüntülenecek adını döndürür
  String get displayName {
    return name.trim();
  }

  /// Müşterinin baş harflerini döndürür (avatar için)
  String get initials {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '';
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Müşterinin kısa bilgisini döndürür
  String get shortInfo {
    final parts = <String>[];
    
    if (phone != null && phone!.isNotEmpty) {
      parts.add(phone!);
    }
    if (email != null && email!.isNotEmpty) {
      parts.add(email!);
    }
    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }
    
    return parts.join(' • ');
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, type: ${customerType.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
