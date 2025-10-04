import 'package:tamgaci/features/sales/domain/entities/sale.dart';

/// Ödeme durumu kontrol servisi
class PaymentStatusService {
  /// Satışın ödeme durumunu kontrol eder
  static bool isSalePaid(Sale sale) {
    // 1. isPaid alanı true ise ödendi
    if (sale.isPaid) {
      return true;
    }

    // 2. paymentStatus paid ise ödendi
    if (sale.paymentStatus == PaymentStatus.paid) {
      return true;
    }

    // 3. status paid ise ödendi
    if (sale.status == SaleStatus.paid) {
      return true;
    }

    // 4. Diğer durumlarda ödenmemiş
    return false;
  }

  /// Satışın ödeme durumunu günceller
  static Sale updatePaymentStatus(Sale sale, bool isPaid) {
    return sale.copyWith(
      isPaid: isPaid,
      paymentStatus: isPaid ? PaymentStatus.paid : PaymentStatus.pending,
      status: isPaid ? SaleStatus.paid : SaleStatus.pending,
    );
  }

  /// Satışın ödeme durumunu kısmi ödeme olarak günceller
  static Sale updatePartialPayment(Sale sale) {
    return sale.copyWith(
      isPaid: false, // Kısmi ödeme tam ödeme değil
      paymentStatus: PaymentStatus.partial,
      status: SaleStatus.pending, // Hala beklemede
    );
  }

  /// Satışın ödeme durumunu iade olarak günceller
  static Sale updateRefund(Sale sale) {
    return sale.copyWith(
      isPaid: false, // İade edildi
      paymentStatus: PaymentStatus.refunded,
      status: SaleStatus.returned,
    );
  }

  /// Satışın ödeme durumunu vadesi geçmiş olarak günceller
  static Sale updateOverdue(Sale sale) {
    return sale.copyWith(
      isPaid: false, // Vadesi geçmiş
      paymentStatus: PaymentStatus.overdue,
      status: SaleStatus.pending, // Hala beklemede
    );
  }

  /// Satışın ödeme durumunu iptal olarak günceller
  static Sale updateCancelled(Sale sale) {
    return sale.copyWith(
      isPaid: false, // İptal edildi
      paymentStatus: PaymentStatus.pending, // Ödeme beklemiyor
      status: SaleStatus.cancelled,
    );
  }

  /// Satışın ödeme durumunu teslim edildi olarak günceller
  static Sale updateDelivered(Sale sale) {
    return sale.copyWith(
      status: SaleStatus.delivered,
      // isPaid ve paymentStatus değişmez
    );
  }

  /// Satışın ödeme durumunu kargoya verildi olarak günceller
  static Sale updateShipped(Sale sale) {
    return sale.copyWith(
      status: SaleStatus.shipped,
      // isPaid ve paymentStatus değişmez
    );
  }

  /// Satışın ödeme durumunu onaylandı olarak günceller
  static Sale updateConfirmed(Sale sale) {
    return sale.copyWith(
      status: SaleStatus.confirmed,
      // isPaid ve paymentStatus değişmez
    );
  }

  /// Satışın ödeme durumunu taslak olarak günceller
  static Sale updateDraft(Sale sale) {
    return sale.copyWith(
      status: SaleStatus.draft,
      paymentStatus: PaymentStatus.pending,
      isPaid: false,
    );
  }

  /// Satışın ödeme durumunu string olarak döndürür
  static String getPaymentStatusText(Sale sale) {
    if (isSalePaid(sale)) {
      return 'Ödendi';
    }

    switch (sale.paymentStatus) {
      case PaymentStatus.pending:
        return 'Ödeme Bekliyor';
      case PaymentStatus.partial:
        return 'Kısmi Ödeme';
      case PaymentStatus.paid:
        return 'Ödendi';
      case PaymentStatus.overdue:
        return 'Vadesi Geçmiş';
      case PaymentStatus.refunded:
        return 'İade Edildi';
    }
  }

  /// Satışın ödeme durumunu renk olarak döndürür
  static String getPaymentStatusColor(Sale sale) {
    if (isSalePaid(sale)) {
      return 'green';
    }

    switch (sale.paymentStatus) {
      case PaymentStatus.pending:
        return 'orange';
      case PaymentStatus.partial:
        return 'blue';
      case PaymentStatus.paid:
        return 'green';
      case PaymentStatus.overdue:
        return 'red';
      case PaymentStatus.refunded:
        return 'purple';
    }
  }

  /// Satışın ödeme durumunu icon olarak döndürür
  static String getPaymentStatusIcon(Sale sale) {
    if (isSalePaid(sale)) {
      return 'check_circle';
    }

    switch (sale.paymentStatus) {
      case PaymentStatus.pending:
        return 'schedule';
      case PaymentStatus.partial:
        return 'payment';
      case PaymentStatus.paid:
        return 'check_circle';
      case PaymentStatus.overdue:
        return 'warning';
      case PaymentStatus.refunded:
        return 'undo';
    }
  }
}

