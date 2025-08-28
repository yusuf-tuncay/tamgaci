// ========== lib/features/customers/data/repositories/customer_repository_impl.dart ==========

import 'package:uuid/uuid.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../../../core/database/tamgaci_database.dart';
import '../models/customer_entity.dart';

/// Müşteri repository implementasyonu - Data katmanı
class CustomerRepositoryImpl implements CustomerRepository {
  final TamgaciDatabase _database;
  final Uuid _uuid = const Uuid();

  CustomerRepositoryImpl(this._database);

  @override
  Future<String> createCustomer(Customer customer) async {
    final dao = _database.customerDao;
    final now = DateTime.now();

    // Yeni ID oluştur
    final id = customer.id.isEmpty ? _uuid.v4() : customer.id;

    final entity = customer
        .copyWith(
          id: id,
          createdAt: now,
          updatedAt: now,
        )
        .toEntity();

    await dao.insertCustomer(entity);
    return id;
  }

  @override
  Future<void> createCustomers(List<Customer> customers) async {
    final dao = _database.customerDao;
    final now = DateTime.now();

    final entities = customers.map((customer) {
      final id = customer.id.isEmpty ? _uuid.v4() : customer.id;
      return customer
          .copyWith(
            id: id,
            createdAt: now,
            updatedAt: now,
          )
          .toEntity();
    }).toList();

    await dao.insertCustomers(entities);
  }

  @override
  Future<List<Customer>> getAllCustomers() async {
    final dao = _database.customerDao;
    final entities = await dao.getAllCustomers();
    return entities.map((entity) => Customer.fromEntity(entity)).toList();
  }

  @override
  Future<List<Customer>> getActiveCustomers() async {
    final dao = _database.customerDao;
    final entities = await dao.getActiveCustomers();
    return entities.map((entity) => Customer.fromEntity(entity)).toList();
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    final dao = _database.customerDao;
    final entity = await dao.getCustomerById(id);
    return entity != null ? Customer.fromEntity(entity) : null;
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    final dao = _database.customerDao;
    final searchTerm = '%$query%';
    final entities = await dao.searchCustomersByName(searchTerm);
    return entities.map((entity) => Customer.fromEntity(entity)).toList();
  }

  @override
  Future<List<Customer>> getCustomersByType(CustomerType type) async {
    final dao = _database.customerDao;
    final entities = await dao.getCustomersByType(type.value);
    return entities.map((entity) => Customer.fromEntity(entity)).toList();
  }

  @override
  Future<List<Customer>> getCustomersByCity(String city) async {
    final dao = _database.customerDao;
    final entities = await dao.getCustomersByCity(city);
    return entities.map((entity) => Customer.fromEntity(entity)).toList();
  }

  @override
  Future<Customer?> getCustomerByEmail(String email) async {
    final dao = _database.customerDao;
    final entity = await dao.getCustomerByEmail(email);
    return entity != null ? Customer.fromEntity(entity) : null;
  }

  @override
  Future<Customer?> getCustomerByPhone(String phone) async {
    final dao = _database.customerDao;
    final entity = await dao.getCustomerByPhone(phone);
    return entity != null ? Customer.fromEntity(entity) : null;
  }

  @override
  Future<Customer?> getCustomerByTaxNumber(String taxNumber) async {
    final dao = _database.customerDao;
    final entity = await dao.getCustomerByTaxNumber(taxNumber);
    return entity != null ? Customer.fromEntity(entity) : null;
  }

  @override
  Future<int> getTotalCustomerCount() async {
    final dao = _database.customerDao;
    return await dao.getTotalCustomerCount() ?? 0;
  }

  @override
  Future<int> getActiveCustomerCount() async {
    final dao = _database.customerDao;
    return await dao.getActiveCustomerCount() ?? 0;
  }

  @override
  Future<int> getInactiveCustomerCount() async {
    final dao = _database.customerDao;
    return await dao.getInactiveCustomerCount() ?? 0;
  }

  @override
  Future<List<Customer>> getRecentCustomers({int limit = 10}) async {
    final dao = _database.customerDao;
    final entities = await dao.getRecentCustomers(limit);
    return entities.map((entity) => Customer.fromEntity(entity)).toList();
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final dao = _database.customerDao;
    final entity = customer.copyWith(updatedAt: DateTime.now()).toEntity();
    await dao.updateCustomer(entity);
  }

  @override
  Future<void> updateCustomerStatus(String id, bool isActive) async {
    final dao = _database.customerDao;
    await dao.updateCustomerStatus(
      id,
      isActive,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> deleteCustomer(String id) async {
    final dao = _database.customerDao;
    await dao.deleteCustomerById(id);
  }

  @override
  Future<void> deleteInactiveCustomers() async {
    final dao = _database.customerDao;
    await dao.deleteInactiveCustomers();
  }

  @override
  Stream<List<Customer>> watchAllCustomers() {
    final dao = _database.customerDao;
    return dao.watchAllCustomers().map(
          (entities) =>
              entities.map((entity) => Customer.fromEntity(entity)).toList(),
        );
  }

  @override
  Stream<List<Customer>> watchActiveCustomers() {
    final dao = _database.customerDao;
    return dao.watchActiveCustomers().map(
          (entities) =>
              entities.map((entity) => Customer.fromEntity(entity)).toList(),
        );
  }

  @override
  Stream<List<Customer>> watchInactiveCustomers() {
    final dao = _database.customerDao;
    return dao.watchInactiveCustomers().map(
          (entities) =>
              entities.map((entity) => Customer.fromEntity(entity)).toList(),
        );
  }

  @override
  Stream<Customer?> watchCustomerById(String id) {
    final dao = _database.customerDao;
    return dao.watchCustomerById(id).map(
          (entity) => entity != null ? Customer.fromEntity(entity) : null,
        );
  }

  @override
  Stream<int> watchActiveCustomerCount() {
    final dao = _database.customerDao;
    return dao.watchActiveCustomerCount().map((count) => count ?? 0);
  }

  @override
  Stream<int> watchInactiveCustomerCount() {
    final dao = _database.customerDao;
    return dao.watchInactiveCustomerCount().map((count) => count ?? 0);
  }

  @override
  Future<Map<CustomerType, int>> getCustomerTypeStats() async {
    final dao = _database.customerDao;
    final stats = await dao.getCustomerTypeStats();

    final result = <CustomerType, int>{};
    for (final stat in stats) {
      final type = CustomerType.fromValue(stat.customerType);
      final count = stat.count;
      result[type] = count;
    }

    return result;
  }

  @override
  Future<Map<String, int>> getCustomerCityStats() async {
    final dao = _database.customerDao;
    final stats = await dao.getCityCustomerCounts();

    final result = <String, int>{};
    for (final stat in stats) {
      final city = stat.city;
      final count = stat.count;
      result[city] = count;
    }

    return result;
  }

  @override
  Future<Map<String, int>> getMonthlyCustomerStats() async {
    final dao = _database.customerDao;
    final stats = await dao.getMonthlyCustomerStats();

    final result = <String, int>{};
    for (final stat in stats) {
      final month = stat.month;
      final count = stat.month as int;
      result[month] = count;
    }

    return result;
  }
}
