// ========== SUPPLIER ENTITY ==========
// lib/features/suppliers/domain/entities/supplier.dart

import 'package:equatable/equatable.dart';
import 'supplier_enums.dart';
import 'supplier_branch.dart';
import 'supplier_category.dart';
import 'supplier_transaction.dart';

/// Tedarikçi entity'si
class Supplier extends Equatable {
  final String id;
  final String tenantId; // Multi-tenant güvenlik için zorunlu
  final String name;
  final String? supplierCode;

  /// Sınıflandırma kategorisi 1
  final String? category1;

  /// Sınıflandırma kategorisi 2
  final String? category2;
  final String? email;
  final String? phone;
  final String? address;
  final String? taxNumber;
  final String? taxOffice;
  final SupplierType supplierType;
  final SupplierStatus status;
  final double creditLimit;
  final double currentBalance;
  final String companyId;
  final String? city;
  final String? country;
  final String? postalCode;
  final double balance;

  /// Tedarikçi para birimi
  final String currency;

  /// Vade (gün)
  final int? maturityDays;

  /// Açılış bakiyesi
  final double? openingBalance;

  /// Vergiden muaf mı?
  final bool isTaxExempt;
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
  final String? customerId; // Eğer müşteri ise, müşteri ID'si

  // Customer modülü ile uyumlu ek alanlar
  /// Sevk adresi
  final String? shippingAddress;

  /// Açık hesap risk limiti
  final double? openAccountRiskLimit;

  /// Sabit iskonto oranı (%)
  final double? fixedDiscountRate;

  /// Banka bilgileri
  final String? bankDetails;

  /// Özel fiyat listesi ID'si
  final String? specialPriceListId;

  /// Yetkili kişi adı (kurumsal tedarikçi için)
  final String? authorizedPersonName;

  /// Yetkili kişi telefonu (kurumsal tedarikçi için)
  final String? authorizedPersonPhone;

  /// Şube bilgileri (kurumsal tedarikçi için)
  final List<SupplierBranch>? branches;

  /// Kategori bilgileri
  final List<SupplierCategory>? categories;

  /// İşlem geçmişi
  final List<SupplierTransaction>? transactions;

  /// Bakiye para birimi
  final String balanceCurrency;

  const Supplier({
    required this.id,
    required this.tenantId,
    required this.name,
    this.supplierCode,
    this.category1,
    this.category2,
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
    this.maturityDays,
    this.openingBalance,
    this.isTaxExempt = false,
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
    // Customer modülü ile uyumlu ek alanlar
    this.shippingAddress,
    this.openAccountRiskLimit,
    this.fixedDiscountRate,
    this.bankDetails,
    this.specialPriceListId,
    this.authorizedPersonName,
    this.authorizedPersonPhone,
    this.branches,
    this.categories,
    this.transactions,
    this.balanceCurrency = 'TRY',
  });

  /// Tedarikçi kopyalama
  Supplier copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? supplierCode,
    String? category1,
    String? category2,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? taxOffice,
    SupplierType? supplierType,
    SupplierStatus? status,
    double? creditLimit,
    double? currentBalance,
    String? companyId,
    String? city,
    String? country,
    String? postalCode,
    double? balance,
    String? currency,
    int? maturityDays,
    double? openingBalance,
    bool? isTaxExempt,
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
    // Customer modülü ile uyumlu ek alanlar
    String? shippingAddress,
    double? openAccountRiskLimit,
    double? fixedDiscountRate,
    String? bankDetails,
    String? specialPriceListId,
    String? authorizedPersonName,
    String? authorizedPersonPhone,
    List<SupplierBranch>? branches,
    List<SupplierCategory>? categories,
    List<SupplierTransaction>? transactions,
    String? balanceCurrency,
  }) {
    return Supplier(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      supplierCode: supplierCode ?? this.supplierCode,
      category1: category1 ?? this.category1,
      category2: category2 ?? this.category2,
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
      maturityDays: maturityDays ?? this.maturityDays,
      openingBalance: openingBalance ?? this.openingBalance,
      isTaxExempt: isTaxExempt ?? this.isTaxExempt,
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
      // Customer modülü ile uyumlu ek alanlar
      shippingAddress: shippingAddress ?? this.shippingAddress,
      openAccountRiskLimit: openAccountRiskLimit ?? this.openAccountRiskLimit,
      fixedDiscountRate: fixedDiscountRate ?? this.fixedDiscountRate,
      bankDetails: bankDetails ?? this.bankDetails,
      specialPriceListId: specialPriceListId ?? this.specialPriceListId,
      authorizedPersonName: authorizedPersonName ?? this.authorizedPersonName,
      authorizedPersonPhone:
          authorizedPersonPhone ?? this.authorizedPersonPhone,
      branches: branches ?? this.branches,
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
      balanceCurrency: balanceCurrency ?? this.balanceCurrency,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        supplierCode,
        category1,
        category2,
        email,
        phone,
        address,
        taxNumber,
        taxOffice,
        supplierType,
        status,
        creditLimit,
        currentBalance,
        companyId,
        city,
        country,
        postalCode,
        balance,
        currency,
        maturityDays,
        openingBalance,
        isTaxExempt,
        notes,
        isActive,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        contactPerson,
        bankName,
        bankAccount,
        website,
        paymentTerms,
        paymentDays,
        discountRate,
        isCustomer,
        customerId,
        // Customer modülü ile uyumlu ek alanlar
        shippingAddress,
        openAccountRiskLimit,
        fixedDiscountRate,
        bankDetails,
        specialPriceListId,
        authorizedPersonName,
        authorizedPersonPhone,
        branches,
        categories,
        transactions,
        balanceCurrency,
      ];

  /// Tedarikçi tipi görünen adı
  String get supplierTypeDisplayName {
    switch (supplierType) {
      case SupplierType.individual:
        return 'Bireysel';
      case SupplierType.company:
        return 'Kurumsal';
    }
  }

  /// Tedarikçi durumu görünen adı
  String get statusDisplayName {
    switch (status) {
      case SupplierStatus.active:
        return 'Aktif';
      case SupplierStatus.inactive:
        return 'Pasif';
      case SupplierStatus.suspended:
        return 'Askıya Alınmış';
      case SupplierStatus.blocked:
        return 'Engellenmiş';
    }
  }

  /// Bakiye durumu
  String get balanceStatus {
    if (currentBalance > 0) {
      return 'Alacaklı';
    } else if (currentBalance < 0) {
      return 'Borçlu';
    } else {
      return 'Sıfır';
    }
  }

  /// Kredi limiti aşıldı mı?
  bool get isCreditLimitExceeded {
    return currentBalance.abs() > creditLimit;
  }

  /// Tam adres
  String get fullAddress {
    final parts = <String>[];
    if (address != null) parts.add(address!);
    if (city != null) parts.add(city!);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  }

  /// Görünen ad
  String get displayName {
    if (contactPerson != null && contactPerson!.isNotEmpty) {
      return '$name (${contactPerson!})';
    }
    return name;
  }
}
