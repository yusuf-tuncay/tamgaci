import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../core/routes/routes.dart';
import '../providers/warehouse_providers.dart';
import '../../domain/entities/warehouse.dart';

class WarehouseListPage extends ConsumerWidget {
  const WarehouseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warehousesAsync = ref.watch(warehousesProvider);

    return ResponsiveScaffold(
      appBar: const CustomAppBar(title: 'Depo Listesi', showDrawer: true),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: Stack(
        children: [
          warehousesAsync.when(
            data: (warehouses) => _buildWarehouseList(warehouses, isDark, ref),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Hata: $error',
                  style: const TextStyle(color: Colors.red)),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(TamgaciRoutes.createWarehouse);
              },
              backgroundColor: TamgaciConstants.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseList(
      List<Warehouse> warehouses, bool isDark, WidgetRef ref) {
    if (warehouses.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.warehouse,
        title: 'Henüz Depo Yok',
        message: 'İlk deponuzu ekleyerek başlayın',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: warehouses.length,
      itemBuilder: (context, index) {
        final warehouse = warehouses[index];
        return _buildWarehouseCard(warehouse, isDark, ref, context);
      },
    );
  }

  Widget _buildWarehouseCard(
      Warehouse warehouse, bool isDark, WidgetRef ref, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            TamgaciRoutes.warehouseDetail,
            arguments: warehouse.id.toString(),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: warehouse.isDefault
                          ? Colors.purple.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      warehouse.isDefault ? Icons.star : Icons.warehouse,
                      color: warehouse.isDefault ? Colors.purple : Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                warehouse.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : TamgaciConstants.textPrimary,
                                ),
                              ),
                            ),
                            if (warehouse.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Varsayılan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.purple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          warehouse.code ?? 'Kod yok',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: TamgaciConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: warehouse.isActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      warehouse.isActive ? 'Aktif' : 'Pasif',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: warehouse.isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (warehouse.description != null) ...[
                Text(
                  warehouse.description!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TamgaciConstants.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.location_on,
                      warehouse.address ?? 'Adres yok',
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.person,
                      warehouse.manager ?? 'Yönetici yok',
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.straighten,
                      warehouse.capacity != null
                          ? '${warehouse.capacity!.toStringAsFixed(0)} ${warehouse.capacityUnit ?? 'birim'}'
                          : 'Kapasite yok',
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.currency_exchange,
                      '${CurrencyHelper.getCurrencySymbol(warehouse.currency)} ${warehouse.currency}',
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Oluşturulma: ${_formatDate(warehouse.createdAt)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            TamgaciRoutes.editWarehouse,
                            arguments: warehouse.id.toString(),
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: TamgaciConstants.primaryColor,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Depo silme
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: TamgaciConstants.textSecondary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: TamgaciConstants.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
