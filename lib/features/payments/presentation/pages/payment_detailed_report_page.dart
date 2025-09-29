// ========== PAYMENT DETAILED REPORT PAGE ==========
// lib/features/payments/presentation/pages/payment_detailed_report_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_status.dart';
import '../providers/payment_providers.dart';

class PaymentDetailedReportPage extends ConsumerStatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String paymentType;
  final String status;
  final String customerId;

  const PaymentDetailedReportPage({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.paymentType,
    required this.status,
    required this.customerId,
  });

  @override
  ConsumerState<PaymentDetailedReportPage> createState() =>
      _PaymentDetailedReportPageState();
}

class _PaymentDetailedReportPageState
    extends ConsumerState<PaymentDetailedReportPage> {
  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detaylı Tahsilat Raporu'),
        backgroundColor: Colors.blue[50],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildReportHeader(isDark),
            _buildReportFilters(isDark),
            Expanded(
              child: _buildReportContent(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment,
                color: Colors.blue[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detaylı Tahsilat Raporu',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${DateFormat('dd.MM.yyyy').format(widget.startDate)} - ${DateFormat('dd.MM.yyyy').format(widget.endDate)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Rapor',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _sortBy,
              hint: const Text('Sıralama'),
              items: const [
                DropdownMenuItem(value: 'date', child: Text('Tarih')),
                DropdownMenuItem(value: 'amount', child: Text('Tutar')),
                DropdownMenuItem(value: 'customer', child: Text('Müşteri')),
                DropdownMenuItem(value: 'type', child: Text('Tür')),
                DropdownMenuItem(value: 'status', child: Text('Durum')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.blue[700],
            ),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(bool isDark) {
    return Consumer(
      builder: (context, ref, child) {
        final paymentsAsync = ref.watch(paymentsProvider);
        return paymentsAsync.when(
          data: (payments) {
            final filteredPayments = _filterAndSortPayments(payments);
            return Column(
              children: [
                _buildReportSummary(filteredPayments),
                Expanded(
                  child: _buildPaymentsList(filteredPayments),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Hata: $error'),
          ),
        );
      },
    );
  }

  Widget _buildReportSummary(List<Payment> payments) {
    final totalAmount =
        payments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final completedAmount = payments
        .where((p) => p.status == PaymentStatus.completed)
        .fold<double>(0, (sum, payment) => sum + payment.amount);
    final pendingAmount = payments
        .where((p) => p.status == PaymentStatus.pending)
        .fold<double>(0, (sum, payment) => sum + payment.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Toplam İşlem',
                  '${payments.length}',
                  Icons.receipt,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Toplam Tutar',
                  '₺${NumberFormat('#,##0.00').format(totalAmount)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Tamamlanan',
                  '₺${NumberFormat('#,##0.00').format(completedAmount)}',
                  Icons.check_circle,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Bekleyen',
                  '₺${NumberFormat('#,##0.00').format(pendingAmount)}',
                  Icons.schedule,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(List<Payment> payments) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Bu dönemde tahsilat bulunamadı',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: payment.status.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: payment.type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              payment.type.icon,
              color: payment.type.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.customerName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      payment.type.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: payment.status.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        payment.status.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: payment.status.color,
                        ),
                      ),
                    ),
                  ],
                ),
                if (payment.description != null &&
                    payment.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    payment.description!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₺${NumberFormat('#,##0.00').format(payment.amount)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              Text(
                DateFormat('dd.MM.yyyy').format(payment.paymentDate),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Payment> _filterAndSortPayments(List<Payment> payments) {
    var filtered = payments.where((payment) {
      // Tarih filtresi
      if (payment.paymentDate.isBefore(widget.startDate) ||
          payment.paymentDate.isAfter(widget.endDate)) {
        return false;
      }

      // Tahsilat türü filtresi
      if (widget.paymentType != 'all' &&
          payment.type.name != widget.paymentType) {
        return false;
      }

      // Durum filtresi
      if (widget.status != 'all' && payment.status.name != widget.status) {
        return false;
      }

      // Müşteri filtresi
      if (widget.customerId != 'all' &&
          payment.customerId != widget.customerId) {
        return false;
      }

      return true;
    }).toList();

    // Sıralama
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'date':
          comparison = a.paymentDate.compareTo(b.paymentDate);
          break;
        case 'amount':
          comparison = a.amount.compareTo(b.amount);
          break;
        case 'customer':
          comparison = a.customerName.compareTo(b.customerName);
          break;
        case 'type':
          comparison = a.type.displayName.compareTo(b.type.displayName);
          break;
        case 'status':
          comparison = a.status.displayName.compareTo(b.status.displayName);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rapor dışa aktarılıyor...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rapor paylaşılıyor...'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
