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

    // Modern gradient - daha yumuşak geçişler
    final gradientColors = [
      backgroundColor,
      backgroundColor.withValues(alpha: 0.85),
      backgroundColor.withValues(alpha: 0.75),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: backgroundColor.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: isDark ? 0.4 : 0.25),
            blurRadius: 16,
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
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              CurrencyHelper.formatCurrency(value, currency),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (percentageChange != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: _PercentageChip(
                isDark: isDark,
                percentageChange: percentageChange!,
                percentageColor: percentageColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PercentageChip extends StatelessWidget {
  final bool isDark;
  final double percentageChange;
  final Color? percentageColor;

  const _PercentageChip({
    required this.isDark,
    required this.percentageChange,
    required this.percentageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: isDark ? 0.18 : 0.12,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: isDark ? 0.35 : 0.25,
          ),
          width: 0.7,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: percentageColor ?? Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            percentageChange >= 0 ? Icons.trending_up : Icons.trending_down,
            size: 12,
            color: percentageColor ?? Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            '${percentageChange.abs().toStringAsFixed(1)}%',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: percentageColor ?? Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
