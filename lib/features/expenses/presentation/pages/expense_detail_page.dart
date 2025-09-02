// ========== EXPENSE DETAIL PAGE ==========
// lib/features/expenses/presentation/pages/expense_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/expense_providers.dart';
import '../../domain/entities/expense.dart';

/// Gider detay sayfası
class ExpenseDetailPage extends ConsumerStatefulWidget {
  final String expenseId;

  const ExpenseDetailPage({super.key, required this.expenseId});

  @override
  ConsumerState<ExpenseDetailPage> createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends ConsumerState<ExpenseDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadExpense();
  }

  void _loadExpense() {
    // Gider verisi zaten provider'da yüklü olmalı
  }

  /// Gider düzenleme sayfasına git
  void _navigateToEdit() {
    Navigator.of(
      context,
    ).pushNamed('/expense/edit', arguments: widget.expenseId);
  }

  /// Gider silme işlemi
  void _deleteExpense() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gider Sil'),
        content: const Text(
          'Bu gider kaydını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(expenseFormProvider.notifier)
                  .deleteExpense(widget.expenseId);
              // Widget dispose edilmişse navigator'a erişmeye çalışma
              if (mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Detay sayfasından çık
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
  void _updateStatus(ExpenseStatus newStatus) {
    ref
        .read(expenseFormProvider.notifier)
        .updateExpenseStatus(widget.expenseId, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Durum güncellendi: ${newStatus.name}')),
      );
    }
  }

  /// Durum seçici dialog
  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Durum Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ExpenseStatus.values.map((status) {
            return ListTile(
              title: Text(status.name),
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
        title: 'Gider Detayı',
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
            onPressed: _deleteExpense,
            icon: const Icon(Icons.delete),
            tooltip: 'Sil',
            color: Colors.red,
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final expenseAsync = ref.watch(expenseProvider(widget.expenseId));

          return expenseAsync.when(
            data: (expense) {
              if (expense == null) {
                return const Center(child: Text('Gider bulunamadı'));
              }

              return _buildExpenseDetail(expense);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hata: $error'),
                  ElevatedButton(
                    onPressed: _loadExpense,
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

  Widget _buildExpenseDetail(Expense expense) {
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
                          expense.title,
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
                          color: _getStatusColor(expense.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          expense.status.name,
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
                    currencyFormat.format(expense.amount),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Detay kartları
          _buildDetailCard(
            title: 'Gider Bilgileri',
            children: [
              _buildDetailRow(
                'Açıklama',
                expense.description ?? 'Açıklama yok',
              ),
              _buildDetailRow('Kategori', expense.categoryName),
              _buildDetailRow(
                'Gider Tarihi',
                dateFormat.format(expense.expenseDate),
              ),
              _buildDetailRow(
                'Ödeme Yöntemi',
                expense.paymentMethod,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildDetailCard(
            title: 'Ek Bilgiler',
            children: [
              _buildDetailRow(
                'Notlar',
                'Not yok',
              ), // Expense entity'de notes alanı yok
              _buildDetailRow(
                'Ekler',
                expense.attachments.isNotEmpty
                    ? expense.attachments.join(', ')
                    : 'Ek dosya yok',
              ),
              _buildDetailRow(
                'Oluşturulma',
                dateFormat.format(expense.createdAt),
              ),
              _buildDetailRow(
                'Güncellenme',
                dateFormat.format(expense.updatedAt),
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

  Color _getStatusColor(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.paid:
        return Colors.green;
      case ExpenseStatus.pending:
        return Colors.orange;
      case ExpenseStatus.cancelled:
        return Colors.grey;
    }
  }
}
