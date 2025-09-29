// ========== PAYMENT REPORTS PAGE ==========
// lib/features/payments/presentation/pages/payment_reports_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_dropdown.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_type.dart';
import '../../domain/entities/payment_status.dart';
import '../providers/payment_providers.dart';
import '../../../customers/presentation/providers/customer_providers.dart';

class PaymentReportsPage extends ConsumerStatefulWidget {
  const PaymentReportsPage({super.key});

  @override
  ConsumerState<PaymentReportsPage> createState() => _PaymentReportsPageState();
}

class _PaymentReportsPageState extends ConsumerState<PaymentReportsPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPaymentType = 'all';
  String _selectedStatus = 'all';
  String _selectedCustomerId = 'all';
  String _selectedReportType = 'summary';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahsilat Raporları'),
        backgroundColor: Colors.blue[50],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(isDark),
              const SizedBox(height: 24),
              _buildFilterSection(isDark),
              const SizedBox(height: 24),
              _buildReportTypeSection(isDark),
              const SizedBox(height: 24),
              _buildReportPreview(isDark),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.assessment,
              color: Colors.blue[700],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahsilat Raporları',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tahsilat işlemlerinizin detaylı raporlarını oluşturun',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                Icons.filter_list,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtre Seçenekleri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Başlangıç Tarihi',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.grey[600], size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${_startDate.day.toString().padLeft(2, '0')}.${_startDate.month.toString().padLeft(2, '0')}.${_startDate.year}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: _startDate,
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bitiş Tarihi',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.grey[600], size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${_endDate.day.toString().padLeft(2, '0')}.${_endDate.month.toString().padLeft(2, '0')}.${_endDate.year}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomDropdown<String>(
                  value: _selectedPaymentType,
                  label: 'Tahsilat Türü',
                  items: const [
                    'all',
                    'cash',
                    'creditCard',
                    'bank',
                    'check',
                    'promissoryNote',
                    'transfer',
                    'voucher',
                    'balanceAdjustment'
                  ],
                  itemBuilder: (type) {
                    if (type == 'all') return const Text('Tümü');
                    return Text(PaymentType.values
                        .firstWhere((e) => e.name == type)
                        .displayName);
                  },
                  onChanged: (type) {
                    setState(() {
                      _selectedPaymentType = type!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomDropdown<String>(
                  value: _selectedStatus,
                  label: 'Durum',
                  items: const [
                    'all',
                    'pending',
                    'completed',
                    'failed',
                    'cancelled'
                  ],
                  itemBuilder: (status) {
                    if (status == 'all') return const Text('Tümü');
                    return Text(PaymentStatus.values
                        .firstWhere((e) => e.name == status)
                        .displayName);
                  },
                  onChanged: (status) {
                    setState(() {
                      _selectedStatus = status!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final customersAsync = ref.watch(customersProvider);
              return customersAsync.when(
                data: (customers) {
                  final customerItems = ['all', ...customers.map((c) => c.id)];
                  return CustomDropdown<String>(
                    value: _selectedCustomerId,
                    label: 'Müşteri',
                    items: customerItems,
                    itemBuilder: (customerId) {
                      if (customerId == 'all') return const Text('Tümü');
                      final customer =
                          customers.firstWhere((c) => c.id == customerId);
                      return Text(customer.name);
                    },
                    onChanged: (customerId) {
                      setState(() {
                        _selectedCustomerId = customerId!;
                      });
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text('Hata: $error'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                Icons.analytics,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Rapor Türü',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildReportTypeCard(
                  'summary', 'Özet Raporu', Icons.summarize, Colors.green),
              _buildReportTypeCard(
                  'detailed', 'Detaylı Rapor', Icons.list_alt, Colors.blue),
              _buildReportTypeCard(
                  'byType', 'Tür Bazında', Icons.category, Colors.orange),
              _buildReportTypeCard(
                  'byCustomer', 'Müşteri Bazında', Icons.person, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeCard(
      String type, String title, IconData icon, Color color) {
    final isSelected = _selectedReportType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedReportType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                Icons.preview,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Rapor Önizleme',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final paymentsAsync = ref.watch(paymentsProvider);
              return paymentsAsync.when(
                data: (payments) {
                  final filteredPayments = _filterPayments(payments);
                  return _buildReportData(filteredPayments);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Hata: $error'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportData(List<Payment> payments) {
    final totalAmount =
        payments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final completedCount =
        payments.where((p) => p.status == PaymentStatus.completed).length;
    final pendingCount =
        payments.where((p) => p.status == PaymentStatus.pending).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Toplam İşlem', '${payments.length}',
                  Icons.receipt, Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                  'Toplam Tutar',
                  '₺${totalAmount.toStringAsFixed(0)}',
                  Icons.attach_money,
                  Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Tamamlanan', '$completedCount',
                  Icons.check_circle, Colors.teal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                  'Bekleyen', '$pendingCount', Icons.schedule, Colors.orange),
            ),
          ],
        ),
        if (payments.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Son İşlemler',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          ...payments.take(5).map((payment) => _buildPaymentItem(payment)),
        ],
      ],
    );
  }

  Widget _buildStatCard(
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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

  Widget _buildPaymentItem(Payment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            payment.type.icon,
            color: payment.type.color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.customerName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  payment.type.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₺${payment.amount.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                payment.status.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: payment.status.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Rapor Oluştur',
            onPressed: _generateReport,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'Excel\'e Aktar',
            onPressed: _exportToExcel,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'PDF\'e Aktar',
            onPressed: _exportToPDF,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }

  List<Payment> _filterPayments(List<Payment> payments) {
    return payments.where((payment) {
      // Tarih filtresi
      if (payment.paymentDate.isBefore(_startDate) ||
          payment.paymentDate.isAfter(_endDate)) {
        return false;
      }

      // Tahsilat türü filtresi
      if (_selectedPaymentType != 'all' &&
          payment.type.name != _selectedPaymentType) {
        return false;
      }

      // Durum filtresi
      if (_selectedStatus != 'all' && payment.status.name != _selectedStatus) {
        return false;
      }

      // Müşteri filtresi
      if (_selectedCustomerId != 'all' &&
          payment.customerId != _selectedCustomerId) {
        return false;
      }

      return true;
    }).toList();
  }

  void _generateReport() {
    // Rapor oluşturma işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rapor oluşturuluyor...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportToExcel() {
    // Excel export işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel dosyası oluşturuluyor...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportToPDF() {
    // PDF export işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF dosyası oluşturuluyor...'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _exportReport() {
    // Genel export işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rapor dışa aktarılıyor...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
