// ========== FIREBASE SUPPLIER ENTITY ==========
// lib/features/suppliers/data/models/firebase_supplier_entity.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/supplier.dart';

/// Firebase için optimize edilmiş tedarikçi entity'si
class FirebaseSupplierEntity {
  final String id;
  final String name;
  final String? supplierCode;
  final String? category;
  final String? email;
  final String? phone;
  final String? address;
  final String? taxNumber;
  final String? taxOffice;
  final String supplierType; // 'individual' veya 'company'
  final String status; // 'active', 'inactive', 'suspended'
  final double creditLimit;
  final double currentBalance;
  final String companyId;
  final String? city;
  final String? country;
  final String? postalCode;
  final double balance;
  final String currency;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  // Tedarikçi özel alanları
  final String? contactPerson;
  final String? bankName;
  final String? bankAccount;
  final String? website;
  final String? paymentTerms;
  final int paymentDays;
  final double discountRate;

  // Hem müşteri hem tedarikçi olabilir
  final bool isCustomer;
  final String? customerId;

  const FirebaseSupplierEntity({
    required this.id,
    required this.name,
    this.supplierCode,
    this.category,
    this.email,
    this.phone,
    this.address,
    this.taxNumber,
    this.taxOffice,
    required this.supplierType,
    required this.status,
    this.creditLimit = 0.0,
    this.currentBalance = 0.0,
    required this.companyId,
    this.city,
    this.country,
    this.postalCode,
    this.balance = 0.0,
    this.currency = 'TRY',
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.contactPerson,
    this.bankName,
    this.bankAccount,
    this.website,
    this.paymentTerms,
    this.paymentDays = 30,
    this.discountRate = 0.0,
    this.isCustomer = false,
    this.customerId,
  });

  /// Domain entity'den Firebase entity'ye dönüştürme
  factory FirebaseSupplierEntity.fromDomain(Supplier supplier) {
    return FirebaseSupplierEntity(
      id: supplier.id,
      name: supplier.name,
      supplierCode: supplier.supplierCode,
      category: supplier.category1,
      email: supplier.email,
      phone: supplier.phone,
      address: supplier.address,
      taxNumber: supplier.taxNumber,
      taxOffice: supplier.taxOffice,
      supplierType: supplier.supplierType.name,
      status: supplier.status.name,
      creditLimit: supplier.creditLimit,
      currentBalance: supplier.currentBalance,
      companyId: supplier.companyId,
      city: supplier.city,
      country: supplier.country,
      postalCode: supplier.postalCode,
      balance: supplier.balance,
      currency: supplier.currency,
      notes: supplier.notes,
      isActive: supplier.isActive,
      createdAt: supplier.createdAt,
      updatedAt: supplier.updatedAt,
      createdBy: supplier.createdBy,
      updatedBy: supplier.updatedBy,
      contactPerson: supplier.contactPerson,
      bankName: supplier.bankName,
      bankAccount: supplier.bankAccount,
      website: supplier.website,
      paymentTerms: supplier.paymentTerms,
      paymentDays: supplier.paymentDays,
      discountRate: supplier.discountRate,
      isCustomer: supplier.isCustomer,
      customerId: supplier.customerId,
    );
  }

  /// Firebase'den domain entity'ye dönüştürme
  Supplier toDomain() {
    return Supplier(
      id: id,
      name: name,
      supplierCode: supplierCode,
      category1: category,
      email: email,
      phone: phone,
      address: address,
      taxNumber: taxNumber,
      taxOffice: taxOffice,
      supplierType: SupplierType.values.firstWhere(
        (e) => e.name == supplierType,
        orElse: () => SupplierType.individual,
      ),
      status: SupplierStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => SupplierStatus.active,
      ),
      creditLimit: creditLimit,
      currentBalance: currentBalance,
      companyId: companyId,
      city: city,
      country: country,
      postalCode: postalCode,
      balance: balance,
      currency: currency,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
      contactPerson: contactPerson,
      bankName: bankName,
      bankAccount: bankAccount,
      website: website,
      paymentTerms: paymentTerms,
      paymentDays: paymentDays,
      discountRate: discountRate,
      isCustomer: isCustomer,
      customerId: customerId,
    );
  }

  /// Firebase Firestore'dan entity oluşturma
  factory FirebaseSupplierEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FirebaseSupplierEntity(
      id: doc.id,
      name: data['name'] ?? '',
      supplierCode: data['supplierCode'],
      category: data['category'],
      email: data['email'],
      phone: data['phone'],
      address: data['address'],
      taxNumber: data['taxNumber'],
      taxOffice: data['taxOffice'],
      supplierType: data['supplierType'] ?? 'individual',
      status: data['status'] ?? 'active',
      creditLimit: (data['creditLimit'] ?? 0.0).toDouble(),
      currentBalance: (data['currentBalance'] ?? 0.0).toDouble(),
      companyId: data['companyId'] ?? '',
      city: data['city'],
      country: data['country'],
      postalCode: data['postalCode'],
      balance: (data['balance'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      notes: data['notes'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'],
      updatedBy: data['updatedBy'],
      contactPerson: data['contactPerson'],
      bankName: data['bankName'],
      bankAccount: data['bankAccount'],
      website: data['website'],
      paymentTerms: data['paymentTerms'],
      paymentDays: data['paymentDays'] ?? 30,
      discountRate: (data['discountRate'] ?? 0.0).toDouble(),
      isCustomer: data['isCustomer'] ?? false,
      customerId: data['customerId'],
    );
  }

  /// Firebase Firestore'a kaydetme için Map dönüştürme
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'supplierCode': supplierCode,
      'category': category,
      'email': email,
      'phone': phone,
      'address': address,
      'taxNumber': taxNumber,
      'taxOffice': taxOffice,
      'supplierType': supplierType,
      'status': status,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'companyId': companyId,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'balance': balance,
      'currency': currency,
      'notes': notes,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'contactPerson': contactPerson,
      'bankName': bankName,
      'bankAccount': bankAccount,
      'website': website,
      'paymentTerms': paymentTerms,
      'paymentDays': paymentDays,
      'discountRate': discountRate,
      'isCustomer': isCustomer,
      'customerId': customerId,
    };
  }

  /// Entity kopyalama
  FirebaseSupplierEntity copyWith({
    String? id,
    String? name,
    String? supplierCode,
    String? category,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? taxOffice,
    String? supplierType,
    String? status,
    double? creditLimit,
    double? currentBalance,
    String? companyId,
    String? city,
    String? country,
    String? postalCode,
    double? balance,
    String? currency,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    String? contactPerson,
    String? bankName,
    String? bankAccount,
    String? website,
    String? paymentTerms,
    int? paymentDays,
    double? discountRate,
    bool? isCustomer,
    String? customerId,
  }) {
    return FirebaseSupplierEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      supplierCode: supplierCode ?? this.supplierCode,
      category: category ?? this.category,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      taxOffice: taxOffice ?? this.taxOffice,
      supplierType: supplierType ?? this.supplierType,
      status: status ?? this.status,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      companyId: companyId ?? this.companyId,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      contactPerson: contactPerson ?? this.contactPerson,
      bankName: bankName ?? this.bankName,
      bankAccount: bankAccount ?? this.bankAccount,
      website: website ?? this.website,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      paymentDays: paymentDays ?? this.paymentDays,
      discountRate: discountRate ?? this.discountRate,
      isCustomer: isCustomer ?? this.isCustomer,
      customerId: customerId ?? this.customerId,
    );
  }
}
