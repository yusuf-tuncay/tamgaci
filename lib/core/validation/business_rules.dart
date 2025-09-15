import 'package:tamgaci/core/errors/error_logger.dart';

/// Business rules validation class
class BusinessRules {
  /// Validate customer business rules
  static BusinessRuleResult validateCustomerRules(
      Map<String, dynamic> customerData) {
    final errors = <String>[];

    // Rule 1: Customer name must be unique
    if (customerData['name'] != null) {
      // This would typically check against database
      // For now, we'll just log the validation
      ErrorLogger.logInfo(
        'Customer name uniqueness check',
        context: 'BusinessRules',
        additionalData: {'name': customerData['name']},
      );
    }

    // Rule 2: Tax number must be unique if provided
    if (customerData['taxNumber'] != null &&
        customerData['taxNumber'].toString().isNotEmpty) {
      // This would typically check against database
      ErrorLogger.logInfo(
        'Customer tax number uniqueness check',
        context: 'BusinessRules',
        additionalData: {'taxNumber': customerData['taxNumber']},
      );
    }

    // Rule 3: Credit limit cannot be negative
    if (customerData['creditLimit'] != null) {
      final creditLimit =
          double.tryParse(customerData['creditLimit'].toString());
      if (creditLimit != null && creditLimit < 0) {
        errors.add('Kredi limiti negatif olamaz');
      }
    }

    // Rule 4: Email must be unique if provided
    if (customerData['email'] != null &&
        customerData['email'].toString().isNotEmpty) {
      // This would typically check against database
      ErrorLogger.logInfo(
        'Customer email uniqueness check',
        context: 'BusinessRules',
        additionalData: {'email': customerData['email']},
      );
    }

    return BusinessRuleResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate product business rules
  static BusinessRuleResult validateProductRules(
      Map<String, dynamic> productData) {
    final errors = <String>[];

    // Rule 1: Product name must be unique
    if (productData['name'] != null) {
      ErrorLogger.logInfo(
        'Product name uniqueness check',
        context: 'BusinessRules',
        additionalData: {'name': productData['name']},
      );
    }

    // Rule 2: SKU must be unique if provided
    if (productData['sku'] != null &&
        productData['sku'].toString().isNotEmpty) {
      ErrorLogger.logInfo(
        'Product SKU uniqueness check',
        context: 'BusinessRules',
        additionalData: {'sku': productData['sku']},
      );
    }

    // Rule 3: Barcode must be unique if provided
    if (productData['barcode'] != null &&
        productData['barcode'].toString().isNotEmpty) {
      ErrorLogger.logInfo(
        'Product barcode uniqueness check',
        context: 'BusinessRules',
        additionalData: {'barcode': productData['barcode']},
      );
    }

    // Rule 4: Price cannot be negative
    if (productData['unitPrice'] != null) {
      final price = double.tryParse(productData['unitPrice'].toString());
      if (price != null && price < 0) {
        errors.add('Ürün fiyatı negatif olamaz');
      }
    }

    // Rule 5: Stock quantity cannot be negative
    if (productData['stockQuantity'] != null) {
      final stock = int.tryParse(productData['stockQuantity'].toString());
      if (stock != null && stock < 0) {
        errors.add('Stok miktarı negatif olamaz');
      }
    }

    // Rule 6: Minimum stock level cannot be negative
    if (productData['minStockLevel'] != null) {
      final minStock = int.tryParse(productData['minStockLevel'].toString());
      if (minStock != null && minStock < 0) {
        errors.add('Minimum stok seviyesi negatif olamaz');
      }
    }

    // Rule 7: Tax rate must be between 0 and 100
    if (productData['taxRate'] != null) {
      final taxRate = double.tryParse(productData['taxRate'].toString());
      if (taxRate != null && (taxRate < 0 || taxRate > 100)) {
        errors.add('Vergi oranı 0-100 arasında olmalıdır');
      }
    }

    return BusinessRuleResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate invoice business rules
  static BusinessRuleResult validateInvoiceRules(
      Map<String, dynamic> invoiceData) {
    final errors = <String>[];

    // Rule 1: Invoice number must be unique
    if (invoiceData['invoiceNumber'] != null) {
      ErrorLogger.logInfo(
        'Invoice number uniqueness check',
        context: 'BusinessRules',
        additionalData: {'invoiceNumber': invoiceData['invoiceNumber']},
      );
    }

    // Rule 2: Customer must exist
    if (invoiceData['customerId'] == null ||
        invoiceData['customerId'].toString().isEmpty) {
      errors.add('Müşteri seçimi gereklidir');
    }

    // Rule 3: Invoice date cannot be in the future
    if (invoiceData['invoiceDate'] != null) {
      final invoiceDate =
          DateTime.tryParse(invoiceData['invoiceDate'].toString());
      if (invoiceDate != null && invoiceDate.isAfter(DateTime.now())) {
        errors.add('Fatura tarihi gelecekte olamaz');
      }
    }

    // Rule 4: Due date must be after invoice date
    if (invoiceData['invoiceDate'] != null && invoiceData['dueDate'] != null) {
      final invoiceDate =
          DateTime.tryParse(invoiceData['invoiceDate'].toString());
      final dueDate = DateTime.tryParse(invoiceData['dueDate'].toString());

      if (invoiceDate != null &&
          dueDate != null &&
          dueDate.isBefore(invoiceDate)) {
        errors.add('Vade tarihi fatura tarihinden önce olamaz');
      }
    }

    // Rule 5: Total amount cannot be negative
    if (invoiceData['totalAmount'] != null) {
      final totalAmount =
          double.tryParse(invoiceData['totalAmount'].toString());
      if (totalAmount != null && totalAmount < 0) {
        errors.add('Toplam tutar negatif olamaz');
      }
    }

    // Rule 6: Invoice must have at least one item
    if (invoiceData['items'] == null ||
        (invoiceData['items'] is List &&
            (invoiceData['items'] as List).isEmpty)) {
      errors.add('Fatura en az bir kalem içermelidir');
    }

    return BusinessRuleResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate expense business rules
  static BusinessRuleResult validateExpenseRules(
      Map<String, dynamic> expenseData) {
    final errors = <String>[];

    // Rule 1: Expense amount cannot be negative
    if (expenseData['amount'] != null) {
      final amount = double.tryParse(expenseData['amount'].toString());
      if (amount != null && amount < 0) {
        errors.add('Gider tutarı negatif olamaz');
      }
    }

    // Rule 2: Expense date cannot be in the future
    if (expenseData['expenseDate'] != null) {
      final expenseDate =
          DateTime.tryParse(expenseData['expenseDate'].toString());
      if (expenseDate != null && expenseDate.isAfter(DateTime.now())) {
        errors.add('Gider tarihi gelecekte olamaz');
      }
    }

    // Rule 3: Category must be selected
    if (expenseData['categoryId'] == null ||
        expenseData['categoryId'].toString().isEmpty) {
      errors.add('Gider kategorisi seçimi gereklidir');
    }

    return BusinessRuleResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate income business rules
  static BusinessRuleResult validateIncomeRules(
      Map<String, dynamic> incomeData) {
    final errors = <String>[];

    // Rule 1: Income amount cannot be negative
    if (incomeData['amount'] != null) {
      final amount = double.tryParse(incomeData['amount'].toString());
      if (amount != null && amount < 0) {
        errors.add('Gelir tutarı negatif olamaz');
      }
    }

    // Rule 2: Income date cannot be in the future
    if (incomeData['incomeDate'] != null) {
      final incomeDate = DateTime.tryParse(incomeData['incomeDate'].toString());
      if (incomeDate != null && incomeDate.isAfter(DateTime.now())) {
        errors.add('Gelir tarihi gelecekte olamaz');
      }
    }

    // Rule 3: Category must be selected
    if (incomeData['categoryId'] == null ||
        incomeData['categoryId'].toString().isEmpty) {
      errors.add('Gelir kategorisi seçimi gereklidir');
    }

    return BusinessRuleResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate stock movement business rules
  static BusinessRuleResult validateStockMovementRules(
      Map<String, dynamic> movementData) {
    final errors = <String>[];

    // Rule 1: Movement quantity cannot be zero
    if (movementData['quantity'] != null) {
      final quantity = int.tryParse(movementData['quantity'].toString());
      if (quantity != null && quantity == 0) {
        errors.add('Hareket miktarı sıfır olamaz');
      }
    }

    // Rule 2: Product must exist
    if (movementData['productId'] == null ||
        movementData['productId'].toString().isEmpty) {
      errors.add('Ürün seçimi gereklidir');
    }

    // Rule 3: Movement date cannot be in the future
    if (movementData['movementDate'] != null) {
      final movementDate =
          DateTime.tryParse(movementData['movementDate'].toString());
      if (movementDate != null && movementDate.isAfter(DateTime.now())) {
        errors.add('Hareket tarihi gelecekte olamaz');
      }
    }

    // Rule 4: Outbound movement cannot exceed available stock
    if (movementData['type'] == 'outbound' &&
        movementData['quantity'] != null) {
      final quantity = int.tryParse(movementData['quantity'].toString());
      if (quantity != null && quantity > 0) {
        // This would typically check against current stock
        ErrorLogger.logInfo(
          'Stock availability check for outbound movement',
          context: 'BusinessRules',
          additionalData: {
            'productId': movementData['productId'],
            'quantity': quantity,
          },
        );
      }
    }

    return BusinessRuleResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate payment business rules
  static BusinessRuleResult validatePaymentRules(
      Map<String, dynamic> paymentData) {
    final errors = <String>[];

    // Rule 1: Payment amount cannot be negative
    if (paymentData['amount'] != null) {
      final amount = double.tryParse(paymentData['amount'].toString());
      if (amount != null && amount < 0) {
        errors.add('Ödeme tutarı negatif olamaz');
      }
    }

    // Rule 2: Payment date cannot be in the future
    if (paymentData['paymentDate'] != null) {
      final paymentDate =
          DateTime.tryParse(paymentData['paymentDate'].toString());
      if (paymentDate != null && paymentDate.isAfter(DateTime.now())) {
        errors.add('Ödeme tarihi gelecekte olamaz');
      }
    }

    // Rule 3: Payment method must be selected
    if (paymentData['paymentMethod'] == null ||
        paymentData['paymentMethod'].toString().isEmpty) {
      errors.add('Ödeme yöntemi seçimi gereklidir');
    }

    return BusinessRuleResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate general business rules
  static BusinessRuleResult validateGeneralRules(
      Map<String, dynamic> data, String entityType) {
    final errors = <String>[];

    // Rule 1: Created date cannot be in the future
    if (data['createdAt'] != null) {
      final createdAt = DateTime.tryParse(data['createdAt'].toString());
      if (createdAt != null && createdAt.isAfter(DateTime.now())) {
        errors.add('Oluşturma tarihi gelecekte olamaz');
      }
    }

    // Rule 2: Updated date cannot be before created date
    if (data['createdAt'] != null && data['updatedAt'] != null) {
      final createdAt = DateTime.tryParse(data['createdAt'].toString());
      final updatedAt = DateTime.tryParse(data['updatedAt'].toString());

      if (createdAt != null &&
          updatedAt != null &&
          updatedAt.isBefore(createdAt)) {
        errors.add('Güncelleme tarihi oluşturma tarihinden önce olamaz');
      }
    }

    // Rule 3: Company ID must be provided
    if (data['companyId'] == null || data['companyId'].toString().isEmpty) {
      errors.add('Şirket ID gereklidir');
    }

    // Rule 4: Created by must be provided
    if (data['createdBy'] == null || data['createdBy'].toString().isEmpty) {
      errors.add('Oluşturan kullanıcı bilgisi gereklidir');
    }

    return BusinessRuleResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// Business rule result class
class BusinessRuleResult {
  final bool isValid;
  final List<String> errors;

  const BusinessRuleResult({
    required this.isValid,
    required this.errors,
  });

  @override
  String toString() {
    return isValid ? 'Valid' : 'Invalid: ${errors.join(', ')}';
  }
}
