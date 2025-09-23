// ========== WAREHOUSE DETAIL PAGE ==========
// lib/features/inventory/presentation/pages/warehouse_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/providers/currency_providers.dart';
import '../providers/warehouse_providers.dart';
import '../../domain/entities/warehouse.dart';

class WarehouseDetailPage extends ConsumerWidget {
  final String warehouseId;

  const WarehouseDetailPage({
    super.key,
    required this.warehouseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warehousesAsync = ref.watch(warehousesProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Depo Detayı',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                TamgaciRoutes.editWarehouse,
                arguments: warehouseId,
              );
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Düzenle',
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: warehousesAsync.when(
        data: (warehouses) {
          final warehouse = warehouses.firstWhere(
            (w) => w.id.toString() == warehouseId,
            orElse: () => Warehouse(
              id: '0',
              name: 'Depo Bulunamadı',
              currency: 'TRY',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          return _buildWarehouseDetail(warehouse, isDark, ref, context);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child:
              Text('Hata: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildWarehouseDetail(
      Warehouse warehouse, bool isDark, WidgetRef ref, BuildContext context) {
    final selectedCurrency = ref.watch(selectedCurrencyProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(warehouse, isDark),
          const SizedBox(height: 16),
          _buildBasicInfoCard(warehouse, isDark),
          const SizedBox(height: 16),
          _buildContactInfoCard(warehouse, isDark),
          const SizedBox(height: 16),
          _buildCapacityInfoCard(warehouse, isDark, selectedCurrency),
          const SizedBox(height: 16),
          _buildSettingsCard(warehouse, isDark),
          const SizedBox(height: 16),
          _buildTimelineCard(warehouse, isDark),
          const SizedBox(height: 32),
          _buildActionButtons(isDark, context),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Warehouse warehouse, bool isDark) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.blue.withValues(alpha: 0.8), Colors.blue]
                : [Colors.blue, Colors.blue.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    warehouse.isDefault ? Icons.star : Icons.warehouse,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        warehouse.name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (warehouse.code != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Kod: ${warehouse.code}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
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
                    color: warehouse.isActive
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: warehouse.isActive ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    warehouse.isActive ? 'Aktif' : 'Pasif',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: warehouse.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            if (warehouse.description != null) ...[
              const SizedBox(height: 16),
              Text(
                warehouse.description!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(Warehouse warehouse, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Temel Bilgiler',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Depo Adı', warehouse.name, Icons.warehouse, isDark),
            if (warehouse.code != null)
              _buildInfoRow('Depo Kodu', warehouse.code!, Icons.code, isDark),
            if (warehouse.description != null)
              _buildInfoRow('Açıklama', warehouse.description!,
                  Icons.description, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(Warehouse warehouse, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.contact_phone,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'İletişim Bilgileri',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (warehouse.address != null)
              _buildInfoRow(
                  'Adres', warehouse.address!, Icons.location_on, isDark),
            if (warehouse.phone != null)
              _buildInfoRow('Telefon', warehouse.phone!, Icons.phone, isDark),
            if (warehouse.email != null)
              _buildInfoRow('E-posta', warehouse.email!, Icons.email, isDark),
            if (warehouse.manager != null)
              _buildInfoRow(
                  'Yönetici', warehouse.manager!, Icons.person, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityInfoCard(
      Warehouse warehouse, bool isDark, dynamic selectedCurrency) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.straighten,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Kapasite Bilgileri',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (warehouse.capacity != null)
              _buildInfoRow(
                'Kapasite',
                '${warehouse.capacity!.toStringAsFixed(0)} ${warehouse.capacityUnit ?? 'birim'}',
                Icons.straighten,
                isDark,
              ),
            _buildInfoRow(
              'Para Birimi',
              '${CurrencyHelper.getCurrencySymbol(warehouse.currency)} ${warehouse.currency}',
              Icons.currency_exchange,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(Warehouse warehouse, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.settings,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ayarlar',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusRow('Durum', warehouse.isActive ? 'Aktif' : 'Pasif',
                warehouse.isActive ? Colors.green : Colors.red, isDark),
            _buildStatusRow(
                'Varsayılan',
                warehouse.isDefault ? 'Evet' : 'Hayır',
                warehouse.isDefault ? Colors.purple : Colors.grey,
                isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(Warehouse warehouse, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Zaman Çizelgesi',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Oluşturulma', _formatDateTime(warehouse.createdAt),
                Icons.add_circle, isDark),
            _buildInfoRow('Son Güncelleme',
                _formatDateTime(warehouse.updatedAt), Icons.update, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TamgaciConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: TamgaciConstants.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark
                        ? TamgaciConstants.textSecondaryDark
                        : TamgaciConstants.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_circle,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark
                        ? TamgaciConstants.textSecondaryDark
                        : TamgaciConstants.textSecondary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(
                TamgaciRoutes.editWarehouse,
                arguments: warehouseId,
              );
            },
            icon: const Icon(Icons.edit),
            label: Text(
              'Düzenle',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: TamgaciConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showDeleteConfirmation(context);
            },
            icon: const Icon(Icons.delete),
            label: Text(
              'Sil',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Depo Silme',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bu depoyu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: TamgaciConstants.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Depo silme işlemi henüz implement edilmedi'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Sil',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
