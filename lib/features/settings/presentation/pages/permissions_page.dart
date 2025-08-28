// ========== PERMISSIONS PAGE ==========
// lib/features/settings/presentation/pages/permissions_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../core/providers/permission_providers.dart';

/// İzinler sayfası
class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({super.key});

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar:
          const CustomAppBar(title: 'İzinler ve Ayarlar', showDrawer: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İnternet bağlantısı
            _buildInternetSection(),
            const SizedBox(height: 24),

            // İzinler
            _buildPermissionsSection(),
            const SizedBox(height: 24),

            // Cihaz bilgileri
            _buildDeviceInfoSection(),
            const SizedBox(height: 24),

            // Uygulama bilgileri
            _buildAppInfoSection(),
          ],
        ),
      ),
    );
  }

  /// İnternet bağlantısı bölümü
  Widget _buildInternetSection() {
    final internetAsync = ref.watch(internetConnectionProvider);
    final connectionTypeAsync = ref.watch(connectionTypeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'İnternet Bağlantısı',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            internetAsync.when(
              data: (isConnected) => Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'Bağlı' : 'Bağlantı Yok',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Hata'),
            ),
            const SizedBox(height: 8),
            connectionTypeAsync.when(
              data: (connectionType) => Text(
                'Bağlantı Tipi: $connectionType',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TamgaciConstants.textSecondary,
                ),
              ),
              loading: () => const Text('Yükleniyor...'),
              error: (_, __) => const Text('Hata'),
            ),
          ],
        ),
      ),
    );
  }

  /// İzinler bölümü
  Widget _buildPermissionsSection() {
    final permissionsAsync = ref.watch(allPermissionStatusesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  'Uygulama İzinleri',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            permissionsAsync.when(
              data: (permissions) => Column(
                children: [
                  _buildPermissionItem(
                    'Konum',
                    Icons.location_on,
                    permissions['location'] ?? PermissionStatus.denied,
                    () => ref
                        .read(permissionNotifierProvider.notifier)
                        .requestLocationPermission(),
                  ),
                  _buildPermissionItem(
                    'Kamera',
                    Icons.camera_alt,
                    permissions['camera'] ?? PermissionStatus.denied,
                    () => ref
                        .read(permissionNotifierProvider.notifier)
                        .requestCameraPermission(),
                  ),
                  _buildPermissionItem(
                    'Depolama',
                    Icons.folder,
                    permissions['storage'] ?? PermissionStatus.denied,
                    () => ref
                        .read(permissionNotifierProvider.notifier)
                        .requestStoragePermission(),
                  ),
                  _buildPermissionItem(
                    'Mikrofon',
                    Icons.mic,
                    permissions['microphone'] ?? PermissionStatus.denied,
                    () => ref
                        .read(permissionNotifierProvider.notifier)
                        .requestMicrophonePermission(),
                  ),
                  _buildPermissionItem(
                    'Bildirimler',
                    Icons.notifications,
                    permissions['notification'] ?? PermissionStatus.denied,
                    () => ref
                        .read(permissionNotifierProvider.notifier)
                        .requestNotificationPermission(),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('İzinler yüklenirken hata oluştu'),
            ),
          ],
        ),
      ),
    );
  }

  /// İzin öğesi
  Widget _buildPermissionItem(
    String title,
    IconData icon,
    PermissionStatus status,
    VoidCallback onRequest,
  ) {
    Color statusColor;
    String statusText;

    switch (status) {
      case PermissionStatus.granted:
        statusColor = Colors.green;
        statusText = 'İzin Verildi';
        break;
      case PermissionStatus.denied:
        statusColor = Colors.orange;
        statusText = 'Reddedildi';
        break;
      case PermissionStatus.permanentlyDenied:
        statusColor = Colors.red;
        statusText = 'Kalıcı Olarak Reddedildi';
        break;
      case PermissionStatus.restricted:
        statusColor = Colors.red;
        statusText = 'Kısıtlandı';
        break;
      case PermissionStatus.limited:
        statusColor = Colors.orange;
        statusText = 'Sınırlı';
        break;
      case PermissionStatus.provisional:
        statusColor = Colors.blue;
        statusText = 'Geçici';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: TamgaciConstants.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (status != PermissionStatus.granted)
            TextButton(
              onPressed: onRequest,
              child: Text(
                status == PermissionStatus.permanentlyDenied
                    ? 'Ayarlar'
                    : 'İzin Ver',
                style: GoogleFonts.poppins(
                  color: TamgaciConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Cihaz bilgileri bölümü
  Widget _buildDeviceInfoSection() {
    final deviceInfoAsync = ref.watch(deviceInfoProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone_android,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Cihaz Bilgileri',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            deviceInfoAsync.when(
              data: (deviceInfo) => Column(
                children: deviceInfo.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          '${entry.key}: ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: TamgaciConstants.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Text('Cihaz bilgileri yüklenirken hata oluştu'),
            ),
          ],
        ),
      ),
    );
  }

  /// Uygulama bilgileri bölümü
  Widget _buildAppInfoSection() {
    final appInfoAsync = ref.watch(appInfoProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Uygulama Bilgileri',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            appInfoAsync.when(
              data: (appInfo) => Column(
                children: appInfo.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          '${entry.key}: ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: TamgaciConstants.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Text('Uygulama bilgileri yüklenirken hata oluştu'),
            ),
          ],
        ),
      ),
    );
  }
}
