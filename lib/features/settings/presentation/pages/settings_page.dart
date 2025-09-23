// ========== SETTINGS PAGE ==========
// lib/features/settings/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../core/providers/currency_providers.dart';
import '../../../../core/domain/entities/currency.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../presentation/providers/settings_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/routes/routes.dart';

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
    final l10n = AppLocalizations.of(context);

    return ResponsiveScaffold(
      appBar: CustomAppBar(title: l10n.settings, showDrawer: true),
      drawerContent: const TamgaciDrawerMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            _buildWelcomeCard(isDark, l10n),
            const SizedBox(height: 24),

            // Genel Ayarlar
            _buildCategoryHeader("Genel Ayarlar", Icons.settings, isDark),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Abonelik",
              icon: Icons.workspace_premium,
              isDark: isDark,
              child: _buildSubscriptionSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Firma Bilgileri",
              icon: Icons.business,
              isDark: isDark,
              child: _buildCompanyInfoSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Logo ve Marka Renkleri",
              icon: Icons.palette,
              isDark: isDark,
              child: _buildBrandingSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: l10n.language,
              icon: Icons.language,
              isDark: isDark,
              child: _buildSimpleLanguageSelector(isDark, l10n),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: l10n.currencySettings,
              icon: Icons.currency_exchange,
              isDark: isDark,
              child: _buildSimpleCurrencySelector(isDark, l10n),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Tarih ve Saat Formatı",
              icon: Icons.calendar_today,
              isDark: isDark,
              child: _buildDateTimeFormatSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "KDV / Vergi Oranları",
              icon: Icons.account_balance,
              isDark: isDark,
              child: _buildTaxSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Para Birimi & Kur Ayarları",
              icon: Icons.calculate,
              isDark: isDark,
              child: _buildRoundingAndFxSettings(isDark),
            ),
            const SizedBox(height: 24),

            // Kullanıcı & Yetkilendirme
            _buildCategoryHeader(
                "Kullanıcı & Yetkilendirme", Icons.people, isDark),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Kullanıcı Yönetimi",
              icon: Icons.person_add,
              isDark: isDark,
              child: _buildUserManagementSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Rol & Yetki Yönetimi",
              icon: Icons.admin_panel_settings,
              isDark: isDark,
              child: _buildRolePermissionSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Güvenlik Ayarları",
              icon: Icons.security,
              isDark: isDark,
              child: _buildSecuritySettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "İki Faktörlü Kimlik Doğrulama",
              icon: Icons.verified_user,
              isDark: isDark,
              child: _buildTwoFactorAuthSettings(isDark),
            ),
            const SizedBox(height: 24),

            // Satış & Fatura
            _buildCategoryHeader("Satış & Fatura", Icons.receipt_long, isDark),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Fatura Şablonları",
              icon: Icons.description,
              isDark: isDark,
              child: _buildInvoiceTemplateSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Belge Ayarları",
              icon: Icons.assignment,
              isDark: isDark,
              child: _buildDocumentSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Vade ve Hatırlatma Kuralları",
              icon: Icons.schedule,
              isDark: isDark,
              child: _buildPaymentReminderSettings(isDark),
            ),
            const SizedBox(height: 24),

            // Raporlama & Bildirimler
            _buildCategoryHeader(
                "Raporlama & Bildirimler", Icons.analytics, isDark),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Otomatik Rapor Gönderimi",
              icon: Icons.send,
              isDark: isDark,
              child: _buildAutoReportSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Bildirim Tercihleri",
              icon: Icons.notifications,
              isDark: isDark,
              child: _buildNotificationPreferences(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Dashboard Özelleştirme",
              icon: Icons.dashboard,
              isDark: isDark,
              child: _buildDashboardCustomization(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Alarm & Hatırlatmalar",
              icon: Icons.alarm,
              isDark: isDark,
              child: _buildAlarmReminderSettings(isDark),
            ),
            const SizedBox(height: 24),

            // Güvenlik & Yedekleme
            _buildCategoryHeader("Güvenlik & Yedekleme", Icons.backup, isDark),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Veri Yedekleme",
              icon: Icons.cloud_upload,
              isDark: isDark,
              child: _buildDataBackupSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Veri Dışa Aktarma",
              icon: Icons.file_download,
              isDark: isDark,
              child: _buildDataExportSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Log Kayıtları",
              icon: Icons.history,
              isDark: isDark,
              child: _buildLogSettings(isDark),
            ),
            const SizedBox(height: 24),

            // Bildirim ve İletişim
            _buildCategoryHeader("Bildirim ve İletişim", Icons.message, isDark),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "E-posta Şablonları",
              icon: Icons.email,
              isDark: isDark,
              child: _buildEmailTemplateSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "SMS / Mobil Bildirim",
              icon: Icons.sms,
              isDark: isDark,
              child: _buildSmsNotificationSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Bildirim Sıklığı",
              icon: Icons.schedule_send,
              isDark: isDark,
              child: _buildNotificationFrequencySettings(isDark),
            ),
            const SizedBox(height: 24),

            // Belge / Şablon / Yazdırma
            _buildCategoryHeader(
                "Belge / Şablon / Yazdırma", Icons.print, isDark),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Belge Şablon Tasarımı",
              icon: Icons.design_services,
              isDark: isDark,
              child: _buildDocumentTemplateDesign(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Yazıcı Ayarları",
              icon: Icons.print,
              isDark: isDark,
              child: _buildPrinterSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Belge Formatları",
              icon: Icons.picture_as_pdf,
              isDark: isDark,
              child: _buildDocumentFormatSettings(isDark),
            ),
            const SizedBox(height: 24),

            // Kategoriler/Sınıflandırmalar
            _buildCategoryHeader(
                "Kategoriler/Sınıflandırmalar", Icons.category, isDark),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Ürün Kategorileri",
              icon: Icons.inventory_2,
              isDark: isDark,
              child: _buildProductCategorySettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Müşteri Kategorileri",
              icon: Icons.people_alt,
              isDark: isDark,
              child: _buildCustomerCategorySettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Tedarikçi Kategorileri",
              icon: Icons.local_shipping,
              isDark: isDark,
              child: _buildSupplierCategorySettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Etiket Yönetimi",
              icon: Icons.label,
              isDark: isDark,
              child: _buildTagManagementSettings(isDark),
            ),
            const SizedBox(height: 24),

            // Görünüm & Tema
            _buildCategoryHeader("Görünüm & Tema", Icons.visibility, isDark),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: l10n.theme,
              icon: Icons.palette,
              isDark: isDark,
              child: _buildSimpleThemeSelector(isDark, l10n),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Görünüm Ayarları",
              icon: Icons.tune,
              isDark: isDark,
              child: _buildViewSettings(isDark),
            ),
            const SizedBox(height: 12),
            _buildSimpleSection(
              title: "Performans Ayarları",
              icon: Icons.speed,
              isDark: isDark,
              child: _buildPerformanceSettings(isDark),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settings,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsDescription,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSection({
    required String title,
    required IconData icon,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSimpleLanguageSelector(bool isDark, AppLocalizations l10n) {
    final currentLocale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    final supportedLocales = localeNotifier.supportedLocales;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: currentLocale,
          isExpanded: true,
          items: supportedLocales.map((locale) {
            return DropdownMenuItem<Locale>(
              value: locale,
              child: Row(
                children: [
                  Text(localeNotifier.getLocaleFlag(locale),
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(
                    localeNotifier.getLocaleName(locale),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (Locale? newValue) {
            if (newValue != null) {
              localeNotifier.setLocale(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSimpleThemeSelector(bool isDark, AppLocalizations l10n) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Column(
      children: [
        _buildThemeOption(
          title: l10n.lightTheme,
          icon: Icons.light_mode,
          isSelected: currentTheme == ThemeMode.light,
          isDark: isDark,
          onTap: () => themeNotifier.setTheme(ThemeMode.light),
        ),
        const SizedBox(height: 8),
        _buildThemeOption(
          title: l10n.darkTheme,
          icon: Icons.dark_mode,
          isSelected: currentTheme == ThemeMode.dark,
          isDark: isDark,
          onTap: () => themeNotifier.setTheme(ThemeMode.dark),
        ),
        const SizedBox(height: 8),
        _buildThemeOption(
          title: l10n.systemTheme,
          icon: Icons.settings_system_daydream,
          isSelected: currentTheme == ThemeMode.system,
          isDark: isDark,
          onTap: () => themeNotifier.setTheme(ThemeMode.system),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.1)
              : (isDark ? Colors.grey[700] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.blue
                  : (isDark ? Colors.white : Colors.black),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.blue
                      : (isDark ? Colors.white : Colors.black),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleCurrencySelector(bool isDark, AppLocalizations l10n) {
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final activeCurrencies = ref.watch(activeCurrenciesProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Currency>(
          value: selectedCurrency,
          isExpanded: true,
          items: activeCurrencies.map((currency) {
            return DropdownMenuItem<Currency>(
              value: currency,
              child: Row(
                children: [
                  Text(
                    currency.symbol,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currency.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
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
        ),
      ),
    );
  }

  // Genel Ayarlar
  Widget _buildCompanyInfoSettings(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Profili Düzenle", isDark, () {
          Navigator.of(context).pushNamed(TamgaciRoutes.profile);
        }),
        const SizedBox(height: 8),
        _buildActionButton("Firma Bilgilerini Düzenle", isDark, () {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Vergi Numarası Görünür", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting(
            "Adres Bilgileri Görünür", true, isDark, (value) {}),
      ],
    );
  }

  Widget _buildBrandingSettings(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Logo Yükle", isDark, () {}),
        const SizedBox(height: 8),
        _buildActionButton("Marka Renklerini Ayarla", isDark, () {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Otomatik Renk Uyumu", true, isDark, (value) {}),
      ],
    );
  }

  Widget _buildSubscriptionSettings(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionButton("Abonelik Planları", isDark, () {
          Navigator.of(context).pushNamed(TamgaciRoutes.subscription);
        }),
        const SizedBox(height: 8),
        Text(
          "Planınızı buradan yönetebilirsiniz.",
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeFormatSettings(bool isDark) {
    return Column(
      children: [
        _buildSimpleDropdown(
          value: "DD/MM/YYYY",
          items: ["DD/MM/YYYY", "MM/DD/YYYY", "YYYY-MM-DD"],
          isDark: isDark,
          onChanged: (value) {},
        ),
        const SizedBox(height: 8),
        _buildSimpleDropdown(
          value: "24 Saat",
          items: ["12 Saat", "24 Saat"],
          isDark: isDark,
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildTaxSettings(bool isDark) {
    return Column(
      children: [
        _buildSwitchSetting("KDV Dahil Fiyatlar", false, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("ÖTV Hesaplama", false, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildActionButton("Vergi Oranlarını Yönet", isDark, () {}),
      ],
    );
  }

  Widget _buildRoundingAndFxSettings(bool isDark) {
    final settingsAsync = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return settingsAsync.when(
      data: (s) {
        final roundingMode =
            (s.customSettings['roundingMode']?.toString() ?? 'halfUp');
        final roundingDecimals = int.tryParse(
              (s.customSettings['roundingDecimals']?.toString() ?? '2'),
            ) ??
            2;
        final fxSource =
            (s.customSettings['fxSource']?.toString() ?? 'TCMB_EVDS');
        final numbering = (s.customSettings['numberingScheme']?.toString() ??
            'INV-{YYYY}-{####}');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rounding Mode
            _buildSimpleDropdown(
              value: roundingMode,
              items: const ['halfUp', 'floor', 'ceil'],
              isDark: isDark,
              onChanged: (val) {
                if (val != null) notifier.updateRoundingMode(val);
              },
            ),
            const SizedBox(height: 8),
            // Rounding Decimals
            _buildSimpleDropdown(
              value: roundingDecimals.toString(),
              items: const ['0', '1', '2', '3', '4', '5', '6'],
              isDark: isDark,
              onChanged: (val) {
                final v = int.tryParse(val ?? '2') ?? 2;
                notifier.updateRoundingDecimals(v);
              },
            ),
            const SizedBox(height: 8),
            // FX Source
            _buildSimpleDropdown(
              value: fxSource,
              items: const ['TCMB_EVDS', 'MANUAL_ONLY'],
              isDark: isDark,
              onChanged: (val) {
                if (val != null) notifier.updateFxSource(val);
              },
            ),
            const SizedBox(height: 8),
            // Numbering Scheme
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number,
                      color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      numbering,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () async {
                      final controller = TextEditingController(text: numbering);
                      final res = await showDialog<String>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Numaralandırma Şeması'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'INV-{YYYY}-{####}',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('İptal')),
                            TextButton(
                                onPressed: () => Navigator.pop(
                                    context, controller.text.trim()),
                                child: const Text('Kaydet')),
                          ],
                        ),
                      );
                      if (res != null && res.isNotEmpty) {
                        notifier.updateNumberingScheme(res);
                      }
                    },
                    child: const Text('Düzenle'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // Kullanıcı & Yetkilendirme
  Widget _buildUserManagementSettings(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Kullanıcı Ekle", isDark, () {}),
        const SizedBox(height: 8),
        _buildActionButton("Kullanıcı Listesi", isDark, () {}),
        const SizedBox(height: 8),
        _buildSwitchSetting(
            "Otomatik Kullanıcı Onayı", false, isDark, (value) {}),
      ],
    );
  }

  Widget _buildRolePermissionSettings(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Rolleri Yönet", isDark, () {}),
        const SizedBox(height: 8),
        _buildActionButton("Yetkileri Düzenle", isDark, () {}),
        const SizedBox(height: 8),
        _buildSwitchSetting(
            "Hiyerarşik Yetki Sistemi", true, isDark, (value) {}),
      ],
    );
  }

  Widget _buildSecuritySettings(bool isDark) {
    return Column(
      children: [
        _buildSwitchSetting(
            "Güçlü Şifre Zorunluluğu", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Oturum Süresi Sınırı", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("IP Kısıtlaması", false, isDark, (value) {}),
      ],
    );
  }

  Widget _buildTwoFactorAuthSettings(bool isDark) {
    return Column(
      children: [
        _buildSwitchSetting("2FA Zorunlu", false, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("SMS Doğrulama", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("E-posta Doğrulama", true, isDark, (value) {}),
      ],
    );
  }

  // Satış & Fatura
  Widget _buildInvoiceTemplateSettings(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Fatura Şablonu Tasarımı", isDark, () {}),
        const SizedBox(height: 8),
        _buildActionButton("İrsaliye Şablonu", isDark, () {}),
        const SizedBox(height: 8),
        _buildActionButton("Teklif Şablonu", isDark, () {}),
      ],
    );
  }

  Widget _buildDocumentSettings(bool isDark) {
    return Column(
      children: [
        _buildSwitchSetting(
            "Otomatik Belge Numarası", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Seri Numarası Takibi", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Belge Onay Sistemi", false, isDark, (value) {}),
      ],
    );
  }

  Widget _buildPaymentReminderSettings(bool isDark) {
    return Column(
      children: [
        _buildSimpleDropdown(
          value: "30 Gün",
          items: ["15 Gün", "30 Gün", "45 Gün", "60 Gün"],
          isDark: isDark,
          onChanged: (value) {},
        ),
        const SizedBox(height: 8),
        _buildSwitchSetting("Otomatik Hatırlatma", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("E-posta Hatırlatması", true, isDark, (value) {}),
      ],
    );
  }

  // Raporlama & Bildirimler
  Widget _buildAutoReportSettings(bool isDark) {
    return Column(
      children: [
        _buildSwitchSetting("Günlük Satış Raporu", false, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Haftalık Stok Raporu", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Aylık Finansal Rapor", true, isDark, (value) {}),
      ],
    );
  }

  Widget _buildNotificationPreferences(bool isDark) {
    return Column(
      children: [
        _buildSwitchSetting("Mobil Bildirimler", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("E-posta Bildirimleri", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("SMS Bildirimleri", false, isDark, (value) {}),
      ],
    );
  }

  Widget _buildDashboardCustomization(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Dashboard Düzenle", isDark, () {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Özel Widget'lar", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Gerçek Zamanlı Veriler", true, isDark, (value) {}),
      ],
    );
  }

  Widget _buildAlarmReminderSettings(bool isDark) {
    return Column(
      children: [
        _buildSwitchSetting("Düşük Stok Alarmı", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting(
            "Vadesi Gelen Borç Alarmı", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Kritik Stok Alarmı", true, isDark, (value) {}),
      ],
    );
  }

  // Güvenlik & Yedekleme
  Widget _buildDataBackupSettings(bool isDark) {
    return Column(
      children: [
        _buildSwitchSetting("Otomatik Yedekleme", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSimpleDropdown(
          value: "Günlük",
          items: ["Saatlik", "Günlük", "Haftalık", "Aylık"],
          isDark: isDark,
          onChanged: (value) {},
        ),
        const SizedBox(height: 8),
        _buildActionButton("Manuel Yedekleme", isDark, () {}),
      ],
    );
  }

  Widget _buildDataExportSettings(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Excel'e Aktar", isDark, () {}),
        const SizedBox(height: 8),
        _buildActionButton("CSV'ye Aktar", isDark, () {}),
        const SizedBox(height: 8),
        _buildActionButton("PDF Raporu", isDark, () {}),
      ],
    );
  }

  Widget _buildLogSettings(bool isDark) {
    return Column(
      children: [
        _buildSwitchSetting("Detaylı Loglama", false, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Hata Loglama", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildActionButton("Log Dosyalarını Görüntüle", isDark, () {}),
      ],
    );
  }

  // Bildirim ve İletişim
  Widget _buildEmailTemplateSettings(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Fatura E-posta Şablonu", isDark, () {}),
        const SizedBox(height: 8),
        _buildActionButton("Hatırlatma E-posta Şablonu", isDark, () {}),
        const SizedBox(height: 8),
        _buildActionButton("Hoş Geldin E-posta Şablonu", isDark, () {}),
      ],
    );
  }

  Widget _buildSmsNotificationSettings(bool isDark) {
    return Column(
      children: [
        _buildSwitchSetting("SMS Bildirimleri", false, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildActionButton("SMS Şablonları", isDark, () {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("SMS Kredi Takibi", true, isDark, (value) {}),
      ],
    );
  }

  Widget _buildNotificationFrequencySettings(bool isDark) {
    return Column(
      children: [
        _buildSimpleDropdown(
          value: "Anlık",
          items: ["Anlık", "Günlük Özet", "Haftalık Özet", "Aylık Özet"],
          isDark: isDark,
          onChanged: (value) {},
        ),
        const SizedBox(height: 8),
        _buildSwitchSetting("Toplu Bildirim", false, isDark, (value) {}),
      ],
    );
  }

  // Belge / Şablon / Yazdırma
  Widget _buildDocumentTemplateDesign(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Fatura Tasarımı", isDark, () {}),
        const SizedBox(height: 8),
        _buildActionButton("İrsaliye Tasarımı", isDark, () {}),
        const SizedBox(height: 8),
        _buildActionButton("Makbuz Tasarımı", isDark, () {}),
      ],
    );
  }

  Widget _buildPrinterSettings(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Varsayılan Yazıcı Seç", isDark, () {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Otomatik Yazdırma", false, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Baskı Önizleme", true, isDark, (value) {}),
      ],
    );
  }

  Widget _buildDocumentFormatSettings(bool isDark) {
    return Column(
      children: [
        _buildSwitchSetting("PDF Formatı", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("HTML Formatı", false, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Baskı Çıkışı", true, isDark, (value) {}),
      ],
    );
  }

  // Kategoriler/Sınıflandırmalar
  Widget _buildProductCategorySettings(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Ürün Kategorilerini Yönet", isDark, () {}),
        const SizedBox(height: 8),
        _buildSwitchSetting(
            "Otomatik Kategori Önerisi", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildActionButton("Kategori İçe Aktar", isDark, () {}),
      ],
    );
  }

  Widget _buildCustomerCategorySettings(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Müşteri Kategorilerini Yönet", isDark, () {}),
        const SizedBox(height: 8),
        _buildSwitchSetting(
            "Kategori Bazlı Fiyatlandırma", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildActionButton("Kategori Raporları", isDark, () {}),
      ],
    );
  }

  Widget _buildSupplierCategorySettings(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Tedarikçi Kategorilerini Yönet", isDark, () {}),
        const SizedBox(height: 8),
        _buildSwitchSetting(
            "Kategori Bazlı Performans", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildActionButton("Tedarikçi Analizi", isDark, () {}),
      ],
    );
  }

  Widget _buildTagManagementSettings(bool isDark) {
    return Column(
      children: [
        _buildActionButton("Etiketleri Yönet", isDark, () {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Otomatik Etiketleme", false, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildActionButton("Etiket Raporları", isDark, () {}),
      ],
    );
  }

  // Görünüm & Tema
  Widget _buildViewSettings(bool isDark) {
    return Column(
      children: [
        _buildSimpleDropdown(
          value: "Orta",
          items: ["Küçük", "Orta", "Büyük"],
          isDark: isDark,
          onChanged: (value) {},
        ),
        const SizedBox(height: 8),
        _buildSwitchSetting("Kompakt Görünüm", false, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Animasyonlar", true, isDark, (value) {}),
      ],
    );
  }

  Widget _buildPerformanceSettings(bool isDark) {
    return Column(
      children: [
        _buildSwitchSetting("Lazy Loading", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Görsel Optimizasyonu", true, isDark, (value) {}),
        const SizedBox(height: 8),
        _buildSwitchSetting("Veri Sıkıştırma", false, isDark, (value) {}),
      ],
    );
  }

  // Yardımcı Widget'lar
  Widget _buildSimpleDropdown({
    required String value,
    required List<String> items,
    required bool isDark,
    required Function(String?) onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
      String title, bool value, bool isDark, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, bool isDark, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
