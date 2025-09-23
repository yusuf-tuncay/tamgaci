// ========== FIREBASE COLLECTIONS STRUCTURE ==========
// lib/core/firebase/collections.dart

/// Firebase koleksiyon isimleri ve yapıları
class FirebaseCollections {
  // Ana koleksiyonlar
  static const String users = 'users';
  static const String companies = 'companies';
  static const String customers = 'customers';
  static const String customerCategories = 'customer_categories';
  static const String suppliers = 'suppliers';
  static const String products = 'products';
  static const String warehouses = 'warehouses';
  static const String sales = 'sales';
  static const String purchases = 'purchases';
  static const String accounts = 'accounts';
  static const String cashTransactions = 'cash_transactions';
  static const String reports = 'reports';
  static const String transactions = 'transactions';
  static const String stockMovements = 'stock_movements';
  static const String currencies = 'currencies';
  static const String settings = 'settings';
  static const String notifications = 'notifications';
  static const String auditLogs = 'audit_logs';

  // Alt koleksiyonlar
  static const String customerTransactions = 'customer_transactions';
  static const String supplierTransactions = 'supplier_transactions';
  static const String productTransactions = 'product_transactions';
  static const String saleItems = 'sale_items';
  static const String purchaseItems = 'purchase_items';
  static const String accountTransactions = 'account_transactions';
  static const String reportParameters = 'report_parameters';
  static const String userPermissions = 'user_permissions';
  static const String companySettings = 'company_settings';
}

/// Firebase field isimleri
class FirebaseFields {
  // Ortak alanlar
  static const String id = 'id';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String createdBy = 'createdBy';
  static const String updatedBy = 'updatedBy';
  static const String isActive = 'isActive';
  static const String isDeleted = 'isDeleted';
  static const String companyId = 'companyId';
  static const String userId = 'userId';

  // Müşteri alanları
  static const String customerName = 'name';
  static const String customerEmail = 'email';
  static const String customerPhone = 'phone';
  static const String customerAddress = 'address';
  static const String customerTaxNumber = 'taxNumber';
  static const String customerType = 'type';
  static const String customerStatus = 'status';
  static const String customerCreditLimit = 'creditLimit';
  static const String customerCurrentBalance = 'currentBalance';

  // Tedarikçi alanları
  static const String supplierName = 'name';
  static const String supplierEmail = 'email';
  static const String supplierPhone = 'phone';
  static const String supplierAddress = 'address';
  static const String supplierTaxNumber = 'taxNumber';
  static const String supplierType = 'type';
  static const String supplierStatus = 'status';
  static const String supplierPaymentTerms = 'paymentTerms';

  // Ürün alanları
  static const String productName = 'name';
  static const String productCode = 'code';
  static const String productBarcode = 'barcode';
  static const String productDescription = 'description';
  static const String productType = 'type';
  static const String productCategory = 'category';
  static const String productUnit = 'unit';
  static const String productPrice = 'price';
  static const String productCost = 'cost';
  static const String productStock = 'stock';
  static const String productMinStock = 'minStock';
  static const String productMaxStock = 'maxStock';
  static const String productWarehouseId = 'warehouseId';
  static const String productImageUrl = 'imageUrl';

  // Depo alanları
  static const String warehouseName = 'name';
  static const String warehouseCode = 'code';
  static const String warehouseAddress = 'address';
  static const String warehouseType = 'type';
  static const String warehouseStatus = 'status';
  static const String warehouseCapacity = 'capacity';
  static const String warehouseManager = 'manager';

  // Satış alanları
  static const String saleNumber = 'saleNumber';
  static const String saleDate = 'saleDate';
  static const String saleDueDate = 'dueDate';
  static const String saleCustomerId = 'customerId';
  static const String saleType = 'type';
  static const String saleStatus = 'status';
  static const String salePaymentStatus = 'paymentStatus';
  static const String saleSubtotal = 'subtotal';
  static const String saleTaxAmount = 'taxAmount';
  static const String saleDiscountAmount = 'discountAmount';
  static const String saleTotalAmount = 'totalAmount';
  static const String saleCurrency = 'currency';
  static const String saleNotes = 'notes';

  // Alış alanları
  static const String purchaseNumber = 'purchaseNumber';
  static const String purchaseDate = 'purchaseDate';
  static const String purchaseDueDate = 'dueDate';
  static const String purchaseSupplierId = 'supplierId';
  static const String purchaseType = 'type';
  static const String purchaseStatus = 'status';
  static const String purchasePaymentStatus = 'paymentStatus';
  static const String purchaseSubtotal = 'subtotal';
  static const String purchaseTaxAmount = 'taxAmount';
  static const String purchaseDiscountAmount = 'discountAmount';
  static const String purchaseTotalAmount = 'totalAmount';
  static const String purchaseCurrency = 'currency';
  static const String purchaseNotes = 'notes';

  // Hesap alanları
  static const String accountName = 'name';
  static const String accountDescription = 'description';
  static const String accountType = 'type';
  static const String accountStatus = 'status';
  static const String accountCurrentBalance = 'currentBalance';
  static const String accountCurrency = 'currency';
  static const String accountBankName = 'bankName';
  static const String accountNumber = 'accountNumber';
  static const String accountIban = 'iban';
  static const String accountSwiftCode = 'swiftCode';
  static const String accountCreditLimit = 'creditLimit';
  static const String accountInterestRate = 'interestRate';

