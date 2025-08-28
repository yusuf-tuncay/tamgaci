// ========== NOTIFICATION TILE WIDGET ==========
// lib/features/notifications/presentation/widgets/notification_tile.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../domain/entities/notification.dart' as app_notification;

/// Bildirim tile widget'ı
class NotificationTile extends StatelessWidget {
  final app_notification.AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: TamgaciConstants.errorColor,
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead
              ? TamgaciConstants.cardColor
              : TamgaciConstants.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
          border: Border.all(
            color: notification.isRead
                ? TamgaciConstants.borderColor
                : TamgaciConstants.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(TamgaciConstants.spaceMD),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getTypeColor(notification.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
            ),
            child: Center(
              child: Text(
                notification.typeIcon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: notification.isRead
                        ? FontWeight.w500
                        : FontWeight.w600,
                    color: notification.isRead
                        ? TamgaciConstants.textPrimary
                        : TamgaciConstants.textPrimary,
                  ),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: TamgaciConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: TamgaciConstants.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 12,
                    color: TamgaciConstants.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    notification.timeAgo,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: TamgaciConstants.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(
                        notification.priority,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        TamgaciConstants.radiusSM,
                      ),
                    ),
                    child: Text(
                      _getPriorityText(notification.priority),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _getPriorityColor(notification.priority),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  /// Bildirim türüne göre renk
  Color _getTypeColor(app_notification.NotificationType type) {
    switch (type) {
      case app_notification.NotificationType.invoice:
        return TamgaciConstants.primaryColor;
      case app_notification.NotificationType.expense:
        return TamgaciConstants.errorColor;
      case app_notification.NotificationType.income:
        return TamgaciConstants.successColor;
      case app_notification.NotificationType.inventory:
        return TamgaciConstants.warningColor;
      case app_notification.NotificationType.customer:
        return TamgaciConstants.infoColor;
      case app_notification.NotificationType.supplier:
        return TamgaciConstants.secondaryColor;
      case app_notification.NotificationType.system:
        return TamgaciConstants.textSecondary;
    }
  }

  /// Öncelik seviyesine göre renk
  Color _getPriorityColor(app_notification.NotificationPriority priority) {
    switch (priority) {
      case app_notification.NotificationPriority.low:
        return TamgaciConstants.successColor;
      case app_notification.NotificationPriority.medium:
        return TamgaciConstants.warningColor;
      case app_notification.NotificationPriority.high:
        return TamgaciConstants.errorColor;
      case app_notification.NotificationPriority.urgent:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  /// Öncelik seviyesine göre metin
  String _getPriorityText(app_notification.NotificationPriority priority) {
    switch (priority) {
      case app_notification.NotificationPriority.low:
        return 'Düşük';
      case app_notification.NotificationPriority.medium:
        return 'Orta';
      case app_notification.NotificationPriority.high:
        return 'Yüksek';
      case app_notification.NotificationPriority.urgent:
        return 'Acil';
    }
  }
}
