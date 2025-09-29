import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/product.dart';

/// Ürün Kartı Widget'ı
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildProductIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 4),
                      _buildProductInfo(),
                      const SizedBox(height: 6),
                      _buildWarehouseAndStockInfo(),
                    ],
                  ),
                ),
                _buildRightSideInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            product.name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildProductIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getTypeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: product.images.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.images.first,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    _getTypeIcon(),
                    color: _getTypeColor(),
                    size: 20,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Icon(
                    _getTypeIcon(),
                    color: _getTypeColor(),
                    size: 20,
                  );
                },
              ),
            )
          : Icon(
              _getTypeIcon(),
              color: _getTypeColor(),
              size: 20,
            ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getStatusText(),
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Row(
      children: [
        if (product.productCode != null) ...[
          Text(
            'Kod: ${product.productCode}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (product.category != null) ...[
          _buildInfoChip(
            Icons.category,
            product.category!,
            Colors.blue,
          ),
          const SizedBox(width: 4),
        ],
        if (product.brand != null) ...[
          _buildInfoChip(
            Icons.business,
            product.brand!,
            Colors.purple,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseAndStockInfo() {
    return Row(
      children: [
        // Warehouse info
        if (product.warehouseName != null) ...[
          Icon(Icons.warehouse, size: 12, color: Colors.blue[600]),
          const SizedBox(width: 4),
          Text(
            product.warehouseName!,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.blue[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
        ] else ...[
          Icon(Icons.warning, size: 12, color: Colors.orange[600]),
          const SizedBox(width: 4),
          Text(
            'Depo yok',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.orange[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
        ],
        // Stock info
        Icon(Icons.inventory, size: 12, color: _getStockColor()),
        const SizedBox(width: 4),
        Text(
          '${product.totalStockQuantity}',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: _getStockColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (product.criticalStockQuantity != null &&
            product.totalStockQuantity <= product.criticalStockQuantity!) ...[
          const SizedBox(width: 4),
          Icon(Icons.warning, size: 10, color: Colors.orange[600]),
        ],
      ],
    );
  }

  Widget _buildRightSideInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Price info
        Text(
          '₺${product.salesPrice.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.green[600],
          ),
        ),
        if (product.purchasePrice != null) ...[
          const SizedBox(height: 2),
          Text(
            '₺${product.purchasePrice!.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.blue[600],
            ),
          ),
        ],
        const SizedBox(height: 4),
        // Type indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getTypeColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            product.type.displayName,
            style: GoogleFonts.poppins(
              fontSize: 8,
              color: _getTypeColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getTypeColor() {
    switch (product.type) {
      case ProductType.stocked:
        return Colors.blue;
      case ProductType.nonStocked:
        return Colors.orange;
      case ProductType.service:
        return Colors.purple;
      case ProductType.digital:
        return Colors.green;
    }
  }

  IconData _getTypeIcon() {
    switch (product.type) {
      case ProductType.stocked:
        return Icons.inventory;
      case ProductType.nonStocked:
        return Icons.shopping_bag;
      case ProductType.service:
        return Icons.room_service;
      case ProductType.digital:
        return Icons.computer;
    }
  }

  Color _getStatusColor() {
    if (product.totalStockQuantity <= 0) {
      return Colors.red;
    } else if (product.isLowStock) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getStatusText() {
    if (product.totalStockQuantity <= 0) {
      return 'Stokta Yok';
    } else if (product.isLowStock) {
      return 'Kritik Stok';
    } else {
      return 'Stokta Var';
    }
  }

  Color _getBorderColor() {
    if (product.totalStockQuantity <= 0) {
      return Colors.red.withValues(alpha: 0.3);
    } else if (product.isLowStock) {
      return Colors.orange.withValues(alpha: 0.3);
    } else {
      return Colors.grey.withValues(alpha: 0.2);
    }
  }

  Color _getStockColor() {
    if (product.totalStockQuantity <= 0) {
      return Colors.red;
    } else if (product.isLowStock) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
