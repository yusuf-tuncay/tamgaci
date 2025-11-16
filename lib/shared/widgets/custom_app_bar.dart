// ========== CUSTOM APP BAR WIDGET ==========
// lib/shared/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/constants.dart';

/// Özel AppBar widget'ı
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Başlık
  final String title;

  /// Geri butonu gösterilsin mi?
  final bool showBackButton;

  /// Drawer menü gösterilsin mi?
  final bool showDrawer;

  /// Aksiyonlar
  final List<Widget>? actions;

  /// Geri butonu callback'i
  final VoidCallback? onBackPressed;

  /// Otomatik geri butonu
  final bool automaticallyImplyLeading;

  /// Arka plan rengi
  final Color? backgroundColor;

  /// Gölge gösterilsin mi?
  final bool showShadow;

  /// Yükseklik
  final double? height;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showDrawer = false,
    this.actions,
    this.onBackPressed,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.showShadow = true,
    this.height,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height ?? kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation - subtle and professional
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Glow animation - 60 saniyede bir parlama
    _glowController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start subtle pulse animation - sadece bir kez çalıştır
    _pulseController.forward();

    // Start glow animation - sadece bir kez çalıştır
    _glowController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: _buildUltraPremiumTamgaciTitle(isDark),
      backgroundColor:
          widget.backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: isDark
          ? TamgaciConstants.textPrimaryDark
          : TamgaciConstants.textPrimary,
      elevation: widget.showShadow ? 2 : 0,
      shadowColor: widget.showShadow
          ? theme.colorScheme.shadow.withValues(alpha: 0.1)
          : Colors.transparent,
      leading: _buildLeadingWidget(context, isDark),
      automaticallyImplyLeading: widget.automaticallyImplyLeading &&
          (widget.showBackButton || widget.showDrawer),
      actions: widget.actions,
      centerTitle: true,
      shape: widget.showShadow
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            )
          : null,
    );
  }

  /// Kurumsal TAMGACI title widget'ı
  Widget _buildUltraPremiumTamgaciTitle(bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        // Parlama efekti için glow değeri
        final glowIntensity = _glowAnimation.value;
        final isGlowing = glowIntensity > 0.8; // Son %20'de parlama

        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Text(
            'TAMGACI',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? const Color(0xFF4F46E5) // Indigo-600 for dark mode
                  : const Color(0xFF3B82F6), // Blue-500 for light mode
              letterSpacing: 1.5,
              shadows: [
                // Normal gölge
                Shadow(
                  color: (isDark
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFF3B82F6))
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                // Parlama efekti gölgesi
                if (isGlowing)
                  Shadow(
                    color: (isDark
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFF3B82F6))
                        .withValues(alpha: 0.8),
                    blurRadius: 20 + (glowIntensity * 15),
                    offset: const Offset(0, 0),
                  ),
                // Parlama efekti - dış glow
                if (isGlowing)
                  Shadow(
                    color: (isDark
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFF3B82F6))
                        .withValues(alpha: 0.4),
                    blurRadius: 30 + (glowIntensity * 20),
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Leading widget'ını oluşturur
  Widget? _buildLeadingWidget(BuildContext context, bool isDark) {
    final iconColor = isDark
        ? TamgaciConstants.textPrimaryDark
        : TamgaciConstants.textPrimary;

    if (widget.showDrawer) {
      return Builder(
        builder: (context) => IconButton(
          onPressed: () {
            try {
              Scaffold.of(context).openDrawer();
            } catch (e) {
              // Fallback if drawer is not available
              debugPrint('Drawer not available: $e');
            }
          },
          icon: Icon(Icons.menu, color: iconColor),
        ),
      );
    }

    if (widget.showBackButton) {
      return IconButton(
        onPressed: widget.onBackPressed ?? () {
          try {
            if (context.canPop()) {
              context.pop();
            } else {
              // Fallback: Ana sayfaya git
              context.go('/dashboard');
            }
          } catch (e) {
            debugPrint('Navigation error: $e');
            // Fallback navigation
            context.go('/dashboard');
          }
        },
        icon: Icon(
          Icons.arrow_back_ios,
          color: iconColor,
        ),
      );
    }

    return null;
  }
}
