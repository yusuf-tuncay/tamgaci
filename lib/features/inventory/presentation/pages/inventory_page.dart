import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/routes/routes.dart';
import '../providers/inventory_providers.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventorySummaryAsync = ref.watch(inventorySummaryProvider);
    final inventoryStatsAsync = ref.watch(inventoryStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Depo Stok Yönetimi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        backgroundColor: TamgaciConstants.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(inventorySummaryProvider);
              ref.invalidate(inventoryStatsProvider);
            },
            icon: const Icon(Icons.refresh),
            color: TamgaciConstants.primaryColor,
          ),
        ],
      ),
      body: inventorySummaryAsync.when(
        data: (summary) =>
            _buildContent(context, ref, summary, inventoryStatsAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: TamgaciConstants.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Hata oluştu',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: TamgaciConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TamgaciConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          TamgaciRoutes.pushNamed(context, TamgaciRoutes.createStockMovement);
        },
        backgroundColor: TamgaciConstants.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Stok Hareketi',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    InventorySummary summary,
    AsyncValue<InventoryStats> statsAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Özet kartları
          _buildSummaryCards(context, summary),

          SizedBox(height: TamgaciConstants.spaceLG),

          // Hızlı işlemler
          _buildQuickActions(context),

          SizedBox(height: TamgaciConstants.spaceLG),

          // Stok istatistikleri
          _buildStockStats(context, statsAsync),

          SizedBox(height: TamgaciConstants.spaceLG),

          // Son stok hareketleri
          _buildRecentMovements(context, ref),
        ],
      ),
    );
  }

  /// Özet kartları
  Widget _buildSummaryCards(BuildContext context, InventorySummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stok Özeti',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        SizedBox(height: TamgaciConstants.spaceMD),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: TamgaciConstants.isMobile(context) ? 2 : 4,
            crossAxisSpacing: TamgaciConstants.spaceMD,
            mainAxisSpacing: TamgaciConstants.spaceMD,
            childAspectRatio: 1.2,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final cards = [
              {
                'title': 'Toplam Stok Değeri',
                'amount': summary.formattedTotalStockValue,
                'icon': Icons.attach_money,
                'color': TamgaciConstants.successColor,
                'gradient': LinearGradient(
                  colors: [
                    TamgaciConstants.successColor.withValues(alpha: 0.15),
                    TamgaciConstants.successColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              },
              {
                'title': 'Düşük Stok',
                'amount': summary.formattedLowStockCount,
                'icon': Icons.warning,
                'color': TamgaciConstants.warningColor,
                'gradient': LinearGradient(
                  colors: [
                    TamgaciConstants.warningColor.withValues(alpha: 0.15),
                    TamgaciConstants.warningColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              },
              {
                'title': 'Stokta Olmayan',
                'amount': summary.formattedOutOfStockCount,
                'icon': Icons.remove_shopping_cart,
                'color': TamgaciConstants.errorColor,
                'gradient': LinearGradient(
                  colors: [
                    TamgaciConstants.errorColor.withValues(alpha: 0.15),
                    TamgaciConstants.errorColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              },
              {
                'title': 'Depo Sayısı',
                'amount': summary.formattedWarehouseCount,
                'icon': Icons.warehouse,
                'color': TamgaciConstants.primaryColor,
                'gradient': LinearGradient(
                  colors: [
                    TamgaciConstants.primaryColor.withValues(alpha: 0.15),
                    TamgaciConstants.primaryColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              },
            ];

            final card = cards[index];
            return Container(
              padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
              decoration: BoxDecoration(
                gradient: card['gradient'] as LinearGradient,
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
                border: Border.all(
                  color: (card['color'] as Color).withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (card['color'] as Color).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (card['color'] as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      card['icon'] as IconData,
                      color: card['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    card['amount'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TamgaciConstants.textPrimary,
                    ),
                  ),
                  Text(
                    card['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Hızlı işlemler
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        SizedBox(height: TamgaciConstants.spaceMD),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: TamgaciConstants.isMobile(context) ? 2 : 4,
            crossAxisSpacing: TamgaciConstants.spaceMD,
            mainAxisSpacing: TamgaciConstants.spaceMD,
            childAspectRatio: 1.5,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final actions = [
              {
                'title': 'Stok Girişi',
                'icon': Icons.input,
                'color': TamgaciConstants.successColor,
                'route': TamgaciRoutes.createStockIn,
                'gradient': LinearGradient(
                  colors: [
                    TamgaciConstants.successColor.withValues(alpha: 0.15),
                    TamgaciConstants.successColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              },
              {
                'title': 'Stok Çıkışı',
                'icon': Icons.output,
                'color': TamgaciConstants.errorColor,
                'route': TamgaciRoutes.createStockOut,
                'gradient': LinearGradient(
                  colors: [
                    TamgaciConstants.errorColor.withValues(alpha: 0.15),
                    TamgaciConstants.errorColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              },
              {
                'title': 'Stok Düzeltme',
                'icon': Icons.edit,
                'color': TamgaciConstants.warningColor,
                'route': TamgaciRoutes.createStockAdjustment,
                'gradient': LinearGradient(
                  colors: [
                    TamgaciConstants.warningColor.withValues(alpha: 0.15),
                    TamgaciConstants.warningColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              },
              {
                'title': 'Depo Transfer',
                'icon': Icons.swap_horiz,
                'color': TamgaciConstants.primaryColor,
                'route': TamgaciRoutes.createStockTransfer,
                'gradient': LinearGradient(
                  colors: [
                    TamgaciConstants.primaryColor.withValues(alpha: 0.15),
                    TamgaciConstants.primaryColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              },
            ];

            final action = actions[index];
            return InkWell(
              onTap: () {
                // Şimdilik products list'e yönlendir
                TamgaciRoutes.pushNamed(context, TamgaciRoutes.productsList);
              },
              borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
              child: Container(
                padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
                decoration: BoxDecoration(
                  gradient: action['gradient'] as LinearGradient,
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                  border: Border.all(
                    color: (action['color'] as Color).withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (action['color'] as Color).withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      action['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TamgaciConstants.textPrimary,
                      ),
                      textAlign: TextAlign.center,
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

  /// Stok istatistikleri
  Widget _buildStockStats(
    BuildContext context,
    AsyncValue<InventoryStats> statsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stok İstatistikleri',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        SizedBox(height: TamgaciConstants.spaceMD),
        statsAsync.when(
          data: (stats) => Column(
            children: [
              // En değerli ürünler
              _buildTopValueItems(context, stats.topValueItems),
              SizedBox(height: TamgaciConstants.spaceLG),
              // En çok stoklu ürünler
              _buildTopQuantityItems(context, stats.topQuantityItems),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'İstatistikler yüklenemedi: $error',
              style: GoogleFonts.poppins(color: TamgaciConstants.errorColor),
            ),
          ),
        ),
      ],
    );
  }

  /// En değerli ürünler
  Widget _buildTopValueItems(BuildContext context, List<dynamic> items) {
    return Container(
      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
      decoration: BoxDecoration(
        color: TamgaciConstants.cardColor,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        boxShadow: TamgaciConstants.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'En Değerli Ürünler',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: TamgaciConstants.textPrimary,
            ),
          ),
          SizedBox(height: TamgaciConstants.spaceMD),
          if (items.isEmpty)
            Center(
              child: Text(
                'Henüz stok verisi bulunmuyor',
                style: GoogleFonts.poppins(
                  color: TamgaciConstants.textSecondary,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length > 5 ? 5 : items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: TamgaciConstants.primaryColor.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        color: TamgaciConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Text(
                    'Ürün ${item.productId}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Miktar: ${item.currentQuantity}',
                    style: GoogleFonts.poppins(
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),
                  trailing: Text(
                    '₺${(item.currentQuantity * item.averageCost).toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: TamgaciConstants.successColor,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// En çok stoklu ürünler
  Widget _buildTopQuantityItems(BuildContext context, List<dynamic> items) {
    return Container(
      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
      decoration: BoxDecoration(
        color: TamgaciConstants.cardColor,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        boxShadow: TamgaciConstants.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'En Çok Stoklu Ürünler',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: TamgaciConstants.textPrimary,
            ),
          ),
          SizedBox(height: TamgaciConstants.spaceMD),
          if (items.isEmpty)
            Center(
              child: Text(
                'Henüz stok verisi bulunmuyor',
                style: GoogleFonts.poppins(
                  color: TamgaciConstants.textSecondary,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length > 5 ? 5 : items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: TamgaciConstants.warningColor.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        color: TamgaciConstants.warningColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Text(
                    'Ürün ${item.productId}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Ortalama Maliyet: ₺${item.averageCost.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),
                  trailing: Text(
                    '${item.currentQuantity} adet',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: TamgaciConstants.primaryColor,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Son stok hareketleri
  Widget _buildRecentMovements(BuildContext context, WidgetRef ref) {
    final recentMovementsAsync = ref.watch(recentStockMovementsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Stok Hareketleri',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // Şimdilik products list'e yönlendir
                TamgaciRoutes.pushNamed(context, TamgaciRoutes.productsList);
              },
              child: Text(
                'Tümünü Gör',
                style: GoogleFonts.poppins(
                  color: TamgaciConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: TamgaciConstants.spaceMD),
        recentMovementsAsync.when(
          data: (movements) => Container(
            padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
            decoration: BoxDecoration(
              color: TamgaciConstants.cardColor,
              borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
              boxShadow: TamgaciConstants.shadowLight,
            ),
            child: movements.isEmpty
                ? Center(
                    child: Text(
                      'Henüz stok hareketi bulunmuyor',
                      style: GoogleFonts.poppins(
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: movements.length > 5 ? 5 : movements.length,
                    itemBuilder: (context, index) {
                      final movement = movements[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getMovementTypeColor(
                            movement.movementType,
                          ).withValues(alpha: 0.1),
                          child: Icon(
                            _getMovementTypeIcon(movement.movementType),
                            color: _getMovementTypeColor(movement.movementType),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          '${movement.movementType.displayName} - ${movement.quantity} adet',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Ürün ID: ${movement.productId}',
                          style: GoogleFonts.poppins(
                            color: TamgaciConstants.textSecondary,
                          ),
                        ),
                        trailing: Text(
                          '₺${movement.totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: _getMovementTypeColor(movement.movementType),
                          ),
                        ),
                        onTap: () {
                          // Şimdilik products list'e yönlendir
                          TamgaciRoutes.pushNamed(
                            context,
                            TamgaciRoutes.productsList,
                          );
                        },
                      );
                    },
                  ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Hareketler yüklenemedi: $error',
              style: GoogleFonts.poppins(color: TamgaciConstants.errorColor),
            ),
          ),
        ),
      ],
    );
  }

  /// Hareket türüne göre renk döndür
  Color _getMovementTypeColor(dynamic movementType) {
    switch (movementType.name) {
      case 'in_':
        return TamgaciConstants.successColor;
      case 'out':
        return TamgaciConstants.errorColor;
      case 'adjustment':
        return TamgaciConstants.warningColor;
      case 'transfer':
        return TamgaciConstants.primaryColor;
      default:
        return TamgaciConstants.textSecondary;
    }
  }

  /// Hareket türüne göre ikon döndür
  IconData _getMovementTypeIcon(dynamic movementType) {
    switch (movementType.name) {
      case 'in_':
        return Icons.input;
      case 'out':
        return Icons.output;
      case 'adjustment':
        return Icons.edit;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.inventory;
    }
  }
}
