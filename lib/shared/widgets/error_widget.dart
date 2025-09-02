// ========== ERROR WIDGET ==========
// lib/shared/widgets/error_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/constants.dart';

/// Özel hata widget'ı
class CustomErrorWidget extends StatelessWidget {
  /// Hata mesajı
  final String message;

  /// Hata detayı
  final String? error;

  /// Tekrar dene callback'i
  final VoidCallback? onRetry;

  /// İkon
  final IconData? icon;

  /// Arka plan rengi
  final Color? backgroundColor;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.error,
    this.onRetry,
    this.icon,
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
              // Hata ikonu
              Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: TamgaciConstants.errorColor,
              ),

              const SizedBox(height: 16),

              // Hata mesajı
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: TamgaciConstants.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              // Hata detayı (varsa)
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: TamgaciConstants.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Tekrar dene butonu (varsa)
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TamgaciConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        TamgaciConstants.radiusMD,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Küçük hata widget'ı
class SmallErrorWidget extends StatelessWidget {
  /// Hata mesajı
  final String message;

  /// Tekrar dene callback'i
  final VoidCallback? onRetry;

  const SmallErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TamgaciConstants.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        border: Border.all(
            color: TamgaciConstants.errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: TamgaciConstants.errorColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: TamgaciConstants.errorColor,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              iconSize: 20,
              color: TamgaciConstants.errorColor,
            ),
          ],
        ],
      ),
    );
  }
}
