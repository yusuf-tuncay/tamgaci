import 'package:flutter/material.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';

/// Satış işlemleri bottom sheet widget'ı
class SaleActionsBottomSheet extends StatefulWidget {
  final Sale sale;
  final Function(SaleStatus) onStatusChanged;
  final Function(PaymentStatus) onPaymentStatusChanged;
  final VoidCallback onApprove;
  final Function(String) onShip;
  final VoidCallback onDeliver;
  final Function(String) onCancel;
  final Function(String) onReturn;

  const SaleActionsBottomSheet({
    super.key,
    required this.sale,
    required this.onStatusChanged,
    required this.onPaymentStatusChanged,
    required this.onApprove,
    required this.onShip,
    required this.onDeliver,
    required this.onCancel,
    required this.onReturn,
  });

  @override
  State<SaleActionsBottomSheet> createState() => _SaleActionsBottomSheetState();
}

class _SaleActionsBottomSheetState extends State<SaleActionsBottomSheet> {
  final TextEditingController _trackingController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _trackingController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.0,
            height: 4.0,
            margin: const EdgeInsets.only(top: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Satış İşlemleri',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildStatusActions(),
                const SizedBox(height: 16.0),
                _buildPaymentActions(),
                const SizedBox(height: 16.0),
                _buildWorkflowActions(),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kapat'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durum Değiştir',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: SaleStatus.values.map((status) {
            if (status == widget.sale.status) return const SizedBox.shrink();

            return ActionChip(
              label: Text(status.displayName),
              onPressed: () => _showStatusConfirmation(status),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ödeme Durumu',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: PaymentStatus.values.map((status) {
            if (status == widget.sale.paymentStatus) {
              return const SizedBox.shrink();
            }

            return ActionChip(
              label: Text(status.displayName),
              onPressed: () => _showPaymentStatusConfirmation(status),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWorkflowActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İşlemler',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: [
            if (widget.sale.status == SaleStatus.draft)
              ActionChip(
                label: const Text('Onayla'),
                onPressed: () => _showApprovalConfirmation(),
              ),
            if (widget.sale.status == SaleStatus.confirmed)
              ActionChip(
                label: const Text('Kargoya Ver'),
                onPressed: () => _showShipDialog(),
              ),
            if (widget.sale.status == SaleStatus.shipped)
              ActionChip(
                label: const Text('Teslim Et'),
                onPressed: () => _showDeliveryConfirmation(),
              ),
            if (widget.sale.status != SaleStatus.cancelled)
              ActionChip(
                label: const Text('İptal Et'),
                onPressed: () => _showCancelDialog(),
              ),
            if (widget.sale.status == SaleStatus.delivered)
              ActionChip(
                label: const Text('İade Et'),
                onPressed: () => _showReturnDialog(),
              ),
          ],
        ),
      ],
    );
  }

  void _showStatusConfirmation(SaleStatus status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Durum Değiştir'),
        content: Text(
            'Satış durumunu "${status.displayName}" olarak değiştirmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onStatusChanged(status);
            },
            child: const Text('Değiştir'),
          ),
        ],
      ),
    );
  }

  void _showPaymentStatusConfirmation(PaymentStatus status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödeme Durumu Değiştir'),
        content: Text(
            'Ödeme durumunu "${status.displayName}" olarak değiştirmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPaymentStatusChanged(status);
            },
            child: const Text('Değiştir'),
          ),
        ],
      ),
    );
  }

  void _showApprovalConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Satışı Onayla'),
        content: const Text('Bu satışı onaylamak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onApprove();
            },
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }

  void _showShipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kargoya Ver'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Takip numarasını girin:'),
            const SizedBox(height: 16.0),
            TextField(
              controller: _trackingController,
              decoration: const InputDecoration(
                labelText: 'Takip Numarası',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (_trackingController.text.isNotEmpty) {
                Navigator.pop(context);
                widget.onShip(_trackingController.text);
              }
            },
            child: const Text('Kargoya Ver'),
          ),
        ],
      ),
    );
  }

  void _showDeliveryConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teslim Et'),
        content: const Text(
            'Bu satışı teslim edildi olarak işaretlemek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeliver();
            },
            child: const Text('Teslim Et'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Satışı İptal Et'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('İptal nedenini girin:'),
            const SizedBox(height: 16.0),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'İptal Nedeni',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (_reasonController.text.isNotEmpty) {
                Navigator.pop(context);
                widget.onCancel(_reasonController.text);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );
  }

  void _showReturnDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Satışı İade Et'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('İade nedenini girin:'),
            const SizedBox(height: 16.0),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'İade Nedeni',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (_reasonController.text.isNotEmpty) {
                Navigator.pop(context);
                widget.onReturn(_reasonController.text);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('İade Et'),
          ),
        ],
      ),
    );
  }
}
