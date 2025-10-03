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
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/excel_service.dart';
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
    // Provider'ı yenile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(customersProvider);
    });
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
        if (customer.category1 != _selectedCategory) return false;
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

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TamgaciConstants.primaryColor,
            Color(0xFF4C6EF5),
            TamgaciConstants.primaryColorDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: TamgaciConstants.primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Müşteriler',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Müşteri bilgilerini yönetin ve takip edin',
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 8),
          Text(
            'Bugün: ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now())}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customersAsync = ref.watch(customersProvider);

    return ResponsiveScaffold(
      appBar: const CustomAppBar(title: 'Müşteriler', showDrawer: true),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildWelcomeCard(isDark),
                const SizedBox(height: 16),
                _buildSearchAndFilters(isDark),
                const SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 300,
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
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, TamgaciRoutes.createCustomer);
                },
                icon: const Icon(Icons.person_add),
                label: Text(
                  'Yeni Müşteri',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                backgroundColor: TamgaciConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
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
                icon: const Icon(Icons.table_chart),
                tooltip: 'Excel\'e Aktar',
              ),
              // CSV dışa aktarım
              IconButton(
                onPressed: () {
                  _exportToCSV();
                },
                icon: const Icon(Icons.description),
                tooltip: 'CSV\'ye Aktar',
              ),
              // PDF dışa aktarım
              IconButton(
                onPressed: () {
                  _exportToPDF();
                },
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: 'PDF\'ye Aktar',
              ),
              // Excel/CSV içe aktarım
              IconButton(
                onPressed: () {
                  _importFromExcel();
                },
                icon: const Icon(Icons.file_upload),
                tooltip: 'Dosyadan İçe Aktar',
              ),
              // Yeni müşteri
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/customers/create');
                },
                icon: const Icon(Icons.person_add),
                tooltip: 'Yeni Müşteri',
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
                  const SizedBox(width: 8),
                  if (customer.branches != null &&
                      customer.branches!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.blueGrey : Colors.blue)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (isDark ? Colors.blueGrey : Colors.blue)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_tree_rounded,
                              size: 16,
                              color: isDark ? Colors.blueGrey : Colors.blue),
                          const SizedBox(width: 4),
                          Text('${customer.branches!.length}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDark ? Colors.blueGrey : Colors.blue)),
                        ],
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
                  if (customer.category1 != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        customer.category1!,
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
                      Navigator.pushNamed(
                        context,
                        TamgaciRoutes.createSale,
                        arguments: {
                          'customerId': customer.id,
                          'customerName': customer.name,
                        },
                      );
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

  void _exportToCSV() async {
    try {
      final customersAsync = ref.read(customersProvider);
      final customers = customersAsync.when(
        data: (data) => data,
        loading: () => throw Exception('Müşteriler yükleniyor'),
        error: (error, stack) =>
            throw Exception('Müşteriler yüklenemedi: $error'),
      );

      if (customers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dışa aktarılacak müşteri bulunamadı'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final fileName = await ExcelService.exportCustomersToCSV(customers);

      // Loading'i kapat
      Navigator.of(context).pop();

      if (fileName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName dosyası başarıyla oluşturuldu'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Paylaş',
              textColor: Colors.white,
              onPressed: () => _shareFile(fileName),
            ),
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV dışa aktarım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportToPDF() async {
    try {
      final customersAsync = ref.read(customersProvider);
      final customers = customersAsync.when(
        data: (data) => data,
        loading: () => throw Exception('Müşteriler yükleniyor'),
        error: (error, stack) =>
            throw Exception('Müşteriler yüklenemedi: $error'),
      );

      if (customers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dışa aktarılacak müşteri bulunamadı'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final fileName = await ExcelService.exportCustomersToPDF(customers);

      // Loading'i kapat
      Navigator.of(context).pop();

      if (fileName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName dosyası başarıyla oluşturuldu'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Paylaş',
              textColor: Colors.white,
              onPressed: () => _shareFile(fileName),
            ),
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF dışa aktarım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportToExcel() async {
    try {
      final customersAsync = ref.read(customersProvider);
      final customers = customersAsync.when(
        data: (data) => data,
        loading: () => throw Exception('Müşteriler yükleniyor'),
        error: (error, stack) =>
            throw Exception('Müşteriler yüklenemedi: $error'),
      );

      if (customers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dışa aktarılacak müşteri bulunamadı'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final fileName = await ExcelService.exportCustomersToExcel(customers);

      // Loading'i kapat
      Navigator.of(context).pop();

      if (fileName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName dosyası başarıyla oluşturuldu'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Paylaş',
              textColor: Colors.white,
              onPressed: () => _shareFile(fileName),
            ),
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel dışa aktarım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _importFromExcel() async {
    try {
      // Import seçenekleri göster
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Müşteri İçe Aktarım',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Excel Dosyası (.xlsx)'),
                subtitle: const Text('Excel formatında müşteri listesi'),
                onTap: () {
                  Navigator.pop(context);
                  _importFromExcelFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.description, color: Colors.blue),
                title: const Text('CSV Dosyası (.csv)'),
                subtitle: const Text('Virgülle ayrılmış değerler'),
                onTap: () {
                  Navigator.pop(context);
                  _importFromCSVFile();
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İçe aktarım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _importFromExcelFile() async {
    try {
      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final customers = await ExcelService.importCustomersFromExcel();

      // Loading'i kapat
      Navigator.of(context).pop();

      if (customers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel dosyasında geçerli müşteri bulunamadı'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Onay dialogu göster
      final shouldImport = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Müşteri İçe Aktarım'),
          content: Text(
              '${customers.length} müşteri içe aktarılacak. Devam etmek istiyor musunuz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('İçe Aktar'),
            ),
          ],
        ),
      );

      if (shouldImport == true) {
        // Müşterileri kaydet
        final repository = ref.read(customerRepositoryProvider);
        await repository.createCustomers(customers);

        // Provider'ı yenile
        ref.invalidate(customersProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${customers.length} müşteri başarıyla içe aktarıldı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel içe aktarım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _importFromCSVFile() async {
    try {
      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final customers = await ExcelService.importCustomersFromCSV();

      // Loading'i kapat
      Navigator.of(context).pop();

      if (customers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV dosyasında geçerli müşteri bulunamadı'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Onay dialogu göster
      final shouldImport = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Müşteri İçe Aktarım'),
          content: Text(
              '${customers.length} müşteri içe aktarılacak. Devam etmek istiyor musunuz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('İçe Aktar'),
            ),
          ],
        ),
      );

      if (shouldImport == true) {
        // Müşterileri kaydet
        final repository = ref.read(customerRepositoryProvider);
        await repository.createCustomers(customers);

        // Provider'ı yenile
        ref.invalidate(customersProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${customers.length} müşteri başarıyla içe aktarıldı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV içe aktarım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareFile(String fileName) async {
    try {
      // TODO: Dosya paylaşım implementasyonu
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName dosyası paylaşım için hazır'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dosya paylaşım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
