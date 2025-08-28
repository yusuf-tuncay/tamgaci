// ========== EXPENSE CARD WIDGET ==========
// lib/features/expenses/presentation/widgets/expense_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../domain/entities/expense.dart';

/// Gider kartı widget'ı
class ExpenseCard extends StatelessWidget {
  /// Gider verisi
  final Expense expense;

  /// Tıklama callback'i
  final VoidCallback? onTap;

  /// Silme callback'i
  final VoidCallback? onDelete;

  /// Düzenleme callback'i
  final VoidCallback? onEdit;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır - Başlık ve tutar
              Row(
                children: [
                  // Kategori ikonu
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: _getCategoryColor(),
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Başlık ve kategori
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: TamgaciConstants.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 2),

                        Text(
                          expense.categoryName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: TamgaciConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tutar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₺${expense.amount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: TamgaciConstants.errorColor,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Durum etiketi
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          expense.status.name,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Alt satır - Tarih ve açıklama
              Row(
                children: [
                  // Tarih
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: TamgaciConstants.textSecondary,
                  ),

                  const SizedBox(width: 4),

                  Text(
                    _formatDate(expense.expenseDate),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Ödeme yöntemi
                  Icon(
                    _getPaymentMethodIcon(),
                    size: 14,
                    color: TamgaciConstants.textSecondary,
                  ),

                  const SizedBox(width: 4),

                  Text(
                    expense.paymentMethod,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),
                ],
              ),

              // Açıklama (varsa)
              if (expense.description != null &&
                  expense.description!.isNotEmpty) ...[
                const SizedBox(height: 8),

                Text(
                  expense.description!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: TamgaciConstants.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Fatura numarası (varsa)
              if (expense.invoiceNumber != null &&
                  expense.invoiceNumber!.isNotEmpty) ...[
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.receipt,
                      size: 14,
                      color: TamgaciConstants.textSecondary,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      'Fatura: ${expense.invoiceNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              // Tedarikçi (varsa)
              if (expense.supplierName != null &&
                  expense.supplierName!.isNotEmpty) ...[
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.business,
                      size: 14,
                      color: TamgaciConstants.textSecondary,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      expense.supplierName!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Kategori rengini döndürür
  Color _getCategoryColor() {
    // Basit renk eşleştirmesi - gerçek uygulamada kategori rengi kullanılır
    switch (expense.categoryId) {
      case 'office':
        return Colors.blue;
      case 'rent':
        return Colors.green;
      case 'utilities':
        return Colors.orange;
      case 'salary':
        return Colors.purple;
      case 'marketing':
        return Colors.pink;
      case 'travel':
        return Colors.grey;
      case 'equipment':
        return Colors.brown;
      case 'insurance':
        return Colors.indigo;
      case 'tax':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Kategori ikonunu döndürür
  IconData _getCategoryIcon() {
    // Basit ikon eşleştirmesi - gerçek uygulamada kategori ikonu kullanılır
    switch (expense.categoryId) {
      case 'office':
        return Icons.business;
      case 'rent':
        return Icons.home;
      case 'utilities':
        return Icons.receipt;
      case 'salary':
        return Icons.people;
      case 'marketing':
        return Icons.campaign;
      case 'travel':
        return Icons.flight;
      case 'equipment':
        return Icons.computer;
      case 'insurance':
        return Icons.security;
      case 'tax':
        return Icons.account_balance;
      default:
        return Icons.more_horiz;
    }
  }

  /// Durum rengini döndürür
  Color _getStatusColor() {
    switch (expense.status) {
      case ExpenseStatus.paid:
        return Colors.green;
      case ExpenseStatus.pending:
        return Colors.orange;
      case ExpenseStatus.cancelled:
        return Colors.red;
    }
  }

  /// Ödeme yöntemi ikonunu döndürür
  IconData _getPaymentMethodIcon() {
    switch (expense.paymentMethod.toLowerCase()) {
      case 'nakit':
        return Icons.money;
      case 'kredi kartı':
        return Icons.credit_card;
      case 'banka havalesi':
        return Icons.account_balance;
      case 'çek':
        return Icons.receipt_long;
      default:
        return Icons.payment;
    }
  }

  /// Tarihi formatlar
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
