import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/core/providers/theme_provider.dart';

class ThemeSelectorDialog extends ConsumerWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return AlertDialog(
      title: const Text('Tema Seçin'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context,
            ThemeMode.light,
            'Açık Tema',
            Icons.light_mode,
            Colors.orange,
            currentTheme == ThemeMode.light,
            () {
              themeNotifier.setTheme(ThemeMode.light);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 12),
          _buildThemeOption(
            context,
            ThemeMode.dark,
            'Koyu Tema',
            Icons.dark_mode,
            Colors.indigo,
            currentTheme == ThemeMode.dark,
            () {
              themeNotifier.setTheme(ThemeMode.dark);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 12),
          _buildThemeOption(
            context,
            ThemeMode.system,
            'Sistem Ayarı',
            Icons.settings_suggest,
            Colors.grey,
            currentTheme == ThemeMode.system,
            () {
              themeNotifier.setTheme(ThemeMode.system);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeMode themeMode,
    String title,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? color : null,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
