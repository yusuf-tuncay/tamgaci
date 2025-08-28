// ========== EMPTY STATE WIDGET ==========
// lib/shared/widgets/empty_state_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/constants.dart';

/// Boş durum widget'ı
class EmptyStateWidget extends StatelessWidget {
  /// İkon
  final IconData icon;

  /// Başlık
  final String title;

  /// Mesaj
  final String message;

  /// Aksiyon butonu
  final Widget? actionButton;

  /// İkon boyutu
  final double iconSize;

  /// İkon rengi
  final Color? iconColor;

  /// Arka plan rengi
  final Color? backgroundColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionButton,
    this.iconSize = 80.0,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // İkon
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? TamgaciConstants.textSecondary,
              ),

              const SizedBox(height: 24),

              // Başlık
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: TamgaciConstants.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Mesaj
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: TamgaciConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              // Aksiyon butonu (varsa)
              if (actionButton != null) ...[
                const SizedBox(height: 24),

                actionButton!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Küçük boş durum widget'ı
class SmallEmptyStateWidget extends StatelessWidget {
  /// İkon
  final IconData icon;

  /// Mesaj
  final String message;

  /// İkon boyutu
  final double iconSize;

  /// İkon rengi
  final Color? iconColor;

  const SmallEmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.iconSize = 48.0,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TamgaciConstants.surfaceColor,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        border: Border.all(color: TamgaciConstants.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // İkon
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? TamgaciConstants.textSecondary,
          ),

          const SizedBox(height: 12),

          // Mesaj
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: TamgaciConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
