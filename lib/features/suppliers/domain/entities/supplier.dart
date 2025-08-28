// ========== SUPPLIER ENTITY ==========
// lib/features/suppliers/domain/entities/supplier.dart

/// Tedarikçi durumu enum'u
enum SupplierStatus {
  active('Aktif'),
  inactive('Pasif'),
  suspended('Askıya Alınmış');

  const SupplierStatus(this.displayName);
  final String displayName;
}

/// Tedarikçi entity sınıfı
class Supplier {
  final String id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final String taxNumber;
  final String taxOffice;
  final String bankName;
  final String bankAccount;
  final double creditLimit;
  final double currentBalance;
  final SupplierStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.taxNumber,
    required this.taxOffice,
    required this.bankName,
    required this.bankAccount,
    required this.creditLimit,
    required this.currentBalance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Kopyalama metodu
  Supplier copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? taxOffice,
    String? bankName,
    String? bankAccount,
    double? creditLimit,
    double? currentBalance,
    SupplierStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      taxOffice: taxOffice ?? this.taxOffice,
      bankName: bankName ?? this.bankName,
      bankAccount: bankAccount ?? this.bankAccount,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan Supplier oluşturma
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      contactPerson: json['contactPerson'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      taxNumber: json['taxNumber'] as String,
      taxOffice: json['taxOffice'] as String,
      bankName: json['bankName'] as String,
      bankAccount: json['bankAccount'] as String,
      creditLimit: (json['creditLimit'] as num).toDouble(),
      currentBalance: (json['currentBalance'] as num).toDouble(),
      status: SupplierStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SupplierStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'taxNumber': taxNumber,
      'taxOffice': taxOffice,
      'bankName': bankName,
      'bankAccount': bankAccount,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Supplier && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Supplier(id: $id, name: $name, status: $status)';
  }
}
