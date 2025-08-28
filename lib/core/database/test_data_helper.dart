// ========== lib/core/database/test_data_helper.dart ==========

import 'package:tamgaci/core/database/tamgaci_database.dart';
import 'package:tamgaci/features/products/data/models/product_entity.dart';
import 'package:tamgaci/features/expenses/data/models/expense_entity.dart';
import 'package:tamgaci/features/expenses/data/models/expense_category_entity.dart';
import 'package:tamgaci/features/income/data/models/income_entity.dart';
import 'package:tamgaci/features/income/data/models/income_category_entity.dart';

/// Test verilerini yükleyen yardımcı sınıf
class TestDataHelper {
  static final TestDataHelper _instance = TestDataHelper._internal();
  factory TestDataHelper() => _instance;
  TestDataHelper._internal();

  /// Test verilerini yükle
  Future<void> loadTestData() async {
    final database = await DatabaseHelper.getDatabase();

    // Ürün test verileri
    await _loadProductTestData(database);

    // Gider kategorileri test verileri
    await _loadExpenseCategoryTestData(database);

    // Gider test verileri
    await _loadExpenseTestData(database);

    // Gelir kategorileri test verileri
    await _loadIncomeCategoryTestData(database);

    // Gelir test verileri
    await _loadIncomeTestData(database);
  }

