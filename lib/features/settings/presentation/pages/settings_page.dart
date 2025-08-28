// ========== SETTINGS (AYARLAR) FEATURE ==========
// lib/features/settings/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../providers/settings_providers.dart';
import '../../domain/entities/app_settings.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';

/// Ayarlar sayfası
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(title: 'Ayarlar', showDrawer: true),
      drawer: const TamgaciDrawerMenu(),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: TamgaciConstants.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Ayarlar yüklenirken hata oluştu',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: TamgaciConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.read(settingsProvider.notifier).refreshSettings(),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (settings) => RefreshIndicator(
          onRefresh: () =>
              ref.read(settingsProvider.notifier).refreshSettings(),
          child: SingleChildScrollView(
            padding: TamgaciConstants.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil bölümü
                _buildProfileSection(),

                const SizedBox(height: 24),

                // İzinler ve sistem bilgileri
                _buildPermissionsSection(),

                const SizedBox(height: 24),

                // Genel ayarlar
                _buildGeneralSettings(settings),

                const SizedBox(height: 24),

                // Bildirim ayarları
                _buildNotificationSettings(settings),

                const SizedBox(height: 24),

                // Güvenlik ayarları
                _buildSecuritySettings(settings),

                const SizedBox(height: 24),

                // Veri yönetimi
                _buildDataManagement(settings),

                const SizedBox(height: 24),

                // Hakkında
                _buildAboutSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// İzinler ve sistem bilgileri bölümü
  Widget _buildPermissionsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'İzinler ve Sistem',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: TamgaciConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Uygulama izinleri, internet bağlantısı ve sistem bilgilerini görüntüleyin',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TamgaciConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/settings/permissions'),
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                label: Text(
                  'İzinleri Yönet',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TamgaciConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(TamgaciConstants.radiusSM),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Profil bölümünü oluşturur
  Widget _buildProfileSection() {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (userProfile) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Profil fotoğrafı
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: TamgaciConstants.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: TamgaciConstants.primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: userProfile.profilePhotoUrl != null
                    ? ClipOval(
                        child: Image.file(
                          File(userProfile.profilePhotoUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 40,
                            color: TamgaciConstants.primaryColor,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 40,
                        color: TamgaciConstants.primaryColor,
                      ),
              ),

              const SizedBox(width: 16),

              // Profil bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile.fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: TamgaciConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userProfile.role,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userProfile.email,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: TamgaciConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Düzenle butonu
              IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/settings/profile'),
                icon: Icon(
                  Icons.edit_outlined,
                  color: TamgaciConstants.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: TamgaciConstants.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: TamgaciConstants.primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: TamgaciConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kullanıcı',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: TamgaciConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kullanıcı',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'kullanici@tamgaci.com',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: TamgaciConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/settings/profile'),
                icon: Icon(
                  Icons.edit_outlined,
                  color: TamgaciConstants.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Genel ayarlar bölümünü oluşturur
  Widget _buildGeneralSettings(AppSettings settings) {
    return _buildSettingsSection(
      title: 'Genel Ayarlar',
      icon: Icons.settings_outlined,
      children: [
        _buildSettingsTile(
          title: 'Karanlık Tema',
          subtitle: 'Uygulamayı karanlık temada kullan',
          leading: Icon(
            Icons.dark_mode_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Switch(
            value: settings.theme.isDarkMode,
            onChanged: (value) {
              final updatedTheme = settings.theme.copyWith(isDarkMode: value);
              ref
                  .read(settingsProvider.notifier)
                  .updateThemeSettings(updatedTheme);
            },
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ),
        _buildSettingsTile(
          title: 'Dil',
          subtitle: _getLanguageName(settings.general.language),
          leading: Icon(
            Icons.language_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: TamgaciConstants.textSecondary,
          ),
          onTap: () => _showLanguageDialog(settings),
        ),
        _buildSettingsTile(
          title: 'Tarih Formatı',
          subtitle: settings.general.dateFormat,
          leading: Icon(
            Icons.calendar_today_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: TamgaciConstants.textSecondary,
          ),
          onTap: () => _showDateFormatDialog(settings),
        ),
        _buildSettingsTile(
          title: 'Para Birimi',
          subtitle: _getCurrencyName(settings.general.currency),
          leading: Icon(
            Icons.attach_money_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: TamgaciConstants.textSecondary,
          ),
          onTap: () => _showCurrencyDialog(settings),
        ),
        _buildSettingsTile(
          title: 'Otomatik Kaydetme',
          subtitle: 'Değişiklikleri otomatik kaydet',
          leading: Icon(
            Icons.save_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Switch(
            value: settings.general.autoSave,
            onChanged: (value) {
              final updatedGeneral = settings.general.copyWith(autoSave: value);
              ref
                  .read(settingsProvider.notifier)
                  .updateGeneralSettings(updatedGeneral);
            },
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ),
      ],
    );
  }

  /// Bildirim ayarları bölümünü oluşturur
  Widget _buildNotificationSettings(AppSettings settings) {
    return _buildSettingsSection(
      title: 'Bildirimler',
      icon: Icons.notifications_outlined,
      children: [
        _buildSettingsTile(
          title: 'Bildirimler',
          subtitle: 'Uygulama bildirimlerini al',
          leading: Icon(
            Icons.notifications_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Switch(
            value: settings.notifications.isEnabled,
            onChanged: (value) {
              final updatedNotifications = settings.notifications.copyWith(
                isEnabled: value,
              );
              ref
                  .read(settingsProvider.notifier)
                  .updateNotificationSettings(updatedNotifications);
            },
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ),
        _buildSettingsTile(
          title: 'Fatura Hatırlatıcıları',
          subtitle: 'Vadesi yaklaşan faturalar için bildirim',
          leading: Icon(
            Icons.receipt_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Switch(
            value: settings.notifications.invoiceReminders,
            onChanged: (value) {
              final updatedNotifications = settings.notifications.copyWith(
                invoiceReminders: value,
              );
              ref
                  .read(settingsProvider.notifier)
                  .updateNotificationSettings(updatedNotifications);
            },
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ),
        _buildSettingsTile(
          title: 'Ödeme Hatırlatıcıları',
          subtitle: 'Ödeme tarihleri için bildirim',
          leading: Icon(
            Icons.payment_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Switch(
            value: settings.notifications.paymentReminders,
            onChanged: (value) {
              final updatedNotifications = settings.notifications.copyWith(
                paymentReminders: value,
              );
              ref
                  .read(settingsProvider.notifier)
                  .updateNotificationSettings(updatedNotifications);
            },
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ),
        _buildSettingsTile(
          title: 'Stok Uyarıları',
          subtitle: 'Düşük stok seviyeleri için bildirim',
          leading: Icon(
            Icons.inventory_2_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Switch(
            value: settings.notifications.stockAlerts,
            onChanged: (value) {
              final updatedNotifications = settings.notifications.copyWith(
                stockAlerts: value,
              );
              ref
                  .read(settingsProvider.notifier)
                  .updateNotificationSettings(updatedNotifications);
            },
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ),
        _buildSettingsTile(
          title: 'Ses Bildirimleri',
          subtitle: 'Bildirim seslerini çal',
          leading: Icon(
            Icons.volume_up_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Switch(
            value: settings.notifications.soundEnabled,
            onChanged: (value) {
              final updatedNotifications = settings.notifications.copyWith(
                soundEnabled: value,
              );
              ref
                  .read(settingsProvider.notifier)
                  .updateNotificationSettings(updatedNotifications);
            },
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ),
        _buildSettingsTile(
          title: 'Titreşim Bildirimleri',
          subtitle: 'Bildirim titreşimlerini etkinleştir',
          leading: Icon(
            Icons.vibration_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Switch(
            value: settings.notifications.vibrationEnabled,
            onChanged: (value) {
              final updatedNotifications = settings.notifications.copyWith(
                vibrationEnabled: value,
              );
              ref
                  .read(settingsProvider.notifier)
                  .updateNotificationSettings(updatedNotifications);
            },
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ),
      ],
    );
  }

  /// Güvenlik ayarları bölümünü oluşturur
  Widget _buildSecuritySettings(AppSettings settings) {
    return _buildSettingsSection(
      title: 'Güvenlik',
      icon: Icons.security_outlined,
      children: [
        _buildSettingsTile(
          title: 'Şifre Değiştir',
          subtitle: 'Hesap şifrenizi güncelleyin',
          leading: Icon(
            Icons.lock_outline,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: TamgaciConstants.textSecondary,
          ),
          onTap: () => _showChangePasswordDialog(),
        ),
        _buildSettingsTile(
          title: 'Biometrik Giriş',
          subtitle: 'Parmak izi veya yüz tanıma ile giriş',
          leading: Icon(
            Icons.fingerprint_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Switch(
            value: settings.security.biometricEnabled,
            onChanged: (value) {
              final updatedSecurity = settings.security.copyWith(
                biometricEnabled: value,
              );
              ref
                  .read(settingsProvider.notifier)
                  .updateSecuritySettings(updatedSecurity);
            },
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ),
        _buildSettingsTile(
          title: 'İki Faktörlü Doğrulama',
          subtitle: 'Ek güvenlik için 2FA kullanın',
          leading: Icon(
            Icons.verified_user_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Switch(
            value: settings.security.twoFactorEnabled,
            onChanged: (value) {
              final updatedSecurity = settings.security.copyWith(
                twoFactorEnabled: value,
              );
              ref
                  .read(settingsProvider.notifier)
                  .updateSecuritySettings(updatedSecurity);
            },
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ),
        _buildSettingsTile(
          title: 'Otomatik Kilitlenme',
          subtitle:
              '${settings.security.autoLockTimeout} dakika sonra kilitlen',
          leading: Icon(
            Icons.timer_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: TamgaciConstants.textSecondary,
          ),
          onTap: () => _showAutoLockDialog(settings),
        ),
      ],
    );
  }

  /// Veri yönetimi bölümünü oluşturur
  Widget _buildDataManagement(AppSettings settings) {
    return _buildSettingsSection(
      title: 'Veri Yönetimi',
      icon: Icons.storage_outlined,
      children: [
        _buildSettingsTile(
          title: 'Otomatik Yedekleme',
          subtitle: 'Verilerinizi otomatik olarak yedekleyin',
          leading: Icon(
            Icons.backup_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Switch(
            value: settings.data.cloudBackup,
            onChanged: (value) {
              final updatedData = settings.data.copyWith(cloudBackup: value);
              ref
                  .read(settingsProvider.notifier)
                  .updateDataSettings(updatedData);
            },
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ),
        _buildSettingsTile(
          title: 'Yedekleme Sıklığı',
          subtitle: '${settings.data.backupFrequency} günde bir',
          leading: Icon(
            Icons.schedule_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: TamgaciConstants.textSecondary,
          ),
          onTap: () => _showBackupFrequencyDialog(settings),
        ),
        _buildSettingsTile(
          title: 'Veri Şifreleme',
          subtitle: 'Verilerinizi şifreleyerek koruyun',
          leading: Icon(
            Icons.security_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Switch(
            value: settings.data.dataEncryption,
            onChanged: (value) {
              final updatedData = settings.data.copyWith(dataEncryption: value);
              ref
                  .read(settingsProvider.notifier)
                  .updateDataSettings(updatedData);
            },
            activeThumbColor: TamgaciConstants.primaryColor,
          ),
        ),
        _buildSettingsTile(
          title: 'Veri Dışa Aktar',
          subtitle: 'Tüm verilerinizi Excel/PDF olarak indirin',
          leading: Icon(
            Icons.download_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: TamgaciConstants.textSecondary,
          ),
          onTap: () => _showExportDataDialog(),
        ),
        _buildSettingsTile(
          title: 'Veri İçe Aktar',
          subtitle: 'Dışarıdan veri yükleyin',
          leading: Icon(
            Icons.upload_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: TamgaciConstants.textSecondary,
          ),
          onTap: () => _showImportDataDialog(),
        ),
        _buildSettingsTile(
          title: 'Verileri Temizle',
          subtitle: 'Tüm verileri kalıcı olarak silin',
          leading: Icon(
            Icons.delete_forever_outlined,
            color: TamgaciConstants.errorColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: TamgaciConstants.textSecondary,
          ),
          onTap: () => _showClearDataDialog(),
        ),
      ],
    );
  }

  /// Hakkında bölümünü oluşturur
  Widget _buildAboutSection() {
    return _buildSettingsSection(
      title: 'Hakkında',
      icon: Icons.info_outline,
      children: [
        _buildSettingsTile(
          title: 'Uygulama Versiyonu',
          subtitle: 'v1.0.0',
          leading: Icon(
            Icons.apps_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: const SizedBox.shrink(),
        ),
        _buildSettingsTile(
          title: 'Lisans',
          subtitle: 'MIT License',
          leading: Icon(
            Icons.description_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: TamgaciConstants.textSecondary,
          ),
          onTap: () => _showLicenseDialog(),
        ),
        _buildSettingsTile(
          title: 'Gizlilik Politikası',
          subtitle: 'Veri kullanım koşulları',
          leading: Icon(
            Icons.privacy_tip_outlined,
            color: TamgaciConstants.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: TamgaciConstants.textSecondary,
          ),
          onTap: () => _showPrivacyPolicyDialog(),
        ),
        _buildSettingsTile(
          title: 'Çıkış Yap',
          subtitle: 'Hesabınızdan güvenli çıkış',
          leading: Icon(
            Icons.logout_outlined,
            color: TamgaciConstants.errorColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: TamgaciConstants.textSecondary,
          ),
          onTap: () => _showLogoutDialog(),
        ),
      ],
    );
  }

  /// Ayarlar bölümü oluşturur
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: TamgaciConstants.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  /// Ayarlar öğesi oluşturur
  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required Widget leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: TamgaciConstants.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: TamgaciConstants.textSecondary,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  // ========== HELPER METHODS ==========

  /// Dil adını getir
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return 'Türkçe';
    }
  }

  /// Para birimi adını getir
  String _getCurrencyName(String currencyCode) {
    switch (currencyCode) {
      case 'TRY':
        return 'Türk Lirası (₺)';
      case 'USD':
        return 'Amerikan Doları (\$)';
      case 'EUR':
        return 'Euro (€)';
      default:
        return 'Türk Lirası (₺)';
    }
  }

  // ========== DIALOG METHODS ==========

  void _showLanguageDialog(AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seçimi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Uygulama dilini seçin:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: settings.general.language,
              items: [
                DropdownMenuItem(value: 'tr', child: const Text('Türkçe')),
                DropdownMenuItem(value: 'en', child: const Text('English')),
              ],
              onChanged: (value) {
                if (value != null) {
                  final updatedGeneral = settings.general.copyWith(
                    language: value,
                  );
                  ref
                      .read(settingsProvider.notifier)
                      .updateGeneralSettings(updatedGeneral);
                  Navigator.of(context).pop();
                }
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
      ),
    );
  }

  void _showDateFormatDialog(AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tarih Formatı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tarih formatını seçin:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: settings.general.dateFormat,
              items: [
                DropdownMenuItem(
                  value: 'dd/MM/yyyy',
                  child: const Text('DD/MM/YYYY'),
                ),
                DropdownMenuItem(
                  value: 'MM/dd/yyyy',
                  child: const Text('MM/DD/YYYY'),
                ),
                DropdownMenuItem(
                  value: 'yyyy-MM-dd',
                  child: const Text('YYYY-MM-DD'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  final updatedGeneral = settings.general.copyWith(
                    dateFormat: value,
                  );
                  ref
                      .read(settingsProvider.notifier)
                      .updateGeneralSettings(updatedGeneral);
                  Navigator.of(context).pop();
                }
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
      ),
    );
  }

  void _showCurrencyDialog(AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Para Birimi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Para birimini seçin:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: settings.general.currency,
              items: [
                DropdownMenuItem(
                  value: 'TRY',
                  child: const Text('Türk Lirası (₺)'),
                ),
                DropdownMenuItem(
                  value: 'USD',
                  child: const Text('Amerikan Doları (\$)'),
                ),
                DropdownMenuItem(value: 'EUR', child: const Text('Euro (€)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  final updatedGeneral = settings.general.copyWith(
                    currency: value,
                  );
                  ref
                      .read(settingsProvider.notifier)
                      .updateGeneralSettings(updatedGeneral);
                  Navigator.of(context).pop();
                }
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
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: const Text('Şifre değiştirme özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veri Dışa Aktar'),
        content: const Text('Veri dışa aktarma özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showImportDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veri İçe Aktar'),
        content: const Text('Veri içe aktarma özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Temizle'),
        content: const Text(
          'Bu işlem tüm verilerinizi kalıcı olarak silecektir. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Veri temizleme işlemi
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TamgaciConstants.errorColor,
            ),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  void _showLicenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lisans'),
        content: const Text('MIT License bilgileri burada görüntülenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gizlilik Politikası'),
        content: const Text('Gizlilik politikası burada görüntülenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Çıkış işlemi
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TamgaciConstants.errorColor,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  void _showAutoLockDialog(AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Otomatik Kilitlenme Süresi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Uygulama kaç dakika sonra kilitlensin?'),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: settings.security.autoLockTimeout,
              items: [1, 3, 5, 10, 15, 30].map((minutes) {
                return DropdownMenuItem(
                  value: minutes,
                  child: Text('$minutes dakika'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final updatedSecurity = settings.security.copyWith(
                    autoLockTimeout: value,
                  );
                  ref
                      .read(settingsProvider.notifier)
                      .updateSecuritySettings(updatedSecurity);
                  Navigator.of(context).pop();
                }
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
      ),
    );
  }

  void _showBackupFrequencyDialog(AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yedekleme Sıklığı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Kaç günde bir yedekleme yapılsın?'),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: settings.data.backupFrequency,
              items: [1, 3, 7, 14, 30].map((days) {
                return DropdownMenuItem(value: days, child: Text('$days gün'));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final updatedData = settings.data.copyWith(
                    backupFrequency: value,
                  );
                  ref
                      .read(settingsProvider.notifier)
                      .updateDataSettings(updatedData);
                  Navigator.of(context).pop();
                }
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
      ),
    );
  }
}
