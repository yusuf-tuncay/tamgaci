// ========== lib/features/notifications/presentation/pages/notifications_page.dart ==========

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_tile.dart';

/// Bildirimler sayfası
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Bildirimler'),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: isDark
            ? TamgaciConstants.textPrimaryDark
            : TamgaciConstants.textPrimary,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(markAllAsReadProvider.notifier).markAllAsRead();
            },
            icon: const Icon(Icons.done_all),
            tooltip: 'Tümünü Okundu İşaretle',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: isDark
                          ? TamgaciConstants.textSecondaryDark
                          : TamgaciConstants.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz bildiriminiz yok',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? TamgaciConstants.textSecondaryDark
                            : TamgaciConstants.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yeni bildirimler burada görünecek',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark
                            ? TamgaciConstants.textSecondaryDark
                            : TamgaciConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () {
                    ref
                        .read(markAsReadProvider.notifier)
                        .markAsRead(notification.id);
                    // TODO: Navigate to relevant page based on notification type
                  },
                  onDismiss: () {
                    ref
                        .read(deleteNotificationProvider.notifier)
                        .deleteNotification(notification.id);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: TamgaciConstants.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bildirimler yüklenirken hata oluştu',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: TamgaciConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TamgaciConstants.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
