// ========== CUSTOM APP BAR WIDGET ==========
// lib/shared/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/constants.dart';

/// Özel AppBar widget'ı
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark
              ? TamgaciConstants.textPrimaryDark
              : TamgaciConstants.textPrimary,
        ),
      ),
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: isDark
          ? TamgaciConstants.textPrimaryDark
          : TamgaciConstants.textPrimary,
      elevation: showShadow ? 2 : 0,
      shadowColor:
          showShadow ? Colors.black.withValues(alpha: 0.1) : Colors.transparent,
      leading: _buildLeadingWidget(context, isDark),
      automaticallyImplyLeading:
          automaticallyImplyLeading && (showBackButton || showDrawer),
      actions: actions,
      centerTitle: true,
      shape: showShadow
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            )
          : null,
    );
  }

  /// Leading widget'ını oluşturur
  Widget? _buildLeadingWidget(BuildContext context, bool isDark) {
    final iconColor = isDark
        ? TamgaciConstants.textPrimaryDark
        : TamgaciConstants.textPrimary;

    if (showDrawer) {
      return IconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: Icon(Icons.menu, color: iconColor),
      );
    }

    if (showBackButton) {
      return IconButton(
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: iconColor,
        ),
      );
    }

    return null;
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? kToolbarHeight);
}
