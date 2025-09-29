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
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getBorderColor(),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildProductInfo(),
                const SizedBox(height: 12),
                _buildWarehouseInfo(),
                const SizedBox(height: 12),
                _buildStockInfo(),
                const SizedBox(height: 12),
                _buildPriceInfo(),
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
        _buildProductIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (product.productCode != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Kod: ${product.productCode}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildProductIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getTypeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getTypeIcon(),
        color: _getTypeColor(),
        size: 24,
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Row(
      children: [
        if (product.category != null) ...[
          _buildInfoChip(
            Icons.category,
            product.category!,
            Colors.blue,
          ),
          const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseInfo() {
    if (product.warehouseName == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, size: 16, color: Colors.orange[600]),
            const SizedBox(width: 8),
            Text(
              'Depo atanmamış',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.orange[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warehouse, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Text(
            product.warehouseName!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.blue[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (product.shelfLocation != null) ...[
            const SizedBox(width: 8),
            Text(
              '• ${product.shelfLocation}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.blue[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildStockItem(
            'Stok',
            '${product.totalStockQuantity}',
            _getStockColor(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStockItem(
            'Kritik',
            '${product.criticalStockQuantity ?? 0}',
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStockItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildPriceItem(
            'Satış',
            '₺${product.salesPrice.toStringAsFixed(2)}',
            Colors.green,
          ),
        ),
        if (product.purchasePrice != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildPriceItem(
              'Alış',
              '₺${product.purchasePrice!.toStringAsFixed(2)}',
              Colors.blue,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
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
