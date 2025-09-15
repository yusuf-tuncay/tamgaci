// ========== lib/features/customers/domain/entities/customer.dart ==========

// import '../../data/models/customer_entity.dart'; // Removed - using Firebase only
import 'customer_enums.dart';

/// Müşteri domain entity'si - Business logic katmanı için
class Customer {
  /// Müşteri benzersiz ID'si
  final String id;

  /// Müşteri/Şirket adı
  final String name;

  /// Müşteri kodu
  final String? customerCode;

  /// Müşteri kategorisi
  final String? category;

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

  /// Müşteri durumu
  final CustomerStatus status;

  /// Kredi limiti
  final double creditLimit;

  /// Mevcut bakiye
  final double currentBalance;

  /// Şirket ID'si
  final String companyId;

  /// Şehir
  final String? city;

  /// Ülke
  final String? country;

  /// Posta kodu
  final String? postalCode;

  /// Müşteri bakiyesi
  final double balance;

  /// Bakiye para birimi
  final String balanceCurrency;

  /// Notlar
  final String? notes;

  /// Aktif/Pasif durumu
  final bool isActive;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  /// Oluşturan kullanıcı
  final String createdBy;

  /// Güncelleyen kullanıcı
  final String? updatedBy;

  const Customer({
    required this.id,
    required this.name,
    this.customerCode,
    this.category,
    this.email,
    this.phone,
    this.address,
    this.taxNumber,
    this.taxOffice,
    required this.customerType,
    required this.status,
    this.creditLimit = 0.0,
    this.currentBalance = 0.0,
    required this.companyId,
    this.city,
    this.country,
    this.postalCode,
    this.balance = 0.0,
    this.balanceCurrency = 'TRY',
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CustomerEntity'den Customer'a dönüştürme - Removed
  // factory Customer.fromEntity(CustomerEntity entity) { ... }

  /// Customer'dan CustomerEntity'ye dönüştürme - Removed
  // CustomerEntity toEntity() { ... }

  /// CopyWith metodu
  Customer copyWith({
    String? id,
    String? name,
    String? customerCode,
    String? category,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? taxOffice,
    CustomerType? customerType,
    CustomerStatus? status,
    double? creditLimit,
    double? currentBalance,
    String? companyId,
    String? city,
    String? country,
    String? postalCode,
    double? balance,
    String? balanceCurrency,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      customerCode: customerCode ?? this.customerCode,
      category: category ?? this.category,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      taxOffice: taxOffice ?? this.taxOffice,
      customerType: customerType ?? this.customerType,
      status: status ?? this.status,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      companyId: companyId ?? this.companyId,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      balance: balance ?? this.balance,
      balanceCurrency: balanceCurrency ?? this.balanceCurrency,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
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

  /// Formatlanmış bakiye
  String get formattedBalance {
    return '${balance.toStringAsFixed(2)} $balanceCurrency';
  }

  /// Bakiye para birimi sembolü
  String get balanceCurrencySymbol {
    switch (balanceCurrency.toUpperCase()) {
      case 'TRY':
        return '₺';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'RUB':
        return '₽';
      case 'CNY':
        return '¥';
      case 'AED':
        return 'د.إ';
      case 'BGN':
        return 'лв';
      case 'CHF':
        return 'CHF';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'JPY':
        return '¥';
      default:
        return balanceCurrency;
    }
  }

  /// Bakiye pozitif mi?
  bool get hasPositiveBalance {
    return balance > 0;
  }

  /// Bakiye negatif mi?
  bool get hasNegativeBalance {
    return balance < 0;
  }

  /// Bakiye sıfır mı?
  bool get hasZeroBalance {
    return balance == 0;
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, type: ${customerType.displayName}, balance: $formattedBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// JSON'dan Customer oluştur
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      customerCode: json['customerCode'] as String?,
      category: json['category'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      taxNumber: json['taxNumber'] as String?,
      taxOffice: json['taxOffice'] as String?,
      customerType: CustomerType.values.firstWhere(
        (e) => e.name == json['customerType'],
        orElse: () => CustomerType.individual,
      ),
      status: CustomerStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CustomerStatus.active,
      ),
      creditLimit: (json['creditLimit'] ?? 0.0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0.0).toDouble(),
      companyId: json['companyId'] as String,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] ?? true,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Customer'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'customerCode': customerCode,
      'category': category,
      'email': email,
      'phone': phone,
      'address': address,
      'taxNumber': taxNumber,
      'taxOffice': taxOffice,
      'customerType': customerType.name,
      'status': status.name,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'companyId': companyId,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'notes': notes,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
