import 'dart:typed_data';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tamgaci/core/services/business/dashboard_service.dart';
import 'package:tamgaci/core/services/business/inventory_service.dart';
import 'package:tamgaci/core/services/business/transaction_service.dart';
import 'package:tamgaci/core/services/firebase/firebase_auth_service.dart';
import 'package:tamgaci/core/services/firebase/firebase_data_service.dart';
import 'package:tamgaci/core/services/firebase/firebase_notification_service.dart';
import 'package:tamgaci/core/services/utils/export_service.dart';
import 'package:tamgaci/core/services/utils/notification_service.dart';
import 'package:tamgaci/core/services/utils/permission_service.dart';
import 'package:tamgaci/core/cache/cache_manager.dart';
import 'package:tamgaci/core/cache/image_cache.dart';
import 'package:tamgaci/core/cache/data_cache.dart';

// Generate mocks for services
@GenerateMocks([
  DashboardService,
  InventoryService,
  TransactionService,
  FirebaseAuthService,
  FirebaseDataService,
  FirebaseNotificationService,
  ExportService,
  NotificationService,
  PermissionService,
  CacheManager,
  ImageCache,
  DataCache,
])
void main() {}

/// Mock dashboard service for testing
class MockDashboardService extends Mock implements DashboardService {}

/// Mock inventory service for testing
class MockInventoryService extends Mock implements InventoryService {}

/// Mock transaction service for testing
class MockTransactionService extends Mock implements TransactionService {}

/// Mock Firebase auth service for testing
class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

/// Mock Firebase data service for testing
class MockFirebaseDataService extends Mock implements FirebaseDataService {}

/// Mock Firebase notification service for testing
class MockFirebaseNotificationService extends Mock
    implements FirebaseNotificationService {}

/// Mock export service for testing
class MockExportService extends Mock implements ExportService {}

/// Mock notification service for testing
class MockNotificationService extends Mock implements NotificationService {}

/// Mock permission service for testing
class MockPermissionService extends Mock implements PermissionService {}

/// Mock cache manager for testing
class MockCacheManager extends Mock implements CacheManager {}

/// Mock image cache for testing
class MockImageCache extends Mock implements ImageCache {}

/// Mock data cache for testing
class MockDataCache extends Mock implements DataCache {}

/// Service test helpers
class ServiceTestHelpers {
  /// Setup mock dashboard service with default responses
  static void setupMockDashboardService(MockDashboardService mockService) {
    when(mockService.getDashboardSummary()).thenAnswer((_) async => {
          'totalSales': 10000.0,
          'totalPurchases': 8000.0,
          'totalCustomers': 50,
          'totalProducts': 100,
          'lowStockProducts': 5,
          'pendingInvoices': 10,
        });

    when(mockService.getSalesChartData(any, any)).thenAnswer((_) async => []);
    when(mockService.getPurchaseChartData(any, any))
        .thenAnswer((_) async => []);
    when(mockService.getTopCustomers(any)).thenAnswer((_) async => []);
    when(mockService.getTopProducts(any)).thenAnswer((_) async => []);
    when(mockService.getRecentTransactions(any)).thenAnswer((_) async => []);
  }

  /// Setup mock inventory service with default responses
  static void setupMockInventoryService(MockInventoryService mockService) {
    when(mockService.getStockLevel(any)).thenAnswer((_) async => 100);
    when(mockService.updateStock(any, any)).thenAnswer((_) async {
      return null;
    });
    when(mockService.getStockMovements(any)).thenAnswer((_) async => []);
    when(mockService.getLowStockProducts()).thenAnswer((_) async => []);
    when(mockService.getStockReport(any, any)).thenAnswer((_) async => {});
  }

