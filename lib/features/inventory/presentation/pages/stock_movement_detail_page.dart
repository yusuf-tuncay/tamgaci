import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../domain/entities/stock_movement.dart';
import '../providers/inventory_providers.dart';

class StockMovementDetailPage extends ConsumerStatefulWidget {
  final StockMovement movement;

  const StockMovementDetailPage({
    super.key,
    required this.movement,
  });

  @override
  ConsumerState<StockMovementDetailPage> createState() =>
      _StockMovementDetailPageState();
}

class _StockMovementDetailPageState
    extends ConsumerState<StockMovementDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Stok Hareketi Detayı',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: TamgaciConstants.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              _showEditOptions();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildDetailsCard(),
            const SizedBox(height: 16),
            _buildWarehouseCard(),
            const SizedBox(height: 16),
            _buildTimestampsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildTypeIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTypeText(widget.movement.movementType),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hareket #${widget.movement.id ?? "N/A"}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTypeColor(widget.movement.movementType),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${widget.movement.quantity}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hareket Detayları',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Ürün ID', '${widget.movement.productId}'),
            _buildDetailRow('Miktar', '${widget.movement.quantity}'),
            _buildDetailRow('Birim Fiyat',
                '₺${widget.movement.unitPrice.toStringAsFixed(2)}'),
            _buildDetailRow('Toplam Tutar',
                '₺${widget.movement.totalAmount.toStringAsFixed(2)}'),
            if (widget.movement.description != null &&
                widget.movement.description!.isNotEmpty)
              _buildDetailRow('Açıklama', widget.movement.description!),
            if (widget.movement.referenceNumber != null &&
                widget.movement.referenceNumber!.isNotEmpty)
              _buildDetailRow('Referans No', widget.movement.referenceNumber!),
            if (widget.movement.referenceType != null &&
                widget.movement.referenceType!.isNotEmpty)
              _buildDetailRow('Referans Türü', widget.movement.referenceType!),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Depo Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            if (widget.movement.warehouseId != null)
              _buildDetailRow('Depo ID', '${widget.movement.warehouseId}'),
            if (widget.movement.sourceWarehouseId != null)
              _buildDetailRow(
                  'Kaynak Depo ID', '${widget.movement.sourceWarehouseId}'),
            if (widget.movement.destinationWarehouseId != null)
              _buildDetailRow(
                  'Hedef Depo ID', '${widget.movement.destinationWarehouseId}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zaman Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
                'Hareket Tarihi', _formatDate(widget.movement.movementDate)),
            _buildDetailRow(
                'Oluşturulma', _formatDate(widget.movement.createdAt)),
            _buildDetailRow(
                'Güncellenme', _formatDate(widget.movement.updatedAt)),
            if (widget.movement.createdBy != null)
              _buildDetailRow('Oluşturan', '${widget.movement.createdBy}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (widget.movement.movementType) {
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
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

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Düzenleme Seçenekleri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.pop(context);
                _editStockMovement();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Sil', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteStockMovement();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _editStockMovement() {
    // TODO: Navigate to edit page based on movement type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Düzenleme özelliği yakında eklenecek',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteStockMovement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stok Hareketini Sil'),
        content: const Text(
            'Bu stok hareketini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(stockMovementOperationsProvider.notifier)
                    .deleteStockMovement(widget.movement.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Stok hareketi başarıyla silindi',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Hata: $e',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
