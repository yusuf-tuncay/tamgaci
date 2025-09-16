// ========== NOTIFICATION PROVIDERS ==========
// lib/features/notifications/presentation/providers/notification_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification.dart' as app_notification;
import '../../data/repositories/notification_repository.dart';

/// Bildirimler için provider
final notificationsProvider =
    FutureProvider<List<app_notification.AppNotification>>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  return await repository.getAllNotifications();
});

/// Okunmamış bildirim sayısı için provider
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  return await repository.getUnreadCount();
});

/// Bildirimi okundu olarak işaretle
final markAsReadProvider =
    StateNotifierProvider<MarkAsReadNotifier, AsyncValue<void>>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return MarkAsReadNotifier(repository, ref);
});

/// Tüm bildirimleri okundu olarak işaretle
final markAllAsReadProvider =
    StateNotifierProvider<MarkAllAsReadNotifier, AsyncValue<void>>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return MarkAllAsReadNotifier(repository, ref);
});

/// Bildirimi sil
final deleteNotificationProvider =
    StateNotifierProvider<DeleteNotificationNotifier, AsyncValue<void>>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return DeleteNotificationNotifier(repository, ref);
});

/// Bildirim repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});

/// Mark as read notifier
class MarkAsReadNotifier extends StateNotifier<AsyncValue<void>> {
  final NotificationRepository _repository;
  final Ref _ref;

  MarkAsReadNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> markAsRead(String notificationId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAsRead(notificationId);
      state = const AsyncValue.data(null);
      // Refresh notifications
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsCountProvider);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

/// Mark all as read notifier
class MarkAllAsReadNotifier extends StateNotifier<AsyncValue<void>> {
  final NotificationRepository _repository;
  final Ref _ref;

  MarkAllAsReadNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> markAllAsRead() async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAllAsRead();
      state = const AsyncValue.data(null);
      // Refresh notifications
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsCountProvider);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

/// Delete notification notifier
class DeleteNotificationNotifier extends StateNotifier<AsyncValue<void>> {
  final NotificationRepository _repository;
  final Ref _ref;

  DeleteNotificationNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> deleteNotification(String notificationId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteNotification(notificationId);
      state = const AsyncValue.data(null);
      // Refresh notifications
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsCountProvider);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}
