// ========== SUPPLIER REPORT PAGE ==========
// lib/features/reports/presentation/pages/supplier_report_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Tedarikçi raporu sayfası
class SupplierReportPage extends ConsumerStatefulWidget {
  const SupplierReportPage({super.key});

  @override
  ConsumerState<SupplierReportPage> createState() => _SupplierReportPageState();
}

class _SupplierReportPageState extends ConsumerState<SupplierReportPage> {
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
    'Premium',
    'Standart',
  ];

  // Mock tedarikçi verileri
  final List<Map<String, dynamic>> _mockSuppliers = [
    {
      'id': '1',
      'name': 'ABC Teknoloji Ltd.',
      'email': 'info@abctech.com',
      'phone': '+90 212 555 0101',
      'status': 'Aktif',
      'type': 'Premium',
      'totalOrders': 45,
      'totalAmount': 125000.0,
      'lastOrderDate': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': '2',
      'name': 'XYZ Elektronik A.Ş.',
      'email': 'contact@xyzelektronik.com',
      'phone': '+90 216 555 0202',
      'status': 'Aktif',
      'type': 'Standart',
      'totalOrders': 23,
      'totalAmount': 67000.0,
      'lastOrderDate': DateTime.now().subtract(const Duration(days: 12)),
    },
    {
      'id': '3',
      'name': 'Delta Mobilya',
      'email': 'info@deltamobilya.com',
      'phone': '+90 232 555 0303',
      'status': 'Pasif',
      'type': 'Standart',
      'totalOrders': 8,
      'totalAmount': 15000.0,
      'lastOrderDate': DateTime.now().subtract(const Duration(days: 45)),
    },
    {
      'id': '4',
      'name': 'Gamma İnşaat Malzemeleri',
      'email': 'satis@gammainsaat.com',
      'phone': '+90 224 555 0404',
      'status': 'Aktif',
      'type': 'Premium',
      'totalOrders': 67,
      'totalAmount': 89000.0,
      'lastOrderDate': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: const CustomAppBar(title: 'Tedarikçi Raporu', showDrawer: false),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Özet kartları
                  _buildSummaryCards(),
                  const SizedBox(height: 24),

                  // Tedarikçi listesi
                  _buildSupplierList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Filtrelenmiş tedarikçileri al
  List<Map<String, dynamic>> _getFilteredSuppliers() {
    List<Map<String, dynamic>> filtered = _mockSuppliers;

    switch (_selectedFilter) {
      case 'Aktif':
        filtered = filtered.where((s) => s['status'] == 'Aktif').toList();
        break;
      case 'Pasif':
        filtered = filtered.where((s) => s['status'] == 'Pasif').toList();
        break;
      case 'Premium':
        filtered = filtered.where((s) => s['type'] == 'Premium').toList();
        break;
      case 'Standart':
        filtered = filtered.where((s) => s['type'] == 'Standart').toList();
        break;
    }

    return filtered;
  }

  /// İstatistikleri hesapla
  Map<String, dynamic> _calculateStats() {
    final suppliers = _getFilteredSuppliers();
    final total = suppliers.length;
    final active = suppliers.where((s) => s['status'] == 'Aktif').length;
    final inactive = total - active;
    final premium = suppliers.where((s) => s['type'] == 'Premium').length;
    final standard = total - premium;
    final totalOrders = suppliers.fold<int>(
      0,
      (sum, s) => sum + (s['totalOrders'] as int),
    );
    final totalAmount = suppliers.fold<double>(
      0.0,
      (sum, s) => sum + s['totalAmount'],
    );

    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'premium': premium,
      'standard': standard,
      'totalOrders': totalOrders,
      'totalAmount': totalAmount,
    };
  }

  /// Özet kartları
  Widget _buildSummaryCards() {
    final stats = _calculateStats();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Toplam Tedarikçi',
          stats['total'].toString(),
          Icons.business,
          Colors.blue,
        ),
        _buildStatCard(
          'Aktif Tedarikçi',
          stats['active'].toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Toplam Sipariş',
          stats['totalOrders'].toString(),
          Icons.shopping_cart,
          Colors.orange,
        ),
        _buildStatCard(
          'Toplam Tutar',
          '₺${NumberFormat('#,##0').format(stats['totalAmount'])}',
          Icons.attach_money,
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
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

  /// Tedarikçi listesi
  Widget _buildSupplierList() {
    final suppliers = _getFilteredSuppliers();

    if (suppliers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.business_outlined,
              size: 64,
              color: TamgaciConstants.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              'Tedarikçi bulunamadı',
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
          'Tedarikçi Listesi (${suppliers.length})',
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
          itemCount: suppliers.length,
          itemBuilder: (context, index) {
            final supplier = suppliers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: supplier['status'] == 'Aktif'
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.business,
                            color: supplier['status'] == 'Aktif'
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supplier['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                supplier['email'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: TamgaciConstants.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: supplier['status'] == 'Aktif'
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            supplier['status'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: supplier['status'] == 'Aktif'
                                  ? Colors.green
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'Telefon',
                            supplier['phone'],
                            Icons.phone,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            'Tip',
                            supplier['type'],
                            Icons.category,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'Toplam Sipariş',
                            supplier['totalOrders'].toString(),
                            Icons.shopping_cart,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            'Toplam Tutar',
                            '₺${NumberFormat('#,##0').format(supplier['totalAmount'])}',
                            Icons.attach_money,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'Son Sipariş',
                            DateFormat(
                              'dd.MM.yyyy',
                            ).format(supplier['lastOrderDate']),
                            Icons.calendar_today,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Bilgi öğesi
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: TamgaciConstants.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: TamgaciConstants.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
