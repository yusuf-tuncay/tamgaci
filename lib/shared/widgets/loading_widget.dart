// ========== LOADING WIDGET ==========
// lib/shared/widgets/loading_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/constants.dart';

/// Yükleme widget'ı
class LoadingWidget extends StatelessWidget {
  /// Yükleme mesajı
  final String? message;

  /// İndikatör boyutu
  final double size;

  /// İndikatör rengi
  final Color? color;

  /// Arka plan rengi
  final Color? backgroundColor;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 50.0,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Yükleme indikatörü
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? TamgaciConstants.primaryColor,
                ),
              ),
            ),

            // Mesaj (varsa)
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: TamgaciConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Küçük yükleme widget'ı
class SmallLoadingWidget extends StatelessWidget {
  /// İndikatör boyutu
  final double size;

  /// İndikatör rengi
  final Color? color;

  const SmallLoadingWidget({super.key, this.size = 24.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? TamgaciConstants.primaryColor,
        ),
      ),
    );
  }
}

/// Buton yükleme widget'ı
class ButtonLoadingWidget extends StatelessWidget {
  /// İndikatör boyutu
  final double size;

  /// İndikatör rengi
  final Color? color;

  const ButtonLoadingWidget({super.key, this.size = 16.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.white),
      ),
    );
  }
}