  /// Setup mock transaction service with default responses
  static void setupMockTransactionService(MockTransactionService mockService) {
    when(mockService.recordTransaction(any))
        .thenAnswer((_) async => 'test_transaction_id');
    when(mockService.getCustomerBalance(any)).thenAnswer((_) async => 1000.0);
    when(mockService.updateCustomerBalance(any, any)).thenAnswer((_) async {
      return null;
    });
    when(mockService.getTransactionHistory(any)).thenAnswer((_) async => []);
    when(mockService.calculateTotalBalance()).thenAnswer((_) async => 5000.0);
  }

  /// Setup mock Firebase auth service with default responses
  static void setupMockFirebaseAuthService(
      MockFirebaseAuthService mockService) {
    when(mockService.signInWithEmailAndPassword(any, any))
        .thenAnswer((_) async => 'test_user_id');
    when(mockService.createUserWithEmailAndPassword(any, any))
        .thenAnswer((_) async => 'test_user_id');
    when(mockService.signOut()).thenAnswer((_) async {
      return null;
    });
    when(mockService.getCurrentUser()).thenAnswer((_) async => 'test_user_id');
    when(mockService.isSignedIn()).thenAnswer((_) async => true);
    when(mockService.sendPasswordResetEmail(any)).thenAnswer((_) async {
      return null;
    });
  }

  /// Setup mock Firebase data service with default responses
  static void setupMockFirebaseDataService(
      MockFirebaseDataService mockService) {
    when(mockService.getCollection(any)).thenAnswer((_) async => []);
    when(mockService.getDocument(any, any)).thenAnswer((_) async => {});
    when(mockService.setDocument(any, any, any)).thenAnswer((_) async {
      return null;
    });
    when(mockService.updateDocument(any, any, any)).thenAnswer((_) async {
      return null;
    });
    when(mockService.deleteDocument(any, any)).thenAnswer((_) async {
      return null;
    });
    when(mockService.queryCollection(any, any)).thenAnswer((_) async => []);
  }

  /// Setup mock Firebase notification service with default responses
  static void setupMockFirebaseNotificationService(
      MockFirebaseNotificationService mockService) {
    when(mockService.sendNotification(any, any, any))
        .thenAnswer((_) async => 'test_message_id');
    when(mockService.subscribeToTopic(any)).thenAnswer((_) async {});
    when(mockService.unsubscribeFromTopic(any)).thenAnswer((_) async {});
    when(mockService.getToken()).thenAnswer((_) async => 'test_token');
  }

  /// Setup mock export service with default responses
  static void setupMockExportService(MockExportService mockService) {
    when(mockService.exportCustomersToExcel(any))
        .thenAnswer((_) async => Uint8List(0));
    when(mockService.exportProductsToExcel(any))
        .thenAnswer((_) async => Uint8List(0));
    when(mockService.exportSalesToExcel(any))
        .thenAnswer((_) async => Uint8List(0));
    when(mockService.exportStockReportToPDF(products: any, summary: any))
        .thenAnswer((_) async => Uint8List(0));
    when(mockService.exportToCSV(data: any, headers: any))
        .thenAnswer((_) async => Uint8List(0));
  }

  /// Setup mock notification service with default responses
  static void setupMockNotificationService(
      MockNotificationService mockService) {
    when(mockService.showNotification(body: any, id: any, title: any))
        .thenAnswer((_) async {});
    when(mockService.showSuccessNotification(any)).thenAnswer((_) async {
      return null;
    });
    when(mockService.showErrorNotification(any)).thenAnswer((_) async {
      return null;
    });
    when(mockService.showWarningNotification(any)).thenAnswer((_) async {
      return null;
    });
    when(mockService.showInfoNotification(any)).thenAnswer((_) async {
      return null;
    });
  }

  /// Setup mock permission service with default responses
  static void setupMockPermissionService(MockPermissionService mockService) {
    when(mockService.requestPermission(any)).thenAnswer((_) async => true);
    when(mockService.checkPermission(any)).thenAnswer((_) async => true);
    when(mockService.isPermissionGranted(any)).thenAnswer((_) async => true);
    when(mockService.openAppSettings()).thenAnswer((_) async {
      return null;
    });
  }

