import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/notifications/domain/entities/notification.dart';

/// Notification Firebase Model
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic> metadata;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    this.isRead = false,
    this.readAt,
    this.metadata = const {},
    this.relatedEntityId,
    this.relatedEntityType,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Domain entity'ye dönüştür
  AppNotification toDomain() {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      priority: priority,
      isRead: isRead,
      readAt: readAt,
      metadata: metadata,
      createdAt: createdAt,
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
    );
  }

  /// Domain entity'den oluştur
  factory NotificationModel.fromDomain(AppNotification notification,
      {required String userId}) {
    return NotificationModel(
      id: notification.id,
      userId: userId,
      title: notification.title,
      message: notification.message,
      type: notification.type,
      priority: notification.priority,
      isRead: notification.isRead,
      readAt: notification.readAt,
      metadata: notification.metadata ?? const {},
      relatedEntityId: notification.relatedEntityId,
      relatedEntityType: notification.relatedEntityType,
      createdAt: notification.createdAt,
      updatedAt: notification.createdAt,
    );
  }

  /// Firestore'dan oluştur
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: (data['message'] ?? data['body'] ?? '') as String,
      type: NotificationType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (p) => p.name == (data['priority'] ?? 'medium'),
        orElse: () => NotificationPriority.medium,
      ),
      isRead: data['isRead'] ?? false,
      readAt: data['readAt'] != null
          ? (data['readAt'] as Timestamp).toDate()
          : null,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      relatedEntityId: data['relatedEntityId'],
      relatedEntityType: data['relatedEntityType'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ??
          (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Firestore'a dönüştür
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'metadata': metadata,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Kopyalama metodu
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
    String? relatedEntityId,
    String? relatedEntityType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
