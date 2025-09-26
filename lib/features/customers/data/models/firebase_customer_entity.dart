// ========== FIREBASE CUSTOMER ENTITY ==========
// lib/features/customers/data/models/firebase_customer_entity.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_enums.dart';
import '../../domain/entities/customer_branch.dart';

/// Firebase için optimize edilmiş müşteri entity'si
class FirebaseCustomerEntity {
  final String id;
  final String name;
  final String? customerCode;
  final String? category;
  final String? category2;
  final String? email;
  final String? phone;
  final String? address;
  final String? taxNumber;
  final String? taxOffice;
  final String? shippingAddress;
  final String customerType; // 'individual' veya 'company'
  final String status; // 'active' veya 'inactive'
  final double creditLimit;
  final double currentBalance;
  final double? openingBalance;
  final String companyId;
  final String? city;
  final String? country;
  final String? postalCode;
  final double balance;
  final String balanceCurrency;
  final String? customerCurrency;
  final int? maturityDays;
  final double? fixedDiscountRate;
  final bool isTaxExempt;
  final String? bankDetails;
  final String? specialPriceListId;
  final double? openAccountRiskLimit;
  final String? authorizedPersonName;
  final String? authorizedPersonPhone;
  final List<CustomerBranch>? branches;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  // Ön muhasebe için ek alanlar
  final bool isSupplier; // Hem müşteri hem tedarikçi olabilir
  final String? supplierCode;
  final double supplierCreditLimit;
  final double supplierCurrentBalance;
  final String? bankName;
  final String? bankAccount;
  final String? contactPerson;

  const FirebaseCustomerEntity({
    required this.id,
    required this.name,
    this.customerCode,
    this.category,
    this.category2,
    this.email,
    this.phone,
    this.address,
    this.taxNumber,
    this.taxOffice,
    this.shippingAddress,
    required this.customerType,
    required this.status,
    this.creditLimit = 0.0,
    this.currentBalance = 0.0,
    this.openingBalance,
    required this.companyId,
    this.city,
    this.country,
    this.postalCode,
    this.balance = 0.0,
    this.balanceCurrency = 'TRY',
    this.customerCurrency,
    this.maturityDays,
    this.fixedDiscountRate,
    this.isTaxExempt = false,
    this.bankDetails,
    this.specialPriceListId,
    this.openAccountRiskLimit,
    this.authorizedPersonName,
    this.authorizedPersonPhone,
    this.branches,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.isSupplier = false,
    this.supplierCode,
    this.supplierCreditLimit = 0.0,
    this.supplierCurrentBalance = 0.0,
    this.bankName,
    this.bankAccount,
    this.contactPerson,
  });

  /// Domain entity'den Firebase entity'ye dönüştürme
  factory FirebaseCustomerEntity.fromDomain(Customer customer) {
    return FirebaseCustomerEntity(
      id: customer.id,
      name: customer.name,
      customerCode: customer.customerCode,
      category: customer.category1,
      category2: customer.category2,
      email: customer.email,
      phone: customer.phone,
      address: customer.address,
      taxNumber: customer.taxNumber,
      taxOffice: customer.taxOffice,
      shippingAddress: customer.shippingAddress,
      customerType: customer.customerType.name,
      status: customer.status.name,
      creditLimit: customer.creditLimit,
      currentBalance: customer.currentBalance,
      openingBalance: customer.openingBalance,
      companyId: customer.companyId,
      city: customer.city,
      country: customer.country,
      postalCode: customer.postalCode,
      balance: customer.balance,
      balanceCurrency: customer.balanceCurrency,
      customerCurrency: customer.customerCurrency,
      maturityDays: customer.maturityDays,
      fixedDiscountRate: customer.fixedDiscountRate,
      isTaxExempt: customer.isTaxExempt,
      bankDetails: customer.bankDetails,
      specialPriceListId: customer.specialPriceListId,
      openAccountRiskLimit: customer.openAccountRiskLimit,
      authorizedPersonName: customer.authorizedPersonName,
      authorizedPersonPhone: customer.authorizedPersonPhone,
      branches: customer.branches,
      notes: customer.notes,
      isActive: customer.isActive,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
      createdBy: customer.createdBy,
      updatedBy: customer.updatedBy,
    );
  }

