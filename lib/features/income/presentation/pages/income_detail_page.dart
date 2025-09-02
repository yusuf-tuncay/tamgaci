// ========== INCOME DETAIL PAGE ==========
// lib/features/income/presentation/pages/income_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/income_providers.dart';
import '../../domain/entities/income.dart';

/// Gelir detay sayfası
class IncomeDetailPage extends ConsumerStatefulWidget {
  final String incomeId;

  const IncomeDetailPage({super.key, required this.incomeId});

  @override
  ConsumerState<IncomeDetailPage> createState() => _IncomeDetailPageState();
}

class _IncomeDetailPageState extends ConsumerState<IncomeDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadIncome();
  }

  void _loadIncome() {
    // Gelir verisi zaten provider'da yüklü olmalı
    setState(() {});
  }

  /// Gelir düzenleme sayfasına git
  void _navigateToEdit() {
    Navigator.of(context).pushNamed('/income/edit', arguments: widget.incomeId);
  }

  /// Gelir silme işlemi
  void _deleteIncome() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gelir Sil'),
        content: const Text(
          'Bu gelir kaydını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              await ref
                  .read(incomeFormProvider.notifier)
                  .deleteIncome(widget.incomeId);
              if (mounted) {
                navigator.pop(); // Detay sayfasından çık
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  /// Durum güncelleme
  void _updateStatus(IncomeStatus newStatus) {
    ref
        .read(incomeOperationsProvider.notifier)
        .updateIncomeStatus(widget.incomeId, newStatus);
  }

  /// Durum seçici dialog
  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Durum Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: IncomeStatus.values.map((status) {
            return ListTile(
              title: Text(status.displayName),
              onTap: () {
                Navigator.of(context).pop();
                _updateStatus(status);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Gelir Detayı',
        showBackButton: true,
        showDrawer: false,
        actions: [
          IconButton(
            onPressed: _showStatusDialog,
            icon: const Icon(Icons.update),
            tooltip: 'Durum Güncelle',
          ),
          IconButton(
            onPressed: _navigateToEdit,
            icon: const Icon(Icons.edit),
            tooltip: 'Düzenle',
          ),
          IconButton(
            onPressed: _deleteIncome,
            icon: const Icon(Icons.delete),
            tooltip: 'Sil',
            color: Colors.red,
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final incomeAsync = ref.watch(incomeProvider(widget.incomeId));

          return incomeAsync.when(
            data: (income) {
              if (income == null) {
                return const Center(child: Text('Gelir bulunamadı'));
              }

              return _buildIncomeDetail(income);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hata: $error'),
                  ElevatedButton(
                    onPressed: _loadIncome,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIncomeDetail(Income income) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormat = DateFormat('dd.MM.yyyy');

    return SingleChildScrollView(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık kartı
          Card(
            child: Padding(
              padding: TamgaciConstants.cardPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          income.title,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: TamgaciConstants.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(income.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          income.status.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(income.amount),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: TamgaciConstants.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Detay kartları
          _buildDetailCard(
            title: 'Gelir Bilgileri',
            children: [
              _buildDetailRow('Açıklama', income.description ?? 'Açıklama yok'),
              _buildDetailRow('Kategori', income.categoryName),
              _buildDetailRow(
                'Gelir Tarihi',
                dateFormat.format(income.incomeDate),
              ),
              _buildDetailRow(
                'Fatura No',
                income.invoiceNumber ?? 'Fatura yok',
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildDetailCard(
            title: 'Müşteri Bilgileri',
            children: [
              _buildDetailRow('Müşteri', income.customerName ?? 'Müşteri yok'),
              _buildDetailRow(
                'Ödeme Yöntemi',
                income.paymentMethod,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildDetailCard(
            title: 'Ek Bilgiler',
            children: [
              _buildDetailRow('Notlar', income.notes ?? 'Not yok'),
              _buildDetailRow(
                'Ekler',
                income.attachments.isNotEmpty
                    ? income.attachments.join(', ')
                    : 'Ek dosya yok',
              ),
              _buildDetailRow(
                'Oluşturulma',
                dateFormat.format(income.createdAt),
              ),
              _buildDetailRow(
                'Güncellenme',
                dateFormat.format(income.updatedAt),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Aksiyon butonları
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // PDF export işlemi
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF export özelliği yakında eklenecek'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF İndir'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Paylaş işlemi
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paylaş özelliği yakında eklenecek'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Paylaş'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: TamgaciConstants.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(IncomeStatus status) {
    switch (status) {
      case IncomeStatus.received:
        return Colors.green;
      case IncomeStatus.pending:
        return Colors.orange;
      case IncomeStatus.cancelled:
        return Colors.grey;
    }
  }
}
