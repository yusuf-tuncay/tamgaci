// ========== CUSTOMER REPORT PAGE ==========
// lib/features/reports/presentation/pages/customer_report_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../customers/presentation/providers/customer_providers.dart';

/// Müşteri raporu sayfası
class CustomerReportPage extends ConsumerStatefulWidget {
  const CustomerReportPage({super.key});

  @override
  ConsumerState<CustomerReportPage> createState() => _CustomerReportPageState();
}

class _CustomerReportPageState extends ConsumerState<CustomerReportPage> {
  String _selectedPeriod = 'Bu Ay';
  String _selectedFilter = 'Tümü';

  final List<String> _periods = [
    'Bu Ay',
    'Geçen Ay',
    'Son 3 Ay',
    'Bu Yıl',
    'Tüm Zamanlar',
  ];
  final List<String> _filters = [
    'Tümü',
    'Aktif',
    'Pasif',
    'Kurumsal',
    'Bireysel',
  ];

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: const CustomAppBar(title: 'Müşteri Raporu', showDrawer: false),
      body: Column(
        children: [
          // Filtreler
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Dönem seçimi
                Row(
                  children: [
                    Text(
                      'Dönem:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPeriod,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _periods.map((period) {
                          return DropdownMenuItem(
                            value: period,
                            child: Text(period),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriod = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Filtre seçimi
                Row(
                  children: [
                    Text(
                      'Filtre:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedFilter,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _filters.map((filter) {
                          return DropdownMenuItem(
                            value: filter,
                            child: Text(filter),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Rapor içeriği
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                final filteredCustomers = _filterCustomers(customers);
                final stats = _calculateStats(filteredCustomers);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Özet kartları
                      _buildSummaryCards(stats),
                      const SizedBox(height: 24),

                      // Müşteri listesi
                      _buildCustomerList(filteredCustomers),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Hata: $error')),
            ),
          ),
        ],
      ),
    );
  }

  /// Müşterileri filtrele
  List<dynamic> _filterCustomers(List<dynamic> customers) {
    List<dynamic> filtered = customers;

    // Filtre uygula
    switch (_selectedFilter) {
      case 'Aktif':
        filtered = filtered.where((c) => c.isActive == true).toList();
        break;
      case 'Pasif':
        filtered = filtered.where((c) => c.isActive == false).toList();
        break;
      case 'Kurumsal':
        filtered = filtered
            .where((c) => c.customerType.toString().contains('company'))
            .toList();
        break;
      case 'Bireysel':
        filtered = filtered
            .where((c) => c.customerType.toString().contains('individual'))
            .toList();
        break;
    }

    return filtered;
  }

  /// İstatistikleri hesapla
  Map<String, dynamic> _calculateStats(List<dynamic> customers) {
    final total = customers.length;
    final active = customers.where((c) => c.isActive == true).length;
    final inactive = total - active;
    final corporate = customers
        .where((c) => c.customerType.toString().contains('company'))
        .length;
    final individual = total - corporate;

    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'corporate': corporate,
      'individual': individual,
    };
  }

  /// Özet kartları
  Widget _buildSummaryCards(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Toplam Müşteri',
          stats['total'].toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Aktif Müşteri',
          stats['active'].toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Kurumsal',
          stats['corporate'].toString(),
          Icons.business,
          Colors.orange,
        ),
        _buildStatCard(
          'Bireysel',
          stats['individual'].toString(),
          Icons.person,
          Colors.purple,
        ),
      ],
    );
  }

  /// İstatistik kartı
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: TamgaciConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Müşteri listesi
  Widget _buildCustomerList(List<dynamic> customers) {
    if (customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: TamgaciConstants.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              'Müşteri bulunamadı',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Müşteri Listesi (${customers.length})',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: customer.isActive == true
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  child: Icon(
                    customer.customerType.toString().contains('company')
                        ? Icons.business
                        : Icons.person,
                    color:
                        customer.isActive == true ? Colors.green : Colors.grey,
                  ),
                ),
                title: Text(
                  customer.name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (customer.email != null)
                      Text(
                        customer.email!,
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    Text(
                      customer.customerType.toString().contains('company')
                          ? 'Kurumsal'
                          : 'Bireysel',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            customer.customerType.toString().contains('company')
                                ? Colors.orange
                                : Colors.purple,
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: customer.isActive == true
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    customer.isActive == true ? 'Aktif' : 'Pasif',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: customer.isActive == true
                          ? Colors.green
                          : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