  // Nakit işlem alanları
  static const String transactionAccountId = 'accountId';
  static const String transactionToAccountId = 'toAccountId';
  static const String transactionType = 'type';
  static const String transactionStatus = 'status';
  static const String transactionAmount = 'amount';
  static const String transactionCurrency = 'currency';
  static const String transactionDate = 'transactionDate';
  static const String transactionDueDate = 'dueDate';
  static const String transactionDescription = 'description';
  static const String transactionCategory = 'category';
  static const String transactionSubCategory = 'subCategory';
  static const String transactionReference = 'reference';
  static const String transactionNotes = 'notes';

  // Rapor alanları
  static const String reportName = 'name';
  static const String reportDescription = 'description';
  static const String reportType = 'type';
  static const String reportFormat = 'format';
  static const String reportStatus = 'status';
  static const String reportFilePath = 'filePath';
  static const String reportDownloadUrl = 'downloadUrl';
  static const String reportGeneratedAt = 'generatedAt';
  static const String reportRecordCount = 'recordCount';
  static const String reportFileSize = 'fileSize';

  // Stok hareket alanları
  static const String movementProductId = 'productId';
  static const String movementWarehouseId = 'warehouseId';
  static const String movementType = 'type';
  static const String movementQuantity = 'quantity';
  static const String movementUnitPrice = 'unitPrice';
  static const String movementTotalPrice = 'totalPrice';
  static const String movementDate = 'movementDate';
  static const String movementReference = 'reference';
  static const String movementNotes = 'notes';

  // Para birimi alanları
  static const String currencyCode = 'code';
  static const String currencyName = 'name';
  static const String currencySymbol = 'symbol';
  static const String currencyRate = 'rate';
  static const String currencyLastUpdated = 'lastUpdated';

  // Kullanıcı alanları
  static const String userEmail = 'email';
  static const String userName = 'name';
  static const String userDisplayName = 'displayName';
  static const String userPhotoUrl = 'photoUrl';
  static const String userRole = 'role';
  static const String userPermissions = 'permissions';
  static const String userLastLogin = 'lastLogin';
  static const String userIsActive = 'isActive';

  // Şirket alanları
  static const String companyName = 'name';
  static const String companyTaxNumber = 'taxNumber';
  static const String companyAddress = 'address';
  static const String companyPhone = 'phone';
  static const String companyEmail = 'email';
  static const String companyWebsite = 'website';
  static const String companyLogoUrl = 'logoUrl';
  static const String companySettings = 'settings';
}

/// Firebase index yapıları
class FirebaseIndexes {
  // Müşteri indexleri
  static const List<String> customerIndexes = [
    'companyId',
    'name',
    'email',
    'type',
    'status',
    'createdAt',
  ];

  // Tedarikçi indexleri
  static const List<String> supplierIndexes = [
    'companyId',
    'name',
    'email',
    'type',
    'status',
    'createdAt',
  ];

  // Ürün indexleri
  static const List<String> productIndexes = [
    'companyId',
    'name',
    'code',
    'barcode',
    'type',
    'category',
    'warehouseId',
    'createdAt',
  ];

  // Satış indexleri
  static const List<String> saleIndexes = [
    'companyId',
    'saleNumber',
    'saleDate',
    'customerId',
    'type',
    'status',
    'paymentStatus',
    'createdAt',
  ];

  // Alış indexleri
  static const List<String> purchaseIndexes = [
    'companyId',
    'purchaseNumber',
    'purchaseDate',
    'supplierId',
    'type',
    'status',
    'paymentStatus',
    'createdAt',
  ];

  // Hesap indexleri
  static const List<String> accountIndexes = [
    'companyId',
    'name',
    'type',
    'status',
    'createdAt',
  ];

  // Nakit işlem indexleri
  static const List<String> cashTransactionIndexes = [
    'companyId',
    'accountId',
    'type',
    'status',
    'transactionDate',
    'createdAt',
  ];

  // Stok hareket indexleri
  static const List<String> stockMovementIndexes = [
    'companyId',
    'productId',
    'warehouseId',
    'type',
    'movementDate',
    'createdAt',
  ];

  // Rapor indexleri
  static const List<String> reportIndexes = [
    'companyId',
    'name',
    'type',
    'format',
    'status',
    'createdAt',
  ];
}

/// Firebase güvenlik kuralları için yardımcı sınıf
class FirebaseSecurityRules {
  // Kullanıcı güvenlik kuralları
  static const String userRules = '''
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        // Kullanıcılar sadece kendi verilerini okuyabilir
        match /users/{userId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
        
        // Şirket verileri sadece şirket üyeleri tarafından erişilebilir
        match /companies/{companyId} {
          allow read, write: if request.auth != null && 
            resource.data.members[request.auth.uid] != null;
        }
        
        // Müşteri verileri
        match /customers/{customerId} {
        allow read, write: if request.auth != null;
        }
        
        // Tedarikçi verileri
        match /suppliers/{supplierId} {
          allow read, write: if request.auth != null;
        }
        
        // Ürün verileri
        match /products/{productId} {
          allow read, write: if request.auth != null;
        }
        
        // Satış verileri
        match /sales/{saleId} {
          allow read, write: if request.auth != null;
        }
        
        // Alış verileri
        match /purchases/{purchaseId} {
          allow read, write: if request.auth != null;
        }
        
        // Hesap verileri
        match /accounts/{accountId} {
          allow read, write: if request.auth != null;
        }
        
        // Nakit işlem verileri
        match /cash_transactions/{transactionId} {
          allow read, write: if request.auth != null;
        }
        
        // Rapor verileri
        match /reports/{reportId} {
          allow read, write: if request.auth != null;
        }
        
        // Stok hareket verileri
        match /stock_movements/{movementId} {
          allow read, write: if request.auth != null;
        }
      }
    }
  ''';
}
