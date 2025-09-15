// ========== SUPPLIER DETAIL PAGE ==========
// lib/features/suppliers/presentation/pages/supplier_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/supplier_providers.dart';
import '../../domain/entities/supplier.dart';

/// Tedarikçi detay sayfası
class SupplierDetailPage extends ConsumerStatefulWidget {
  final String supplierId;

  const SupplierDetailPage({super.key, required this.supplierId});

  @override
  ConsumerState<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends ConsumerState<SupplierDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadSupplier();
  }

  void _loadSupplier() {
    // Tedarikçi verisi zaten provider'da yüklü olmalı
  }

  /// Tedarikçi düzenleme sayfasına git
  void _navigateToEdit() {
    Navigator.of(
      context,
    ).pushNamed('/supplier/edit', arguments: widget.supplierId);
  }

  /// Tedarikçi silme işlemi
  void _deleteSupplier() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tedarikçi Sil'),
        content: const Text(
          'Bu tedarikçi kaydını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              await ref
                  .read(supplierOperationsProvider.notifier)
                  .deleteSupplier(widget.supplierId);
              if (mounted) {
                navigator.pop(); // Detay sayfasından çık
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Tedarikçi Detayı',
        showBackButton: true,
        showDrawer: false,
        actions: [
          IconButton(
            onPressed: _navigateToEdit,
            icon: const Icon(Icons.edit),
            tooltip: 'Düzenle',
          ),
          IconButton(
            onPressed: _deleteSupplier,
            icon: const Icon(Icons.delete),
            tooltip: 'Sil',
            color: Colors.red,
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final supplierAsync = ref.watch(supplierProvider(widget.supplierId));

          return supplierAsync.when(
            data: (supplier) {
              if (supplier == null) {
                return const Center(child: Text('Tedarikçi bulunamadı'));
              }

              return _buildSupplierDetail(supplier);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hata: $error'),
                  ElevatedButton(
                    onPressed: () =>
                        ref.invalidate(supplierProvider(widget.supplierId)),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSupplierDetail(Supplier supplier) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return SingleChildScrollView(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık kartı
          Card(
            child: Padding(
              padding: TamgaciConstants.cardPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          supplier.name,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: TamgaciConstants.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(supplier.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          supplier.status.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kredi Limiti: ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(supplier.creditLimit)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: TamgaciConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mevcut Bakiye: ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(supplier.currentBalance)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // İletişim bilgileri
          _buildDetailCard(
            title: 'İletişim Bilgileri',
            children: [
              _buildDetailRow('İletişim Kişisi', supplier.contactPerson ?? ''),
              _buildDetailRow('E-posta', supplier.email ?? ''),
              _buildDetailRow('Telefon', supplier.phone ?? ''),
              _buildDetailRow('Adres', supplier.address ?? ''),
            ],
          ),

          const SizedBox(height: 16),

          // Vergi bilgileri
          _buildDetailCard(
            title: 'Vergi Bilgileri',
            children: [
              _buildDetailRow('Vergi No', supplier.taxNumber ?? ''),
              _buildDetailRow('Vergi Dairesi', supplier.taxOffice ?? ''),
            ],
          ),

          const SizedBox(height: 16),

          // Banka bilgileri
          _buildDetailCard(
            title: 'Banka Bilgileri',
            children: [
              _buildDetailRow('Banka Adı', supplier.bankName ?? ''),
              _buildDetailRow('Hesap No', supplier.bankAccount ?? ''),
            ],
          ),

          const SizedBox(height: 16),

          // Sistem bilgileri
          _buildDetailCard(
            title: 'Sistem Bilgileri',
            children: [
              _buildDetailRow(
                'Oluşturulma',
                dateFormat.format(supplier.createdAt),
              ),
              _buildDetailRow(
                'Güncellenme',
                dateFormat.format(supplier.updatedAt),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Aksiyon butonları
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Alım geçmişi
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alım geçmişi yakında eklenecek'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Alım Geçmişi'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Ödeme planları
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ödeme planları yakında eklenecek'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Ödeme Planları'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // PDF export
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF export yakında eklenecek'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF İndir'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Paylaş
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paylaş özelliği yakında eklenecek'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Paylaş'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: TamgaciConstants.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SupplierStatus status) {
    switch (status) {
      case SupplierStatus.active:
        return Colors.green;
      case SupplierStatus.inactive:
        return Colors.grey;
      case SupplierStatus.suspended:
        return Colors.orange;
    }
  }
}
