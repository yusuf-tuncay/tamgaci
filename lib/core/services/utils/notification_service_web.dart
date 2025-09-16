// ========== NOTIFICATION SERVICE (WEB) ==========
// No-op implementation for Web to avoid 'dart:ffi' transitive imports.

class NotificationService {
  const NotificationService();

  Future<void> initialize() async {}

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {}

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {}

  Future<void> cancelNotification(int id) async {}

  Future<void> cancelAllNotifications() async {}

  Future<List<dynamic>> getPendingNotifications() async => const [];
}


