// aylık fatura istatistikleri için
class MonthlyInvoiceStatsDTO {
  final String month;
  final int count;
  final int total;

  MonthlyInvoiceStatsDTO({
    required this.month,
    required this.count,
    required this.total,
  });

  factory MonthlyInvoiceStatsDTO.fromMap(Map<String, Object?> map) {
    return MonthlyInvoiceStatsDTO(
      month: map['month'] as String,
      count: (map['count'] as int),
      total: (map['total'] as int),
    );
  }
}

// fatura durum istatistikleri için
class InvoiceStatusStatsDTO {
  final String status;
  final int count;
  final int total;

  InvoiceStatusStatsDTO({
    required this.status,
    required this.count,
    required this.total,
  });

  factory InvoiceStatusStatsDTO.fromMap(Map<String, Object?> map) {
    return InvoiceStatusStatsDTO(
      status: map['status'] as String,
      count: map['count'] as int,
      total: map['total'] as int,
    );
  }
}

// en çok fatura olan müşteriler
class TopCustomerStatsDTO {
  final String customerId;
  final int invoiceCount;
  final int totalAmount;

  TopCustomerStatsDTO({
    required this.customerId,
    required this.invoiceCount,
    required this.totalAmount,
  });

  factory TopCustomerStatsDTO.fromMap(Map<String, Object?> map) {
    return TopCustomerStatsDTO(
      customerId: map['customer_id'] as String,
      invoiceCount: map['invoice_count'] as int,
      totalAmount: map['total_amount'] as int,
    );
  }
}

// günlük gelir raporu için
class DailyRevenueDTO {
  final String date;
  final int count;
  final int total;

  DailyRevenueDTO({
    required this.date,
    required this.count,
    required this.total,
  });

  factory DailyRevenueDTO.fromMap(Map<String, Object?> map) {
    return DailyRevenueDTO(
      date: map['date'] as String,
      count: map['count'] as int,
      total: map['total'] as int,
    );
  }
}
