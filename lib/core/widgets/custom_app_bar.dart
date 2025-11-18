// ========== CUSTOM APP BAR ==========
// lib/core/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/constants.dart';

/// Özelleştirilmiş AppBar widget'ı
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title; // Opsiyonel - verilmezse "TAMGACI" gösterilir
  final bool showBackButton;
  final bool showDrawer;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.showDrawer = false,
    this.actions,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title ?? 'TAMGACI',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark
              ? TamgaciConstants.textPrimaryDark
              : TamgaciConstants.textPrimary,
        ),
      ),
      backgroundColor: isDark ? TamgaciConstants.cardColorDark : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark
                    ? TamgaciConstants.textPrimaryDark
                    : TamgaciConstants.textPrimary,
              ),
              onPressed: onBackPressed ?? () {
                try {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    // Fallback: Ana sayfaya git
                    Navigator.of(context).pushReplacementNamed('/dashboard');
                  }
                } catch (e) {
                  debugPrint('Navigation error: $e');
                  // Fallback navigation
                  Navigator.of(context).pushReplacementNamed('/dashboard');
                }
              },
            )
          : showDrawer
              ? IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: isDark
                        ? TamgaciConstants.textPrimaryDark
                        : TamgaciConstants.textPrimary,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                )
              : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
