// ========== SUPPLIERS (TEDARİKÇİLER) FEATURE ==========
// lib/features/suppliers/presentation/pages/suppliers_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/supplier_providers.dart';
import '../../domain/entities/supplier.dart';

/// Tedarikçi listesi sayfası
class SuppliersListPage extends ConsumerStatefulWidget {
  const SuppliersListPage({super.key});

  @override
  ConsumerState<SuppliersListPage> createState() => _SuppliersListPageState();
}

class _SuppliersListPageState extends ConsumerState<SuppliersListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadSuppliers();
  }

  void _loadSuppliers() {
    // Tedarikçiler zaten provider'da yüklü olmalı
    // Eğer yüklü değilse yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final operationsState = ref.read(supplierOperationsProvider);
      if (operationsState.suppliers.isEmpty && !operationsState.isLoading) {
        ref.read(supplierOperationsProvider.notifier).loadSuppliers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Arama değişikliği dinleyicisi
  void _onSearchChanged() {
    setState(() {});
  }

  /// Yeni tedarikçi ekleme sayfasına git
  void _navigateToCreate() {
    Navigator.of(context).pushNamed('/suppliers/create');
  }

  /// Tedarikçi detay sayfasına git
  void _navigateToDetail(String supplierId) {
    Navigator.of(context).pushNamed('/suppliers/detail', arguments: supplierId);
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(supplierOperationsProvider);
    final searchQuery = _searchController.text;

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Tedarikçiler',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(onPressed: _navigateToCreate, icon: const Icon(Icons.add)),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          // Arama çubuğu
          Container(
            padding: TamgaciConstants.paddingMedium(context),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tedarikçi ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                ),
              ),
            ),
          ),

          // Tedarikçi listesi
          Expanded(child: _buildSuppliersList(operationsState, searchQuery)),
        ],
      ),
    );
  }

  /// Tedarikçi listesini oluşturur
  Widget _buildSuppliersList(
    SupplierOperationsState operationsState,
    String searchQuery,
  ) {
    if (operationsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (operationsState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hata: ${operationsState.errorMessage}'),
            ElevatedButton(
              onPressed: _loadSuppliers,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    final suppliers = operationsState.suppliers;

    // Arama filtresi uygula
    List<Supplier> filteredSuppliers = suppliers;
    if (searchQuery.isNotEmpty) {
      filteredSuppliers = suppliers.where((supplier) {
        return supplier.name.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            supplier.contactPerson.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            supplier.email.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (filteredSuppliers.isEmpty && !operationsState.isLoading) {
      return EmptyStateWidget(
        icon: Icons.business_outlined,
        title: 'Tedarikçi Bulunamadı',
        message: searchQuery.isNotEmpty
            ? 'Arama kriterlerinize uygun tedarikçi bulunamadı.'
            : 'Henüz tedarikçi kaydı bulunmuyor.\nYeni tedarikçi eklemek için + butonuna tıklayın.',
        actionButton: searchQuery.isEmpty
            ? ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add),
                label: const Text('Tedarikçi Ekle'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(supplierOperationsProvider.notifier).loadSuppliers();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredSuppliers.length,
        itemBuilder: (context, index) {
          final supplier = filteredSuppliers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSupplierCard(supplier),
          );
        },
      ),
    );
  }

  /// Tedarikçi kartı oluşturur
  Widget _buildSupplierCard(Supplier supplier) {
    final isActive = supplier.status == SupplierStatus.active;
    final hasOutstandingBalance = supplier.currentBalance > 0;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(supplier.id),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: TamgaciConstants.cardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım - Şirket adı ve durum
              Row(
                children: [
                  // Şirket ikonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          (isActive
                                  ? TamgaciConstants.successColor
                                  : TamgaciConstants.errorColor)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        TamgaciConstants.radiusSM,
                      ),
                    ),
                    child: Icon(
                      Icons.business,
                      color: isActive
                          ? TamgaciConstants.successColor
                          : TamgaciConstants.errorColor,
                      size: 24,
                    ),
                  ),

                  SizedBox(width: TamgaciConstants.spaceMD),

                  // Şirket bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: TamgaciConstants.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          supplier.contactPerson,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: TamgaciConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: TamgaciConstants.spaceSM),

                  // Durum
                  _buildStatusChip(isActive),
                ],
              ),

              SizedBox(height: TamgaciConstants.spaceMD),

              // İletişim bilgileri
              Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 16,
                    color: TamgaciConstants.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      supplier.email,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: TamgaciConstants.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4),

              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: TamgaciConstants.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    supplier.phone,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: TamgaciConstants.spaceMD),

              // Alt kısım - Finansal bilgiler
              Row(
                children: [
                  // Kredi limiti
                  Expanded(
                    child: _buildFinancialInfo(
                      label: 'Kredi Limiti',
                      value:
                          '₺${NumberFormat('#,##0', 'tr_TR').format(supplier.creditLimit)}',
                      color: TamgaciConstants.primaryColor,
                    ),
                  ),

                  SizedBox(width: TamgaciConstants.spaceMD),

                  // Mevcut bakiye
                  Expanded(
                    child: _buildFinancialInfo(
                      label: 'Mevcut Bakiye',
                      value:
                          '₺${NumberFormat('#,##0', 'tr_TR').format(supplier.currentBalance)}',
                      color: hasOutstandingBalance
                          ? TamgaciConstants.errorColor
                          : TamgaciConstants.successColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Durum chip'i oluşturur
  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? TamgaciConstants.successColor.withValues(alpha: 0.1)
            : TamgaciConstants.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Pasif',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isActive
              ? TamgaciConstants.successColor
              : TamgaciConstants.errorColor,
        ),
      ),
    );
  }

  /// Finansal bilgi widget'ı oluşturur
  Widget _buildFinancialInfo({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: TamgaciConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Filtre dialog'unu gösterir
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreler'),
        content: const Text('Filtre özellikleri yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