  /// Firebase'den domain entity'ye dönüştürme
  Customer toDomain() {
    return Customer(
      id: id,
      name: name,
      customerCode: customerCode,
      category1: category,
      category2: category2,
      email: email,
      phone: phone,
      address: address,
      taxNumber: taxNumber,
      taxOffice: taxOffice,
      shippingAddress: shippingAddress,
      customerType: CustomerType.values.firstWhere(
        (e) => e.name == customerType,
        orElse: () => CustomerType.individual,
      ),
      status: CustomerStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => CustomerStatus.active,
      ),
      creditLimit: creditLimit,
      currentBalance: currentBalance,
      openingBalance: openingBalance,
      companyId: companyId,
      city: city,
      country: country,
      postalCode: postalCode,
      balance: balance,
      balanceCurrency: balanceCurrency,
      customerCurrency: customerCurrency,
      maturityDays: maturityDays,
      fixedDiscountRate: fixedDiscountRate,
      isTaxExempt: isTaxExempt,
      bankDetails: bankDetails,
      specialPriceListId: specialPriceListId,
      openAccountRiskLimit: openAccountRiskLimit,
      authorizedPersonName: authorizedPersonName,
      authorizedPersonPhone: authorizedPersonPhone,
      branches: branches,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy ?? '',
      updatedBy: updatedBy,
    );
  }

  /// Firebase Firestore'dan entity oluşturma
  factory FirebaseCustomerEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FirebaseCustomerEntity(
      id: doc.id,
      name: data['name'] ?? '',
      customerCode: data['customerCode'],
      category: data['category'],
      category2: data['category2'],
      email: data['email'],
      phone: data['phone'],
      address: data['address'],
      taxNumber: data['taxNumber'],
      taxOffice: data['taxOffice'],
      shippingAddress: data['shippingAddress'],
      customerType: data['customerType'] ?? 'individual',
      status: data['status'] ?? 'active',
      creditLimit: (data['creditLimit'] ?? 0.0).toDouble(),
      currentBalance: (data['currentBalance'] ?? 0.0).toDouble(),
      openingBalance: (data['openingBalance'] as num?)?.toDouble(),
      companyId: data['companyId'] ?? '',
      city: data['city'],
      country: data['country'],
      postalCode: data['postalCode'],
      balance: (data['balance'] ?? 0.0).toDouble(),
      balanceCurrency: data['balanceCurrency'] ?? 'TRY',
      customerCurrency: data['customerCurrency'],
      maturityDays: (data['maturityDays'] as num?)?.toInt(),
      fixedDiscountRate: (data['fixedDiscountRate'] as num?)?.toDouble(),
      isTaxExempt: data['isTaxExempt'] ?? false,
      bankDetails: data['bankDetails'],
      specialPriceListId: data['specialPriceListId'],
      openAccountRiskLimit: (data['openAccountRiskLimit'] as num?)?.toDouble(),
      authorizedPersonName: data['authorizedPersonName'],
      authorizedPersonPhone: data['authorizedPersonPhone'],
      branches: (data['branches'] as List<dynamic>?)
          ?.map((e) => CustomerBranch.fromJson(
              (e as Map<String, dynamic>).map((k, v) => MapEntry(k, v))))
          .toList(),
      notes: data['notes'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'],
      updatedBy: data['updatedBy'],
      isSupplier: data['isSupplier'] ?? false,
      supplierCode: data['supplierCode'],
      supplierCreditLimit: (data['supplierCreditLimit'] ?? 0.0).toDouble(),
      supplierCurrentBalance:
          (data['supplierCurrentBalance'] ?? 0.0).toDouble(),
      bankName: data['bankName'],
      bankAccount: data['bankAccount'],
      contactPerson: data['contactPerson'],
    );
  }

  /// Firebase Firestore'a kaydetme için Map dönüştürme
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'customerCode': customerCode,
      'category': category,
      'category2': category2,
      'email': email,
      'phone': phone,
      'address': address,
      'taxNumber': taxNumber,
      'taxOffice': taxOffice,
      'shippingAddress': shippingAddress,
      'customerType': customerType,
      'status': status,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'openingBalance': openingBalance,
      'companyId': companyId,
      'tenantId': companyId, // Multi-tenant için tenantId ekle
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'balance': balance,
      'balanceCurrency': balanceCurrency,
      'customerCurrency': customerCurrency,
      'maturityDays': maturityDays,
      'fixedDiscountRate': fixedDiscountRate,
      'isTaxExempt': isTaxExempt,
      'bankDetails': bankDetails,
      'specialPriceListId': specialPriceListId,
      'openAccountRiskLimit': openAccountRiskLimit,
      'authorizedPersonName': authorizedPersonName,
      'authorizedPersonPhone': authorizedPersonPhone,
      'branches': branches?.map((b) => b.toJson()).toList(),
      'notes': notes,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'isSupplier': isSupplier,
      'supplierCode': supplierCode,
      'supplierCreditLimit': supplierCreditLimit,
      'supplierCurrentBalance': supplierCurrentBalance,
      'bankName': bankName,
      'bankAccount': bankAccount,
      'contactPerson': contactPerson,
    };
  }

  /// Entity kopyalama
  FirebaseCustomerEntity copyWith({
    String? id,
    String? name,
    String? customerCode,
    String? category,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? taxOffice,
    String? customerType,
    String? status,
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
    bool? isSupplier,
    String? supplierCode,
    double? supplierCreditLimit,
    double? supplierCurrentBalance,
    String? bankName,
    String? bankAccount,
    String? contactPerson,
  }) {
    return FirebaseCustomerEntity(
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
      isSupplier: isSupplier ?? this.isSupplier,
      supplierCode: supplierCode ?? this.supplierCode,
      supplierCreditLimit: supplierCreditLimit ?? this.supplierCreditLimit,
      supplierCurrentBalance:
          supplierCurrentBalance ?? this.supplierCurrentBalance,
      bankName: bankName ?? this.bankName,
      bankAccount: bankAccount ?? this.bankAccount,
      contactPerson: contactPerson ?? this.contactPerson,
    );
  }
}
