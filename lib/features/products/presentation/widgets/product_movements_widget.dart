// ========== PRODUCT MOVEMENTS WIDGET ==========
// lib/features/products/presentation/widgets/product_movements_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_movement.dart';
import '../providers/product_movement_providers.dart';

/// Ürün hareketleri widget'ı
class ProductMovementsWidget extends ConsumerWidget {
  final Product product;

  const ProductMovementsWidget({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Ürün Hareketleri',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? TamgaciConstants.textPrimaryDark
                        : TamgaciConstants.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAllMovements(context, product, ref),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMovementsList(context, product, isDark, ref),
          ],
        ),
      ),
    );
  }

  /// Hareketler listesi
  Widget _buildMovementsList(BuildContext context, Product product, bool isDark, WidgetRef ref) {
    final movementsAsync = ref.watch(productMovementsProvider(product.id));

    return movementsAsync.when(
      data: (movements) {
        if (movements.isEmpty) {
          return _buildEmptyMovements(isDark);
        }

        // Son 5 hareketi göster
        final recentMovements = movements.take(5).toList();

        return Column(
          children: recentMovements.map((movement) {
            return _buildMovementItem(movement, isDark);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildMovementsError(error.toString(), isDark),
    );
  }

  /// Hareket öğesi
  Widget _buildMovementItem(ProductMovement movement, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getMovementColor(movement.type).withValues(alpha:0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getMovementColor(movement.type).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                movement.typeIcon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.typeDisplayName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  movement.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${movement.createdAt.day}/${movement.createdAt.month}/${movement.createdAt.year} ${movement.createdAt.hour.toString().padLeft(2, '0')}:${movement.createdAt.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getMovementColor(movement.type),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${movement.quantity > 0 ? '+' : ''}${movement.quantity}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hareket rengi
  Color _getMovementColor(ProductMovementType type) {
    switch (type) {
      case ProductMovementType.stockIn:
      case ProductMovementType.purchase:
      case ProductMovementType.returnIn:
      case ProductMovementType.production:
        return Colors.green;
      case ProductMovementType.stockOut:
      case ProductMovementType.sale:
      case ProductMovementType.returnOut:
      case ProductMovementType.consumption:
      case ProductMovementType.waste:
        return Colors.red;
      case ProductMovementType.transfer:
        return Colors.blue;
      case ProductMovementType.adjustment:
        return Colors.orange;
      case ProductMovementType.other:
        return Colors.grey;
    }
  }

  /// Boş hareketler durumu
  Widget _buildEmptyMovements(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz hareket yok',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu ürün için henüz stok hareketi kaydı bulunmuyor.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Hareketler hata durumu
  Widget _buildMovementsError(String error, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 32,
            color: Colors.red[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Hareketler yüklenemedi',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Tüm hareketleri göster
  void _showAllMovements(BuildContext context, Product product, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${product.name} - Tüm Hareketler',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // Movements list
                Expanded(
                  child: _buildAllMovementsList(context, product, ref),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Tüm hareketler listesi
  Widget _buildAllMovementsList(BuildContext context, Product product, WidgetRef ref) {
    final movementsAsync = ref.watch(productMovementsProvider(product.id));

    return movementsAsync.when(
      data: (movements) {
        if (movements.isEmpty) {
          return _buildEmptyMovements(false);
        }

        return ListView.builder(
          controller: ScrollController(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            final movement = movements[index];
            return _buildMovementItem(movement, false);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildMovementsError(error.toString(), false),
    );
  }
}
