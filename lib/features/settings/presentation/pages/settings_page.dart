// ========== SETTINGS PAGE ==========
// lib/features/settings/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../core/providers/currency_providers.dart';
import '../../../../core/domain/entities/currency.dart';

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

    return Scaffold(
      appBar: const CustomAppBar(title: 'Ayarlar', showDrawer: true),
      drawer: const TamgaciDrawerMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(isDark),
            const SizedBox(height: 16),
            _buildCurrencySettings(isDark, selectedCurrency, activeCurrencies),
            const SizedBox(height: 16),
            _buildOtherSettings(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blue.withValues(alpha: 0.8), Colors.blue]
              : [Colors.blue, Colors.blue.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
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
                  'Uygulama Ayarları',
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
            'Para birimi ve diğer tercihlerinizi yönetin',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySettings(
      bool isDark, Currency selectedCurrency, List<Currency> activeCurrencies) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TamgaciConstants.borderColor : Colors.grey.shade200,
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
                'Para Birimi Ayarları',
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
            'Varsayılan Para Birimi',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : TamgaciConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tüm işlemlerde kullanılacak varsayılan para birimini seçin',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildCurrencySelector(isDark, selectedCurrency, activeCurrencies),
          const SizedBox(height: 20),
          _buildExchangeRatesInfo(isDark),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(
      bool isDark, Currency selectedCurrency, List<Currency> currencies) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? TamgaciConstants.borderColor : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<Currency>(
        initialValue: selectedCurrency,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: 'Para birimi seçin',
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

  Widget _buildExchangeRatesInfo(bool isDark) {
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
              'Güncel Kurlar',
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
            'Kurlar yüklenemedi: $error',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: TamgaciConstants.errorColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherSettings(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TamgaciConstants.borderColor : Colors.grey.shade200,
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
                'Diğer Ayarlar',
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
            'Otomatik Kur Güncelleme',
            'Kurlar otomatik olarak güncellensin',
            Icons.sync,
            true,
            isDark,
            (value) {
              // TODO: Implement auto update setting
            },
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            'Bildirimler',
            'Önemli işlemler için bildirim al',
            Icons.notifications,
            true,
            isDark,
            (value) {
              // TODO: Implement notifications setting
            },
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            'Karanlık Tema',
            'Karanlık tema kullan',
            Icons.dark_mode,
            isDark,
            isDark,
            (value) {
              // TODO: Implement theme setting
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
