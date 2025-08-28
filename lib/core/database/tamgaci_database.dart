// ========== lib/core/database/tamgaci_database.dart ==========

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tamgaci/core/database/converters/date_time_converter.dart';
import 'package:tamgaci/features/invoices/data/datasources/invoice_dao.dart';
import 'package:tamgaci/features/invoices/data/datasources/invoice_item_dao.dart';
import '../../features/customers/data/models/customer_entity.dart';
import '../../features/customers/data/datasources/customer_dao.dart';
import 'package:tamgaci/features/customers/data/models/stats_views.dart';
import 'package:tamgaci/features/invoices/data/models/invoice_entity.dart';
import 'package:tamgaci/features/invoices/data/models/invoice_item_entity.dart';
import 'package:tamgaci/features/products/data/models/product_entity.dart';
import 'package:tamgaci/features/products/data/datasources/product_dao.dart';
import 'package:tamgaci/features/expenses/data/models/expense_entity.dart';
import 'package:tamgaci/features/expenses/data/models/expense_category_entity.dart';
import 'package:tamgaci/features/expenses/data/datasources/expense_dao.dart';
import 'package:tamgaci/features/expenses/data/datasources/expense_category_dao.dart';
import 'package:tamgaci/features/income/data/models/income_entity.dart';
import 'package:tamgaci/features/income/data/models/income_category_entity.dart';
import 'package:tamgaci/features/income/data/datasources/income_dao.dart';
import 'package:tamgaci/features/income/data/datasources/income_category_dao.dart';
import 'package:tamgaci/features/inventory/data/models/stock_movement_entity.dart';
import 'package:tamgaci/features/inventory/domain/entities/stock_movement.dart';
import 'package:tamgaci/features/inventory/data/models/warehouse_entity.dart';
import 'package:tamgaci/features/inventory/data/models/stock_status_entity.dart';
import 'package:tamgaci/features/inventory/data/datasources/stock_movement_dao.dart';
import 'package:tamgaci/features/inventory/data/datasources/warehouse_dao.dart';
import 'package:tamgaci/features/inventory/data/datasources/stock_status_dao.dart';
import 'package:tamgaci/features/directory/domain/entities/contact.dart';
import 'package:tamgaci/features/directory/data/datasources/contact_dao.dart';
import 'package:tamgaci/features/directory/data/models/contacts_table.dart';

// Floor code generation için gerekli import
part 'tamgaci_database.g.dart';

/// Tamgaci uygulaması ana database sınıfı
/// Floor ile SQLite database yönetimi
@Database(
  version: 6,
  entities: [
    CustomerEntity,
    InvoiceEntity,
    InvoiceItemEntity,
    ProductEntity,
    ExpenseEntity,
    ExpenseCategoryEntity,
    IncomeEntity,
    IncomeCategoryEntity,
    StockMovementEntity,
    WarehouseEntity,
    StockStatusEntity,
    Contact,
    // Gelecekte diğer entity'ler buraya eklenecek:
    // SupplierEntity, vs.
  ],
  views: [CustomerTypeStat, CityCustomerCount, MonthlyCustomerStat],
)
abstract class TamgaciDatabase extends FloorDatabase {
  /// Customer DAO'yu döndürür
  CustomerDao get customerDao;
  InvoiceDao get invoiceDao;
  InvoiceItemDao get invoiceItemDao;
  ProductDao get productDao;
  ExpenseDao get expenseDao;
  ExpenseCategoryDao get expenseCategoryDao;
  IncomeDao get incomeDao;
  IncomeCategoryDao get incomeCategoryDao;
  StockMovementDao get stockMovementDao;
  WarehouseDao get warehouseDao;
  StockStatusDao get stockStatusDao;
  ContactDao get contactDao;
  // Gelecekte diğer DAO'lar buraya eklenecek:
  // SupplierDao get supplierDao;
}

/// Database singleton instance'ını yönetir
class DatabaseHelper {
  static TamgaciDatabase? _database;
  static const String _databaseName = 'tamgaci_database.db';

  /// Database instance'ını döndürür (singleton pattern)
  static Future<TamgaciDatabase> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  /// Database'i başlatır
  static Future<TamgaciDatabase> _initDatabase() async {
    return await $FloorTamgaciDatabase
        .databaseBuilder(_databaseName)
        .addMigrations([
      // Gelecekteki migration'lar buraya eklenecek
    ]).build();
  }

  /// Database'i sıfırlar (dikkatli kullanın!)
  static Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // Database dosyasını siler
    final databasesPath = await sqflite.getDatabasesPath();
    final path = '$databasesPath/$_databaseName';
    await sqflite.deleteDatabase(path);
  }

  /// Database'i kapatır
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

// ========== RIVERPOD PROVIDER ==========

/// Database provider'ı
final databaseProvider = FutureProvider<TamgaciDatabase>((ref) async {
  // Web platformunda database kullanma
  if (kIsWeb) {
    throw UnsupportedError('Database is not supported on web platform');
  }
  return await DatabaseHelper.getDatabase();
});

// ========== DOSYA YERLEŞTİRME TALİMATLARI ==========

/*
📁 Bu dosyaların yerleştirilmesi gereken konumlar:

1. 📄 customer_entity.dart
   → lib/features/customers/data/models/customer_entity.dart

2. 📄 customer_dao.dart  
   → lib/features/customers/data/datasources/customer_dao.dart

3. 📄 tamgaci_database.dart
   → lib/core/database/tamgaci_database.dart

========== SONRAKI ADIM: CODE GENERATION ==========

Dosyaları yerleştirdikten sonra şu komutu çalıştırın:

flutter packages pub run build_runner build

Bu komut Floor için gerekli tamgaci_database.g.dart dosyasını oluşturacak.

Eğer hata alırsanız, önce şunu deneyin:
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs

========== TEST VERİLERİ ==========

Database hazır olduktan sonra test müşterileri eklemek için
DatabaseHelper kullanabilirsiniz:

```dart
final database = await DatabaseHelper.getDatabase();
final customerDao = database.customerDao;

final testCustomer = CustomerEntity(
  id: 'customer_1',
  name: 'Ahmet Yılmaz',
  email: 'ahmet@example.com',
  phone: '+90 555 123 45 67',
  customerType: CustomerType.individual.value,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

await customerDao.insertCustomer(testCustomer);
```
*/