  /// Setup mock cache manager with default responses
  static void setupMockCacheManager(MockCacheManager mockCacheManager) {
    when(mockCacheManager.get<Map<String, dynamic>>(any,
            fromJson: anyNamed('fromJson')))
        .thenAnswer((_) async => throw Exception('Not found'));
    when(mockCacheManager.set<Map<String, dynamic>>(any, any,
            expiry: anyNamed('expiry'), toJson: anyNamed('toJson')))
        .thenAnswer((_) async {});
    when(mockCacheManager.remove(any)).thenAnswer((_) async {});
    when(mockCacheManager.clear()).thenAnswer((_) async {});
    when(mockCacheManager.exists(any)).thenAnswer((_) async => false);
    when(mockCacheManager.getCacheSize()).thenAnswer((_) async => 0);
    when(mockCacheManager.getCacheInfo())
        .thenAnswer((_) async => const CacheInfo(
              totalSize: 0,
              memoryItems: 0,
              diskItems: 0,
              totalItems: 0,
              hitRate: 0.0,
              memoryHitRate: 0.0,
              diskHitRate: 0.0,
            ));
    when(mockCacheManager.cleanup()).thenAnswer((_) async {});
  }

  /// Setup mock image cache with default responses
  static void setupMockImageCache(MockImageCache mockImageCache) {
    when(mockImageCache.getCachedImage(any))
        .thenAnswer((_) async => throw Exception('Not found'));
    when(mockImageCache.cacheImage(any, any)).thenAnswer((_) async {});
    when(mockImageCache.removeCachedImage(any)).thenAnswer((_) async {});
    when(mockImageCache.clearAllImages()).thenAnswer((_) async {});
    when(mockImageCache.isImageCached(any)).thenAnswer((_) async => false);
    when(mockImageCache.getImageCacheInfo(any))
        .thenAnswer((_) async => throw Exception('Not found'));
    when(mockImageCache.getAllCachedImagesInfo()).thenAnswer((_) async => []);
    when(mockImageCache.getCacheSize()).thenAnswer((_) async => 0);
    when(mockImageCache.cleanupExpiredImages()).thenAnswer((_) async {});
    when(mockImageCache.preloadImages(any)).thenAnswer((_) async {});
  }

  /// Setup mock data cache with default responses
  static void setupMockDataCache(MockDataCache mockDataCache) {
    when(mockDataCache.cacheCustomers(any)).thenAnswer((_) async {});
    when(mockDataCache.getCachedCustomers()).thenAnswer((_) async => []);
    when(mockDataCache.cacheCustomer(any, any)).thenAnswer((_) async {});
    when(mockDataCache.getCachedCustomer(any))
        .thenAnswer((_) async => throw Exception('Not found'));
    when(mockDataCache.cacheProducts(any)).thenAnswer((_) async {});
    when(mockDataCache.getCachedProducts()).thenAnswer((_) async => []);
    when(mockDataCache.cacheProduct(any, any)).thenAnswer((_) async {});
    when(mockDataCache.getCachedProduct(any))
        .thenAnswer((_) async => throw Exception('Not found'));
    when(mockDataCache.cacheInvoices(any)).thenAnswer((_) async {});
    when(mockDataCache.getCachedInvoices()).thenAnswer((_) async => []);
    when(mockDataCache.cacheDashboardData(any)).thenAnswer((_) async {});
    when(mockDataCache.getCachedDashboardData())
        .thenAnswer((_) async => throw Exception('Not found'));
    when(mockDataCache.cacheReportData(any, any)).thenAnswer((_) async {});
    when(mockDataCache.getCachedReportData(any))
        .thenAnswer((_) async => throw Exception('Not found'));
    when(mockDataCache.cacheSearchResults(any, any)).thenAnswer((_) async {});
    when(mockDataCache.getCachedSearchResults(any))
        .thenAnswer((_) async => throw Exception('Not found'));
    when(mockDataCache.cacheUserPreferences(any)).thenAnswer((_) async {});
    when(mockDataCache.getCachedUserPreferences())
        .thenAnswer((_) async => throw Exception('Not found'));
    when(mockDataCache.clearDataTypeCache(any)).thenAnswer((_) async {});
    when(mockDataCache.clearAllDataCache()).thenAnswer((_) async {});
    when(mockDataCache.getCacheStatistics())
        .thenAnswer((_) async => DataCacheStats.empty());
    when(mockDataCache.preloadCriticalData()).thenAnswer((_) async {});
  }

