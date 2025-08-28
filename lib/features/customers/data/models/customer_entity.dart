import 'package:floor/floor.dart';
import 'package:tamgaci/core/database/converters/date_time_converter.dart';

/// Müşteri varlığı - Database entity sınıfı
@TypeConverters([DateTimeConverter])
@Entity(tableName: 'customers')
class CustomerEntity {
  /// Müşteri benzersiz ID'si (Primary Key)
  @PrimaryKey()
  final String id;

  /// Müşteri/Şirket adı
  @ColumnInfo(name: 'name')
  final String name;

  /// E-posta adresi
  @ColumnInfo(name: 'email')
  final String? email;

  /// Telefon numarası
  @ColumnInfo(name: 'phone')
  final String? phone;

  /// Adres bilgisi
  @ColumnInfo(name: 'address')
  final String? address;

  /// Vergi numarası
  @ColumnInfo(name: 'tax_number')
  final String? taxNumber;

  /// Vergi dairesi
  @ColumnInfo(name: 'tax_office')
  final String? taxOffice;

  /// Müşteri tipi (individual: Bireysel, company: Kurumsal)
  @ColumnInfo(name: 'customer_type')
  final String customerType;

  /// Şehir
  @ColumnInfo(name: 'city')
  final String? city;

  /// Ülke
  @ColumnInfo(name: 'country')
  final String? country;

  /// Posta kodu
  @ColumnInfo(name: 'postal_code')
  final String? postalCode;

  /// Notlar
  @ColumnInfo(name: 'notes')
  final String? notes;

  /// Aktif/Pasif durumu
  @ColumnInfo(name: 'is_active')
  final bool isActive;

  /// Oluşturulma tarihi
  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;

  /// Güncellenme tarihi
  @ColumnInfo(name: 'updated_at')
  final DateTime updatedAt;

  /// CustomerEntity constructor
  const CustomerEntity({
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

  /// Factory constructor - JSON'dan oluşturma
  factory CustomerEntity.fromJson(Map<String, dynamic> json) {
    return CustomerEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      taxNumber: json['tax_number'] as String?,
      taxOffice: json['tax_office'] as String?,
      customerType: json['customer_type'] as String,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postal_code'] as String?,
      notes: json['notes'] as String?,
      isActive: (json['is_active'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
    );
  }

  /// JSON'a dönüştürme metodu
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'tax_number': taxNumber,
      'tax_office': taxOffice,
      'customer_type': customerType,
      'city': city,
      'country': country,
      'postal_code': postalCode,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// CopyWith metodu - Güncelleme için
  CustomerEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? taxOffice,
    String? customerType,
    String? city,
    String? country,
    String? postalCode,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerEntity(
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

  @override
  String toString() {
    return 'CustomerEntity(id: $id, name: $name, customerType: $customerType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Müşteri türleri enum'u
enum CustomerType {
  /// Bireysel müşteri
  individual('individual', 'Bireysel'),

  /// Kurumsal müşteri
  company('company', 'Kurumsal');

  const CustomerType(this.value, this.displayName);

  /// Database'de saklanacak değer
  final String value;

  /// Kullanıcıya gösterilecek isim
  final String displayName;

  /// String değerden CustomerType oluşturma
  static CustomerType fromValue(String value) {
    switch (value) {
      case 'individual':
        return CustomerType.individual;
      case 'company':
        return CustomerType.company;
      default:
        throw ArgumentError('Invalid customer type: $value');
    }
  }
}
