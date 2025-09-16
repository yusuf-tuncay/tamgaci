import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/notifications/domain/entities/notification.dart';

/// Notification Firebase DataSource
/// Firebase Firestore ile doğrudan etkileşimi yönetir.
class NotificationFirebaseDataSource {
  final FirebaseFirestore _firestore;
  // ignore: unused_field
  final FirebaseAuth _firebaseAuth;

  NotificationFirebaseDataSource(this._firestore, this._firebaseAuth);

  /// Kullanıcının tüm bildirimlerini getirir
  Future<List<AppNotification>> getAllNotifications({
    int? limit,
    int? offset,
  }) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => _notificationFromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all notifications', e);
      rethrow;
    }
  }

  /// Okunmamış bildirimleri getirir
  Future<List<AppNotification>> getUnreadNotifications({
    int? limit,
  }) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => _notificationFromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting unread notifications', e);
      rethrow;
    }
  }

  /// Bildirim türüne göre bildirimleri getirir
  Future<List<AppNotification>> getNotificationsByType(
    NotificationType type, {
    int? limit,
    int? offset,
  }) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .where('type', isEqualTo: type.name)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => _notificationFromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting notifications by type: ${type.name}', e);
      rethrow;
    }
  }

  /// Yeni bildirim oluşturur
  Future<AppNotification> createNotification(
      AppNotification notification) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final docRef = _firestore.collection('notifications').doc();
      final newNotification = AppNotification(
        id: docRef.id,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        priority: notification.priority,
        createdAt: notification.createdAt,
        readAt: notification.readAt,
        isRead: notification.isRead,
        metadata: notification.metadata,
        relatedEntityId: notification.relatedEntityId,
        relatedEntityType: notification.relatedEntityType,
      );

      final data = _notificationToFirestore(newNotification);
      data['userId'] = userId;
      await docRef.set(data);
      AppLogger.info('Notification created: ${newNotification.title}');
      return newNotification;
    } catch (e) {
      AppLogger.error('Error creating notification', e);
      rethrow;
    }
  }

  /// Bildirimi okundu olarak işaretler
  Future<void> markAsRead(String id) async {
    try {
      await _firestore.collection('notifications').doc(id).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Notification marked as read: $id');
    } catch (e) {
      AppLogger.error('Error marking notification as read: $id', e);
      rethrow;
    }
  }

  /// Tüm bildirimleri okundu olarak işaretler
  Future<void> markAllAsRead() async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      AppLogger.info('All notifications marked as read for user: $userId');
    } catch (e) {
      AppLogger.error('Error marking all notifications as read', e);
      rethrow;
    }
  }

  /// Bildirimi siler
  Future<void> deleteNotification(String id) async {
    try {
      await _firestore.collection('notifications').doc(id).delete();
      AppLogger.info('Notification deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting notification: $id', e);
      rethrow;
    }
  }

  /// Okunmamış bildirim sayısını getirir
  Future<int> getUnreadCount() async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) return 0;

      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting unread notification count', e);
      rethrow;
    }
  }

  /// Bildirimleri dinle (real-time)
  Stream<List<AppNotification>> watchNotifications({int? limit}) {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        return Stream.value([]);
      }

      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => _notificationFromFirestore(doc)).toList());
    } catch (e) {
      AppLogger.error('Error watching notifications', e);
      return Stream.value([]);
    }
  }

  /// Okunmamış bildirim sayısını dinle (real-time)
  Stream<int> watchUnreadCount() {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        return Stream.value(0);
      }

      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      AppLogger.error('Error watching unread count', e);
      return Stream.value(0);
    }
  }

  // Helper methods
  AppNotification _notificationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      relatedEntityId: data['relatedEntityId'],
      relatedEntityType: data['relatedEntityType'],
    );
  }

  Map<String, dynamic> _notificationToFirestore(AppNotification notification) {
    return {
      'title': notification.title,
      'message': notification.message,
      'type': notification.type.name,
      'priority': notification.priority.name,
      'isRead': notification.isRead,
      'readAt': notification.readAt != null
          ? Timestamp.fromDate(notification.readAt!)
          : null,
      'metadata': notification.metadata,
      'relatedEntityId': notification.relatedEntityId,
      'relatedEntityType': notification.relatedEntityType,
      'createdAt': Timestamp.fromDate(notification.createdAt),
    };
  }
}
