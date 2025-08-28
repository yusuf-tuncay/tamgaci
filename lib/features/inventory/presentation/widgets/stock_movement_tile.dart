import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../domain/entities/stock_movement.dart';

class StockMovementTile extends StatelessWidget {
  final StockMovement movement;
  final VoidCallback? onTap;

  const StockMovementTile({
    super.key,
    required this.movement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ürün ID: ${movement.productId}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Depo ID: ${movement.warehouseId ?? "N/A"}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildQuantityBadge(),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Miktar: ${movement.quantity}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '₺${movement.unitPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TamgaciConstants.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(movement.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    _getTypeText(movement.movementType),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getTypeColor(movement.movementType),
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

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (movement.movementType) {
      case StockMovementType.in_:
        iconData = Icons.arrow_downward;
        iconColor = Colors.green;
        break;
      case StockMovementType.out:
        iconData = Icons.arrow_upward;
        iconColor = Colors.red;
        break;
      case StockMovementType.transfer:
        iconData = Icons.swap_horiz;
        iconColor = Colors.blue;
        break;
      case StockMovementType.adjustment:
        iconData = Icons.edit;
        iconColor = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildQuantityBadge() {
    Color badgeColor;
    switch (movement.movementType) {
      case StockMovementType.in_:
        badgeColor = Colors.green;
        break;
      case StockMovementType.out:
        badgeColor = Colors.red;
        break;
      case StockMovementType.transfer:
        badgeColor = Colors.blue;
        break;
      case StockMovementType.adjustment:
        badgeColor = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${movement.quantity}',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getTypeText(StockMovementType type) {
    switch (type) {
      case StockMovementType.in_:
        return 'Stok Girişi';
      case StockMovementType.out:
        return 'Stok Çıkışı';
      case StockMovementType.transfer:
        return 'Transfer';
      case StockMovementType.adjustment:
        return 'Düzeltme';
    }
  }

  Color _getTypeColor(StockMovementType type) {
    switch (type) {
      case StockMovementType.in_:
        return Colors.green;
      case StockMovementType.out:
        return Colors.red;
      case StockMovementType.transfer:
        return Colors.blue;
      case StockMovementType.adjustment:
        return Colors.orange;
    }
  }
}
