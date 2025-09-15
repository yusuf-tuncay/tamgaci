// ========== TAMGACI DATABASE ==========
// lib/core/database/tamgaci_database.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Tamgaci Database Service
/// Firebase Firestore database operations
class TamgaciDatabase {
  static final TamgaciDatabase _instance = TamgaciDatabase._internal();
  factory TamgaciDatabase() => _instance;
  TamgaciDatabase._internal();

  late FirebaseFirestore _firestore;

  /// Initialize database
  Future<void> initialize() async {
    try {
      _firestore = FirebaseFirestore.instance;

      // Configure Firestore settings
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      AppLogger.info('Tamgaci Database initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize Tamgaci Database', e);
      rethrow;
    }
  }

  /// Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// Get document reference
  DocumentReference<Map<String, dynamic>> doc(String path) {
    return _firestore.doc(path);
  }

  /// Batch write operations
  WriteBatch batch() {
    return _firestore.batch();
  }

  /// Run transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) {
    return _firestore.runTransaction(updateFunction);
  }

  /// Enable network
  Future<void> enableNetwork() async {
    await _firestore.enableNetwork();
  }

  /// Disable network
  Future<void> disableNetwork() async {
    await _firestore.disableNetwork();
  }

  /// Clear persistence
  Future<void> clearPersistence() async {
    await _firestore.clearPersistence();
  }

  /// Wait for pending writes
  Future<void> waitForPendingWrites() async {
    await _firestore.waitForPendingWrites();
  }

  /// Terminate
  Future<void> terminate() async {
    await _firestore.terminate();
  }

  /// Collection names
  static const String customersCollection = 'customers';
  static const String suppliersCollection = 'suppliers';
  static const String productsCollection = 'products';
  static const String salesCollection = 'sales';
  static const String purchasesCollection = 'purchases';
  static const String incomesCollection = 'incomes';
  static const String expensesCollection = 'expenses';
  static const String stocksCollection = 'stocks';
  static const String warehousesCollection = 'warehouses';
  static const String invoicesCollection = 'invoices';
  static const String cashAccountsCollection = 'cash_accounts';
  static const String cashMovementsCollection = 'cash_movements';
  static const String reportsCollection = 'reports';
  static const String settingsCollection = 'settings';
  static const String usersCollection = 'users';
  static const String notificationsCollection = 'notifications';
  static const String auditLogsCollection = 'audit_logs';
}

/// Database provider for dependency injection
final databaseProvider = Provider<TamgaciDatabase>((ref) {
  return TamgaciDatabase();
});

/// Firestore provider for dependency injection
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return TamgaciDatabase().firestore;
});
