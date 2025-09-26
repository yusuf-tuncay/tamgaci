// ========== SEARCH BAR ==========
// lib/shared/widgets/search_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/constants.dart';

/// Özelleştirilmiş arama çubuğu widget'ı
class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool enabled;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Ara...',
    this.onChanged,
    this.onClear,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? TamgaciConstants.borderColorDark : Colors.grey[300]!,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        onChanged: onChanged,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: isDark
              ? TamgaciConstants.textPrimaryDark
              : TamgaciConstants.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: isDark
                ? TamgaciConstants.textSecondaryDark
                : TamgaciConstants.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark
                ? TamgaciConstants.textSecondaryDark
                : TamgaciConstants.textSecondary,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark
                        ? TamgaciConstants.textSecondaryDark
                        : TamgaciConstants.textSecondary,
                  ),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
