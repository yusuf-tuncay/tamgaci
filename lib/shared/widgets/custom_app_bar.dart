// ========== CUSTOM APP BAR WIDGET ==========
// lib/shared/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/constants.dart';
import 'dart:math' as math;

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
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _gradientController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Gradient animation
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _gradientController.repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: widget.title == 'Dashboard' 
          ? _buildUltraPremiumTamgaciTitle(isDark)
          : Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? TamgaciConstants.textPrimaryDark
                    : TamgaciConstants.textPrimary,
              ),
            ),
      backgroundColor: widget.backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: isDark
          ? TamgaciConstants.textPrimaryDark
          : TamgaciConstants.textPrimary,
      elevation: widget.showShadow ? 2 : 0,
      shadowColor:
          widget.showShadow ? Colors.black.withValues(alpha: 0.1) : Colors.transparent,
      leading: _buildLeadingWidget(context, isDark),
      automaticallyImplyLeading:
          widget.automaticallyImplyLeading && (widget.showBackButton || widget.showDrawer),
      actions: widget.actions,
      centerTitle: true,
      shape: widget.showShadow
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            )
          : null,
    );
  }

  /// Ultra premium TAMGACI title widget'ı
  Widget _buildUltraPremiumTamgaciTitle(bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _glowAnimation,
        _pulseAnimation,
        _gradientAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF6366F1),
                    const Color(0xFF8B5CF6),
                    _gradientAnimation.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF8B5CF6),
                    const Color(0xFFEC4899),
                    _gradientAnimation.value,
                  )!,
                  Color.lerp(
                    const Color(0xFFEC4899),
                    const Color(0xFFF59E0B),
                    _gradientAnimation.value,
                  )!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.lerp(
                    const Color(0xFF6366F1).withValues(alpha: 0.3),
                    const Color(0xFFEC4899).withValues(alpha: 0.3),
                    _gradientAnimation.value,
                  )!,
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Color.lerp(
                    const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    _gradientAnimation.value,
                  )!,
                  blurRadius: 30 * _glowAnimation.value,
                  spreadRadius: 1 * _glowAnimation.value,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background glow effect
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.0,
                        colors: [
                          Colors.white.withValues(alpha: 0.1 * _glowAnimation.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Main text
                Center(
                  child: Text(
                    'TAMGACI',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
                // Animated particles
                ...List.generate(6, (index) {
                  final angle = (index * 60.0) * (math.pi / 180.0);
                  final radius = 30.0 + (10.0 * _glowAnimation.value);
                  final x = math.cos(angle + _gradientAnimation.value * 2 * math.pi) * radius;
                  final y = math.sin(angle + _gradientAnimation.value * 2 * math.pi) * radius;
                  
                  return Positioned(
                    left: 50 + x,
                    top: 20 + y,
                    child: AnimatedOpacity(
                      opacity: _glowAnimation.value,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.8),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
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
        onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: iconColor,
        ),
      );
    }

    return null;
  }

}