  /// Verify service method was called
  static void verifyServiceMethodCalled(
      dynamic mockService, String methodName) {
    switch (methodName) {
      case 'getDashboardSummary':
        verify(mockService.getDashboardSummary()).called(1);
        break;
      case 'getStockLevel':
        verify(mockService.getStockLevel(any)).called(1);
        break;
      case 'recordTransaction':
        verify(mockService.recordTransaction(any)).called(1);
        break;
      case 'signIn':
        verify(mockService.signIn(any, any)).called(1);
        break;
      case 'exportCustomersToExcel':
        verify(mockService.exportCustomersToExcel()).called(1);
        break;
      case 'showNotification':
        verify(mockService.showNotification(any, any)).called(1);
        break;
      case 'requestPermission':
        verify(mockService.requestPermission(any)).called(1);
        break;
      case 'get':
        verify(mockService.get<Map<String, dynamic>>(any,
                fromJson: anyNamed('fromJson')))
            .called(1);
        break;
      case 'set':
        verify(mockService.set<Map<String, dynamic>>(any, any,
                expiry: anyNamed('expiry'), toJson: anyNamed('toJson')))
            .called(1);
        break;
      case 'getCachedImage':
        verify(mockService.getCachedImage(any)).called(1);
        break;
      case 'cacheImage':
        verify(mockService.cacheImage(any, any)).called(1);
        break;
      case 'cacheCustomers':
        verify(mockService.cacheCustomers(any)).called(1);
        break;
      case 'getCachedCustomers':
        verify(mockService.getCachedCustomers()).called(1);
        break;
    }
  }

  /// Verify service method was not called
  static void verifyServiceMethodNotCalled(
      dynamic mockService, String methodName) {
    switch (methodName) {
      case 'getDashboardSummary':
        verifyNever(mockService.getDashboardSummary());
        break;
      case 'getStockLevel':
        verifyNever(mockService.getStockLevel(any));
        break;
      case 'recordTransaction':
        verifyNever(mockService.recordTransaction(any));
        break;
      case 'signIn':
        verifyNever(mockService.signIn(any, any));
        break;
      case 'exportCustomersToExcel':
        verifyNever(mockService.exportCustomersToExcel());
        break;
      case 'showNotification':
        verifyNever(mockService.showNotification(any, any));
        break;
      case 'requestPermission':
        verifyNever(mockService.requestPermission(any));
        break;
      case 'get':
        verifyNever(mockService.get<Map<String, dynamic>>(any,
            fromJson: anyNamed('fromJson')));
        break;
      case 'set':
        verifyNever(mockService.set<Map<String, dynamic>>(any, any,
            expiry: anyNamed('expiry'), toJson: anyNamed('toJson')));
        break;
      case 'getCachedImage':
        verifyNever(mockService.getCachedImage(any));
        break;
      case 'cacheImage':
        verifyNever(mockService.cacheImage(any, any));
        break;
      case 'cacheCustomers':
        verifyNever(mockService.cacheCustomers(any));
        break;
      case 'getCachedCustomers':
        verifyNever(mockService.getCachedCustomers());
        break;
    }
  }

  /// Reset all service mocks
  static void resetAllServiceMocks(List<dynamic> mocks) {
    for (final mock in mocks) {
      reset(mock);
    }
  }

  /// Clear all service mocks
  static void clearAllServiceMocks(List<dynamic> mocks) {
    for (final mock in mocks) {
      clearInteractions(mock);
    }
  }
}
