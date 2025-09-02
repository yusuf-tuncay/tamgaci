// ========== CASH REPOSITORY ==========
// lib/features/cash/domain/repositories/cash_repository.dart

import '../entities/cash_transaction.dart';

/// Nakit repository interface'i
abstract class CashRepository {
  /// Tüm nakit işlemlerini getir
  Future<List<CashTransaction>> getAllCashTransactions();

  /// ID'ye göre nakit işlem getir
  Future<CashTransaction?> getCashTransactionById(String id);

  /// Yeni nakit işlem ekle
  Future<String> createCashTransaction(CashTransaction transaction);

  /// Nakit işlem güncelle
  Future<void> updateCashTransaction(CashTransaction transaction);

  /// Nakit işlem sil
  Future<void> deleteCashTransaction(String id);

  /// Tarih aralığına göre nakit işlemleri getir
  Future<List<CashTransaction>> getCashTransactionsByDateRange(DateTime startDate, DateTime endDate);

  /// Tipe göre nakit işlemleri getir
  Future<List<CashTransaction>> getCashTransactionsByType(CashTransactionType type);

  /// Kategoriye göre nakit işlemleri getir
  Future<List<CashTransaction>> getCashTransactionsByCategory(String category);

  /// Son nakit işlemleri getir
  Future<List<CashTransaction>> getRecentCashTransactions(int limit);

  /// Nakit işlem arama
  Future<List<CashTransaction>> searchCashTransactions(String query);

  /// Toplam nakit bakiyesi getir
  Future<double> getTotalCashBalance();

  /// Tarih aralığına göre toplam gelir getir
  Future<double> getTotalIncomeByDateRange(DateTime startDate, DateTime endDate);

  /// Tarih aralığına göre toplam gider getir
  Future<double> getTotalExpenseByDateRange(DateTime startDate, DateTime endDate);

  /// Nakit işlem istatistikleri getir
  Future<Map<String, dynamic>> getCashStatistics();

  // ========== STREAM OPERATIONS ==========

  /// Nakit işlem stream'i (tek işlem)
  Stream<CashTransaction?> watchCashTransactionById(String id);

  /// Tüm nakit işlemler stream'i
  Stream<List<CashTransaction>> watchAllCashTransactions();

  /// Tarih aralığına göre nakit işlemler stream'i
  Stream<List<CashTransaction>> watchCashTransactionsByDateRange(DateTime startDate, DateTime endDate);

  /// Tipe göre nakit işlemler stream'i
  Stream<List<CashTransaction>> watchCashTransactionsByType(CashTransactionType type);
}
