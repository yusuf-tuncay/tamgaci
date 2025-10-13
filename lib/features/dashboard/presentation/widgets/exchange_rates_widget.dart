// ========== EXCHANGE RATES WIDGET ==========
// lib/features/dashboard/presentation/widgets/exchange_rates_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/providers/currency_providers.dart';
import '../../../../core/domain/entities/currency.dart';
import '../../../../core/services/exchange_rate_service.dart';

/// Kur widget'ı
class ExchangeRatesWidget extends ConsumerWidget {
  const ExchangeRatesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exchangeRatesAsync = ref.watch(currencyRefreshNotifierProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TamgaciConstants.borderColor : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 16),
          _buildExchangeRates(
              ref, exchangeRatesAsync, isDark, selectedCurrency),
        ],
      ),
    );
  }

  /// Header oluşturur
  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        const Icon(
          Icons.currency_exchange,
          color: TamgaciConstants.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          'Güncel Kurlar',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : TamgaciConstants.textPrimary,
          ),
        ),
        const Spacer(),
        Consumer(
          builder: (context, ref, child) {
            final lastUpdate = ref
                .watch(currencyRefreshNotifierProvider)
                .value
                ?.first
                .lastUpdated;
            if (lastUpdate == null) return const SizedBox.shrink();

            return Text(
              'Son güncelleme: ${_formatTime(lastUpdate)}',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isDark
                    ? TamgaciConstants.textSecondaryDark
                    : TamgaciConstants.textSecondary,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        Consumer(
          builder: (context, ref, child) {
            final isLoading =
                ref.watch(currencyRefreshNotifierProvider).isLoading;

            return GestureDetector(
              onTap: isLoading
                  ? null
                  : () async {
                      // Kurları yenile
                      await ref
                          .read(currencyRefreshNotifierProvider.notifier)
                          .refresh();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Kurlar yenilendi!',
                              style: GoogleFonts.poppins(),
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? TamgaciConstants.primaryColor.withValues(alpha: 0.1)
                      : TamgaciConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AnimatedRotation(
                  turns: isLoading ? 1 : 0,
                  duration: const Duration(seconds: 1),
                  child: Icon(
                    Icons.refresh,
                    size: 20,
                    color: isLoading
                        ? (isDark ? Colors.grey : Colors.grey.shade600)
                        : TamgaciConstants.primaryColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Kur listesi oluşturur
  Widget _buildExchangeRates(
      WidgetRef ref,
      AsyncValue<List<Currency>> exchangeRatesAsync,
      bool isDark,
      Currency selectedCurrency) {
    return exchangeRatesAsync.when(
      data: (currencies) {
        if (currencies.isEmpty) {
          return _buildEmptyState(ref, isDark);
        }
        return _buildCurrenciesList(currencies, isDark, selectedCurrency);
      },
      loading: () => _buildLoadingSkeleton(isDark),
      error: (error, stack) => _buildErrorState(ref, error, isDark),
    );
  }

  /// Para birimleri listesi oluşturur
  Widget _buildCurrenciesList(
      List<Currency> currencies, bool isDark, Currency selectedCurrency) {
    // Seçili para birimi hariç diğerlerini göster
    final displayCurrencies =
        currencies.where((c) => c.code != selectedCurrency.code).toList();

    return Column(
      children: displayCurrencies.map((currency) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCurrencyItem(currency, isDark, selectedCurrency),
        );
      }).toList(),
    );
  }

  /// Para birimi öğesi oluşturur
  Widget _buildCurrencyItem(
      Currency currency, bool isDark, Currency selectedCurrency) {
    final isPositive = currency.isIncreasing;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    // Türk Lirası cinsinden kur göster
    final rateText = '${currency.exchangeRate.toStringAsFixed(2)} ₺';

    return Row(
      children: [
        // Para birimi ikonu
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: TamgaciConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              currency.symbol,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TamgaciConstants.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Para birimi bilgileri
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currency.name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                ),
              ),
              Text(
                currency.country,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark
                      ? TamgaciConstants.textSecondaryDark
                      : TamgaciConstants.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Kur bilgileri
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              rateText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  changeIcon,
                  size: 12,
                  color: changeColor,
                ),
                const SizedBox(width: 2),
                Text(
                  '${currency.changeRate.toStringAsFixed(2)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: changeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '1 ₺ = ${(1 / currency.exchangeRate).toStringAsFixed(4)} ${currency.code}',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? TamgaciConstants.textSecondaryDark
                    : TamgaciConstants.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Loading durumu oluşturur
  Widget _buildLoadingSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey.shade200;
    final highlight = isDark ? Colors.grey[700]! : Colors.grey.shade300;
    Widget row() => Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 120, color: highlight),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 80, color: baseColor),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(height: 12, width: 80, color: highlight),
                const SizedBox(height: 6),
                Container(height: 10, width: 60, color: baseColor),
              ],
            )
          ],
        );
    return Column(
      children: [
        row(),
        const SizedBox(height: 12),
        row(),
        const SizedBox(height: 12),
        row(),
        const SizedBox(height: 12),
        row(),
      ],
    );
  }

  /// Hata durumu oluşturur
  Widget _buildErrorState(WidgetRef ref, Object error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: TamgaciConstants.errorColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Kur bilgileri yüklenemedi',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark
                    ? TamgaciConstants.textSecondaryDark
                    : TamgaciConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(currencyRefreshNotifierProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Yenile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.currency_exchange,
              color: isDark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Kur verisi bulunamadı',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark
                    ? TamgaciConstants.textSecondaryDark
                    : TamgaciConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(currencyRefreshNotifierProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Yeniden Dene'),
            ),
          ],
        ),
      ),
    );
  }

  /// Zaman formatla
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }
}

/// Kur detay widget'ı
class ExchangeRateDetailWidget extends ConsumerWidget {
  final Currency currency;

  const ExchangeRateDetailWidget({
    super.key,
    required this.currency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? TamgaciConstants.borderColor : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                currency.symbol,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TamgaciConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white
                            : TamgaciConstants.textPrimary,
                      ),
                    ),
                    Text(
                      currency.country,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark
                            ? TamgaciConstants.textSecondaryDark
                            : TamgaciConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kur',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark
                          ? TamgaciConstants.textSecondaryDark
                          : TamgaciConstants.textSecondary,
                    ),
                  ),
                  Text(
                    ExchangeRateService.formatCurrencyRate(
                      currency.exchangeRate,
                      currency.code,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.white : TamgaciConstants.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Değişim',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark
                          ? TamgaciConstants.textSecondaryDark
                          : TamgaciConstants.textSecondary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        currency.isIncreasing
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color:
                            currency.isIncreasing ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${currency.changeRate.toStringAsFixed(2)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              currency.isIncreasing ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