  /// Ürün test verilerini yükle
  Future<void> _loadProductTestData(TamgaciDatabase database) async {
    final productDao = database.productDao;

    // Mevcut ürün sayısını kontrol et
    final existingProducts = await productDao.getAllProducts().first;
    if (existingProducts.isNotEmpty) return;

    final testProducts = [
      ProductEntity(
        name: 'Laptop Bilgisayar',
        description: 'Yüksek performanslı iş bilgisayarı',
        sku: 'LAP-001',
        barcode: '1234567890123',
        category: 'Elektronik',
        unitPrice: 15000.0,
        stockQuantity: 25,
        minStockLevel: 5,
        unit: 'Adet',
        taxRate: 18.0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      ProductEntity(
        name: 'Mouse Kablosuz',
        description: 'Ergonomik kablosuz mouse',
        sku: 'MOU-002',
        barcode: '1234567890124',
        category: 'Elektronik',
        unitPrice: 150.0,
        stockQuantity: 100,
        minStockLevel: 20,
        unit: 'Adet',
        taxRate: 18.0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      ProductEntity(
        name: 'Klavye Mekanik',
        description: 'RGB aydınlatmalı mekanik klavye',
        sku: 'KLA-003',
        barcode: '1234567890125',
        category: 'Elektronik',
        unitPrice: 800.0,
        stockQuantity: 3,
        minStockLevel: 10,
        unit: 'Adet',
        taxRate: 18.0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      ProductEntity(
        name: 'Monitör 24"',
        description: 'Full HD LED monitör',
        sku: 'MON-004',
        barcode: '1234567890126',
        category: 'Elektronik',
        unitPrice: 1200.0,
        stockQuantity: 0,
        minStockLevel: 5,
        unit: 'Adet',
        taxRate: 18.0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final product in testProducts) {
      await productDao.insertProduct(product);
    }
  }

  /// Gider kategorileri test verilerini yükle
  Future<void> _loadExpenseCategoryTestData(TamgaciDatabase database) async {
    final categoryDao = database.expenseCategoryDao;

    // Mevcut kategorileri kontrol et
    final existingCategories = await categoryDao.getAllCategories().first;
    if (existingCategories.isNotEmpty) return;

    final testCategories = [
      ExpenseCategoryEntity(
        name: 'Kira',
        description: 'Ofis ve depo kiraları',
        color: '#2196F3',
        icon: 'home',
        isActive: true,
        isDefault: true,
        sortOrder: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      ExpenseCategoryEntity(
        name: 'Faturalar',
        description: 'Elektrik, su, doğalgaz faturaları',
        color: '#4CAF50',
        icon: 'receipt',
        isActive: true,
        isDefault: true,
        sortOrder: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      ExpenseCategoryEntity(
        name: 'Yazılım',
        description: 'Yazılım lisansları ve abonelikler',
        color: '#9C27B0',
        icon: 'computer',
        isActive: true,
        isDefault: true,
        sortOrder: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      ExpenseCategoryEntity(
        name: 'Personel',
        description: 'Maaş ve personel giderleri',
        color: '#FF9800',
        icon: 'people',
        isActive: true,
        isDefault: true,
        sortOrder: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final category in testCategories) {
      await categoryDao.insertCategory(category);
    }
  }

  /// Gider test verilerini yükle
  Future<void> _loadExpenseTestData(TamgaciDatabase database) async {
    final expenseDao = database.expenseDao;

    // Mevcut gider sayısını kontrol et
    final existingExpenses = await expenseDao.getAllExpenses().first;
    if (existingExpenses.isNotEmpty) return;

    final testExpenses = [
      ExpenseEntity(
        title: 'Ofis Kirası',
        description: 'Aylık ofis kirası ödemesi',
        amount: 3000.0,
        categoryId: 1,
        date: DateTime.now().subtract(const Duration(days: 5)),
        paymentMethod: 'Banka Transferi',
        status: 'paid',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ExpenseEntity(
        title: 'Elektrik Faturası',
        description: 'Aylık elektrik faturası',
        amount: 500.0,
        categoryId: 2,
        date: DateTime.now().subtract(const Duration(days: 2)),
        paymentMethod: 'Otomatik Ödeme',
        status: 'paid',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ExpenseEntity(
        title: 'Yazılım Lisansı',
        description: 'Yıllık yazılım lisans ücreti',
        amount: 1200.0,
        categoryId: 3,
        date: DateTime.now(),
        paymentMethod: 'Kredi Kartı',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final expense in testExpenses) {
      await expenseDao.insertExpense(expense);
    }
  }

  /// Gelir kategorileri test verilerini yükle
  Future<void> _loadIncomeCategoryTestData(TamgaciDatabase database) async {
    final categoryDao = database.incomeCategoryDao;

    // Mevcut kategori sayısını kontrol et
    final existingCategories = await categoryDao.getActiveCategories().first;
    if (existingCategories.isNotEmpty) return;

    final testCategories = [
      IncomeCategoryEntity(
        name: 'Satış',
        description: 'Ürün satış gelirleri',
        color: '#4CAF50',
        icon: 'shopping_cart',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      IncomeCategoryEntity(
        name: 'Hizmet',
        description: 'Hizmet gelirleri',
        color: '#2196F3',
        icon: 'build',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      IncomeCategoryEntity(
        name: 'Danışmanlık',
        description: 'Danışmanlık hizmet gelirleri',
        color: '#9C27B0',
        icon: 'business',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      IncomeCategoryEntity(
        name: 'Diğer',
        description: 'Diğer gelirler',
        color: '#FF9800',
        icon: 'attach_money',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final category in testCategories) {
      await categoryDao.insertCategory(category);
    }
  }

  /// Gelir test verilerini yükle
  Future<void> _loadIncomeTestData(TamgaciDatabase database) async {
    final incomeDao = database.incomeDao;

    // Mevcut gelir sayısını kontrol et
    final existingIncomes = await incomeDao.getAllIncomes().first;
    if (existingIncomes.isNotEmpty) return;

    final testIncomes = [
      IncomeEntity(
        title: 'Laptop Satışı',
        description: 'ABC Şirketi\'ne laptop satışı',
        amount: 15000.0,
        categoryId: '1',
        categoryName: 'Satış',
        incomeDate: DateTime.now().subtract(const Duration(days: 3)),
        paymentMethod: 'Banka Transferi',
        status: 'received',
        customerId: '1',
        customerName: 'ABC Şirketi A.Ş.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      IncomeEntity(
        title: 'Web Sitesi Geliştirme',
        description: 'XYZ Ticaret için web sitesi geliştirme hizmeti',
        amount: 8000.0,
        categoryId: '2',
        categoryName: 'Hizmet',
        incomeDate: DateTime.now().subtract(const Duration(days: 1)),
        paymentMethod: 'Kredi Kartı',
        status: 'received',
        customerId: '2',
        customerName: 'XYZ Ticaret Ltd.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      IncomeEntity(
        title: 'Danışmanlık Hizmeti',
        description: 'Mehmet Kaya\'ya danışmanlık hizmeti',
        amount: 2500.0,
        categoryId: '3',
        categoryName: 'Danışmanlık',
        incomeDate: DateTime.now(),
        paymentMethod: 'Nakit',
        status: 'pending',
        customerId: '3',
        customerName: 'Mehmet Kaya',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final income in testIncomes) {
      await incomeDao.insertIncome(income);
    }
  }
}
