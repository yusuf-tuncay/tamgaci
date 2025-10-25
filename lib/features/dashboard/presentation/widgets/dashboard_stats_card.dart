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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            backgroundColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: backgroundColor.withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.8),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
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
          Flexible(
            child: Text(
              CurrencyHelper.formatCurrency(value, currency),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.grey[900],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
