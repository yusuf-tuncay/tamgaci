// ========== DASHBOARD STATS CARD ==========
// lib/features/dashboard/presentation/widgets/dashboard_stats_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/currency_helper.dart';

/// Dashboard istatistik kartı widget'ı
class DashboardStatsCard extends StatelessWidget {
  /// Kart başlığı
  final String title;

  /// Ana değer
  final double value;

  /// Para birimi kodu
  final String currency;

  /// Alt başlık (opsiyonel)
  final String? subtitle;

  /// İkon
  final IconData icon;

  /// İkon rengi
  final Color iconColor;

  /// Arka plan rengi
  final Color backgroundColor;

  /// Yüzde değişim (opsiyonel)
  final double? percentageChange;

  /// Yüzde değişim rengi
  final Color? percentageColor;

  const DashboardStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.currency,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.percentageChange,
    this.percentageColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (percentageChange != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (percentageColor ?? Colors.green)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        percentageChange! >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 12,
                        color: percentageColor ?? Colors.green,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${percentageChange!.abs().toStringAsFixed(1)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: percentageColor ?? Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyHelper.formatCurrency(value, currency),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
