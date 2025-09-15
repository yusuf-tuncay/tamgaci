// ========== INCOME CARD WIDGET ==========
// lib/features/income/presentation/widgets/income_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/providers/currency_providers.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../domain/entities/income.dart';

/// Gelir kartı widget'ı
class IncomeCard extends ConsumerWidget {
  /// Gelir verisi
  final Income income;

  /// Tıklama callback'i
  final VoidCallback? onTap;

  const IncomeCard({super.key, required this.income, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: isDark ? TamgaciConstants.cardColorDark : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: TamgaciConstants.cardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım - Başlık ve tutar
              Row(
                children: [
                  // Gelir ikonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: TamgaciConstants.successColor.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(
                        TamgaciConstants.radiusSM,
                      ),
                    ),
                    child: const Icon(
                      Icons.attach_money_outlined,
                      color: TamgaciConstants.successColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Başlık ve açıklama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          income.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? TamgaciConstants.textPrimaryDark
                                : TamgaciConstants.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (income.description != null &&
                            income.description!.isNotEmpty)
                          Text(
                            income.description!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? TamgaciConstants.textSecondaryDark
                                  : TamgaciConstants.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceSM),

                  // Tutar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildAmountDisplay(ref),
                      _buildStatusChip(),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // Alt kısım - Detaylar
              Row(
                children: [
                  // Kategori
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.category_outlined,
                      label: income.categoryName,
                      color: TamgaciConstants.primaryColor,
                      isDark: isDark,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Tarih
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat(
                        'dd.MM.yyyy',
                        'tr_TR',
                      ).format(income.incomeDate),
                      color: isDark
                          ? TamgaciConstants.textSecondaryDark
                          : TamgaciConstants.textSecondary,
                      isDark: isDark,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Ödeme yöntemi
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.payment_outlined,
                      label: income.paymentMethod,
                      color: isDark
                          ? TamgaciConstants.textSecondaryDark
                          : TamgaciConstants.textSecondary,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              // Müşteri bilgisi (varsa)
              if (income.customerName != null) ...[
                const SizedBox(height: TamgaciConstants.spaceSM),
                _buildDetailItem(
                  icon: Icons.person_outline,
                  label: 'Müşteri: ${income.customerName}',
                  color: isDark
                      ? TamgaciConstants.textSecondaryDark
                      : TamgaciConstants.textSecondary,
                  isDark: isDark,
                ),
              ],

              // Fatura numarası (varsa)
              if (income.invoiceNumber != null) ...[
                const SizedBox(height: TamgaciConstants.spaceSM),
                _buildDetailItem(
                  icon: Icons.receipt_outlined,
                  label: 'Fatura: ${income.invoiceNumber}',
                  color: isDark
                      ? TamgaciConstants.textSecondaryDark
                      : TamgaciConstants.textSecondary,
                  isDark: isDark,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Durum chip'i oluşturur
  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;

    switch (income.status) {
      case IncomeStatus.received:
        chipColor = TamgaciConstants.successColor;
        statusText = 'Tahsil Edildi';
        break;
      case IncomeStatus.pending:
        chipColor = TamgaciConstants.warningColor;
        statusText = 'Beklemede';
        break;
      case IncomeStatus.cancelled:
        chipColor = TamgaciConstants.errorColor;
        statusText = 'İptal Edildi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusXS),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }

  /// Tutar gösterimi oluşturur
  Widget _buildAmountDisplay(WidgetRef ref) {
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final exchangeRatesAsync = ref.watch(exchangeRatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          CurrencyHelper.formatAmount(income.amount, income.currency),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: TamgaciConstants.successColor,
          ),
        ),
        // Varsayılan para birimi gösterimi
        if (income.currency != selectedCurrency.code)
          exchangeRatesAsync.when(
            data: (exchangeRates) {
              final convertedAmount = CurrencyHelper.convertCurrency(
                income.amount,
                income.currency,
                selectedCurrency.code,
              );
              return Text(
                '(${convertedAmount.toStringAsFixed(2)} ${selectedCurrency.symbol})',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: TamgaciConstants.textSecondary,
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
      ],
    );
  }

  /// Detay öğesi oluşturur
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required Color color,
    bool isDark = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: TamgaciConstants.spaceXS),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
