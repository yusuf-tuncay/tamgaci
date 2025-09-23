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
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: (isDark ? Colors.white12 : Colors.black12),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.04),
                  Colors.white.withValues(alpha: 0.02),
                ]
              : [
                  Colors.white,
                  Colors.white,
                ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [
                  backgroundColor.withValues(alpha: 0.9),
                  iconColor.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      backgroundColor.withValues(alpha: 0.18),
                      iconColor.withValues(alpha: 0.18),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 20),
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
                        color: isDark ? Colors.grey[200] : Colors.grey[700],
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
          Text(
            CurrencyHelper.formatCurrency(value, currency),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }
}
