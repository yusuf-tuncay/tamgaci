import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/core/providers/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);

    return IconButton(
      onPressed: () {
        themeNotifier.toggleTheme();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Tema ${themeNotifier.getThemeName()} moduna değiştirildi'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      icon: Icon(
        themeNotifier.getThemeIcon(),
        color: Theme.of(context).colorScheme.onSurface,
      ),
      tooltip: 'Tema Değiştir (${themeNotifier.getThemeName()})',
    );
  }
}

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
            'Gündüz modu',
            currentTheme == ThemeMode.light,
            () {
              themeNotifier.setTheme(ThemeMode.light);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            context,
            ThemeMode.dark,
            'Koyu Tema',
            Icons.dark_mode,
            'Gece modu',
            currentTheme == ThemeMode.dark,
            () {
              themeNotifier.setTheme(ThemeMode.dark);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            context,
            ThemeMode.system,
            'Sistem',
            Icons.brightness_auto,
            'Sistem ayarını takip et',
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
    String description,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
