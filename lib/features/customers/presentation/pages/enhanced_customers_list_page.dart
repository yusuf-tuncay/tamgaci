// ========== ENHANCED CUSTOMERS LIST PAGE ==========
// lib/features/customers/presentation/pages/enhanced_customers_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../core/routes/routes.dart';
import '../../domain/entities/customer.dart';
import '../providers/customer_providers.dart';

/// Gelişmiş müşteri listesi sayfası
class EnhancedCustomersListPage extends ConsumerStatefulWidget {
  const EnhancedCustomersListPage({super.key});

  @override
  ConsumerState<EnhancedCustomersListPage> createState() =>
      _EnhancedCustomersListPageState();
}

class _EnhancedCustomersListPageState
    extends ConsumerState<EnhancedCustomersListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  String _sortBy = 'name';
  bool _sortAscending = true;
  bool _showOnlyWithBalance = false;

  final List<String> _categories = [
    'Tümü',
    'VIP',
    'Normal',
    'Kurumsal',
    'Bireysel'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<Customer> _filterAndSortCustomers(List<Customer> customers) {
    var filtered = customers.where((customer) {
      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = customer.name
                .toLowerCase()
                .contains(_searchQuery) ||
            customer.phone?.toLowerCase().contains(_searchQuery) == true ||
            customer.customerCode?.toLowerCase().contains(_searchQuery) == true;
        if (!matchesSearch) return false;
      }

      // Kategori filtresi
      if (_selectedCategory != 'Tümü') {
        if (customer.category != _selectedCategory) return false;
      }

      // Bakiye filtresi
      if (_showOnlyWithBalance) {
        if (customer.balance == 0) return false;
      }

      return true;
    }).toList();

    // Sıralama
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'balance':
          comparison = a.balance.compareTo(b.balance);
          break;
        case 'phone':
          comparison = (a.phone ?? '').compareTo(b.phone ?? '');
          break;
        case 'code':
          comparison = (a.customerCode ?? '').compareTo(b.customerCode ?? '');
          break;
        case 'date':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Müşteriler', showDrawer: true),
      drawer: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          _buildSearchAndFilters(isDark),
          Expanded(
            child: customersAsync.when(
              data: (customers) => _buildCustomersList(customers, isDark),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Müşteriler yüklenirken hata oluştu',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, TamgaciRoutes.createCustomer);
        },
        icon: const Icon(Icons.person_add),
        label: Text(
          'Yeni Müşteri',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Column(
        children: [
          // Arama çubuğu
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Müşteri ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[700] : Colors.grey[50],
            ),
          ),
          const SizedBox(height: 12),
          // Filtreler
          Row(
            children: [
              // Kategori filtresi
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Sıralama
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  decoration: InputDecoration(
                    labelText: 'Sırala',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('İsim')),
                    DropdownMenuItem(value: 'balance', child: Text('Bakiye')),
                    DropdownMenuItem(value: 'phone', child: Text('Telefon')),
                    DropdownMenuItem(value: 'code', child: Text('Kod')),
                    DropdownMenuItem(value: 'date', child: Text('Tarih')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Sıralama yönü
              IconButton(
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                },
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                tooltip: _sortAscending ? 'Artan' : 'Azalan',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bakiye filtresi
          Row(
            children: [
              Checkbox(
                value: _showOnlyWithBalance,
                onChanged: (value) {
                  setState(() {
                    _showOnlyWithBalance = value!;
                  });
                },
              ),
              Text(
                'Sadece bakiyeli müşteriler',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const Spacer(),
              // Excel dışa aktarım
              IconButton(
                onPressed: () {
                  _exportToExcel();
                },
                icon: const Icon(Icons.file_download),
                tooltip: 'Excel\'e Aktar',
              ),
              // Excel içe aktarım
              IconButton(
                onPressed: () {
                  _importFromExcel();
                },
                icon: const Icon(Icons.file_upload),
                tooltip: 'Excel\'den İçe Aktar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList(List<Customer> customers, bool isDark) {
    final filteredCustomers = _filterAndSortCustomers(customers);

    if (filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ||
                      _selectedCategory != 'Tümü' ||
                      _showOnlyWithBalance
                  ? 'Arama kriterlerinize uygun müşteri bulunamadı'
                  : 'Henüz müşteri eklenmemiş',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            if (_searchQuery.isNotEmpty ||
                _selectedCategory != 'Tümü' ||
                _showOnlyWithBalance) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedCategory = 'Tümü';
                    _showOnlyWithBalance = false;
                  });
                },
                child: const Text('Filtreleri Temizle'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(customersProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredCustomers.length,
        itemBuilder: (context, index) {
          final customer = filteredCustomers[index];
          return _buildCustomerCard(customer, isDark);
        },
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer, bool isDark) {
    final balanceColor = customer.balance > 0
        ? Colors.green
        : customer.balance < 0
            ? Colors.red
            : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            TamgaciRoutes.customerDetail,
            arguments: customer.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır - İsim ve bakiye
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.grey[800],
                          ),
                        ),
                        if (customer.customerCode != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Kod: ${customer.customerCode}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: balanceColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: balanceColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      CurrencyHelper.formatCurrency(customer.balance, 'TRY'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: balanceColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Orta satır - Telefon ve kategori
              Row(
                children: [
                  if (customer.phone != null) ...[
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      customer.phone!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (customer.category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        customer.category!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (customer.email != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      customer.email!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              // Alt satır - Tarih ve hızlı işlemler
              Row(
                children: [
                  Text(
                    'Kayıt: ${DateFormat('dd.MM.yyyy').format(customer.createdAt)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  // Hızlı işlem butonları
                  IconButton(
                    onPressed: () {
                      _showQuickActions(customer);
                    },
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'Hızlı İşlemler',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions(Customer customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hızlı İşlemler - ${customer.name}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Satış yap
                    },
                    icon: const Icon(Icons.sell),
                    label: const Text('Satış Yap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Tahsilat yap
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Tahsilat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Hesap ekstresi
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Hesap Ekstresi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        TamgaciRoutes.editCustomer,
                        arguments: customer.id,
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportToExcel() {
    // TODO: Excel dışa aktarım implementasyonu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel dışa aktarım özelliği yakında eklenecek'),
      ),
    );
  }

  void _importFromExcel() {
    // TODO: Excel içe aktarım implementasyonu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel içe aktarım özelliği yakında eklenecek'),
      ),
    );
  }
}
