// ========== NOTIFICATION ENTITY ==========
// lib/features/notifications/domain/entities/notification.dart

/// Bildirim türleri
enum NotificationType {
  invoice,
  expense,
  income,
  inventory,
  customer,
  supplier,
  system,
}

/// Bildirim öncelik seviyeleri
enum NotificationPriority { low, medium, high, urgent }

/// Bildirim entity
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final String? relatedEntityId;
  final String? relatedEntityType;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.readAt,
    required this.isRead,
    this.metadata,
    this.relatedEntityId,
    this.relatedEntityType,
  });

  /// JSON'dan entity oluştur
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      isRead: json['isRead'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      relatedEntityId: json['relatedEntityId'] as String?,
      relatedEntityType: json['relatedEntityType'] as String?,
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isRead': isRead,
      'metadata': metadata,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
    };
  }

  /// Okundu olarak işaretlenmiş kopya oluştur
  AppNotification copyWithRead() {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      priority: priority,
      createdAt: createdAt,
      readAt: DateTime.now(),
      isRead: true,
      metadata: metadata,
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
    );
  }

  /// Bildirim türüne göre icon
  String get typeIcon {
    switch (type) {
      case NotificationType.invoice:
        return '📄';
      case NotificationType.expense:
        return '💰';
      case NotificationType.income:
        return '💵';
      case NotificationType.inventory:
        return '📦';
      case NotificationType.customer:
        return '👤';
      case NotificationType.supplier:
        return '🏢';
      case NotificationType.system:
        return '⚙️';
    }
  }

  /// Öncelik seviyesine göre renk
  String get priorityColor {
    switch (priority) {
      case NotificationPriority.low:
        return '#4CAF50'; // Green
      case NotificationPriority.medium:
        return '#FF9800'; // Orange
      case NotificationPriority.high:
        return '#F44336'; // Red
      case NotificationPriority.urgent:
        return '#9C27B0'; // Purple
    }
  }

  /// Zaman farkını formatla
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification &&
        other.id == id &&
        other.title == title &&
        other.message == message &&
        other.type == type &&
        other.priority == priority &&
        other.createdAt == createdAt &&
        other.readAt == readAt &&
        other.isRead == isRead &&
        other.metadata == metadata &&
        other.relatedEntityId == relatedEntityId &&
        other.relatedEntityType == relatedEntityType;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      message,
      type,
      priority,
      createdAt,
      readAt,
      isRead,
      metadata,
      relatedEntityId,
      relatedEntityType,
    );
  }
}
