// ========== PAYMENT PROVIDERS ==========
// lib/features/payments/presentation/providers/payment_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_payment_repository.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_type.dart';
import '../../domain/entities/payment_status.dart';

/// Tüm tahsilatları getiren provider
final paymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getAllPayments();
});

/// Müşteriye göre tahsilatları getiren provider
final paymentsByCustomerProvider =
    FutureProvider.family<List<Payment>, String>((ref, customerId) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByCustomer(customerId);
});

/// Tahsilat türüne göre getiren provider
final paymentsByTypeProvider =
    FutureProvider.family<List<Payment>, PaymentType>((ref, type) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByType(type.name);
});

/// Tahsilat durumuna göre getiren provider
final paymentsByStatusProvider =
    FutureProvider.family<List<Payment>, PaymentStatus>((ref, status) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByStatus(status.name);
});

/// ID'ye göre tahsilat getiren provider
final paymentByIdProvider =
    FutureProvider.family<Payment?, String>((ref, id) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentById(id);
});

/// Tarih aralığına göre tahsilatları getiren provider
final paymentsByDateRangeProvider =
    FutureProvider.family<List<Payment>, Map<String, DateTime>>(
        (ref, dateRange) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByDateRange(
    dateRange['startDate']!,
    dateRange['endDate']!,
  );
});

/// Nakit tahsilatları getiren provider
final cashPaymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  final allPayments = await repository.getAllPayments();
  return allPayments
      .where((payment) =>
          payment.type == PaymentType.cash ||
          payment.type == PaymentType.creditCard ||
          payment.type == PaymentType.bank)
      .toList();
});

/// Çek tahsilatları getiren provider
final checkPaymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByType(PaymentType.check.name);
});

/// Senet tahsilatları getiren provider
final promissoryPaymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByType(PaymentType.promissoryNote.name);
});

/// Cari virman tahsilatları getiren provider
final transferPaymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByType(PaymentType.transfer.name);
});

/// Borç-alacak fişi tahsilatları getiren provider
final voucherPaymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByType(PaymentType.voucher.name);
});

/// Bakiye düzelt tahsilatları getiren provider
final balancePaymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByType(PaymentType.balanceAdjustment.name);
});

/// Bekleyen tahsilatları getiren provider
final pendingPaymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByStatus(PaymentStatus.pending.name);
});

/// Tamamlanan tahsilatları getiren provider
final completedPaymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByStatus(PaymentStatus.completed.name);
});

/// İptal edilen tahsilatları getiren provider
final cancelledPaymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByStatus(PaymentStatus.cancelled.name);
});

/// Başarısız tahsilatları getiren provider
final failedPaymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  return repository.getPaymentsByStatus(PaymentStatus.failed.name);
});

/// Tahsilat istatistikleri provider
final paymentStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  final allPayments = await repository.getAllPayments();

  final totalAmount =
      allPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  final completedAmount = allPayments
      .where((p) => p.status == PaymentStatus.completed)
      .fold(0.0, (sum, payment) => sum + payment.amount);
  final pendingAmount = allPayments
      .where((p) => p.status == PaymentStatus.pending)
      .fold(0.0, (sum, payment) => sum + payment.amount);

  return {
    'totalPayments': allPayments.length,
    'totalAmount': totalAmount,
    'completedAmount': completedAmount,
    'pendingAmount': pendingAmount,
    'completedCount':
        allPayments.where((p) => p.status == PaymentStatus.completed).length,
    'pendingCount':
        allPayments.where((p) => p.status == PaymentStatus.pending).length,
    'cancelledCount':
        allPayments.where((p) => p.status == PaymentStatus.cancelled).length,
    'failedCount':
        allPayments.where((p) => p.status == PaymentStatus.failed).length,
  };
});

