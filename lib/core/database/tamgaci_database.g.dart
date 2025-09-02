// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tamgaci_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $TamgaciDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $TamgaciDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $TamgaciDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<TamgaciDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorTamgaciDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $TamgaciDatabaseBuilderContract databaseBuilder(String name) =>
      _$TamgaciDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $TamgaciDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$TamgaciDatabaseBuilder(null);
}

class _$TamgaciDatabaseBuilder implements $TamgaciDatabaseBuilderContract {
  _$TamgaciDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $TamgaciDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $TamgaciDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<TamgaciDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$TamgaciDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$TamgaciDatabase extends TamgaciDatabase {
  _$TamgaciDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CustomerDao? _customerDaoInstance;

  InvoiceDao? _invoiceDaoInstance;

  InvoiceItemDao? _invoiceItemDaoInstance;

  ProductDao? _productDaoInstance;

  ExpenseDao? _expenseDaoInstance;

  ExpenseCategoryDao? _expenseCategoryDaoInstance;

  IncomeDao? _incomeDaoInstance;

  IncomeCategoryDao? _incomeCategoryDaoInstance;

  WarehouseDao? _warehouseDaoInstance;

  StockDao? _stockDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 7,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `customers` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `email` TEXT, `phone` TEXT, `address` TEXT, `tax_number` TEXT, `tax_office` TEXT, `customer_type` TEXT NOT NULL, `city` TEXT, `country` TEXT, `postal_code` TEXT, `balance` INTEGER NOT NULL, `balance_currency` TEXT NOT NULL, `notes` TEXT, `is_active` INTEGER NOT NULL, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `invoices` (`id` TEXT NOT NULL, `invoice_number` TEXT NOT NULL, `customer_id` TEXT NOT NULL, `invoice_date` INTEGER NOT NULL, `due_date` INTEGER, `status` TEXT NOT NULL, `subtotal` INTEGER NOT NULL, `tax_amount` INTEGER NOT NULL, `discount_amount` INTEGER NOT NULL, `total_amount` INTEGER NOT NULL, `currency_code` TEXT NOT NULL, `payment_terms` TEXT, `notes` TEXT, `description` TEXT, `is_paid` INTEGER NOT NULL, `paid_date` INTEGER, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON UPDATE NO ACTION ON DELETE RESTRICT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `invoice_items` (`id` TEXT NOT NULL, `invoice_id` TEXT NOT NULL, `item_order` INTEGER NOT NULL, `product_name` TEXT NOT NULL, `description` TEXT, `quantity` REAL NOT NULL, `unit` TEXT, `unit_price` INTEGER NOT NULL, `tax_rate` REAL NOT NULL, `tax_amount` INTEGER NOT NULL, `line_total` INTEGER NOT NULL, `created_at` INTEGER NOT NULL, FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `products` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `description` TEXT, `sku` TEXT, `barcode` TEXT, `category` TEXT, `unit_price` REAL NOT NULL, `stock_quantity` INTEGER NOT NULL, `min_stock_level` INTEGER NOT NULL, `unit` TEXT NOT NULL, `tax_rate` REAL NOT NULL, `currency` TEXT NOT NULL, `is_active` INTEGER NOT NULL, `image_url` TEXT, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `expenses` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `description` TEXT, `amount` REAL NOT NULL, `currency` TEXT NOT NULL, `categoryId` INTEGER NOT NULL, `date` INTEGER NOT NULL, `status` TEXT NOT NULL, `paymentMethod` TEXT, `receiptPath` TEXT, `notes` TEXT, `createdAt` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `expense_categories` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `description` TEXT, `color` TEXT, `icon` TEXT, `isActive` INTEGER NOT NULL, `isDefault` INTEGER NOT NULL, `sortOrder` INTEGER NOT NULL, `createdAt` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `incomes` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `description` TEXT, `amount` REAL NOT NULL, `currency` TEXT NOT NULL, `category_id` TEXT NOT NULL, `category_name` TEXT NOT NULL, `income_date` INTEGER NOT NULL, `customer_id` TEXT, `customer_name` TEXT, `payment_method` TEXT NOT NULL, `invoice_number` TEXT, `status` TEXT NOT NULL, `notes` TEXT, `attachments` TEXT, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `income_categories` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `description` TEXT, `color` TEXT, `icon` TEXT, `is_active` INTEGER NOT NULL, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `warehouses` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `code` TEXT, `description` TEXT, `address` TEXT, `phone` TEXT, `email` TEXT, `manager` TEXT, `capacity` REAL, `capacity_unit` TEXT, `currency` TEXT NOT NULL, `is_active` INTEGER NOT NULL, `is_default` INTEGER NOT NULL, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `stocks` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `productId` INTEGER NOT NULL, `warehouseId` INTEGER NOT NULL, `quantity` REAL NOT NULL, `minimumQuantity` REAL NOT NULL, `maximumQuantity` REAL NOT NULL, `unit` TEXT NOT NULL, `currency` TEXT NOT NULL, `unitPrice` REAL NOT NULL, `location` TEXT, `notes` TEXT, `isActive` INTEGER NOT NULL, `createdAt` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL, FOREIGN KEY (`productId`) REFERENCES `products` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`warehouseId`) REFERENCES `warehouses` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE INDEX `index_invoices_customer_id` ON `invoices` (`customer_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_invoices_invoice_number` ON `invoices` (`invoice_number`)');
        await database.execute(
            'CREATE INDEX `index_invoices_status` ON `invoices` (`status`)');
        await database.execute(
            'CREATE INDEX `index_invoices_created_at` ON `invoices` (`created_at`)');
        await database.execute(
            'CREATE INDEX `index_invoice_items_invoice_id` ON `invoice_items` (`invoice_id`)');
        await database.execute(
            'CREATE INDEX `index_invoice_items_item_order` ON `invoice_items` (`item_order`)');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `CustomerTypeStat` AS   SELECT \n    customer_type AS customerType,\n    COUNT(*) AS count\n  FROM customers \n  WHERE is_active = 1 \n  GROUP BY customer_type\n');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `CityCustomerCount` AS   SELECT \n    city,\n    COUNT(*) AS count\n  FROM customers\n  WHERE is_active = 1 AND city IS NOT NULL\n  GROUP BY city\n  ORDER BY count DESC\n  LIMIT 10\n');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `MonthlyCustomerStat` AS   SELECT \n    strftime(\'%Y-%m\', datetime(created_at / 1000, \'unixepoch\')) AS month,\n    COUNT(*) AS count\n  FROM customers\n  GROUP BY month\n  ORDER BY month DESC\n  LIMIT 12\n');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CustomerDao get customerDao {
    return _customerDaoInstance ??= _$CustomerDao(database, changeListener);
  }

  @override
  InvoiceDao get invoiceDao {
    return _invoiceDaoInstance ??= _$InvoiceDao(database, changeListener);
  }

  @override
  InvoiceItemDao get invoiceItemDao {
    return _invoiceItemDaoInstance ??=
        _$InvoiceItemDao(database, changeListener);
  }

  @override
  ProductDao get productDao {
    return _productDaoInstance ??= _$ProductDao(database, changeListener);
  }

  @override
  ExpenseDao get expenseDao {
    return _expenseDaoInstance ??= _$ExpenseDao(database, changeListener);
  }

  @override
  ExpenseCategoryDao get expenseCategoryDao {
    return _expenseCategoryDaoInstance ??=
        _$ExpenseCategoryDao(database, changeListener);
  }

  @override
  IncomeDao get incomeDao {
    return _incomeDaoInstance ??= _$IncomeDao(database, changeListener);
  }

  @override
  IncomeCategoryDao get incomeCategoryDao {
    return _incomeCategoryDaoInstance ??=
        _$IncomeCategoryDao(database, changeListener);
  }

  @override
  WarehouseDao get warehouseDao {
    return _warehouseDaoInstance ??= _$WarehouseDao(database, changeListener);
  }

  @override
  StockDao get stockDao {
    return _stockDaoInstance ??= _$StockDao(database, changeListener);
  }
}

class _$CustomerDao extends CustomerDao {
  _$CustomerDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _customerEntityInsertionAdapter = InsertionAdapter(
            database,
            'customers',
            (CustomerEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'email': item.email,
                  'phone': item.phone,
                  'address': item.address,
                  'tax_number': item.taxNumber,
                  'tax_office': item.taxOffice,
                  'customer_type': item.customerType,
                  'city': item.city,
                  'country': item.country,
                  'postal_code': item.postalCode,
                  'balance': item.balance,
                  'balance_currency': item.balanceCurrency,
                  'notes': item.notes,
                  'is_active': item.isActive ? 1 : 0,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener),
        _customerEntityUpdateAdapter = UpdateAdapter(
            database,
            'customers',
            ['id'],
            (CustomerEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'email': item.email,
                  'phone': item.phone,
                  'address': item.address,
                  'tax_number': item.taxNumber,
                  'tax_office': item.taxOffice,
                  'customer_type': item.customerType,
                  'city': item.city,
                  'country': item.country,
                  'postal_code': item.postalCode,
                  'balance': item.balance,
                  'balance_currency': item.balanceCurrency,
                  'notes': item.notes,
                  'is_active': item.isActive ? 1 : 0,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener),
        _customerEntityDeletionAdapter = DeletionAdapter(
            database,
            'customers',
            ['id'],
            (CustomerEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'email': item.email,
                  'phone': item.phone,
                  'address': item.address,
                  'tax_number': item.taxNumber,
                  'tax_office': item.taxOffice,
                  'customer_type': item.customerType,
                  'city': item.city,
                  'country': item.country,
                  'postal_code': item.postalCode,
                  'balance': item.balance,
                  'balance_currency': item.balanceCurrency,
                  'notes': item.notes,
                  'is_active': item.isActive ? 1 : 0,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CustomerEntity> _customerEntityInsertionAdapter;

  final UpdateAdapter<CustomerEntity> _customerEntityUpdateAdapter;

  final DeletionAdapter<CustomerEntity> _customerEntityDeletionAdapter;

  @override
  Future<List<CustomerEntity>> getAllCustomers() async {
    return _queryAdapter.queryList('SELECT * FROM customers ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => CustomerEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            email: row['email'] as String?,
            phone: row['phone'] as String?,
            address: row['address'] as String?,
            taxNumber: row['tax_number'] as String?,
            taxOffice: row['tax_office'] as String?,
            customerType: row['customer_type'] as String,
            city: row['city'] as String?,
            country: row['country'] as String?,
            postalCode: row['postal_code'] as String?,
            balance: row['balance'] as int,
            balanceCurrency: row['balance_currency'] as String,
            notes: row['notes'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<List<CustomerEntity>> getActiveCustomers() async {
    return _queryAdapter.queryList(
        'SELECT * FROM customers WHERE is_active = 1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => CustomerEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            email: row['email'] as String?,
            phone: row['phone'] as String?,
            address: row['address'] as String?,
            taxNumber: row['tax_number'] as String?,
            taxOffice: row['tax_office'] as String?,
            customerType: row['customer_type'] as String,
            city: row['city'] as String?,
            country: row['country'] as String?,
            postalCode: row['postal_code'] as String?,
            balance: row['balance'] as int,
            balanceCurrency: row['balance_currency'] as String,
            notes: row['notes'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<CustomerEntity?> getCustomerById(String id) async {
    return _queryAdapter.query('SELECT * FROM customers WHERE id = ?1',
        mapper: (Map<String, Object?> row) => CustomerEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            email: row['email'] as String?,
            phone: row['phone'] as String?,
            address: row['address'] as String?,
            taxNumber: row['tax_number'] as String?,
            taxOffice: row['tax_office'] as String?,
            customerType: row['customer_type'] as String,
            city: row['city'] as String?,
            country: row['country'] as String?,
            postalCode: row['postal_code'] as String?,
            balance: row['balance'] as int,
            balanceCurrency: row['balance_currency'] as String,
            notes: row['notes'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<List<CustomerEntity>> searchCustomersByName(String searchTerm) async {
    return _queryAdapter.queryList(
        'SELECT * FROM customers WHERE name LIKE ?1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => CustomerEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            email: row['email'] as String?,
            phone: row['phone'] as String?,
            address: row['address'] as String?,
            taxNumber: row['tax_number'] as String?,
            taxOffice: row['tax_office'] as String?,
            customerType: row['customer_type'] as String,
            city: row['city'] as String?,
            country: row['country'] as String?,
            postalCode: row['postal_code'] as String?,
            balance: row['balance'] as int,
            balanceCurrency: row['balance_currency'] as String,
            notes: row['notes'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [searchTerm]);
  }

  @override
  Future<List<CustomerEntity>> getCustomersByType(String type) async {
    return _queryAdapter.queryList(
        'SELECT * FROM customers WHERE customer_type = ?1 AND is_active = 1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => CustomerEntity(id: row['id'] as String, name: row['name'] as String, email: row['email'] as String?, phone: row['phone'] as String?, address: row['address'] as String?, taxNumber: row['tax_number'] as String?, taxOffice: row['tax_office'] as String?, customerType: row['customer_type'] as String, city: row['city'] as String?, country: row['country'] as String?, postalCode: row['postal_code'] as String?, balance: row['balance'] as int, balanceCurrency: row['balance_currency'] as String, notes: row['notes'] as String?, isActive: (row['is_active'] as int) != 0, createdAt: _dateTimeConverter.decode(row['created_at'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [type]);
  }

  @override
  Future<List<CustomerEntity>> getCustomersByCity(String city) async {
    return _queryAdapter.queryList(
        'SELECT * FROM customers WHERE city = ?1 AND is_active = 1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => CustomerEntity(id: row['id'] as String, name: row['name'] as String, email: row['email'] as String?, phone: row['phone'] as String?, address: row['address'] as String?, taxNumber: row['tax_number'] as String?, taxOffice: row['tax_office'] as String?, customerType: row['customer_type'] as String, city: row['city'] as String?, country: row['country'] as String?, postalCode: row['postal_code'] as String?, balance: row['balance'] as int, balanceCurrency: row['balance_currency'] as String, notes: row['notes'] as String?, isActive: (row['is_active'] as int) != 0, createdAt: _dateTimeConverter.decode(row['created_at'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [city]);
  }

  @override
  Future<CustomerEntity?> getCustomerByEmail(String email) async {
    return _queryAdapter.query(
        'SELECT * FROM customers WHERE email = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => CustomerEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            email: row['email'] as String?,
            phone: row['phone'] as String?,
            address: row['address'] as String?,
            taxNumber: row['tax_number'] as String?,
            taxOffice: row['tax_office'] as String?,
            customerType: row['customer_type'] as String,
            city: row['city'] as String?,
            country: row['country'] as String?,
            postalCode: row['postal_code'] as String?,
            balance: row['balance'] as int,
            balanceCurrency: row['balance_currency'] as String,
            notes: row['notes'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [email]);
  }

  @override
  Future<CustomerEntity?> getCustomerByPhone(String phone) async {
    return _queryAdapter.query(
        'SELECT * FROM customers WHERE phone = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => CustomerEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            email: row['email'] as String?,
            phone: row['phone'] as String?,
            address: row['address'] as String?,
            taxNumber: row['tax_number'] as String?,
            taxOffice: row['tax_office'] as String?,
            customerType: row['customer_type'] as String,
            city: row['city'] as String?,
            country: row['country'] as String?,
            postalCode: row['postal_code'] as String?,
            balance: row['balance'] as int,
            balanceCurrency: row['balance_currency'] as String,
            notes: row['notes'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [phone]);
  }

  @override
  Future<CustomerEntity?> getCustomerByTaxNumber(String taxNumber) async {
    return _queryAdapter.query(
        'SELECT * FROM customers WHERE tax_number = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => CustomerEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            email: row['email'] as String?,
            phone: row['phone'] as String?,
            address: row['address'] as String?,
            taxNumber: row['tax_number'] as String?,
            taxOffice: row['tax_office'] as String?,
            customerType: row['customer_type'] as String,
            city: row['city'] as String?,
            country: row['country'] as String?,
            postalCode: row['postal_code'] as String?,
            balance: row['balance'] as int,
            balanceCurrency: row['balance_currency'] as String,
            notes: row['notes'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [taxNumber]);
  }

  @override
  Future<int?> getActiveCustomerCount() async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM customers WHERE is_active = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getTotalCustomerCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM customers',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getInactiveCustomerCount() async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM customers WHERE is_active = 0',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<List<CustomerEntity>> getRecentCustomers(int limit) async {
    return _queryAdapter.queryList(
        'SELECT * FROM customers WHERE is_active = 1 ORDER BY created_at DESC LIMIT ?1',
        mapper: (Map<String, Object?> row) => CustomerEntity(id: row['id'] as String, name: row['name'] as String, email: row['email'] as String?, phone: row['phone'] as String?, address: row['address'] as String?, taxNumber: row['tax_number'] as String?, taxOffice: row['tax_office'] as String?, customerType: row['customer_type'] as String, city: row['city'] as String?, country: row['country'] as String?, postalCode: row['postal_code'] as String?, balance: row['balance'] as int, balanceCurrency: row['balance_currency'] as String, notes: row['notes'] as String?, isActive: (row['is_active'] as int) != 0, createdAt: _dateTimeConverter.decode(row['created_at'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [limit]);
  }

  @override
  Future<void> updateCustomerStatus(
    String id,
    bool isActive,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE customers SET is_active = ?2, updated_at = ?3 WHERE id = ?1',
        arguments: [id, isActive ? 1 : 0, updatedAt]);
  }

  @override
  Future<void> updateCustomerNotes(
    String id,
    String notes,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE customers SET notes = ?2, updated_at = ?3 WHERE id = ?1',
        arguments: [id, notes, updatedAt]);
  }

  @override
  Future<void> deleteCustomerById(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM customers WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteInactiveCustomers() async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM customers WHERE is_active = 0');
  }

  @override
  Future<void> deleteAllCustomers() async {
    await _queryAdapter.queryNoReturn('DELETE FROM customers');
  }

  @override
  Stream<List<CustomerEntity>> watchAllCustomers() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM customers ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => CustomerEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            email: row['email'] as String?,
            phone: row['phone'] as String?,
            address: row['address'] as String?,
            taxNumber: row['tax_number'] as String?,
            taxOffice: row['tax_office'] as String?,
            customerType: row['customer_type'] as String,
            city: row['city'] as String?,
            country: row['country'] as String?,
            postalCode: row['postal_code'] as String?,
            balance: row['balance'] as int,
            balanceCurrency: row['balance_currency'] as String,
            notes: row['notes'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        queryableName: 'customers',
        isView: false);
  }

  @override
  Stream<List<CustomerEntity>> watchActiveCustomers() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM customers WHERE is_active = 1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => CustomerEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            email: row['email'] as String?,
            phone: row['phone'] as String?,
            address: row['address'] as String?,
            taxNumber: row['tax_number'] as String?,
            taxOffice: row['tax_office'] as String?,
            customerType: row['customer_type'] as String,
            city: row['city'] as String?,
            country: row['country'] as String?,
            postalCode: row['postal_code'] as String?,
            balance: row['balance'] as int,
            balanceCurrency: row['balance_currency'] as String,
            notes: row['notes'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        queryableName: 'customers',
        isView: false);
  }

  @override
  Stream<List<CustomerEntity>> watchInactiveCustomers() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM customers WHERE is_active = 0 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => CustomerEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            email: row['email'] as String?,
            phone: row['phone'] as String?,
            address: row['address'] as String?,
            taxNumber: row['tax_number'] as String?,
            taxOffice: row['tax_office'] as String?,
            customerType: row['customer_type'] as String,
            city: row['city'] as String?,
            country: row['country'] as String?,
            postalCode: row['postal_code'] as String?,
            balance: row['balance'] as int,
            balanceCurrency: row['balance_currency'] as String,
            notes: row['notes'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        queryableName: 'customers',
        isView: false);
  }

  @override
  Stream<CustomerEntity?> watchCustomerById(String id) {
    return _queryAdapter.queryStream('SELECT * FROM customers WHERE id = ?1',
        mapper: (Map<String, Object?> row) => CustomerEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            email: row['email'] as String?,
            phone: row['phone'] as String?,
            address: row['address'] as String?,
            taxNumber: row['tax_number'] as String?,
            taxOffice: row['tax_office'] as String?,
            customerType: row['customer_type'] as String,
            city: row['city'] as String?,
            country: row['country'] as String?,
            postalCode: row['postal_code'] as String?,
            balance: row['balance'] as int,
            balanceCurrency: row['balance_currency'] as String,
            notes: row['notes'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id],
        queryableName: 'customers',
        isView: false);
  }

  @override
  Stream<int?> watchActiveCustomerCount() {
    return _queryAdapter.queryStream(
        'SELECT COUNT(*) FROM customers WHERE is_active = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        queryableName: 'customers',
        isView: false);
  }

  @override
  Stream<int?> watchInactiveCustomerCount() {
    return _queryAdapter.queryStream(
        'SELECT COUNT(*) FROM customers WHERE is_active = 0',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        queryableName: 'customers',
        isView: false);
  }

  @override
  Future<List<CustomerTypeStat>> getCustomerTypeStats() async {
    return _queryAdapter.queryList(
        'SELECT      customer_type AS customerType,     COUNT(*) AS count   FROM customers    WHERE is_active = 1    GROUP BY customer_type',
        mapper: (Map<String, Object?> row) => CustomerTypeStat(
            row['customerType'] as String, row['count'] as int));
  }

  @override
  Future<List<CityCustomerCount>> getCityCustomerCounts() async {
    return _queryAdapter.queryList(
        'SELECT        city,       COUNT(*) as count     FROM customers      WHERE is_active = 1 AND city IS NOT NULL     GROUP BY city     ORDER BY count DESC     LIMIT 10',
        mapper: (Map<String, Object?> row) =>
            CityCustomerCount(row['city'] as String, row['count'] as int));
  }

  @override
  Future<List<MonthlyCustomerStat>> getMonthlyCustomerStats() async {
    return _queryAdapter.queryList(
        'SELECT        strftime(\'%Y-%m\', datetime(created_at / 1000, \'unixepoch\')) as month,       COUNT(*) as count     FROM customers     GROUP BY month     ORDER BY month DESC     LIMIT 12',
        mapper: (Map<String, Object?> row) =>
            MonthlyCustomerStat(row['month'] as String, row['count'] as int));
  }

  @override
  Future<void> insertCustomer(CustomerEntity customer) async {
    await _customerEntityInsertionAdapter.insert(
        customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertCustomers(List<CustomerEntity> customers) async {
    await _customerEntityInsertionAdapter.insertList(
        customers, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCustomer(CustomerEntity customer) async {
    await _customerEntityUpdateAdapter.update(
        customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCustomer(CustomerEntity customer) async {
    await _customerEntityDeletionAdapter.delete(customer);
  }
}

class _$InvoiceDao extends InvoiceDao {
  _$InvoiceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _invoiceEntityInsertionAdapter = InsertionAdapter(
            database,
            'invoices',
            (InvoiceEntity item) => <String, Object?>{
                  'id': item.id,
                  'invoice_number': item.invoiceNumber,
                  'customer_id': item.customerId,
                  'invoice_date': item.invoiceDate,
                  'due_date': item.dueDate,
                  'status': item.status,
                  'subtotal': item.subtotal,
                  'tax_amount': item.taxAmount,
                  'discount_amount': item.discountAmount,
                  'total_amount': item.totalAmount,
                  'currency_code': item.currencyCode,
                  'payment_terms': item.paymentTerms,
                  'notes': item.notes,
                  'description': item.description,
                  'is_paid': item.isPaid ? 1 : 0,
                  'paid_date': item.paidDate,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt
                },
            changeListener),
        _invoiceEntityUpdateAdapter = UpdateAdapter(
            database,
            'invoices',
            ['id'],
            (InvoiceEntity item) => <String, Object?>{
                  'id': item.id,
                  'invoice_number': item.invoiceNumber,
                  'customer_id': item.customerId,
                  'invoice_date': item.invoiceDate,
                  'due_date': item.dueDate,
                  'status': item.status,
                  'subtotal': item.subtotal,
                  'tax_amount': item.taxAmount,
                  'discount_amount': item.discountAmount,
                  'total_amount': item.totalAmount,
                  'currency_code': item.currencyCode,
                  'payment_terms': item.paymentTerms,
                  'notes': item.notes,
                  'description': item.description,
                  'is_paid': item.isPaid ? 1 : 0,
                  'paid_date': item.paidDate,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt
                },
            changeListener),
        _invoiceEntityDeletionAdapter = DeletionAdapter(
            database,
            'invoices',
            ['id'],
            (InvoiceEntity item) => <String, Object?>{
                  'id': item.id,
                  'invoice_number': item.invoiceNumber,
                  'customer_id': item.customerId,
                  'invoice_date': item.invoiceDate,
                  'due_date': item.dueDate,
                  'status': item.status,
                  'subtotal': item.subtotal,
                  'tax_amount': item.taxAmount,
                  'discount_amount': item.discountAmount,
                  'total_amount': item.totalAmount,
                  'currency_code': item.currencyCode,
                  'payment_terms': item.paymentTerms,
                  'notes': item.notes,
                  'description': item.description,
                  'is_paid': item.isPaid ? 1 : 0,
                  'paid_date': item.paidDate,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<InvoiceEntity> _invoiceEntityInsertionAdapter;

  final UpdateAdapter<InvoiceEntity> _invoiceEntityUpdateAdapter;

  final DeletionAdapter<InvoiceEntity> _invoiceEntityDeletionAdapter;

  @override
  Future<List<InvoiceEntity>> getAllInvoices() async {
    return _queryAdapter.queryList(
        'SELECT * FROM invoices ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => InvoiceEntity(
            id: row['id'] as String,
            invoiceNumber: row['invoice_number'] as String,
            customerId: row['customer_id'] as String,
            invoiceDate: row['invoice_date'] as int,
            dueDate: row['due_date'] as int?,
            status: row['status'] as String,
            subtotal: row['subtotal'] as int,
            taxAmount: row['tax_amount'] as int,
            discountAmount: row['discount_amount'] as int,
            totalAmount: row['total_amount'] as int,
            currencyCode: row['currency_code'] as String,
            paymentTerms: row['payment_terms'] as String?,
            notes: row['notes'] as String?,
            description: row['description'] as String?,
            isPaid: (row['is_paid'] as int) != 0,
            paidDate: row['paid_date'] as int?,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int));
  }

  @override
  Future<InvoiceEntity?> getInvoiceById(String id) async {
    return _queryAdapter.query('SELECT * FROM invoices WHERE id = ?1',
        mapper: (Map<String, Object?> row) => InvoiceEntity(
            id: row['id'] as String,
            invoiceNumber: row['invoice_number'] as String,
            customerId: row['customer_id'] as String,
            invoiceDate: row['invoice_date'] as int,
            dueDate: row['due_date'] as int?,
            status: row['status'] as String,
            subtotal: row['subtotal'] as int,
            taxAmount: row['tax_amount'] as int,
            discountAmount: row['discount_amount'] as int,
            totalAmount: row['total_amount'] as int,
            currencyCode: row['currency_code'] as String,
            paymentTerms: row['payment_terms'] as String?,
            notes: row['notes'] as String?,
            description: row['description'] as String?,
            isPaid: (row['is_paid'] as int) != 0,
            paidDate: row['paid_date'] as int?,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int),
        arguments: [id]);
  }

  @override
  Future<InvoiceEntity?> getInvoiceByNumber(String invoiceNumber) async {
    return _queryAdapter.query(
        'SELECT * FROM invoices WHERE invoice_number = ?1',
        mapper: (Map<String, Object?> row) => InvoiceEntity(
            id: row['id'] as String,
            invoiceNumber: row['invoice_number'] as String,
            customerId: row['customer_id'] as String,
            invoiceDate: row['invoice_date'] as int,
            dueDate: row['due_date'] as int?,
            status: row['status'] as String,
            subtotal: row['subtotal'] as int,
            taxAmount: row['tax_amount'] as int,
            discountAmount: row['discount_amount'] as int,
            totalAmount: row['total_amount'] as int,
            currencyCode: row['currency_code'] as String,
            paymentTerms: row['payment_terms'] as String?,
            notes: row['notes'] as String?,
            description: row['description'] as String?,
            isPaid: (row['is_paid'] as int) != 0,
            paidDate: row['paid_date'] as int?,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int),
        arguments: [invoiceNumber]);
  }

  @override
  Future<List<InvoiceEntity>> getInvoicesByCustomerId(String customerId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM invoices WHERE customer_id = ?1 ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => InvoiceEntity(id: row['id'] as String, invoiceNumber: row['invoice_number'] as String, customerId: row['customer_id'] as String, invoiceDate: row['invoice_date'] as int, dueDate: row['due_date'] as int?, status: row['status'] as String, subtotal: row['subtotal'] as int, taxAmount: row['tax_amount'] as int, discountAmount: row['discount_amount'] as int, totalAmount: row['total_amount'] as int, currencyCode: row['currency_code'] as String, paymentTerms: row['payment_terms'] as String?, notes: row['notes'] as String?, description: row['description'] as String?, isPaid: (row['is_paid'] as int) != 0, paidDate: row['paid_date'] as int?, createdAt: row['created_at'] as int, updatedAt: row['updated_at'] as int),
        arguments: [customerId]);
  }

  @override
  Future<List<InvoiceEntity>> getInvoicesByStatus(String status) async {
    return _queryAdapter.queryList(
        'SELECT * FROM invoices WHERE status = ?1 ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => InvoiceEntity(
            id: row['id'] as String,
            invoiceNumber: row['invoice_number'] as String,
            customerId: row['customer_id'] as String,
            invoiceDate: row['invoice_date'] as int,
            dueDate: row['due_date'] as int?,
            status: row['status'] as String,
            subtotal: row['subtotal'] as int,
            taxAmount: row['tax_amount'] as int,
            discountAmount: row['discount_amount'] as int,
            totalAmount: row['total_amount'] as int,
            currencyCode: row['currency_code'] as String,
            paymentTerms: row['payment_terms'] as String?,
            notes: row['notes'] as String?,
            description: row['description'] as String?,
            isPaid: (row['is_paid'] as int) != 0,
            paidDate: row['paid_date'] as int?,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int),
        arguments: [status]);
  }

  @override
  Future<List<InvoiceEntity>> getInvoicesByDateRange(
    int startDate,
    int endDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM invoices WHERE invoice_date >= ?1 AND invoice_date <= ?2 ORDER BY invoice_date DESC',
        mapper: (Map<String, Object?> row) => InvoiceEntity(id: row['id'] as String, invoiceNumber: row['invoice_number'] as String, customerId: row['customer_id'] as String, invoiceDate: row['invoice_date'] as int, dueDate: row['due_date'] as int?, status: row['status'] as String, subtotal: row['subtotal'] as int, taxAmount: row['tax_amount'] as int, discountAmount: row['discount_amount'] as int, totalAmount: row['total_amount'] as int, currencyCode: row['currency_code'] as String, paymentTerms: row['payment_terms'] as String?, notes: row['notes'] as String?, description: row['description'] as String?, isPaid: (row['is_paid'] as int) != 0, paidDate: row['paid_date'] as int?, createdAt: row['created_at'] as int, updatedAt: row['updated_at'] as int),
        arguments: [startDate, endDate]);
  }

  @override
  Future<List<InvoiceEntity>> getUnpaidInvoices() async {
    return _queryAdapter.queryList(
        'SELECT * FROM invoices WHERE is_paid = 0 ORDER BY due_date ASC',
        mapper: (Map<String, Object?> row) => InvoiceEntity(
            id: row['id'] as String,
            invoiceNumber: row['invoice_number'] as String,
            customerId: row['customer_id'] as String,
            invoiceDate: row['invoice_date'] as int,
            dueDate: row['due_date'] as int?,
            status: row['status'] as String,
            subtotal: row['subtotal'] as int,
            taxAmount: row['tax_amount'] as int,
            discountAmount: row['discount_amount'] as int,
            totalAmount: row['total_amount'] as int,
            currencyCode: row['currency_code'] as String,
            paymentTerms: row['payment_terms'] as String?,
            notes: row['notes'] as String?,
            description: row['description'] as String?,
            isPaid: (row['is_paid'] as int) != 0,
            paidDate: row['paid_date'] as int?,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int));
  }

  @override
  Future<List<InvoiceEntity>> getOverdueInvoices(int currentDate) async {
    return _queryAdapter.queryList(
        'SELECT * FROM invoices WHERE is_paid = 0 AND due_date IS NOT NULL AND due_date < ?1 ORDER BY due_date ASC',
        mapper: (Map<String, Object?> row) => InvoiceEntity(id: row['id'] as String, invoiceNumber: row['invoice_number'] as String, customerId: row['customer_id'] as String, invoiceDate: row['invoice_date'] as int, dueDate: row['due_date'] as int?, status: row['status'] as String, subtotal: row['subtotal'] as int, taxAmount: row['tax_amount'] as int, discountAmount: row['discount_amount'] as int, totalAmount: row['total_amount'] as int, currencyCode: row['currency_code'] as String, paymentTerms: row['payment_terms'] as String?, notes: row['notes'] as String?, description: row['description'] as String?, isPaid: (row['is_paid'] as int) != 0, paidDate: row['paid_date'] as int?, createdAt: row['created_at'] as int, updatedAt: row['updated_at'] as int),
        arguments: [currentDate]);
  }

  @override
  Future<List<InvoiceEntity>> getRecentInvoices(int limit) async {
    return _queryAdapter.queryList(
        'SELECT * FROM invoices ORDER BY created_at DESC LIMIT ?1',
        mapper: (Map<String, Object?> row) => InvoiceEntity(
            id: row['id'] as String,
            invoiceNumber: row['invoice_number'] as String,
            customerId: row['customer_id'] as String,
            invoiceDate: row['invoice_date'] as int,
            dueDate: row['due_date'] as int?,
            status: row['status'] as String,
            subtotal: row['subtotal'] as int,
            taxAmount: row['tax_amount'] as int,
            discountAmount: row['discount_amount'] as int,
            totalAmount: row['total_amount'] as int,
            currencyCode: row['currency_code'] as String,
            paymentTerms: row['payment_terms'] as String?,
            notes: row['notes'] as String?,
            description: row['description'] as String?,
            isPaid: (row['is_paid'] as int) != 0,
            paidDate: row['paid_date'] as int?,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int),
        arguments: [limit]);
  }

  @override
  Future<List<InvoiceEntity>> searchInvoices(String searchTerm) async {
    return _queryAdapter.queryList(
        'SELECT * FROM invoices      WHERE invoice_number LIKE ?1      OR description LIKE ?1      ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => InvoiceEntity(id: row['id'] as String, invoiceNumber: row['invoice_number'] as String, customerId: row['customer_id'] as String, invoiceDate: row['invoice_date'] as int, dueDate: row['due_date'] as int?, status: row['status'] as String, subtotal: row['subtotal'] as int, taxAmount: row['tax_amount'] as int, discountAmount: row['discount_amount'] as int, totalAmount: row['total_amount'] as int, currencyCode: row['currency_code'] as String, paymentTerms: row['payment_terms'] as String?, notes: row['notes'] as String?, description: row['description'] as String?, isPaid: (row['is_paid'] as int) != 0, paidDate: row['paid_date'] as int?, createdAt: row['created_at'] as int, updatedAt: row['updated_at'] as int),
        arguments: [searchTerm]);
  }

  @override
  Future<int?> getTotalInvoiceCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM invoices',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getInvoiceCountByStatus(String status) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM invoices WHERE status = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [status]);
  }

  @override
  Future<void> updateInvoiceStatus(
    String id,
    String status,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE invoices SET status = ?2, updated_at = ?3 WHERE id = ?1',
        arguments: [id, status, updatedAt]);
  }

  @override
  Future<void> updateInvoicePaymentStatus(
    String id,
    bool isPaid,
    int paidDate,
    String status,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE invoices SET is_paid = ?2, paidDate = CASE WHEN ?3 IS NOT NULL THEN  ?3, status = ?4, updated_at = ?5 WHERE id = ?1',
        arguments: [id, isPaid ? 1 : 0, paidDate, status, updatedAt]);
  }

  @override
  Future<void> updateInvoiceAmounts(
    String id,
    int subtotal,
    int taxAmount,
    int discountAmount,
    int totalAmount,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE invoices      SET subtotal = ?2,          tax_amount = ?3,          discount_amount = ?4,          total_amount = ?5,         updated_at = ?6     WHERE id = ?1',
        arguments: [
          id,
          subtotal,
          taxAmount,
          discountAmount,
          totalAmount,
          updatedAt
        ]);
  }

  @override
  Future<void> deleteInvoiceById(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM invoices WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteInvoicesByCustomerId(String customerId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM invoices WHERE customer_id = ?1',
        arguments: [customerId]);
  }

  @override
  Future<void> deleteInvoicesByStatus(String status) async {
    await _queryAdapter.queryNoReturn('DELETE FROM invoices WHERE status = ?1',
        arguments: [status]);
  }

  @override
  Stream<List<InvoiceEntity>> watchAllInvoices() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM invoices ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => InvoiceEntity(
            id: row['id'] as String,
            invoiceNumber: row['invoice_number'] as String,
            customerId: row['customer_id'] as String,
            invoiceDate: row['invoice_date'] as int,
            dueDate: row['due_date'] as int?,
            status: row['status'] as String,
            subtotal: row['subtotal'] as int,
            taxAmount: row['tax_amount'] as int,
            discountAmount: row['discount_amount'] as int,
            totalAmount: row['total_amount'] as int,
            currencyCode: row['currency_code'] as String,
            paymentTerms: row['payment_terms'] as String?,
            notes: row['notes'] as String?,
            description: row['description'] as String?,
            isPaid: (row['is_paid'] as int) != 0,
            paidDate: row['paid_date'] as int?,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int),
        queryableName: 'invoices',
        isView: false);
  }

  @override
  Stream<InvoiceEntity?> watchInvoiceById(String id) {
    return _queryAdapter.queryStream('SELECT * FROM invoices WHERE id = ?1',
        mapper: (Map<String, Object?> row) => InvoiceEntity(
            id: row['id'] as String,
            invoiceNumber: row['invoice_number'] as String,
            customerId: row['customer_id'] as String,
            invoiceDate: row['invoice_date'] as int,
            dueDate: row['due_date'] as int?,
            status: row['status'] as String,
            subtotal: row['subtotal'] as int,
            taxAmount: row['tax_amount'] as int,
            discountAmount: row['discount_amount'] as int,
            totalAmount: row['total_amount'] as int,
            currencyCode: row['currency_code'] as String,
            paymentTerms: row['payment_terms'] as String?,
            notes: row['notes'] as String?,
            description: row['description'] as String?,
            isPaid: (row['is_paid'] as int) != 0,
            paidDate: row['paid_date'] as int?,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int),
        arguments: [id],
        queryableName: 'invoices',
        isView: false);
  }

  @override
  Stream<List<InvoiceEntity>> watchInvoicesByCustomerId(String customerId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM invoices WHERE customer_id = ?1 ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => InvoiceEntity(
            id: row['id'] as String,
            invoiceNumber: row['invoice_number'] as String,
            customerId: row['customer_id'] as String,
            invoiceDate: row['invoice_date'] as int,
            dueDate: row['due_date'] as int?,
            status: row['status'] as String,
            subtotal: row['subtotal'] as int,
            taxAmount: row['tax_amount'] as int,
            discountAmount: row['discount_amount'] as int,
            totalAmount: row['total_amount'] as int,
            currencyCode: row['currency_code'] as String,
            paymentTerms: row['payment_terms'] as String?,
            notes: row['notes'] as String?,
            description: row['description'] as String?,
            isPaid: (row['is_paid'] as int) != 0,
            paidDate: row['paid_date'] as int?,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int),
        arguments: [customerId],
        queryableName: 'invoices',
        isView: false);
  }

  @override
  Stream<List<InvoiceEntity>> watchInvoicesByStatus(String status) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM invoices WHERE status = ?1 ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => InvoiceEntity(
            id: row['id'] as String,
            invoiceNumber: row['invoice_number'] as String,
            customerId: row['customer_id'] as String,
            invoiceDate: row['invoice_date'] as int,
            dueDate: row['due_date'] as int?,
            status: row['status'] as String,
            subtotal: row['subtotal'] as int,
            taxAmount: row['tax_amount'] as int,
            discountAmount: row['discount_amount'] as int,
            totalAmount: row['total_amount'] as int,
            currencyCode: row['currency_code'] as String,
            paymentTerms: row['payment_terms'] as String?,
            notes: row['notes'] as String?,
            description: row['description'] as String?,
            isPaid: (row['is_paid'] as int) != 0,
            paidDate: row['paid_date'] as int?,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int),
        arguments: [status],
        queryableName: 'invoices',
        isView: false);
  }

  @override
  Stream<List<InvoiceEntity>> watchUnpaidInvoices() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM invoices WHERE is_paid = 0 ORDER BY due_date ASC',
        mapper: (Map<String, Object?> row) => InvoiceEntity(
            id: row['id'] as String,
            invoiceNumber: row['invoice_number'] as String,
            customerId: row['customer_id'] as String,
            invoiceDate: row['invoice_date'] as int,
            dueDate: row['due_date'] as int?,
            status: row['status'] as String,
            subtotal: row['subtotal'] as int,
            taxAmount: row['tax_amount'] as int,
            discountAmount: row['discount_amount'] as int,
            totalAmount: row['total_amount'] as int,
            currencyCode: row['currency_code'] as String,
            paymentTerms: row['payment_terms'] as String?,
            notes: row['notes'] as String?,
            description: row['description'] as String?,
            isPaid: (row['is_paid'] as int) != 0,
            paidDate: row['paid_date'] as int?,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int),
        queryableName: 'invoices',
        isView: false);
  }

  @override
  Future<int?> getTotalRevenue() async {
    return _queryAdapter.query(
        'SELECT SUM(total_amount) FROM invoices WHERE is_paid = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getCurrentMonthRevenue() async {
    return _queryAdapter.query(
        'SELECT SUM(total_amount)      FROM invoices      WHERE is_paid = 1      AND strftime(\'%Y-%m\', datetime(invoice_date / 1000, \'unixepoch\')) = strftime(\'%Y-%m\', \'now\')',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getPendingPaymentAmount() async {
    return _queryAdapter.query(
        'SELECT SUM(total_amount) FROM invoices WHERE is_paid = 0',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> insertInvoice(InvoiceEntity invoice) async {
    await _invoiceEntityInsertionAdapter.insert(
        invoice, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertInvoices(List<InvoiceEntity> invoices) async {
    await _invoiceEntityInsertionAdapter.insertList(
        invoices, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateInvoice(InvoiceEntity invoice) async {
    await _invoiceEntityUpdateAdapter.update(invoice, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteInvoice(InvoiceEntity invoice) async {
    await _invoiceEntityDeletionAdapter.delete(invoice);
  }
}

class _$InvoiceItemDao extends InvoiceItemDao {
  _$InvoiceItemDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _invoiceItemEntityInsertionAdapter = InsertionAdapter(
            database,
            'invoice_items',
            (InvoiceItemEntity item) => <String, Object?>{
                  'id': item.id,
                  'invoice_id': item.invoiceId,
                  'item_order': item.itemOrder,
                  'product_name': item.productName,
                  'description': item.description,
                  'quantity': item.quantity,
                  'unit': item.unit,
                  'unit_price': item.unitPrice,
                  'tax_rate': item.taxRate,
                  'tax_amount': item.taxAmount,
                  'line_total': item.lineTotal,
                  'created_at': item.createdAt
                },
            changeListener),
        _invoiceItemEntityUpdateAdapter = UpdateAdapter(
            database,
            'invoice_items',
            ['id'],
            (InvoiceItemEntity item) => <String, Object?>{
                  'id': item.id,
                  'invoice_id': item.invoiceId,
                  'item_order': item.itemOrder,
                  'product_name': item.productName,
                  'description': item.description,
                  'quantity': item.quantity,
                  'unit': item.unit,
                  'unit_price': item.unitPrice,
                  'tax_rate': item.taxRate,
                  'tax_amount': item.taxAmount,
                  'line_total': item.lineTotal,
                  'created_at': item.createdAt
                },
            changeListener),
        _invoiceItemEntityDeletionAdapter = DeletionAdapter(
            database,
            'invoice_items',
            ['id'],
            (InvoiceItemEntity item) => <String, Object?>{
                  'id': item.id,
                  'invoice_id': item.invoiceId,
                  'item_order': item.itemOrder,
                  'product_name': item.productName,
                  'description': item.description,
                  'quantity': item.quantity,
                  'unit': item.unit,
                  'unit_price': item.unitPrice,
                  'tax_rate': item.taxRate,
                  'tax_amount': item.taxAmount,
                  'line_total': item.lineTotal,
                  'created_at': item.createdAt
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<InvoiceItemEntity> _invoiceItemEntityInsertionAdapter;

  final UpdateAdapter<InvoiceItemEntity> _invoiceItemEntityUpdateAdapter;

  final DeletionAdapter<InvoiceItemEntity> _invoiceItemEntityDeletionAdapter;

  @override
  Future<List<InvoiceItemEntity>> getInvoiceItemsByInvoiceId(
      String invoiceId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM invoice_items WHERE invoice_id = ?1 ORDER BY item_order ASC',
        mapper: (Map<String, Object?> row) => InvoiceItemEntity(id: row['id'] as String, invoiceId: row['invoice_id'] as String, itemOrder: row['item_order'] as int, productName: row['product_name'] as String, description: row['description'] as String?, quantity: row['quantity'] as double, unit: row['unit'] as String?, unitPrice: row['unit_price'] as int, taxRate: row['tax_rate'] as double, taxAmount: row['tax_amount'] as int, lineTotal: row['line_total'] as int, createdAt: row['created_at'] as int),
        arguments: [invoiceId]);
  }

  @override
  Future<InvoiceItemEntity?> getInvoiceItemById(String id) async {
    return _queryAdapter.query('SELECT * FROM invoice_items WHERE id = ?1',
        mapper: (Map<String, Object?> row) => InvoiceItemEntity(
            id: row['id'] as String,
            invoiceId: row['invoice_id'] as String,
            itemOrder: row['item_order'] as int,
            productName: row['product_name'] as String,
            description: row['description'] as String?,
            quantity: row['quantity'] as double,
            unit: row['unit'] as String?,
            unitPrice: row['unit_price'] as int,
            taxRate: row['tax_rate'] as double,
            taxAmount: row['tax_amount'] as int,
            lineTotal: row['line_total'] as int,
            createdAt: row['created_at'] as int),
        arguments: [id]);
  }

  @override
  Future<int?> getItemCountByInvoiceId(String invoiceId) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM invoice_items WHERE invoice_id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [invoiceId]);
  }

  @override
  Future<void> updateInvoiceItemAmounts(
    String id,
    int unitPrice,
    int taxAmount,
    int lineTotal,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE invoice_items      SET unit_price = ?2,         tax_amount = ?3,         line_total = ?4     WHERE id = ?1',
        arguments: [id, unitPrice, taxAmount, lineTotal]);
  }

  @override
  Future<void> deleteInvoiceItemById(String id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM invoice_items WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteInvoiceItemsByInvoiceId(String invoiceId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM invoice_items WHERE invoice_id = ?1',
        arguments: [invoiceId]);
  }

  @override
  Stream<List<InvoiceItemEntity>> watchInvoiceItemsByInvoiceId(
      String invoiceId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM invoice_items WHERE invoice_id = ?1 ORDER BY item_order ASC',
        mapper: (Map<String, Object?> row) => InvoiceItemEntity(
            id: row['id'] as String,
            invoiceId: row['invoice_id'] as String,
            itemOrder: row['item_order'] as int,
            productName: row['product_name'] as String,
            description: row['description'] as String?,
            quantity: row['quantity'] as double,
            unit: row['unit'] as String?,
            unitPrice: row['unit_price'] as int,
            taxRate: row['tax_rate'] as double,
            taxAmount: row['tax_amount'] as int,
            lineTotal: row['line_total'] as int,
            createdAt: row['created_at'] as int),
        arguments: [invoiceId],
        queryableName: 'invoice_items',
        isView: false);
  }

  @override
  Stream<InvoiceItemEntity?> watchInvoiceItemById(String id) {
    return _queryAdapter.queryStream(
        'SELECT * FROM invoice_items WHERE id = ?1',
        mapper: (Map<String, Object?> row) => InvoiceItemEntity(
            id: row['id'] as String,
            invoiceId: row['invoice_id'] as String,
            itemOrder: row['item_order'] as int,
            productName: row['product_name'] as String,
            description: row['description'] as String?,
            quantity: row['quantity'] as double,
            unit: row['unit'] as String?,
            unitPrice: row['unit_price'] as int,
            taxRate: row['tax_rate'] as double,
            taxAmount: row['tax_amount'] as int,
            lineTotal: row['line_total'] as int,
            createdAt: row['created_at'] as int),
        arguments: [id],
        queryableName: 'invoice_items',
        isView: false);
  }

  @override
  Future<void> insertInvoiceItem(InvoiceItemEntity item) async {
    await _invoiceItemEntityInsertionAdapter.insert(
        item, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertInvoiceItems(List<InvoiceItemEntity> items) async {
    await _invoiceItemEntityInsertionAdapter.insertList(
        items, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateInvoiceItem(InvoiceItemEntity item) async {
    await _invoiceItemEntityUpdateAdapter.update(
        item, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteInvoiceItem(InvoiceItemEntity item) async {
    await _invoiceItemEntityDeletionAdapter.delete(item);
  }
}

class _$ProductDao extends ProductDao {
  _$ProductDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _productEntityInsertionAdapter = InsertionAdapter(
            database,
            'products',
            (ProductEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'sku': item.sku,
                  'barcode': item.barcode,
                  'category': item.category,
                  'unit_price': item.unitPrice,
                  'stock_quantity': item.stockQuantity,
                  'min_stock_level': item.minStockLevel,
                  'unit': item.unit,
                  'tax_rate': item.taxRate,
                  'currency': item.currency,
                  'is_active': item.isActive ? 1 : 0,
                  'image_url': item.imageUrl,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener),
        _productEntityUpdateAdapter = UpdateAdapter(
            database,
            'products',
            ['id'],
            (ProductEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'sku': item.sku,
                  'barcode': item.barcode,
                  'category': item.category,
                  'unit_price': item.unitPrice,
                  'stock_quantity': item.stockQuantity,
                  'min_stock_level': item.minStockLevel,
                  'unit': item.unit,
                  'tax_rate': item.taxRate,
                  'currency': item.currency,
                  'is_active': item.isActive ? 1 : 0,
                  'image_url': item.imageUrl,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener),
        _productEntityDeletionAdapter = DeletionAdapter(
            database,
            'products',
            ['id'],
            (ProductEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'sku': item.sku,
                  'barcode': item.barcode,
                  'category': item.category,
                  'unit_price': item.unitPrice,
                  'stock_quantity': item.stockQuantity,
                  'min_stock_level': item.minStockLevel,
                  'unit': item.unit,
                  'tax_rate': item.taxRate,
                  'currency': item.currency,
                  'is_active': item.isActive ? 1 : 0,
                  'image_url': item.imageUrl,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ProductEntity> _productEntityInsertionAdapter;

  final UpdateAdapter<ProductEntity> _productEntityUpdateAdapter;

  final DeletionAdapter<ProductEntity> _productEntityDeletionAdapter;

  @override
  Stream<List<ProductEntity>> getAllProducts() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM products ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            sku: row['sku'] as String?,
            barcode: row['barcode'] as String?,
            category: row['category'] as String?,
            unitPrice: row['unit_price'] as double,
            stockQuantity: row['stock_quantity'] as int,
            minStockLevel: row['min_stock_level'] as int,
            unit: row['unit'] as String,
            taxRate: row['tax_rate'] as double,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            imageUrl: row['image_url'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        queryableName: 'products',
        isView: false);
  }

  @override
  Stream<List<ProductEntity>> getActiveProducts() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM products WHERE is_active = 1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            sku: row['sku'] as String?,
            barcode: row['barcode'] as String?,
            category: row['category'] as String?,
            unitPrice: row['unit_price'] as double,
            stockQuantity: row['stock_quantity'] as int,
            minStockLevel: row['min_stock_level'] as int,
            unit: row['unit'] as String,
            taxRate: row['tax_rate'] as double,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            imageUrl: row['image_url'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        queryableName: 'products',
        isView: false);
  }

  @override
  Future<ProductEntity?> getProductById(int id) async {
    return _queryAdapter.query('SELECT * FROM products WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            sku: row['sku'] as String?,
            barcode: row['barcode'] as String?,
            category: row['category'] as String?,
            unitPrice: row['unit_price'] as double,
            stockQuantity: row['stock_quantity'] as int,
            minStockLevel: row['min_stock_level'] as int,
            unit: row['unit'] as String,
            taxRate: row['tax_rate'] as double,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            imageUrl: row['image_url'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<ProductEntity?> getProductBySku(String sku) async {
    return _queryAdapter.query('SELECT * FROM products WHERE sku = ?1',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            sku: row['sku'] as String?,
            barcode: row['barcode'] as String?,
            category: row['category'] as String?,
            unitPrice: row['unit_price'] as double,
            stockQuantity: row['stock_quantity'] as int,
            minStockLevel: row['min_stock_level'] as int,
            unit: row['unit'] as String,
            taxRate: row['tax_rate'] as double,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            imageUrl: row['image_url'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [sku]);
  }

  @override
  Future<ProductEntity?> getProductByBarcode(String barcode) async {
    return _queryAdapter.query('SELECT * FROM products WHERE barcode = ?1',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            sku: row['sku'] as String?,
            barcode: row['barcode'] as String?,
            category: row['category'] as String?,
            unitPrice: row['unit_price'] as double,
            stockQuantity: row['stock_quantity'] as int,
            minStockLevel: row['min_stock_level'] as int,
            unit: row['unit'] as String,
            taxRate: row['tax_rate'] as double,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            imageUrl: row['image_url'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [barcode]);
  }

  @override
  Stream<List<ProductEntity>> getProductsByCategory(String category) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM products WHERE category = ?1 AND is_active = 1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            sku: row['sku'] as String?,
            barcode: row['barcode'] as String?,
            category: row['category'] as String?,
            unitPrice: row['unit_price'] as double,
            stockQuantity: row['stock_quantity'] as int,
            minStockLevel: row['min_stock_level'] as int,
            unit: row['unit'] as String,
            taxRate: row['tax_rate'] as double,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            imageUrl: row['image_url'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [category],
        queryableName: 'products',
        isView: false);
  }

  @override
  Stream<List<ProductEntity>> getLowStockProducts() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM products WHERE stock_quantity <= min_stock_level AND is_active = 1 ORDER BY stock_quantity ASC',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            sku: row['sku'] as String?,
            barcode: row['barcode'] as String?,
            category: row['category'] as String?,
            unitPrice: row['unit_price'] as double,
            stockQuantity: row['stock_quantity'] as int,
            minStockLevel: row['min_stock_level'] as int,
            unit: row['unit'] as String,
            taxRate: row['tax_rate'] as double,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            imageUrl: row['image_url'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        queryableName: 'products',
        isView: false);
  }

  @override
  Stream<List<ProductEntity>> getOutOfStockProducts() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM products WHERE stock_quantity = 0 AND is_active = 1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            sku: row['sku'] as String?,
            barcode: row['barcode'] as String?,
            category: row['category'] as String?,
            unitPrice: row['unit_price'] as double,
            stockQuantity: row['stock_quantity'] as int,
            minStockLevel: row['min_stock_level'] as int,
            unit: row['unit'] as String,
            taxRate: row['tax_rate'] as double,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            imageUrl: row['image_url'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        queryableName: 'products',
        isView: false);
  }

  @override
  Stream<List<ProductEntity>> searchProducts(String query) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM products      WHERE (name LIKE \'%\' || ?1 || \'%\' OR             description LIKE \'%\' || ?1 || \'%\' OR             sku LIKE \'%\' || ?1 || \'%\' OR             barcode LIKE \'%\' || ?1 || \'%\')     AND is_active = 1     ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            sku: row['sku'] as String?,
            barcode: row['barcode'] as String?,
            category: row['category'] as String?,
            unitPrice: row['unit_price'] as double,
            stockQuantity: row['stock_quantity'] as int,
            minStockLevel: row['min_stock_level'] as int,
            unit: row['unit'] as String,
            taxRate: row['tax_rate'] as double,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            imageUrl: row['image_url'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [query],
        queryableName: 'products',
        isView: false);
  }

  @override
  Future<void> updateStockQuantity(
    int id,
    int quantity,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE products SET stock_quantity = ?2, updated_at = ?3 WHERE id = ?1',
        arguments: [id, quantity, updatedAt]);
  }

  @override
  Future<void> updateProductStatus(
    int id,
    int isActive,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE products SET is_active = ?2, updated_at = ?3 WHERE id = ?1',
        arguments: [id, isActive, updatedAt]);
  }

  @override
  Future<int?> getActiveProductCount() async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM products WHERE is_active = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<double?> getTotalStockValue() async {
    return _queryAdapter.query(
        'SELECT SUM(stock_quantity * unit_price) FROM products WHERE is_active = 1',
        mapper: (Map<String, Object?> row) => row.values.first as double);
  }

  @override
  Stream<List<String>> getCategories() {
    return _queryAdapter.queryListStream(
        'SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND category != \"\" AND is_active = 1 ORDER BY category ASC',
        mapper: (Map<String, Object?> row) => row.values.first as String,
        queryableName: 'products',
        isView: false);
  }

  @override
  Future<int> insertProduct(ProductEntity product) {
    return _productEntityInsertionAdapter.insertAndReturnId(
        product, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateProduct(ProductEntity product) {
    return _productEntityUpdateAdapter.updateAndReturnChangedRows(
        product, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteProduct(ProductEntity product) {
    return _productEntityDeletionAdapter.deleteAndReturnChangedRows(product);
  }
}

class _$ExpenseDao extends ExpenseDao {
  _$ExpenseDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _expenseEntityInsertionAdapter = InsertionAdapter(
            database,
            'expenses',
            (ExpenseEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'amount': item.amount,
                  'currency': item.currency,
                  'categoryId': item.categoryId,
                  'date': _dateTimeConverter.encode(item.date),
                  'status': item.status,
                  'paymentMethod': item.paymentMethod,
                  'receiptPath': item.receiptPath,
                  'notes': item.notes,
                  'createdAt': _dateTimeConverter.encode(item.createdAt),
                  'updatedAt': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener),
        _expenseEntityUpdateAdapter = UpdateAdapter(
            database,
            'expenses',
            ['id'],
            (ExpenseEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'amount': item.amount,
                  'currency': item.currency,
                  'categoryId': item.categoryId,
                  'date': _dateTimeConverter.encode(item.date),
                  'status': item.status,
                  'paymentMethod': item.paymentMethod,
                  'receiptPath': item.receiptPath,
                  'notes': item.notes,
                  'createdAt': _dateTimeConverter.encode(item.createdAt),
                  'updatedAt': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener),
        _expenseEntityDeletionAdapter = DeletionAdapter(
            database,
            'expenses',
            ['id'],
            (ExpenseEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'amount': item.amount,
                  'currency': item.currency,
                  'categoryId': item.categoryId,
                  'date': _dateTimeConverter.encode(item.date),
                  'status': item.status,
                  'paymentMethod': item.paymentMethod,
                  'receiptPath': item.receiptPath,
                  'notes': item.notes,
                  'createdAt': _dateTimeConverter.encode(item.createdAt),
                  'updatedAt': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ExpenseEntity> _expenseEntityInsertionAdapter;

  final UpdateAdapter<ExpenseEntity> _expenseEntityUpdateAdapter;

  final DeletionAdapter<ExpenseEntity> _expenseEntityDeletionAdapter;

  @override
  Stream<List<ExpenseEntity>> getAllExpenses() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM expenses ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => ExpenseEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['categoryId'] as int,
            date: _dateTimeConverter.decode(row['date'] as int),
            status: row['status'] as String,
            paymentMethod: row['paymentMethod'] as String?,
            receiptPath: row['receiptPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        queryableName: 'expenses',
        isView: false);
  }

  @override
  Stream<List<ExpenseEntity>> getActiveExpenses() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM expenses WHERE status = \"active\" ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => ExpenseEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['categoryId'] as int,
            date: _dateTimeConverter.decode(row['date'] as int),
            status: row['status'] as String,
            paymentMethod: row['paymentMethod'] as String?,
            receiptPath: row['receiptPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        queryableName: 'expenses',
        isView: false);
  }

  @override
  Future<ExpenseEntity?> getExpenseById(int id) async {
    return _queryAdapter.query('SELECT * FROM expenses WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ExpenseEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['categoryId'] as int,
            date: _dateTimeConverter.decode(row['date'] as int),
            status: row['status'] as String,
            paymentMethod: row['paymentMethod'] as String?,
            receiptPath: row['receiptPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        arguments: [id]);
  }

  @override
  Stream<List<ExpenseEntity>> getExpensesByCategory(int categoryId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM expenses WHERE categoryId = ?1 ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => ExpenseEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['categoryId'] as int,
            date: _dateTimeConverter.decode(row['date'] as int),
            status: row['status'] as String,
            paymentMethod: row['paymentMethod'] as String?,
            receiptPath: row['receiptPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        arguments: [categoryId],
        queryableName: 'expenses',
        isView: false);
  }

  @override
  Stream<List<ExpenseEntity>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM expenses WHERE date BETWEEN ?1 AND ?2 ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => ExpenseEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['categoryId'] as int,
            date: _dateTimeConverter.decode(row['date'] as int),
            status: row['status'] as String,
            paymentMethod: row['paymentMethod'] as String?,
            receiptPath: row['receiptPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        arguments: [
          _dateTimeConverter.encode(startDate),
          _dateTimeConverter.encode(endDate)
        ],
        queryableName: 'expenses',
        isView: false);
  }

  @override
  Stream<List<ExpenseEntity>> getExpensesByStatus(String status) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM expenses WHERE status = ?1 ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => ExpenseEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['categoryId'] as int,
            date: _dateTimeConverter.decode(row['date'] as int),
            status: row['status'] as String,
            paymentMethod: row['paymentMethod'] as String?,
            receiptPath: row['receiptPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        arguments: [status],
        queryableName: 'expenses',
        isView: false);
  }

  @override
  Stream<List<ExpenseEntity>> searchExpenses(String query) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM expenses      WHERE title LIKE \'%\' || ?1 || \'%\'      OR description LIKE \'%\' || ?1 || \'%\'     ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => ExpenseEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['categoryId'] as int,
            date: _dateTimeConverter.decode(row['date'] as int),
            status: row['status'] as String,
            paymentMethod: row['paymentMethod'] as String?,
            receiptPath: row['receiptPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        arguments: [query],
        queryableName: 'expenses',
        isView: false);
  }

  @override
  Future<double?> getTotalExpenseAmount() async {
    return _queryAdapter.query(
        'SELECT SUM(amount) FROM expenses WHERE status = \"active\"',
        mapper: (Map<String, Object?> row) => row.values.first as double);
  }

  @override
  Future<double?> getTotalAmountByCategory(int categoryId) async {
    return _queryAdapter.query(
        'SELECT SUM(amount) FROM expenses WHERE categoryId = ?1 AND status = \"active\"',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [categoryId]);
  }

  @override
  Future<double?> getTotalAmountByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _queryAdapter.query(
        'SELECT SUM(amount) FROM expenses WHERE date BETWEEN ?1 AND ?2 AND status = \"active\"',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [
          _dateTimeConverter.encode(startDate),
          _dateTimeConverter.encode(endDate)
        ]);
  }

  @override
  Future<int?> deleteExpenseById(int id) async {
    return _queryAdapter.query('DELETE FROM expenses WHERE id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [id]);
  }

  @override
  Future<int?> deleteAllExpenses() async {
    return _queryAdapter.query('DELETE FROM expenses',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> insertExpense(ExpenseEntity expense) {
    return _expenseEntityInsertionAdapter.insertAndReturnId(
        expense, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateExpense(ExpenseEntity expense) {
    return _expenseEntityUpdateAdapter.updateAndReturnChangedRows(
        expense, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteExpense(ExpenseEntity expense) {
    return _expenseEntityDeletionAdapter.deleteAndReturnChangedRows(expense);
  }
}

class _$ExpenseCategoryDao extends ExpenseCategoryDao {
  _$ExpenseCategoryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _expenseCategoryEntityInsertionAdapter = InsertionAdapter(
            database,
            'expense_categories',
            (ExpenseCategoryEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'color': item.color,
                  'icon': item.icon,
                  'isActive': item.isActive ? 1 : 0,
                  'isDefault': item.isDefault ? 1 : 0,
                  'sortOrder': item.sortOrder,
                  'createdAt': _dateTimeConverter.encode(item.createdAt),
                  'updatedAt': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener),
        _expenseCategoryEntityUpdateAdapter = UpdateAdapter(
            database,
            'expense_categories',
            ['id'],
            (ExpenseCategoryEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'color': item.color,
                  'icon': item.icon,
                  'isActive': item.isActive ? 1 : 0,
                  'isDefault': item.isDefault ? 1 : 0,
                  'sortOrder': item.sortOrder,
                  'createdAt': _dateTimeConverter.encode(item.createdAt),
                  'updatedAt': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener),
        _expenseCategoryEntityDeletionAdapter = DeletionAdapter(
            database,
            'expense_categories',
            ['id'],
            (ExpenseCategoryEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'color': item.color,
                  'icon': item.icon,
                  'isActive': item.isActive ? 1 : 0,
                  'isDefault': item.isDefault ? 1 : 0,
                  'sortOrder': item.sortOrder,
                  'createdAt': _dateTimeConverter.encode(item.createdAt),
                  'updatedAt': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ExpenseCategoryEntity>
      _expenseCategoryEntityInsertionAdapter;

  final UpdateAdapter<ExpenseCategoryEntity>
      _expenseCategoryEntityUpdateAdapter;

  final DeletionAdapter<ExpenseCategoryEntity>
      _expenseCategoryEntityDeletionAdapter;

  @override
  Stream<List<ExpenseCategoryEntity>> getAllCategories() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM expense_categories ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ExpenseCategoryEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            color: row['color'] as String?,
            icon: row['icon'] as String?,
            isActive: (row['isActive'] as int) != 0,
            isDefault: (row['isDefault'] as int) != 0,
            sortOrder: row['sortOrder'] as int,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        queryableName: 'expense_categories',
        isView: false);
  }

  @override
  Stream<List<ExpenseCategoryEntity>> getActiveCategories() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM expense_categories WHERE isActive = 1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ExpenseCategoryEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            color: row['color'] as String?,
            icon: row['icon'] as String?,
            isActive: (row['isActive'] as int) != 0,
            isDefault: (row['isDefault'] as int) != 0,
            sortOrder: row['sortOrder'] as int,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        queryableName: 'expense_categories',
        isView: false);
  }

  @override
  Future<ExpenseCategoryEntity?> getCategoryById(int id) async {
    return _queryAdapter.query('SELECT * FROM expense_categories WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ExpenseCategoryEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            color: row['color'] as String?,
            icon: row['icon'] as String?,
            isActive: (row['isActive'] as int) != 0,
            isDefault: (row['isDefault'] as int) != 0,
            sortOrder: row['sortOrder'] as int,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        arguments: [id]);
  }

  @override
  Stream<List<ExpenseCategoryEntity>> getDefaultCategories() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM expense_categories WHERE isDefault = 1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ExpenseCategoryEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            color: row['color'] as String?,
            icon: row['icon'] as String?,
            isActive: (row['isActive'] as int) != 0,
            isDefault: (row['isDefault'] as int) != 0,
            sortOrder: row['sortOrder'] as int,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        queryableName: 'expense_categories',
        isView: false);
  }

  @override
  Future<int?> deleteCategoryById(int id) async {
    return _queryAdapter.query('DELETE FROM expense_categories WHERE id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [id]);
  }

  @override
  Future<int?> deleteAllCategories() async {
    return _queryAdapter.query('DELETE FROM expense_categories',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Stream<List<ExpenseCategoryEntity>> searchCategories(String query) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM expense_categories WHERE name LIKE \"%\" || ?1 || \"%\" ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ExpenseCategoryEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            color: row['color'] as String?,
            icon: row['icon'] as String?,
            isActive: (row['isActive'] as int) != 0,
            isDefault: (row['isDefault'] as int) != 0,
            sortOrder: row['sortOrder'] as int,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        arguments: [query],
        queryableName: 'expense_categories',
        isView: false);
  }

  @override
  Future<int?> getActiveCategoryCount() async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM expense_categories WHERE isActive = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> insertCategory(ExpenseCategoryEntity category) {
    return _expenseCategoryEntityInsertionAdapter.insertAndReturnId(
        category, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateCategory(ExpenseCategoryEntity category) {
    return _expenseCategoryEntityUpdateAdapter.updateAndReturnChangedRows(
        category, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteCategory(ExpenseCategoryEntity category) {
    return _expenseCategoryEntityDeletionAdapter
        .deleteAndReturnChangedRows(category);
  }
}

class _$IncomeDao extends IncomeDao {
  _$IncomeDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _incomeEntityInsertionAdapter = InsertionAdapter(
            database,
            'incomes',
            (IncomeEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'amount': item.amount,
                  'currency': item.currency,
                  'category_id': item.categoryId,
                  'category_name': item.categoryName,
                  'income_date': _dateTimeConverter.encode(item.incomeDate),
                  'customer_id': item.customerId,
                  'customer_name': item.customerName,
                  'payment_method': item.paymentMethod,
                  'invoice_number': item.invoiceNumber,
                  'status': item.status,
                  'notes': item.notes,
                  'attachments': item.attachments,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener),
        _incomeEntityUpdateAdapter = UpdateAdapter(
            database,
            'incomes',
            ['id'],
            (IncomeEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'amount': item.amount,
                  'currency': item.currency,
                  'category_id': item.categoryId,
                  'category_name': item.categoryName,
                  'income_date': _dateTimeConverter.encode(item.incomeDate),
                  'customer_id': item.customerId,
                  'customer_name': item.customerName,
                  'payment_method': item.paymentMethod,
                  'invoice_number': item.invoiceNumber,
                  'status': item.status,
                  'notes': item.notes,
                  'attachments': item.attachments,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener),
        _incomeEntityDeletionAdapter = DeletionAdapter(
            database,
            'incomes',
            ['id'],
            (IncomeEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'amount': item.amount,
                  'currency': item.currency,
                  'category_id': item.categoryId,
                  'category_name': item.categoryName,
                  'income_date': _dateTimeConverter.encode(item.incomeDate),
                  'customer_id': item.customerId,
                  'customer_name': item.customerName,
                  'payment_method': item.paymentMethod,
                  'invoice_number': item.invoiceNumber,
                  'status': item.status,
                  'notes': item.notes,
                  'attachments': item.attachments,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<IncomeEntity> _incomeEntityInsertionAdapter;

  final UpdateAdapter<IncomeEntity> _incomeEntityUpdateAdapter;

  final DeletionAdapter<IncomeEntity> _incomeEntityDeletionAdapter;

  @override
  Stream<List<IncomeEntity>> getAllIncomes() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM incomes ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => IncomeEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['category_id'] as String,
            categoryName: row['category_name'] as String,
            incomeDate: _dateTimeConverter.decode(row['income_date'] as int),
            customerId: row['customer_id'] as String?,
            customerName: row['customer_name'] as String?,
            paymentMethod: row['payment_method'] as String,
            invoiceNumber: row['invoice_number'] as String?,
            status: row['status'] as String,
            notes: row['notes'] as String?,
            attachments: row['attachments'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        queryableName: 'incomes',
        isView: false);
  }

  @override
  Stream<List<IncomeEntity>> getActiveIncomes() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM incomes WHERE status != \"deleted\" ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => IncomeEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['category_id'] as String,
            categoryName: row['category_name'] as String,
            incomeDate: _dateTimeConverter.decode(row['income_date'] as int),
            customerId: row['customer_id'] as String?,
            customerName: row['customer_name'] as String?,
            paymentMethod: row['payment_method'] as String,
            invoiceNumber: row['invoice_number'] as String?,
            status: row['status'] as String,
            notes: row['notes'] as String?,
            attachments: row['attachments'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        queryableName: 'incomes',
        isView: false);
  }

  @override
  Future<IncomeEntity?> getIncomeById(int id) async {
    return _queryAdapter.query('SELECT * FROM incomes WHERE id = ?1',
        mapper: (Map<String, Object?> row) => IncomeEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['category_id'] as String,
            categoryName: row['category_name'] as String,
            incomeDate: _dateTimeConverter.decode(row['income_date'] as int),
            customerId: row['customer_id'] as String?,
            customerName: row['customer_name'] as String?,
            paymentMethod: row['payment_method'] as String,
            invoiceNumber: row['invoice_number'] as String?,
            status: row['status'] as String,
            notes: row['notes'] as String?,
            attachments: row['attachments'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<IncomeEntity?> getIncomeByStringId(String id) async {
    return _queryAdapter.query('SELECT * FROM incomes WHERE id = ?1',
        mapper: (Map<String, Object?> row) => IncomeEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['category_id'] as String,
            categoryName: row['category_name'] as String,
            incomeDate: _dateTimeConverter.decode(row['income_date'] as int),
            customerId: row['customer_id'] as String?,
            customerName: row['customer_name'] as String?,
            paymentMethod: row['payment_method'] as String,
            invoiceNumber: row['invoice_number'] as String?,
            status: row['status'] as String,
            notes: row['notes'] as String?,
            attachments: row['attachments'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Stream<List<IncomeEntity>> getIncomesByCategory(String categoryId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM incomes WHERE category_id = ?1 ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => IncomeEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['category_id'] as String,
            categoryName: row['category_name'] as String,
            incomeDate: _dateTimeConverter.decode(row['income_date'] as int),
            customerId: row['customer_id'] as String?,
            customerName: row['customer_name'] as String?,
            paymentMethod: row['payment_method'] as String,
            invoiceNumber: row['invoice_number'] as String?,
            status: row['status'] as String,
            notes: row['notes'] as String?,
            attachments: row['attachments'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [categoryId],
        queryableName: 'incomes',
        isView: false);
  }

  @override
  Stream<List<IncomeEntity>> getIncomesByStatus(String status) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM incomes WHERE status = ?1 ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => IncomeEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['category_id'] as String,
            categoryName: row['category_name'] as String,
            incomeDate: _dateTimeConverter.decode(row['income_date'] as int),
            customerId: row['customer_id'] as String?,
            customerName: row['customer_name'] as String?,
            paymentMethod: row['payment_method'] as String,
            invoiceNumber: row['invoice_number'] as String?,
            status: row['status'] as String,
            notes: row['notes'] as String?,
            attachments: row['attachments'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [status],
        queryableName: 'incomes',
        isView: false);
  }

  @override
  Stream<List<IncomeEntity>> getIncomesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM incomes WHERE created_at BETWEEN ?1 AND ?2 ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => IncomeEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['category_id'] as String,
            categoryName: row['category_name'] as String,
            incomeDate: _dateTimeConverter.decode(row['income_date'] as int),
            customerId: row['customer_id'] as String?,
            customerName: row['customer_name'] as String?,
            paymentMethod: row['payment_method'] as String,
            invoiceNumber: row['invoice_number'] as String?,
            status: row['status'] as String,
            notes: row['notes'] as String?,
            attachments: row['attachments'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [
          _dateTimeConverter.encode(startDate),
          _dateTimeConverter.encode(endDate)
        ],
        queryableName: 'incomes',
        isView: false);
  }

  @override
  Stream<List<IncomeEntity>> searchIncomes(String query) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM incomes      WHERE title LIKE ?1      OR description LIKE ?1      OR customer_name LIKE ?1      OR invoice_number LIKE ?1     ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => IncomeEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String?,
            amount: row['amount'] as double,
            currency: row['currency'] as String,
            categoryId: row['category_id'] as String,
            categoryName: row['category_name'] as String,
            incomeDate: _dateTimeConverter.decode(row['income_date'] as int),
            customerId: row['customer_id'] as String?,
            customerName: row['customer_name'] as String?,
            paymentMethod: row['payment_method'] as String,
            invoiceNumber: row['invoice_number'] as String?,
            status: row['status'] as String,
            notes: row['notes'] as String?,
            attachments: row['attachments'] as String?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [query],
        queryableName: 'incomes',
        isView: false);
  }

  @override
  Future<int?> deleteIncomeById(int id) async {
    return _queryAdapter.query('DELETE FROM incomes WHERE id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [id]);
  }

  @override
  Future<int?> deleteIncomeByStringId(String id) async {
    return _queryAdapter.query('DELETE FROM incomes WHERE id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [id]);
  }

  @override
  Future<double?> getTotalIncome() async {
    return _queryAdapter.query(
        'SELECT SUM(amount) FROM incomes WHERE status = \"paid\"',
        mapper: (Map<String, Object?> row) => row.values.first as double);
  }

  @override
  Future<double?> getTotalIncomeByCategory(String categoryId) async {
    return _queryAdapter.query(
        'SELECT SUM(amount) FROM incomes WHERE category_id = ?1 AND status = \"paid\"',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [categoryId]);
  }

  @override
  Future<double?> getTotalIncomeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _queryAdapter.query(
        'SELECT SUM(amount) FROM incomes WHERE created_at BETWEEN ?1 AND ?2 AND status = \"paid\"',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [
          _dateTimeConverter.encode(startDate),
          _dateTimeConverter.encode(endDate)
        ]);
  }

  @override
  Future<int?> getIncomeCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM incomes',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getIncomeCountByStatus(String status) async {
    return _queryAdapter.query('SELECT COUNT(*) FROM incomes WHERE status = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [status]);
  }

  @override
  Future<int> insertIncome(IncomeEntity income) {
    return _incomeEntityInsertionAdapter.insertAndReturnId(
        income, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateIncome(IncomeEntity income) {
    return _incomeEntityUpdateAdapter.updateAndReturnChangedRows(
        income, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteIncome(IncomeEntity income) {
    return _incomeEntityDeletionAdapter.deleteAndReturnChangedRows(income);
  }
}

class _$IncomeCategoryDao extends IncomeCategoryDao {
  _$IncomeCategoryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _incomeCategoryEntityInsertionAdapter = InsertionAdapter(
            database,
            'income_categories',
            (IncomeCategoryEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'color': item.color,
                  'icon': item.icon,
                  'is_active': item.isActive ? 1 : 0,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener),
        _incomeCategoryEntityUpdateAdapter = UpdateAdapter(
            database,
            'income_categories',
            ['id'],
            (IncomeCategoryEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'color': item.color,
                  'icon': item.icon,
                  'is_active': item.isActive ? 1 : 0,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener),
        _incomeCategoryEntityDeletionAdapter = DeletionAdapter(
            database,
            'income_categories',
            ['id'],
            (IncomeCategoryEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'color': item.color,
                  'icon': item.icon,
                  'is_active': item.isActive ? 1 : 0,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<IncomeCategoryEntity>
      _incomeCategoryEntityInsertionAdapter;

  final UpdateAdapter<IncomeCategoryEntity> _incomeCategoryEntityUpdateAdapter;

  final DeletionAdapter<IncomeCategoryEntity>
      _incomeCategoryEntityDeletionAdapter;

  @override
  Stream<List<IncomeCategoryEntity>> getAllCategories() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM income_categories ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => IncomeCategoryEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            color: row['color'] as String?,
            icon: row['icon'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        queryableName: 'income_categories',
        isView: false);
  }

  @override
  Stream<List<IncomeCategoryEntity>> getActiveCategories() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM income_categories WHERE is_active = 1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => IncomeCategoryEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            color: row['color'] as String?,
            icon: row['icon'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        queryableName: 'income_categories',
        isView: false);
  }

  @override
  Future<IncomeCategoryEntity?> getCategoryById(int id) async {
    return _queryAdapter.query('SELECT * FROM income_categories WHERE id = ?1',
        mapper: (Map<String, Object?> row) => IncomeCategoryEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            description: row['description'] as String?,
            color: row['color'] as String?,
            icon: row['icon'] as String?,
            isActive: (row['is_active'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<int?> deleteCategoryById(int id) async {
    return _queryAdapter.query('DELETE FROM income_categories WHERE id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [id]);
  }

  @override
  Future<int?> getCategoryCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM income_categories',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getActiveCategoryCount() async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM income_categories WHERE is_active = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> insertCategory(IncomeCategoryEntity category) {
    return _incomeCategoryEntityInsertionAdapter.insertAndReturnId(
        category, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateCategory(IncomeCategoryEntity category) {
    return _incomeCategoryEntityUpdateAdapter.updateAndReturnChangedRows(
        category, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteCategory(IncomeCategoryEntity category) {
    return _incomeCategoryEntityDeletionAdapter
        .deleteAndReturnChangedRows(category);
  }
}

class _$WarehouseDao extends WarehouseDao {
  _$WarehouseDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _warehouseEntityInsertionAdapter = InsertionAdapter(
            database,
            'warehouses',
            (WarehouseEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'code': item.code,
                  'description': item.description,
                  'address': item.address,
                  'phone': item.phone,
                  'email': item.email,
                  'manager': item.manager,
                  'capacity': item.capacity,
                  'capacity_unit': item.capacityUnit,
                  'currency': item.currency,
                  'is_active': item.isActive ? 1 : 0,
                  'is_default': item.isDefault ? 1 : 0,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _warehouseEntityUpdateAdapter = UpdateAdapter(
            database,
            'warehouses',
            ['id'],
            (WarehouseEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'code': item.code,
                  'description': item.description,
                  'address': item.address,
                  'phone': item.phone,
                  'email': item.email,
                  'manager': item.manager,
                  'capacity': item.capacity,
                  'capacity_unit': item.capacityUnit,
                  'currency': item.currency,
                  'is_active': item.isActive ? 1 : 0,
                  'is_default': item.isDefault ? 1 : 0,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _warehouseEntityDeletionAdapter = DeletionAdapter(
            database,
            'warehouses',
            ['id'],
            (WarehouseEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'code': item.code,
                  'description': item.description,
                  'address': item.address,
                  'phone': item.phone,
                  'email': item.email,
                  'manager': item.manager,
                  'capacity': item.capacity,
                  'capacity_unit': item.capacityUnit,
                  'currency': item.currency,
                  'is_active': item.isActive ? 1 : 0,
                  'is_default': item.isDefault ? 1 : 0,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<WarehouseEntity> _warehouseEntityInsertionAdapter;

  final UpdateAdapter<WarehouseEntity> _warehouseEntityUpdateAdapter;

  final DeletionAdapter<WarehouseEntity> _warehouseEntityDeletionAdapter;

  @override
  Future<List<WarehouseEntity>> getAllWarehouses() async {
    return _queryAdapter.queryList('SELECT * FROM warehouses ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => WarehouseEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            code: row['code'] as String?,
            description: row['description'] as String?,
            address: row['address'] as String?,
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            manager: row['manager'] as String?,
            capacity: row['capacity'] as double?,
            capacityUnit: row['capacity_unit'] as String?,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            isDefault: (row['is_default'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<List<WarehouseEntity>> getActiveWarehouses() async {
    return _queryAdapter.queryList(
        'SELECT * FROM warehouses WHERE is_active = 1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => WarehouseEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            code: row['code'] as String?,
            description: row['description'] as String?,
            address: row['address'] as String?,
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            manager: row['manager'] as String?,
            capacity: row['capacity'] as double?,
            capacityUnit: row['capacity_unit'] as String?,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            isDefault: (row['is_default'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<WarehouseEntity?> getDefaultWarehouse() async {
    return _queryAdapter.query(
        'SELECT * FROM warehouses WHERE is_default = 1 LIMIT 1',
        mapper: (Map<String, Object?> row) => WarehouseEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            code: row['code'] as String?,
            description: row['description'] as String?,
            address: row['address'] as String?,
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            manager: row['manager'] as String?,
            capacity: row['capacity'] as double?,
            capacityUnit: row['capacity_unit'] as String?,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            isDefault: (row['is_default'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<WarehouseEntity?> getWarehouseById(int id) async {
    return _queryAdapter.query('SELECT * FROM warehouses WHERE id = ?1',
        mapper: (Map<String, Object?> row) => WarehouseEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            code: row['code'] as String?,
            description: row['description'] as String?,
            address: row['address'] as String?,
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            manager: row['manager'] as String?,
            capacity: row['capacity'] as double?,
            capacityUnit: row['capacity_unit'] as String?,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            isDefault: (row['is_default'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<WarehouseEntity?> getWarehouseByCode(String code) async {
    return _queryAdapter.query('SELECT * FROM warehouses WHERE code = ?1',
        mapper: (Map<String, Object?> row) => WarehouseEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            code: row['code'] as String?,
            description: row['description'] as String?,
            address: row['address'] as String?,
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            manager: row['manager'] as String?,
            capacity: row['capacity'] as double?,
            capacityUnit: row['capacity_unit'] as String?,
            currency: row['currency'] as String,
            isActive: (row['is_active'] as int) != 0,
            isDefault: (row['is_default'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [code]);
  }

  @override
  Future<int?> getWarehouseCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM warehouses',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getActiveWarehouseCount() async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM warehouses WHERE is_active = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> insertWarehouse(WarehouseEntity warehouse) {
    return _warehouseEntityInsertionAdapter.insertAndReturnId(
        warehouse, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateWarehouse(WarehouseEntity warehouse) async {
    await _warehouseEntityUpdateAdapter.update(
        warehouse, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteWarehouse(WarehouseEntity warehouse) async {
    await _warehouseEntityDeletionAdapter.delete(warehouse);
  }
}

class _$StockDao extends StockDao {
  _$StockDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _stockEntityInsertionAdapter = InsertionAdapter(
            database,
            'stocks',
            (StockEntity item) => <String, Object?>{
                  'id': item.id,
                  'productId': item.productId,
                  'warehouseId': item.warehouseId,
                  'quantity': item.quantity,
                  'minimumQuantity': item.minimumQuantity,
                  'maximumQuantity': item.maximumQuantity,
                  'unit': item.unit,
                  'currency': item.currency,
                  'unitPrice': item.unitPrice,
                  'location': item.location,
                  'notes': item.notes,
                  'isActive': item.isActive ? 1 : 0,
                  'createdAt': _dateTimeConverter.encode(item.createdAt),
                  'updatedAt': _dateTimeConverter.encode(item.updatedAt)
                }),
        _stockEntityUpdateAdapter = UpdateAdapter(
            database,
            'stocks',
            ['id'],
            (StockEntity item) => <String, Object?>{
                  'id': item.id,
                  'productId': item.productId,
                  'warehouseId': item.warehouseId,
                  'quantity': item.quantity,
                  'minimumQuantity': item.minimumQuantity,
                  'maximumQuantity': item.maximumQuantity,
                  'unit': item.unit,
                  'currency': item.currency,
                  'unitPrice': item.unitPrice,
                  'location': item.location,
                  'notes': item.notes,
                  'isActive': item.isActive ? 1 : 0,
                  'createdAt': _dateTimeConverter.encode(item.createdAt),
                  'updatedAt': _dateTimeConverter.encode(item.updatedAt)
                }),
        _stockEntityDeletionAdapter = DeletionAdapter(
            database,
            'stocks',
            ['id'],
            (StockEntity item) => <String, Object?>{
                  'id': item.id,
                  'productId': item.productId,
                  'warehouseId': item.warehouseId,
                  'quantity': item.quantity,
                  'minimumQuantity': item.minimumQuantity,
                  'maximumQuantity': item.maximumQuantity,
                  'unit': item.unit,
                  'currency': item.currency,
                  'unitPrice': item.unitPrice,
                  'location': item.location,
                  'notes': item.notes,
                  'isActive': item.isActive ? 1 : 0,
                  'createdAt': _dateTimeConverter.encode(item.createdAt),
                  'updatedAt': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<StockEntity> _stockEntityInsertionAdapter;

  final UpdateAdapter<StockEntity> _stockEntityUpdateAdapter;

  final DeletionAdapter<StockEntity> _stockEntityDeletionAdapter;

  @override
  Future<List<StockEntity>> getAllStocks() async {
    return _queryAdapter.queryList(
        'SELECT * FROM stocks ORDER BY updatedAt DESC',
        mapper: (Map<String, Object?> row) => StockEntity(
            id: row['id'] as int,
            productId: row['productId'] as int,
            warehouseId: row['warehouseId'] as int,
            quantity: row['quantity'] as double,
            minimumQuantity: row['minimumQuantity'] as double,
            maximumQuantity: row['maximumQuantity'] as double,
            unit: row['unit'] as String,
            currency: row['currency'] as String,
            unitPrice: row['unitPrice'] as double,
            location: row['location'] as String?,
            notes: row['notes'] as String?,
            isActive: (row['isActive'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)));
  }

  @override
  Future<List<StockEntity>> getActiveStocks() async {
    return _queryAdapter.queryList(
        'SELECT * FROM stocks WHERE isActive = 1 ORDER BY updatedAt DESC',
        mapper: (Map<String, Object?> row) => StockEntity(
            id: row['id'] as int,
            productId: row['productId'] as int,
            warehouseId: row['warehouseId'] as int,
            quantity: row['quantity'] as double,
            minimumQuantity: row['minimumQuantity'] as double,
            maximumQuantity: row['maximumQuantity'] as double,
            unit: row['unit'] as String,
            currency: row['currency'] as String,
            unitPrice: row['unitPrice'] as double,
            location: row['location'] as String?,
            notes: row['notes'] as String?,
            isActive: (row['isActive'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)));
  }

  @override
  Future<StockEntity?> getStockById(int id) async {
    return _queryAdapter.query('SELECT * FROM stocks WHERE id = ?1',
        mapper: (Map<String, Object?> row) => StockEntity(
            id: row['id'] as int,
            productId: row['productId'] as int,
            warehouseId: row['warehouseId'] as int,
            quantity: row['quantity'] as double,
            minimumQuantity: row['minimumQuantity'] as double,
            maximumQuantity: row['maximumQuantity'] as double,
            unit: row['unit'] as String,
            currency: row['currency'] as String,
            unitPrice: row['unitPrice'] as double,
            location: row['location'] as String?,
            notes: row['notes'] as String?,
            isActive: (row['isActive'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        arguments: [id]);
  }

  @override
  Future<List<StockEntity>> getStocksByProductId(int productId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM stocks WHERE productId = ?1 AND isActive = 1',
        mapper: (Map<String, Object?> row) => StockEntity(
            id: row['id'] as int,
            productId: row['productId'] as int,
            warehouseId: row['warehouseId'] as int,
            quantity: row['quantity'] as double,
            minimumQuantity: row['minimumQuantity'] as double,
            maximumQuantity: row['maximumQuantity'] as double,
            unit: row['unit'] as String,
            currency: row['currency'] as String,
            unitPrice: row['unitPrice'] as double,
            location: row['location'] as String?,
            notes: row['notes'] as String?,
            isActive: (row['isActive'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        arguments: [productId]);
  }

  @override
  Future<List<StockEntity>> getStocksByWarehouseId(int warehouseId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM stocks WHERE warehouseId = ?1 AND isActive = 1',
        mapper: (Map<String, Object?> row) => StockEntity(
            id: row['id'] as int,
            productId: row['productId'] as int,
            warehouseId: row['warehouseId'] as int,
            quantity: row['quantity'] as double,
            minimumQuantity: row['minimumQuantity'] as double,
            maximumQuantity: row['maximumQuantity'] as double,
            unit: row['unit'] as String,
            currency: row['currency'] as String,
            unitPrice: row['unitPrice'] as double,
            location: row['location'] as String?,
            notes: row['notes'] as String?,
            isActive: (row['isActive'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        arguments: [warehouseId]);
  }

  @override
  Future<StockEntity?> getStockByProductAndWarehouse(
    int productId,
    int warehouseId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM stocks WHERE productId = ?1 AND warehouseId = ?2',
        mapper: (Map<String, Object?> row) => StockEntity(
            id: row['id'] as int,
            productId: row['productId'] as int,
            warehouseId: row['warehouseId'] as int,
            quantity: row['quantity'] as double,
            minimumQuantity: row['minimumQuantity'] as double,
            maximumQuantity: row['maximumQuantity'] as double,
            unit: row['unit'] as String,
            currency: row['currency'] as String,
            unitPrice: row['unitPrice'] as double,
            location: row['location'] as String?,
            notes: row['notes'] as String?,
            isActive: (row['isActive'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)),
        arguments: [productId, warehouseId]);
  }

  @override
  Future<List<StockEntity>> getLowStocks() async {
    return _queryAdapter.queryList(
        'SELECT * FROM stocks WHERE quantity <= minimumQuantity AND isActive = 1',
        mapper: (Map<String, Object?> row) => StockEntity(
            id: row['id'] as int,
            productId: row['productId'] as int,
            warehouseId: row['warehouseId'] as int,
            quantity: row['quantity'] as double,
            minimumQuantity: row['minimumQuantity'] as double,
            maximumQuantity: row['maximumQuantity'] as double,
            unit: row['unit'] as String,
            currency: row['currency'] as String,
            unitPrice: row['unitPrice'] as double,
            location: row['location'] as String?,
            notes: row['notes'] as String?,
            isActive: (row['isActive'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)));
  }

  @override
  Future<List<StockEntity>> getOverstockedItems() async {
    return _queryAdapter.queryList(
        'SELECT * FROM stocks WHERE quantity >= maximumQuantity AND isActive = 1',
        mapper: (Map<String, Object?> row) => StockEntity(
            id: row['id'] as int,
            productId: row['productId'] as int,
            warehouseId: row['warehouseId'] as int,
            quantity: row['quantity'] as double,
            minimumQuantity: row['minimumQuantity'] as double,
            maximumQuantity: row['maximumQuantity'] as double,
            unit: row['unit'] as String,
            currency: row['currency'] as String,
            unitPrice: row['unitPrice'] as double,
            location: row['location'] as String?,
            notes: row['notes'] as String?,
            isActive: (row['isActive'] as int) != 0,
            createdAt: _dateTimeConverter.decode(row['createdAt'] as int),
            updatedAt: _dateTimeConverter.decode(row['updatedAt'] as int)));
  }

  @override
  Future<int?> getStockCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM stocks',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getActiveStockCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM stocks WHERE isActive = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getLowStockCount() async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM stocks WHERE quantity <= minimumQuantity AND isActive = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<double?> getTotalStockValue() async {
    return _queryAdapter.query(
        'SELECT SUM(quantity * unitPrice) FROM stocks WHERE isActive = 1',
        mapper: (Map<String, Object?> row) => row.values.first as double);
  }

  @override
  Future<void> deleteStockById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM stocks WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteStocksByProductId(int productId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM stocks WHERE productId = ?1',
        arguments: [productId]);
  }

  @override
  Future<void> deleteStocksByWarehouseId(int warehouseId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM stocks WHERE warehouseId = ?1',
        arguments: [warehouseId]);
  }

  @override
  Future<void> updateStockQuantity(
    int id,
    double quantity,
    DateTime updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE stocks SET quantity = ?2, updatedAt = ?3 WHERE id = ?1',
        arguments: [id, quantity, _dateTimeConverter.encode(updatedAt)]);
  }

  @override
  Future<void> updateStockPrice(
    int id,
    double unitPrice,
    DateTime updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE stocks SET unitPrice = ?2, updatedAt = ?3 WHERE id = ?1',
        arguments: [id, unitPrice, _dateTimeConverter.encode(updatedAt)]);
  }

  @override
  Future<int> insertStock(StockEntity stock) {
    return _stockEntityInsertionAdapter.insertAndReturnId(
        stock, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateStock(StockEntity stock) async {
    await _stockEntityUpdateAdapter.update(stock, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteStock(StockEntity stock) async {
    await _stockEntityDeletionAdapter.delete(stock);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
