// ========== SETTINGS PAGE ==========
// lib/features/settings/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../core/providers/currency_providers.dart';
import '../../../../core/domain/entities/currency.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Ayarlar Sayfası
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final activeCurrencies = ref.watch(activeCurrenciesProvider);
    final currentTheme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context);

    return ResponsiveScaffold(
      appBar: CustomAppBar(title: l10n.settings, showDrawer: true),
      drawerContent: const TamgaciDrawerMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(isDark, l10n),
            const SizedBox(height: 16),
            _buildLanguageSettings(isDark, l10n),
            const SizedBox(height: 16),
            _buildThemeSettings(isDark, currentTheme, l10n),
            const SizedBox(height: 16),
            _buildCurrencySettings(
                isDark, selectedCurrency, activeCurrencies, l10n),
            const SizedBox(height: 16),
            _buildOtherSettings(isDark, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF2563EB).withValues(alpha: 0.8),
                  const Color(0xFF1D4ED8)
                ]
              : [
                  const Color(0xFF2563EB),
                  const Color(0xFF1D4ED8).withValues(alpha: 0.8)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.settings,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.settings,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsDescription,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettings(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? TamgaciConstants.borderColorDark : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.language,
                color: TamgaciConstants.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.language,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.languageDescription,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLanguageSelector(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(bool isDark, AppLocalizations l10n) {
    final currentLocale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color:
              isDark ? TamgaciConstants.borderColorDark : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<Locale>(
        value: currentLocale,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: l10n.selectLanguage,
          hintStyle: GoogleFonts.poppins(
            color: isDark
                ? TamgaciConstants.textSecondaryDark
                : TamgaciConstants.textSecondary,
          ),
        ),
        items: localeNotifier.supportedLocales.map((locale) {
          return DropdownMenuItem<Locale>(
            value: locale,
            child: Row(
              children: [
                Text(
                  localeNotifier.getLocaleFlag(locale),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  localeNotifier.getLocaleName(locale),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (Locale? newValue) {
          if (newValue != null) {
            localeNotifier.setLocale(newValue);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${l10n.languageChanged}: ${localeNotifier.getLocaleName(newValue)}'),
                backgroundColor: TamgaciConstants.primaryColor,
              ),
            );
          }
        },
        dropdownColor: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        style: GoogleFonts.poppins(
          color: isDark ? Colors.white : TamgaciConstants.textPrimary,
        ),
      ),
    );
  }

  Widget _buildThemeSettings(
      bool isDark, ThemeMode currentTheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? TamgaciConstants.borderColorDark : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.palette,
                color: TamgaciConstants.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.theme,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.themeDescription,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildThemeSelector(isDark, currentTheme, l10n),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
      bool isDark, ThemeMode currentTheme, AppLocalizations l10n) {
    final themes = [
      {
        'mode': ThemeMode.light,
        'name': l10n.lightTheme,
        'icon': Icons.light_mode
      },
      {'mode': ThemeMode.dark, 'name': l10n.darkTheme, 'icon': Icons.dark_mode},
      {
        'mode': ThemeMode.system,
        'name': l10n.systemTheme,
        'icon': Icons.settings_system_daydream
      },
    ];

    return Column(
      children: themes.map((theme) {
        final isSelected = theme['mode'] == currentTheme;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? TamgaciConstants.primaryColor.withValues(alpha: 0.1)
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? TamgaciConstants.primaryColor
                  : (isDark
                      ? TamgaciConstants.borderColorDark
                      : Colors.grey.shade300),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            leading: Icon(
              theme['icon'] as IconData,
              color: isSelected
                  ? TamgaciConstants.primaryColor
                  : (isDark ? Colors.white : TamgaciConstants.textPrimary),
            ),
            title: Text(
              theme['name'] as String,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? TamgaciConstants.primaryColor
                    : (isDark ? Colors.white : TamgaciConstants.textPrimary),
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: TamgaciConstants.primaryColor,
                  )
                : null,
            onTap: () {
              ref
                  .read(themeProvider.notifier)
                  .setTheme(theme['mode'] as ThemeMode);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrencySettings(bool isDark, Currency selectedCurrency,
      List<Currency> activeCurrencies, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? TamgaciConstants.borderColorDark : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.currency_exchange,
                color: TamgaciConstants.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.currencySettings,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.defaultCurrency,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : TamgaciConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.defaultCurrencyDescription,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildCurrencySelector(
              isDark, selectedCurrency, activeCurrencies, l10n),
          const SizedBox(height: 20),
          _buildExchangeRatesInfo(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(bool isDark, Currency selectedCurrency,
      List<Currency> currencies, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color:
              isDark ? TamgaciConstants.borderColorDark : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<Currency>(
        initialValue: selectedCurrency,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: l10n.selectCurrency,
          hintStyle: GoogleFonts.poppins(
            color: isDark
                ? TamgaciConstants.textSecondaryDark
                : TamgaciConstants.textSecondary,
          ),
        ),
        items: currencies.map((currency) {
          return DropdownMenuItem<Currency>(
            value: currency,
            child: Row(
              children: [
                Text(
                  currency.symbol,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TamgaciConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currency.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : TamgaciConstants.textPrimary,
                        ),
                      ),
                      Text(
                        currency.country,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark
                              ? TamgaciConstants.textSecondaryDark
                              : TamgaciConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (Currency? newValue) {
          if (newValue != null) {
            ref
                .read(selectedCurrencyProvider.notifier)
                .selectCurrency(newValue);
          }
        },
        dropdownColor: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        style: GoogleFonts.poppins(
          color: isDark ? Colors.white : TamgaciConstants.textPrimary,
        ),
      ),
    );
  }

  Widget _buildExchangeRatesInfo(bool isDark, AppLocalizations l10n) {
    final exchangeRatesAsync = ref.watch(exchangeRatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.trending_up,
              color: TamgaciConstants.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.currentRates,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : TamgaciConstants.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        exchangeRatesAsync.when(
          data: (exchangeRates) {
            return Column(
              children: exchangeRates.take(5).map((currency) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${currency.symbol} ${currency.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : TamgaciConstants.textPrimary,
                        ),
                      ),
                      Text(
                        '${currency.exchangeRate.toStringAsFixed(4)} ₺',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: TamgaciConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text(
            '${l10n.ratesLoadError}: $error',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: TamgaciConstants.errorColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherSettings(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? TamgaciConstants.borderColorDark : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tune,
                color: TamgaciConstants.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.otherSettings,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            l10n.autoUpdateRates,
            l10n.autoUpdateRatesDescription,
            Icons.sync,
            true,
            isDark,
            (value) {
              // TODO: Implement auto update setting
            },
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            l10n.notifications,
            l10n.notificationsDescription,
            Icons.notifications,
            true,
            isDark,
            (value) {
              // TODO: Implement notifications setting
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    bool isDark,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: TamgaciConstants.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : TamgaciConstants.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark
                        ? TamgaciConstants.textSecondaryDark
                        : TamgaciConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ],
      ),
    );
  }
}
