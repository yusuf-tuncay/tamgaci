import 'package:floor/floor.dart';
import 'package:tamgaci/core/database/converters/date_time_converter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/customer.dart';

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

  /// Müşteri bakiyesi (kuruş cinsinden)
  @ColumnInfo(name: 'balance')
  final int balance;

  /// Bakiye para birimi
  @ColumnInfo(name: 'balance_currency')
  final String balanceCurrency;

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
    this.balance = 0,
    this.balanceCurrency = 'TRY',
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
      balance: json['balance'] as int? ?? 0,
      balanceCurrency: json['balance_currency'] as String? ?? 'TRY',
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
      'balance': balance,
      'balance_currency': balanceCurrency,
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
    int? balance,
    String? balanceCurrency,
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
      balance: balance ?? this.balance,
      balanceCurrency: balanceCurrency ?? this.balanceCurrency,
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

  /// Firebase Firestore'dan entity oluşturma
  factory CustomerEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerEntity(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      taxNumber: data['taxNumber'] as String?,
      taxOffice: data['taxOffice'] as String?,
      customerType:
          data['customerType'] as String? ?? CustomerType.individual.value,
      city: data['city'] as String?,
      country: data['country'] as String?,
      postalCode: data['postalCode'] as String?,
      balance: data['balance'] as int? ?? 0,
      balanceCurrency: data['balanceCurrency'] as String? ?? 'TRY',
      notes: data['notes'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Entity'yi Firebase Firestore formatına dönüştürme
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'taxNumber': taxNumber,
      'taxOffice': taxOffice,
      'customerType': customerType,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'balance': balance,
      'balanceCurrency': balanceCurrency,
      'notes': notes,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Domain modeline dönüştürme
  Customer toDomain() {
    return Customer(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      taxNumber: taxNumber,
      taxOffice: taxOffice,
      customerType: CustomerType.fromValue(customerType),
      city: city,
      country: country,
      postalCode: postalCode,
      balance: balance / 100.0,
      balanceCurrency: balanceCurrency,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Domain modelinden entity oluşturma
  factory CustomerEntity.fromDomain(Customer customer) {
    return CustomerEntity(
      id: customer.id,
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      address: customer.address,
      taxNumber: customer.taxNumber,
      taxOffice: customer.taxOffice,
      customerType: customer.customerType.value,
      city: customer.city,
      country: customer.country,
      postalCode: customer.postalCode,
      balance: (customer.balance * 100).round(),
      balanceCurrency: customer.balanceCurrency,
      notes: customer.notes,
      isActive: customer.isActive,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
    );
  }
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
