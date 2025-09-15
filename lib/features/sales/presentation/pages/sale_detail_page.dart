import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/features/sales/presentation/providers/sale_providers.dart';
import 'package:tamgaci/features/sales/presentation/widgets/sale_detail_card.dart';
import 'package:tamgaci/features/sales/presentation/widgets/sale_items_list.dart';
import 'package:tamgaci/features/sales/presentation/widgets/sale_actions_bottom_sheet.dart';
import 'package:tamgaci/core/routes/routes.dart';
import 'package:tamgaci/core/widgets/loading_widget.dart';
import 'package:tamgaci/core/widgets/error_widget.dart' as core_widgets;
import 'package:tamgaci/core/widgets/empty_state_widget.dart';
import 'package:tamgaci/features/sales/presentation/states/sale_state.dart';

/// Satış detay sayfası
class SaleDetailPage extends ConsumerStatefulWidget {
  final String saleId;

  const SaleDetailPage({
    super.key,
    required this.saleId,
  });

  @override
  ConsumerState<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends ConsumerState<SaleDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSale();
    });
  }

  void _loadSale() {
    ref.read(saleNotifierProvider.notifier).getSale(widget.saleId);
  }

  @override
  Widget build(BuildContext context) {
    final saleState = ref.watch(saleNotifierProvider);
    final sale = saleState.selectedSale;

    return Scaffold(
      appBar: AppBar(
        title: Text(sale?.saleNumber ?? 'Satış Detayı'),
        actions: [
          if (sale != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    Navigator.pushNamed(
                      context,
                      TamgaciRoutes.editSale,
                      arguments: sale.id,
                    );
                    break;
                  case 'duplicate':
                    _duplicateSale();
                    break;
                  case 'actions':
                    _showActionsBottomSheet();
                    break;
                  case 'delete':
                    _showDeleteDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Düzenle'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    leading: Icon(Icons.copy),
                    title: Text('Kopyala'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'actions',
                  child: ListTile(
                    leading: Icon(Icons.more_horiz),
                    title: Text('İşlemler'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Sil', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(saleState),
      floatingActionButton: sale != null
          ? FloatingActionButton.extended(
              onPressed: _showActionsBottomSheet,
              icon: const Icon(Icons.more_horiz),
              label: const Text('İşlemler'),
            )
          : null,
    );
  }

  Widget _buildBody(SaleState state) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.error != null) {
      return core_widgets.ErrorWidget(
        message: state.error!,
        onRetry: _loadSale,
      );
    }

    if (state.selectedSale == null) {
      return const EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        title: 'Satış Bulunamadı',
        message: 'Aradığınız satış bulunamadı.',
      );
    }

    final sale = state.selectedSale!;

    return RefreshIndicator(
      onRefresh: () async {
        _loadSale();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SaleDetailCard(sale: sale),
            const SizedBox(height: 16.0),
            SaleItemsList(items: sale.items),
            const SizedBox(height: 16.0),
            _buildSummaryCard(sale),
            const SizedBox(height: 16.0),
            _buildStatusCard(sale),
            const SizedBox(height: 16.0),
            _buildNotesCard(sale),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Sale sale) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Özet',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ara Toplam:'),
                Text(
                  '₺${sale.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('KDV:'),
                Text(
                  '₺${sale.taxAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('İndirim:'),
                Text(
                  '₺${sale.discountAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Toplam:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₺${sale.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Sale sale) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Durum Bilgileri',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Satış Durumu:'),
                Chip(
                  label: Text(sale.status.displayName),
                  backgroundColor: _getStatusColor(sale.status),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ödeme Durumu:'),
                Chip(
                  label: Text(sale.paymentStatus.displayName),
                  backgroundColor: _getPaymentStatusColor(sale.paymentStatus),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Satış Tarihi:'),
                Text(sale.saleDate.toLocal().toString().split(' ')[0]),
              ],
            ),
            if (sale.dueDate != null) ...[
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Vade Tarihi:'),
                  Text(sale.dueDate!.toLocal().toString().split(' ')[0]),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Sale sale) {
    if (sale.notes == null || sale.notes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notlar',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(sale.notes!),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SaleStatus status) {
    switch (status) {
      case SaleStatus.draft:
        return Colors.grey.shade300;
      case SaleStatus.pending:
        return Colors.orange.shade300;
      case SaleStatus.confirmed:
        return Colors.blue.shade300;
      case SaleStatus.shipped:
        return Colors.orange.shade300;
      case SaleStatus.delivered:
        return Colors.green.shade300;
      case SaleStatus.paid:
        return Colors.green.shade400;
      case SaleStatus.cancelled:
        return Colors.red.shade300;
      case SaleStatus.returned:
        return Colors.purple.shade300;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange.shade300;
      case PaymentStatus.partial:
        return Colors.yellow.shade300;
      case PaymentStatus.paid:
        return Colors.green.shade300;
      case PaymentStatus.overdue:
        return Colors.red.shade300;
      case PaymentStatus.refunded:
        return Colors.blueGrey.shade300;
    }
  }

  void _showActionsBottomSheet() {
    final sale = ref.read(saleNotifierProvider).selectedSale;
    if (sale == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaleActionsBottomSheet(
        sale: sale,
        onStatusChanged: (newStatus) {
          Navigator.pop(context);
          _updateSaleStatus(newStatus);
        },
        onPaymentStatusChanged: (newPaymentStatus) {
          Navigator.pop(context);
          _updatePaymentStatus(newPaymentStatus);
        },
        onApprove: () {
          Navigator.pop(context);
          _approveSale();
        },
        onShip: (trackingNumber) {
          Navigator.pop(context);
          _shipSale(trackingNumber);
        },
        onDeliver: () {
          Navigator.pop(context);
          _deliverSale();
        },
        onCancel: (reason) {
          Navigator.pop(context);
          _cancelSale(reason);
        },
        onReturn: (reason) {
          Navigator.pop(context);
          _returnSale(reason);
        },
      ),
    );
  }

  void _updateSaleStatus(SaleStatus status) {
    final current = ref.read(saleNotifierProvider).selectedSale;
    if (current == null) return;
    ref
        .read(saleNotifierProvider.notifier)
        .updateSaleStatus(current.id, status);
  }

  void _updatePaymentStatus(PaymentStatus paymentStatus) {
    final current = ref.read(saleNotifierProvider).selectedSale;
    if (current == null) return;
    ref
        .read(saleNotifierProvider.notifier)
        .updatePaymentStatus(current.id, paymentStatus);
  }

  void _approveSale() {
    final current = ref.read(saleNotifierProvider).selectedSale;
    if (current == null) return;
    ref.read(saleNotifierProvider.notifier).approveSale(current.id);
  }

  void _shipSale(String trackingNumber) {
    final current = ref.read(saleNotifierProvider).selectedSale;
    if (current == null) return;
    ref
        .read(saleNotifierProvider.notifier)
        .shipSale(current.id, trackingNumber);
  }

  void _deliverSale() {
    final current = ref.read(saleNotifierProvider).selectedSale;
    if (current == null) return;
    ref.read(saleNotifierProvider.notifier).deliverSale(current.id);
  }

  void _cancelSale(String reason) {
    final current = ref.read(saleNotifierProvider).selectedSale;
    if (current == null) return;
    ref.read(saleNotifierProvider.notifier).cancelSale(current.id, reason);
  }

  void _returnSale(String reason) {
    final current = ref.read(saleNotifierProvider).selectedSale;
    if (current == null) return;
    ref.read(saleNotifierProvider.notifier).returnSale(current.id, reason);
  }

  void _duplicateSale() {
    final current = ref.read(saleNotifierProvider).selectedSale;
    if (current == null) return;
    ref.read(saleNotifierProvider.notifier).duplicateSale(current.id);
  }

  void _showDeleteDialog() {
    final sale = ref.read(saleNotifierProvider).selectedSale;
    if (sale == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Satışı Sil'),
        content: Text(
            '${sale.saleNumber} numaralı satışı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSale();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _deleteSale() {
    final sale = ref.read(saleNotifierProvider).selectedSale;
    if (sale == null) return;

    ref.read(saleNotifierProvider.notifier).deleteSale(sale.id);
    Navigator.pop(context);
  }
}
