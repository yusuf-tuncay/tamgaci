// ========== NOTIFICATION REPOSITORY ==========
// lib/features/notifications/data/repositories/notification_repository.dart

import '../../domain/entities/notification.dart' as app_notification;

/// Bildirim repository interface
abstract class NotificationRepository {
  /// Tüm bildirimleri getir
  Future<List<app_notification.AppNotification>> getAllNotifications();

  /// Okunmamış bildirim sayısını getir
  Future<int> getUnreadCount();

  /// Bildirimi okundu olarak işaretle
  Future<void> markAsRead(String notificationId);

  /// Tüm bildirimleri okundu olarak işaretle
  Future<void> markAllAsRead();

  /// Bildirimi sil
  Future<void> deleteNotification(String notificationId);

  /// Yeni bildirim oluştur
  Future<void> createNotification(
    app_notification.AppNotification notification,
  );

  /// Bildirimleri temizle (eski bildirimleri sil)
  Future<void> clearOldNotifications({int daysToKeep = 30});
}

/// Bildirim repository implementasyonu
class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<app_notification.AppNotification>> getAllNotifications() async {
    // TODO: Gerçek veritabanı implementasyonu
    // Şimdilik test verileri döndür
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      app_notification.AppNotification(
        id: '1',
        title: 'Yeni Fatura Oluşturuldu',
        message: 'Fatura #INV-2024-001 başarıyla oluşturuldu.',
        type: app_notification.NotificationType.invoice,
        priority: app_notification.NotificationPriority.medium,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        relatedEntityId: 'inv-001',
        relatedEntityType: 'invoice',
      ),
      app_notification.AppNotification(
        id: '2',
        title: 'Stok Uyarısı',
        message: '5 ürün stok seviyesi kritik seviyede.',
        type: app_notification.NotificationType.inventory,
        priority: app_notification.NotificationPriority.high,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: false,
        relatedEntityType: 'inventory',
      ),
      app_notification.AppNotification(
        id: '3',
        title: 'Gelir Eklendi',
        message: 'Müşteri ödemesi alındı: ₺15,000',
        type: app_notification.NotificationType.income,
        priority: app_notification.NotificationPriority.low,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(hours: 12)),
        relatedEntityId: 'inc-001',
        relatedEntityType: 'income',
      ),
      app_notification.AppNotification(
        id: '4',
        title: 'Sistem Güncellemesi',
        message: 'Yeni özellikler eklendi. Detaylar için tıklayın.',
        type: app_notification.NotificationType.system,
        priority: app_notification.NotificationPriority.medium,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      app_notification.AppNotification(
        id: '5',
        title: 'Gider Kaydedildi',
        message: 'Ofis gideri kaydedildi: ₺2,500',
        type: app_notification.NotificationType.expense,
        priority: app_notification.NotificationPriority.low,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(days: 2)),
        relatedEntityId: 'exp-001',
        relatedEntityType: 'expense',
      ),
    ];
  }

  @override
  Future<int> getUnreadCount() async {
    // TODO: Gerçek veritabanı implementasyonu
    await Future.delayed(const Duration(milliseconds: 200));
    return 2; // Test verisi
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // TODO: Gerçek veritabanı implementasyonu
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> markAllAsRead() async {
    // TODO: Gerçek veritabanı implementasyonu
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    // TODO: Gerçek veritabanı implementasyonu
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> createNotification(
    app_notification.AppNotification notification,
  ) async {
    // TODO: Gerçek veritabanı implementasyonu
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> clearOldNotifications({int daysToKeep = 30}) async {
    // TODO: Gerçek veritabanı implementasyonu
    await Future.delayed(const Duration(milliseconds: 600));
  }
}
